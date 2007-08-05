From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Sun, 5 Aug 2007 01:04:19 -0700
Message-ID: <200708050104.19596.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708031819.17039.phillips@phunq.net> <20070804163740.GB14175@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070804163740.GB14175@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 04 August 2007 09:37, Evgeniy Polyakov wrote:
> On Fri, Aug 03, 2007 at 06:19:16PM -0700, I wrote:
> > To be sure, I am not very proud of this throttling mechanism for
> > various reasons, but the thing is, _any_ throttling mechanism no
> > matter how sucky solves the deadlock problem.  Over time I want to
> > move the
>
> make_request_fn is always called in process context,

Yes, as is submit_bio which calls it.  The decision re where it is best 
to throttle, in submit_bio or in make_request_fn, has more to do with 
system factoring, that is, is throttling something that _every_ block 
device should have (yes I think) or is it a delicate, optional thing 
that needs a tweakable algorithm per block device type (no I think).

The big worry I had was that by blocking on congestion in the 
submit_bio/make_request_fn I might stuff up system-wide mm writeout.  
But a while ago that part of the mm was tweaked (by Andrew if I recall 
correctly) to use a pool of writeout threads and understand the concept 
of one of them blocking on some block device, and not submit more 
writeout to the same block device until the first thread finishes its 
submission.  Meanwhile, other mm writeout threads carry on with other 
block devices.

> we can wait in it for memory in mempool. Although that means we
> already in trouble. 

Not at all.  This whole block writeout path needs to be written to run 
efficiently even when normal system memory is completely gone.  All it 
means when we wait on a mempool is that the block device queue is as 
full as we are ever going to let it become, and that means the block 
device is working as hard as it can (subject to a small caveat: for 
some loads a device can work more efficiently if it can queue up larger 
numbers of requests down at the physical elevators).

By the way, ddsnap waits on a counting semaphore, not a mempool.  That 
is because we draw our reserve memory from the global memalloc reserve, 
not from a mempool.  And that is not only because it takes less code to 
do so, but mainly because global pools as opposed to lots of little 
special purpose pools seem like a good idea to me.  Though I will admit 
that with our current scheme we need to allow for the total of the 
maximum reserve requirements for all memalloc users in the memalloc 
pool, so it does not actually save any memory vs dedicated pools.  We 
could improve that if we wanted to, by having hard and soft reserve 
requirements: the global reserve actually only needs to be as big as 
the total of the hard requirements.  With this idea, if by some unlucky 
accident every single pool user got itself maxed out at the same time, 
we would still not exceed our share of the global reserve.  
Under "normal" low memory situations, a block device would typically be 
free to grab reserve memory up to its soft limit, allowing it to 
optimize over a wider range of queued transactions.   My little idea 
here is: allocating specific pages to a pool is kind of dumb, all we 
really want to do is account precisely for the number of pages we are 
allowed to draw from the global reserve.

OK, I kind of digressed, but this all counts as explaining the details 
of what Peter and I have been up to for the last year (longer for me).  
At this point, we don't need to do the reserve accounting in the most 
absolutely perfect way possible, we just need to get something minimal 
in place to fix the current deadlock problems, then we can iteratively 
improve it.

> I agree, any kind of high-boundary leveling must be implemented in
> device itself, since block layer does not know what device is at the
> end and what it will need to process given block request.

I did not say the throttling has to be implemented in the device, only 
that we did it there because it was easiest to code that up and try it 
out (it worked).  This throttling really wants to live at a higher 
level, possibly submit_bio()...bio->endio().  Someone at OLS (James 
Bottomley?) suggested it would be better done at the request queue 
layer, but I do not immediately see why that should be.  I guess this 
is going to come down to somebody throwing out a patch for interested 
folks to poke at.  But this detail is a fine point.  The big point is 
to have _some_ throttling mechanism in place on the block IO path, 
always.

Device mapper in particular does not have any throttling itself: calling 
submit_bio on a device mapper device directly calls the device mapper 
bio dispatcher.  Default initialized block device queue do provide a 
crude form of throttling based on limiting the number of requests.  
This is insufficiently precise to do a good job in the long run, but it 
works for now because the current gaggle of low level block drivers do 
not have a lot of resource requirements and tend to behave fairly 
predictably (except for some irritating issues re very slow devices 
working in parallel with very fast devices, but... worry about that 
later).  Network block drivers - for example your driver - do have 
nontrivial resource requirements and they do not, as far as I can see, 
have any form of throttling on the upstream side.  So unless you can 
demonstrate I'm wrong (I would be more than happy about that) then we 
are going to need to add some.

Anyway, I digressed again.  _Every_ layer in a block IO stack needs to 
have a reserve, if it consumes memory.  So we can't escape the question 
of how big to make those reserves by trying to push it all down to the 
lowest level, hoping that the low level device knows more about how 
many requests it will have in flight.  For the time being, we will just 
plug in some seat of the pants numbers in classic Linux fashion and 
that will serve us until somebody gets around to inventing the one true 
path discovery mechanism that can sniff around in the block IO stack 
and figure out the optimal amount of system resources to reserve at 
each level, which ought to be worth at least a master's thesis for 
somebody.

Regards,

Daniel
