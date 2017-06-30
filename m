From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 02/26] task_work: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Fri, 30 Jun 2017 09:16:07 -0700
Message-ID: <20170630161607.GX2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-2-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630110445.GA5123@redhat.com>
 <20170630125020.GU2393@linux.vnet.ibm.com>
 <20170630152010.GA6935@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com,
        tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org,
        will.deacon@arm.com, peterz@infradead.org,
        stern@rowland.harvard.edu, parri.andrea@gmail.com,
        torvalds@linux-foundation.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170630152010.GA6935@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 05:20:10PM +0200, Oleg Nesterov wrote:
> On 06/30, Paul E. McKenney wrote:
> >
> > > > +		raw_spin_lock_irq(&task->pi_lock);
> > > > +		raw_spin_unlock_irq(&task->pi_lock);
> >
> > I agree that the spin_unlock_wait() implementations would avoid the
> > deadlock with an acquisition from an interrupt handler, while also
> > avoiding the need to momentarily disable interrupts.  The ->pi_lock is
> > a per-task lock, so I am assuming (perhaps naively) that contention is
> > not a problem.  So is the overhead of interrupt disabling likely to be
> > noticeable here?
> 
> I do not think the overhead will be noticeable in this particular case.
> 
> But I am not sure I understand why do we want to unlock_wait. Yes I agree,
> it has some problems, but still...
> 
> The code above looks strange for me. If we are going to repeat this pattern
> the perhaps we should add a helper for lock+unlock and name it unlock_wait2 ;)
> 
> If not, we should probably change this code more:

This looks -much- better than my patch!  May I have your Signed-off-by?

							Thanx, Paul

> --- a/kernel/task_work.c
> +++ b/kernel/task_work.c
> @@ -96,20 +96,16 @@ void task_work_run(void)
>  		 * work->func() can do task_work_add(), do not set
>  		 * work_exited unless the list is empty.
>  		 */
> +		raw_spin_lock_irq(&task->pi_lock);
>  		do {
>  			work = READ_ONCE(task->task_works);
>  			head = !work && (task->flags & PF_EXITING) ?
>  				&work_exited : NULL;
>  		} while (cmpxchg(&task->task_works, work, head) != work);
> +		raw_spin_unlock_irq(&task->pi_lock);
> 
>  		if (!work)
>  			break;
> -		/*
> -		 * Synchronize with task_work_cancel(). It can't remove
> -		 * the first entry == work, cmpxchg(task_works) should
> -		 * fail, but it can play with *work and other entries.
> -		 */
> -		raw_spin_unlock_wait(&task->pi_lock);
> 
>  		do {
>  			next = work->next;
> 
> performance-wise this is almost the same, and if we do not really care about
> overhead we can simplify the code: this way it is obvious that we can't race
> with task_work_cancel().
> 
> Oleg.
> 

