From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large struct
 on stack"
Date: Thu, 12 Jan 2017 14:21:20 -0800
Message-ID: <CAM_iQpWdjo-3+vVQpay9FSEbc_R5Y2=iKA8PpC4f=USTDkL+ww@mail.gmail.com>
References: <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170109.135259.988711786570465428.davem@davemloft.net> <CAM_iQpUbcVogq7jGePkgPJ0z_J=46hnK8KcTiX1svVXr1Hoh-w@mail.gmail.com>
 <20170110.131223.748150430551443881.davem@davemloft.net> <CAM_iQpV0V23fndi6DOW1gu9kq+2UufHNrnfRYCME7uOOLCaX-Q@mail.gmail.com>
 <20170110210820.1c5dbc87@redhat.com> <1484084891.21472.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34463 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdALWVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 17:21:41 -0500
Received: by mail-qk0-f194.google.com with SMTP id e1so4686959qkh.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 14:21:41 -0800 (PST)
In-Reply-To: <1484084891.21472.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 1:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-01-10 at 21:08 +0100, Jesper Dangaard Brouer wrote:
>> On Tue, 10 Jan 2017 10:44:59 -0800 Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> > On Tue, Jan 10, 2017 at 10:12 AM, David Miller <davem@davemloft.net> wrote:
>> [...]
>> > > You can keep showing us how expertly you can deflect the real
>> > > issue we are discussion here, but that won't improve the situation
>> > > at all I am afraid.
>> >
>> > Of course, there are just too many people too lazy to do a google search:
>> >
>> > https://lists.debian.org/debian-kernel/2013/05/msg00500.html
>>
>> My analysis of the problem shown in above link is not related to using
>> all the stack space, but instead that skb->cb was not cleared.  This
>> can cause the ip_options_echo() call in icmp_send() to access garbage
>> as this is: __ip_options_echo(dopt, skb, &IPCB(skb)->opt).
>>
>> Fixed by commit a622260254ee ("ip_tunnel: fix kernel panic with icmp_dest_unreach")
>>  https://git.kernel.org/torvalds/c/a622260254ee
>>
>> Thus, it is (likely) the __ip_options_echo() call that violates stack
>> access, as it is passed in a pointer to the stack, and advance this
>> based on garbage "optlen".
>>
>
> I totally agree.

I can't agree, iptunnel or ipgre symbols are not in the above stack trace
at all. Although I do agree that the above stack usage is not aggressive,
especially when compared with the other I sent.

My vague memory told me the original problem I fixed is related to vxlan
but after trying to search all netdev archives in 2013 May/Jun, I still can't
find it, perhaps it was reported to LKML or somewhere else rather than
netdev. It was certainly a real problem.

Even though the irq stack is 16K, but it is too easy to stack netdevices
and stack qdisc's too, so for TX path I am not surprised at all if 16K could
be exhausted eventually. Yeah, it is hard to blame one of them in the call
chain, but 112 bytes _alone_ are aggressive for such a function deeply
in the call stack. That's my whole point.
