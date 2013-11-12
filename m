From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] ipvs: Remove unused variable ret from
 sync_thread_master()
Date: Tue, 12 Nov 2013 18:00:43 +0100
Message-ID: <20131112170043.GB16796@laptop.programming.kicks-ass.net>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org>
 <20131112141314.GQ5056@laptop.programming.kicks-ass.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com>
 <20131112145243.GU5056@laptop.programming.kicks-ass.net>
 <20131112162136.GA29065@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131112162136.GA29065@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 05:21:36PM +0100, Oleg Nesterov wrote:
> On 11/12, Peter Zijlstra wrote:
> >
> > On Tue, Nov 12, 2013 at 02:21:39PM -0000, David Laight wrote:
> > > Shame there isn't a process flag to indicate that the process
> > > will sleep uninterruptibly and that it doesn't matter.
> > > So don't count to the load average and don't emit a warning
> > > if it has been sleeping for a long time.
> >
> > A process flag wouldn't work, because the task could block waiting for
> > actual work to complete in other sleeps.
> >
> > However, we could do something like the below; which would allow us
> > writing things like:
> >
> > 	(void)___wait_event(*sk_sleep(sk),
> > 			    sock_writeable(sk) || kthread_should_stop(),
> > 			    TASK_UNINTERRUPTIBLE | TASK_IDLE, 0, 0,
> > 			    schedule());
> >
> > Marking the one wait-for-more-work as TASK_IDLE such that it doesn't
> > contribute to the load avg.
> 
> Agreed, I thought about additional bit too.
> 
> >  static const char * const task_state_array[] = {
> > -	"R (running)",		/*   0 */
> > -	"S (sleeping)",		/*   1 */
> > -	"D (disk sleep)",	/*   2 */
> > -	"T (stopped)",		/*   4 */
> > -	"t (tracing stop)",	/*   8 */
> > -	"Z (zombie)",		/*  16 */
> > -	"X (dead)",		/*  32 */
> > -	"x (dead)",		/*  64 */
> > -	"K (wakekill)",		/* 128 */
> > -	"W (waking)",		/* 256 */
> > -	"P (parked)",		/* 512 */
> > +	"R (running)",		/*    0 */
> > +	"S (sleeping)",		/*    1 */
> > +	"D (disk sleep)",	/*    2 */
> > +	"T (stopped)",		/*    4 */
> > +	"t (tracing stop)",	/*    8 */
> > +	"Z (zombie)",		/*   16 */
> > +	"X (dead)",		/*   32 */
> > +	"x (dead)",		/*   64 */
> > +	"K (wakekill)",		/*  128 */
> > +	"W (waking)",		/*  256 */
> > +	"P (parked)",		/*  512 */
> > +	"I (idle)",		/* 1024 */
> >  };
> 
> but I am not sure about what /proc/ should report in this case...

We have to put in something...

	BUILD_BUG_ON(1 + ilog2(TASK_STATE_MAX) != ARRAY_SIZE(task_state_array));

However, since we always set it together with TASK_UNINTERUPTIBLE
userspace shouldn't actually ever see the I thing.

> >  #define task_contributes_to_load(task)	\
> >  				((task->state & TASK_UNINTERRUPTIBLE) != 0 && \
> > -				 (task->flags & PF_FROZEN) == 0)
> > +				 (task->flags & PF_FROZEN) == 0 && \
> > +				 (task->state & TASK_IDLE) == 0)
> 
> perhaps
> 
> 	(task->state & (TASK_UNINTERRUPTIBLE | TASK_IDLE)) == TASK_UNINTERRUPTIBLE
> 
> can save an insn.

Fair enough.

> I am also wondering if it makes any sense to turn PF_FROZEN into
> TASK_FROZEN, something like (incomplete, probably racy) patch below.
> Note that it actually adds the new state, not the the qualifier.
> 
> --- x/include/linux/freezer.h
> +++ x/include/linux/freezer.h
> @@ -23,7 +23,7 @@ extern unsigned int freeze_timeout_msecs
>   */
>  static inline bool frozen(struct task_struct *p)
>  {
> -	return p->flags & PF_FROZEN;
> +	return p->state & TASK_FROZEN;

do we want == there? Does it make sense to allow it be set with other
state flags?

>  }
>  
>  extern bool freezing_slow_path(struct task_struct *p);
> --- x/kernel/freezer.c
> +++ x/kernel/freezer.c
> @@ -57,16 +57,13 @@ bool __refrigerator(bool check_kthr_stop
>  	pr_debug("%s entered refrigerator\n", current->comm);
>  
>  	for (;;) {
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -
>  		spin_lock_irq(&freezer_lock);
> -		current->flags |= PF_FROZEN;
> -		if (!freezing(current) ||
> -		    (check_kthr_stop && kthread_should_stop()))
> -			current->flags &= ~PF_FROZEN;
> +		if (freezing(current) &&
> +		    !(check_kthr_stop && kthread_should_stop()))
> +			set_current_state(TASK_FROZEN);
>  		spin_unlock_irq(&freezer_lock);
>  
> -		if (!(current->flags & PF_FROZEN))
> +		if (!(current->state & TASK_FROZEN))
>  			break;
>  		was_frozen = true;
>  		schedule();
> @@ -148,8 +145,7 @@ void __thaw_task(struct task_struct *p)
>  	 * refrigerator.
>  	 */
>  	spin_lock_irqsave(&freezer_lock, flags);
> -	if (frozen(p))
> -		wake_up_process(p);
> +	try_to_wake_up(p, TASK_FROZEN, 0);
>  	spin_unlock_irqrestore(&freezer_lock, flags);
>  }

Should work I suppose... I'm not entirely sure why that's a PF to begin
with.
