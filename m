From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: __alloc_skb() speedup
Date: Wed, 05 May 2010 10:22:14 +0200
Message-ID: <1273047734.2367.3.camel@edumazet-laptop>
References: <1272993054.2245.21.camel@edumazet-laptop>
	 <20100505.010658.48498744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:41855 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932388Ab0EEIWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:22:19 -0400
Received: by bwz25 with SMTP id 25so2752903bwz.28
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 01:22:17 -0700 (PDT)
In-Reply-To: <20100505.010658.48498744.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 mai 2010 =C3=A0 01:06 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 04 May 2010 19:10:54 +0200
>=20
> > With following patch I can reach maximum rate of my pktgen+udpsink
> > simulator :
> > - 'old' machine : dual quad core E5450  @3.00GHz
> > - 64 UDP rx flows (only differ by destination port)
> > - RPS enabled, NIC interrupts serviced on cpu0
> > - rps dispatched on 7 other cores. (~130.000 IPI per second)
> > - SLAB allocator (faster than SLUB in this workload)
> > - tg3 NIC
> > - 1.080.000 pps without a single drop at NIC level.
> >=20
> > Idea is to add two prefetchw() calls in __alloc_skb(), one to prefe=
tch
> > first sk_buff cache line, the second to prefetch the shinfo part.
> >=20
> > Also using one memset() to initialize all skb_shared_info fields in=
stead
> > of one by one to reduce number of instructions, using long word mov=
es.
> >=20
> > All skb_shared_info fields before 'dataref' are cleared in=20
> > __alloc_skb().
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I'll apply this, nice work Eric.
>=20
> But some caveats...
>=20
> On several cpu types it is possible to "prefetch invalidate"
> cachelines.  PowerPC and sparc64 can both do it.  I'm pretty
> sure current gen x86 have SSE bits that can do this too.
>=20
> In fact, the memset() for sparc64 is going to do these cacheline
> invalidates, making the prefetches on 'skb' in fact wasteful.
> It will just create spurious bus traffic.
>=20

You mean memset() wont be inlined by ompiler to plain memory writes, bu=
t
use the custom kernel memset()  ?


