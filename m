From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [PATCH 6/8] netfront: multi-page ring support
Date: Tue, 26 Feb 2013 14:52:06 +0800
Message-ID: <512C5B96.10204@oracle.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com> <1360944010-15336-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, konrad.wilk@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27490 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab3BZGvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 01:51:38 -0500
In-Reply-To: <1360944010-15336-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013-2-16 0:00, Wei Liu wrote:
> Signed-off-by: Wei Liu<wei.liu2@citrix.com>
> ---
>   drivers/net/xen-netfront.c |  246 +++++++++++++++++++++++++++++++-------------
>   1 file changed, 174 insertions(+), 72 deletions(-)
>
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 8bd75a1..de73a71 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -67,9 +67,19 @@ struct netfront_cb {
>
>   #define GRANT_INVALID_REF	0
>
> -#define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
> -#define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
> -#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE, 256)
> +#define XENNET_MAX_RING_PAGE_ORDER XENBUS_MAX_RING_PAGE_ORDER
> +#define XENNET_MAX_RING_PAGES      (1U<<  XENNET_MAX_RING_PAGE_ORDER)
> +
> +
> +#define NET_TX_RING_SIZE(_nr_pages)			\
> +	__CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages))
> +#define NET_RX_RING_SIZE(_nr_pages)			\
> +	__CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE * (_nr_pages))
> +
> +#define XENNET_MAX_TX_RING_SIZE NET_TX_RING_SIZE(XENNET_MAX_RING_PAGES)
> +#define XENNET_MAX_RX_RING_SIZE NET_RX_RING_SIZE(XENNET_MAX_RING_PAGES)
> +
> +#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE(1), 256)

Not using multi-page ring here?
In xennet_create_dev, gnttab_alloc_grant_references allocates 
TX_MAX_TARGET number of grant reference for tx. In 
xennet_release_tx_bufs, NET_TX_RING_SIZE(np->tx_ring_pages) numbers of 
grants are processed. And NET_RX_RING_SIZE(np->tx_ring_pages) is totally 
different from TX_MAX_TARGET if np->rx_ring_pages is not 1. Although 
skb_entry_is_link helps to not release invalid grants, lots of null loop 
seems unnecessary. I think TX_MAX_TARGET should be changed into some 
variableconnected with np->tx_ring_pages. Or you intended to use one 
page ring here?

>
>   struct netfront_stats {
>   	u64			rx_packets;
> @@ -80,6 +90,11 @@ struct netfront_stats {
>   };
>
>   struct netfront_info {
> +	/* Statistics */
> +	struct netfront_stats __percpu *stats;
> +
> +	unsigned long rx_gso_checksum_fixup;
> +
>   	struct list_head list;
>   	struct net_device *netdev;
>
> @@ -90,7 +105,9 @@ struct netfront_info {
>
>   	spinlock_t   tx_lock;
>   	struct xen_netif_tx_front_ring tx;
> -	int tx_ring_ref;
> +	int tx_ring_ref[XENNET_MAX_RING_PAGES];
> +	unsigned int tx_ring_page_order;
> +	unsigned int tx_ring_pages;
>
>   	/*
>   	 * {tx,rx}_skbs store outstanding skbuffs. Free tx_skb entries
> @@ -104,36 +121,33 @@ struct netfront_info {
>   	union skb_entry {
>   		struct sk_buff *skb;
>   		unsigned long link;
> -	} tx_skbs[NET_TX_RING_SIZE];
> +	} tx_skbs[XENNET_MAX_TX_RING_SIZE];
>   	grant_ref_t gref_tx_head;
> -	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
> +	grant_ref_t grant_tx_ref[XENNET_MAX_TX_RING_SIZE];
>   	unsigned tx_skb_freelist;
>
>   	spinlock_t   rx_lock ____cacheline_aligned_in_smp;
>   	struct xen_netif_rx_front_ring rx;
> -	int rx_ring_ref;
> +	int rx_ring_ref[XENNET_MAX_RING_PAGES];
> +	unsigned int rx_ring_page_order;
> +	unsigned int rx_ring_pages;
>
>   	/* Receive-ring batched refills. */
>   #define RX_MIN_TARGET 8
>   #define RX_DFL_MIN_TARGET 64
> -#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
> +#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE(1), 256)

Not using multi-page ring here?
(See comments of tx side above)

Thanks
Annie

>   	unsigned rx_min_target, rx_max_target, rx_target;
>   	struct sk_buff_head rx_batch;
>
>   	struct timer_list rx_refill_timer;
>
> -	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
> +	struct sk_buff *rx_skbs[XENNET_MAX_RX_RING_SIZE];
>   	grant_ref_t gref_rx_head;
> -	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
> -
> -	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
> -	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
> -	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
> -
> -	/* Statistics */
> -	struct netfront_stats __percpu *stats;
> +	grant_ref_t grant_rx_ref[XENNET_MAX_RX_RING_SIZE];
>
> -	unsigned long rx_gso_checksum_fixup;
> +	unsigned long rx_pfn_array[XENNET_MAX_RX_RING_SIZE];
> +	struct multicall_entry rx_mcl[XENNET_MAX_RX_RING_SIZE+1];
> +	struct mmu_update rx_mmu[XENNET_MAX_RX_RING_SIZE];
>   };
>
>   struct netfront_rx_info {
> @@ -171,15 +185,15 @@ static unsigned short get_id_from_freelist(unsigned *head,
>   	return id;
>   }
>
> -static int xennet_rxidx(RING_IDX idx)
> +static int xennet_rxidx(RING_IDX idx, struct netfront_info *info)
>   {
> -	return idx&  (NET_RX_RING_SIZE - 1);
> +	return idx&  (NET_RX_RING_SIZE(info->rx_ring_pages) - 1);
>   }
>
>   static struct sk_buff *xennet_get_rx_skb(struct netfront_info *np,
>   					 RING_IDX ri)
>   {
> -	int i = xennet_rxidx(ri);
> +	int i = xennet_rxidx(ri, np);
>   	struct sk_buff *skb = np->rx_skbs[i];
>   	np->rx_skbs[i] = NULL;
>   	return skb;
> @@ -188,7 +202,7 @@ static struct sk_buff *xennet_get_rx_skb(struct netfront_info *np,
>   static grant_ref_t xennet_get_rx_ref(struct netfront_info *np,
>   					    RING_IDX ri)
>   {
> -	int i = xennet_rxidx(ri);
> +	int i = xennet_rxidx(ri, np);
>   	grant_ref_t ref = np->grant_rx_ref[i];
>   	np->grant_rx_ref[i] = GRANT_INVALID_REF;
>   	return ref;
> @@ -301,7 +315,7 @@ no_skb:
>
>   		skb->dev = dev;
>
> -		id = xennet_rxidx(req_prod + i);
> +		id = xennet_rxidx(req_prod + i, np);
>
>   		BUG_ON(np->rx_skbs[id]);
>   		np->rx_skbs[id] = skb;
> @@ -653,7 +667,7 @@ static int xennet_close(struct net_device *dev)
>   static void xennet_move_rx_slot(struct netfront_info *np, struct sk_buff *skb,
>   				grant_ref_t ref)
>   {
> -	int new = xennet_rxidx(np->rx.req_prod_pvt);
> +	int new = xennet_rxidx(np->rx.req_prod_pvt, np);
>
>   	BUG_ON(np->rx_skbs[new]);
>   	np->rx_skbs[new] = skb;
> @@ -1109,7 +1123,7 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
>   	struct sk_buff *skb;
>   	int i;
>
> -	for (i = 0; i<  NET_TX_RING_SIZE; i++) {
> +	for (i = 0; i<  NET_TX_RING_SIZE(np->tx_ring_pages); i++) {
>   		/* Skip over entries which are actually freelist references */
>   		if (skb_entry_is_link(&np->tx_skbs[i]))
>   			continue;
> @@ -1143,7 +1157,7 @@ static void xennet_release_rx_bufs(struct netfront_info *np)
>
>   	spin_lock_bh(&np->rx_lock);
>
> -	for (id = 0; id<  NET_RX_RING_SIZE; id++) {
> +	for (id = 0; id<  NET_RX_RING_SIZE(np->rx_ring_pages); id++) {
>   		ref = np->grant_rx_ref[id];
>   		if (ref == GRANT_INVALID_REF) {
>   			unused++;
> @@ -1324,13 +1338,13 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
>
>   	/* Initialise tx_skbs as a free chain containing every entry. */
>   	np->tx_skb_freelist = 0;
> -	for (i = 0; i<  NET_TX_RING_SIZE; i++) {
> +	for (i = 0; i<  XENNET_MAX_TX_RING_SIZE; i++) {
>   		skb_entry_set_link(&np->tx_skbs[i], i+1);
>   		np->grant_tx_ref[i] = GRANT_INVALID_REF;
>   	}
>
>   	/* Clear out rx_skbs */
> -	for (i = 0; i<  NET_RX_RING_SIZE; i++) {
> +	for (i = 0; i<  XENNET_MAX_RX_RING_SIZE; i++) {
>   		np->rx_skbs[i] = NULL;
>   		np->grant_rx_ref[i] = GRANT_INVALID_REF;
>   	}
> @@ -1428,13 +1442,6 @@ static int netfront_probe(struct xenbus_device *dev,
>   	return err;
>   }
>
> -static void xennet_end_access(int ref, void *page)
> -{
> -	/* This frees the page as a side-effect */
> -	if (ref != GRANT_INVALID_REF)
> -		gnttab_end_foreign_access(ref, 0, (unsigned long)page);
> -}
> -
>   static void xennet_disconnect_backend(struct netfront_info *info)
>   {
>   	/* Stop old i/f to prevent errors whilst we rebuild the state. */
> @@ -1448,12 +1455,12 @@ static void xennet_disconnect_backend(struct netfront_info *info)
>   		unbind_from_irqhandler(info->netdev->irq, info->netdev);
>   	info->evtchn = info->netdev->irq = 0;
>
> -	/* End access and free the pages */
> -	xennet_end_access(info->tx_ring_ref, info->tx.sring);
> -	xennet_end_access(info->rx_ring_ref, info->rx.sring);
> +	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->tx.sring);
> +	free_pages((unsigned long)info->tx.sring, info->tx_ring_page_order);
> +
> +	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->rx.sring);
> +	free_pages((unsigned long)info->rx.sring, info->rx_ring_page_order);
>
> -	info->tx_ring_ref = GRANT_INVALID_REF;
> -	info->rx_ring_ref = GRANT_INVALID_REF;
>   	info->tx.sring = NULL;
>   	info->rx.sring = NULL;
>   }
> @@ -1501,11 +1508,14 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
>   	struct xen_netif_tx_sring *txs;
>   	struct xen_netif_rx_sring *rxs;
>   	int err;
> -	int grefs[1];
>   	struct net_device *netdev = info->netdev;
> +	unsigned int max_tx_ring_page_order, max_rx_ring_page_order;
> +	int i;
>
> -	info->tx_ring_ref = GRANT_INVALID_REF;
> -	info->rx_ring_ref = GRANT_INVALID_REF;
> +	for (i = 0; i<  XENNET_MAX_RING_PAGES; i++) {
> +		info->tx_ring_ref[i] = GRANT_INVALID_REF;
> +		info->rx_ring_ref[i] = GRANT_INVALID_REF;
> +	}
>   	info->rx.sring = NULL;
>   	info->tx.sring = NULL;
>   	netdev->irq = 0;
> @@ -1516,50 +1526,100 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
>   		goto fail;
>   	}
>
> -	txs = (struct xen_netif_tx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
> +	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
> +			   "max-tx-ring-page-order", "%u",
> +			&max_tx_ring_page_order);
> +	if (err<  0) {
> +		info->tx_ring_page_order = 0;
> +		dev_info(&dev->dev, "single tx ring\n");
> +	} else {
> +		if (max_tx_ring_page_order>  XENNET_MAX_RING_PAGE_ORDER) {
> +			dev_info(&dev->dev,
> +				 "backend ring page order %d too large, clamp to %d\n",
> +				 max_tx_ring_page_order,
> +				 XENNET_MAX_RING_PAGE_ORDER);
> +			max_tx_ring_page_order = XENNET_MAX_RING_PAGE_ORDER;
> +		}
> +		info->tx_ring_page_order = max_tx_ring_page_order;
> +		dev_info(&dev->dev, "multi-page tx ring, order = %d\n",
> +			 info->tx_ring_page_order);
> +	}
> +	info->tx_ring_pages = (1U<<  info->tx_ring_page_order);
> +
> +	txs = (struct xen_netif_tx_sring *)
> +		__get_free_pages(__GFP_ZERO | GFP_NOIO | __GFP_HIGH,
> +				 info->tx_ring_page_order);
>   	if (!txs) {
>   		err = -ENOMEM;
>   		xenbus_dev_fatal(dev, err, "allocating tx ring page");
>   		goto fail;
>   	}
>   	SHARED_RING_INIT(txs);
> -	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
> +	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE * info->tx_ring_pages);
> +
> +	err = xenbus_grant_ring(dev, txs, info->tx_ring_pages,
> +				info->tx_ring_ref);
> +	if (err<  0)
> +		goto grant_tx_ring_fail;
>
> -	err = xenbus_grant_ring(dev, txs, 1, grefs);
> +	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
> +			   "max-rx-ring-page-order", "%u",
> +			&max_rx_ring_page_order);
>   	if (err<  0) {
> -		free_page((unsigned long)txs);
> -		goto fail;
> +		info->rx_ring_page_order = 0;
> +		dev_info(&dev->dev, "single rx ring\n");
> +	} else {
> +		if (max_rx_ring_page_order>  XENNET_MAX_RING_PAGE_ORDER) {
> +			dev_info(&dev->dev,
> +				 "backend ring page order %d too large, clamp to %d\n",
> +				 max_rx_ring_page_order,
> +				 XENNET_MAX_RING_PAGE_ORDER);
> +			max_rx_ring_page_order = XENNET_MAX_RING_PAGE_ORDER;
> +		}
> +		info->rx_ring_page_order = max_rx_ring_page_order;
> +		dev_info(&dev->dev, "multi-page rx ring, order = %d\n",
> +			 info->rx_ring_page_order);
>   	}
> +	info->rx_ring_pages = (1U<<  info->rx_ring_page_order);
>
> -	info->tx_ring_ref = grefs[0];
> -	rxs = (struct xen_netif_rx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
> +	rxs = (struct xen_netif_rx_sring *)
> +		__get_free_pages(__GFP_ZERO | GFP_NOIO | __GFP_HIGH,
> +				 info->rx_ring_page_order);
>   	if (!rxs) {
>   		err = -ENOMEM;
>   		xenbus_dev_fatal(dev, err, "allocating rx ring page");
> -		goto fail;
> +		goto alloc_rx_ring_fail;
>   	}
>   	SHARED_RING_INIT(rxs);
> -	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
> +	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE * info->rx_ring_pages);
>
> -	err = xenbus_grant_ring(dev, rxs, 1, grefs);
> -	if (err<  0) {
> -		free_page((unsigned long)rxs);
> -		goto fail;
> -	}
> -	info->rx_ring_ref = grefs[0];
> +	err = xenbus_grant_ring(dev, rxs, info->rx_ring_pages,
> +				info->rx_ring_ref);
> +	if (err<  0)
> +		goto grant_rx_ring_fail;
>
>   	err = xenbus_alloc_evtchn(dev,&info->evtchn);
>   	if (err)
> -		goto fail;
> +		goto alloc_evtchn_fail;
>
>   	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
>   					0, netdev->name, netdev);
>   	if (err<  0)
> -		goto fail;
> +		goto bind_fail;
>   	netdev->irq = err;
>   	return 0;
>
> - fail:
> +bind_fail:
> +	xenbus_free_evtchn(dev, info->evtchn);
> +alloc_evtchn_fail:
> +	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->rx.sring);
> +grant_rx_ring_fail:
> +	free_pages((unsigned long)info->rx.sring, info->rx_ring_page_order);
> +alloc_rx_ring_fail:
> +	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->tx.sring);
> +grant_tx_ring_fail:
> +	free_pages((unsigned long)info->tx.sring, info->tx_ring_page_order);
> +fail:
>   	return err;
>   }
>
> @@ -1570,6 +1630,7 @@ static int talk_to_netback(struct xenbus_device *dev,
>   	const char *message;
>   	struct xenbus_transaction xbt;
>   	int err;
> +	int i;
>
>   	/* Create shared ring, alloc event channel. */
>   	err = setup_netfront(dev, info);
> @@ -1583,18 +1644,58 @@ again:
>   		goto destroy_ring;
>   	}
>
> -	err = xenbus_printf(xbt, dev->nodename, "tx-ring-ref", "%u",
> -			    info->tx_ring_ref);
> -	if (err) {
> -		message = "writing tx ring-ref";
> -		goto abort_transaction;
> +	if (info->tx_ring_page_order == 0) {
> +		err = xenbus_printf(xbt, dev->nodename, "tx-ring-ref", "%u",
> +				    info->tx_ring_ref[0]);
> +		if (err) {
> +			message = "writing tx ring-ref";
> +			goto abort_transaction;
> +		}
> +	} else {
> +		err = xenbus_printf(xbt, dev->nodename, "tx-ring-order", "%u",
> +				    info->tx_ring_page_order);
> +		if (err) {
> +			message = "writing tx-ring-order";
> +			goto abort_transaction;
> +		}
> +		for (i = 0; i<  info->tx_ring_pages; i++) {
> +			char name[sizeof("tx-ring-ref")+3];
> +			snprintf(name, sizeof(name), "tx-ring-ref%u", i);
> +			err = xenbus_printf(xbt, dev->nodename, name, "%u",
> +					    info->tx_ring_ref[i]);
> +			if (err) {
> +				message = "writing tx ring-ref";
> +				goto abort_transaction;
> +			}
> +		}
>   	}
> -	err = xenbus_printf(xbt, dev->nodename, "rx-ring-ref", "%u",
> -			    info->rx_ring_ref);
> -	if (err) {
> -		message = "writing rx ring-ref";
> -		goto abort_transaction;
> +
> +	if (info->rx_ring_page_order == 0) {
> +		err = xenbus_printf(xbt, dev->nodename, "rx-ring-ref", "%u",
> +				    info->rx_ring_ref[0]);
> +		if (err) {
> +			message = "writing rx ring-ref";
> +			goto abort_transaction;
> +		}
> +	} else {
> +		err = xenbus_printf(xbt, dev->nodename, "rx-ring-order", "%u",
> +				    info->rx_ring_page_order);
> +		if (err) {
> +			message = "writing rx-ring-order";
> +			goto abort_transaction;
> +		}
> +		for (i = 0; i<  info->rx_ring_pages; i++) {
> +			char name[sizeof("rx-ring-ref")+3];
> +			snprintf(name, sizeof(name), "rx-ring-ref%u", i);
> +			err = xenbus_printf(xbt, dev->nodename, name, "%u",
> +					    info->rx_ring_ref[i]);
> +			if (err) {
> +				message = "writing rx ring-ref";
> +				goto abort_transaction;
> +			}
> +		}
>   	}
> +
>   	err = xenbus_printf(xbt, dev->nodename,
>   			    "event-channel", "%u", info->evtchn);
>   	if (err) {
> @@ -1681,7 +1782,8 @@ static int xennet_connect(struct net_device *dev)
>   	xennet_release_tx_bufs(np);
>
>   	/* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
> -	for (requeue_idx = 0, i = 0; i<  NET_RX_RING_SIZE; i++) {
> +	for (requeue_idx = 0, i = 0; i<  NET_RX_RING_SIZE(np->rx_ring_pages);
> +	     i++) {
>   		skb_frag_t *frag;
>   		const struct page *page;
>   		if (!np->rx_skbs[i])
