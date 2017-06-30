From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 02/26] task_work: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Fri, 30 Jun 2017 13:19:02 -0700
Message-ID: <20170630201902.GA940@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-2-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630110445.GA5123@redhat.com>
 <20170630125020.GU2393@linux.vnet.ibm.com>
 <20170630152010.GA6935@redhat.com>
 <20170630161607.GX2393@linux.vnet.ibm.com>
 <20170630192123.GA8471@redhat.com>
 <20170630200248.GF2393@linux.vnet.ibm.com>
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
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170630200248.GF2393@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 01:02:48PM -0700, Paul E. McKenney wrote:
> On Fri, Jun 30, 2017 at 09:21:23PM +0200, Oleg Nesterov wrote:
> > On 06/30, Paul E. McKenney wrote:
> > >
> > > On Fri, Jun 30, 2017 at 05:20:10PM +0200, Oleg Nesterov wrote:
> > > >
> > > > I do not think the overhead will be noticeable in this particular case.
> > > >
> > > > But I am not sure I understand why do we want to unlock_wait. Yes I agree,
> >                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > 
> > if it was not clear, I tried to say "why do we want to _remove_ unlock_wait".
> > 
> > > > it has some problems, but still...
> > > >
> > > > The code above looks strange for me. If we are going to repeat this pattern
> > > > the perhaps we should add a helper for lock+unlock and name it unlock_wait2 ;)
> > > >
> > > > If not, we should probably change this code more:
> > >
> > > This looks -much- better than my patch!  May I have your Signed-off-by?
> > 
> > Only if you promise to replace all RCU flavors with a single simple implementation
> > based on rwlock ;)
> 
> ;-) ;-) ;-)
> 
> Here you go:
> 
> https://github.com/pramalhe/ConcurrencyFreaks/blob/master/papers/poormanurcu-2015.pdf
> 
> > Seriously, of course I won't argue, and it seems that nobody except me likes
> > this primitive, but to me spin_unlock_wait() looks like synchronize_rcu(() and
> > sometimes it makes sense.
> 
> Well, that analogy was what led me to propose that its semantics be
> defined as spin_lock() immediately followed by spin_unlock().  But that
> didn't go over well.
> 
> > Including this particular case. task_work_run() is going to flush/destroy the
> > ->task_works list, so it needs to wait until all currently executing "readers"
> > (task_work_cancel()'s which have started before ->task_works was updated) have
> > completed.
> 
> Understood!

And please see below for the resulting patch and commit log.  Please let
me know if I broke something.

							Thanx, Paul

------------------------------------------------------------------------

commit 6c0801c9ab19fc2f4c1e2436eb1b72e0af9a317b
Author: Oleg Nesterov <oleg@redhat.com>
Date:   Fri Jun 30 13:13:59 2017 -0700

    task_work: Replace spin_unlock_wait() with lock/unlock pair
    
    There is no agreed-upon definition of spin_unlock_wait()'s semantics,
    and it appears that all callers could do just as well with a lock/unlock
    pair.  This commit therefore replaces the spin_unlock_wait() call in
    task_work_run() with a spin_lock_irq() and a spin_unlock_irq() aruond
    the cmpxchg() dequeue loop.  This should be safe from a performance
    perspective because ->pi_lock is local to the task and because calls to
    the other side of the race, task_work_cancel(), should be rare.
    
    Signed-off-by: Oleg Nesterov <oleg@redhat.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/task_work.c b/kernel/task_work.c
index d513051fcca2..836a72a66fba 100644
--- a/kernel/task_work.c
+++ b/kernel/task_work.c
@@ -96,20 +96,16 @@ void task_work_run(void)
 		 * work->func() can do task_work_add(), do not set
 		 * work_exited unless the list is empty.
 		 */
+		raw_spin_lock_irq(&task->pi_lock);
 		do {
 			work = READ_ONCE(task->task_works);
 			head = !work && (task->flags & PF_EXITING) ?
 				&work_exited : NULL;
 		} while (cmpxchg(&task->task_works, work, head) != work);
+		raw_spin_unlock_irq(&task->pi_lock);
 
 		if (!work)
 			break;
-		/*
-		 * Synchronize with task_work_cancel(). It can't remove
-		 * the first entry == work, cmpxchg(task_works) should
-		 * fail, but it can play with *work and other entries.
-		 */
-		raw_spin_unlock_wait(&task->pi_lock);
 
 		do {
 			next = work->next;
