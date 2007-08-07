From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Distributed storage.
Date: Tue, 7 Aug 2007 22:55:38 +0200
Message-ID: <20070807205538.GB5245@kernel.dk>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708051423.45484.phillips@phunq.net> <20070807120523.GX5245@kernel.dk> <200708071124.56859.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708071124.56859.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07 2007, Daniel Phillips wrote:
> On Tuesday 07 August 2007 05:05, Jens Axboe wrote:
> > On Sun, Aug 05 2007, Daniel Phillips wrote:
> > > A simple way to solve the stable accounting field issue is to add a
> > > new pointer to struct bio that is owned by the top level submitter
> > > (normally generic_make_request but not always) and is not affected
> > > by any recursive resubmission.  Then getting rid of that field
> > > later becomes somebody's summer project, which is not all that
> > > urgent because struct bio is already bloated up with a bunch of
> > > dubious fields and is a transient structure anyway.
> >
> > Thanks for your insights. Care to detail what bloat and dubious
> > fields struct bio has?
> 
> First obvious one I see is bi_rw separate from bi_flags.  Front_size and 
> back_size smell dubious.  Is max_vecs really necessary?  You could 

I don't like structure bloat, but I do like nice design. Overloading is
a necessary evil sometimes, though. Even today, there isn't enough room
to hold bi_rw and bi_flags in the same variable on 32-bit archs, so that
concern can be scratched. If you read bio.h, that much is obvious.

If you check up on the iommu virtual merging, you'll understand the
front and back size members. They may smell dubious to you, but please
take the time to understand why it looks the way it does.

> reasonably assume bi_vcnt rounded up to a power of two and bury the 
> details of making that work behind wrapper functions to change the 
> number of bvecs, if anybody actually needs that.  Bi_endio and 

Changing the number of bvecs is integral to how bio buildup current
works.

> bi_destructor could be combined.  I don't see a lot of users of bi_idx, 

bi_idx is integral to partial io completions.

> that looks like a soft target.  See what happened to struct page when a 
> couple of folks got serious about attacking it, some really deep hacks 
> were done to pare off a few bytes here and there.  But struct bio as a 
> space waster is not nearly in the same ballpark.

So show some concrete patches and examples, hand waving and assumptions
is just a waste of everyones time.

> It would be interesting to see if bi_bdev could be made read only.  
> Generally, each stage in the block device stack knows what the next 
> stage is going to be, so why do we have to write that in the bio?  For 
> error reporting from interrupt context?  Anyway, if Evgeniy wants to do 
> the patch, I will happily unload the task of convincing you that random 
> fields are/are not needed in struct bio :-)

It's a trade off, otherwise you'd have to pass the block device around a
lot. And it's, again, a design issue. A bio contains destination
information, that means device/offset/size information. I'm all for
shaving structure bytes where it matters, but not for the sake of
sacrificing code stability or design. I consider struct bio quite lean
and have worked hard to keep it that way. In fact, iirc, the only
addition to struct bio since 2001 is the iommu front/back size members.
And I resisted those for quite a while.

-- 
Jens Axboe

