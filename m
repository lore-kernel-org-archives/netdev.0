From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: use-after-free in tw_timer_handler
Date: Tue, 14 Feb 2017 20:38:30 +0100
Message-ID: <CACT4Y+aZrpZ3JevLrg5i=nTzBAcVhKX9qmajyW5b-+xExwrCHg@mail.gmail.com>
References: <CACT4Y+a2t=Ev1-Mp6+aHzRkNPhWaY-dSYRdMeL2Hp7b37bnbUg@mail.gmail.com>
 <CACT4Y+ba65AD9qpjjJqM=_Pn333iWTm86BNmy2A5_EqHTY_kWA@mail.gmail.com>
 <1485268138.16328.297.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+b=-XJCwofbCRo6BnKJRU=amd7pxYpNrGdPEFT0bAtJaQ@mail.gmail.com>
 <CANn89iK=5uPEDLpM6=JAKzJ=1GuSSiXw5b_8BrkVUvhYRi_9mw@mail.gmail.com>
 <CACT4Y+bRP9ffnXDJeOD5VkqFw+-cDHh4hEVzcnv3vnHh+vdqBQ@mail.gmail.com>
 <1486576716.7793.84.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+ZqSi_v+ie5MCRggJSZeKQgWqGPKrsRRyaE_GVAfkgLjA@mail.gmail.com>
 <1486581462.7793.86.camel@edumazet-glaptop3.roam.corp.google.com> <CACT4Y+aagYbMz=3w4zrXaZYJXn65LxZRd7ud1nje9SfS39d+eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33201 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752968AbdBNTiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:38:52 -0500
Received: by mail-vk0-f46.google.com with SMTP id k127so86599933vke.0
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 11:38:52 -0800 (PST)
In-Reply-To: <CACT4Y+aagYbMz=3w4zrXaZYJXn65LxZRd7ud1nje9SfS39d+eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 8:32 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> >> >>> This code was changed a long time ago :
>>> >> >>>
>>> >> >>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054
>>> >> >>>
>>> >> >>> So I suspect a recent patch broke the logic.
>>> >> >>>
>>> >> >>> You might start a bisection :
>>> >> >>>
>>> >> >>> I would check if 4.7 and 4.8 trigger the issue you noticed.
>>> >> >>
>>> >> >>
>>> >> >> It happens with too low rate for bisecting (few times per day). I
>>> >> >> could add some additional checks into code, but I don't know what
>>> >> >> checks could be useful.
>>> >> >
>>> >> > If you can not tell if 4.7 and/or 4.8 have the problem, I am not sure
>>> >> > we are able to help.
>>> >>
>>> >>
>>> >> There are also chances that the problem is older.
>>> >>
>>> >> Looking at the code, this part of inet_twsk_purge looks fishy:
>>> >>
>>> >> 285                         if (unlikely((tw->tw_family != family) ||
>>> >> 286                                      atomic_read(&twsk_net(tw)->count))) {
>>> >>
>>> >> It uses net->count == 0 check to find the right sockets. But what if
>>> >> there are several nets with count == 0 in flight, can't there be
>>> >> several inet_twsk_purge calls running concurrently freeing each other
>>> >> sockets? If so it looks like inet_twsk_purge can call
>>> >> inet_twsk_deschedule_put twice for a socket. Namely, two calls for
>>> >> different nets discover the socket, check that net->count==0 and both
>>> >> call inet_twsk_deschedule_put. Shouldn't we just give inet_twsk_purge
>>> >> net that it needs to purge?
>>> >
>>> > Yes, atomic_read() is not a proper sync point.
>>>
>>> Do you mean that it does not include read barrier?
>>> I more mean that we can call inet_twsk_deschedule_put twice for the same socket.
>>
>> I meant that this code assumed RTNL being held.
>>
>> This might not be the case now, after some old change.
>
>
> cleanup_net releases rtnl lock right before calling these callbacks.


+Andrey, do you know somebody on your side interested in stability of
network namespace?
This use-after-free seems to be related to net namespace. For context,
full thread is here:
https://groups.google.com/forum/#!msg/syzkaller/p1tn-_Kc6l4/smuL_FMAAgAJ
