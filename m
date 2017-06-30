From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 25/26] tile: Remove spin_unlock_wait() arch-specific definitions
Date: Thu, 29 Jun 2017 17:01:33 -0700
Message-ID: <1498780894-8253-25-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Chris Metcalf <cmetcalf@mellanox.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/tile/include/asm/spinlock_32.h |  2 --
 arch/tile/include/asm/spinlock_64.h |  2 --
 arch/tile/lib/spinlock_32.c         | 23 -----------------------
 arch/tile/lib/spinlock_64.c         | 22 ----------------------
 4 files changed, 49 deletions(-)

diff --git a/arch/tile/include/asm/spinlock_32.h b/arch/tile/include/asm/spinlock_32.h
index b14b1ba5bf9c..cba8ba9b8da6 100644
--- a/arch/tile/include/asm/spinlock_32.h
+++ b/arch/tile/include/asm/spinlock_32.h
@@ -64,8 +64,6 @@ static inline void arch_spin_unlock(arch_spinlock_t *lock)
 	lock->current_ticket = old_ticket + TICKET_QUANTUM;
 }
 
-void arch_spin_unlock_wait(arch_spinlock_t *lock);
-
 /*
  * Read-write spinlocks, allowing multiple readers
  * but only one writer.
diff --git a/arch/tile/include/asm/spinlock_64.h b/arch/tile/include/asm/spinlock_64.h
index b9718fb4e74a..9a2c2d605752 100644
--- a/arch/tile/include/asm/spinlock_64.h
+++ b/arch/tile/include/asm/spinlock_64.h
@@ -58,8 +58,6 @@ static inline void arch_spin_unlock(arch_spinlock_t *lock)
 	__insn_fetchadd4(&lock->lock, 1U << __ARCH_SPIN_CURRENT_SHIFT);
 }
 
-void arch_spin_unlock_wait(arch_spinlock_t *lock);
-
 void arch_spin_lock_slow(arch_spinlock_t *lock, u32 val);
 
 /* Grab the "next" ticket number and bump it atomically.
diff --git a/arch/tile/lib/spinlock_32.c b/arch/tile/lib/spinlock_32.c
index 076c6cc43113..db9333f2447c 100644
--- a/arch/tile/lib/spinlock_32.c
+++ b/arch/tile/lib/spinlock_32.c
@@ -62,29 +62,6 @@ int arch_spin_trylock(arch_spinlock_t *lock)
 }
 EXPORT_SYMBOL(arch_spin_trylock);
 
-void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	u32 iterations = 0;
-	int curr = READ_ONCE(lock->current_ticket);
-	int next = READ_ONCE(lock->next_ticket);
-
-	/* Return immediately if unlocked. */
-	if (next == curr)
-		return;
-
-	/* Wait until the current locker has released the lock. */
-	do {
-		delay_backoff(iterations++);
-	} while (READ_ONCE(lock->current_ticket) == curr);
-
-	/*
-	 * The TILE architecture doesn't do read speculation; therefore
-	 * a control dependency guarantees a LOAD->{LOAD,STORE} order.
-	 */
-	barrier();
-}
-EXPORT_SYMBOL(arch_spin_unlock_wait);
-
 /*
  * The low byte is always reserved to be the marker for a "tns" operation
  * since the low bit is set to "1" by a tns.  The next seven bits are
diff --git a/arch/tile/lib/spinlock_64.c b/arch/tile/lib/spinlock_64.c
index a4b5b2cbce93..de414c22892f 100644
--- a/arch/tile/lib/spinlock_64.c
+++ b/arch/tile/lib/spinlock_64.c
@@ -62,28 +62,6 @@ int arch_spin_trylock(arch_spinlock_t *lock)
 }
 EXPORT_SYMBOL(arch_spin_trylock);
 
-void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	u32 iterations = 0;
-	u32 val = READ_ONCE(lock->lock);
-	u32 curr = arch_spin_current(val);
-
-	/* Return immediately if unlocked. */
-	if (arch_spin_next(val) == curr)
-		return;
-
-	/* Wait until the current locker has released the lock. */
-	do {
-		delay_backoff(iterations++);
-	} while (arch_spin_current(READ_ONCE(lock->lock)) == curr);
-
-	/*
-	 * The TILE architecture doesn't do read speculation; therefore
-	 * a control dependency guarantees a LOAD->{LOAD,STORE} order.
-	 */
-	barrier();
-}
-EXPORT_SYMBOL(arch_spin_unlock_wait);
 
 /*
  * If the read lock fails due to a writer, we retry periodically
-- 
2.5.2
