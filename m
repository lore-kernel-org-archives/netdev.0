From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 37/44] xen: add virtual network device driver
Date: Tue, 17 Jul 2007 09:45:11 +0100
Message-ID: <20070717094511.795beb69@oldman>
References: <20070716231536.937393000@xensource.com>
	<20070716232916.472694000@xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.com>,
	Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@linux-foundation.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Xen-devel <xen-devel@lists.xensource.com>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>,
	Christoph Hellwig <hch@infradead.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50495 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750752AbXGQIqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 04:46:38 -0400
In-Reply-To: <20070716232916.472694000@xensource.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +struct netfront_info {
> +	struct list_head list;
> +	struct net_device *netdev;
> +
> +	struct net_device_stats stats;

There is now a net_device_stats element inside net_device on
2.6.21 or later.

> +
> +	struct xen_netif_tx_front_ring tx;
> +	struct xen_netif_rx_front_ring rx;
> +
> +	spinlock_t   tx_lock;
> +	spinlock_t   rx_lock;

It might be a performance advantage to reorder/align these
structure elements to put transmit hot elements together, and
put tx and rx on different cache lines?

> +	unsigned int evtchn;
> +
> +	/* Receive-ring batched refills. */
> +#define RX_MIN_TARGET 8
> +#define RX_DFL_MIN_TARGET 64
> +#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
> +	unsigned rx_min_target, rx_max_target, rx_target;
> +	struct sk_buff_head rx_batch;
> +
> +	struct timer_list rx_refill_timer;
> +
> +	/*
> +	 * {tx,rx}_skbs store outstanding skbuffs. Free tx_skb entries
> +	 * are linked from tx_skb_freelist through skb_entry.link.
> +	 *
> +	 *  NB. Freelist index entries are always going to be less than
> +	 *  PAGE_OFFSET, whereas pointers to skbs will always be equal or
> +	 *  greater than PAGE_OFFSET: we use this property to distinguish
> +	 *  them.
> +	 */
> +	union skb_entry {
> +		struct sk_buff *skb;
> +		unsigned link;
> +	} tx_skbs[NET_TX_RING_SIZE];
> +	grant_ref_t gref_tx_head;
> +	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
> +	unsigned tx_skb_freelist;
> +
> +	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
> +	grant_ref_t gref_rx_head;
> +	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
> +
> +	struct xenbus_device *xbdev;
> +	int tx_ring_ref;
> +	int rx_ring_ref;
> +
> +	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
> +	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
> +	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
> +};
