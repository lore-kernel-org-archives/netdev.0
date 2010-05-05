From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: __alloc_skb() speedup
Date: Wed, 05 May 2010 01:06:58 -0700 (PDT)
Message-ID: <20100505.010658.48498744.davem@davemloft.net>
References: <1272993054.2245.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45877
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755064Ab0EEIGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:06:52 -0400
In-Reply-To: <1272993054.2245.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 May 2010 19:10:54 +0200

> With following patch I can reach maximum rate of my pktgen+udpsink
> simulator :
> - 'old' machine : dual quad core E5450  @3.00GHz
> - 64 UDP rx flows (only differ by destination port)
> - RPS enabled, NIC interrupts serviced on cpu0
> - rps dispatched on 7 other cores. (~130.000 IPI per second)
> - SLAB allocator (faster than SLUB in this workload)
> - tg3 NIC
> - 1.080.000 pps without a single drop at NIC level.
> 
> Idea is to add two prefetchw() calls in __alloc_skb(), one to prefetch
> first sk_buff cache line, the second to prefetch the shinfo part.
> 
> Also using one memset() to initialize all skb_shared_info fields instead
> of one by one to reduce number of instructions, using long word moves.
> 
> All skb_shared_info fields before 'dataref' are cleared in 
> __alloc_skb().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this, nice work Eric.

But some caveats...

On several cpu types it is possible to "prefetch invalidate"
cachelines.  PowerPC and sparc64 can both do it.  I'm pretty
sure current gen x86 have SSE bits that can do this too.

In fact, the memset() for sparc64 is going to do these cacheline
invalidates, making the prefetches on 'skb' in fact wasteful.
It will just create spurious bus traffic.

The memset() for skb_shared_info() is going to help universally
I think.


