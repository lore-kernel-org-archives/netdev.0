From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Thu, 09 Feb 2017 18:00:42 +0100
Message-ID: <4145102.8mea7fgqQV@wuerfel>
References: <20170208211843.2822208-1-arnd@arndb.de> <CAK8P3a1FLFG7NvTEPNQB6Gam2y7O3K+5T_cmQg-rOfT4TKNfnA@mail.gmail.com> <CACT4Y+bpoud4y2N0xkatG8N5we6+scqYhCZhvaXJSBQiVnznTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bpoud4y2N0xkatG8N5we6+scqYhCZhvaXJSBQiVnznTQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, February 9, 2017 4:51:25 PM CET Dmitry Vyukov wrote:
> On Thu, Feb 9, 2017 at 3:33 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> >>>
> >>> Thanks for the list, that looks very helpful. The ones I found myself
> >>> seem to be a strict (and small) subset of those, using gcc-7.0.1 on x86-64
> >>> with allmodconfig and a few hundred randconfig builds. Which compiler
> >>> version did you use for your testing? If new versions are better than old
> >>> ones, we could start by fixing the ones that are still present in gcc-6 and
> >>> gcc-7, and making the warning conditionally on the compiler version.
> >>>
> >>> Another idea might be to separate out asan_stack=1 into a separate
> >>> Kconfig option and warn if that is enabled with compilers that are known
> >>> to be relatively bad it keeping the stack small.
> >>
> >>
> >> Mine is gcc version 7.0.0 20161208. Make sure you enable KASAN_INLINE
> >> and I also enabled CONFIG_KCOV. Other than that I just did
> >> allyesconfig + make -k.
> >
> > Ok, I see my mistake now: On the allmodconfig build, I had KASAN_INLINE
> > disabled, which made the problem go away for almost all files (almost all
> > frame sizes are below 2048 bytes, except for the two issues I posted patches
> > for (hisilicon ethernet driver, and nla_put_* users).
> >
> > On the randconfig build test, I have a long series of patches applied that
> > address all known warnings, including my earlier "kasan: turn off
> > -fsanitize-address-use-after-scope for now" (see
> > https://patchwork.kernel.org/patch/9442323/). Without
> > -fsanitize-address-use-after-scope, the problem is also mostly gone
> > (a few cases show up in drivers/media/, and also in block/sed-opal.c
> > and drivers/tty/vt/keyboard.c). I now have initial patches for all of
> > them to bring the stack size below 2048 bytes.
> >
> > As far as I can see, the remaining problems with scary stack frame sizes
> > you found only show up with the combination of all three: KASAN_INLINE,
> > asan_stack=1 and -fsanitize-address-use-after-scope. If all three were
> > separately configurable and we merge the patches I made, I think we could
> > enable the normal 2048 byte warning in all configurations that have at least
> > one of the turned off, but I don't know which of those combinations would
> > actually be sensible for production kernels.
> 
> FWIW I use all of them (+KCOV which is additional instrumentation).
> If you ask which is the least important one, it is
> -fsanitize-address-use-after-scope. I have not see any single report
> due to it (probably due to kernel coding style).

Ok, I'm testing with this patch now and will let you know if I run
into any other warnings on my x86 randconfig build. I'll also try
to get some results from other compiler versions and architectures.

Let me know what you think of this approach.

	Arnd

>From 119968322aa83f8039531d704e5f1cf24e680680 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 9 Feb 2017 17:45:59 +0100
Subject: [PATCH] kasan: make use-after-scope sanitizer optional

We get a lot of very large stack frames when combining CONFIG_KASAN_INLINE
with the default -fsanitize-address-use-after-scope --param asan-stack=1
options, which can easily cause an overflow of the kernel stack, e.g.

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
into a separate Kconfig option, which cannot be selected at the same time
as CONFIG_KASAN_INLINE, leading to stack frames that are smaller than 2
kilobytes most of the time on x86_64. Now we can turn on the warning again
that was disabled in commit 3f181b4 ("lib/Kconfig.debug: disable
-Wframe-larger-than warnings with KASAN=y").

The hope is that we can fix all code that still produces warnings, so far
I have found four areas that are still affected (netlink, hisi-hns,
dvb and tty/keyboard), and I have patches for all of them.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 554f4c37e72d..7a1657ed9183 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -216,7 +216,6 @@ config ENABLE_MUST_CHECK
 config FRAME_WARN
 	int "Warn for stack frames larger than (needs gcc 4.4)"
 	range 0 8192
-	default 0 if KASAN
 	default 2048 if GCC_PLUGIN_LATENT_ENTROPY
 	default 1024 if !64BIT
 	default 2048 if 64BIT
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index bd38aab05929..0731c945c85a 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
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
@@ -36,6 +45,7 @@ config KASAN_OUTLINE
 
 config KASAN_INLINE
 	bool "Inline instrumentation"
+	depends on !KASAN_EXTRA
 	help
 	  Compiler directly inserts code checking shadow memory before
 	  memory accesses. This is faster than outline (in some workloads
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
