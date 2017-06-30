From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 21/26] powerpc: Remove spin_unlock_wait() arch-specific
 definitions
Date: Thu, 29 Jun 2017 17:01:29 -0700
Message-ID: <1498780894-8253-21-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: linux-arch@vger.kernel.org, parri.andrea@gmail.com, dave@stgolabs.net,
 manfred@colorfullife.com, arnd@arndb.de, peterz@infradead.org,
 netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, will.deacon@arm.com,
 oleg@redhat.com, mingo@redhat.com, netfilter-devel@vger.kernel.org,
 tj@kernel.org, stern@rowland.harvard.edu, akpm@linux-foundation.org,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, torvalds@linux-foundation.org,
 Paul Mackerras <paulus@samba.org>
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: <linuxppc-dev@lists.ozlabs.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/powerpc/include/asm/spinlock.h | 33 ---------------------------------
 1 file changed, 33 deletions(-)

diff --git a/arch/powerpc/include/asm/spinlock.h b/arch/powerpc/include/asm/spinlock.h
index 8c1b913de6d7..d256e448ea49 100644
--- a/arch/powerpc/include/asm/spinlock.h
+++ b/arch/powerpc/include/asm/spinlock.h
@@ -170,39 +170,6 @@ static inline void arch_spin_unlock(arch_spinlock_t *lock)
 	lock->slock = 0;
 }
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	arch_spinlock_t lock_val;
-
-	smp_mb();
-
-	/*
-	 * Atomically load and store back the lock value (unchanged). This
-	 * ensures that our observation of the lock value is ordered with
-	 * respect to other lock operations.
-	 */
-	__asm__ __volatile__(
-"1:	" PPC_LWARX(%0, 0, %2, 0) "\n"
-"	stwcx. %0, 0, %2\n"
-"	bne- 1b\n"
-	: "=&r" (lock_val), "+m" (*lock)
-	: "r" (lock)
-	: "cr0", "xer");
-
-	if (arch_spin_value_unlocked(lock_val))
-		goto out;
-
-	while (lock->slock) {
-		HMT_low();
-		if (SHARED_PROCESSOR)
-			__spin_yield(lock);
-	}
-	HMT_medium();
-
-out:
-	smp_mb();
-}
-
 /*
  * Read-write spinlocks, allowing multiple readers
  * but only one writer.
-- 
2.5.2
