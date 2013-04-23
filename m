From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list depth
Date: Tue, 23 Apr 2013 02:20:22 +0200
Message-ID: <20130423002022.GA28991@order.stressinduktion.org>
References: <20130418213637.14296.43143.stgit@dragon> <20130418213732.14296.36026.stgit@dragon> <1366366287.3205.98.camel@edumazet-glaptop> <1366373950.26911.134.camel@localhost> <20130419124528.GF27889@order.stressinduktion.org> <1366381742.26911.166.camel@localhost> <20130419194424.GI27889@order.stressinduktion.org> <1366621834.26911.271.camel@localhost> <20130422145431.GA26838@order.stressinduktion.org> <1366652952.26911.334.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57564 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab3DWAUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 20:20:24 -0400
Content-Disposition: inline
In-Reply-To: <1366652952.26911.334.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 06:30:17PM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 2013-04-22 at 16:54 +0200, Hannes Frederic Sowa wrote:
> > On Mon, Apr 22, 2013 at 11:10:34AM +0200, Jesper Dangaard Brouer wrote:
> [...]
> > > Besides, after we have implemented per hash bucket locking (in my change
> > > commit 19952cc4 "net: frag queue per hash bucket locking").
> > > Then, I don't think it is a big problem that a single hash bucket is
> > > being "attacked".
> > 
> > I don't know, I wouldn't say so. The contention point is now the per
> > hash bucket lock but it should show the same symptoms as before.
> 
> No, the contention point is the LRU list lock, not the hash bucket lock.
> If you perf record/profile the code, you can easily miss that its the
> LRU lock, because its inlined.  Try to rerun your tests with noinline
> e.g.:

It depends on the test. Last time I checked with my ipv6 torture test I
had most hits in the inet_frag_find loop (I looked at it after your per
bucket locks landed in net-next). I think your test setup could provide
more meaningful numbers. If you fill up the whole fragment cache it is
plausible that the contention will shift towards the lru lock.

On Mon, Apr 22, 2013 at 07:49:12PM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 2013-04-22 at 16:54 +0200, Hannes Frederic Sowa wrote:
> > At first I thought we should make the fragment hash per namespace too,
> > to provide better isolation in case of lxc. But then each chrome tab
> > would allocate its own fragment cache, too. Hmm... but people using
> > namespaces have plenty much memory, don't they? We could also provide
> > an inet_fragment namespace. ;)
> 
> I'm wondering if we could do the opposite, move the mem limit and LRU
> list "out-of" the netns?
> Either way, this would make the relationship of the mem limit and hash
> size more sane.

It seems to be the only sane way currently. If we resize on cloning/changing
per-ns parameters we would also have to resize the frag hash on every google
chrome tab creation/destruction.

Perhaps we sould think about adding lazy allocation/resizing of the
fragment cache per-ns (or we do the resize on every rebuild timeout).

> > > The dangerous part of your change (commit 5a3da1fe) is that you keep the
> > > existing frag queues (and don't allow new frag queues to be created).
> > > The attackers fragments will never finish (timeout 30 sec), while valid
> > > fragments will complete and "exit" the queue, thus the end result is
> > > hash bucket is filled with attackers invalid/incomplete fragments.
> > 
> > I would not mind if your change gets accepted (I have not completyl
> > reviewed it yet), but I have my doubts if it is an advantage to the
> > current solution.
> > 
> > First off, I think an attacker can keep the fragment cache pretty much
> > filled up with little cost. The current implementation has the grace
> > period where no new fragments will be accepted after the DoS, this is
> > solved by your patch. But the change makes it easier for an attacker to
> > evict "valid" fragments from the cache in the first 30 seconds of the
> > DoS, too.
> 
> The "grace period" is quite harmful (where no new fragments will be
> accepted).  Just creating 3 netns (3x 4MB mem limit) we can make all
> queues reach 128 entries, resulting in a "grace period" of 30 sec where
> no frags are possible. (min frag size is 1108 bytes with my trafgen
> script).

I see your point. But some other fragments would be in the queue perhaps
going to be reassembled correctly which would otherwise be evicted. So
I really don't know what is the better behavior here.

But this would be changed as a side-effect of this whole patch set. ;)

> I'm also thinking, it is really worth the complexity of having a depth
> limit on this hash table?  Is it that important.  The mem limit should
> at some point kick in and save the day anyhow (before, without per hash
> bucket locking it might make sense).

Depends on how we proceed with the ipv6 fragment hashing. If we go back to the
3 rounds of jhash for each fragment this would be possible.

> Yes, removal of the (per netns) "global" LRU list should be the real
> focus.  This was just a dependency for introducing the eviction strategy
> I needed for patch 3.
> 
> But the eviction strategy in patch-3, is actually also "broken" because
> the mem limit is per netns and we do eviction based on the netns shared
> hash table... thinking of going back to my original idea of simply doing
> LRU lists per CPU.

That depends on how we proceed with the memory limits. If we don't solve this
now we will have to deal with this again if we think about how to calculate a
decent hash size.

Greetings,

  Hannes
