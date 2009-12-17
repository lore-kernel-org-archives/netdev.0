From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 18:26:33 +0530
Message-ID: <OF5A62ABA0.8A2B2426-ON6525768F.0044F439-6525768F.004611D6@in.ibm.com>
References: <20091217111219.9809.27432.sendpatchset@krkumar2.in.ibm.com> <20091217123153.GA31131@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:46486 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbZLQMp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:45:26 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHCjNOq009858
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 18:15:23 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHCjNc53727562
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 18:15:23 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHCjMYV013699
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 23:45:23 +1100
In-Reply-To: <20091217123153.GA31131@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote on 12/17/2009 06:01:53 PM:
>
> > On a (slightly) related note, qdisc_restart() has this code:
> >    /* Dequeue packet */
> >    skb = dequeue_skb(q);
> >    if (unlikely(!skb))
> >       return 0;
> >
> > When a txq is stopped, all subsequent dev_queue_xmits will
> > execute this path, pass the "unlikely" code, and return. Is
> > it reasonable to remove "unlikely" in both dequeue_skb and
> > qdisc_restart, if so patch inlined below:
>
> Why would it return skb == NULL? If the queue is stopped, then
> chances are packets will pile up in the qdisc so dequeue_skb
> should return a non-NULL skb.

Since dequeue_skb finds the first skb that was cached in gso_skb,
handles the stopped txq and returns NULL for all subsequent skbs.
And qdisc_restart bails out immediately. Only the first skb will
get requeue'd, and no more skbs are taken out of the queue -
either dequeue or gso_skb, till the driver restarts the queue.
That's why I think this code is not the issue, and probably as
optimized as possible for all cases.

I still feel the device is wrongly waking up the txq, and next
tx fails, driver stops the queue, and core does another requeue/sched,
and so on.

thanks,

- KK

