From: Eric Dumazet <erdlkml@gmail.com>
Subject: Re: net: GPF in eth_header
Date: Sat, 26 Nov 2016 12:05:08 -0800
Message-ID: <CACPEyM-4dwvmEvq3uTN_8Y-YosP8qA3cYV+oxkufFOn8M+=hew@mail.gmail.com>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
 <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com> <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35846 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbcKZUFK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 15:05:10 -0500
In-Reply-To: <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Eric,
>
> The crash happens when the kernel tries to access shadow for nonmapped memory.
>
> The issue here is an integer overflow which happens in neigh_resolve_output().
> skb_network_offset(skb) can return negative number, but __skb_pull()
> accepts unsigned int as len.
> As a result, the least significat bit in higher 32 bits of skb->data
> gets set and we get an out-of-bounds with offset of 4 GB.
>
> I've attached a short reproducer, but you either need KASAN or to add
> a BUG_ON to see the crash.
> In this reproducer skb_network_offset() becomes negative after merging
> two ipv6 fragments.
>
> I actually see multiple places where skb_network_offset() is used as
> an argument to skb_pull().
> So I guess every place can potentially be buggy.

Well, I think the intent is to accept a negative number.

This definitely was assumed by commit e1f165032c8bade authors !

I guess they were using a 32bit kernel for their tests.
