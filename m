From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 05/26] exit: Replace spin_unlock_wait() with lock/unlock pair
Date: Thu, 29 Jun 2017 17:01:13 -0700
Message-ID: <1498780894-8253-5-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Ingo Molnar <mingo@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics, and
it appears that all callers could do just as well with a lock/unlock pair.
This commit therefore replaces the spin_unlock_wait() call in do_exit()
with spin_lock() followed immediately by spin_unlock().  This should be
safe from a performance perspective because the lock is a per-task lock,
and this is happening only at task-exit time.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 kernel/exit.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 516acdb0e0ec..1a976e47ddd1 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -832,7 +832,8 @@ void __noreturn do_exit(long code)
 	 * Ensure that we must observe the pi_state in exit_mm() ->
 	 * mm_release() -> exit_pi_state_list().
 	 */
-	raw_spin_unlock_wait(&tsk->pi_lock);
+	raw_spin_lock(&tsk->pi_lock);
+	raw_spin_unlock(&tsk->pi_lock);
 
 	if (unlikely(in_atomic())) {
 		pr_info("note: %s[%d] exited with preempt_count %d\n",
-- 
2.5.2

