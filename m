From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] igb: use build_skb()
Date: Mon, 06 Aug 2012 20:08:49 +0200
Message-ID: <1344276529.26674.51.camel@edumazet-glaptop>
References: <1343922692.9299.231.camel@edumazet-glaptop>
	 <50200066.6060905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58021 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685Ab2HFSIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 14:08:54 -0400
Received: by bkwj10 with SMTP id j10so1142803bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 11:08:53 -0700 (PDT)
In-Reply-To: <50200066.6060905@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 10:35 -0700, Alexander Duyck wrote:
> On 08/02/2012 08:51 AM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > By using netdev_alloc_frag() & build_skb() instead of legacy
> > netdev_alloc_skb_ip_align() calls, we reduce number of cache misses in
> > RX path and size of working set.
> >
> > For a given rx workload, number of 'inuse' sk_buff can be reduced to a
> > very minimum, especially when packets are dropped by our stack.
> >
> > (Before this patch, default sk_buff allocation was 2048 sk_buffs in rx
> > ring buffer)
> >
> > They are initialized right before being delivered to stack, so can stay
> > hot in cpu caches.
> >
> > Ethernet header prefetching is more effective (old prefetch of skb->data
> > paid a stall to access skb->data pointer)
> >
> > I have 15% performance increase in a RX stress test, removing SLUB slow
> > path in the profiles.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> > ---
> >  drivers/net/ethernet/intel/igb/igb.h         |    8 ++
> >  drivers/net/ethernet/intel/igb/igb_ethtool.c |   14 ++--
> >  drivers/net/ethernet/intel/igb/igb_main.c    |   56 ++++++++++-------
> >  3 files changed, 49 insertions(+), 29 deletions(-)
> >
> [...]
> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> > index b7c2d50..8b732c9 100644
> > --- a/drivers/net/ethernet/intel/igb/igb_main.c
> > +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> [...]
> > @@ -6091,6 +6095,15 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
> >  		next_rxd = IGB_RX_DESC(rx_ring, i);
> >  		prefetch(next_rxd);
> >  
> > +		if (!skb) {
> > +			skb = build_skb(data, IGB_FRAGSZ);
> > +			if (unlikely(!skb)) {
> > +				rx_ring->rx_stats.alloc_failed++;
> > +				buffer_info->data = data;
> > +				goto next_desc;
> > +			}
> > +			skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
> > +		}
> >  		/*
> >  		 * This memory barrier is needed to keep us from reading
> >  		 * any other fields out of the rx_desc until we know the
> This logic is broken.  If an allocation failure occurs it would leave
> the data in the ring and could possibly give you a corrupted packet.
> 
> I was planning to move igb over to an ixgbe style receive path at some
> point anyway.  Since it seems like this is now a higher priority I
> figured I would try to get the patches for it implemented in the next
> week or so.  Would there be any issue with us rejecting this patch and
> instead switching igb over to the ixgbe style path?

I checked again and I believe logic is fine, exactly like driver before
this patch.

If skb cannot be allocated, the data part is reused for next frame.

( buffer_info->data = data; goto next_desc; )
