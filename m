From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 15/45] sched/rt: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Fri, 28 Jun 2013 01:24:59 +0530
Message-ID: <20130627195458.29830.25978.stgit@srivatsabhat.in.ibm.com>
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

 kernel/sched/rt.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/kernel/sched/rt.c b/kernel/sched/rt.c
index 01970c8..03d9f38 100644
--- a/kernel/sched/rt.c
+++ b/kernel/sched/rt.c
@@ -6,6 +6,7 @@
 #include "sched.h"
 
 #include <linux/slab.h>
+#include <linux/cpu.h>
 
 int sched_rr_timeslice = RR_TIMESLICE;
 
@@ -28,7 +29,9 @@ static enum hrtimer_restart sched_rt_period_timer(struct hrtimer *timer)
 		if (!overrun)
 			break;
 
+		get_online_cpus_atomic();
 		idle = do_sched_rt_period_timer(rt_b, overrun);
+		put_online_cpus_atomic();
 	}
 
 	return idle ? HRTIMER_NORESTART : HRTIMER_RESTART;
@@ -547,6 +550,7 @@ static int do_balance_runtime(struct rt_rq *rt_rq)
 	int i, weight, more = 0;
 	u64 rt_period;
 
+	get_online_cpus_atomic();
 	weight = cpumask_weight(rd->span);
 
 	raw_spin_lock(&rt_b->rt_runtime_lock);
@@ -588,6 +592,7 @@ next:
 		raw_spin_unlock(&iter->rt_runtime_lock);
 	}
 	raw_spin_unlock(&rt_b->rt_runtime_lock);
+	put_online_cpus_atomic();
 
 	return more;
 }
@@ -1168,6 +1173,10 @@ static void yield_task_rt(struct rq *rq)
 #ifdef CONFIG_SMP
 static int find_lowest_rq(struct task_struct *task);
 
+/*
+ * Must be called within get/put_online_cpus_atomic(), to prevent CPUs
+ * from going offline from under us.
+ */
 static int
 select_task_rq_rt(struct task_struct *p, int sd_flag, int flags)
 {
@@ -1561,6 +1570,8 @@ retry:
 		return 0;
 	}
 
+	get_online_cpus_atomic();
+
 	/* We might release rq lock */
 	get_task_struct(next_task);
 
@@ -1611,6 +1622,7 @@ retry:
 out:
 	put_task_struct(next_task);
 
+	put_online_cpus_atomic();
 	return ret;
 }
 
@@ -1630,6 +1642,7 @@ static int pull_rt_task(struct rq *this_rq)
 	if (likely(!rt_overloaded(this_rq)))
 		return 0;
 
+	get_online_cpus_atomic();
 	for_each_cpu(cpu, this_rq->rd->rto_mask) {
 		if (this_cpu == cpu)
 			continue;
@@ -1695,6 +1708,7 @@ skip:
 		double_unlock_balance(this_rq, src_rq);
 	}
 
+	put_online_cpus_atomic();
 	return ret;
 }
 

