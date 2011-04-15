From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/3] irq: Add registered affinity guidance infrastructure
Date: Fri, 15 Apr 2011 16:17:55 -0400
Message-ID: <1302898677-3833-2-git-send-email-nhorman@tuxdriver.com>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, nhorman <nhorman@devel2.think-freely.org>,
	Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51323 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab1DOUTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:19:04 -0400
In-Reply-To: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nhorman <nhorman@devel2.think-freely.org>

This patch adds the needed data to the irq_desc struct, as well as the needed
API calls to allow the requester of an irq to register a handler function to
determine the affinity_hint of that irq when queried from user space.

Signed-offy-by: Neil Horman <nhorman@tuxdriver.com>

CC: Dimitris Michailidis <dm@chelsio.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: David Howells <dhowells@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 include/linux/interrupt.h |   38 +++++++++++++++++++++++++++++++++++++-
 include/linux/irq.h       |    9 +++++++++
 include/linux/irqdesc.h   |    4 ++++
 kernel/irq/Kconfig        |   12 +++++++++++-
 kernel/irq/manage.c       |   39 +++++++++++++++++++++++++++++++++++++++
 kernel/irq/proc.c         |   35 +++++++++++++++++++++++++++++++++++
 6 files changed, 135 insertions(+), 2 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 59b72ca..6edb364 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -118,6 +118,17 @@ struct irqaction {
 } ____cacheline_internodealigned_in_smp;
 
 extern irqreturn_t no_action(int cpl, void *dev_id);
+#ifdef CONFIG_AFFINITY_UPDATE
+extern int setup_affinity_data(int irq, irq_affinity_init_t, void *);
+#else
+static inline int setup_affinity_data(int irq,
+				      irq_affinity_init_t init, void *d)
+{
+	return 0;
+}
+#endif
+
+extern void free_irq(unsigned int, void *);
 
 #ifdef CONFIG_GENERIC_HARDIRQS
 extern int __must_check
@@ -125,6 +136,32 @@ request_threaded_irq(unsigned int irq, irq_handler_t handler,
 		     irq_handler_t thread_fn,
 		     unsigned long flags, const char *name, void *dev);
 
+#ifdef CONFIG_AFFINITY_UPDATE
+static inline int __must_check
+request_affinity_irq(unsigned int irq, irq_handler_t handler,
+		     irq_handler_t thread_fn,
+		     unsigned long flags, const char *name, void *dev,
+		     irq_affinity_init_t af_init, void *af_priv)
+{
+	int rc;
+
+	rc = request_threaded_irq(irq, handler, thread_fn, flags, name, dev);
+	if (rc)
+		goto out;
+
+	if (af_init)
+		rc = setup_affinity_data(irq, af_init, af_priv);
+	if (rc)
+		free_irq(irq, dev);
+
+out:
+	return rc;
+}
+#else
+#define request_affinity_irq(irq, hnd, tfn, flg, nm, dev, init, priv) \
+	request_threaded_irq(irq, hnd, NULL, flg, nm, dev)
+#endif
+
 static inline int __must_check
 request_irq(unsigned int irq, irq_handler_t handler, unsigned long flags,
 	    const char *name, void *dev)
@@ -167,7 +204,6 @@ request_any_context_irq(unsigned int irq, irq_handler_t handler,
 static inline void exit_irq_thread(void) { }
 #endif
 
-extern void free_irq(unsigned int, void *);
 
 struct device;
 
diff --git a/include/linux/irq.h b/include/linux/irq.h
index 1d3577f..4bff14f 100644
--- a/include/linux/irq.h
+++ b/include/linux/irq.h
@@ -30,6 +30,15 @@
 
 struct irq_desc;
 struct irq_data;
+struct affin_data {
+	void *priv;
+	char *affinity_alg;
+	void (*affin_update)(int irq, struct affin_data *ad);
+	void (*affin_cleanup)(int irq, struct affin_data *ad);
+};
+
+typedef int (*irq_affinity_init_t)(int, struct affin_data*, void *);
+
 typedef	void (*irq_flow_handler_t)(unsigned int irq,
 					    struct irq_desc *desc);
 typedef	void (*irq_preflow_handler_t)(struct irq_data *data);
diff --git a/include/linux/irqdesc.h b/include/linux/irqdesc.h
index 0021837..14a22fb 100644
--- a/include/linux/irqdesc.h
+++ b/include/linux/irqdesc.h
@@ -64,6 +64,10 @@ struct irq_desc {
 	struct timer_rand_state *timer_rand_state;
 	unsigned int __percpu	*kstat_irqs;
 	irq_flow_handler_t	handle_irq;
+#ifdef CONFIG_AFFINITY_UPDATE
+	struct affin_data	*af_data;
+#endif
+
 #ifdef CONFIG_IRQ_PREFLOW_FASTEOI
 	irq_preflow_handler_t	preflow_handler;
 #endif
diff --git a/kernel/irq/Kconfig b/kernel/irq/Kconfig
index 09bef82..abaf19c 100644
--- a/kernel/irq/Kconfig
+++ b/kernel/irq/Kconfig
@@ -51,6 +51,17 @@ config IRQ_PREFLOW_FASTEOI
 config IRQ_FORCED_THREADING
        bool
 
+config AFFINITY_UPDATE
+	bool "Support irq affinity direction"
+	depends on GENERIC_HARDIRQS
+	---help---
+
+	Affinity updating adds the ability for requestors of irqs to
+	register affinity update methods against the irq in question
+	in so doing the requestor can be informed every time user space
+	queries an irq for its optimal affinity, giving the requstor the
+	chance to tell user space where the irq can be optimally handled
+
 config SPARSE_IRQ
 	bool "Support sparse irq numbering"
 	depends on HAVE_SPARSE_IRQ
@@ -64,6 +75,5 @@ config SPARSE_IRQ
 	    out the interrupt descriptors in a more NUMA-friendly way. )
 
 	  If you don't know what to do here, say N.
-
 endmenu
 endif
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index acd599a..257ea4d 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -1159,6 +1159,17 @@ static struct irqaction *__free_irq(unsigned int irq, void *dev_id)
 
 	unregister_handler_proc(irq, action);
 
+#ifdef CONFIG_AFFINITY_UPDATE
+	/*
+	 * Have to do this after we unregister proc accessors
+	 */
+	if (desc->af_data) {
+		if (desc->af_data->affin_cleanup)
+			desc->af_data->affin_cleanup(irq, desc->af_data);
+		kfree(desc->af_data);
+		desc->af_data = NULL;
+	}
+#endif
 	/* Make sure it's not being used on another CPU: */
 	synchronize_irq(irq);
 
@@ -1345,6 +1356,34 @@ int request_threaded_irq(unsigned int irq, irq_handler_t handler,
 }
 EXPORT_SYMBOL(request_threaded_irq);
 
+#ifdef CONFIG_AFFINITY_UPDATE
+int setup_affinity_data(int irq, irq_affinity_init_t af_init, void *af_priv)
+{
+	struct affin_data *data;
+	struct irq_desc *desc;
+	int rc;
+
+	desc = irq_to_desc(irq);
+	if (!desc)
+		return -ENOENT;
+
+	data = kzalloc(sizeof(struct affin_data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	rc = af_init(irq, data, af_priv);
+	if (rc) {
+		kfree(data);
+		return rc;
+	}
+
+	desc->af_data = data;
+
+	return 0;
+}
+EXPORT_SYMBOL(setup_affinity_data);
+#endif
+
 /**
  *	request_any_context_irq - allocate an interrupt line
  *	@irq: Interrupt line to allocate
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 4cc2e5e..8fecb05 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -42,6 +42,11 @@ static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
 	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
 		return -ENOMEM;
 
+#ifdef CONFIG_AFFINITY_UPDATE
+	if (desc->af_data && desc->af_data->affin_update)
+		desc->af_data->affin_update((long)m->private, desc->af_data);
+#endif
+
 	raw_spin_lock_irqsave(&desc->lock, flags);
 	if (desc->affinity_hint)
 		cpumask_copy(mask, desc->affinity_hint);
@@ -54,6 +59,19 @@ static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int irq_affinity_alg_proc_show(struct seq_file *m, void *v)
+{
+	char *alg = "none";
+#ifdef CONFIG_AFFINITY_UPDATE
+	struct irq_desc *desc = irq_to_desc((long)m->private);
+
+	if (desc->af_data->affinity_alg)
+		alg = desc->af_data->affinity_alg;
+#endif
+	seq_printf(m, "%s\n", alg);
+	return 0;
+}
+
 #ifndef is_affinity_mask_valid
 #define is_affinity_mask_valid(val) 1
 #endif
@@ -110,6 +128,11 @@ static int irq_affinity_hint_proc_open(struct inode *inode, struct file *file)
 	return single_open(file, irq_affinity_hint_proc_show, PDE(inode)->data);
 }
 
+static int irq_affinity_alg_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, irq_affinity_alg_proc_show, PDE(inode)->data);
+}
+
 static const struct file_operations irq_affinity_proc_fops = {
 	.open		= irq_affinity_proc_open,
 	.read		= seq_read,
@@ -125,6 +148,13 @@ static const struct file_operations irq_affinity_hint_proc_fops = {
 	.release	= single_release,
 };
 
+static const struct file_operations irq_affinity_alg_proc_fops = {
+	.open		= irq_affinity_alg_proc_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
 static int default_affinity_show(struct seq_file *m, void *v)
 {
 	seq_cpumask(m, irq_default_affinity);
@@ -288,6 +318,11 @@ void register_irq_proc(unsigned int irq, struct irq_desc *desc)
 	/* create /proc/irq/<irq>/affinity_hint */
 	proc_create_data("affinity_hint", 0400, desc->dir,
 			 &irq_affinity_hint_proc_fops, (void *)(long)irq);
+#ifdef CONFIG_AFFINITY_UPDATE
+	/* Create /proc/irq/<irq>/affinity_alg */
+	proc_create_data("affinity_alg", 0400, desc->dir,
+			&irq_affinity_alg_proc_fops, (void *)(long)irq);
+#endif
 
 	proc_create_data("node", 0444, desc->dir,
 			 &irq_node_proc_fops, (void *)(long)irq);
-- 
1.7.4.2

