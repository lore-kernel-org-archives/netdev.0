From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 18:52:55 +0530
Message-ID: <OF6BB64FFB.075C585D-ON6525768F.0047CB9A-6525768F.00487BE4@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au> <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com> <20091217124254.GB8654@ff.dom.local> <20091217125654.GA31560@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:36331 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbZLQNLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 08:11:48 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHClUGE027112
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 18:17:30 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHDBjhF2601164
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 18:41:45 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHDBiLh006440
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 00:11:45 +1100
In-Reply-To: <20091217125654.GA31560@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote on 12/17/2009 06:26:54 PM:

>
> > On Thu, Dec 17, 2009 at 05:57:15PM +0530, Krishna Kumar2 wrote:
> > > the first resched. I also think the resched in requeue is probably
> > > not required, since the device will call netif_tx_wake_queue anyway.
>
> Actually, the requeue is there for the case where we hit lock
> contention on the device TX lock so it is needed for that at
> least.
>
> However, for the case where the device queue is stopped you're
> right we don't need to reschedule.

Yes, my patch had a handle for both cases by adding another arg
to dev_requeue_skb, something like:

static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q,
                                  int reason)
{
      q->gso_skb = skb;
      q->qstats.requeues++;
      q->q.qlen++;    /* it's still part of the queue */

      if (reason != NETDEV_TX_BUSY)
            __netif_schedule(q);

      return 0;
}

and pass the reason in the two places that call requeue. I didn't
submit it since it felt a small optimization - avoiding one resched
per stopped txq (not for every skb), plus I was not sure if every
driver would properly call netif_tx_wake_queue.

thanks,

- KK

