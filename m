From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 12:23:27 +0400
Message-ID: <20070813082326.GC30089@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <20070807205538.GB5245@kernel.dk> <20070808095448.GA3440@2ka.mipt.ru> <200708122236.24096.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708122236.24096.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 10:36:23PM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> (previous incomplete message sent accidentally)
> 
> On Wednesday 08 August 2007 02:54, Evgeniy Polyakov wrote:
> > On Tue, Aug 07, 2007 at 10:55:38PM +0200, Jens Axboe wrote:
> >
> > So, what did we decide? To bloat bio a bit (add a queue pointer) or
> > to use physical device limits? The latter requires to replace all
> > occurence of bio->bi_bdev = something_new with blk_set_bdev(bio,
> > somthing_new), where queue limits will be appropriately charged. So
> > far I'm testing second case, but I only changed DST for testing, can
> > change all other users if needed though.
> 
> Adding a queue pointer to struct bio and using physical device limits as 
> in your posted patch both suffer from the same problem: you release the 
> throttling on the previous queue when the bio moves to a new one, which 
> is a bug because memory consumption on the previous queue then becomes 
> unbounded, or limited only by the number of struct requests that can be 
> allocated.  In other words, it reverts to the same situation we have 
> now as soon as the IO stack has more than one queue.  (Just a shorter 
> version of my previous post.)

No. Since all requests for virtual device end up in physical devices,
which have limits, this mechanism works. Virtual device will essentially 
call either generic_make_request() for new physical device (and thus
will sleep is limit is over), or will process bios directly, but in that
case it will sleep in generic_make_request() for virutal device.

> 1) One throttle count per submitted bio is too crude a measure.  A bio 
> can carry as few as one page or as many as 256 pages.  If you take only 

It does not matter - we can count bytes, pages, bio vectors or whatever
we like, its just a matter of counter and can be changed without
problem.

> 2) Exposing the per-block device throttle limits via sysfs or similar is 
> really not a good long term solution for system administration.  
> Imagine our help text: "just keep trying smaller numbers until your 
> system deadlocks".  We really need to figure this out internally and 
> get it correct.  I can see putting in a temporary userspace interface 
> just for experimentation, to help determine what really is safe, and 
> what size the numbers should be to approach optimal throughput in a 
> fully loaded memory state.

Well, we already have number of such 'supposed-to-be-automatic'
variables exported to userspace, so this will not change a picture,
frankly I do not care if there will or will not be any sysfs exported
tunable, eventually we can remove it or do not create at all.

-- 
	Evgeniy Polyakov
