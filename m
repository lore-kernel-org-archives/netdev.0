From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 01:59:22 -0700
Message-ID: <200708130159.22407.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708121637.00144.phillips@phunq.net> <20070813072848.GC23758@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-085-152.lax1.dsl.speakeasy.net ([64.81.85.152]:33495
	"EHLO moonbase.phunq.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S970530AbXHMI7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 04:59:33 -0400
In-Reply-To: <20070813072848.GC23758@kernel.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 00:28, Jens Axboe wrote:
> On Sun, Aug 12 2007, Daniel Phillips wrote:
> > Right, that is done by bi_vcnt.  I meant bi_max_vecs, which you can
> > derive efficiently from BIO_POOL_IDX() provided the bio was
> > allocated in the standard way.
>
> That would only be feasible, if we ruled that any bio in the system
> must originate from the standard pools.

Not at all.

> > This leaves a little bit of clean up to do for bios not allocated
> > from a standard pool.
>
> Please suggest how to do such a cleanup.

Easy, use the BIO_POOL bits to know the bi_max_size, the same as for a 
bio from the standard pool.  Just put the power of two size in the bits 
and map that number to the standard pool arrangement with a table 
lookup.

> > On the other hand, vm writeout deadlock ranks smack dab at the top
> > of the list, so that is where the patching effort must go for the
> > forseeable future.  Without bio throttling, the ddsnap load can go
> > to 24 MB for struct bio alone.  That definitely moves the needle. 
> > in short, we save 3,200 times more memory by putting decent
> > throttling in place than by saving an int in struct bio.
>
> Then fix the damn vm writeout. I always thought it was silly to
> depend on the block layer for any sort of throttling. If it's not a
> system wide problem, then throttle the io count in the
> make_request_fn handler of that problematic driver.

It is a system wide problem.  Every block device needs throttling, 
otherwise queues expand without limit.  Currently, block devices that 
use the standard request library get a slipshod form of throttling for 
free in the form of limiting in-flight request structs.  Because the 
amount of IO carried by a single request can vary by two orders of 
magnitude, the system behavior of this approach is far from 
predictable.

> > You did not comment on the one about putting the bio destructor in
> > the ->endio handler, which looks dead simple.  The majority of
> > cases just use the default endio handler and the default
> > destructor.  Of the remaining cases, where a specialized destructor
> > is needed, typically a specialized endio handler is too, so
> > combining is free.  There are few if any cases where a new
> > specialized endio handler would need to be written.
>
> We could do that without too much work, I agree.

OK, we got one and another is close to cracking, enough of that.

> > As far as code stability goes, current kernels are horribly
> > unstable in a variety of contexts because of memory deadlock and
> > slowdowns related to the attempt to fix the problem via dirty
> > memory limits.  Accurate throttling of bio traffic is one of the
> > two key requirements to fix this instability, the other other is
> > accurate writeout path reserve management, which is only partially
> > addressed by BIO_POOL.
>
> Which, as written above and stated many times over the years on lkml,
> is not a block layer issue imho.

Whoever stated that was wrong, but this should be no surprise.  There 
have been many wrong things said about this particular bug over the 
years.  The one thing that remains constant is, Linux continues to 
deadlock under a variety of loads both with and without network 
involvement, making it effectively useless as a storage platform.

These deadlocks are first and foremost, block layer deficiencies.  Even 
the network becomes part of the problem only because it lies in the 
block IO path.

Regards,

Daniel
