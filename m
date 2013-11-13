From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: oom-kill && frozen()
Date: Wed, 13 Nov 2013 18:07:24 +0100
Message-ID: <20131113170724.GA17739@redhat.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com> <20131112145243.GU5056@laptop.programming.kicks-ass.net> <20131112162136.GA29065@redhat.com> <20131112165643.GA31278@redhat.com> <20131113032053.GA19394@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	David Rientjes <rientjes@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138Ab3KMRGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 12:06:33 -0500
Content-Disposition: inline
In-Reply-To: <20131113032053.GA19394@mtj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13, Tejun Heo wrote:
>
> Hello,
>
> On Tue, Nov 12, 2013 at 05:56:43PM +0100, Oleg Nesterov wrote:
> > On 11/12, Oleg Nesterov wrote:
> > > I am also wondering if it makes any sense to turn PF_FROZEN into
> > > TASK_FROZEN, something like (incomplete, probably racy) patch below.
> > > Note that it actually adds the new state, not the the qualifier.
> >
> > As for the current usage of PF_FROZEN... David, it seems that
> > oom_scan_process_thread()->__thaw_task() is dead? Probably this
> > was fine before, when __thaw_task() cleared the "need to freeze"
> > condition, iirc it was PF_FROZEN.
> >
> > But today __thaw_task() can't help, no? the task will simply
> > schedule() in D state again.
>
> Yeah, it'll have to be actively excluded using e.g. PF_FREEZER_SKIP,
> which, BTW, can usually only be manipulated by the task itself.

Oh, yes, yes, yes, I agree. PF_FREEZER_SKIP and the growing number of
freezable_schedule() makes this all more confusing.

In fact I was think about something like

	1. Add the new __TASK_FREEZABLE qualifier

	2. Turn freezable_schedule() into

		void freezable_schedule(void)
		{
			spin_lock_irq(&current->pi_lock);
			if (current->state)
				current->state |= __TASK_FREEZABLE
			spin_unlock_irq(&current->pi_lock);
			
			schedule();

			try_to_freeze();
		}

	3. Kill PF_FREEZER_SKIP/freezer_do_not_count/count/should_skip

	4. Change freeze_task() and fake_signal_wake_up()

		-	wake_up_state(p, TASK_INTERRUPTIBLE);
		+	wake_up_state(p, TASK_INTERRUPTIBLE | __TASK_FREEZABLE);

Unfortunately, this can only work if the caller can tolerate the
false wakeup. We can even fix wait_for_vfork_done(), but say
ptrace_stop() can't work this way.

And even if we can make this work, the very fact that freezable_schedule()
does schedule() twice does not look right.

_Perhaps_ we can do something like "selective wakeup"? IOW, ignoring the
races/details,

	1. Add __TASK_FROZEN qualifier _and_ state

	2. Change frozen(),

		static inline bool frozen(struct task_struct *p)
		{
			return p->state & __TASK_FROZEN;
		}

	2. Change freezable_schedule(),

		void freezable_schedule(void)
		{
			spin_lock_irq(&current->pi_lock);
			if (current->state)
				current->state |= __TASK_FROZEN;
			spin_unlock_irq(&current->pi_lock);
			
			schedule();
		}

	3. Change __refrigerator() to use saved_state | __TASK_FROZEN
	   too.

	4. Finally, change try_to_wake_up() path to do

		-	p->state = TASK_WAKING;
		+	p->state &= ~state;
		+	if (p->state & ~(TASK_DEAD | TASK_WAKEKILL | TASK_PARKED))
		+		return;
		+	else
		+		p->state = TASK_WAKING;

	   IOW, if the task sleeps in, say, TASK_INTERRUPTIBLE | __TASK_FROZEN
	   then it need both try_to_wake_up(TASK_INTERRUPTIBLE) and
	   try_to_wake_up(__TASK_FROZEN) to wake up.

	 5. Kill PF_FREEZER_SKIP / etc.

Unfortunately, 4. is obviously needs more changes, although at first glance
nothing really nontrivial... we need a common helper for try_to_wake_up()
and ttwu_remote() which checks/changes ->state and we need to avoid "stat"
if we do not actually wake up.

Hmm. and this all makes me think that at least s/PF_FROZEN/TASK_FROZEN/ as
a first step actually makes some sense... Note the "qualifier _and_ state"
above.

Tejun, Peter, do you think this makes any sense? I am just curious, but
"selective wakeup" looks potentially useful.



And what about oom_scan_process_thread() ? should we simply kill this
dead frozen/__thaw_task code or should we change freezing() to respect
TIF_MEMDIE?

Oleg.
