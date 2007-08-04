From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 18:19:16 -0700
Message-ID: <200708031819.17039.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708021408.24876.phillips@phunq.net> <20070803102629.GB10089@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070803102629.GB10089@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 03 August 2007 03:26, Evgeniy Polyakov wrote:
> On Thu, Aug 02, 2007 at 02:08:24PM -0700, I wrote:
> > I see bits that worry me, e.g.:
> >
> > +		req = mempool_alloc(st->w->req_pool, GFP_NOIO);
> >
> > which seems to be callable in response to a local request, just the
> > case where NBD deadlocks.  Your mempool strategy can work reliably
> > only if you can prove that the pool allocations of the maximum
> > number of requests you can have in flight do not exceed the size of
> > the pool.  In other words, if you ever take the pool's fallback
> > path to normal allocation, you risk deadlock.
>
> mempool should be allocated to be able to catch up with maximum
> in-flight requests, in my tests I was unable to force block layer to
> put more than 31 pages in sync, but in one bio. Each request is
> essentially dealyed bio processing, so this must handle maximum
> number of in-flight bios (if they do not cover multiple nodes, if
> they do, then each node requires own request).

It depends on the characteristics of the physical and virtual block 
devices involved.  Slow block devices can produce surprising effects.  
Ddsnap still qualifies as "slow" under certain circumstances (big 
linear write immediately following a new snapshot). Before we added 
throttling we would see as many as 800,000 bios in flight.  Nice to 
know the system can actually survive this... mostly.  But memory 
deadlock is a clear and present danger under those conditions and we 
did hit it (not to mention that read latency sucked beyond belief). 

Anyway, we added a simple counting semaphore to throttle the bio traffic 
to a reasonable number and behavior became much nicer, but most 
importantly, this satisfies one of the primary requirements for 
avoiding block device memory deadlock: a strictly bounded amount of bio 
traffic in flight.  In fact, we allow some bounded number of 
non-memalloc bios *plus* however much traffic the mm wants to throw at 
us in memalloc mode, on the assumption that the mm knows what it is 
doing and imposes its own bound of in flight bios per device.   This 
needs auditing obviously, but the mm either does that or is buggy.  In 
practice, with this throttling in place we never saw more than 2,000 in 
flight no matter how hard we hit it, which is about the number we were 
aiming at.  Since we draw our reserve from the main memalloc pool, we 
can easily handle 2,000 bios in flight, even under extreme conditions.

See:
    http://zumastor.googlecode.com/svn/trunk/ddsnap/kernel/dm-ddsnap.c
    down(&info->throttle_sem);

To be sure, I am not very proud of this throttling mechanism for various 
reasons, but the thing is, _any_ throttling mechanism no matter how 
sucky solves the deadlock problem.  Over time I want to move the 
throttling up into bio submission proper, or perhaps incorporate it in 
device mapper's queue function, not quite as high up the food chain.  
Only some stupid little logistical issues stopped me from doing it one 
of those ways right from the start.   I think Peter has also tried some 
things in this area.  Anyway, that part is not pressing because the 
throttling can be done in the virtual device itself as we do it, even 
if it is not very pretty there.  The point is: you have to throttle the 
bio traffic.  The alternative is to die a horrible death under 
conditions that may be rare, but _will_ hit somebody.

Regards,

Daniel
