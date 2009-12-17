From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 20:05:02 +0530
Message-ID: <OF6A94FA41.B9EF2995-ON6525768F.004B99AC-6525768F.004F1634@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au> <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com> <20091217134408.GB31964@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:54594 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764763AbZLQOX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 09:23:56 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHENr9O019311
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:53:53 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHENrW72519040
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:53:53 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHENpJ6027403
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 01:23:52 +1100
In-Reply-To: <20091217134408.GB31964@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote on 12/17/2009 07:14:08 PM:

> > I am confused. Isn't dequeue_skb returning NULL for 2nd - nth skbs
> > till the queue is restarted, so how is it broken?
>
> Sorry I didn't read dev_dequeue carefully enough.  Indeed it
> correctly checks the queue status so the loop that I thought
> was there doesn't exist.
>
> The requeues are probably caused by the driver still.  Was Sridhar
> testing Rusty's latest patch?

I was using numbers from his first test run. He has not posted
the requeue numbers for the NAPI run. But he ran with NAPI, and
said:

"I had to change virtnet_xmit_poll() to get it working. See below.
With this change, i don't see any 'queue full' warnings, but requeues
are still happening at the qdisc level (sch_direct_xmit() finds that
tx queue is stopped and does requeues)".

I think the bug is in this check:

+     if (vi->capacity >= 2 + MAX_SKB_FRAGS) {
+           /* Suppress further xmit interrupts. */
+           vi->svq->vq_ops->disable_cb(vi->svq);
+           napi_complete(xmit_napi);
+
+           /* Don't wake it if link is down. */
+           if (likely(netif_carrier_ok(vi->vdev)))
+                 netif_wake_queue(vi->dev);
+     }

We wake up too fast, just enough space for one more skb to be sent
before the queue is stopped again. And hence no more messages about
queue full, but lot of requeues. The qdisc code is doing the correct
thing, but we need to increase the limit here.

Can we try with some big number, 64, 128?

Thanks,

- KK

