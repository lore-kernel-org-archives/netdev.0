From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH linux-next v2 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 01:51:54 -0700
Message-ID: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, davem@davemloft.net, arjan@linux.jf.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

 include/linux/interrupt.h |   13 +++++++++++++
 include/linux/irq.h       |    1 +
 kernel/irq/manage.c       |   28 ++++++++++++++++++++++++++++
 kernel/irq/proc.c         |   33 +++++++++++++++++++++++++++++++++
 4 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 75f3f00..9c9ea2a 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -209,6 +209,9 @@ extern int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask);
 extern int irq_can_set_affinity(unsigned int irq);
 extern int irq_select_affinity(unsigned int irq);
 
+extern int irq_register_affinity_hint(unsigned int irq,
+                                      const struct cpumask *m);
+extern int irq_unregister_affinity_hint(unsigned int irq);
 #else /* CONFIG_SMP */
 
 static inline int irq_set_affinity(unsigned int irq, const struct cpumask *m)
@@ -223,6 +226,16 @@ static inline int irq_can_set_affinity(unsigned int irq)
 
 static inline int irq_select_affinity(unsigned int irq)  { return 0; }
 
+static inline int irq_register_affinity_hint(unsigned int irq,
+                                             const struct cpumask *m)
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
index 704e488..bce7e38 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -138,6 +138,31 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
 	return 0;
 }
 
+int irq_register_affinity_hint(unsigned int irq, const struct cpumask *m)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	unsigned long flags;
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+	desc->affinity_hint = m;
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
+	desc->affinity_hint = NULL;
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL(irq_unregister_affinity_hint);
 #ifndef CONFIG_AUTO_IRQ_AFFINITY
 /*
  * Generic version of the affinity autoselector.
@@ -916,6 +941,9 @@ static struct irqaction *__free_irq(unsigned int irq, void *dev_id)
 			desc->chip->disable(irq);
 	}
 
+	/* make sure affinity_hint is cleaned up */
+	desc->affinity_hint = NULL;
+
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
 
 	unregister_handler_proc(irq, action);
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 7a6eb04..8b85f77 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -32,6 +32,23 @@ static int irq_affinity_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
+{
+	struct irq_desc *desc = irq_to_desc((long)m->private);
+	unsigned long flags;
+	int ret = -EINVAL;
+
+	raw_spin_lock_irqsave(&desc->lock, flags);
+	if (desc->affinity_hint) {
+		seq_cpumask(m, desc->affinity_hint);
+		seq_putc(m, '\n');
+		ret = 0;
+	}
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+
+	return ret;
+}
+
 #ifndef is_affinity_mask_valid
 #define is_affinity_mask_valid(val) 1
 #endif
@@ -84,6 +101,11 @@ static int irq_affinity_proc_open(struct inode *inode, struct file *file)
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
@@ -92,6 +114,13 @@ static const struct file_operations irq_affinity_proc_fops = {
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
@@ -231,6 +260,10 @@ void register_irq_proc(unsigned int irq, struct irq_desc *desc)
 	/* create /proc/irq/<irq>/smp_affinity */
 	proc_create_data("smp_affinity", 0600, desc->dir,
 			 &irq_affinity_proc_fops, (void *)(long)irq);
+
+	/* create /proc/irq/<irq>/affinity_hint */
+	proc_create_data("affinity_hint", 0400, desc->dir,
+			 &irq_affinity_hint_proc_fops, (void *)(long)irq);
 #endif
 
 	proc_create_data("spurious", 0444, desc->dir,
