From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Fri, 22 Aug 2008 16:56:55 +1000
Message-ID: <20080822065655.GA18471@gondor.apana.org.au>
References: <20080721164306.GA13131@gondor.apana.org.au> <20080721.095124.89249903.davem@davemloft.net> <20080721170233.GA13417@gondor.apana.org.au> <20080721.100821.38432201.davem@davemloft.net> <20080721171141.GA13573@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45015 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753399AbYHVG5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 02:57:11 -0400
Content-Disposition: inline
In-Reply-To: <20080721171141.GA13573@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 01:11:41AM +0800, Herbert Xu wrote:
> On Mon, Jul 21, 2008 at 10:08:21AM -0700, David Miller wrote:
> >
> > Can I at least get some commitment that someone will test
> > that this really is necessary before we add the CPU ID
> > hash option?
> 
> Sure, I'll be testing some related things on this front so I'll
> try to produce some results that compare these two cases.

I haven't had a chance to do the test yet but I've just had an
idea of how we can get the best of both worlds.

The problem with always directing traffic based on the CPU alone
is that processes move around and we don't want to introduce packet
reordering because to that.

The problem with hashing based on packet headers alone is that
it doesn't take CPU affinity into account at all so we may end
up with a situation where one thread out of a thread pool (e.g.,
a web server) has n sockets which are hashed to n different
queues.

So here's the idea, we determine the tx queue for a flow based
on the CPU on which we saw its first packet.  Once we have decided
on a queue we store that in a dst object (see below).  This
ensures that all subsequent packets of that flow ends up in
the same queue so there is no reordering.  It also avoids the
problem where traffic genreated by one CPU gets scattered across
queues.

Of course to make this work we need to restart the flow cache
project so that we have somewhere to store this txq assignment.

The good thing is that a flow cache would be of benefit for IPsec
users too and I hear that there is some interest in doing that
in the immediate future.  So perhaps we can combine efforts and
use it for txq assignment as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
