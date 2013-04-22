From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Mon, 22 Apr 2013 19:49:12 +0200
Message-ID: <1366652952.26911.334.camel@localhost>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
	 <20130419124528.GF27889@order.stressinduktion.org>
	 <1366381742.26911.166.camel@localhost>
	 <20130419194424.GI27889@order.stressinduktion.org>
	 <1366621834.26911.271.camel@localhost>
	 <20130422145431.GA26838@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab3DVRtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 13:49:19 -0400
In-Reply-To: <20130422145431.GA26838@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 16:54 +0200, Hannes Frederic Sowa wrote:
> On Mon, Apr 22, 2013 at 11:10:34AM +0200, Jesper Dangaard Brouer wrote:
> > (To avoid pissing people off) I acknowledge that we should change the
> > hash size, as its ridiculously small with 64 entries.
> > 
> > But your mem limit assumption and hash depth limit assumptions are
> > broken, because the mem limit is per netns (network namespace).
> > Thus, starting more netns instances will break these assumptions.
> 
> Oh, I see. :/
> 
> At first I thought we should make the fragment hash per namespace too,
> to provide better isolation in case of lxc. But then each chrome tab
> would allocate its own fragment cache, too. Hmm... but people using
> namespaces have plenty much memory, don't they? We could also provide
> an inet_fragment namespace. ;)

I'm wondering if we could do the opposite, move the mem limit and LRU
list "out-of" the netns?
Either way, this would make the relationship of the mem limit and hash
size more sane.



> > The dangerous part of your change (commit 5a3da1fe) is that you keep the
> > existing frag queues (and don't allow new frag queues to be created).
> > The attackers fragments will never finish (timeout 30 sec), while valid
> > fragments will complete and "exit" the queue, thus the end result is
> > hash bucket is filled with attackers invalid/incomplete fragments.
> 
> I would not mind if your change gets accepted (I have not completyl
> reviewed it yet), but I have my doubts if it is an advantage to the
> current solution.
> 
> First off, I think an attacker can keep the fragment cache pretty much
> filled up with little cost. The current implementation has the grace
> period where no new fragments will be accepted after the DoS, this is
> solved by your patch. But the change makes it easier for an attacker to
> evict "valid" fragments from the cache in the first 30 seconds of the
> DoS, too.

The "grace period" is quite harmful (where no new fragments will be
accepted).  Just creating 3 netns (3x 4MB mem limit) we can make all
queues reach 128 entries, resulting in a "grace period" of 30 sec where
no frags are possible. (min frag size is 1108 bytes with my trafgen
script).


> I am not sure whether the current fragmentation handling or your solution
> does perform better in real world (or if it actually matters).
> 
> Nonetheless it does add a bit more complexity and a new sysctl which does
> expose something the kernel should know how to do better.

Well, actually I don't like exposing the max_hash_depth sysctl, it was a
wrong idea/move.

I like Eric's idea of resizing the hash based on the max thresh,
unfortunately this does not make sense when the max thresh is per netns
and the hash table is global.

I'm also thinking, it is really worth the complexity of having a depth
limit on this hash table?  Is it that important.  The mem limit should
at some point kick in and save the day anyhow (before, without per hash
bucket locking it might make sense).



> > Besides, after we have implemented per hash bucket locking (in my change
> > commit 19952cc4 "net: frag queue per hash bucket locking").
> > Then, I don't think it is a big problem that a single hash bucket is
> > being "attacked".
> 
> I don't know, I wouldn't say so. The contention point is now the per
> hash bucket lock but it should show the same symptoms as before.
> 
> In my opinion we should start resizing the hash table irrespective of
> the namespace limits (one needs CAP_NET_ADMIN to connect a netns to
> the outside world, I think) and try to move forward with Patch 3. This
> patch 2 would then only be a dependency and would introduce the eviction
> strategy you need for patch 3. But the focus should be on the removal of the
> lru cleanup. What do you think?

I agree, increasing the hash tables size makes sense, as its
ridiculously small with 64 entries.

Yes, removal of the (per netns) "global" LRU list should be the real
focus.  This was just a dependency for introducing the eviction strategy
I needed for patch 3.

But the eviction strategy in patch-3, is actually also "broken" because
the mem limit is per netns and we do eviction based on the netns shared
hash table... thinking of going back to my original idea of simply doing
LRU lists per CPU.

--Jesper
