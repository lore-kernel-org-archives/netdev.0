From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH v2] xen network backend driver
Date: Wed, 9 Feb 2011 13:47:44 +0000
Message-ID: <1297259264.28185.6.camel@zakaz.uk.xensource.com>
References: <1297160635.9149.21.camel@zakaz.uk.xensource.com>
	 <20110208164158.GA9584@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22163 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754893Ab1BINrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 08:47:47 -0500
In-Reply-To: <20110208164158.GA9584@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review. Comments below.

On Tue, 2011-02-08 at 16:41 +0000, Francois Romieu wrote: 
> Ian Campbell <Ian.Campbell@citrix.com> :
> [...]
> >       * Dropped the tasklet mode for the backend worker leaving only the
> >         kthread mode. I will revisit the suggestion to use NAPI on the
> >         driver side in the future, I think it's somewhat orthogonal to
> >         the use of kthread here, but it seems likely to be a worthwhile
> >         improvement either way. 
> 
> I have not dug into bind_interdomain_evtchn_to_irqhandler but I would
> expect the kthread to go away once NAPI is plugged into xenvif_interrupt().

bind_interdomain_evtchn_to_irqhandler is analogous to request_irq except
it takes a foreign domain and an evtchn reference instead of an IRQ so I
think it's use is not related to NAPI vs. kthread.

I figure some better explanation/background for the non-Xen folks
regarding the current structure is probably in order. So:

Netback is effectively implementing a NIC in software. Some of the
operations required to do this are more expensive than what would
normally happen within a driver (e.g. copying to/from guest buffers
posted by the frontend driver). They are operations which would normally
be implemented by hardware/DMA/etc in a non-virtual system.

In some sense the kthread (and netback.c) embodies the "hardware"
portion of netback. The driver portion (interface.c) defers the actual
work to the thread and is mostly a pretty normal driver.

It's possible that switching the driver to NAPI will allow us to pull
some work up out of the netback thread into the NAPI context but I think
the bulk of the work is too expensive to do there. In the past when
netback used tasklets instead of kthreads we found that doing netback
processing in that context had a fairly detrimental effect on the host
(e.g. nothing else gets to run), doing the processing in the kthread
allows it to be scheduled and controlled alongside everything else.

That said I am going to try switching the driver over to NAPI and see if
it is workable to pull some/all of the netback functionality up into
that context but unless it's a blocker for upstream acceptance I would
like to defer that work until afterwards. 

[...]
> > +/*
> > + * Implement our own carrier flag: the network stack's version causes delays
> > + * when the carrier is re-enabled (in particular, dev_activate() may not
> > + * immediately be called, which can cause packet loss; also the etherbridge
> > + * can be rather lazy in activating its port).
> > + */
> 
> I have found a netif_carrier_off(vif->dev) but no
> netif_carrier_on(vif->dev). Did I overlook something ?

Huh, yeah. It's apparently been that way for years. I'll investigate.

[...]
> > +	if (xenvif_schedulable(vif) && !xenvif_queue_full(vif))
> 
> This test appears three times along the code. Factor it out ?

Yes, good idea.

[...]
> > +		netif_wake_queue(vif->dev);
> > +
> > +	return IRQ_HANDLED;
> > +}
> > +
> > +static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	struct xenvif *vif = netdev_priv(dev);
> > +
> > +	BUG_ON(skb->dev != dev);
> > +
> > +	if (vif->netbk == NULL)
> 
> How is it supposed to happen ?

Apart from "ifconfig down" it can happen when either the frontend driver
shuts itself down or the toolstack hotunplugs the network device and
tearsdown the backend. 

xenvif_disconnect
	xenvif_down
		xen_netbk_remove_xenvif
			vif->netbk = NULL

However xenvif_down is always called with RTNL held. So perhaps the
check is unnecessary. I'll investigate. 

> 
> > +		goto drop;
> > +
> > +	/* Drop the packet if the target domain has no receive buffers. */
> > +	if (unlikely(!xenvif_schedulable(vif) || xenvif_queue_full(vif)))
> > +		goto drop;
> > +
> > +	/* Reserve ring slots for the worst-case number of fragments. */
> > +	vif->rx_req_cons_peek += xen_netbk_count_skb_slots(vif, skb);
> > +	xenvif_get(vif);
> > +
> > +	if (vif->can_queue && xenvif_queue_full(vif)) {
> > +		vif->rx.sring->req_event = vif->rx_req_cons_peek +
> > +			xenvif_max_required_rx_slots(vif);
> > +		mb(); /* request notification /then/ check & stop the queue */
> > +		if (xenvif_queue_full(vif))
> > +			netif_stop_queue(dev);
> > +	}
> > +
> > +	xen_netbk_queue_tx_skb(vif, skb);
> 
> Why not do the real work (xen_netbk_rx_action) here and avoid the skb list
> lock ?  Batching ?

Partly batching but also for the reasons described above.

> > +
> > +	return 0;
> 
> NETDEV_TX_OK

OK

> > +
> > + drop:
> > +	vif->stats.tx_dropped++;
> > +	dev_kfree_skb(skb);
> > +	return 0;
> 
> NETDEV_TX_OK

There is no NETDEV_TX_DROPPED or similar so I guess this is right?

> > +}
> > +
> [...]
> > +struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
> > +			    unsigned int handle)
> > +{
> > +	int err = 0;
> 
> Useless init.

OK

[...]
> > +	vif = netdev_priv(dev);
> > +	memset(vif, 0, sizeof(*vif));
> 
> Useless memset. It is kzalloced behind the scene.

OK

[...]
> > +	rtnl_lock();
> > +	err = register_netdevice(dev);
> > +	rtnl_unlock();
> 
> register_netdev() will do the locking for you.

OK

[...]
> > +
> > +	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> > +	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
> > +
> > +	u16 pending_ring[MAX_PENDING_REQS];
> 
> Group the [MAX_PENDING_REQS] arrays as a single array ?

tx_copy_ops is used to marshal arguments to a hypercall so has to be a
standalone array like that.

The indexes into pending_tx_info and pending_ring are not the same so I
think combining them would be confusing.

> 
> [...]
> > +static int xen_netbk_kthread(void *data)
> > +{
> > +	struct xen_netbk *netbk = (struct xen_netbk *)data;
> 
> Useless cast.

OK

> > +	while (!kthread_should_stop()) {
> > +		wait_event_interruptible(netbk->wq,
> > +				rx_work_todo(netbk)
> > +				|| tx_work_todo(netbk)
> > +				|| kthread_should_stop());
> 
> Please put || at the end of the line.

OK

> [...]
> > +static int __init netback_init(void)
> > +{
> > +	int i;
> > +	int rc = 0;
> > +	int group;
> > +
> > +	if (!xen_pv_domain())
> > +		return -ENODEV;
> > +
> > +	xen_netbk_group_nr = num_online_cpus();
> > +	xen_netbk = vmalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
> > +	if (!xen_netbk) {
> > +		printk(KERN_ALERT "%s: out of memory\n", __func__);
> > +		return -ENOMEM;
> > +	}
> > +	memset(xen_netbk, 0, sizeof(struct xen_netbk) * xen_netbk_group_nr);
> 
> vzalloc

OK

[...]
> > +failed_init:
> > +	for (i = 0; i < group; i++) {
> 
> 	while (--group >= 0) ?

Good idea.

> > +		struct xen_netbk *netbk = &xen_netbk[i];
> > +		int j;
> > +		for (j = 0; j < MAX_PENDING_REQS; j++) {
> > +			if (netbk->mmap_pages[i])
>                                               ^ j ?
> > +				__free_page(netbk->mmap_pages[i]);
>                                                               ^ j ?
> > +		}

Yes, good catch, thanks! (actually since --group >= 0 I made this i
throughout) 

Ian.





