From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 12/26] arm64: Remove spin_unlock_wait() arch-specific
 definitions
Date: Thu, 29 Jun 2017 17:01:20 -0700
Message-ID: <1498780894-8253-12-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, parri.andrea@gmail.com, dave@stgolabs.net,
 manfred@colorfullife.com, arnd@arndb.de, peterz@infradead.org,
 netdev@vger.kernel.org, will.deacon@arm.com, oleg@redhat.com, mingo@redhat.com,
 netfilter-devel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>,
 tj@kernel.org, stern@rowland.harvard.edu, akpm@linux-foundation.org,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, torvalds@linux-foundation.org,
 linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: <linux-arm-kernel@lists.infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/arm64/include/asm/spinlock.h | 58 ++++-----------------------------------
 1 file changed, 5 insertions(+), 53 deletions(-)

diff --git a/arch/arm64/include/asm/spinlock.h b/arch/arm64/include/asm/spinlock.h
index cae331d553f8..f445bd7f2b9f 100644
--- a/arch/arm64/include/asm/spinlock.h
+++ b/arch/arm64/include/asm/spinlock.h
@@ -26,58 +26,6 @@
  * The memory barriers are implicit with the load-acquire and store-release
  * instructions.
  */
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	unsigned int tmp;
-	arch_spinlock_t lockval;
-	u32 owner;
-
-	/*
-	 * Ensure prior spin_lock operations to other locks have completed
-	 * on this CPU before we test whether "lock" is locked.
-	 */
-	smp_mb();
-	owner = READ_ONCE(lock->owner) << 16;
-
-	asm volatile(
-"	sevl\n"
-"1:	wfe\n"
-"2:	ldaxr	%w0, %2\n"
-	/* Is the lock free? */
-"	eor	%w1, %w0, %w0, ror #16\n"
-"	cbz	%w1, 3f\n"
-	/* Lock taken -- has there been a subsequent unlock->lock transition? */
-"	eor	%w1, %w3, %w0, lsl #16\n"
-"	cbz	%w1, 1b\n"
-	/*
-	 * The owner has been updated, so there was an unlock->lock
-	 * transition that we missed. That means we can rely on the
-	 * store-release of the unlock operation paired with the
-	 * load-acquire of the lock operation to publish any of our
-	 * previous stores to the new lock owner and therefore don't
-	 * need to bother with the writeback below.
-	 */
-"	b	4f\n"
-"3:\n"
-	/*
-	 * Serialise against any concurrent lockers by writing back the
-	 * unlocked lock value
-	 */
-	ARM64_LSE_ATOMIC_INSN(
-	/* LL/SC */
-"	stxr	%w1, %w0, %2\n"
-	__nops(2),
-	/* LSE atomics */
-"	mov	%w1, %w0\n"
-"	cas	%w0, %w0, %2\n"
-"	eor	%w1, %w1, %w0\n")
-	/* Somebody else wrote to the lock, GOTO 10 and reload the value */
-"	cbnz	%w1, 2b\n"
-"4:"
-	: "=&r" (lockval), "=&r" (tmp), "+Q" (*lock)
-	: "r" (owner)
-	: "memory");
-}
 
 #define arch_spin_lock_flags(lock, flags) arch_spin_lock(lock)
 
@@ -176,7 +124,11 @@ static inline int arch_spin_value_unlocked(arch_spinlock_t lock)
 
 static inline int arch_spin_is_locked(arch_spinlock_t *lock)
 {
-	smp_mb(); /* See arch_spin_unlock_wait */
+	/*
+	 * Ensure prior spin_lock operations to other locks have completed
+	 * on this CPU before we test whether "lock" is locked.
+	 */
+	smp_mb(); /* ^^^ */
 	return !arch_spin_value_unlocked(READ_ONCE(*lock));
 }
 
-- 
2.5.2
