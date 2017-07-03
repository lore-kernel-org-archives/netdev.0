From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH RFC 01/26] netfilter: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Mon, 3 Jul 2017 16:04:14 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1707031559380.2027-100000@iolanthe.rowland.org>
References: <20170703171420.GC2393@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Manfred Spraul <manfred@colorfullife.com>,
        <linux-kernel@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <oleg@redhat.com>,
        <akpm@linux-foundation.org>, <mingo@redhat.com>,
        <dave@stgolabs.net>, <tj@kernel.org>, <arnd@arndb.de>,
        <linux-arch@vger.kernel.org>, <will.deacon@arm.com>,
        <peterz@infradead.org>, <parri.andrea@gmail.com>,
        <torvalds@linux-foundation.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, <coreteam@netfilter.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170703171420.GC2393@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 3 Jul 2017, Paul E. McKenney wrote:

> On Mon, Jul 03, 2017 at 10:39:49AM -0400, Alan Stern wrote:
> > On Sat, 1 Jul 2017, Manfred Spraul wrote:
> > 
> > > As we want to remove spin_unlock_wait() and replace it with explicit
> > > spin_lock()/spin_unlock() calls, we can use this to simplify the
> > > locking.
> > > 
> > > In addition:
> > > - Reading nf_conntrack_locks_all needs ACQUIRE memory ordering.
> > > - The new code avoids the backwards loop.
> > > 
> > > Only slightly tested, I did not manage to trigger calls to
> > > nf_conntrack_all_lock().
> > > 
> > > Fixes: b16c29191dc8
> > > Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> > > Cc: <stable@vger.kernel.org>
> > > Cc: Sasha Levin <sasha.levin@oracle.com>
> > > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > > Cc: netfilter-devel@vger.kernel.org
> > > ---
> > >  net/netfilter/nf_conntrack_core.c | 44 +++++++++++++++++++++------------------
> > >  1 file changed, 24 insertions(+), 20 deletions(-)
> > > 
> > > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > > index e847dba..1193565 100644
> > > --- a/net/netfilter/nf_conntrack_core.c
> > > +++ b/net/netfilter/nf_conntrack_core.c
> > > @@ -96,19 +96,24 @@ static struct conntrack_gc_work conntrack_gc_work;
> > >  
> > >  void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
> > >  {
> > > +	/* 1) Acquire the lock */
> > >  	spin_lock(lock);
> > > -	while (unlikely(nf_conntrack_locks_all)) {
> > > -		spin_unlock(lock);
> > >  
> > > -		/*
> > > -		 * Order the 'nf_conntrack_locks_all' load vs. the
> > > -		 * spin_unlock_wait() loads below, to ensure
> > > -		 * that 'nf_conntrack_locks_all_lock' is indeed held:
> > > -		 */
> > > -		smp_rmb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
> > > -		spin_unlock_wait(&nf_conntrack_locks_all_lock);
> > > -		spin_lock(lock);
> > > -	}
> > > +	/* 2) read nf_conntrack_locks_all, with ACQUIRE semantics */
> > > +	if (likely(smp_load_acquire(&nf_conntrack_locks_all) == false))
> > > +		return;
> > 
> > As far as I can tell, this read does not need to have ACQUIRE
> > semantics.
> > 
> > You need to guarantee that two things can never happen:
> > 
> >     (1) We read nf_conntrack_locks_all == false, and this routine's
> > 	critical section for nf_conntrack_locks[i] runs after the
> > 	(empty) critical section for that lock in 
> > 	nf_conntrack_all_lock().
> > 
> >     (2) We read nf_conntrack_locks_all == true, and this routine's 
> > 	critical section for nf_conntrack_locks_all_lock runs before 
> > 	the critical section in nf_conntrack_all_lock().
> > 
> > In fact, neither one can happen even if smp_load_acquire() is replaced
> > with READ_ONCE().  The reason is simple enough, using this property of
> > spinlocks:
> > 
> > 	If critical section CS1 runs before critical section CS2 (for 
> > 	the same lock) then: (a) every write coming before CS1's
> > 	spin_unlock() will be visible to any read coming after CS2's
> > 	spin_lock(), and (b) no write coming after CS2's spin_lock()
> > 	will be visible to any read coming before CS1's spin_unlock().
> > 
> > Thus for (1), assuming the critical sections run in the order mentioned
> > above, since nf_conntrack_all_lock() writes to nf_conntrack_locks_all
> > before releasing nf_conntrack_locks[i], and since nf_conntrack_lock()
> > acquires nf_conntrack_locks[i] before reading nf_conntrack_locks_all,
> > by (a) the read will always see the write.
> > 
> > Similarly for (2), since nf_conntrack_all_lock() acquires 
> > nf_conntrack_locks_all_lock before writing to nf_conntrack_locks_all, 
> > and since nf_conntrack_lock() reads nf_conntrack_locks_all before 
> > releasing nf_conntrack_locks_all_lock, by (b) the read cannot see the 
> > write.
> 
> And the Linux kernel memory model (https://lwn.net/Articles/718628/
> and https://lwn.net/Articles/720550/) agrees with Alan.  Here is
> a litmus test, which emulates spin_lock() with xchg_acquire() and
> spin_unlock() with smp_store_release():
> 
> ------------------------------------------------------------------------
> 
> C C-ManfredSpraul-L1G1xchgnr.litmus
> 
> (* Expected result: Never.  *)
> 
> {
> }
> 
> P0(int *nfcla, spinlock_t *gbl, int *gbl_held, spinlock_t *lcl, int *lcl_held)
> {
> 	/* Acquire local lock. */
> 	r10 = xchg_acquire(lcl, 1);
> 	r1 = READ_ONCE(*nfcla);
> 	if (r1) {
> 		smp_store_release(lcl, 0);
> 		r11 = xchg_acquire(gbl, 1);
> 		r12 = xchg_acquire(lcl, 1);
> 		smp_store_release(gbl, 0);
> 	}
> 	r2 = READ_ONCE(*gbl_held);
> 	WRITE_ONCE(*lcl_held, 1);
> 	WRITE_ONCE(*lcl_held, 0);
> 	smp_store_release(lcl, 0);
> }
> 
> P1(int *nfcla, spinlock_t *gbl, int *gbl_held, spinlock_t *lcl, int *lcl_held)
> {
> 	/* Acquire global lock. */
> 	r10 = xchg_acquire(gbl, 1);
> 	WRITE_ONCE(*nfcla, 1);
> 	r11 = xchg_acquire(lcl, 1);
> 	smp_store_release(lcl, 0);
> 	r2 = READ_ONCE(*lcl_held);
> 	WRITE_ONCE(*gbl_held, 1);

This litmus test is incomplete, because it omits the assignment setting
nf_conntrack_locks_all back to false when the global lock is released.  
You should insert

	smp_store_release(*nfcla, 0);

right here.

> 	WRITE_ONCE(*gbl_held, 0);
> 	smp_store_release(gbl, 0);
> }
> 
> exists
> ((0:r2=1 \/ 1:r2=1) /\ 0:r10=0 /\ 0:r11=0 /\ 0:r12=0 /\ 1:r10=0 /\ 1:r11=0)

With that addition, the litmus test fails unless the read of nfcla in 
P0 is an smp_load_acquire.  So Manfred's patch should not be changed.

Alan Stern
