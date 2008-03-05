From: therbert@google.com (Tom Herbert)
Subject: RFC [PATCH net-2.6 2/6] net: Changes to x86_64 for softirq scheduling
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
Message-ID: <20080305205116.5B86741278F@localhost>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:19844 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707AbYCEUvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:51:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches includes changes to x86_64 to support scheduling of softirq's between CPUs.

Signed-off-by: Tom Herbert <therbert@google.com>

---

diff -uprN -X /tmp/donts/si_2 net-2.6/arch/x86/kernel/smp_64.c net-2.6.patch/arch/x86/kernel/smp_64.c
--- net-2.6/arch/x86/kernel/smp_64.c	2008-03-05 09:02:22.768649000 -0800
+++ net-2.6.patch/arch/x86/kernel/smp_64.c	2008-03-05 09:25:33.403752000 -0800
@@ -296,6 +296,15 @@ void smp_send_reschedule(int cpu)
 }
 
 /*
+ * this function sends a 'reschedule' IPI to multiple
+ * CPUs in the mask.
+ */
+void smp_send_reschedule_mask(cpumask_t mask)
+{
+	send_IPI_mask(mask, RESCHEDULE_VECTOR);
+}
+
+/*
  * Structure and data for smp_call_function(). This is designed to minimise
  * static memory requirements. It also looks cleaner.
  */
@@ -494,11 +503,20 @@ void smp_send_stop(void)
  * Reschedule call back. Nothing to do,
  * all the work is done automatically when
  * we return from the interrupt.
+ * Reschedule call back.  Process rescheduling is done
+ * automatically on return from interrupt.  Also, 'or' into
+ * local_softirq_pending any softirq scheduling requests sent
+ * from other CPUs, these softirq's will execute in irq_exit.
  */
 asmlinkage void smp_reschedule_interrupt(void)
 {
 	ack_APIC_irq();
+
+	exit_idle();
+	irq_enter();
+	or_alt_softirqs_pending_irqoff();
 	add_pda(irq_resched_count, 1);
+	irq_exit();
 }
 
 asmlinkage void smp_call_function_interrupt(void)
diff -uprN -X /tmp/donts/si_2 net-2.6/include/asm-x86/smp_64.h net-2.6.patch/include/asm-x86/smp_64.h
--- net-2.6/include/asm-x86/smp_64.h	2008-03-05 09:03:19.005115000 -0800
+++ net-2.6.patch/include/asm-x86/smp_64.h	2008-03-05 09:27:32.532262000 -0800
@@ -74,6 +74,9 @@ static inline int num_booting_cpus(void)
 }
 
 extern void smp_send_reschedule(int cpu);
+extern void smp_send_reschedule_mask(cpumask_t mask);
+#define       ARCH_HAS_SEND_RESCHEDULE_MASK
+
 
 #else /* CONFIG_SMP */
 
