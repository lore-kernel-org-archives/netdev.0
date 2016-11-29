From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: GPF in eth_header
Date: Tue, 29 Nov 2016 11:26:53 +0100
Message-ID: <CAAeHK+xr+GdLbLch7XatW5rifOz+=cjRCGf1ro8WxEZWziyU4Q@mail.gmail.com>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
 <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
 <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com> <CACPEyM-4dwvmEvq3uTN_8Y-YosP8qA3cYV+oxkufFOn8M+=hew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34170 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757041AbcK2K1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 05:27:01 -0500
Received: by mail-lf0-f43.google.com with SMTP id o141so117953351lff.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 02:26:55 -0800 (PST)
In-Reply-To: <CACPEyM-4dwvmEvq3uTN_8Y-YosP8qA3cYV+oxkufFOn8M+=hew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2016 at 9:05 PM, Eric Dumazet <erdlkml@gmail.com> wrote:
>> I actually see multiple places where skb_network_offset() is used as
>> an argument to skb_pull().
>> So I guess every place can potentially be buggy.
>
> Well, I think the intent is to accept a negative number.

I'm not sure that was the intent since it results in a signedness
issue which leads to an out-of-bounds.

A quick grep shows that the same issue can potentially happen in
multiple places across the kernel:

net/ipv6/ip6_output.c:1655: __skb_pull(skb, skb_network_offset(skb));
net/packet/af_packet.c:2043: skb_pull(skb, skb_network_offset(skb));
net/packet/af_packet.c:2165: skb_pull(skb, skb_network_offset(skb));
net/core/neighbour.c:1301: __skb_pull(skb, skb_network_offset(skb));
net/core/neighbour.c:1331: __skb_pull(skb, skb_network_offset(skb));
net/core/dev.c:3157: __skb_pull(skb, skb_network_offset(skb));
net/sched/sch_teql.c:337: __skb_pull(skb, skb_network_offset(skb));
net/sched/sch_atm.c:479: skb_pull(skb, skb_network_offset(skb));
net/ipv4/ip_output.c:1385: __skb_pull(skb, skb_network_offset(skb));
net/ipv4/ip_fragment.c:391: if (!pskb_pull(skb, skb_network_offset(skb) + ihl))
drivers/net/vxlan.c:1440: __skb_pull(reply, skb_network_offset(reply));
drivers/net/vxlan.c:1902: __skb_pull(skb, skb_network_offset(skb));
drivers/net/vrf.c:220: __skb_pull(skb, skb_network_offset(skb));
drivers/net/vrf.c:314: __skb_pull(skb, skb_network_offset(skb));

A similar thing also happened to somebody else (on a receive path!):
https://forums.grsecurity.net/viewtopic.php?f=3&t=4550

Does it make sense to check skb_network_offset() before passing it to
skb_pull() everywhere?

>
> This definitely was assumed by commit e1f165032c8bade authors !
>
> I guess they were using a 32bit kernel for their tests.
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
