From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
 hashing.
Date: Wed, 28 Jan 2009 16:40:58 -0800 (PST)
Message-ID: <20090128.164058.248259991.davem@davemloft.net>
References: <20090128085358.GA15593@gondor.apana.org.au>
	<20090128.122231.208600152.davem@davemloft.net>
	<20090128213141.GD22141@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751508AbZA2AlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 19:41:01 -0500
In-Reply-To: <20090128213141.GD22141@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 29 Jan 2009 08:31:41 +1100

> On Wed, Jan 28, 2009 at 12:22:31PM -0800, David Miller wrote:
> >
> > No matter what you think about the randomness aspect, our
> > divide avoidance technique being used here will still
> > get in the way of the situations you seem to be concerned
> > about.
> > 
> > We do the jhash et al. magic in order to be able to use a
> > multiply to get the modulus.  So the function computing from
> > RX to TX queue numbers will never be straightforward.
> 
> Right, if the number of queues weren't equal then clearly it's
> not an issue to tack on more randomness.  But I was thinking of
> scenarios where you have two identical NICs, performing routing
> where the number of queues is likely to be identical.

It is even the same for "identical" NICs.  Robert Olsson knows this
quite well :-)

For example, with the NIU chips the number of TX queues is larger
than the number of RX queues.

Robert has been proposing some ideas wherein some mapping is
implemented such that we iterate over a group of TX queues
per RX queue.

Otherwise in a routing workload some of the TX queues become
unused.

That's a fun hack for testing when you know the characteristics of
all of the devices in your system, but doesn't generalize well.

It's a tricky thing because we don't know where we're sending to of
course.  It shows that the "RX queue number" is not a sufficient
seed.

One way to deal with this is to grab the hash the chip computed.
I'm reluctant to advocate this because it's expensive with NIU
because I have to start using the larger RX descriptor layout
to get at that cookie.  (see "rx_pkt_hdr0" vs. "rx_pkt_hdr1" in
drivers/net/niu.h)

And I suspect other cards will require similar tradeoffs.
