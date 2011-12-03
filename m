From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: Re: [PATCH 2/3] caif: Add support for flow-control on device's tx-queue
Date: Sat, 3 Dec 2011 18:35:34 +0100
Message-ID: <CAJK669ZKtmd+Cwz2_G7DtF25yMA33v6-4am=fcnHFTYaBdpwtw@mail.gmail.com>
References: <1322834777-2486-1-git-send-email-sjur.brandeland@stericsson.com>
	<1322834777-2486-3-git-send-email-sjur.brandeland@stericsson.com>
	<1322836682.2762.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:52704 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552Ab1LCRfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 12:35:36 -0500
Received: by qcqz2 with SMTP id z2so775209qcq.19
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 09:35:35 -0800 (PST)
In-Reply-To: <1322836682.2762.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

> >  static int transmit(struct cflayer *layer, struct cfpkt *pkt)
> >  {
> >  	int err;
> > +	struct caif_dev_common *caifdev;
> >  	struct caif_device_entry *caifd =
> >  	    container_of(layer, struct caif_device_entry, layer);
> >  	struct sk_buff *skb;
> > @@ -137,6 +158,33 @@ static int transmit(struct cflayer *layer,
> struct cfpkt *pkt)
> >  	skb->dev = caifd->netdev;
> >  	skb_reset_network_header(skb);
> >  	skb->protocol = htons(ETH_P_CAIF);
> > +	caifdev = netdev_priv(caifd->netdev);
> > +
> > +	if (caifdev->flowctrl == NULL && caifd->netdev->tx_queue_len > 0
> &&
> > +			!caifd->xoff) {
> > +		struct netdev_queue *txq;
> > +		int high;
> > +
> > +		txq = netdev_get_tx_queue(skb->dev, 0);
>
> Why queue 0 and not another one ?

The purpose of flow-control here is to try to avoid loosing
"control" traffic such as AT-commands sent to the modem.

So far we have (too my knowledge) never configured
multiple queues for any CAIF interface. So for current
setup just queue 0 should work just fine.

But in future it might make sense to configure more than one queue:
One queue for control and others for IP traffic or debug.
I think the sensible setup then would be to have control traffic
on queue-0 with flow control, but just ignore overflow other queues
carrying IP and Debug traffic. (For proper IP queue management
this is done in the modem anyway - the radio-link normally
slower than the CAIF link so queues would normally build
in the modem not at the CAIF link interface).

In any case flow control on queue-0 would do.


> > +		high = (caifd->netdev->tx_queue_len * q_high) / 100;
> > +
> > +		/* If we run with a TX queue, check if the queue is too
> long*/
>
> Are you sure only this cpu can run here ? any lock is held ?

I guess there are multiple issues here.
1) Access to tx_queue: I see in net/core/dev.c access to qdisc is RCU
	protected. I believe I should add RCU locking here.

2) I don't believe I need to hold spin_lock for the detection of overflow.
	If I we have races here the worst thing that can
	happened is that Flow-off is a bit off in timing.

3) I think I'll add a spin_lock when accessing caifd->xoff to avoid
	multiple flow-off indications.

I'll make a new patch fixing these issues.

> > +		if (netif_queue_stopped(caifd->netdev) ||
> > +			qdisc_qlen(txq->qdisc) > high) {
> > +
> > +			pr_debug("queue stop(%d) or full (%d>%d) - XOFF\n",
> > +					netif_queue_stopped(caifd->netdev),
> > +					qdisc_qlen(txq->qdisc), high);
> > +			caifd->xoff = 1;
> > +			/* Hijack this skb free callback function. */
> > +			skb_orphan(skb);
> > +			skb->destructor = caif_flow_cb;
> > +			caifd->layer.up->
> > +				ctrlcmd(caifd->layer.up,
> > +					_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
> > +					caifd->layer.id);
> > +		}
> > +	}
> >
> >  	err = dev_queue_xmit(skb);
> >  	if (err > 0)
>
> What prevents dev_queue_xmit() to early orphan skb ?

My understanding is that skb destructor primarily is used for socket
memory accounting. In this case we're fooling the socket accounting,
but it should only happen when hitting the flow-off queue length
threshold. If we have a tx queue on 1000 it would happen at most
every 500 packet, in reality much more seldom.

However I think I can, if I do locking properly, stash away the destructor
and call it when the flow callback is called... what do you think?


Thank you for reviewing this Eric, further feedback welcome.

Regards,
Sjur
