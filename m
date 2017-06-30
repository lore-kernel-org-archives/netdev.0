From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 08/26] locking: Remove spin_unlock_wait() generic
 definitions
Date: Fri, 30 Jun 2017 05:38:15 -0700
Message-ID: <20170630123815.GT2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-8-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630091928.GC9726@arm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, oleg@redhat.com, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com,
        tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170630091928.GC9726@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 10:19:29AM +0100, Will Deacon wrote:
> On Thu, Jun 29, 2017 at 05:01:16PM -0700, Paul E. McKenney wrote:
> > There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> > and it appears that all callers could do just as well with a lock/unlock
> > pair.  This commit therefore removes spin_unlock_wait() and related
> > definitions from core code.
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Will Deacon <will.deacon@arm.com>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Alan Stern <stern@rowland.harvard.edu>
> > Cc: Andrea Parri <parri.andrea@gmail.com>
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > ---
> >  include/asm-generic/qspinlock.h |  14 -----
> >  include/linux/spinlock.h        |  31 -----------
> >  include/linux/spinlock_up.h     |   6 ---
> >  kernel/locking/qspinlock.c      | 117 ----------------------------------------
> >  4 files changed, 168 deletions(-)
> 
> [...]
> 
> > diff --git a/kernel/locking/qspinlock.c b/kernel/locking/qspinlock.c
> > index b2caec7315af..64a9051e4c2c 100644
> > --- a/kernel/locking/qspinlock.c
> > +++ b/kernel/locking/qspinlock.c
> > @@ -267,123 +267,6 @@ static __always_inline u32  __pv_wait_head_or_lock(struct qspinlock *lock,
> >  #define queued_spin_lock_slowpath	native_queued_spin_lock_slowpath
> >  #endif
> >  
> > -/*
> > - * Various notes on spin_is_locked() and spin_unlock_wait(), which are
> > - * 'interesting' functions:
> > - *
> > - * PROBLEM: some architectures have an interesting issue with atomic ACQUIRE
> > - * operations in that the ACQUIRE applies to the LOAD _not_ the STORE (ARM64,
> > - * PPC). Also qspinlock has a similar issue per construction, the setting of
> > - * the locked byte can be unordered acquiring the lock proper.
> > - *
> > - * This gets to be 'interesting' in the following cases, where the /should/s
> > - * end up false because of this issue.
> > - *
> > - *
> > - * CASE 1:
> > - *
> > - * So the spin_is_locked() correctness issue comes from something like:
> > - *
> > - *   CPU0				CPU1
> > - *
> > - *   global_lock();			local_lock(i)
> > - *     spin_lock(&G)			  spin_lock(&L[i])
> > - *     for (i)				  if (!spin_is_locked(&G)) {
> > - *       spin_unlock_wait(&L[i]);	    smp_acquire__after_ctrl_dep();
> > - *					    return;
> > - *					  }
> > - *					  // deal with fail
> > - *
> > - * Where it is important CPU1 sees G locked or CPU0 sees L[i] locked such
> > - * that there is exclusion between the two critical sections.
> > - *
> > - * The load from spin_is_locked(&G) /should/ be constrained by the ACQUIRE from
> > - * spin_lock(&L[i]), and similarly the load(s) from spin_unlock_wait(&L[i])
> > - * /should/ be constrained by the ACQUIRE from spin_lock(&G).
> > - *
> > - * Similarly, later stuff is constrained by the ACQUIRE from CTRL+RMB.
> 
> Might be worth keeping this comment about spin_is_locked, since we're not
> removing that guy just yet!

Ah, all the examples had spin_unlock_wait() in them.  So what I need to
do is to create a spin_unlock_wait()-free example to illustrate the
text starting with "The load from spin_is_locked(", correct?

I also need to check all uses of spin_is_locked().  There might no
longer be any that rely on any particular ordering...

								Thanx, Paul
