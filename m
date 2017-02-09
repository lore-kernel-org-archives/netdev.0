From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Thu, 9 Feb 2017 15:33:24 +0100
Message-ID: <CAK8P3a1FLFG7NvTEPNQB6Gam2y7O3K+5T_cmQg-rOfT4TKNfnA@mail.gmail.com>
References: <20170208211843.2822208-1-arnd@arndb.de> <CACT4Y+ZCZPh8be8zL1zNt=mqW586ngybiZ66b4Wc7Jt03qqtCw@mail.gmail.com>
 <CAK8P3a3uQJTxRjo+BwLqaiPnwZ7abGwj341UiLi_mhz1QQpY9w@mail.gmail.com> <CACT4Y+anR0oC_BXBOKW+SqfFEd_a4BXVcEPXr+4tE5XhuwF6BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
In-Reply-To: <CACT4Y+anR0oC_BXBOKW+SqfFEd_a4BXVcEPXr+4tE5XhuwF6BA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2017 at 1:46 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Feb 9, 2017 at 12:55 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Thu, Feb 9, 2017 at 12:28 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Wed, Feb 8, 2017 at 10:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>
>> Thanks for the list, that looks very helpful. The ones I found myself
>> seem to be a strict (and small) subset of those, using gcc-7.0.1 on x86-64
>> with allmodconfig and a few hundred randconfig builds. Which compiler
>> version did you use for your testing? If new versions are better than old
>> ones, we could start by fixing the ones that are still present in gcc-6 and
>> gcc-7, and making the warning conditionally on the compiler version.
>>
>> Another idea might be to separate out asan_stack=1 into a separate
>> Kconfig option and warn if that is enabled with compilers that are known
>> to be relatively bad it keeping the stack small.
>
>
> Mine is gcc version 7.0.0 20161208. Make sure you enable KASAN_INLINE
> and I also enabled CONFIG_KCOV. Other than that I just did
> allyesconfig + make -k.

Ok, I see my mistake now: On the allmodconfig build, I had KASAN_INLINE
disabled, which made the problem go away for almost all files (almost all
frame sizes are below 2048 bytes, except for the two issues I posted patches
for (hisilicon ethernet driver, and nla_put_* users).

On the randconfig build test, I have a long series of patches applied that
address all known warnings, including my earlier "kasan: turn off
-fsanitize-address-use-after-scope for now" (see
https://patchwork.kernel.org/patch/9442323/). Without
-fsanitize-address-use-after-scope, the problem is also mostly gone
(a few cases show up in drivers/media/, and also in block/sed-opal.c
and drivers/tty/vt/keyboard.c). I now have initial patches for all of
them to bring the stack size below 2048 bytes.

As far as I can see, the remaining problems with scary stack frame sizes
you found only show up with the combination of all three: KASAN_INLINE,
asan_stack=1 and -fsanitize-address-use-after-scope. If all three were
separately configurable and we merge the patches I made, I think we could
enable the normal 2048 byte warning in all configurations that have at least
one of the turned off, but I don't know which of those combinations would
actually be sensible for production kernels.

      Arnd
