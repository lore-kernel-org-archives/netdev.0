From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 16:14:49 +0100
Message-ID: <200702191614.49666.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <200702191514.02937.dada1@cosmosbay.com> <20070219142504.GA5626@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:56332 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932327AbXBSPO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 10:14:59 -0500
In-Reply-To: <20070219142504.GA5626@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 February 2007 15:25, Evgeniy Polyakov wrote:
> On Mon, Feb 19, 2007 at 03:14:02PM +0100, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > > Forget about cache misses and cache lines - we have a hash table, only
> > > part of which is used (part for time-wait sockets, part for established
> > > ones).
> >
> > No you didnt not read my mail. Current ehash is not as decribed by you.
>
> I did.
> And I also said that my tests do not have timewait sockets at all - I
> removed sk_for_each and so on, which should effectively increase lookup
> time twice on busy system with lots of created/removed sockets per
> timeframe (that is theory from my side already).
> Anyway, I ran the same test with increased table too.
>
> > > Anyway, even with 2^20 (i.e. when the whole table is only used for
> > > established sockets) search time is about 360-370 nsec on 3.7 GHz Core
> > > Duo (only one CPU is used) with 2 GB of ram.
> >
> > Your tests are user land, so unfortunatly are biased...
> >
> > (Unless you use hugetlb data ?)
>
> No I do not. But the same can be applied to trie test - it is also
> performed in userspace and thus suffers from possible swapping/cache
> flushing and so on.
>
> And I doubt moving test into kernel will suddenly end up with 10 times
> increased rates.

At least some architectures pay a high price using vmalloc() instead of 
kmalloc(), and TLB misses means something for them. Not everybody has the 
latest Intel cpu. Normally, ehash table is using huge pages.

>
> Anyway, trie test (broken implementation) is two times slower than hash
> table (resized already), and it does not include locking isses of the
> hash table access and further scalability issues.
>

You mix apples and oranges. We already know locking has nothing to do with 
hashing or trie-ing. We *can* put RCU on top of the existing ehash. We also 
can add hash resizing if we really care.


> I think I need to fix my trie implementation to fully show its
> potential, but original question was why tree/trie based implementation
> is not considered at all although it promises better performance and
> scalability.

Because you mix performance and scalability. Thats not exactly the same.
Sometime, high performance means *suboptimal* scalability.

Because O(1) is different of O(log(N)) ?
if N = 2^20, it certainly makes a difference.
Yes, 1% of chains might have a length > 10, but yet 99% of the lookups are 
touching less than 4 cache lines.
With a binary tree, log(2^20) is 20. or maybe not ? If you tell me it's 4, I 
will be very pleased.

