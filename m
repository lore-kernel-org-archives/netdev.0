From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Wed, 24 Sep 2008 00:42:47 -0700 (PDT)
Message-ID: <20080924.004247.193721529.davem@davemloft.net>
References: <20080919.234824.223177211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbYIXHm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 03:42:59 -0400
In-Reply-To: <20080919.234824.223177211.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 19 Sep 2008 23:48:24 -0700 (PDT)

> Jens Axboe has written some hacks for the block layer that allow
> queueing softirq work to remote cpus.  In the context of the block
> layer he used this facility to trigger the softirq block I/O
> completion on the same cpu where the I/O was submitted.

As a followup to this, I've refreshed my patches and put them
in a tree cloned from Linus's current GIT tree:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/softirq-2.6.git

I made minor touchups to the second patch, such as adding a few more
descriptive comments, and adding the missing export of the softirq_work
list array.

Updated version below for reference:

softirq: Add support for triggering softirq work on softirqs.

This is basically a genericization of Jens Axboe's block layer
remote softirq changes.

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 include/linux/interrupt.h |   21 +++++++
 include/linux/smp.h       |    4 +-
 kernel/softirq.c          |  129 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 153 insertions(+), 1 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index fdd7b90..0a7a14b 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -11,6 +11,8 @@
 #include <linux/hardirq.h>
 #include <linux/sched.h>
 #include <linux/irqflags.h>
+#include <linux/smp.h>
+#include <linux/percpu.h>
 #include <asm/atomic.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
@@ -272,6 +274,25 @@ extern void softirq_init(void);
 extern void raise_softirq_irqoff(unsigned int nr);
 extern void raise_softirq(unsigned int nr);
 
+/* This is the worklist that queues up per-cpu softirq work.
+ *
+ * send_remote_sendirq() adds work to these lists, and
+ * the softirq handler itself dequeues from them.  The queues
+ * are protected by disabling local cpu interrupts and they must
+ * only be accessed by the local cpu that they are for.
+ */
+DECLARE_PER_CPU(struct list_head [NR_SOFTIRQ], softirq_work_list);
+
+/* Try to send a softirq to a remote cpu.  If this cannot be done, the
+ * work will be queued to the local cpu.
+ */
+extern void send_remote_softirq(struct call_single_data *cp, int cpu, int softirq);
+
+/* Like send_remote_softirq(), but the caller must disable local cpu interrupts
+ * and compute the current cpu, passed in as 'this_cpu'.
+ */
+extern void __send_remote_softirq(struct call_single_data *cp, int cpu,
+				  int this_cpu, int softirq);
 
 /* Tasklets --- multithreaded analogue of BHs.
 
diff --git a/include/linux/smp.h b/include/linux/smp.h
index 66484d4..2e4d58b 100644
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -7,6 +7,7 @@
  */
 
 #include <linux/errno.h>
+#include <linux/types.h>
 #include <linux/list.h>
 #include <linux/cpumask.h>
 
@@ -16,7 +17,8 @@ struct call_single_data {
 	struct list_head list;
 	void (*func) (void *info);
 	void *info;
-	unsigned int flags;
+	u16 flags;
+	u16 priv;
 };
 
 #ifdef CONFIG_SMP
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 27642a2..77aba5e 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -6,6 +6,8 @@
  *	Distribute under GPLv2.
  *
  *	Rewritten. Old one was good in 2.2, but in 2.3 it was immoral. --ANK (990903)
+ *
+ *	Remote softirq infrastructure is by Jens Axboe.
  */
 
 #include <linux/module.h>
@@ -463,17 +465,144 @@ void tasklet_kill(struct tasklet_struct *t)
 
 EXPORT_SYMBOL(tasklet_kill);
 
+DEFINE_PER_CPU(struct list_head [NR_SOFTIRQ], softirq_work_list);
+EXPORT_PER_CPU_SYMBOL(softirq_work_list);
+
+static void __local_trigger(struct call_single_data *cp, int softirq)
+{
+	struct list_head *head = &__get_cpu_var(softirq_work_list[softirq]);
+
+	list_add_tail(&cp->list, head);
+
+	/* Trigger the softirq only if the list was previously empty.  */
+	if (head->next == &cp->list)
+		raise_softirq_irqoff(softirq);
+}
+
+#ifdef CONFIG_USE_GENERIC_SMP_HELPERS
+static void remote_softirq_receive(void *data)
+{
+	struct call_single_data *cp = data;
+	unsigned long flags;
+	int softirq;
+
+	softirq = cp->priv;
+
+	local_irq_save(flags);
+	__local_trigger(cp, softirq);
+	local_irq_restore(flags);
+}
+
+static int __try_remote_softirq(struct call_single_data *cp, int cpu, int softirq)
+{
+	if (cpu_online(cpu)) {
+		cp->func = remote_softirq_receive;
+		cp->info = cp;
+		cp->flags = 0;
+		cp->priv = softirq;
+
+		__smp_call_function_single(cpu, cp);
+		return 0;
+	}
+	return 1;
+}
+#else /* CONFIG_USE_GENERIC_SMP_HELPERS */
+static int __try_remote_softirq(struct call_single_data *cp, int cpu, int softirq)
+{
+	return 1;
+}
+#endif
+
+/**
+ * __send_remote_softirq - try to schedule softirq work on a remote cpu
+ * @cp: private SMP call function data area
+ * @cpu: the remote cpu
+ * @this_cpu: the currently executing cpu
+ * @softirq: the softirq for the work
+ *
+ * Attempt to schedule softirq work on a remote cpu.  If this cannot be
+ * done, the work is instead queued up on the local cpu.
+ *
+ * Interrupts must be disabled.
+ */
+void __send_remote_softirq(struct call_single_data *cp, int cpu, int this_cpu, int softirq)
+{
+	if (cpu == this_cpu || __try_remote_softirq(cp, cpu, softirq))
+		__local_trigger(cp, softirq);
+}
+EXPORT_SYMBOL(__send_remote_softirq);
+
+/**
+ * send_remote_softirq - try to schedule softirq work on a remote cpu
+ * @cp: private SMP call function data area
+ * @cpu: the remote cpu
+ * @softirq: the softirq for the work
+ *
+ * Like __send_remote_softirq except that disabling interrupts and
+ * computing the current cpu is done for the caller.
+ */
+void send_remote_softirq(struct call_single_data *cp, int cpu, int softirq)
+{
+	unsigned long flags;
+	int this_cpu;
+
+	local_irq_save(flags);
+	this_cpu = smp_processor_id();
+	__send_remote_softirq(cp, cpu, this_cpu, softirq);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(send_remote_softirq);
+
+static int __cpuinit remote_softirq_cpu_notify(struct notifier_block *self,
+					       unsigned long action, void *hcpu)
+{
+	/*
+	 * If a CPU goes away, splice its entries to the current CPU
+	 * and trigger a run of the softirq
+	 */
+	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
+		int cpu = (unsigned long) hcpu;
+		int i;
+
+		local_irq_disable();
+		for (i = 0; i < NR_SOFTIRQ; i++) {
+			struct list_head *head = &per_cpu(softirq_work_list[i], cpu);
+			struct list_head *local_head;
+
+			if (list_empty(head))
+				continue;
+
+			local_head = &__get_cpu_var(softirq_work_list[i]);
+			list_splice_init(head, local_head);
+			raise_softirq_irqoff(i);
+		}
+		local_irq_enable();
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block __cpuinitdata remote_softirq_cpu_notifier = {
+	.notifier_call	= remote_softirq_cpu_notify,
+};
+
 void __init softirq_init(void)
 {
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
+		int i;
+
 		per_cpu(tasklet_vec, cpu).tail =
 			&per_cpu(tasklet_vec, cpu).head;
 		per_cpu(tasklet_hi_vec, cpu).tail =
 			&per_cpu(tasklet_hi_vec, cpu).head;
+		for (i = 0; i < NR_SOFTIRQ; i++)
+			INIT_LIST_HEAD(&per_cpu(softirq_work_list[i], cpu));
 	}
 
+	register_hotcpu_notifier(&remote_softirq_cpu_notifier);
+
 	open_softirq(TASKLET_SOFTIRQ, tasklet_action);
 	open_softirq(HI_SOFTIRQ, tasklet_hi_action);
 }
-- 
1.5.6.5


