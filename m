From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] igb: use build_skb()
Date: Mon, 06 Aug 2012 10:35:34 -0700
Message-ID: <50200066.6060905@intel.com>
References: <1343922692.9299.231.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24439 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721Ab2HFRfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 13:35:34 -0400
In-Reply-To: <1343922692.9299.231.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2012 08:51 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> By using netdev_alloc_frag() & build_skb() instead of legacy
> netdev_alloc_skb_ip_align() calls, we reduce number of cache misses in
> RX path and size of working set.
>
> For a given rx workload, number of 'inuse' sk_buff can be reduced to a
> very minimum, especially when packets are dropped by our stack.
>
> (Before this patch, default sk_buff allocation was 2048 sk_buffs in rx
> ring buffer)
>
> They are initialized right before being delivered to stack, so can stay
> hot in cpu caches.
>
> Ethernet header prefetching is more effective (old prefetch of skb->data
> paid a stall to access skb->data pointer)
>
> I have 15% performance increase in a RX stress test, removing SLUB slow
> path in the profiles.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h         |    8 ++
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   14 ++--
>  drivers/net/ethernet/intel/igb/igb_main.c    |   56 ++++++++++-------
>  3 files changed, 49 insertions(+), 29 deletions(-)
>
[...]
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index b7c2d50..8b732c9 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
[...]
> @@ -6091,6 +6095,15 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
>  		next_rxd = IGB_RX_DESC(rx_ring, i);
>  		prefetch(next_rxd);
>  
> +		if (!skb) {
> +			skb = build_skb(data, IGB_FRAGSZ);
> +			if (unlikely(!skb)) {
> +				rx_ring->rx_stats.alloc_failed++;
> +				buffer_info->data = data;
> +				goto next_desc;
> +			}
> +			skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
> +		}
>  		/*
>  		 * This memory barrier is needed to keep us from reading
>  		 * any other fields out of the rx_desc until we know the
This logic is broken.  If an allocation failure occurs it would leave
the data in the ring and could possibly give you a corrupted packet.

I was planning to move igb over to an ixgbe style receive path at some
point anyway.  Since it seems like this is now a higher priority I
figured I would try to get the patches for it implemented in the next
week or so.  Would there be any issue with us rejecting this patch and
instead switching igb over to the ixgbe style path?

Thanks,

Alex
