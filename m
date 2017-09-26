From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH v4 9/9] kasan: rework Kconfig settings
Date: Tue, 26 Sep 2017 22:36:38 +0300
Message-ID: <aeb9c144-10a6-53c2-89ba-cc7864f254e1@virtuozzo.com>
References: <20170922212930.620249-1-arnd@arndb.de>
 <20170922212930.620249-10-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>,
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
        =?UTF-8?Q?Martin_Li=c5=a1ka?= <marxin@gcc.gnu.org>
To: Arnd Bergmann <arnd@arndb.de>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-10-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2017 12:29 AM, Arnd Bergmann wrote:
> We get a lot of very large stack frames using gcc-7.0.1 with the default
> -fsanitize-address-use-after-scope --param asan-stack=1 options, which
> can easily cause an overflow of the kernel stack, e.g.
> 
> drivers/gpu/drm/i915/gvt/handlers.c:2407:1: error: the frame size of 31216 bytes is larger than 2048 bytes
> drivers/net/wireless/ralink/rt2x00/rt2800lib.c:5650:1: error: the frame size of 23632 bytes is larger than 2048 bytes
> drivers/scsi/fnic/fnic_trace.c:451:1: error: the frame size of 5152 bytes is larger than 2048 bytes
> fs/btrfs/relocation.c:1202:1: error: the frame size of 4256 bytes is larger than 2048 bytes
> fs/fscache/stats.c:287:1: error: the frame size of 6552 bytes is larger than 2048 bytes
> lib/atomic64_test.c:250:1: error: the frame size of 12616 bytes is larger than 2048 bytes
> mm/vmscan.c:1367:1: error: the frame size of 5080 bytes is larger than 2048 bytes
> net/wireless/nl80211.c:1905:1: error: the frame size of 4232 bytes is larger than 2048 bytes
> 
> To reduce this risk, -fsanitize-address-use-after-scope is now split
> out into a separate CONFIG_KASAN_EXTRA Kconfig option, leading to stack
> frames that are smaller than 2 kilobytes most of the time on x86_64. An
> earlier version of this patch also prevented combining KASAN_EXTRA with
> KASAN_INLINE, but that is no longer necessary with gcc-7.0.1.
> 
> A lot of warnings with KASAN_EXTRA go away if we disable KMEMCHECK,
> as -fsanitize-address-use-after-scope seems to understand the builtin
> memcpy, but adds checking code around an extern memcpy call. I had to work
> around a circular dependency, as DEBUG_SLAB/SLUB depended on !KMEMCHECK,
> while KASAN did it the other way round. Now we handle both the same way
> and make KASAN and KMEMCHECK mutually exclusive.
> 
> All patches to get the frame size below 2048 bytes with CONFIG_KASAN=y
> and CONFIG_KASAN_EXTRA=n have been submitted along with this patch, so
> we can bring back that default now. KASAN_EXTRA=y still causes lots of
> warnings but now defaults to !COMPILE_TEST to disable it in allmodconfig,
> and it remains disabled in all other defconfigs since it is a new option.
> I arbitrarily raise the warning limit for KASAN_EXTRA to 3072 to reduce
> the noise, but an allmodconfig kernel still has around 50 warnings
> on gcc-7.
> 
> I experimented a bit more with smaller stack frames and have another
> follow-up series that reduces the warning limit for 64-bit architectures
> to 1280 bytes (without CONFIG_KASAN).
> 
> With earlier versions of this patch series, I also had patches to
> address the warnings we get with KASAN and/or KASAN_EXTRA, using a
> "noinline_if_stackbloat" annotation. That annotation now got replaced with
> a gcc-8 bugfix (see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715)
> and a workaround for older compilers, which means that KASAN_EXTRA is
> now just as bad as before and will lead to an instant stack overflow in
> a few extreme cases.
> 
> This reverts parts of commit commit 3f181b4 ("lib/Kconfig.debug: disable
> -Wframe-larger-than warnings with KASAN=y").
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
