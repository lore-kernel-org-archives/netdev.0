From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 10/45] smp,
 cpu hotplug: Fix on_each_cpu_*() to prevent CPU offline properly
Date: Tue, 22 Jan 2013 13:05:17 +0530
Message-ID: <20130122073515.13822.80220.stgit@srivatsabhat.in.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
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
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:40962 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636Ab3AVHhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 02:37:25 -0500
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 22 Jan 2013 17:32:11 +1000
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() to prevent CPUs from going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/smp.c |   25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/kernel/smp.c b/kernel/smp.c
index f421bcc..d870bfe 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -688,12 +688,12 @@ int on_each_cpu(void (*func) (void *info), void *info, int wait)
 	unsigned long flags;
 	int ret = 0;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	ret = smp_call_function(func, info, wait);
 	local_irq_save(flags);
 	func(info);
 	local_irq_restore(flags);
-	preempt_enable();
+	put_online_cpus_atomic();
 	return ret;
 }
 EXPORT_SYMBOL(on_each_cpu);
@@ -715,7 +715,11 @@ EXPORT_SYMBOL(on_each_cpu);
 void on_each_cpu_mask(const struct cpumask *mask, smp_call_func_t func,
 			void *info, bool wait)
 {
-	int cpu = get_cpu();
+	int cpu;
+
+	get_online_cpus_atomic();
+
+	cpu = smp_processor_id();
 
 	smp_call_function_many(mask, func, info, wait);
 	if (cpumask_test_cpu(cpu, mask)) {
@@ -723,7 +727,7 @@ void on_each_cpu_mask(const struct cpumask *mask, smp_call_func_t func,
 		func(info);
 		local_irq_enable();
 	}
-	put_cpu();
+	put_online_cpus_atomic();
 }
 EXPORT_SYMBOL(on_each_cpu_mask);
 
@@ -748,8 +752,9 @@ EXPORT_SYMBOL(on_each_cpu_mask);
  * The function might sleep if the GFP flags indicates a non
  * atomic allocation is allowed.
  *
- * Preemption is disabled to protect against CPUs going offline but not online.
- * CPUs going online during the call will not be seen or sent an IPI.
+ * We use get/put_online_cpus_atomic() to prevent CPUs from going
+ * offline in-between our operation. CPUs coming online during the
+ * call will not be seen or sent an IPI.
  *
  * You must not call this function with disabled interrupts or
  * from a hardware interrupt handler or from a bottom half handler.
@@ -764,26 +769,26 @@ void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
 	might_sleep_if(gfp_flags & __GFP_WAIT);
 
 	if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN)))) {
-		preempt_disable();
+		get_online_cpus_atomic();
 		for_each_online_cpu(cpu)
 			if (cond_func(cpu, info))
 				cpumask_set_cpu(cpu, cpus);
 		on_each_cpu_mask(cpus, func, info, wait);
-		preempt_enable();
+		put_online_cpus_atomic();
 		free_cpumask_var(cpus);
 	} else {
 		/*
 		 * No free cpumask, bother. No matter, we'll
 		 * just have to IPI them one by one.
 		 */
-		preempt_disable();
+		get_online_cpus_atomic();
 		for_each_online_cpu(cpu)
 			if (cond_func(cpu, info)) {
 				ret = smp_call_function_single(cpu, func,
 								info, wait);
 				WARN_ON_ONCE(!ret);
 			}
-		preempt_enable();
+		put_online_cpus_atomic();
 	}
 }
 EXPORT_SYMBOL(on_each_cpu_cond);
