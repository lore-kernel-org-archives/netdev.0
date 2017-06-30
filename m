From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 18/26] mips: Remove spin_unlock_wait() arch-specific definitions
Date: Thu, 29 Jun 2017 17:01:26 -0700
Message-ID: <1498780894-8253-18-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Ralf Baechle <ralf@linux-mips.org>, <linux-mips@linux-mips.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: <linux-mips@linux-mips.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/mips/include/asm/spinlock.h | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/arch/mips/include/asm/spinlock.h b/arch/mips/include/asm/spinlock.h
index a8df44d60607..81b4945031ee 100644
--- a/arch/mips/include/asm/spinlock.h
+++ b/arch/mips/include/asm/spinlock.h
@@ -50,22 +50,6 @@ static inline int arch_spin_value_unlocked(arch_spinlock_t lock)
 
 #define arch_spin_lock_flags(lock, flags) arch_spin_lock(lock)
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	u16 owner = READ_ONCE(lock->h.serving_now);
-	smp_rmb();
-	for (;;) {
-		arch_spinlock_t tmp = READ_ONCE(*lock);
-
-		if (tmp.h.serving_now == tmp.h.ticket ||
-		    tmp.h.serving_now != owner)
-			break;
-
-		cpu_relax();
-	}
-	smp_acquire__after_ctrl_dep();
-}
-
 static inline int arch_spin_is_contended(arch_spinlock_t *lock)
 {
 	u32 counters = ACCESS_ONCE(lock->lock);
-- 
2.5.2
