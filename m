From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 26/26] kasan: rework Kconfig settings
Date: Thu,  2 Mar 2017 17:38:34 +0100
Message-ID: <20170302163834.2273519-27-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a lot of very large stack frames using gcc-7.0.1 with the default
-fsanitize-address-use-after-scope --param asan-stack=1 options, which
can easily cause an overflow of the kernel stack, e.g.

drivers/acpi/nfit/core.c:2686:1: warning: the frame size of 4080 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/gpu/drm/amd/amdgpu/si.c:1756:1: warning: the frame size of 7304 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/gpu/drm/i915/gvt/handlers.c:2200:1: warning: the frame size of 43752 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/gpu/drm/vmwgfx/vmwgfx_drv.c:952:1: warning: the frame size of 6032 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/isdn/hardware/avm/b1.c:637:1: warning: the frame size of 13200 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/media/dvb-frontends/stv090x.c:3089:1: warning: the frame size of 5880 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/media/i2c/cx25840/cx25840-core.c:4964:1: warning: the frame size of 93992 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:4994:1: warning: the frame size of 23928 bytes is larger than 2048 bytes [-Wframe-larger-than=]
drivers/staging/dgnc/dgnc_tty.c:2788:1: warning: the frame size of 7072 bytes is larger than 2048 bytes [-Wframe-larger-than=]
fs/ntfs/mft.c:2762:1: warning: the frame size of 7432 bytes is larger than 2048 bytes [-Wframe-larger-than=]
lib/atomic64_test.c:242:1: warning: the frame size of 12648 bytes is larger than 2048 bytes [-Wframe-larger-than=]

To reduce this risk, -fsanitize-address-use-after-scope is now split out
into a separate Kconfig option, vhich cannot be selected at the same
time as KMEMCHECK, leading to stack frames that are smaller than 2
kilobytes most of the time on x86_64. An earlier version of this
patch also prevented combining KASAN_EXTRA with KASAN_INLINE, but that
is no longer necessary with the latest gcc-7.0.1 snapshot.

A lot of warnings with KASAN_EXTRA go away if we disable KMEMCHECK,
as -fsanitize-address-use-after-scope seems to understand the builtin
memcpy, but adds checking code around an extern memcpy call. I had
to work around a circular dependency, as DEBUG_SLAB/SLUB depended
on !KMEMCHECK, while KASAN did it the other way round. Now we handle
both the same way.

All patches to get the frame size below 3072 bytes with KASAN_EXTRA,
and below 2048 bytes without it have been submitted, so we can make
those the default now. Note that KASAN is only supported on arm64
and x86_64 at the moment, and both use 2048 byte stacks by default.
This reverts parts of commit commit 3f181b4 ("lib/Kconfig.debug:
disable -Wframe-larger-than warnings with KASAN=y").

I experimented a bit more with smaller stack frames and have another
follow-up series that reduces the warning limit for 64-bit architectures
to 1280 bytes and 1536 when CONFIG_KASAN (but not KASAN_EXTRA) is
enabled, this requires another ~25 patches to address the additional
warnings.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 lib/Kconfig.debug      |  9 ++++-----
 lib/Kconfig.kasan      | 11 ++++++++++-
 lib/Kconfig.kmemcheck  |  1 +
 scripts/Makefile.kasan |  3 +++
 4 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 97d62c2da6c2..27c838c40a36 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -216,10 +216,9 @@ config ENABLE_MUST_CHECK
 config FRAME_WARN
 	int "Warn for stack frames larger than (needs gcc 4.4)"
 	range 0 8192
-	default 0 if KASAN
-	default 2048 if GCC_PLUGIN_LATENT_ENTROPY
+	default 3072 if KASAN_EXTRA
 	default 1024 if !64BIT
-	default 2048 if 64BIT
+	default 1280 if 64BIT
 	help
 	  Tell gcc to warn at build time for stack frames larger than this.
 	  Setting this too low will cause a lot of warnings.
@@ -499,7 +498,7 @@ config DEBUG_OBJECTS_ENABLE_DEFAULT
 
 config DEBUG_SLAB
 	bool "Debug slab memory allocations"
-	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK
+	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK && !KASAN
 	help
 	  Say Y here to have the kernel do limited verification on memory
 	  allocation as well as poisoning memory on free to catch use of freed
@@ -511,7 +510,7 @@ config DEBUG_SLAB_LEAK
 
 config SLUB_DEBUG_ON
 	bool "SLUB debugging on by default"
-	depends on SLUB && SLUB_DEBUG && !KMEMCHECK
+	depends on SLUB && SLUB_DEBUG && !KMEMCHECK && !KASAN
 	default n
 	help
 	  Boot with debugging on by default. SLUB boots by default with
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index bd38aab05929..e88ce7cc13bb 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -5,7 +5,7 @@ if HAVE_ARCH_KASAN
 
 config KASAN
 	bool "KASan: runtime memory debugger"
-	depends on SLUB || (SLAB && !DEBUG_SLAB)
+	depends on SLUB || SLAB
 	select CONSTRUCTORS
 	select STACKDEPOT
 	help
@@ -20,6 +20,15 @@ config KASAN
 	  Currently CONFIG_KASAN doesn't work with CONFIG_DEBUG_SLAB
 	  (the resulting kernel does not boot).
 
+config KASAN_EXTRA
+	bool "KAsan: extra checks"
+	depends on KASAN
+	help
+	  This enables further checks in the kernel address sanitizer, for now
+	  it only includes the address-use-after-scope check which requires the
+	  use of KASAN_OUTLINE to avoid excessive kernel stack frame sizes that
+	  might lead to stack overflows.
+
 choice
 	prompt "Instrumentation type"
 	depends on KASAN
diff --git a/lib/Kconfig.kmemcheck b/lib/Kconfig.kmemcheck
index 846e039a86b4..58b9f3f81dc8 100644
--- a/lib/Kconfig.kmemcheck
+++ b/lib/Kconfig.kmemcheck
@@ -7,6 +7,7 @@ menuconfig KMEMCHECK
 	bool "kmemcheck: trap use of uninitialized memory"
 	depends on DEBUG_KERNEL
 	depends on !X86_USE_3DNOW
+	depends on !KASAN_EXTRA
 	depends on SLUB || SLAB
 	depends on !CC_OPTIMIZE_FOR_SIZE
 	depends on !FUNCTION_TRACER
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 9576775a86f6..3b3148faf866 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -29,5 +29,8 @@ else
     endif
 endif
 
+ifdef CONFIG_KASAN_EXTRA
 CFLAGS_KASAN += $(call cc-option, -fsanitize-address-use-after-scope)
 endif
+
+endif
-- 
2.9.0
