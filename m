From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Mon, 6 Aug 2007 12:25:35 +0400
Message-ID: <20070806082535.GB21909@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708050104.19596.phillips@phunq.net> <20070805150824.GB32132@2ka.mipt.ru> <200708051423.45484.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51025 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755925AbXHFI1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 04:27:50 -0400
Content-Disposition: inline
In-Reply-To: <200708051423.45484.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 05, 2007 at 02:23:45PM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Sunday 05 August 2007 08:08, Evgeniy Polyakov wrote:
> > If we are sleeping in memory pool, then we already do not have memory
> > to complete previous requests, so we are in trouble.
> 
> Not at all.  Any requests in flight are guaranteed to get the resources 
> they need to complete.  This is guaranteed by the combination of memory 
> reserve management and request queue throttling.  In logical terms, 
> reserve management plus queue throttling is necessary and sufficient to 
> prevent these deadlocks.  Conversely, the absence of either one allows 
> deadlock.

Only if you have two, which must be closely related to each other (i.e.
each request  must have network reserve big enough to store data).

> > This can work 
> > for devices which do not require additional allocations (like usual
> > local storage), but not for network connected ones.
> 
> It works for network devices too, and also for a fancy device like 
> ddsnap, which is the moral equivalent of a filesystem implemented in 
> user space.

With or without vm deadlock patches? I can not see how it can work, if
network does not have a reserve and there is not free memory completely.
If all systems have reserve then yes, it works good.

> > By default things will be like they are now, except additional
> > non-atomic increment and branch in generic_make_request() and
> > decrement and wake in bio_end_io()?
> 
> ->endio is called in interrupt context, so the accounting needs to be 
> atomic as far as I can see.

Actually we only care about if there is a place in the queue or not - so
it can be a flag. Actually non-atomic operations are ok, since having
plus/minus couple of requests in flight does not change the picture, but
allows not to introduce slow atomic operations in the fast path.

> We actually account the total number of bio pages in flight, otherwise 
> you would need to assume the largest possible bio and waste a huge 
> amount of reserve memory.  A counting semaphore works fine for this 
> purpose, with some slight inefficiency that is nigh on unmeasurable in 
> the block IO path.  What the semaphore does is make the patch small and 
> easy to understand, which is important at this point.

Yes, it can be bio vectors.

> > I can cook up such a patch if idea worth efforts.
> 
> It is.  There are some messy details...  You need a place to store the 
> accounting variable/semaphore and need to be able to find that place 
> again in ->endio.  Trickier than it sounds, because of the unstructured 
> way drivers rewrite ->bi_bdev.   Peterz has already poked at this in a 
> number of different ways, typically involving backing_dev_info, which 
> seems like a good idea to me.

We can demand that reserve is not per virtual device, but per real one -
for example in case of distributed storage locally connected node should
have much higher limit than network one, but having a per-virtual device
reserve might end up with situation, when local node can proceed data,
but no requests will be queued sine all requests below limit are in
network node. In case of per real device limit there is no need to
increase bio.

-- 
	Evgeniy Polyakov
