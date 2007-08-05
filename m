From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Sun, 5 Aug 2007 19:08:24 +0400
Message-ID: <20070805150824.GB32132@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708031819.17039.phillips@phunq.net> <20070804163740.GB14175@2ka.mipt.ru> <200708050104.19596.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708050104.19596.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel.

On Sun, Aug 05, 2007 at 01:04:19AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> > we can wait in it for memory in mempool. Although that means we
> > already in trouble. 
> 
> Not at all.  This whole block writeout path needs to be written to run 
> efficiently even when normal system memory is completely gone.  All it 
> means when we wait on a mempool is that the block device queue is as 
> full as we are ever going to let it become, and that means the block 
> device is working as hard as it can (subject to a small caveat: for 
> some loads a device can work more efficiently if it can queue up larger 
> numbers of requests down at the physical elevators).

If we are sleeping in memory pool, then we already do not have memory to
complete previous requests, so we are in trouble. This can work for
devices which do not require additional allocations (like usual local
storage), but not for network connected ones.

> > I agree, any kind of high-boundary leveling must be implemented in
> > device itself, since block layer does not know what device is at the
> > end and what it will need to process given block request.
> 
> I did not say the throttling has to be implemented in the device, only 
> that we did it there because it was easiest to code that up and try it 
> out (it worked).  This throttling really wants to live at a higher 
> level, possibly submit_bio()...bio->endio().  Someone at OLS (James 
> Bottomley?) suggested it would be better done at the request queue 
> layer, but I do not immediately see why that should be.  I guess this 
> is going to come down to somebody throwing out a patch for interested 
> folks to poke at.  But this detail is a fine point.  The big point is 
> to have _some_ throttling mechanism in place on the block IO path, 
> always.

If not in device, then at least it should say to block layer about its
limits. What about new function to register queue which will get maximum
number of bios in flight and sleep in generic_make_request() when new
bio is going to be submitted and it is about to exceed the limit?

By default things will be like they are now, except additional
non-atomic increment and branch in generic_make_request() and decrement
and wake in bio_end_io()?

I can cook up such a patch if idea worth efforts.

-- 
	Evgeniy Polyakov
