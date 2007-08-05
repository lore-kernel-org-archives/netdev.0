From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Sun, 5 Aug 2007 14:23:45 -0700
Message-ID: <200708051423.45484.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708050104.19596.phillips@phunq.net> <20070805150824.GB32132@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070805150824.GB32132@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 05 August 2007 08:08, Evgeniy Polyakov wrote:
> If we are sleeping in memory pool, then we already do not have memory
> to complete previous requests, so we are in trouble.

Not at all.  Any requests in flight are guaranteed to get the resources 
they need to complete.  This is guaranteed by the combination of memory 
reserve management and request queue throttling.  In logical terms, 
reserve management plus queue throttling is necessary and sufficient to 
prevent these deadlocks.  Conversely, the absence of either one allows 
deadlock.

> This can work 
> for devices which do not require additional allocations (like usual
> local storage), but not for network connected ones.

It works for network devices too, and also for a fancy device like 
ddsnap, which is the moral equivalent of a filesystem implemented in 
user space.

> If not in device, then at least it should say to block layer about
> its limits. What about new function to register queue...

Yes, a new internal API is needed eventually.  However, no new api is 
needed right at the moment because we can just hard code the reserve 
sizes and queue limits and audit them by hand, which is not any more 
sloppy than several other kernel subsystems.  The thing is, we need to 
keep any obfuscating detail out of the initial patches because these 
principles are hard enough to explain already without burying them in 
hundreds of lines of API fluff.

That said, the new improved API should probably not be a new way to 
register, but a set of function calls you can use after the queue is 
created, which follows the pattern of the existing queue API.

> ...which will get 
> maximum number of bios in flight and sleep in generic_make_request()
> when new bio is going to be submitted and it is about to exceed the
> limit?

Exactly.  This is what ddsnap currently does and it works.  But we did 
not change generic_make_request for this driver, instead we throttled 
the driver from the time it makes a request to its user space server, 
until the reply comes back.  We did it that way because it was easy and 
was the only segment of the request lifeline that could not be fixed by 
other means.  A proper solution for all block devices will move the 
throttling up into generic_make_request, as you say below.

> By default things will be like they are now, except additional
> non-atomic increment and branch in generic_make_request() and
> decrement and wake in bio_end_io()?

->endio is called in interrupt context, so the accounting needs to be 
atomic as far as I can see.

We actually account the total number of bio pages in flight, otherwise 
you would need to assume the largest possible bio and waste a huge 
amount of reserve memory.  A counting semaphore works fine for this 
purpose, with some slight inefficiency that is nigh on unmeasurable in 
the block IO path.  What the semaphore does is make the patch small and 
easy to understand, which is important at this point.

> I can cook up such a patch if idea worth efforts.

It is.  There are some messy details...  You need a place to store the 
accounting variable/semaphore and need to be able to find that place 
again in ->endio.  Trickier than it sounds, because of the unstructured 
way drivers rewrite ->bi_bdev.   Peterz has already poked at this in a 
number of different ways, typically involving backing_dev_info, which 
seems like a good idea to me.

A simple way to solve the stable accounting field issue is to add a new 
pointer to struct bio that is owned by the top level submitter 
(normally generic_make_request but not always) and is not affected by 
any recursive resubmission.  Then getting rid of that field later 
becomes somebody's summer project, which is not all that urgent because 
struct bio is already bloated up with a bunch of dubious fields and is 
a transient structure anyway.

Regards,

Daniel
