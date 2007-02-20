From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 22:06:34 +0300
Message-ID: <20070220190634.GA12193@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201854.00092.dada1@cosmosbay.com> <20070220180027.GC26961@2ka.mipt.ru> <200702201955.15567.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35942 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965092AbXBTTIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:08:21 -0500
Content-Disposition: inline
In-Reply-To: <200702201955.15567.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 07:55:15PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Tuesday 20 February 2007 19:00, Evgeniy Polyakov wrote:
> > As you can see, jhash has problems in a really trivial case of 2^16,
> > which in local lan is a disaster. The only reason jenkins hash is good
> > for hashing purposes is that is it more complex than xor one, and thus
> > it is harder to find a collision law. That's all.
> > And it is two times slower.
> 
> I see no problems at all. An attacker can not exploit the fact that two (or 
> three) different values of sport will hit the same hash bucket.
> 
> A hash function may have collisions. This is *designed* like that.
> 
> The complexity of the hash function is a tradeoff. A perfect hash would be :
> - Perfect distribution
> - Hard (or even : impossible) to guess for an attacker.
> - No CPU cost.
> 
> There is no perfect hash function... given 96 bits in input.
> So what ? hashes are 'badly broken' ?
> Thats just not even funny Evgeniy.

Jenkins has _worse_ distribution than xor one.
_That_ is bad, not the fact that hash has collisions.

hash(val) = val >> 16;
is a hash too, and it has even worse distribution - so it is designed
even worse, so we do not use it.

> The 'two times slower' is a simplistic view, or maybe you have an alien CPU, 
> or a CPU from the past ?

It is core duo 3.7 ghz.
Timings are printed in the test I showed in the list.

> On my oprofile, rt_hash_code() uses 0.24% of cpu (about 50 x86_64 
> instructions)
> 
> Each time a cache miss is done because your bucket length is (X+1) instead of 
> (X), your CPU is stuck while it could have do 150 instructions. Next CPUS 
> will do 300 instructions per cache miss, maybe 1000 one day... yes, life is 
> hard.
> 
> I added to my 'simulator_plugged_on_real_server' the average cost calculation, 
> relative to number of cache line per lookup.
> 
> ehash_size=2^20
> xor hash :
> 386290 sockets, Avg lookup cost=3.2604 cache lines/lookup
> 393667 sockets, Avg lookup cost=3.30579 cache lines/lookup
> 400777 sockets, Avg lookup cost=3.3493 cache lines/lookup
> 404720 sockets, Avg lookup cost=3.36705 cache lines/lookup
> 406671 sockets, Avg lookup cost=3.37677 cache lines/lookup
> jenkin hash:
> 386290 sockets, Avg lookup cost=2.36763 cache lines/lookup
> 393667 sockets, Avg lookup cost=2.37533 cache lines/lookup
> 400777 sockets, Avg lookup cost=2.38211 cache lines/lookup
> 404720 sockets, Avg lookup cost=2.38582 cache lines/lookup
> 406671 sockets, Avg lookup cost=2.38679 cache lines/lookup
> 
> (you can see that when number of sockets increase, the xor hash becomes worst)
> 
> So the jenkin hash function CPU cost is balanced by the fact its distribution 
> is better. In the end you are faster.

Very strange test - it shows that jenkins distribution for your setup is
better than xor one, although for the true random data they are roughly
the same, and jenkins one has more instructions.

But _you_ have shown that with true random data of 2^16 ports jenkins
distribution is _worse_ than xor without any gain to buy.

-- 
	Evgeniy Polyakov
