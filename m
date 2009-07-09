From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Thu, 9 Jul 2009 12:44:12 +0200
Message-ID: <20090709104412.GA3651@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local> <200907090023.18040.andres@anarazel.de> <20090708224828.GD3666@ami.dom.local> <alpine.LFD.2.00.0907090956490.24704@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres Freund <andres@anarazel.de>,
	Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:60974 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756080AbZGIKos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 06:44:48 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0907090956490.24704@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 09, 2009 at 12:31:53PM +0200, Thomas Gleixner wrote:
> On Thu, 9 Jul 2009, Jarek Poplawski wrote:
> > On Thu, Jul 09, 2009 at 12:23:17AM +0200, Andres Freund wrote:
> > ...
> > > Unfortunately this just yields the same backtraces during softlockup and not 
> > > earlier.
> > > I did not test without lockdep yet, but that should not have stopped the BUG 
> > > from appearing, right?
> > 
> > Since it looks like hrtimers now, these changes in timers shouldn't
> > matter. Let's wait for new ideas.
> 
> Some background:
...
> There is another oddity in cbq_undelay() which is the hrtimer callback
> function:
> 
> 	if (delay) {
> 		ktime_t time;
> 
> 		time = ktime_set(0, 0);
> 		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
> 		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
> 
> The canocial way to restart a hrtimer from the callback function is to
> set the expiry value and return HRTIMER_RESTART.

OK, that's for later because we didn't use cbq here.

> 
> 	}
> 
> 	sch->flags &= ~TCQ_F_THROTTLED;
> 	__netif_schedule(qdisc_root(sch));
> 	return HRTIMER_NORESTART;
> 
> Again, this should not cause the timer to be enqueued on another CPU
> as we do not enqueue on a different CPU when the callback is running,
> but see above ...
> 
> I have the feeling that the code relies on some implicit cpu
> boundness, which is not longer guaranteed with the timer migration
> changes, but that's a question for the network experts.

As a matter of fact, I've just looked at this __netif_schedule(),
which really is cpu bound, so you might be 100% right.

Thanks for your help,
Jarek P.
