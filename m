From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused
 by netem)
Date: Thu, 9 Jul 2009 12:31:53 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0907090956490.24704@localhost.localdomain>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local> <200907090023.18040.andres@anarazel.de> <20090708224828.GD3666@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andres Freund <andres@anarazel.de>,
	Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:36322 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756215AbZGIKca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 06:32:30 -0400
In-Reply-To: <20090708224828.GD3666@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Jul 2009, Jarek Poplawski wrote:
> On Thu, Jul 09, 2009 at 12:23:17AM +0200, Andres Freund wrote:
> ...
> > Unfortunately this just yields the same backtraces during softlockup and not 
> > earlier.
> > I did not test without lockdep yet, but that should not have stopped the BUG 
> > from appearing, right?
> 
> Since it looks like hrtimers now, these changes in timers shouldn't
> matter. Let's wait for new ideas.

Some background:

Up to 2.6.30 hrtimer_start() and add_timer() enqueue (hr)timers on the
CPU on which the functions are called. There is one exception when the
timer callback is currently running on another CPU then it is enqueued
on that other CPU.

The migration patches change that behaviour and enqeue the timer on
the nohz.idle_balancer CPU when parts of the system are idle.

With the migration code disabled (via sysctl or the #if 0 patch) the
timer is always enqeued on the same CPU, i.e. you get the 2.6.30
behaviour back.

As you found out it is probably related to hrtimers. Checking the
network code the only hrtimer users are in net/sched/sch_api.c and
net/sched/sch_cbq.c . There is some in net/can as well, but that's
probably irrelevant for the problem at hand.

I'm not familiar with that code, so I have no clue which problems
might pop up due to enqueueing the timer on another CPU, but there is
one pretty suspicios code sequence in cbq_ovl_delay()

	expires = ktime_set(0, 0);
	expires = ktime_add_ns(expires, PSCHED_US2NS(sched));
	if (hrtimer_try_to_cancel(&q->delay_timer) &&
	    ktime_to_ns(ktime_sub(
			hrtimer_get_expires(&q->delay_timer),
			expires)) > 0)
		hrtimer_set_expires(&q->delay_timer, expires);
	hrtimer_restart(&q->delay_timer);

So we set the expiry value of the timer only when the timer was active
(hrtimer_try_to_cancel() returned != 0) and the new expiry time is
before the expiry time which was in the active timer. If the timer was
inactive we start the timer with the last expiry time which is
probably already in the past.

I'm quite sure that this is not causing the migration problem, because
we do not enqueue it on a different CPU when the timer is already
expired.

For completeness: hrtimer_try_to_cancel() can return -1 when the timer
callback is running. So in that case we also fiddle with the expiry
value and restart the timer while the callback code itself might do
the same. There is no serializiation of that code and the callback it
seems. The watchdog timer callback in sch_api.c is not serialized
either.

There is another oddity in cbq_undelay() which is the hrtimer callback
function:

	if (delay) {
		ktime_t time;

		time = ktime_set(0, 0);
		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);

The canocial way to restart a hrtimer from the callback function is to
set the expiry value and return HRTIMER_RESTART.

	}

	sch->flags &= ~TCQ_F_THROTTLED;
	__netif_schedule(qdisc_root(sch));
	return HRTIMER_NORESTART;

Again, this should not cause the timer to be enqueued on another CPU
as we do not enqueue on a different CPU when the callback is running,
but see above ...

I have the feeling that the code relies on some implicit cpu
boundness, which is not longer guaranteed with the timer migration
changes, but that's a question for the network experts.

Thanks,

	tglx
