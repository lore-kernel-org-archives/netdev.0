From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Thu, 17 Dec 2009 15:33:57 +0530
Message-ID: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com> <20091217031539.GA26087@gondor.apana.org.au> <4B29BC1C.7090800@us.ibm.com> <20091217062853.GA27734@gondor.apana.org.au> <4B29D36F.5000802@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:43394 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbZLQJww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 04:52:52 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBH9SZJg000580
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 14:58:35 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBH9qmCU1556494
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 15:22:48 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBH9qmpL017267
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 15:22:48 +0530
In-Reply-To: <4B29D36F.5000802@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sridhar Samudrala <sri@us.ibm.com>
>
> Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
>
> Herbert Xu wrote:
> > On Wed, Dec 16, 2009 at 09:05:32PM -0800, Sridhar Samudrala wrote:
> >
> >> I think sch_direct_xmit() is not even calling dev_hard_start_xmit() as

> >> the tx queue is stopped
> >> and does a dev_requeue_skb() and returns NETDEV_TX_BUSY.
> >>
> >
> > Yes but if the queue was stopped then we shouldn't even get into
> > sch_direct_xmit.
> I don't see any checks for txq_stopped in the callers of
sch_direct_xmit() :
> __dev_xmit_skb() and qdisc_restart().  Both these routines get the txq
> and call
> sch_direct_xmit() which checks if tx queue is stopped or frozen.
>
> Am i missing something?

Yes - dequeue_skb.

The final skb, before the queue was stopped, is transmitted by
the driver. The next time sch_direct_xmit is called, it gets a
skb and finds the device is stopped and requeue's the skb. For
all subsequent xmits, dequeue_skb returns NULL (and the other
caller - __dev_xmit_skb can never be called since qdisc_qlen is
true) and thus requeue's will not happen. This also means that
the number of requeues you see (eg 283K in one run) is the number
of times the queue was stopped and restarted. So it looks like
driver either:

1. didn't stop the queue when xmiting a packet successfully (the
      condition being that it would not be possible to xmit the
      next skb). But this doesn't seem to be the case.
2. wrongly restarted the queue. Possible - since a few places
      use both the start & wake queue api's.

Thanks,

- KK

