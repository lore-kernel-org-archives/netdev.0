From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 15/26] ia64: Remove spin_unlock_wait() arch-specific definitions
Date: Thu, 29 Jun 2017 17:01:23 -0700
Message-ID: <1498780894-8253-15-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Tony Luck <tony.luck@intel.com>,
        Fenghua Yu <fenghua.yu@intel.com>, <linux-ia64@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:48358 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751650AbdF3ABp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 20:01:45 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5TNx4LJ043128
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 20:01:44 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bd6t3ad24-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 20:01:44 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Thu, 29 Jun 2017 20:01:42 -0400
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: <linux-ia64@vger.kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/ia64/include/asm/spinlock.h | 21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/arch/ia64/include/asm/spinlock.h b/arch/ia64/include/asm/spinlock.h
index ca9e76149a4a..df2c121164b8 100644
--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -76,22 +76,6 @@ static __always_inline void __ticket_spin_unlock(arch_spinlock_t *lock)
 	ACCESS_ONCE(*p) = (tmp + 2) & ~1;
 }
 
-static __always_inline void __ticket_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	int	*p = (int *)&lock->lock, ticket;
-
-	ia64_invala();
-
-	for (;;) {
-		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(ticket) : "r"(p) : "memory");
-		if (!(((ticket >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
-			return;
-		cpu_relax();
-	}
-
-	smp_acquire__after_ctrl_dep();
-}
-
 static inline int __ticket_spin_is_locked(arch_spinlock_t *lock)
 {
 	long tmp = ACCESS_ONCE(lock->lock);
@@ -143,11 +127,6 @@ static __always_inline void arch_spin_lock_flags(arch_spinlock_t *lock,
 	arch_spin_lock(lock);
 }
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	__ticket_spin_unlock_wait(lock);
-}
-
 #define arch_read_can_lock(rw)		(*(volatile int *)(rw) >= 0)
 #define arch_write_can_lock(rw)	(*(volatile int *)(rw) == 0)
 
-- 
2.5.2
