From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock tuning.
Date: Thu, 09 Sep 2010 15:53:13 -0700
Message-ID: <1284072793.2762.259.camel@localhost.localdomain>
References: <cover.1283504065.git.richard.cochran@omicron.at>
	 <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>
	 <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6>
	 <20100909133449.GB2823@riccoc20.at.omicron.at>
	 <alpine.LFD.2.00.1009092102150.2477@localhost6.localdomain6>
	 <alpine.LFD.2.00.1009092244390.2477@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:37427 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757286Ab0IIWxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Sep 2010 18:53:19 -0400
In-Reply-To: <alpine.LFD.2.00.1009092244390.2477@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-09-09 at 23:16 +0200, Thomas Gleixner wrote:
> Hmm. Talked to John Stultz about this and got enlightened that there
> might be more than one of these beasts. That changes the story
> slightly.
> 
> So yes, I've been wrong as usual and we'll need some way of assigning
> those ids dynamically, but I'm still opposed to providing an
> unconfined "give me one of those id's" interface for public
> consumption.
> 
> I'd rather see a controlled environment for device classes like PTP
> clocks. That would have a couple of advantages:
> 
>  - clear association of the device to a well defined functionality
> 
>  - avoidance of duplicated code
> 
>  - consistent sysfs interfaces for functionality which is device class
>    specific
> 
>  - simpler identification for interested applications
> 
>  - preventing the random spread of clock id consumers
> 
> So the clock device class code would provide the interface for these
> class specific hardware drivers and consult the posix timer core code
> to give out an id.
> 
> And that would apply to any other class of clock devices which do not
> fall into the general clocksource category (e.g. RTCs, audio clocks
> ..)
> 
> Thoughts ?

So at first I was concerned, because I thought you were suggesting we
distinguish between the classes of clocks in our userspace interface. 

But after some clarification on IRC, you made it clear that you want
some generic infrastructure that supports what the PTP driver needs that
would then be re-usable by other clocks we want to similarly expose to
userland via a clockid.

So basically you want something akin to the struct clocksource for the
driver to register that would minimize code duplication.

My initial reaction, is that we already have the k_clock structure (from
include/linux/posix-timers.h):
struct k_clock {
	int res;		/* in nanoseconds */
	int (*clock_getres) (const clockid_t which_clock, struct timespec *tp);
	int (*clock_set) (const clockid_t which_clock, struct timespec * tp);
	int (*clock_get) (const clockid_t which_clock, struct timespec * tp);
	int (*timer_create) (struct k_itimer *timer);
	int (*nsleep) (const clockid_t which_clock, int flags,
		       struct timespec *, struct timespec __user *);
	long (*nsleep_restart) (struct restart_block *restart_block);
	int (*timer_set) (struct k_itimer * timr, int flags,
			  struct itimerspec * new_setting,
			  struct itimerspec * old_setting);
	int (*timer_del) (struct k_itimer * timr);
	void (*timer_get) (struct k_itimer * timr,
			   struct itimerspec * cur_setting);
};


This is still very close to the level of the posix clocks/timers api, so
maybe you're wanting something a little lower level, possibly as low as
the clocksource/clockevent structures? 

The only problem there is from the examples, it seems some PTP hardware
can be fairly self-contained. So its a actual ns clock that can be freq
adjusted in hardware, not a constant freq counter that is then converted
to nanoseconds and freq managed in software. So the interface probably
can't be quite as low-level as the clocksource/clockevent structures.

In fact, from the example drivers posted already, it looks like the
k_clock structure maps fairly close to what the hardware uses.

Other clock types that we may want to expose, such as the RTC also can
map fairly close to k_clock. The audio clocks may need some research, as
I suspect they're just a clocksource style counter, so some additional
software cycle->ns layering similar to the timekeeping core (but likely
much simpler) may be needed.

So the question to Richard is, what does the above k_clock not provide
that the PTP driver needs?  If you've already made some stabs at it,
seeing an example of the generic header and a trivial example driver
that includes the k_clock structure, so we can see what it removed from
your earlier chardev implementation would be helpful.

thanks
-john


