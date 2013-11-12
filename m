From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] ipvs: Remove unused variable ret from
	sync_thread_master()
Date: Tue, 12 Nov 2013 19:04:51 +0100
Message-ID: <20131112180451.GA32565@redhat.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com> <20131112145243.GU5056@laptop.programming.kicks-ass.net> <20131112162136.GA29065@redhat.com> <20131112170043.GB16796@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab3KLSD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 13:03:56 -0500
Content-Disposition: inline
In-Reply-To: <20131112170043.GB16796@laptop.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12, Peter Zijlstra wrote:
>
> On Tue, Nov 12, 2013 at 05:21:36PM +0100, Oleg Nesterov wrote:
> > On 11/12, Peter Zijlstra wrote:
> > >
> > >  static const char * const task_state_array[] = {
> > >  ...
> > > +	"I (idle)",		/* 1024 */
> > >  };
> >
> > but I am not sure about what /proc/ should report in this case...
>
> We have to put in something...
>
> 	BUILD_BUG_ON(1 + ilog2(TASK_STATE_MAX) != ARRAY_SIZE(task_state_array));
>
> However, since we always set it together with TASK_UNINTERUPTIBLE
> userspace shouldn't actually ever see the I thing.

OOPS. I didn't know that get_task_state() does &= TASK_REPORT. So it
can never report anything > EXIT_DEAD.

Perhaps we should change BUILD_BUG_ON() and shrink task_state_array?

	--- x/include/linux/sched.h
	+++ x/include/linux/sched.h
	@@ -163,7 +163,7 @@ extern char ___assert_task_state[1 - 2*!
	 /* get_task_state() */
	 #define TASK_REPORT		(TASK_RUNNING | TASK_INTERRUPTIBLE | \
					 TASK_UNINTERRUPTIBLE | __TASK_STOPPED | \
	-				 __TASK_TRACED)
	+				 __TASK_TRACED | EXIT_ZOMBIE | EXIT_DEAD)
	 
	 #define task_is_traced(task)	((task->state & __TASK_TRACED) != 0)
	 #define task_is_stopped(task)	((task->state & __TASK_STOPPED) != 0)
	--- x/fs/proc/array.c
	+++ x/fs/proc/array.c
	@@ -148,16 +148,12 @@ static const char * const task_state_arr
	 
	 static inline const char *get_task_state(struct task_struct *tsk)
	 {
	-	unsigned int state = (tsk->state & TASK_REPORT) | tsk->exit_state;
	+	unsigned int state = (tsk->state | tsk->exit_state) & TASK_REPORT;
		const char * const *p = &task_state_array[0];
	 
	-	BUILD_BUG_ON(1 + ilog2(TASK_STATE_MAX) != ARRAY_SIZE(task_state_array));
	+	BUILD_BUG_ON(1 + ilog2(TASK_REPORT) != ARRAY_SIZE(task_state_array));
	 
	-	while (state) {
	-		p++;
	-		state >>= 1;
	-	}
	-	return *p;
	+	return task_state_array[fls(state)];
	 }
	 
	 static inline void task_state(struct seq_file *m, struct pid_namespace *ns,

> > I am also wondering if it makes any sense to turn PF_FROZEN into
> > TASK_FROZEN, something like (incomplete, probably racy) patch below.
> > Note that it actually adds the new state, not the the qualifier.
> >
> > --- x/include/linux/freezer.h
> > +++ x/include/linux/freezer.h
> > @@ -23,7 +23,7 @@ extern unsigned int freeze_timeout_msecs
> >   */
> >  static inline bool frozen(struct task_struct *p)
> >  {
> > -	return p->flags & PF_FROZEN;
> > +	return p->state & TASK_FROZEN;
>
> do we want == there?

Not really, but if we add TASK_FROZEN then we should probably
add task_is_frozen() just for consistency (frozen() should use
this helper) and all task_is_* helpers do "&".

And,

> Does it make sense to allow it be set with other
> state flags?

Not sure, but _perhaps_ TASK_FROZEN | TASK_KILLABLE can be used
too, say, we can add CGROUP_FROZEN_KILLABLE. Probably makes no
sense, I dunno.

> > --- x/kernel/freezer.c
> > +++ x/kernel/freezer.c
> > @@ -57,16 +57,13 @@ bool __refrigerator(bool check_kthr_stop
> >  	pr_debug("%s entered refrigerator\n", current->comm);
> >
> >  	for (;;) {
> > -		set_current_state(TASK_UNINTERRUPTIBLE);
> > -
> >  		spin_lock_irq(&freezer_lock);
> > -		current->flags |= PF_FROZEN;
> > -		if (!freezing(current) ||
> > -		    (check_kthr_stop && kthread_should_stop()))
> > -			current->flags &= ~PF_FROZEN;
> > +		if (freezing(current) &&
> > +		    !(check_kthr_stop && kthread_should_stop()))
> > +			set_current_state(TASK_FROZEN);
> >  		spin_unlock_irq(&freezer_lock);
> >
> > -		if (!(current->flags & PF_FROZEN))
> > +		if (!(current->state & TASK_FROZEN))
> >  			break;
> >  		was_frozen = true;
> >  		schedule();
> > @@ -148,8 +145,7 @@ void __thaw_task(struct task_struct *p)
> >  	 * refrigerator.
> >  	 */
> >  	spin_lock_irqsave(&freezer_lock, flags);
> > -	if (frozen(p))
> > -		wake_up_process(p);
> > +	try_to_wake_up(p, TASK_FROZEN, 0);
> >  	spin_unlock_irqrestore(&freezer_lock, flags);
> >  }
>
> Should work I suppose...

And perhaps we can simplify this a bit. Not sure we can kill freezer_lock
altogether, but at least __thaw_task() can avoid it.

But I am still not sure the new TASK_ state really makes sense, even if
it looks a bit more clean to me.

OTOH, personally I think that /proc/pid/status should report "F (frozen)"
if frozen(), but this doesn't need TASK_FROZEN of course.

> I'm not entirely sure why that's a PF to begin
> with.

Oh, it had more PF_'s until tj improved (and cleanuped) this code ;)

Oleg.
