From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Fri, 20 Mar 2015 10:27:01 +0000
Message-ID: <20150320102701.GA28736@acer.localdomain>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
 <20150316111345.GA22070@acer.localdomain>
 <20150320085509.GA16748@gondor.apana.org.au>
 <20150320092216.GE21258@acer.localdomain>
 <20150320092703.GA17081@gondor.apana.org.au>
 <20150320095908.GG21258@acer.localdomain>
 <20150320101603.GA17662@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35373 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbbCTK1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:27:06 -0400
Content-Disposition: inline
In-Reply-To: <20150320101603.GA17662@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.03, Herbert Xu wrote:
> On Fri, Mar 20, 2015 at 09:59:09AM +0000, Patrick McHardy wrote:
> >
> > Regarding the chain length as trigger - I'm sorry, but this doesn't work
> > for us. I don't see why you would have to look at chain length. That
> > implies that you don't trust your hash function - why not fix that
> > instead?
> 
> Any hash function can be attacked.  That's why we need to be able
> to rehash it.  And the best way to decide when to rehash is based
> on chain length (otherwise you'd waste time rehashing periodically
> like we used to do).  With name spaces these days anyone could be
> an adversary.

We already had this discussion. I strongly do not believe this is
the right way to fix namespace problems. There are millions of ways
of creating CPU intensive workloads. You need to be able to put
bounds on the entire namespace. Fixing individual spots will not
solve that problem.

> Besides, putting multiple objects with the same key into a hash
> table defeats the whole point of hashing.

They exist only for (very) short periods of time. Its simply not a
problem in our case. We could even put hard bounds on them, meaning
an element will at most exist twice during that period.

> > > Of course many hash table users need to be able to keep multiple
> > > objects under the same key.  My suggestion would be to allocate
> > > your own linked list and have the linked list be the object that
> > > is inserted into the hash table.
> > 
> > That would require a huge amount of extra memory per element and having
> > millions of them is not unrealistic for our use case.
> 
> You should be able to do it with just 8 extra bytes per unique
> hash table key.

That's something 25% more memory usage for us in common cases. We try
very hard to keep the active memory size small. I don't want to waste
that amount of memory just for the very short periods while transactions
are unconfirmed.
