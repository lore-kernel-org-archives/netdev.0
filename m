From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 17:57:15 +0530
Message-ID: <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:58688 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbZLQMQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:16:09 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHBpoiC021089
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 17:21:52 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHCG6ql3211488
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 17:46:06 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHCG4Tr025745
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 17:46:05 +0530
In-Reply-To: <20091217120856.GA30774@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote on 12/17/2009 05:38:56 PM:

> > And indeed, this new requeue behaviour was introduced in 2.6.32.
>
> Actually no, it was merely rearranged.  It would appear that this
> behaviour has been around for over a year.
>
> It is even worse than I thought.  Not only would new tx packets
> trigger this unnecessary queue run, but once it is triggered, it
> would consume 100% CPU as dev_requeue_skb unconditionally reschedules
> the queue!
>
> Tell me this is not true please...

Hi Herbert,

I am confused. Isn't dequeue_skb returning NULL for 2nd - nth skbs
till the queue is restarted, so how is it broken?

__dev_xmit_skb calls sch_direct_xmit only once after the device is
stopped, and this call results in skb being re-queued. Next call to
__dev_xmit_skb calls qdisc_restart which will always bail out since
dev_dequeue returns NULL. We also avoid rescheduling the queue after
the first resched. I also think the resched in requeue is probably
not required, since the device will call netif_tx_wake_queue anyway.

dev_dequeue()
{
      if (unlikely(skb)) {
            struct net_device *dev = qdisc_dev(q);
            struct netdev_queue *txq;

            /* check the reason of requeuing without tx lock first */
            txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
            if (!netif_tx_queue_stopped(txq) &&
                !netif_tx_queue_frozen(txq)) {
                        q->gso_skb = NULL;
                        q->q.qlen--;
            } else
                  skb = NULL;
}

Thanks,

- KK

