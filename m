From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Tue, 23 Sep 2008 14:23:33 +0800
Message-ID: <20080923062333.GA26595@gondor.apana.org.au>
References: <20080920.223538.130375517.davem@davemloft.net> <20080920.225033.261544815.davem@davemloft.net> <20080921063821.GA8677@gondor.apana.org.au> <20080921.000301.198672963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34223 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752000AbYIWGXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 02:23:46 -0400
Content-Disposition: inline
In-Reply-To: <20080921.000301.198672963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 12:03:01AM -0700, David Miller wrote:
>
> This works if you want it at the root, but what if you only wanted to
> prio at a leaf?  I think that case has value too.

Good question :)

I think what we should do is to pass some token that rerepsents
the TX queue that's being run down into the dequeue function.

Then each qdisc can decide which child to recursively dequeue
based on that token (or ignore it for non-prio qdiscs such as
HTB).  When the token reaches the leaf then we have two cases:

1) A prio-like qdisc that has separate queues based on priorities.
In this case we dequeue the respective queue based on the token.

2) Any other qdisc.  We dequeue the first packet that hashes
into the queue given by the token.  Ideally these qdiscs should
have separate queues already so that this would be trivial.

> I tend to also disagree with another mentioned assertion.  The one
> where having a shared qdisc sucks on SMP.  It doesn't.  The TX queue
> lock is held much longer than the qdisc lock.

Yes I was exaggerating :)

However, after answering your question above I'm even more convinced
that we should be separating the traffic at the point of enqueueing,
and not after we dequeue it in qdisc_run.

The only reason to do the separation after dequeueing would be to
allow the TX queue selction to change in the time being.  However,
since I see absolutely no reason why we'd need that, it's just so
much simpler to separate them at qdisc_enqueue, and actually have
the same number of software queues as there are hardware queues.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
