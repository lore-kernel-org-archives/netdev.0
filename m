From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 10/46] smp,
 cpu hotplug: Fix smp_call_function_*() to prevent CPU offline properly
Date: Mon, 18 Feb 2013 18:09:37 +0530
Message-ID: <20130218123937.26245.44200.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() to prevent CPUs from going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/smp.c |   40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/kernel/smp.c b/kernel/smp.c
index 69f38bd..0f40d36 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -315,7 +315,8 @@ int smp_call_function_single(int cpu, smp_call_func_t func, void *info,
 	 * prevent preemption and reschedule on another processor,
 	 * as well as CPU removal
 	 */
-	this_cpu = get_cpu();
+	get_online_cpus_atomic();
+	this_cpu = smp_processor_id();
 
 	/*
 	 * Can deadlock when called with interrupts disabled.
@@ -347,7 +348,7 @@ int smp_call_function_single(int cpu, smp_call_func_t func, void *info,
 		}
 	}
 
-	put_cpu();
+	put_online_cpus_atomic();
 
 	return err;
 }
@@ -376,8 +377,10 @@ int smp_call_function_any(const struct cpumask *mask,
 	const struct cpumask *nodemask;
 	int ret;
 
+	get_online_cpus_atomic();
 	/* Try for same CPU (cheapest) */
-	cpu = get_cpu();
+	cpu = smp_processor_id();
+
 	if (cpumask_test_cpu(cpu, mask))
 		goto call;
 
@@ -393,7 +396,7 @@ int smp_call_function_any(const struct cpumask *mask,
 	cpu = cpumask_any_and(mask, cpu_online_mask);
 call:
 	ret = smp_call_function_single(cpu, func, info, wait);
-	put_cpu();
+	put_online_cpus_atomic();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(smp_call_function_any);
@@ -414,25 +417,28 @@ void __smp_call_function_single(int cpu, struct call_single_data *data,
 	unsigned int this_cpu;
 	unsigned long flags;
 
-	this_cpu = get_cpu();
+	get_online_cpus_atomic();
+
+	this_cpu = smp_processor_id();
+
 	/*
 	 * Can deadlock when called with interrupts disabled.
 	 * We allow cpu's that are not yet online though, as no one else can
 	 * send smp call function interrupt to this cpu and as such deadlocks
 	 * can't happen.
 	 */
-	WARN_ON_ONCE(cpu_online(smp_processor_id()) && wait && irqs_disabled()
+	WARN_ON_ONCE(cpu_online(this_cpu) && wait && irqs_disabled()
 		     && !oops_in_progress);
 
 	if (cpu == this_cpu) {
 		local_irq_save(flags);
 		data->func(data->info);
 		local_irq_restore(flags);
-	} else {
+	} else if ((unsigned)cpu < nr_cpu_ids && cpu_online(cpu)) {
 		csd_lock(data);
 		generic_exec_single(cpu, data, wait);
 	}
-	put_cpu();
+	put_online_cpus_atomic();
 }
 
 /**
@@ -456,6 +462,8 @@ void smp_call_function_many(const struct cpumask *mask,
 	unsigned long flags;
 	int refs, cpu, next_cpu, this_cpu = smp_processor_id();
 
+	get_online_cpus_atomic();
+
 	/*
 	 * Can deadlock when called with interrupts disabled.
 	 * We allow cpu's that are not yet online though, as no one else can
@@ -472,17 +480,18 @@ void smp_call_function_many(const struct cpumask *mask,
 
 	/* No online cpus?  We're done. */
 	if (cpu >= nr_cpu_ids)
-		return;
+		goto out_unlock;
 
 	/* Do we have another CPU which isn't us? */
 	next_cpu = cpumask_next_and(cpu, mask, cpu_online_mask);
 	if (next_cpu == this_cpu)
-		next_cpu = cpumask_next_and(next_cpu, mask, cpu_online_mask);
+		next_cpu = cpumask_next_and(next_cpu, mask,
+						cpu_online_mask);
 
 	/* Fastpath: do that cpu by itself. */
 	if (next_cpu >= nr_cpu_ids) {
 		smp_call_function_single(cpu, func, info, wait);
-		return;
+		goto out_unlock;
 	}
 
 	data = &__get_cpu_var(cfd_data);
@@ -528,7 +537,7 @@ void smp_call_function_many(const struct cpumask *mask,
 	/* Some callers race with other cpus changing the passed mask */
 	if (unlikely(!refs)) {
 		csd_unlock(&data->csd);
-		return;
+		goto out_unlock;
 	}
 
 	/*
@@ -565,6 +574,9 @@ void smp_call_function_many(const struct cpumask *mask,
 	/* Optionally wait for the CPUs to complete */
 	if (wait)
 		csd_lock_wait(&data->csd);
+
+out_unlock:
+	put_online_cpus_atomic();
 }
 EXPORT_SYMBOL(smp_call_function_many);
 
@@ -585,9 +597,9 @@ EXPORT_SYMBOL(smp_call_function_many);
  */
 int smp_call_function(smp_call_func_t func, void *info, int wait)
 {
-	preempt_disable();
+	get_online_cpus_atomic();
 	smp_call_function_many(cpu_online_mask, func, info, wait);
-	preempt_enable();
+	put_online_cpus_atomic();
 
 	return 0;
 }
