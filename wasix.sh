#!/bin/bash

set -xe

if [[ -z "${WASI_SDK_PATH}" ]]; then
    echo "WASI_SDK_PATH environment variable is not set."
    exit 1
fi

if [[ -z "${WASIX_SYSROOT}" ]]; then
    echo "WASIX_SYSROOT environment variable is not set. Using the default"
    exit 1
fi

export RANLIB="$WASI_SDK_PATH/bin/ranlib"
export AR="$WASI_SDK_PATH/bin/ar"
export NM="$WASI_SDK_PATH/bin/nm"
export CC="$WASI_SDK_PATH/bin/clang"
export CXX="$WASI_SDK_PATH/bin/clang"
export CFLAGS="\
--sysroot=$WASIX_SYSROOT \
--target=wasm32-wasi \
-matomics \
-mbulk-memory \
-mmutable-globals \
-pthread \
-mthread-model posix \
-ftls-model=local-exec \
-fno-trapping-math \
-D_WASI_EMULATED_MMAN \
-D_WASI_EMULATED_SIGNAL \
-D_WASI_EMULATED_PROCESS_CLOCKS \
-DUSE_TIMEGM \
-DOPENSSL_NO_SECURE_MEMORY \
-DOPENSSL_NO_DGRAM \
-DOPENSSL_THREADS \
-O3 \
-g \
-flto"

./configure --enable-static --disable-shared --host=wasm32-wasi --without-test --without-cxx-binding

make -j4

$RANLIB libs/libncurses.a