From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 03/26] sched: Replace spin_unlock_wait() with lock/unlock pair
Date: Thu, 29 Jun 2017 17:01:11 -0700
Message-ID: <1498780894-8253-3-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore replaces the spin_unlock_wait() call in
do_task_dead() with spin_lock() followed immediately by spin_unlock().
This should be safe from a performance perspective because the lock is
this tasks ->pi_lock, and this is called only after the task exits.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 kernel/sched/core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index e91138fcde86..6dea3d9728c8 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3461,7 +3461,8 @@ void __noreturn do_task_dead(void)
 	 * is held by try_to_wake_up()
 	 */
 	smp_mb();
-	raw_spin_unlock_wait(&current->pi_lock);
+	raw_spin_lock(&current->pi_lock);
+	raw_spin_unlock(&current->pi_lock);
 
 	/* Causes final put_task_struct in finish_task_switch(): */
 	__set_current_state(TASK_DEAD);
-- 
2.5.2
