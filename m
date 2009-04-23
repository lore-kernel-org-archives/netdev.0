From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC] v1 expedited "big hammer" RCU grace periods
Date: Wed, 22 Apr 2009 22:25:20 -0700
Message-ID: <20090423052520.GA13036@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:35981 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369AbZDWFZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 01:25:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First cut of "big hammer" expedited RCU grace periods, but only for
rcu_bh.  This creates another softirq vector, so that entering this
softirq vector will have forced an rcu_bh quiescent state (as noted by
Dave Miller).  Use smp_call_function() to invoke raise_softirq() on all
CPUs in order to cause this to happen.  Track the CPUs that have passed
through a quiescent state (or gone offline) with a cpumask.

Does nothing to expedite callbacks already registered with call_rcu_bh(),
but there is no need to.

Shortcomings:

o	Untested, probably does not compile, not for inclusion.

o	Does not handle rcu, only rcu_bh.

Thoughts?

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 include/linux/interrupt.h |    1 
 include/linux/rcupdate.h  |    1 
 kernel/rcupdate.c         |  106 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 108 insertions(+)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 91bb76f..b7b58cc 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -338,6 +338,7 @@ enum
 	TASKLET_SOFTIRQ,
 	SCHED_SOFTIRQ,
 	HRTIMER_SOFTIRQ,
+	RCU_EXPEDITED_SOFTIRQ,
 	RCU_SOFTIRQ,	/* Preferable RCU should always be the last softirq */
 
 	NR_SOFTIRQS
diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 15fbb3c..d4af557 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -264,6 +264,7 @@ extern void synchronize_rcu(void);
 extern void rcu_barrier(void);
 extern void rcu_barrier_bh(void);
 extern void rcu_barrier_sched(void);
+extern void synchronize_rcu_bh_expedited(void);
 
 /* Internal to kernel */
 extern void rcu_init(void);
diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
index a967c9f..bfa98dd 100644
--- a/kernel/rcupdate.c
+++ b/kernel/rcupdate.c
@@ -217,10 +217,116 @@ static int __cpuinit rcu_barrier_cpu_hotplug(struct notifier_block *self,
 	return NOTIFY_OK;
 }
 
+static DEFINE_MUTEX(synchronize_rcu_bh_mutex);
+static long synchronize_rcu_bh_completed; /* Expedited-grace-period count. */
+
+#ifndef CONFIG_SMP
+
+static void __init synchronize_rcu_expedited_init(void)
+{
+}
+
+void synchronize_rcu_bh_expedited(void)
+{
+	mutex_lock(&synchronize_rcu_bh_mutex);
+	synchronize_rcu_bh_completed++;
+	mutex_unlock(&synchronize_rcu_bh_mutex);
+}
+
+#else /* #ifndef CONFIG_SMP */
+
+static DEFINE_PER_CPU(int, rcu_bh_need_qs);
+static cpumask_var_t rcu_bh_waiting_map;
+
+static void synchronize_rcu_bh_expedited_help(struct softirq_action *unused)
+{
+	if (__get_cpu_var(rcu_bh_need_qs)) {
+		smp_mb();
+		__get_cpu_var(rcu_bh_need_qs) = 0;
+		smp_mb();
+	}
+}
+
+static void rcu_bh_fast_qs(void *unused)
+{
+	raise_softirq(RCU_EXPEDITED_SOFTIRQ);
+}
+
+static void __init synchronize_rcu_expedited_init(void)
+{
+	open_softirq(RCU_EXPEDITED_SOFTIRQ, synchronize_rcu_bh_expedited_help);
+	alloc_bootmem_cpumask_var(&rcu_bh_waiting_map);
+}
+
+void synchronize_rcu_bh_expedited(void)
+{
+	int cpu;
+	int done;
+	int times = 0;
+
+	mutex_lock(&synchronize_rcu_bh_mutex);
+
+	/* Take snapshot of online CPUs, blocking CPU hotplug. */
+	preempt_disable();
+	cpumask_copy(rcu_bh_waiting_map, &cpu_online_map);
+	preempt_enable();
+
+	/* Mark each online CPU as needing a quiescent state. */
+	for_each_cpu(cpu, rcu_bh_waiting_map)
+		per_cpu(rcu_bh_need_qs, cpu) = 1;
+
+	/* Call for a quiescent state on each online CPU. */
+	preempt_disable();
+	cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
+	smp_call_function(rcu_bh_fast_qs, NULL, 1);
+	preempt_enable();
+
+	/*
+	 * Loop waiting for each CPU to either pass through a quiescent
+	 * state or to go offline.  We don't care which.
+	 */
+	for (;;) {
+		
+		/* Ignore CPUs that have gone offline, blocking CPU hotplug. */
+		preempt_disable();
+		cpumask_and(rcu_bh_waiting_map, rcu_bh_waiting_map,
+			    &cpu_online_map);
+		cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
+		preempt_enable();
+
+		/* Check if any CPUs still need a quiescent state. */
+		done = 1;
+		for_each_cpu(cpu, rcu_bh_waiting_map) {
+			if (per_cpu(rcu_bh_need_qs, cpu)) {
+				done = 0;
+				break;
+			}
+			cpumask_clear_cpu(cpu, rcu_bh_waiting_map);
+		}
+		if (done)
+			break;
+
+		/*
+		 * Wait a bit.  If we have already waited a fair
+		 * amount of time, sleep.
+		 */
+		if (++times < 10)
+			udelay(10 * times);
+		else
+			schedule_timeout_uninterruptible(1);
+	}
+
+	synchronize_rcu_bh_completed++;
+	mutex_unlock(&synchronize_rcu_bh_mutex);
+}
+
+#endif /* #else #ifndef CONFIG_SMP */
+
 void __init rcu_init(void)
 {
 	__rcu_init();
 	hotcpu_notifier(rcu_barrier_cpu_hotplug, 0);
+	synchronize_rcu_expedited_init();
 }
 
 void rcu_scheduler_starting(void)
