From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 1/5] genirq: Add IRQ affinity notifiers
Date: Fri, 19 Nov 2010 18:44:35 +0000
Message-ID: <1290192275.2671.39.camel@bwh-desktop>
References: <1290192176.2671.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23175 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756343Ab0KSSoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 13:44:39 -0500
In-Reply-To: <1290192176.2671.38.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When initiating I/O on a multiqueue and multi-IRQ device, we may want
to select a queue for which the response will be handled on the same
or a nearby CPU.  This requires a reverse-map of IRQ affinity.  Add a
notification mechanism to support this.

This is based closely on work by Thomas Gleixner <tglx@linutronix.de>.
---
 include/linux/interrupt.h |   41 +++++++++++++++++++++++
 include/linux/irqdesc.h   |    3 ++
 kernel/irq/manage.c       |   81 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 125 insertions(+), 0 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 79d0c4f..1649b30 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -14,6 +14,8 @@
 #include <linux/smp.h>
 #include <linux/percpu.h>
 #include <linux/hrtimer.h>
+#include <linux/kref.h>
+#include <linux/workqueue.h>
 
 #include <asm/atomic.h>
 #include <asm/ptrace.h>
@@ -231,6 +233,28 @@ static inline void resume_device_irqs(void) { };
 static inline int check_wakeup_irqs(void) { return 0; }
 #endif
 
+/**
+ * struct irq_affinity_notify - context for notification of IRQ affinity changes
+ * @irq:		Interrupt to which notification applies
+ * @kref:		Reference count, for internal use
+ * @work:		Work item, for internal use
+ * @notify:		Function to be called on change.  This will be
+ *			called in process context.
+ * @release:		Function to be called on release.  This will be
+ *			called in process context.  Once registered, the
+ *			structure must only be freed when this function is
+ *			called or later.
+ */
+struct irq_affinity_notify {
+        unsigned int irq;
+        struct kref kref;
+#if defined(CONFIG_SMP) && defined(CONFIG_GENERIC_HARDIRQS)
+        struct work_struct work;
+#endif
+        void (*notify)(struct irq_affinity_notify *, const cpumask_t *mask);
+        void (*release)(struct kref *ref);
+};
+
 #if defined(CONFIG_SMP) && defined(CONFIG_GENERIC_HARDIRQS)
 
 extern cpumask_var_t irq_default_affinity;
@@ -240,6 +264,13 @@ extern int irq_can_set_affinity(unsigned int irq);
 extern int irq_select_affinity(unsigned int irq);
 
 extern int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m);
+extern int
+irq_set_affinity_notifier(unsigned int irq, struct irq_affinity_notify *notify);
+
+static inline void irq_run_affinity_notifiers(void)
+{
+	flush_scheduled_work();
+}
 #else /* CONFIG_SMP */
 
 static inline int irq_set_affinity(unsigned int irq, const struct cpumask *m)
@@ -259,6 +290,16 @@ static inline int irq_set_affinity_hint(unsigned int irq,
 {
 	return -EINVAL;
 }
+
+static inline int
+irq_set_affinity_notifier(unsigned int irq, struct irq_affinity_notify *notify)
+{
+	return 0;
+}
+
+static inline void irq_run_affinity_notifiers(void)
+{
+}
 #endif /* CONFIG_SMP && CONFIG_GENERIC_HARDIRQS */
 
 #ifdef CONFIG_GENERIC_HARDIRQS
diff --git a/include/linux/irqdesc.h b/include/linux/irqdesc.h
index 979c68c..5e0d2e4 100644
--- a/include/linux/irqdesc.h
+++ b/include/linux/irqdesc.h
@@ -8,6 +8,7 @@
  * For now it's included from <linux/irq.h>
  */
 
+struct irq_affinity_notify;
 struct proc_dir_entry;
 struct timer_rand_state;
 /**
@@ -24,6 +25,7 @@ struct timer_rand_state;
  * @last_unhandled:	aging timer for unhandled count
  * @irqs_unhandled:	stats field for spurious unhandled interrupts
  * @lock:		locking for SMP
+ * @affinity_notify:	context for notification of affinity changes
  * @pending_mask:	pending rebalanced interrupts
  * @threads_active:	number of irqaction threads currently running
  * @wait_for_threads:	wait queue for sync_irq to wait for threaded handlers
@@ -70,6 +72,7 @@ struct irq_desc {
 	raw_spinlock_t		lock;
 #ifdef CONFIG_SMP
 	const struct cpumask	*affinity_hint;
+	struct irq_affinity_notify *affinity_notify;
 #ifdef CONFIG_GENERIC_PENDING_IRQ
 	cpumask_var_t		pending_mask;
 #endif
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 5f92acc..82b48d0 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -134,6 +134,10 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
 		irq_set_thread_affinity(desc);
 	}
 #endif
+	if (desc->affinity_notify) {
+		kref_get(&desc->affinity_notify->kref);
+		schedule_work(&desc->affinity_notify->work);
+	}
 	desc->status |= IRQ_AFFINITY_SET;
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
 	return 0;
@@ -155,6 +159,79 @@ int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m)
 }
 EXPORT_SYMBOL_GPL(irq_set_affinity_hint);
 
+static void irq_affinity_notify(struct work_struct *work)
+{
+	struct irq_affinity_notify *notify =
+		container_of(work, struct irq_affinity_notify, work);
+	struct irq_desc *desc = irq_to_desc(notify->irq);
+	cpumask_var_t cpumask;
+	unsigned long flags;
+
+	if (!desc)
+		goto out;
+
+	if (!alloc_cpumask_var(&cpumask, GFP_KERNEL))
+		goto out;
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+#ifdef CONFIG_GENERIC_PENDING_IRQ
+	if (desc->status & IRQ_MOVE_PENDING)
+		cpumask_copy(cpumask, desc->pending_mask);
+	else
+#endif
+		cpumask_copy(cpumask, desc->affinity);
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	notify->notify(notify, cpumask);
+
+	free_cpumask_var(cpumask);
+out:
+	kref_put(&notify->kref, notify->release);
+}
+
+/**
+ *	irq_set_affinity_notifier - control notification of IRQ affinity changes
+ *	@irq:		Interrupt for which to enable/disable notification
+ *	@notify:	Context for notification, or %NULL to disable
+ *			notification.  Function pointers must be initialised;
+ *			the other fields will be initialised by this function.
+ *
+ *	Must be called in process context.  Notification may only be enabled
+ *	after the IRQ is allocated but before it is bound with request_irq()
+ *	and must be disabled before the IRQ is freed using free_irq().
+ */
+int
+irq_set_affinity_notifier(unsigned int irq, struct irq_affinity_notify *notify)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	struct irq_affinity_notify *old_notify;
+	unsigned long flags;
+
+	/* The release function is promised process context */
+	might_sleep();
+
+	if (!desc)
+		return -EINVAL;
+
+	/* Complete initialisation of *notify */
+	if (notify) {
+		notify->irq = irq;
+		kref_init(&notify->kref);
+		INIT_WORK(&notify->work, irq_affinity_notify);
+	}
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+	old_notify = desc->affinity_notify;
+	desc->affinity_notify = notify;
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	if (old_notify)
+		kref_put(&old_notify->kref, old_notify->release);
+	
+	return 0;
+}
+EXPORT_SYMBOL_GPL(irq_set_affinity_notifier);
+
 #ifndef CONFIG_AUTO_IRQ_AFFINITY
 /*
  * Generic version of the affinity autoselector.
@@ -1002,6 +1079,10 @@ void free_irq(unsigned int irq, void *dev_id)
 	if (!desc)
 		return;
 
+#ifdef CONFIG_SMP
+	BUG_ON(desc->affinity_notify);
+#endif
+
 	chip_bus_lock(desc);
 	kfree(__free_irq(irq, dev_id));
 	chip_bus_sync_unlock(desc);
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

