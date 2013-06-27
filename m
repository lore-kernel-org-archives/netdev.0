From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 11/45] sched/core: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Fri, 28 Jun 2013 01:24:25 +0530
Message-ID: <20130627195425.29830.3829.stgit@srivatsabhat.in.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/sched/core.c |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 9b1f2e5..9d870bf 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1160,11 +1160,11 @@ void kick_process(struct task_struct *p)
 {
 	int cpu;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpu = task_cpu(p);
 	if ((cpu != smp_processor_id()) && task_curr(p))
 		smp_send_reschedule(cpu);
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 EXPORT_SYMBOL_GPL(kick_process);
 #endif /* CONFIG_SMP */
@@ -1172,6 +1172,9 @@ EXPORT_SYMBOL_GPL(kick_process);
 #ifdef CONFIG_SMP
 /*
  * ->cpus_allowed is protected by both rq->lock and p->pi_lock
+ *
+ *  Must be called within get/put_online_cpus_atomic(), to prevent
+ *  CPUs from going offline from under us.
  */
 static int select_fallback_rq(int cpu, struct task_struct *p)
 {
@@ -1245,6 +1248,9 @@ out:
 
 /*
  * The caller (fork, wakeup) owns p->pi_lock, ->cpus_allowed is stable.
+ *
+ * Must be called within get/put_online_cpus_atomic(), to prevent
+ * CPUs from going offline from under us.
  */
 static inline
 int select_task_rq(struct task_struct *p, int sd_flags, int wake_flags)
@@ -1489,6 +1495,8 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	unsigned long flags;
 	int cpu, success = 0;
 
+	get_online_cpus_atomic();
+
 	smp_wmb();
 	raw_spin_lock_irqsave(&p->pi_lock, flags);
 	if (!(p->state & state))
@@ -1531,6 +1539,7 @@ stat:
 out:
 	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
 
+	put_online_cpus_atomic();
 	return success;
 }
 
@@ -1744,6 +1753,8 @@ void wake_up_new_task(struct task_struct *p)
 	unsigned long flags;
 	struct rq *rq;
 
+	get_online_cpus_atomic();
+
 	raw_spin_lock_irqsave(&p->pi_lock, flags);
 #ifdef CONFIG_SMP
 	/*
@@ -1766,6 +1777,8 @@ void wake_up_new_task(struct task_struct *p)
 		p->sched_class->task_woken(rq, p);
 #endif
 	task_rq_unlock(rq, p, &flags);
+
+	put_online_cpus_atomic();
 }
 
 #ifdef CONFIG_PREEMPT_NOTIFIERS
@@ -3879,6 +3892,8 @@ bool __sched yield_to(struct task_struct *p, bool preempt)
 	unsigned long flags;
 	int yielded = 0;
 
+	get_online_cpus_atomic();
+
 	local_irq_save(flags);
 	rq = this_rq();
 
@@ -3924,6 +3939,8 @@ out_unlock:
 out_irq:
 	local_irq_restore(flags);
 
+	put_online_cpus_atomic();
+
 	if (yielded > 0)
 		schedule();
 
@@ -4324,9 +4341,11 @@ static int migration_cpu_stop(void *data)
 	 * The original target cpu might have gone down and we might
 	 * be on another cpu but it doesn't matter.
 	 */
+	get_online_cpus_atomic();
 	local_irq_disable();
 	__migrate_task(arg->task, raw_smp_processor_id(), arg->dest_cpu);
 	local_irq_enable();
+	put_online_cpus_atomic();
 	return 0;
 }
 

