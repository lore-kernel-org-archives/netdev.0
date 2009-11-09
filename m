From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/8] udp: add a counter into udp_hslot
Date: Mon, 9 Nov 2009 13:10:22 +0100
Message-ID: <20091109121022.GD26740@basil.fritz.box>
References: <4AF72741.5070405@gmail.com> <87fx8o56eq.fsf@basil.nowhere.org> <4AF80040.6060501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57854 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbZKIMKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 07:10:18 -0500
Content-Disposition: inline
In-Reply-To: <4AF80040.6060501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Do you really need an int? On 64bit it's free due to the alignment, 
> > but on 32bit x86 it's costly and you blow up the table considerably,
> > increasing cache misses.
> 
> Even a short (16 bits) might be too small for IXIACOM :)

True, but see below.


> 
> On 32bit x86, size of hash table is 512 slots max.
> (one slot per 2MB of LOWMEM, rounded to power of two)
> 
> You are speaking of <= 4096 bytes overhead :)

Well it's cache line overhead too. 32bit systems have often
small caches (i.e. Atom)

> 
> >  
> > Again it would be nicer if that was a separate smaller table together
> > with the spinlock.
> 
> Nice for space, not nice for fast path, because this means additional
> cache miss to get the spinlock (multicast rx still needs to take spinlock),
> and some guys want really fast (low latency) multicast rx.

When the spinlock use is mostly local it should be in cache
(that's the nice thing about small tables, they don't drop out of cache)

> 
> > 
> > In theory could also put a short counter into the low level alignment
> > bits of the pointer and perhaps convert the spinlock to a bitlock?
> > Then all could collapse into a single pointer.
> > 
> 
> Not enough bits in low level alignment unfortunatly. We only could give a
> hint (one bit is enough) of possibly long chain, but not allowing precise 
> choice of shortest chain.

Do we really need a precise answer here? I would assume an approximate
answer would be good enough using a saturating counter. 
e.g. if both have >N  just round robin.

Ok it would be tricky to decrement that again on unbind, but I assume just 
continuing to RR later wouldn't be too bad.

The question is just if there are enough bits even for that.

> Once multicast is converted to RCU, then we wont need one spinlock per slot
> (it wont be used in fast path, only at bind()/close() time)
> and yes, we can use a separate small array to contain hashed spinlocks,
> or even a single spinlock for CONFIG_BASE_SMALL :)

Or a bit spinlock in the bucket low pointer bits.

With that (and the saturating counter) even the 64bit table could be shortened to half.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
