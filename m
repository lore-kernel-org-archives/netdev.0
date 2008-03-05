From: therbert@google.com (Tom Herbert)
Subject: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
Message-ID: <20080305205116.5989A412541@localhost>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:9578 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbYCEUvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:51:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements kernel changes to allow scheduling of softirq's between processors.

Signed-off-by: Tom Herbert <therbert@google.com>

---

diff -uprN -X /tmp/donts/si_1 net-2.6/include/linux/interrupt.h net-2.6.patch/include/linux/interrupt.h
--- net-2.6/include/linux/interrupt.h	2008-03-05 09:03:21.033991000 -0800
+++ net-2.6.patch/include/linux/interrupt.h	2008-03-05 09:34:48.010014000 -0800
@@ -247,6 +247,9 @@ static inline void __deprecated save_and
 enum
 {
 	HI_SOFTIRQ=0,
+#ifdef CONFIG_SMP
+	SEND_CPU_SOFTIRQ,
+#endif
 	TIMER_SOFTIRQ,
 	NET_TX_SOFTIRQ,
 	NET_RX_SOFTIRQ,
@@ -276,6 +279,13 @@ extern void softirq_init(void);
 extern void raise_softirq_irqoff(unsigned int nr);
 extern void raise_softirq(unsigned int nr);
 
+#ifdef CONFIG_SMP
+DECLARE_PER_CPU(atomic_t, alt_softirqs);
+
+extern void raise_softirq_oncpu(int cpu, unsigned int nr);
+extern void or_alt_softirqs_pending_irqoff(void);
+extern void or_alt_softirqs_pending(void);
+#endif
 
 /* Tasklets --- multithreaded analogue of BHs.
 
diff -uprN -X /tmp/donts/si_1 net-2.6/include/linux/smp.h net-2.6.patch/include/linux/smp.h
--- net-2.6/include/linux/smp.h	2008-03-05 09:03:23.150865000 -0800
+++ net-2.6.patch/include/linux/smp.h	2008-03-05 09:25:33.530753000 -0800
@@ -33,6 +33,21 @@ extern void smp_send_stop(void);
  */
 extern void smp_send_reschedule(int cpu);
 
+/*
+ * sends a 'reschedule' event to multiple CPUs in mask:
+ */
+#ifdef ARCH_HAS_SEND_RESCHEDULE_MASK
+extern void smp_send_reschedule_mask(cpumask_t mask);
+#else
+static inline void smp_send_reschedule_mask(cpumask_t mask)
+{
+	int cpu;
+
+	for_each_cpu_mask(cpu, mask) {
+		smp_send_reschedule(cpu);
+	}
+}
+#endif
 
 /*
  * Prepare machine for booting other CPUs.
diff -uprN -X /tmp/donts/si_1 net-2.6/kernel/softirq.c net-2.6.patch/kernel/softirq.c
--- net-2.6/kernel/softirq.c	2008-03-05 09:03:26.407673000 -0800
+++ net-2.6.patch/kernel/softirq.c	2008-03-05 09:36:33.849334000 -0800
@@ -16,6 +16,7 @@
 #include <linux/notifier.h>
 #include <linux/percpu.h>
 #include <linux/cpu.h>
+#include <linux/cpumask.h>
 #include <linux/freezer.h>
 #include <linux/kthread.h>
 #include <linux/rcupdate.h>
@@ -352,6 +353,62 @@ void open_softirq(int nr, void (*action)
 	softirq_vec[nr].action = action;
 }
 
+#ifdef CONFIG_SMP
+/*
+ * Functions and definitions to support scheduling of softirqs between CPU's.
+ */
+
+DEFINE_PER_CPU(atomic_t, alt_softirqs);
+static DEFINE_PER_CPU(cpumask_t, softirq_cpus);
+
+static void send_cpu_softirq_action(struct softirq_action *a)
+{
+	cpumask_t mask;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	mask = __get_cpu_var(softirq_cpus);
+	cpus_clear(__get_cpu_var(softirq_cpus));
+	local_irq_restore(flags);
+
+	/*
+	 * Wake up CPUs by sending them a reschedule event.  This is
+	 * usually implemented by an IPI.
+	 */
+	if (!cpus_empty(mask))
+		smp_send_reschedule_mask(mask);
+}
+
+void raise_softirq_oncpu(int cpu, unsigned int nr)
+{
+	if (cpu == get_cpu())
+		raise_softirq(nr);
+	else if (!test_and_set_bit(nr, &per_cpu(alt_softirqs, cpu))) {
+		cpu_set(cpu, __get_cpu_var(softirq_cpus));
+		raise_softirq(SEND_CPU_SOFTIRQ);
+	}
+}
+
+
+inline void or_alt_softirqs_pending_irqoff(void)
+{
+	__u32 pending;
+
+	pending = atomic_xchg(&__get_cpu_var(alt_softirqs), 0);
+	or_softirq_pending(pending);
+}
+
+
+void or_alt_softirqs_pending(void)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	or_alt_softirqs_pending_irqoff();
+	local_irq_restore(flags);
+}
+#endif /* CONFIG_SMP */
+
 /* Tasklets */
 struct tasklet_head
 {
@@ -488,6 +545,9 @@ void __init softirq_init(void)
 {
 	open_softirq(TASKLET_SOFTIRQ, tasklet_action, NULL);
 	open_softirq(HI_SOFTIRQ, tasklet_hi_action, NULL);
+#ifdef CONFIG_SMP
+	open_softirq(SEND_CPU_SOFTIRQ, send_cpu_softirq_action, NULL);
+#endif
 }
 
 static int ksoftirqd(void * __bind_cpu)
