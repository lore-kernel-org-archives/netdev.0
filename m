From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 02/26] task_work: Replace spin_unlock_wait() with lock/unlock pair
Date: Thu, 29 Jun 2017 17:01:10 -0700
Message-ID: <1498780894-8253-2-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore replaces the spin_unlock_wait() call in
task_work_run() with spin_lock() followed immediately by spin_unlock().
This should be safe from a performance perspective because calls to the
other side of the race, task_work_cancel(), should be rare.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 kernel/task_work.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/task_work.c b/kernel/task_work.c
index d513051fcca2..b9b428832229 100644
--- a/kernel/task_work.c
+++ b/kernel/task_work.c
@@ -109,7 +109,8 @@ void task_work_run(void)
 		 * the first entry == work, cmpxchg(task_works) should
 		 * fail, but it can play with *work and other entries.
 		 */
-		raw_spin_unlock_wait(&task->pi_lock);
+		raw_spin_lock(&task->pi_lock);
+		raw_spin_unlock(&task->pi_lock);
 
 		do {
 			next = work->next;
-- 
2.5.2
