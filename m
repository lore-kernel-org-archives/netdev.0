From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
	hashing.
Date: Thu, 29 Jan 2009 12:34:03 +1100
Message-ID: <20090129013403.GA24043@gondor.apana.org.au>
References: <20090128085358.GA15593@gondor.apana.org.au> <20090128.122231.208600152.davem@davemloft.net> <20090128213141.GD22141@gondor.apana.org.au> <20090128.164058.248259991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752224AbZA2BeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 20:34:08 -0500
Content-Disposition: inline
In-Reply-To: <20090128.164058.248259991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2009 at 04:40:58PM -0800, David Miller wrote:
> 
> It is even the same for "identical" NICs.  Robert Olsson knows this
> quite well :-)
> 
> For example, with the NIU chips the number of TX queues is larger
> than the number of RX queues.

I see that as a temporary issue while the NIC manufacturers are
catching up with the CPU development.  From the CPU's point of
view, the ideal situation is where you reduce the amount of cross-
cache communication to a minimum.  So having more TX queues than
you have cores (or rather caches) isn't all that useful since a
single core can only do so much (and a single piece of wire can
only carry so much data, no matter how many queues you place in
front of it).

Of course having less queues than cores may be the order of the
day for a while and we should certainly deal with that as well
as we can, but we should at least ensure the optimal case where
you have exactly one queue per core/cache is not penalised.

Having said that, it would seem that the randomness isn't too
big a deal since we could always create an interface where the
admin sets it to a fixed value so that we get predictable IRQ
affinity.  So I'm happy :)

> Robert has been proposing some ideas wherein some mapping is
> implemented such that we iterate over a group of TX queues
> per RX queue.
> 
> Otherwise in a routing workload some of the TX queues become
> unused.

If the number of RX queues is less than the number of caches or
cores, then I think this is a great idea and we could use the
stuff that you played with at the Kernel Summit to in effect
boost the number of queues so that all cores are utilised while
incurring the minimum amount of interprocessor communication.

> It's a tricky thing because we don't know where we're sending to of
> course.  It shows that the "RX queue number" is not a sufficient
> seed.

I don't think it really matters where we're sending to.  Ideally
every outbound interface should have a sufficient number of TX
queues so that each core can just deposit its output into a queue
that does not incur cross-CPU overheads.

So from the RX queue's point of view, we want to have the packet
stay on the core it arrived at for as long as possible, with the
best case being the entire duration from the RX queue to the TX
queue.

Now of course if the number of RX queues is too small such that
we can't utilise all the cores, then something has to give.  My
suggestion (as above) would be to multiplex it as early as possible,
i.e., simulat the hardware multiplexer in software if the number
of hardware RX queues is too small.

In fact, while doing the GRO stuff it occured me that this is
the perfect spot to do the multiplexing since it's the first
moment (or at least close to it) when we touch the data.

> One way to deal with this is to grab the hash the chip computed.
> I'm reluctant to advocate this because it's expensive with NIU
> because I have to start using the larger RX descriptor layout
> to get at that cookie.  (see "rx_pkt_hdr0" vs. "rx_pkt_hdr1" in
> drivers/net/niu.h)

That's a separate discussion.  The hash would be useful for the
software multiplexer discussed above, and further processing in
our stack.  But it isn't all that important with regards to keeping
the traffic on the core where it arrived.

So if we can get it then great, but if it's more expensive than
computing one in software then forget it :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
