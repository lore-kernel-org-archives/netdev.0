From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 04:18:03 -0700
Message-ID: <200708130418.03667.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708122236.24096.phillips@phunq.net> <20070813082326.GC30089@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-085-152.lax1.dsl.speakeasy.net ([64.81.85.152]:46615
	"EHLO moonbase.phunq.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S944390AbXHMLSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 07:18:09 -0400
In-Reply-To: <20070813082326.GC30089@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 01:23, Evgeniy Polyakov wrote:
> On Sun, Aug 12, 2007 at 10:36:23PM -0700, Daniel Phillips 
(phillips@phunq.net) wrote:
> > (previous incomplete message sent accidentally)
> >
> > On Wednesday 08 August 2007 02:54, Evgeniy Polyakov wrote:
> > > On Tue, Aug 07, 2007 at 10:55:38PM +0200, Jens Axboe wrote:
> > >
> > > So, what did we decide? To bloat bio a bit (add a queue pointer)
> > > or to use physical device limits? The latter requires to replace
> > > all occurence of bio->bi_bdev = something_new with
> > > blk_set_bdev(bio, somthing_new), where queue limits will be
> > > appropriately charged. So far I'm testing second case, but I only
> > > changed DST for testing, can change all other users if needed
> > > though.
> >
> > Adding a queue pointer to struct bio and using physical device
> > limits as in your posted patch both suffer from the same problem:
> > you release the throttling on the previous queue when the bio moves
> > to a new one, which is a bug because memory consumption on the
> > previous queue then becomes unbounded, or limited only by the
> > number of struct requests that can be allocated.  In other words,
> > it reverts to the same situation we have now as soon as the IO
> > stack has more than one queue.  (Just a shorter version of my
> > previous post.)
>
> No. Since all requests for virtual device end up in physical devices,
> which have limits, this mechanism works. Virtual device will
> essentially call either generic_make_request() for new physical
> device (and thus will sleep is limit is over), or will process bios
> directly, but in that case it will sleep in generic_make_request()
> for virutal device.

What can happen is, as soon as you unthrottle the previous queue, 
another thread can come in and put another request on it.  Sure, that 
thread will likely block on the physical throttle and so will the rest 
of the incoming threads, but it still allows the higher level queue to 
grow past any given limit, with the help of lots of threads.  JVM for 
example?

Say you have a device mapper device with some physical device sitting 
underneath, the classic use case for this throttle code.  Say 8,000 
threads each submit an IO in parallel.  The device mapper mapping 
function will be called 8,000 times with associated resource 
allocations, regardless of any throttling on the physical device queue.

Anyway, your approach is awfully close to being airtight, there is just 
a small hole.  I would be more than happy to be proved wrong about 
that, but the more I look, the more I see that hole.

> > 1) One throttle count per submitted bio is too crude a measure.  A
> > bio can carry as few as one page or as many as 256 pages.  If you
> > take only
>
> It does not matter - we can count bytes, pages, bio vectors or
> whatever we like, its just a matter of counter and can be changed
> without problem.

Quite true.  In some cases the simple inc/dec per bio works just fine.  
But the general case where finer granularity is required comes up in 
existing code, so there needs to be a plan.

Regards,

Daniel
