From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] xen network backend driver
Date: Tue, 8 Feb 2011 17:41:58 +0100
Message-ID: <20110208164158.GA9584@electric-eye.fr.zoreil.com>
References: <1297160635.9149.21.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39545 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705Ab1BHQpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 11:45:30 -0500
Content-Disposition: inline
In-Reply-To: <1297160635.9149.21.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Campbell <Ian.Campbell@citrix.com> :
[...]
>       * Dropped the tasklet mode for the backend worker leaving only the
>         kthread mode. I will revisit the suggestion to use NAPI on the
>         driver side in the future, I think it's somewhat orthogonal to
>         the use of kthread here, but it seems likely to be a worthwhile
>         improvement either way. 

I have not dug into bind_interdomain_evtchn_to_irqhandler but I would
expect the kthread to go away once NAPI is plugged into xenvif_interrupt().

[...]
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> new file mode 100644
> index 0000000..98a992d
> --- /dev/null
> +++ b/drivers/net/xen-netback/interface.c
> @@ -0,0 +1,550 @@
> +/*
> + * Network-device interface management.
> + *
> + * Copyright (c) 2004-2005, Keir Fraser
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation; or, when distributed
> + * separately from the Linux kernel or incorporated into other
> + * software packages, subject to the following license:
> + *
> + * Permission is hereby granted, free of charge, to any person obtaining a copy
> + * of this source file (the "Software"), to deal in the Software without
> + * restriction, including without limitation the rights to use, copy, modify,
> + * merge, publish, distribute, sublicense, and/or sell copies of the Software,
> + * and to permit persons to whom the Software is furnished to do so, subject to
> + * the following conditions:
> + *
> + * The above copyright notice and this permission notice shall be included in
> + * all copies or substantial portions of the Software.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> + * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> + * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> + * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> + * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
> + * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
> + * IN THE SOFTWARE.
> + */
> +
> +#include "common.h"
> +
> +#include <linux/ethtool.h>
> +#include <linux/rtnetlink.h>
> +
> +#include <xen/events.h>
> +#include <asm/xen/hypercall.h>
> +
> +#define XENVIF_QUEUE_LENGTH 32
> +
> +void xenvif_get(struct xenvif *vif)
> +{
> +	atomic_inc(&vif->refcnt);
> +}
> +
> +void xenvif_put(struct xenvif *vif)
> +{
> +	if (atomic_dec_and_test(&vif->refcnt))
> +		wake_up(&vif->waiting_to_free);
> +}
> +
> +static int xenvif_max_required_rx_slots(struct xenvif *vif)
> +{
> +	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
> +
> +	if (vif->can_sg || vif->gso || vif->gso_prefix)
> +		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> +
> +	return max;
> +}
> +
> +int xenvif_queue_full(struct xenvif *vif)
> +{
> +	RING_IDX peek   = vif->rx_req_cons_peek;
> +	RING_IDX needed = xenvif_max_required_rx_slots(vif);
> +
> +	return ((vif->rx.sring->req_prod - peek) < needed) ||
> +	       ((vif->rx.rsp_prod_pvt + XEN_NETIF_RX_RING_SIZE - peek) < needed);
> +}
> +
> +/*
> + * Implement our own carrier flag: the network stack's version causes delays
> + * when the carrier is re-enabled (in particular, dev_activate() may not
> + * immediately be called, which can cause packet loss; also the etherbridge
> + * can be rather lazy in activating its port).
> + */

I have found a netif_carrier_off(vif->dev) but no
netif_carrier_on(vif->dev). Did I overlook something ?

> +static void xenvif_carrier_on(struct xenvif *vif)
> +{
> +	vif->carrier = 1;
> +}
> +static void xenvif_carrier_off(struct xenvif *vif)
> +{
> +	vif->carrier = 0;
> +}
> +static int xenvif_carrier_ok(struct xenvif *vif)
> +{
> +	return vif->carrier;
> +}
> +
> +int xenvif_schedulable(struct xenvif *vif)
> +{
> +	return netif_running(vif->dev) && xenvif_carrier_ok(vif);
> +}
> +
> +static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
> +{
> +	struct xenvif *vif = dev_id;
> +
> +	if (vif->netbk == NULL)
> +		return IRQ_NONE;
> +
> +	xen_netbk_schedule_xenvif(vif);
> +
> +	if (xenvif_schedulable(vif) && !xenvif_queue_full(vif))

This test appears three times along the code. Factor it out ?

> +		netif_wake_queue(vif->dev);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct xenvif *vif = netdev_priv(dev);
> +
> +	BUG_ON(skb->dev != dev);
> +
> +	if (vif->netbk == NULL)

How is it supposed to happen ?

xenvif_open
	xenvif_up
		xen_netbk_add_xenvif
			netbk = &xen_netbk[min_group];

			vif->netbk = netbk;
	netif_start_queue

> +		goto drop;
> +
> +	/* Drop the packet if the target domain has no receive buffers. */
> +	if (unlikely(!xenvif_schedulable(vif) || xenvif_queue_full(vif)))
> +		goto drop;
> +
> +	/* Reserve ring slots for the worst-case number of fragments. */
> +	vif->rx_req_cons_peek += xen_netbk_count_skb_slots(vif, skb);
> +	xenvif_get(vif);
> +
> +	if (vif->can_queue && xenvif_queue_full(vif)) {
> +		vif->rx.sring->req_event = vif->rx_req_cons_peek +
> +			xenvif_max_required_rx_slots(vif);
> +		mb(); /* request notification /then/ check & stop the queue */
> +		if (xenvif_queue_full(vif))
> +			netif_stop_queue(dev);
> +	}
> +
> +	xen_netbk_queue_tx_skb(vif, skb);

Why not do the real work (xen_netbk_rx_action) here and avoid the skb list
lock ?  Batching ?

> +
> +	return 0;

NETDEV_TX_OK

> +
> + drop:
> +	vif->stats.tx_dropped++;
> +	dev_kfree_skb(skb);
> +	return 0;

NETDEV_TX_OK

> +}
> +
[...]
> +struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
> +			    unsigned int handle)
> +{
> +	int err = 0;

Useless init.

> +	struct net_device *dev;
> +	struct xenvif *vif;
> +	char name[IFNAMSIZ] = {};
> +
> +	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
> +	dev = alloc_netdev(sizeof(struct xenvif), name, ether_setup);
> +	if (dev == NULL) {
> +		pr_debug("Could not allocate netdev\n");
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	SET_NETDEV_DEV(dev, parent);
> +
> +	vif = netdev_priv(dev);
> +	memset(vif, 0, sizeof(*vif));

Useless memset. It is kzalloced behind the scene.

> +	vif->domid  = domid;
> +	vif->handle = handle;
> +	vif->netbk  = NULL;
> +	vif->can_sg = 1;
> +	vif->csum = 1;
> +	atomic_set(&vif->refcnt, 1);
> +	init_waitqueue_head(&vif->waiting_to_free);
> +	vif->dev = dev;
> +	INIT_LIST_HEAD(&vif->list);
> +
> +	xenvif_carrier_off(vif);
> +
> +	vif->credit_bytes = vif->remaining_credit = ~0UL;
> +	vif->credit_usec  = 0UL;
> +	init_timer(&vif->credit_timeout);
> +	/* Initialize 'expires' now: it's used to track the credit window. */
> +	vif->credit_timeout.expires = jiffies;
> +
> +	dev->netdev_ops	= &xenvif_netdev_ops;
> +	xenvif_set_features(vif);
> +	SET_ETHTOOL_OPS(dev, &xenvif_ethtool_ops);
> +
> +	dev->tx_queue_len = XENVIF_QUEUE_LENGTH;
> +
> +	/*
> +	 * Initialise a dummy MAC address. We choose the numerically
> +	 * largest non-broadcast address to prevent the address getting
> +	 * stolen by an Ethernet bridge for STP purposes.
> +	 * (FE:FF:FF:FF:FF:FF)
> +	 */
> +	memset(dev->dev_addr, 0xFF, ETH_ALEN);
> +	dev->dev_addr[0] &= ~0x01;
> +
> +	rtnl_lock();
> +	err = register_netdevice(dev);
> +	rtnl_unlock();

register_netdev() will do the locking for you.

> +	if (err) {
> +		pr_debug("Could not register new net device %s: err=%d\n",
> +			 dev->name, err);
> +		free_netdev(dev);
> +		return ERR_PTR(err);
> +	}
> +
> +	pr_debug("Successfully created xenvif\n");
> +	return vif;
> +}
> +
[...]
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> new file mode 100644
> index 0000000..fbddf3d
> --- /dev/null
> +++ b/drivers/net/xen-netback/netback.c
[...]
> +struct xen_netbk {
> +	wait_queue_head_t wq;
> +	struct task_struct *task;
> +
> +	struct sk_buff_head rx_queue;
> +	struct sk_buff_head tx_queue;
> +
> +	struct timer_list net_timer;
> +
> +	struct page *mmap_pages[MAX_PENDING_REQS];
> +
> +	pending_ring_idx_t pending_prod;
> +	pending_ring_idx_t pending_cons;
> +	struct list_head net_schedule_list;
> +
> +	/* Protect the net_schedule_list in netif. */
> +	spinlock_t net_schedule_list_lock;
> +
> +	atomic_t netfront_count;
> +
> +	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> +	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
> +
> +	u16 pending_ring[MAX_PENDING_REQS];

Group the [MAX_PENDING_REQS] arrays as a single array ?

> +
> +	/*
> +	 * Each head or fragment can be up to 4096 bytes. Given
> +	 * MAX_BUFFER_OFFSET of 4096 the worst case is that each
> +	 * head/fragment uses 2 copy operation.
> +	 */
> +	struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
> +	unsigned char rx_notify[NR_IRQS];
> +	u16 notify_list[XEN_NETIF_RX_RING_SIZE];
> +	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
> +};
> +
[...]
> +static int xen_netbk_kthread(void *data)
> +{
> +	struct xen_netbk *netbk = (struct xen_netbk *)data;

Useless cast.

> +	while (!kthread_should_stop()) {
> +		wait_event_interruptible(netbk->wq,
> +				rx_work_todo(netbk)
> +				|| tx_work_todo(netbk)
> +				|| kthread_should_stop());

Please put || at the end of the line.

[...]
> +static int __init netback_init(void)
> +{
> +	int i;
> +	int rc = 0;
> +	int group;
> +
> +	if (!xen_pv_domain())
> +		return -ENODEV;
> +
> +	xen_netbk_group_nr = num_online_cpus();
> +	xen_netbk = vmalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
> +	if (!xen_netbk) {
> +		printk(KERN_ALERT "%s: out of memory\n", __func__);
> +		return -ENOMEM;
> +	}
> +	memset(xen_netbk, 0, sizeof(struct xen_netbk) * xen_netbk_group_nr);

vzalloc

> +
> +	for (group = 0; group < xen_netbk_group_nr; group++) {
> +		struct xen_netbk *netbk = &xen_netbk[group];
> +		skb_queue_head_init(&netbk->rx_queue);
> +		skb_queue_head_init(&netbk->tx_queue);
> +
> +		init_timer(&netbk->net_timer);
> +		netbk->net_timer.data = (unsigned long)netbk;
> +		netbk->net_timer.function = xen_netbk_alarm;
> +
> +		netbk->pending_cons = 0;
> +		netbk->pending_prod = MAX_PENDING_REQS;
> +		for (i = 0; i < MAX_PENDING_REQS; i++)
> +			netbk->pending_ring[i] = i;
> +
> +		init_waitqueue_head(&netbk->wq);
> +		netbk->task = kthread_create(xen_netbk_kthread,
> +					     (void *)netbk,
> +					     "netback/%u", group);
> +
> +		if (IS_ERR(netbk->task)) {
> +			printk(KERN_ALERT "kthread_run() fails at netback\n");
> +			del_timer(&netbk->net_timer);
> +			rc = PTR_ERR(netbk->task);
> +			goto failed_init;
> +		}
> +
> +		kthread_bind(netbk->task, group);
> +
> +		INIT_LIST_HEAD(&netbk->net_schedule_list);
> +
> +		spin_lock_init(&netbk->net_schedule_list_lock);
> +
> +		atomic_set(&netbk->netfront_count, 0);
> +
> +		wake_up_process(netbk->task);
> +	}
> +
> +	rc = xenvif_xenbus_init();
> +	if (rc)
> +		goto failed_init;
> +
> +	return 0;
> +
> +failed_init:
> +	for (i = 0; i < group; i++) {

	while (--group >= 0) ?

> +		struct xen_netbk *netbk = &xen_netbk[i];
> +		int j;
> +		for (j = 0; j < MAX_PENDING_REQS; j++) {
> +			if (netbk->mmap_pages[i])
                                              ^ j ?
> +				__free_page(netbk->mmap_pages[i]);
                                                              ^ j ?
> +		}


> +		del_timer(&netbk->net_timer);
> +		kthread_stop(netbk->task);
> +	}
> +	vfree(xen_netbk);
> +	return rc;
> +
> +}
> +

-- 
Ueimor
