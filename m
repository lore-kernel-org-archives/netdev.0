From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [RFC 0/7] hrtimer: drop active hrtimer checks after adding it
Date: Thu, 10 Jul 2014 03:34:58 +0200
Message-ID: <20140710013456.GB6480@localhost.localdomain>
References: <cover.1404888801.git.viresh.kumar@linaro.org>
 <alpine.DEB.2.10.1407092321130.4357@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Viresh Kumar <viresh.kumar@linaro.org>,
	linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org,
	arvind.chauhan@arm.com, preeti@linux.vnet.ibm.com,
	khilman@linaro.org, Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1407092321130.4357@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 09, 2014 at 11:30:41PM +0200, Thomas Gleixner wrote:
> On Wed, 9 Jul 2014, Viresh Kumar wrote:
> 
> So your patch series drops active hrtimer checks after adding it,
> according to your subject line.
> 
> Quite useeul to drop something after adding it, right?
> 
> > hrtimer_start*() family never fails to enqueue a hrtimer to a clock-base. The
> > only special case is when the hrtimer was in past. If it is getting enqueued to
> > local CPUs's clock-base, we raise a softirq and exit, else we handle that on
> > next interrupt on remote CPU.
> > 
> > At several places in the kernel, we try to make sure if hrtimer was added
> > properly or not by calling hrtimer_active(), like:
> > 
> > 	hrtimer_start(timer, expires, mode);
> > 	if (hrtimer_active(timer)) {
> > 		/* Added successfully */
> > 	} else {
> > 		/* Was added in the past */
> > 	}
> > 
> > As hrtimer_start*() never fails, hrtimer_active() is guaranteed to return '1'.
> > So, there is no point calling hrtimer_active().
> 
> Wrong as usual.
> 
> It's a common pattern that short timeouts are given which lead to
> immediate expiry so the extra round through schedule is even more
> pointless than the extra check.

It may be a common pattern but it's not obvious at all as is in the code
except for timers gurus.

It looks like error handling while it's actually an optimization.

Also what about this pattern when it's used in interrupt or interrupt-disabled code?
In this case the handler is not going to fire right away, unless it's enqueued
on another CPU for unpinned timers.

For example this code in tick_nohz_stop_sched_tick():

          hrtimer_start(&ts->sched_timer, expires, HRTIMER_MODE_ABS_PINNED);
          /* Check, if the timer was already in the past */
          if (hrtimer_active(&ts->sched_timer))
                 goto out;

It's not clear what this is handling. Concurrent immediate callback expiration from another CPU?
But the timer is pinned local so it can't execute right away between hrtimer_start() and hrtimer_active()
check...
