From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 11:15:48 +0800
Message-ID: <20090729031548.GA2435@gondor.apana.org.au>
References: <20090729012523.GA1583@gondor.apana.org.au> <20090728.183451.93398827.davem@davemloft.net> <20090729021212.GA1946@gondor.apana.org.au> <20090728.192247.247655474.davem@davemloft.net> <20090729023809.GA2218@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37016 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752703AbZG2DP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 23:15:57 -0400
Content-Disposition: inline
In-Reply-To: <20090729023809.GA2218@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 10:38:09AM +0800, Herbert Xu wrote:
>
> I did say it wasn't a good answer :)

Here's another crazy idea:

Forget about using multiple hardware TX queues with rate limiting
qdiscs.  Why? Because these qdiscs are fundamentally serialising
so once the traffic has gone through it there is nothing to be
gained from multiplexing them into the hardware only to be merged
again onto the wire right away.

So does this mean that we give up on CPU scalability on limiting
qdiscs? No, the bottleneck is in fact in the qdisc, not in the
NIC.  So we implement multiqueue in the qdisc instead.

This can be done with a lockless ring buffer.  Each CPU would
deposit its packets in a qdisc ringer buffer assigned to it.
The qdisc would then run on a single CPU harvesting all the
ring buffers in some fair manner.

Essentially we can treat rate limiting qdiscs as NICs.  Another
way of thinking about this is that we're essentially decoupling
a single system into two.  One that is using a default qdisc to
achieve maximum throughput.  This is then fed into a second system
that is dedicated to rate limiting.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
