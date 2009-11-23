From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance hints
Date: Sun, 22 Nov 2009 22:46:30 -0800
Message-ID: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29493 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938AbZKWHHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 02:07:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a new CPU mask for SMP systems to the irq_desc
struct.  It also exposes an API for underlying device drivers to
assist irqbalance in making smarter decisions when balancing, especially
in a NUMA environment.  For example, an ethernet driver with MSI-X may
wish to limit the CPUs that an interrupt can be balanced within to
stay on a single NUMA node.  Current irqbalance operation can move the
interrupt off the node, resulting in cross-node memory accesses and
locks.

The API is a get/set API within the kernel, along with a /proc entry
for the interrupt.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/interrupt.h |    8 ++++++
 include/linux/irq.h       |    2 ++
 kernel/irq/manage.c       |   32 +++++++++++++++++++++++++
 kernel/irq/proc.c         |   57 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 75f3f00..9fd08aa 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -208,6 +208,8 @@ extern cpumask_var_t irq_default_affinity;
 extern int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask);
 extern int irq_can_set_affinity(unsigned int irq);
 extern int irq_select_affinity(unsigned int irq);
+extern int irq_set_node_affinity(unsigned int irq,
+                                 const struct cpumask *cpumask);
 
 #else /* CONFIG_SMP */
 
@@ -223,6 +225,12 @@ static inline int irq_can_set_affinity(unsigned int irq)
 
 static inline int irq_select_affinity(unsigned int irq)  { return 0; }
 
+static inline int irq_set_node_affinity(unsigned int irq,
+                                        const struct cpumask *m)
+{
+	return -EINVAL;
+}
+
 #endif /* CONFIG_SMP && CONFIG_GENERIC_HARDIRQS */
 
 #ifdef CONFIG_GENERIC_HARDIRQS
diff --git a/include/linux/irq.h b/include/linux/irq.h
index ae9653d..26d7d07 100644
--- a/include/linux/irq.h
+++ b/include/linux/irq.h
@@ -166,6 +166,7 @@ struct irq_2_iommu;
  * @lock:		locking for SMP
  * @affinity:		IRQ affinity on SMP
  * @node:		node index useful for balancing
+ * @node_affinity:	irq mask hints for irqbalance
  * @pending_mask:	pending rebalanced interrupts
  * @threads_active:	number of irqaction threads currently running
  * @wait_for_threads:	wait queue for sync_irq to wait for threaded handlers
@@ -196,6 +197,7 @@ struct irq_desc {
 #ifdef CONFIG_SMP
 	cpumask_var_t		affinity;
 	unsigned int		node;
+	cpumask_var_t		node_affinity;
 #ifdef CONFIG_GENERIC_PENDING_IRQ
 	cpumask_var_t		pending_mask;
 #endif
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 7305b29..9e80783 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -138,6 +138,38 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
 	return 0;
 }
 
+/**
+ *	irq_set_node_affinity - Set the CPU mask this interrupt can run on
+ *	@irq:		Interrupt to modify
+ *	@cpumask:	CPU mask to assign to the interrupt
+ *
+ */
+int irq_set_node_affinity(unsigned int irq, const struct cpumask *cpumask)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	unsigned long flags;
+
+	spin_lock_irqsave(&desc->lock, flags);
+	cpumask_copy(desc->node_affinity, cpumask);
+	spin_unlock_irqrestore(&desc->lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL(irq_set_node_affinity);
+
+/**
+ *	irq_get_node_affinity - Get the CPU mask this interrupt can run on
+ *	@irq:		Interrupt to get information
+ *
+ */
+struct cpumask *irq_get_node_affinity(unsigned int irq)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+
+	return desc->node_affinity;
+}
+EXPORT_SYMBOL(irq_get_node_affinity);
+
 #ifndef CONFIG_AUTO_IRQ_AFFINITY
 /*
  * Generic version of the affinity autoselector.
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 0832145..192e3fb 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -31,6 +31,16 @@ static int irq_affinity_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int irq_node_affinity_proc_show(struct seq_file *m, void *v)
+{
+	struct irq_desc *desc = irq_to_desc((long)m->private);
+	const struct cpumask *mask = desc->node_affinity;
+
+	seq_cpumask(m, mask);
+	seq_putc(m, '\n');
+	return 0;
+}
+
 #ifndef is_affinity_mask_valid
 #define is_affinity_mask_valid(val) 1
 #endif
@@ -78,11 +88,46 @@ free_cpumask:
 	return err;
 }
 
+static ssize_t irq_node_affinity_proc_write(struct file *file,
+		const char __user *buffer, size_t count, loff_t *pos)
+{
+	unsigned int irq = (int)(long)PDE(file->f_path.dentry->d_inode)->data;
+	cpumask_var_t new_value;
+	int err;
+
+	if (no_irq_affinity || irq_balancing_disabled(irq))
+		return -EIO;
+
+	if (!alloc_cpumask_var(&new_value, GFP_KERNEL))
+		return -ENOMEM;
+
+	err = cpumask_parse_user(buffer, count, new_value);
+	if (err)
+		goto free_cpumask;
+
+	if (!is_affinity_mask_valid(new_value)) {
+		err = -EINVAL;
+		goto free_cpumask;
+	}
+
+	irq_set_node_affinity(irq, new_value);
+	err = count;
+
+free_cpumask:
+	free_cpumask_var(new_value);
+	return err;
+}
+
 static int irq_affinity_proc_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, irq_affinity_proc_show, PDE(inode)->data);
 }
 
+static int irq_node_affinity_proc_open(struct inode *inode, struct file *f)
+{
+	return single_open(f, irq_node_affinity_proc_show, PDE(inode)->data);
+}
+
 static const struct file_operations irq_affinity_proc_fops = {
 	.open		= irq_affinity_proc_open,
 	.read		= seq_read,
@@ -91,6 +136,14 @@ static const struct file_operations irq_affinity_proc_fops = {
 	.write		= irq_affinity_proc_write,
 };
 
+static const struct file_operations irq_node_affinity_proc_fops = {
+	.open		= irq_node_affinity_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+	.write		= irq_node_affinity_proc_write,
+};
+
 static int default_affinity_show(struct seq_file *m, void *v)
 {
 	seq_cpumask(m, irq_default_affinity);
@@ -230,6 +283,10 @@ void register_irq_proc(unsigned int irq, struct irq_desc *desc)
 	/* create /proc/irq/<irq>/smp_affinity */
 	proc_create_data("smp_affinity", 0600, desc->dir,
 			 &irq_affinity_proc_fops, (void *)(long)irq);
+
+	/* create /proc/irq/<irq>/node_affinity */
+	proc_create_data("node_affinity", 0600, desc->dir,
+	                 &irq_node_affinity_proc_fops, (void *)(long)irq);
 #endif
 
 	proc_create_data("spurious", 0444, desc->dir,

