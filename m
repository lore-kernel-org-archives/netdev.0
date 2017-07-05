From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v2 8/9] locking: Remove spin_unlock_wait() generic definitions
Date: Wed,  5 Jul 2017 16:31:42 -0700
Message-ID: <1499297503-23852-8-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170705232955.GA15992@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170705232955.GA15992@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes spin_unlock_wait() and related
definitions from core code.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 include/asm-generic/qspinlock.h |  14 -----
 include/linux/spinlock.h        |  31 -----------
 include/linux/spinlock_up.h     |   6 ---
 kernel/locking/qspinlock.c      | 117 ----------------------------------------
 4 files changed, 168 deletions(-)

diff --git a/include/asm-generic/qspinlock.h b/include/asm-generic/qspinlock.h
index 9f0681bf1e87..66260777d644 100644
--- a/include/asm-generic/qspinlock.h
+++ b/include/asm-generic/qspinlock.h
@@ -22,17 +22,6 @@
 #include <asm-generic/qspinlock_types.h>
 
 /**
- * queued_spin_unlock_wait - wait until the _current_ lock holder releases the lock
- * @lock : Pointer to queued spinlock structure
- *
- * There is a very slight possibility of live-lock if the lockers keep coming
- * and the waiter is just unfortunate enough to not see any unlock state.
- */
-#ifndef queued_spin_unlock_wait
-extern void queued_spin_unlock_wait(struct qspinlock *lock);
-#endif
-
-/**
  * queued_spin_is_locked - is the spinlock locked?
  * @lock: Pointer to queued spinlock structure
  * Return: 1 if it is locked, 0 otherwise
@@ -41,8 +30,6 @@ extern void queued_spin_unlock_wait(struct qspinlock *lock);
 static __always_inline int queued_spin_is_locked(struct qspinlock *lock)
 {
 	/*
-	 * See queued_spin_unlock_wait().
-	 *
 	 * Any !0 state indicates it is locked, even if _Q_LOCKED_VAL
 	 * isn't immediately observable.
 	 */
@@ -135,6 +122,5 @@ static __always_inline bool virt_spin_lock(struct qspinlock *lock)
 #define arch_spin_trylock(l)		queued_spin_trylock(l)
 #define arch_spin_unlock(l)		queued_spin_unlock(l)
 #define arch_spin_lock_flags(l, f)	queued_spin_lock(l)
-#define arch_spin_unlock_wait(l)	queued_spin_unlock_wait(l)
 
 #endif /* __ASM_GENERIC_QSPINLOCK_H */
diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index d9510e8522d4..ef018a6e4985 100644
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
@@ -130,12 +130,6 @@ do {								\
 #define smp_mb__before_spinlock()	smp_wmb()
 #endif
 
-/**
- * raw_spin_unlock_wait - wait until the spinlock gets unlocked
- * @lock: the spinlock in question.
- */
-#define raw_spin_unlock_wait(lock)	arch_spin_unlock_wait(&(lock)->raw_lock)
-
 #ifdef CONFIG_DEBUG_SPINLOCK
  extern void do_raw_spin_lock(raw_spinlock_t *lock) __acquires(lock);
 #define do_raw_spin_lock_flags(lock, flags) do_raw_spin_lock(lock)
@@ -369,31 +363,6 @@ static __always_inline int spin_trylock_irq(spinlock_t *lock)
 	raw_spin_trylock_irqsave(spinlock_check(lock), flags); \
 })
 
-/**
- * spin_unlock_wait - Interpose between successive critical sections
- * @lock: the spinlock whose critical sections are to be interposed.
- *
- * Semantically this is equivalent to a spin_lock() immediately
- * followed by a spin_unlock().  However, most architectures have
- * more efficient implementations in which the spin_unlock_wait()
- * cannot block concurrent lock acquisition, and in some cases
- * where spin_unlock_wait() does not write to the lock variable.
- * Nevertheless, spin_unlock_wait() can have high overhead, so if
- * you feel the need to use it, please check to see if there is
- * a better way to get your job done.
- *
- * The ordering guarantees provided by spin_unlock_wait() are:
- *
- * 1.  All accesses preceding the spin_unlock_wait() happen before
- *     any accesses in later critical sections for this same lock.
- * 2.  All accesses following the spin_unlock_wait() happen after
- *     any accesses in earlier critical sections for this same lock.
- */
-static __always_inline void spin_unlock_wait(spinlock_t *lock)
-{
-	raw_spin_unlock_wait(&lock->rlock);
-}
-
 static __always_inline int spin_is_locked(spinlock_t *lock)
 {
 	return raw_spin_is_locked(&lock->rlock);
diff --git a/include/linux/spinlock_up.h b/include/linux/spinlock_up.h
index 0d9848de677d..612fb530af41 100644
--- a/include/linux/spinlock_up.h
+++ b/include/linux/spinlock_up.h
@@ -26,11 +26,6 @@
 #ifdef CONFIG_DEBUG_SPINLOCK
 #define arch_spin_is_locked(x)		((x)->slock == 0)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	smp_cond_load_acquire(&lock->slock, VAL);
-}
-
 static inline void arch_spin_lock(arch_spinlock_t *lock)
 {
 	lock->slock = 0;
@@ -73,7 +68,6 @@ static inline void arch_spin_unlock(arch_spinlock_t *lock)
 
 #else /* DEBUG_SPINLOCK */
 #define arch_spin_is_locked(lock)	((void)(lock), 0)
-#define arch_spin_unlock_wait(lock)	do { barrier(); (void)(lock); } while (0)
 /* for sched/core.c and kernel_lock.c: */
 # define arch_spin_lock(lock)		do { barrier(); (void)(lock); } while (0)
 # define arch_spin_lock_flags(lock, flags)	do { barrier(); (void)(lock); } while (0)
diff --git a/kernel/locking/qspinlock.c b/kernel/locking/qspinlock.c
index b2caec7315af..64a9051e4c2c 100644
--- a/kernel/locking/qspinlock.c
+++ b/kernel/locking/qspinlock.c
@@ -267,123 +267,6 @@ static __always_inline u32  __pv_wait_head_or_lock(struct qspinlock *lock,
 #define queued_spin_lock_slowpath	native_queued_spin_lock_slowpath
 #endif
 
-/*
- * Various notes on spin_is_locked() and spin_unlock_wait(), which are
- * 'interesting' functions:
- *
- * PROBLEM: some architectures have an interesting issue with atomic ACQUIRE
- * operations in that the ACQUIRE applies to the LOAD _not_ the STORE (ARM64,
- * PPC). Also qspinlock has a similar issue per construction, the setting of
- * the locked byte can be unordered acquiring the lock proper.
- *
- * This gets to be 'interesting' in the following cases, where the /should/s
- * end up false because of this issue.
- *
- *
- * CASE 1:
- *
- * So the spin_is_locked() correctness issue comes from something like:
- *
- *   CPU0				CPU1
- *
- *   global_lock();			local_lock(i)
- *     spin_lock(&G)			  spin_lock(&L[i])
- *     for (i)				  if (!spin_is_locked(&G)) {
- *       spin_unlock_wait(&L[i]);	    smp_acquire__after_ctrl_dep();
- *					    return;
- *					  }
- *					  // deal with fail
- *
- * Where it is important CPU1 sees G locked or CPU0 sees L[i] locked such
- * that there is exclusion between the two critical sections.
- *
- * The load from spin_is_locked(&G) /should/ be constrained by the ACQUIRE from
- * spin_lock(&L[i]), and similarly the load(s) from spin_unlock_wait(&L[i])
- * /should/ be constrained by the ACQUIRE from spin_lock(&G).
- *
- * Similarly, later stuff is constrained by the ACQUIRE from CTRL+RMB.
- *
- *
- * CASE 2:
- *
- * For spin_unlock_wait() there is a second correctness issue, namely:
- *
- *   CPU0				CPU1
- *
- *   flag = set;
- *   smp_mb();				spin_lock(&l)
- *   spin_unlock_wait(&l);		if (!flag)
- *					  // add to lockless list
- *					spin_unlock(&l);
- *   // iterate lockless list
- *
- * Which wants to ensure that CPU1 will stop adding bits to the list and CPU0
- * will observe the last entry on the list (if spin_unlock_wait() had ACQUIRE
- * semantics etc..)
- *
- * Where flag /should/ be ordered against the locked store of l.
- */
-
-/*
- * queued_spin_lock_slowpath() can (load-)ACQUIRE the lock before
- * issuing an _unordered_ store to set _Q_LOCKED_VAL.
- *
- * This means that the store can be delayed, but no later than the
- * store-release from the unlock. This means that simply observing
- * _Q_LOCKED_VAL is not sufficient to determine if the lock is acquired.
- *
- * There are two paths that can issue the unordered store:
- *
- *  (1) clear_pending_set_locked():	*,1,0 -> *,0,1
- *
- *  (2) set_locked():			t,0,0 -> t,0,1 ; t != 0
- *      atomic_cmpxchg_relaxed():	t,0,0 -> 0,0,1
- *
- * However, in both cases we have other !0 state we've set before to queue
- * ourseves:
- *
- * For (1) we have the atomic_cmpxchg_acquire() that set _Q_PENDING_VAL, our
- * load is constrained by that ACQUIRE to not pass before that, and thus must
- * observe the store.
- *
- * For (2) we have a more intersting scenario. We enqueue ourselves using
- * xchg_tail(), which ends up being a RELEASE. This in itself is not
- * sufficient, however that is followed by an smp_cond_acquire() on the same
- * word, giving a RELEASE->ACQUIRE ordering. This again constrains our load and
- * guarantees we must observe that store.
- *
- * Therefore both cases have other !0 state that is observable before the
- * unordered locked byte store comes through. This means we can use that to
- * wait for the lock store, and then wait for an unlock.
- */
-#ifndef queued_spin_unlock_wait
-void queued_spin_unlock_wait(struct qspinlock *lock)
-{
-	u32 val;
-
-	for (;;) {
-		val = atomic_read(&lock->val);
-
-		if (!val) /* not locked, we're done */
-			goto done;
-
-		if (val & _Q_LOCKED_MASK) /* locked, go wait for unlock */
-			break;
-
-		/* not locked, but pending, wait until we observe the lock */
-		cpu_relax();
-	}
-
-	/* any unlock is good */
-	while (atomic_read(&lock->val) & _Q_LOCKED_MASK)
-		cpu_relax();
-
-done:
-	smp_acquire__after_ctrl_dep();
-}
-EXPORT_SYMBOL(queued_spin_unlock_wait);
-#endif
-
 #endif /* _GEN_PV_LOCK_SLOWPATH */
 
 /**
-- 
2.5.2
