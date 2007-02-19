From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 16:56:09 +0300
Message-ID: <20070219135608.GA10268@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <45D8B54A.70903@cosmosbay.com> <20070219114117.GA22622@2ka.mipt.ru> <200702191438.14010.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51050 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932256AbXBSOAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 09:00:15 -0500
Content-Disposition: inline
In-Reply-To: <200702191438.14010.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 02:38:13PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Monday 19 February 2007 12:41, Evgeniy Polyakov wrote:
> 
> > > 1 microsecond ? Are you kidding ? We want no more than 50 ns.
> >
> > Theory again.
> 
> 
> Theory is nice, but I personally prefer oprofile :)
> I base my comments on real facts.
> We *want* 50 ns tcp lookups (2 cache line misses, one with reader intent, one 
> for exclusive access intent)

I said that your words are theory in previous mails :)

Current code works 10 times worse than you expect.

> > Existing table does not scale that good - I created (1<<20)/2 (to cover
> > only established part) entries table and filled it with 1 million of random
> > entries -search time is about half of microsecod.
> 
> I use exactly 1^20 slots, not 1^19 (see commit  
> dbca9b2750e3b1ee6f56a616160ccfc12e8b161f , where I changed layout of ehash 
> table so that two chains (established/timewait) are on the same cache line. 
> every cache miss *counts*) 

Forget about cache misses and cache lines - we have a hash table, only
part of which is used (part for time-wait sockets, part for established
ones).

Anyway, even with 2^20 (i.e. when the whole table is only used for
established sockets) search time is about 360-370 nsec on 3.7 GHz Core
Duo (only one CPU is used) with 2 GB of ram.

> http://www.mail-archive.com/netdev@vger.kernel.org/msg31096.html
> 
> (Of course, you may have to change MAX_ORDER to 14 or else the hash table hits 
> the MAX_ORDER limit)
> 
> Search time under 100 ns, for real trafic (kind of random... but not quite)
> Most of this time is taken by the rwlock, so expect 50 ns once RCU is finally 
> in...

My experiment shows almost 400 nsecs without _any_ locks - they are
removed completely - it is pure hash selection/list traverse time.

> In your tests, please make sure a User process is actually doing real work on 
> each CPU, ie evicting cpu caches every ms...
> 
> The rule is : On a normal machine, cpu caches contain UserMode data, not 
> kernel data. (as a typical machine spends 15% of its cpu time in kernel land, 
> and 85% in User land). You can assume kernel text is in cache, but even this 
> assumption may be wrong.

In my tests _only_ hash tables are in memory (well with some bits of
other stuff) - I use exactly the same approach for both trie and hash
table tests - table/trie is allocated, filled and lookup of random
values is performed in a loop. It is done in userspace - I just moved
list.h inet_hashtable.h and other needed files into separate project and
compiled them (with removed locks, atomic operations and other pure
kernel stuff). So actual time even more for hash table - at least it
requires locks while trie implementation works with RCU.

-- 
	Evgeniy Polyakov
