From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH linux-next v3 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 13:23:43 -0700
Message-ID: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, davem@davemloft.net, arjan@linux.jf.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21041 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756344Ab0D3UPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 16:15:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a cpumask affinity hint to the irq_desc
structure, along with a registration function and a read-only
proc entry for each interrupt.

This affinity_hint handle for each interrupt can be used by
underlying drivers that need a better mechanism to control
interrupt affinity.  The underlying driver can register a
cpumask for the interrupt, which will allow the driver to
provide the CPU mask for the interrupt to anything that
requests it.  The intent is to extend the userspace daemon,
irqbalance, to help hint to it a preferred CPU mask to balance
the interrupt into.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/interrupt.h |    7 +++++++
 include/linux/irq.h       |    1 +
 kernel/irq/manage.c       |   19 +++++++++++++++++++
 kernel/irq/proc.c         |   42 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 75f3f00..4d1df9b 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -209,6 +209,8 @@ extern int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask);
 extern int irq_can_set_affinity(unsigned int irq);
 extern int irq_select_affinity(unsigned int irq);
 
+extern int irq_register_affinity_hint(unsigned int irq,
+                                      const struct cpumask *m);
 #else /* CONFIG_SMP */
 
 static inline int irq_set_affinity(unsigned int irq, const struct cpumask *m)
@@ -223,6 +225,11 @@ static inline int irq_can_set_affinity(unsigned int irq)
 
 static inline int irq_select_affinity(unsigned int irq)  { return 0; }
 
+static inline int irq_register_affinity_hint(unsigned int irq,
+                                             const struct cpumask *m)
+{
+	return -EINVAL;
+}
 #endif /* CONFIG_SMP && CONFIG_GENERIC_HARDIRQS */
 
 #ifdef CONFIG_GENERIC_HARDIRQS
diff --git a/include/linux/irq.h b/include/linux/irq.h
index 707ab12..83b16d7 100644
--- a/include/linux/irq.h
+++ b/include/linux/irq.h
@@ -206,6 +206,7 @@ struct irq_desc {
 	struct proc_dir_entry	*dir;
 #endif
 	const char		*name;
+	struct cpumask		*affinity_hint;
 } ____cacheline_internodealigned_in_smp;
 
 extern void arch_init_copy_chip_data(struct irq_desc *old_desc,
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 704e488..1354fc9 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -138,6 +138,22 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
 	return 0;
 }
 
+int irq_register_affinity_hint(unsigned int irq, const struct cpumask *m)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	unsigned long flags;
+
+	if (!desc)
+		return -EINVAL;
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+	desc->affinity_hint = m;
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(irq_register_affinity_hint);
+
 #ifndef CONFIG_AUTO_IRQ_AFFINITY
 /*
  * Generic version of the affinity autoselector.
@@ -916,6 +932,9 @@ static struct irqaction *__free_irq(unsigned int irq, void *dev_id)
 			desc->chip->disable(irq);
 	}
 
+	/* make sure affinity_hint is cleaned up */
+	desc->affinity_hint = NULL;
+
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
 
 	unregister_handler_proc(irq, action);
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 7a6eb04..1aa7939 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -32,6 +32,32 @@ static int irq_affinity_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
+{
+	struct irq_desc *desc = irq_to_desc((long)m->private);
+	unsigned long flags;
+	cpumask_var_t mask;
+	int ret = -EINVAL;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+	if (desc->affinity_hint) {
+		cpumask_copy(mask, desc->affinity_hint);
+		ret = 0;
+	}
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	if (!ret) {
+		seq_cpumask(m, mask);
+		seq_putc(m, '\n');
+	}
+	free_cpumask_var(mask);
+
+	return ret;
+}
+
 #ifndef is_affinity_mask_valid
 #define is_affinity_mask_valid(val) 1
 #endif
@@ -84,6 +110,11 @@ static int irq_affinity_proc_open(struct inode *inode, struct file *file)
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
@@ -92,6 +123,13 @@ static const struct file_operations irq_affinity_proc_fops = {
 	.write		= irq_affinity_proc_write,
 };
 
+static const struct file_operations irq_affinity_hint_proc_fops = {
+	.open		= irq_affinity_hint_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static int default_affinity_show(struct seq_file *m, void *v)
 {
 	seq_cpumask(m, irq_default_affinity);
@@ -231,6 +269,10 @@ void register_irq_proc(unsigned int irq, struct irq_desc *desc)
 	/* create /proc/irq/<irq>/smp_affinity */
 	proc_create_data("smp_affinity", 0600, desc->dir,
 			 &irq_affinity_proc_fops, (void *)(long)irq);
+
+	/* create /proc/irq/<irq>/affinity_hint */
+	proc_create_data("affinity_hint", 0400, desc->dir,
+			 &irq_affinity_hint_proc_fops, (void *)(long)irq);
 #endif
 
 	proc_create_data("spurious", 0444, desc->dir,

