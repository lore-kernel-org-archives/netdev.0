From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 21 Sep 2008 15:38:21 +0900
Message-ID: <20080921063821.GA8677@gondor.apana.org.au>
References: <20080920.002137.108837580.davem@davemloft.net> <20080920234843.GA2531@ami.dom.local> <20080920.223538.130375517.davem@davemloft.net> <20080920.225033.261544815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37131 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750997AbYIUGi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 02:38:28 -0400
Content-Disposition: inline
In-Reply-To: <20080920.225033.261544815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2008 at 10:50:33PM -0700, David Miller wrote:
>
> Ok, here is the kind of thing I'm suggesting in all of this.
> 
> It gets rid of bouncing unnecessarily into __qdisc_run() when
> dev_queue_xmit()'s finally selected TXQ is stopped.
> 
> It also gets rid of the dev_requeue_skb() looping case Jarek
> discovered.

Looks good to me.

However, I've changed my mind about letting this thread die :)

Let's go back to the basic requirements.  I claim that there
are exactly two different ways for which multiple TX queues are
useful:  SMP scaling and QOS.  In the first case we stuff different
flows into different queues to reduce contention between CPUs.
In the latter case we put packets of different priorities into
different queues in order to prevent a storm of lower priority
packets from starving higher priority ones that arrive later.

Despite the different motivations, these two scenarios have
one thing in common, we can structure it such that there is
a one-to-one correspondence between the qdisc/software queues
and the hardware queues.  I know that this isn't currently the
case for prio but I'll get to that later in the message.

What I'm trying to say is that we shouldn't ever support cases
where a single qdisc empties into multiple TX queues.  It just
doesn't make sense.

For example, if you were using a qdisc like TBF, multiple queues
buy you absolutely nothing.  All it does is give you a longer queue
to stuff packets into but you can already get that in software.

Why am I saying all this? It's because a lot of the complexity
in the current code comes from supporting the case of one qdisc
queue mapping onto n hardware queues.  If we didn't do that then
handling stopped queues becomes trivial (or at least as easy as
it was before).

Put it another way, it makes absolutely no sense to map packets
onto different queues after you've dequeued them from a single
qdisc queue.  The mapping by hashing is for SMP scalability only
and if you've already gone through a single qdisc queue you can
stop worrying about it because it will suck on SMP :)

Going back to the case of prio, I think what we should do is to
create a separate qdisc queue for each band.  The qdisc selection
should be done before the packet is queued, just as we do in the
TX hashing case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
