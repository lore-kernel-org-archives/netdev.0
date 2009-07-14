From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 14 Jul 2009 18:28:10 +0200
Message-ID: <1247588890.7500.186.camel@twins>
References: <20090709215606.526259917@linutronix.de>
	 <20090712.135555.207096388.davem@davemloft.net>
	 <alpine.LFD.2.00.0907141040350.2777@localhost.localdomain>
	 <20090714.090055.56906831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755505AbZGNQdP@vger.kernel.org>
In-Reply-To: <20090714.090055.56906831.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-07-14 at 09:00 -0700, David Miller wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Tue, 14 Jul 2009 10:55:14 +0200 (CEST)

> > On Sun, 12 Jul 2009, David Miller wrote:
> > 
> >> What should probably happen is that the hrtimer merely fires off work
> >> at software interrupt context (perhaps a tasklet or similar), and that
> >> software interrupt code take the qdisc's root lock throughout it's
> >> execution.
> > 
> > Sigh, I almost expected that the removal of the callback modes will
> > fire back some day.
> 
> Well this makes hrtimers decidedly less useful for networking and we
> have a ton of bugs right now, basically in every hrtimer used by the
> networking currently.
> 
> The only way we can use them, as things currently stand, is as
> triggers for softirq work.
> 
> Is it really that troublesome to provide this kind of facility
> generically, rather than having various subsystems replicate such code
> where they want to use hrtimers and are restricted to softirqs?

Linus really hated the softirq mode, which is what prompted me to change
that.

Now, it might be he only hated the particular interface and the
resulting code, but I think to remember he simply thought the whole
thing daft.

I can look into adding it back if we can agree on the interface and code
impact, but looking at:

# git grep hrtimer_init net/ | sort -u
net/can/bcm.c:          hrtimer_init(&op->thrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
net/can/bcm.c:          hrtimer_init(&op->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
net/sched/sch_api.c:    hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
net/sched/sch_cbq.c:    hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);

I wonder if its worth the impact on the core kernel code, or whether its
better for these few timers to kick off a tasklet or the like.

Further, I don't think a lot of subsystems would need this, as the
general trend is away from softirqs/tasklets and towards
threads/workqueues as most people want to schedule. And for those
hardirq hrtimers are good enough as a wakeup source.
