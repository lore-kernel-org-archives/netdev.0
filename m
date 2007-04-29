From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 27/32] xen: Add the Xen virtual network device driver.
Date: Sun, 29 Apr 2007 18:59:42 +0100
Message-ID: <20070429175942.GA3551@infradead.org>
References: <20070429172835.284784000@goop.org> <20070429172916.025602000@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>,
	virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminge@linux-foundation.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50302 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbXD2SA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 14:00:57 -0400
Content-Disposition: inline
In-Reply-To: <20070429172916.025602000@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 29, 2007 at 10:29:02AM -0700, Jeremy Fitzhardinge wrote:
> +#include <linux/version.h>

not needed.

> +#include <xen/xenbus.h>
> +#include <xen/interface/io/netif.h>
> +#include <xen/interface/memory.h>
> +#ifdef CONFIG_XEN_BALLOON
> +#include <xen/balloon.h>
> +#endif
> +#include <xen/interface/grant_table.h>

Please don't try to put such a fucked up include hierachy in.
Just move everything under include/xen or you will soon get
problems with the 80 line length limit for your includes..

Also please make sure that <xen/balloon.h> can be included unconditionally,
as we really don't like ifdefs around includes.

> +struct netfront_info {
> +	struct list_head list;
> +	struct net_device *netdev;
> +
> +	struct net_device_stats stats;
> +
> +	struct netif_tx_front_ring tx;
> +	struct netif_rx_front_ring rx;
> +
> +	spinlock_t   tx_lock;
> +	spinlock_t   rx_lock;
> +
> +	unsigned int evtchn, irq;
> +	unsigned int copying_receiver;
> +	unsigned int carrier;

This doesn't not look like exactly smart cacheline alignment :)

> +	grant_ref_t gref_tx_head;

What's a grant_ref_t?  Should this really be a typedef or better
a struct type?  Also it really wants a xen_ prefix instead of someting
so generic.

> + * Implement our own carrier flag: the network stack's version causes delays
> + * when the carrier is re-enabled (in particular, dev_activate() may not
> + * immediately be called, which can cause packet loss).
> + */

Did you talk to the networking folks about these problems?

> +#define netfront_carrier_on(netif)	((netif)->carrier = 1)
> +#define netfront_carrier_off(netif)	((netif)->carrier = 0)
> +#define netfront_carrier_ok(netif)	((netif)->carrier)

Please use proper symbolic names for the ctal states and kill these
wrappers.

> +static int setup_device(struct xenbus_device *, struct netfront_info *);
> +static struct net_device *create_netdev(struct xenbus_device *);
> +
> +static void end_access(int, void *);
> +static void netif_disconnect_backend(struct netfront_info *);
> +
> +static int network_connect(struct net_device *);
> +static void network_tx_buf_gc(struct net_device *);
> +static void network_alloc_rx_buffers(struct net_device *);
> +
> +static irqreturn_t netif_int(int irq, void *dev_id);

Any chance you could avoid these forward-prototypes by reordering
the functions a little?

Also a lot of these names are horribly generic.  A proper xennet_
prefix would probably help.

> +static inline int xennet_can_sg(struct net_device *dev)
> +{
> +	return dev->features & NETIF_F_SG;
> +}

totally useless wrapper.

> +static int __devexit netfront_remove(struct xenbus_device *dev)
> +{
> +	struct netfront_info *info = dev->dev.driver_data;
> +
> +	dev_dbg(&dev->dev, "%s\n", dev->nodename);
> +
> +	netif_disconnect_backend(info);
> +
> +	del_timer_sync(&info->rx_refill_timer);
> +
> +	xennet_sysfs_delif(info->netdev);
> +
> +	unregister_netdev(info->netdev);
> +
> +	free_netdev(info->netdev);

This looks like very wrong ordering to me.  unregister_netdev should
be the first thing in the remove function.

> +	SHARED_RING_INIT(rxs);
> +	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);

Can you replace these shouting macros with proper named functions?

> +	 * receive ring. This creates a less bursty demand on the memory
> +	 * allocator, so should reduce the chance of failed allocation requests
> +	 * both for ourself and for other kernel subsystems.
> +	 */
> +	batch_target = np->rx_target - (req_prod - np->rx.rsp_cons);
> +	for (i = skb_queue_len(&np->rx_batch); i < batch_target; i++) {
> +		/*
> +		 * Allocate an skb and a page. Do not use __dev_alloc_skb as
> +		 * that will allocate page-sized buffers which is not
> +		 * necessary here.
> +		 * 16 bytes added as necessary headroom for netif_receive_skb.
> +		 */
> +		skb = alloc_skb(RX_COPY_THRESHOLD + 16 + NET_IP_ALIGN,
> +				GFP_ATOMIC | __GFP_NOWARN);

This comment doesn't make any sense, __dev_alloc_skb is:

static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
                                              gfp_t gfp_mask)
{
	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
	if (likely(skb))
		skb_reserve(skb, NET_SKB_PAD);
	return skb;
}

then again what you really should be using here is __netdev_alloc_skb.

> +#ifdef CONFIG_XEN_BALLOON
> +		/* Tell the ballon driver what is going on. */
> +		balloon_update_driver_allowance(i);
> +#endif

	This should be a noop for !CONFIG_XEN_BALLOON in the header,
	and there should be no need for ifdefs here.

> +		skb->nh.raw = (void *)skb_shinfo(skb)->frags[0].page;
> +		skb->h.raw = skb->nh.raw + rx->offset;

Stuff like this won't compile anymore in the current tree.

