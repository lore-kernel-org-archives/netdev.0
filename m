From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint callback
	framework
Date: Sun, 18 Apr 2010 21:57:41 -0700
Message-ID: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, davem@davemloft.net, arjan@linux.jf.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51841 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901Ab0DSEwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 00:52:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a callback function pointer to the irq_desc
structure, along with a registration function and a read-only
proc entry for each interrupt.

This affinity_hint handle for each interrupt can be used by
underlying drivers that need a better mechanism to control
interrupt affinity.  The underlying driver can register a
callback for the interrupt, which will allow the driver to
provide the CPU mask for the interrupt to anything that
requests it.  The intent is to extend the userspace daemon,
irqbalance, to help hint to it a preferred CPU mask to balance
the interrupt into.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/interrupt.h |   27 +++++++++++++++++++++++++++
 include/linux/irq.h       |    1 +
 kernel/irq/manage.c       |   39 +++++++++++++++++++++++++++++++++++++++
 kernel/irq/proc.c         |   41 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 108 insertions(+), 0 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 75f3f00..f2a7d0b 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -78,6 +78,8 @@ enum {
 };
 
 typedef irqreturn_t (*irq_handler_t)(int, void *);
+typedef unsigned int (*irq_affinity_hint_t)(cpumask_var_t, unsigned int,
+                                            void *);
 
 /**
  * struct irqaction - per interrupt action descriptor
@@ -105,6 +107,18 @@ struct irqaction {
 	unsigned long thread_flags;
 };
 
+/**
+ * struct irqaffinityhint - per interrupt affinity helper
+ * @callback:	device driver callback function
+ * @dev:	reference for the affected device
+ * @irq:	interrupt number
+ */
+struct irqaffinityhint {
+	irq_affinity_hint_t callback;
+	void *dev;
+	int irq;
+};
+
 extern irqreturn_t no_action(int cpl, void *dev_id);
 
 #ifdef CONFIG_GENERIC_HARDIRQS
@@ -209,6 +223,9 @@ extern int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask);
 extern int irq_can_set_affinity(unsigned int irq);
 extern int irq_select_affinity(unsigned int irq);
 
+extern int irq_register_affinity_hint(unsigned int irq, void *dev,
+                                      irq_affinity_hint_t callback);
+extern int irq_unregister_affinity_hint(unsigned int irq);
 #else /* CONFIG_SMP */
 
 static inline int irq_set_affinity(unsigned int irq, const struct cpumask *m)
@@ -223,6 +240,16 @@ static inline int irq_can_set_affinity(unsigned int irq)
 
 static inline int irq_select_affinity(unsigned int irq)  { return 0; }
 
+static inline int irq_register_affinity_hint(unsigned int irq, void *dev,
+                                             irq_affinity_hint_t callback)
+{
+	return -EINVAL;
+}
+
+static inline int irq_unregister_affinity_hint(unsigned int irq);
+{
+	return -EINVAL;
+}
 #endif /* CONFIG_SMP && CONFIG_GENERIC_HARDIRQS */
 
 #ifdef CONFIG_GENERIC_HARDIRQS
diff --git a/include/linux/irq.h b/include/linux/irq.h
index 707ab12..bd73e9b 100644
--- a/include/linux/irq.h
+++ b/include/linux/irq.h
@@ -206,6 +206,7 @@ struct irq_desc {
 	struct proc_dir_entry	*dir;
 #endif
 	const char		*name;
+	struct irqaffinityhint	*hint;
 } ____cacheline_internodealigned_in_smp;
 
 extern void arch_init_copy_chip_data(struct irq_desc *old_desc,
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 704e488..3674b6a 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -138,6 +138,42 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
 	return 0;
 }
 
+int irq_register_affinity_hint(unsigned int irq, void *dev,
+                               irq_affinity_hint_t callback)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	unsigned long flags;
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+
+	if (!desc->hint)
+		desc->hint = kmalloc(sizeof(struct irqaffinityhint),
+		                     GFP_KERNEL);
+	desc->hint->callback = callback;
+	desc->hint->dev = dev;
+	desc->hint->irq = irq;
+
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL(irq_register_affinity_hint);
+
+int irq_unregister_affinity_hint(unsigned int irq)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	unsigned long flags;
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+
+	kfree(desc->hint);
+	desc->hint = NULL;
+
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL(irq_unregister_affinity_hint);
 #ifndef CONFIG_AUTO_IRQ_AFFINITY
 /*
  * Generic version of the affinity autoselector.
@@ -916,6 +952,9 @@ static struct irqaction *__free_irq(unsigned int irq, void *dev_id)
 			desc->chip->disable(irq);
 	}
 
+	/* make sure affinity_hint callback is cleaned up */
+	kfree(desc->hint);
+
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
 
 	unregister_handler_proc(irq, action);
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 7a6eb04..59110a3 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -32,6 +32,23 @@ static int irq_affinity_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
+{
+	struct irq_desc *desc = irq_to_desc((long)m->private);
+	struct cpumask mask;
+	unsigned int ret = 0;
+
+	if (desc->hint && desc->hint->callback) {
+		ret = desc->hint->callback(&mask, (long)m->private,
+		                           desc->hint->dev);
+		if (!ret)
+			seq_cpumask(m, &mask);
+	}
+
+	seq_putc(m, '\n');
+	return ret;
+}
+
 #ifndef is_affinity_mask_valid
 #define is_affinity_mask_valid(val) 1
 #endif
@@ -79,11 +96,23 @@ free_cpumask:
 	return err;
 }
 
+static ssize_t irq_affinity_hint_proc_write(struct file *file,
+		const char __user *buffer, size_t count, loff_t *pos)
+{
+	/* affinity_hint is read-only from proc */
+	return -EOPNOTSUPP;
+}
+
 static int irq_affinity_proc_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, irq_affinity_proc_show, PDE(inode)->data);
 }
 
+static int irq_affinity_hint_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, irq_affinity_hint_proc_show, PDE(inode)->data);
+}
+
 static const struct file_operations irq_affinity_proc_fops = {
 	.open		= irq_affinity_proc_open,
 	.read		= seq_read,
@@ -92,6 +121,14 @@ static const struct file_operations irq_affinity_proc_fops = {
 	.write		= irq_affinity_proc_write,
 };
 
+static const struct file_operations irq_affinity_hint_proc_fops = {
+	.open		= irq_affinity_hint_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+	.write		= irq_affinity_hint_proc_write,
+};
+
 static int default_affinity_show(struct seq_file *m, void *v)
 {
 	seq_cpumask(m, irq_default_affinity);
@@ -231,6 +268,10 @@ void register_irq_proc(unsigned int irq, struct irq_desc *desc)
 	/* create /proc/irq/<irq>/smp_affinity */
 	proc_create_data("smp_affinity", 0600, desc->dir,
 			 &irq_affinity_proc_fops, (void *)(long)irq);
+
+	/* create /proc/irq/<irq>/affinity_hint */
+	proc_create_data("affinity_hint", 0400, desc->dir,
+			 &irq_affinity_hint_proc_fops, (void *)(long)irq);
 #endif
 
 	proc_create_data("spurious", 0444, desc->dir,

