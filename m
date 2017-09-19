From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] tcp: avoid bogus warning in tcp_clean_rtx_queue
Date: Tue, 19 Sep 2017 23:32:33 +0200
Message-ID: <CAK8P3a3G78pqFsoimeNrKnPLOUYR+X1qzhbKyabn_tN4oZMLyQ@mail.gmail.com>
References: <20170918204855.170920-1-arnd@arndb.de> <20170919.140250.1393293793761020505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, yoshfuji@linux-ipv6.org,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>, ycheng@google.com,
        soheil@google.com, Florian Westphal <fw@strlen.de>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919.140250.1393293793761020505.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2017 at 11:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Mon, 18 Sep 2017 22:48:47 +0200
>
>> gcc-4.9 warns that it cannot trace the state of the 'last_ackt'
>> variable since the change to the TCP timestamping code, when
>> CONFIG_PROFILE_ANNOTATED_BRANCHES is set:
>>
>> net/ipv4/tcp_input.c: In function 'tcp_clean_rtx_queue':
>> include/net/tcp.h:757:23: error: 'last_ackt' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>>
>> Other gcc versions, both older and newer do now show this
>> warning. Removing the 'likely' annotation makes it go away,
>> and has no effect on the object code without
>> CONFIG_PROFILE_ANNOTATED_BRANCHES, as tested with gcc-4.9
>> and gcc-7.1.1, so this seems to be a safe workaround.
>>
>> Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> This reaches the limits at which I am willing to work around compiler
> stuff.

I see. It is a definitely a really obscure case, so if there is any doubt
that the workaround is harmless, then we shouldn't take it. The warning
only shows up on gcc-4.9 but not anything newer, and we disable
-Wmaybe-uninitialized on all older versions because of the false
positives.

It's also possible that it needed a combination of multiple other options,
not just CONFIG_PROFILE_ANNOTATED_BRANCHES. I build-tested
with gcc-4.9 to see if anything would show up that we don't also get a
warning for in gcc-7, and this came up once in several hundred randconfig
builds across multiple architectures (no other new warnings appeared
with gcc-4.9).

> What cpu did you test the object code generation upon and does that
> cpu have branch prediction hints in the target you are building for?

This was a randconfig build targetting ARMv5. I'm pretty sure that has
no such hint instructions.

       Arnd
