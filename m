From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v4 9/9] kasan: rework Kconfig settings
Date: Fri, 22 Sep 2017 23:29:20 +0200
Message-ID: <20170922212930.620249-10-arnd@arndb.de>
References: <20170922212930.620249-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, kasan-dev@googlegroups.com,
        linux-kbuild@vger.kernel.org, Jakub Jelinek <jakub@gcc.gnu.org>,
        =?UTF-8?q?Martin=20Li=C5=A1ka?= <marxin@gcc.gnu.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a lot of very large stack frames using gcc-7.0.1 with the default
-fsanitize-address-use-after-scope --param asan-stack=1 options, which
can easily cause an overflow of the kernel stack, e.g.

drivers/gpu/drm/i915/gvt/handlers.c:2407:1: error: the frame size of 31216 bytes is larger than 2048 bytes
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:5650:1: error: the frame size of 23632 bytes is larger than 2048 bytes
drivers/scsi/fnic/fnic_trace.c:451:1: error: the frame size of 5152 bytes is larger than 2048 bytes
fs/btrfs/relocation.c:1202:1: error: the frame size of 4256 bytes is larger than 2048 bytes
fs/fscache/stats.c:287:1: error: the frame size of 6552 bytes is larger than 2048 bytes
lib/atomic64_test.c:250:1: error: the frame size of 12616 bytes is larger than 2048 bytes
mm/vmscan.c:1367:1: error: the frame size of 5080 bytes is larger than 2048 bytes
net/wireless/nl80211.c:1905:1: error: the frame size of 4232 bytes is larger than 2048 bytes

To reduce this risk, -fsanitize-address-use-after-scope is now split
out into a separate CONFIG_KASAN_EXTRA Kconfig option, leading to stack
frames that are smaller than 2 kilobytes most of the time on x86_64. An
earlier version of this patch also prevented combining KASAN_EXTRA with
KASAN_INLINE, but that is no longer necessary with gcc-7.0.1.

A lot of warnings with KASAN_EXTRA go away if we disable KMEMCHECK,
as -fsanitize-address-use-after-scope seems to understand the builtin
memcpy, but adds checking code around an extern memcpy call. I had to work
around a circular dependency, as DEBUG_SLAB/SLUB depended on !KMEMCHECK,
while KASAN did it the other way round. Now we handle both the same way
and make KASAN and KMEMCHECK mutually exclusive.

All patches to get the frame size below 2048 bytes with CONFIG_KASAN=y
and CONFIG_KASAN_EXTRA=n have been submitted along with this patch, so
we can bring back that default now. KASAN_EXTRA=y still causes lots of
warnings but now defaults to !COMPILE_TEST to disable it in allmodconfig,
and it remains disabled in all other defconfigs since it is a new option.
I arbitrarily raise the warning limit for KASAN_EXTRA to 3072 to reduce
the noise, but an allmodconfig kernel still has around 50 warnings
on gcc-7.

I experimented a bit more with smaller stack frames and have another
follow-up series that reduces the warning limit for 64-bit architectures
to 1280 bytes (without CONFIG_KASAN).

With earlier versions of this patch series, I also had patches to
address the warnings we get with KASAN and/or KASAN_EXTRA, using a
"noinline_if_stackbloat" annotation. That annotation now got replaced with
a gcc-8 bugfix (see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715)
and a workaround for older compilers, which means that KASAN_EXTRA is
now just as bad as before and will lead to an instant stack overflow in
a few extreme cases.

This reverts parts of commit commit 3f181b4 ("lib/Kconfig.debug: disable
-Wframe-larger-than warnings with KASAN=y").

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 lib/Kconfig.debug      |  4 ++--
 lib/Kconfig.kasan      | 13 ++++++++++++-
 lib/Kconfig.kmemcheck  |  1 +
 scripts/Makefile.kasan |  3 +++
 4 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index b19c491cbc4e..5755875d4a80 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -217,7 +217,7 @@ config ENABLE_MUST_CHECK
 config FRAME_WARN
 	int "Warn for stack frames larger than (needs gcc 4.4)"
 	range 0 8192
-	default 0 if KASAN
+	default 3072 if KASAN_EXTRA
 	default 2048 if GCC_PLUGIN_LATENT_ENTROPY
 	default 1024 if !64BIT
 	default 2048 if 64BIT
@@ -503,7 +503,7 @@ config DEBUG_OBJECTS_ENABLE_DEFAULT
 
 config DEBUG_SLAB
 	bool "Debug slab memory allocations"
-	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK
+	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK && !KASAN
 	help
 	  Say Y here to have the kernel do limited verification on memory
 	  allocation as well as poisoning memory on free to catch use of freed
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index bd38aab05929..db799e6e9dba 100644
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
@@ -20,6 +20,17 @@ config KASAN
 	  Currently CONFIG_KASAN doesn't work with CONFIG_DEBUG_SLAB
 	  (the resulting kernel does not boot).
 
+config KASAN_EXTRA
+	bool "KAsan: extra checks"
+	depends on KASAN && DEBUG_KERNEL && !COMPILE_TEST
+	help
+	  This enables further checks in the kernel address sanitizer, for now
+	  it only includes the address-use-after-scope check that can lead
+	  to excessive kernel stack usage, frame size warnings and longer
+	  compile time.
+	  https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715 has more
+
+
 choice
 	prompt "Instrumentation type"
 	depends on KASAN
diff --git a/lib/Kconfig.kmemcheck b/lib/Kconfig.kmemcheck
index 846e039a86b4..1a534e638635 100644
--- a/lib/Kconfig.kmemcheck
+++ b/lib/Kconfig.kmemcheck
@@ -7,6 +7,7 @@ menuconfig KMEMCHECK
 	bool "kmemcheck: trap use of uninitialized memory"
 	depends on DEBUG_KERNEL
 	depends on !X86_USE_3DNOW
+	depends on !KASAN
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
