From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Get rid of rt_check_expire and rt_garbage_collect
Date: Sun, 3 Apr 2005 17:38:40 +1000
Message-ID: <20050403073840.GA8105@gondor.apana.org.au>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <20050402112304.GA11321@gondor.apana.org.au> <1112475955.1088.294.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112475955.1088.294.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 02, 2005 at 04:05:55PM -0500, jamal wrote:
>
> > In this state there is absolutely no need to execute the timer GC.
> 
> Yeah, but memory is finite friend. True, if you can imagine infinite
> memory we would not need gc ;->

True.  However running the GC when you can't free most of the entries
is a waste of time.

On a busy system where the routing cache is near capacity and new
entries are coming in all the time, we should arrange it so that the
old entries are expired when entries are inserted.

Assuming the hash function is good, then as long as there is
a steady stream of entries coming in, the old entries will be
expired automatically.

Of course, we should not leave the systems that have experienced
a burst of flows at a disadvantage.  Indeed there is a rather
simple way of doing GC for them without having to do work that's
proportional to the number of hash chains in the routing cache.

The key is that the GC is only useful when the routing cache contains
enough entries that can be freed.  Let's say that if we can free more
than 1/3 of the entries then the GC should be run.  Of course you
can define this to be whatever you want.

So now the problem is to quickly determine whether there are enough
entries in the cache that can be freed.  What we can do is take a
leaf out of the politicians' book :)

We take a poll on a small sample of the routing cache.  That is,
we run the GC on a fixed number of chains, e.g., 256 chains.  After
that we tally the total number of entries and the number of entries
freed.

Since the hash function should be spreading entries throughout the
chains evenly, the ratio here can be extrapolated out to the entire
cache.

Therefore once the ratio exceeds the defined threshold, we perform
GC over the entire cache, preferably in a kernel thread.

If not then we'll simply let the GC roam along at the constant pace
of 256 chains.

The advantage of this is that the GC will free entries in the entire
table as soon as that becomes possible without having to do work
proportional to the number of chains in each GC interval.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
