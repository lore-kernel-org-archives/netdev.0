From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Thu, 8 Mar 2007 07:26:22 +0100
Message-ID: <20070308062622.GB28263@wotan.suse.de>
References: <20070305.202632.74752497.davem@davemloft.net> <17901.27628.548105.353342@robur.slu.se> <20070306.142055.14973231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	dada1@cosmosbay.com, robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50345 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932396AbXCHG0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 01:26:51 -0500
Content-Disposition: inline
In-Reply-To: <20070306.142055.14973231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 02:20:55PM -0800, David Miller wrote:
> From: Robert Olsson <Robert.Olsson@data.slu.se>
> Date: Tue, 6 Mar 2007 14:26:04 +0100
> 
> > David Miller writes:
> >  
> >  > Actually, more accurately, the conflict exists in how this GC
> >  > logic is implemented.  The core issue is that hash table size
> >  > guides the GC processing, and hash table growth therefore
> >  > modifies those GC goals.  So with the patch below we'll just
> >  > keep growing the hash table instead of giving GC some time to
> >  > try to keep the working set in equilibrium before doing the
> >  > hash grow.
> >  
> >  AFIK the equilibrium is resizing function as well but using fixed 
> >  hash table. So can we do without equilibrium resizing if tables 
> >  are dynamic?  I think so....
> > 
> >  With the hash data structure we could monitor the average chain 
> >  length or just size and resize hash after that.
> 
> I'm not so sure, it may be a mistake to eliminate the equilibrium
> logic.  One error I think it does have is the usage of chain length.
> 
> Even a nearly perfect hash has small lumps in distribution, and we
> should not penalize entries which fall into these lumps.
> 
> Let us call T the threshold at which we would grow the routing hash
> table.  As we approach T we start to GC.  Let's assume hash table
> has shift = 2. and T would (with T=N+(N>>1) algorithm) therefore be
> 6.
> 
> TABLE:	[0]	DST1, DST2
> 	[1]	DST3, DST4, DST5
> 
> DST6 arrives, what should we do?
> 
> If we just accept it and don't GC some existing entries, we
> will grow the hash table.  This is the wrong thing to do if
> our true working set is smaller than 6 entries and thus some
> of the existing entries are unlikely to be reused and thus
> could be purged to keep us from hitting T.
> 
> If they are all active, growing is the right thing to do.
> 
> This is the crux of the whole routing cache problem.

I guess this is similar to our problems with bdev and filesystem
caches as well.

What we do in that case (as you would know), is to let the caches
expand to the size of memory, and the problem just becomes balancing
their relative importance. We just try to go with a reasonable default,
and provide a knob or two for fine tuning.


> I am of the opinion that LRU, for routes not attached to sockets, is
> probably the best thing to do here.
> 
> Furthermore at high packet rates, the current rt_may_expire() logic
> probably is not very effective since it's granularity is limited to
> jiffies.  We can quite easily create 100,000 or more entries per
> jiffie when HZ=100 during rDOS, for example.  So perhaps some global
> LRU algorithm using ktime is more appropriate.
> 
> Global LRU is not easy without touching a lot of memory.  But I'm
> sure some clever trick can be discovered by someone :)

Well we do a pseudo LRU in most vm/vfs caches, where we just set a
bit if it has been touched since last checked. Add another "working
set" list to promote popular routes into, and you have something
like our pagecache active/inactive reclaim.

I don't know if that really applies here, but it might if you decide
to try hooking this cache into the "slab shrinker" thingy...
