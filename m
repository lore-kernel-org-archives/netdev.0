From: jamal <hadi@cyberus.ca>
Subject: Re: Get rid of rt_check_expire and rt_garbage_collect
Date: 02 Apr 2005 16:05:55 -0500
Message-ID: <1112475955.1088.294.camel@jzny.localdomain>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	 <424E641A.1020609@cosmosbay.com>
	 <20050402112304.GA11321@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050402112304.GA11321@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-02 at 06:23, Herbert Xu wrote:
> On Sat, Apr 02, 2005 at 11:21:30AM +0200, Eric Dumazet wrote:
> > 
> > Well, I began my work because of the overflow bug in rt_check_expire()...
> > Then I realize this function could not work as expected. On a loaded 
> > machine, one timer tick is 1 ms.
> > During this time, number of chains that are scanned is ridiculous.
> > With the standard timer of 60 second, fact is rt_check_expire() is useless.
> 
> I see.  What we've got here is a scalability problem with respect
> to the number of hash buckets.  As the number of buckets increases,
> the amount of work the timer GC has to perform inreases proportionally.
> 

Its classical incremental garbage collection algorithm thats being used
i.e something along whats typically refered to as mark-and-sweep.
Could the main issue be not the amount of routes in the cache but
rather the locking when number of CPUs go up?
Incrementing the timer frequency would certainly help but maybe have
adverse effects if the frequency is too high because of the across
system locking IMO.

> Since the timer GC parameters are fixed, this will eventually break.
> 
> Rather than changing the timer GC so that it runs more often to keep
> up with the large routing cache, we should get out of this by reducing
> the amount of work we have to do.
> 

Refer to my hint above: perhaps per CPU caches?

> Imagine an ideal balanced hash table with 2.6 million entries.  That
> is, all incoming/outgoing packets belong to flows that are already in
> the hash table.  Imagine also that there is no PMTU/link failure taking
> place so all entries are valid forever.
> 
>
> In this state there is absolutely no need to execute the timer GC.
> 

Yeah, but memory is finite friend. True, if you can imagine infinite
memory we would not need gc ;->

> Let's remove one of those assumptions and allow there to be entries

> which need to expire after a set period.

> Instead of having the timer GC clean them up, we can move the expire
> check to the place where the entries are used.  That is, we make
> ip_route_input/ip_route_output/ipv4_dst_check check whether the
> entry has expired.
> 

If you can show lock grabbing is the main contentious issue; i believe
it is as CPUs go up. Then this is a valuable idea since you are already
grabbing the locks anyways.

> On the face of it we're doing more work since every routing cache
> hit will need to check the validity of the dst.  However, because
> it's a single subtraction it is actually pretty cheap.  There is
> also no additional cache miss compared to doing it in the timer
> GC since we have to read the dst anyway.
> 

In the case of slower machine, the compute is also an issue. 
To be honest i feel like handwaving - experimenting and collecting
profiles would help nail it.

> Let's go one step further and make the routing cache come to life.
> Now there are new entries coming in and we need to remove old ones
> in order to make room for them.
> 
> That task is currently carried out by the timer GC in rt_check_expire
> and on demand by rt_garbage_collect.  Either way we have to walk the
> entire routing cache looking for entries to get rid of.
> 

we dont really do the whole route cache everytime - I am sure you know
that.

> This is quite expensive when the routing cache is large.  However,
> there is a better way.
> 
> The reason we keep a cap on the routing cache (for a given hash size)
> is so that individual chains do not degenerate into long linked lists.
> 
> In other words, we don't really care about how many entries there are
> in the routing cache.  But we do care about how long each hash chain
> is.
> 
> So instead of walking the entire routing cache to keep the number of
> entries down, what we should do is keep each hash chain as short as
> possible.
> 

Thats certainly one solution .. reading on how you achive this ..

> Assuming that the hash function is good, this should achieve the
> same end result.
> 
> Here is how it can be done: Every time a routing entry is inserted into
> a hash chain, we perform GC on that chain unconditionally.
> 

May not be a good idea to do it unconditionally - in particular on SMP
where another CPU maybe spinning waiting for you to let go of bucket
lock. In particular if a burst of packets accessing the same bucket show
up on different processors, this would be aggravated.
You may wanna kick in this algorithm only when things start going past a
certain threshold.

> It might seem that we're doing more work again.  However, as before
> because we're traversing the chain anyway, it is very cheap to perform
> the GC operations which mainly involve the checks in rt_may_expire.
> 
> OK that's enough thinking and it's time to write some code to see
> whether this is all bullshit :)
> 

I think there are some good ideas in there; the bottleneck could be
perceived as one of either the locks are too expensive (clearly so in
SMP as number of CPUs go up) or the compute is taking too long (clearly
so in slower systems - but a general fact of life as well).
For the first issue, amortizing the lock grabbing via compute as you
suggest maybe of value or make per cpu caches.

cheers,
jamal
