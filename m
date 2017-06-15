From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH v2 11/11] kasan: rework Kconfig settings
Date: Thu, 15 Jun 2017 09:02:04 +0200
Message-ID: <CACT4Y+aNMBbkb8b+wwrdhVVxH-1NwgUm+vwXqUggmLnGK-8Q4w@mail.gmail.com>
References: <20170614211556.2062728-1-arnd@arndb.de> <20170614211556.2062728-12-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Kees Cook <keescook@chromium.org>,
        Ingo Molnar <mingo@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614211556.2062728-12-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2017 at 11:15 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> We get a lot of very large stack frames using gcc-7.0.1 with the default
> -fsanitize-address-use-after-scope --param asan-stack=1 options, which
> can easily cause an overflow of the kernel stack, e.g.
>
> drivers/acpi/nfit/core.c:2686:1: warning: the frame size of 4080 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/gpu/drm/amd/amdgpu/si.c:1756:1: warning: the frame size of 7304 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/gpu/drm/i915/gvt/handlers.c:2200:1: warning: the frame size of 43752 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/gpu/drm/vmwgfx/vmwgfx_drv.c:952:1: warning: the frame size of 6032 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/isdn/hardware/avm/b1.c:637:1: warning: the frame size of 13200 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/media/dvb-frontends/stv090x.c:3089:1: warning: the frame size of 5880 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/media/i2c/cx25840/cx25840-core.c:4964:1: warning: the frame size of 93992 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/net/wireless/ralink/rt2x00/rt2800lib.c:4994:1: warning: the frame size of 23928 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> drivers/staging/dgnc/dgnc_tty.c:2788:1: warning: the frame size of 7072 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> fs/ntfs/mft.c:2762:1: warning: the frame size of 7432 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> lib/atomic64_test.c:242:1: warning: the frame size of 12648 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>
> To reduce this risk, -fsanitize-address-use-after-scope is now split out
> into a separate Kconfig option, vhich cannot be selected at the same
> time as KMEMCHECK, leading to stack frames that are smaller than 2
> kilobytes most of the time on x86_64. An earlier version of this
> patch also prevented combining KASAN_EXTRA with KASAN_INLINE, but that
> is no longer necessary with gcc-7.0.1.
>
> A lot of warnings with KASAN_EXTRA go away if we disable KMEMCHECK,
> as -fsanitize-address-use-after-scope seems to understand the builtin
> memcpy, but adds checking code around an extern memcpy call. I had
> to work around a circular dependency, as DEBUG_SLAB/SLUB depended
> on !KMEMCHECK, while KASAN did it the other way round. Now we handle
> both the same way.
>
> All patches to get the frame size below 2048 bytes with CONFIG_KASAN=y
> and CONFIG_KASAN_EXTRA=n have been submitted along with this patch,
> so we can bring back that default now. KASAN_EXTRA=y still causes lots
> of warnings but now defaults to !COMPILE_TEST to disable it in
> allmodconfig, and it remains disabled in all other defconfigs since
> it is a new option.
>
> This reverts parts of commit commit 3f181b4 ("lib/Kconfig.debug:
> disable -Wframe-larger-than warnings with KASAN=y").
>
> I experimented a bit more with smaller stack frames and have another
> follow-up series that reduces the warning limit for 64-bit architectures
> to 1280 bytes and 1536 when CONFIG_KASAN (but not KASAN_EXTRA) is
> enabled, this requires another ~25 patches to address the additional
> warnings. I also have patches for all KASAN_EXTRA warnings, but we
> should look at those separately and then decide whether to remove
> it completely, leaving out -fsanitize-address-use-after-scope.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  lib/Kconfig.debug      |  4 ++--
>  lib/Kconfig.kasan      | 11 ++++++++++-
>  lib/Kconfig.kmemcheck  |  1 +
>  scripts/Makefile.kasan |  3 +++
>  4 files changed, 16 insertions(+), 3 deletions(-)
>
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index ddbef2cac189..02ec4a4da7b1 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -217,7 +217,7 @@ config ENABLE_MUST_CHECK
>  config FRAME_WARN
>         int "Warn for stack frames larger than (needs gcc 4.4)"
>         range 0 8192
> -       default 0 if KASAN
> +       default 3072 if KASAN_EXTRA
>         default 2048 if GCC_PLUGIN_LATENT_ENTROPY
>         default 1024 if !64BIT
>         default 2048 if 64BIT
> @@ -500,7 +500,7 @@ config DEBUG_OBJECTS_ENABLE_DEFAULT
>
>  config DEBUG_SLAB
>         bool "Debug slab memory allocations"
> -       depends on DEBUG_KERNEL && SLAB && !KMEMCHECK
> +       depends on DEBUG_KERNEL && SLAB && !KMEMCHECK && !KASAN
>         help
>           Say Y here to have the kernel do limited verification on memory
>           allocation as well as poisoning memory on free to catch use of freed
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index bd38aab05929..4d17a8f4742f 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -5,7 +5,7 @@ if HAVE_ARCH_KASAN
>
>  config KASAN
>         bool "KASan: runtime memory debugger"
> -       depends on SLUB || (SLAB && !DEBUG_SLAB)
> +       depends on SLUB || SLAB
>         select CONSTRUCTORS
>         select STACKDEPOT
>         help
> @@ -20,6 +20,15 @@ config KASAN
>           Currently CONFIG_KASAN doesn't work with CONFIG_DEBUG_SLAB
>           (the resulting kernel does not boot).
>
> +config KASAN_EXTRA
> +       bool "KAsan: extra checks"
> +       depends on KASAN && !COMPILE_TEST
> +       help
> +         This enables further checks in the kernel address sanitizer, for now
> +         it only includes the address-use-after-scope check that can lead
> +         to excessive kernel stack usage, frame size warnings and longer
> +         compile time.
> +
>  choice
>         prompt "Instrumentation type"
>         depends on KASAN
> diff --git a/lib/Kconfig.kmemcheck b/lib/Kconfig.kmemcheck
> index 846e039a86b4..58b9f3f81dc8 100644
> --- a/lib/Kconfig.kmemcheck
> +++ b/lib/Kconfig.kmemcheck
> @@ -7,6 +7,7 @@ menuconfig KMEMCHECK
>         bool "kmemcheck: trap use of uninitialized memory"
>         depends on DEBUG_KERNEL
>         depends on !X86_USE_3DNOW
> +       depends on !KASAN_EXTRA


KASAN is not meant to work with KMEMCHECK. I am not sure if it even
works, and it's definitely unmaintained. Even if it works now, I am
not sure what could be the intention of somebody running that
combination.
So I think we should do: depends on !KASAN
Will it make things simper for you?


>         depends on SLUB || SLAB
>         depends on !CC_OPTIMIZE_FOR_SIZE
>         depends on !FUNCTION_TRACER
> diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
> index 9576775a86f6..3b3148faf866 100644
> --- a/scripts/Makefile.kasan
> +++ b/scripts/Makefile.kasan
> @@ -29,5 +29,8 @@ else
>      endif
>  endif
>
> +ifdef CONFIG_KASAN_EXTRA
>  CFLAGS_KASAN += $(call cc-option, -fsanitize-address-use-after-scope)
>  endif
> +
> +endif
> --
> 2.9.0
