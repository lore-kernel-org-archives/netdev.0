From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Fri, 24 Jul 2009 16:37:49 +0800
Message-ID: <20090724083749.GA23521@gondor.apana.org.au>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain> <20090724083006.GA5698@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38953 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750826AbZGXIiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 04:38:00 -0400
Content-Disposition: inline
In-Reply-To: <20090724083006.GA5698@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2009 at 08:30:06AM +0000, Jarek Poplawski wrote:
> On 20-07-2009 09:46, Krishna Kumar wrote:
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> > 
> > Driver sends an skb and stops the queue if no more space is
> > available on the device, and returns OK. When dev_queue_xmit
> > runs for the next skb, it enqueue's the skb & calls qdisc_run.
> > qdisc_run dequeue's the skb and finds the queue is stopped
> > after getting the HARD_LOCK_TX, and puts the skb back on
> > gso_skb (the next iteration fails faster at dequeue_skb).
> > 
> > This patch avoids calling __qdisc_run if the queue is stopped.
> > This also lets us remove the queue_stopped check in dequeue_skb
> > and in qdisc_restart.
> 
> It was designed wrt. multiqueue handling mainly, were such a check
> isn't enough at this place.

Well multiqueue TX was designed so that each CPU could have its
own queue.  While this isn't always the case due to resource
constraints and legacy applications, we should optimise for the
case where each CPU is using its own TX queue.

Of course we should still maintain correctness should the unexpected
occur.

So while I agree with Krishna's patch in principle, someone needs to
make sure that it still does the right thing (i.e., it doesn't
introduce potential starvation) if one CPU transmits to someone
else's queue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
