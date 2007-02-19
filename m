From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 14:41:18 +0300
Message-ID: <20070219114117.GA22622@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain> <20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com> <20070218191009.GA28216@2ka.mipt.ru> <45D8B54A.70903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@linux.intel.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43368 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932145AbXBSLrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 06:47:42 -0500
Content-Disposition: inline
In-Reply-To: <45D8B54A.70903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 18, 2007 at 09:21:30PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> Evgeniy Polyakov a e'crit :
> >On Sun, Feb 18, 2007 at 07:46:22PM +0100, Eric Dumazet 
> >(dada1@cosmosbay.com) wrote:
> >>>Why anyone do not want to use trie - for socket-like loads it has
> >>>exactly constant search/insert/delete time and scales as hell.
> >>>
> >>Because we want to be *very* fast. You cannot beat hash table.
> >>
> >>Say you have 1.000.000 tcp connections, with 50.000 incoming packets per 
> >>second to *random* streams...
> >
> >What is really good in trie, that you may have upto 2^32 connections
> >without _any_ difference in lookup performance of random streams.
> 
> So are you speaking of one memory cache miss per lookup ?
> If not, you loose.

With trie big part of it _does_ live in cache compared to hash table
where similar addresses ends up in a completely different hash entries.

> >>With a 2^20 hashtable, a lookup uses one cache line (the hash head 
> >>pointer) plus one cache line to get the socket (you need it to access its 
> >>refcounter)
> >>
> >>Several attempts were done in the past to add RCU to ehash table (last 
> >>done by Benjamin LaHaise last March). I believe this was delayed a bit, 
> >>because David would like to be able to resize the hash table...
> >
> >This is a theory.
> 
> Not theory, but actual practice, on a real machine.
> 
> # cat /proc/net/sockstat
> sockets: used 918944
> TCP: inuse 925413 orphan 7401 tw 4906 alloc 926292 mem 304759
> UDP: inuse 9
> RAW: inuse 0
> FRAG: inuse 9 memory 18360

Theory is a speculation about performance.

Highly cache usage optimized bubble sorting still much worse than 
cache usage non-optimized binary tree.
 
> >Practice includes cost for hashing, locking, and list traversal
> >(each pointer is in own cache line btw, which must be fetched) and plus
> >the same for time wait sockets (if we are unlucky).
> >
> >No need to talk about price of cache miss when there might be more
> >serious problems - for example length of the linked list to traverse each 
> >time new packet is received.
> >
> >For example lookup time in trie with 1.6 millions random 3-dimensional
> >32bit (saddr/daddr/ports) entries is about 1 microsecond on amd athlon64 
> >3500 cpu (test was ran in userspace emulator though).
> 
> 1 microsecond ? Are you kidding ? We want no more than 50 ns.

Theory again.

Existing table does not scale that good - I created (1<<20)/2 (to cover only
established part) entries table and filled it with 1 million of random entries 
-search time is about half of microsecod.

Wanna see a code? I copied Linux hash table magic into userspace and run
the same inet_hash() and inet_lookup() in a loop. Result above.

Trie is still 2 times worse, but I've just found a bug in my implementation.

-- 
	Evgeniy Polyakov
