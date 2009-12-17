From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 17:26:37 +0530
Message-ID: <OF32B8811E.870B9515-ON6525768F.003F57BD-6525768F.0040952B@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:54954 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762092AbZLQLpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 06:45:31 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHBJ98v018258
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 16:49:09 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHBjTTZ3854468
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 17:15:29 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHBjSPw001300
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 22:45:29 +1100
In-Reply-To: <20091217112754.GA7755@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Jarek Poplawski <jarkao2@gmail.com>
>
> >>> On Wed, Dec 16, 2009 at 09:05:32PM -0800, Sridhar Samudrala wrote:
> >>>
> >>>> I think sch_direct_xmit() is not even calling dev_hard_start_xmit()
as
> >
> >>>> the tx queue is stopped
> >>>> and does a dev_requeue_skb() and returns NETDEV_TX_BUSY.
> >>>>
> >>> Yes but if the queue was stopped then we shouldn't even get into
> >>> sch_direct_xmit.
> >> I don't see any checks for txq_stopped in the callers of
> > sch_direct_xmit() :
> >> __dev_xmit_skb() and qdisc_restart().  Both these routines get the txq
> >> and call
> >> sch_direct_xmit() which checks if tx queue is stopped or frozen.
> >>
> >> Am i missing something?
> >
> > Yes - dequeue_skb.
> >
> > The final skb, before the queue was stopped, is transmitted by
> > the driver. The next time sch_direct_xmit is called, it gets a
> > skb and finds the device is stopped and requeue's the skb.
>
> So we _should_ get into sch_direct_xmit when the queue was stopped...
> I guess Herbert might forget the multiqueue change, and Sridhar isn't
> missing much. ;-)

I meant his question on who is checking tx queue stopped before
calling driver xmit. In stopped queue case, qdisc_restart makes
sure sch_direct_xmit is not called for all subsequent skbs.

Sridhar is seeing 280K requeue's, and that probably implies device
was stopped and wrongly restarted immediately. So the next xmit in
the kernel found the txq is not stopped and called the xmit handler,
get a BUSY, requeue, and so on. That would also explain why his BW
drops so much - all false starts (besides 19% of all skbs being
requeued). I assume that each time when we check:

      if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
            ret = dev_hard_start_xmit(skb, dev, txq);
it passes the check and dev_hard_start_xmit is called wrongly.

#Requeues: 283575
#total skbs: 1469482
Percentage requeued: 19.29%

Thanks,

- KK

