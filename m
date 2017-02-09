From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Thu, 9 Feb 2017 13:46:06 +0100
Message-ID: <CACT4Y+anR0oC_BXBOKW+SqfFEd_a4BXVcEPXr+4tE5XhuwF6BA@mail.gmail.com>
References: <20170208211843.2822208-1-arnd@arndb.de> <CACT4Y+ZCZPh8be8zL1zNt=mqW586ngybiZ66b4Wc7Jt03qqtCw@mail.gmail.com>
 <CAK8P3a3uQJTxRjo+BwLqaiPnwZ7abGwj341UiLi_mhz1QQpY9w@mail.gmail.com>
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
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3uQJTxRjo+BwLqaiPnwZ7abGwj341UiLi_mhz1QQpY9w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2017 at 12:55 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thu, Feb 9, 2017 at 12:28 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Wed, Feb 8, 2017 at 10:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> When CONFIG_KASAN is enabled, the "--param asan-stack=1" causes rather large
>>> stack frames in some functions. This goes unnoticed normally because
>>> CONFIG_FRAME_WARN is disabled with CONFIG_KASAN by default as of commit
>>> 3f181b4d8652 ("lib/Kconfig.debug: disable -Wframe-larger-than warnings with
>>> KASAN=y").
>>>
>>> The kernelci.org build bot however has the warning enabled and that led
>>> me to investigate it a little further, as every build produces these warnings:
>>>
>>> net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>> net/wireless/nl80211.c:1895:1: warning: the frame size of 3776 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>> net/wireless/nl80211.c:1410:1: warning: the frame size of 2208 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>> net/bridge/br_netlink.c:1282:1: warning: the frame size of 2544 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>
>>
>> This may be a good thing in itself, I don't know. But I don't think we
>> need to do this for KASAN.
>> KASAN does increase stack frames, but it also doubles stack size. So
>> at the very least we need to also double CONFIG_FRAME_WARN under KASAN
>> to 4096, which would auto-fix your warnings. Enabling 4096 warning for
>> KASAN may be moderately useful (catch cases of extremely large frames,
>> because KASAN frame increase can be much larger than 2x). But I am
>> watching these "used greatest stack depth" messages and also my test
>> bots and never seen anything worryingly low.
>
> I'm playing with this on my autobuilder some more, and so far
> have only encountered a handful of functions that use more
> than 2048 bytes of stack on x86-64 with KASAN enabled, and
> for each one of them I could come up with a patch that improved
> the object code while making the stack smaller.
>
> A "noinline_for_kasan" annotation would be sufficient to address most
> of them.
>
>> I've built kernel with KASAN+KCOV and there is 381 case throughout the codebase:
>> https://gist.githubusercontent.com/dvyukov/038426827b369f62d56e50cb39db29df/raw/96cdd758f06751339428c05fda3bc09c6beb700b/gistfile1.txt
>> Changing code for each of them looks like lots of work, and can
>> introduce bugs. 4096 would leave about 50 of them, but it's still
>> lots.
>
> Thanks for the list, that looks very helpful. The ones I found myself
> seem to be a strict (and small) subset of those, using gcc-7.0.1 on x86-64
> with allmodconfig and a few hundred randconfig builds. Which compiler
> version did you use for your testing? If new versions are better than old
> ones, we could start by fixing the ones that are still present in gcc-6 and
> gcc-7, and making the warning conditionally on the compiler version.
>
> Another idea might be to separate out asan_stack=1 into a separate
> Kconfig option and warn if that is enabled with compilers that are known
> to be relatively bad it keeping the stack small.


Mine is gcc version 7.0.0 20161208. Make sure you enable KASAN_INLINE
and I also enabled CONFIG_KCOV. Other than that I just did
allyesconfig + make -k.
