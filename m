From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 1/5] genirq: implement support for runtime switch to threaded irqs
Date: Wed, 15 Jun 2016 15:42:02 +0200
Message-ID: <5104d67d1f9370e9fe3790164d07c628b727d382.1465996447.git.pabeni@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1465996447.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the IRQ_FORCED_THREADING compile option is enabled, a new
new 'threaded' procfs entry is added under the action proc
directory upon irq request. Writing a true value onto
that file will cause the underlying action to be reconfigured
in a FORCE_THREADED mode.

The reconfiguration is performed disabling the irq underlaying
the current action, and then updating the action struct to the
specified mode, i.e. setting the thread field and the
IRQTF_FORCED_THREAD.

If en error occours before notifying the device, the
irq action is unmodified.

A device that wants to be notified about irq mode change,
can register a notifier with irq_set_mode_notifier(). Such
notifier will be invoked in atomic context just after each
irq reconfiguration.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/interrupt.h |  15 ++++
 kernel/irq/internals.h    |   3 +
 kernel/irq/manage.c       | 197 ++++++++++++++++++++++++++++++++++++++++++++--
 kernel/irq/proc.c         |  51 ++++++++++++
 4 files changed, 261 insertions(+), 5 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 9fcabeb..85d3738 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -90,6 +90,7 @@ enum {
 };
 
 typedef irqreturn_t (*irq_handler_t)(int, void *);
+typedef void (*mode_notifier_t)(int, void *, struct task_struct *);
 
 /**
  * struct irqaction - per interrupt action descriptor
@@ -106,6 +107,8 @@ typedef irqreturn_t (*irq_handler_t)(int, void *);
  * @thread_flags:	flags related to @thread
  * @thread_mask:	bitmask for keeping track of @thread activity
  * @dir:	pointer to the proc/irq/NN/name entry
+ * @mode_notifier:	callback to notify the device about irq mode change
+ *		(threaded vs normal mode)
  */
 struct irqaction {
 	irq_handler_t		handler;
@@ -121,6 +124,7 @@ struct irqaction {
 	unsigned long		thread_mask;
 	const char		*name;
 	struct proc_dir_entry	*dir;
+	mode_notifier_t		mode_notifier;
 } ____cacheline_internodealigned_in_smp;
 
 extern irqreturn_t no_action(int cpl, void *dev_id);
@@ -212,6 +216,17 @@ extern void irq_wake_thread(unsigned int irq, void *dev_id);
 extern void suspend_device_irqs(void);
 extern void resume_device_irqs(void);
 
+#ifdef CONFIG_IRQ_FORCED_THREADING
+extern int irq_set_mode_notifier(unsigned int irq, void *dev_id,
+				 mode_notifier_t notifier);
+#else
+static inline int
+irq_set_mode_notifier(unsigned int irq, void *dev_id, mode_notifier_t notifier)
+{
+	return 0;
+}
+#endif
+
 /**
  * struct irq_affinity_notify - context for notification of IRQ affinity changes
  * @irq:		Interrupt to which notification applies
diff --git a/kernel/irq/internals.h b/kernel/irq/internals.h
index 09be2c9..841c714 100644
--- a/kernel/irq/internals.h
+++ b/kernel/irq/internals.h
@@ -105,6 +105,9 @@ static inline void unregister_handler_proc(unsigned int irq,
 					   struct irqaction *action) { }
 #endif
 
+extern int irq_reconfigure(unsigned int irq, struct irqaction *act,
+			   bool threaded);
+
 extern int irq_select_affinity_usr(unsigned int irq, struct cpumask *mask);
 
 extern void irq_set_thread_affinity(struct irq_desc *desc);
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index ef0bc02..cce4efd 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -938,8 +938,7 @@ static int irq_thread(void *data)
 	irqreturn_t (*handler_fn)(struct irq_desc *desc,
 			struct irqaction *action);
 
-	if (force_irqthreads && test_bit(IRQTF_FORCED_THREAD,
-					&action->thread_flags))
+	if (test_bit(IRQTF_FORCED_THREAD, &action->thread_flags))
 		handler_fn = irq_forced_thread_fn;
 	else
 		handler_fn = irq_thread_fn;
@@ -1052,8 +1051,8 @@ static void irq_release_resources(struct irq_desc *desc)
 		c->irq_release_resources(d);
 }
 
-static int
-setup_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
+static struct task_struct *
+create_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
 {
 	struct task_struct *t;
 	struct sched_param param = {
@@ -1070,7 +1069,7 @@ setup_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
 	}
 
 	if (IS_ERR(t))
-		return PTR_ERR(t);
+		return t;
 
 	sched_setscheduler_nocheck(t, SCHED_FIFO, &param);
 
@@ -1080,6 +1079,17 @@ setup_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
 	 * references an already freed task_struct.
 	 */
 	get_task_struct(t);
+	return t;
+}
+
+static int
+setup_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
+{
+	struct task_struct *t = create_irq_thread(new, irq, secondary);
+
+	if (IS_ERR(t))
+		return PTR_ERR(t);
+
 	new->thread = t;
 	/*
 	 * Tell the thread to set its affinity. This is
@@ -1511,6 +1521,183 @@ static struct irqaction *__free_irq(unsigned int irq, void *dev_id)
 	return action;
 }
 
+#ifdef CONFIG_IRQ_FORCED_THREADING
+/*
+ * Internal function to reconfigure an irqaction - change it to
+ * threaded mode if the specified task struct is not NULL and vice versa
+ */
+void __irq_reconfigure_action(struct irq_desc *desc, struct irqaction *action,
+			      struct task_struct *t)
+{
+	action->flags &= ~IRQF_ONESHOT;
+	action->thread_mask = 0;
+	if (!t) {
+		if (action->thread_fn) {
+			action->handler = action->thread_fn;
+			action->thread_fn = NULL;
+		}
+		clear_bit(IRQTF_FORCED_THREAD, &action->thread_flags);
+		action->thread = NULL;
+		return;
+	}
+
+	/* Force the irq in threaded mode */
+	if (!action->thread_fn) {
+		action->thread_fn = action->handler;
+		action->handler = irq_default_primary_handler;
+	}
+
+	action->thread = t;
+	set_bit(IRQTF_FORCED_THREAD, &action->thread_flags);
+	set_bit(IRQTF_AFFINITY, &action->thread_flags);
+
+	if (!(desc->irq_data.chip->flags & IRQCHIP_ONESHOT_SAFE)) {
+		/*
+		 * We already ensured no other actions is registered on
+		 * this irq
+		 */
+		action->thread_mask = 1;
+		action->flags |= IRQF_ONESHOT;
+		desc->istate |= IRQS_ONESHOT;
+	}
+}
+
+/* Internal function to check if the specified irqaction can be threadable */
+static bool __irq_check_threadable(struct irq_desc *desc, struct irqaction *act)
+{
+	if (irq_settings_is_nested_thread(desc) ||
+	    !irq_settings_can_thread(desc))
+		return false;
+
+	/*
+	 * Enabling thread mode is going to set IRQF_ONESHOT, unless the irq
+	 * chip will help us; in the first case the irq can't be shared: the
+	 * only registered action can be the current one
+	 */
+	if (desc->irq_data.chip->flags & IRQCHIP_ONESHOT_SAFE)
+		return true;
+	return !desc->action ||
+	       (act && desc->action == act && act->next == NULL);
+}
+
+/* Internal function to configure the specified action threaded mode */
+int irq_reconfigure(unsigned int irq, struct irqaction *act, bool threaded)
+{
+	struct task_struct *thread = NULL, *old_thread = NULL;
+	struct irq_desc *desc = irq_to_desc(irq);
+	struct irqaction *action;
+	int retval = -EINVAL;
+	unsigned long flags;
+
+	/*
+	 * Preallocate the kthread, so that we can update the action atomically
+	 * later
+	 */
+	if (threaded) {
+		old_thread = thread = create_irq_thread(act, irq, false);
+		if (IS_ERR(thread))
+			return PTR_ERR(thread);
+	}
+
+	disable_irq(irq);
+
+	chip_bus_lock(desc);
+	raw_spin_lock_irqsave(&desc->lock, flags);
+
+	/* Check for no-op under lock */
+	if (threaded == test_bit(IRQTF_FORCED_THREAD, &act->thread_flags))
+		goto unlock;
+
+	/* Even more pedantic check: look-up for our action */
+	for_each_action_of_desc(desc, action)
+		if (action->dev_id == act->dev_id)
+			break;
+	if (!action || action != act)
+		goto unlock;
+
+	/*
+	 * Check again for threadable constraints: the action list/desc
+	 * can be changed since the irq_set_threadable call
+	  */
+	if (!__irq_check_threadable(desc, action))
+		goto unlock;
+
+	old_thread = action->thread;
+	__irq_reconfigure_action(desc, action, thread);
+
+	if (action->mode_notifier)
+		action->mode_notifier(action->irq, action->dev_id, thread);
+	retval = 0;
+
+unlock:
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+	chip_bus_sync_unlock(desc);
+
+	if (old_thread) {
+		kthread_stop(old_thread);
+		put_task_struct(old_thread);
+	}
+
+	if (retval)
+		pr_err("can't change configuration for irq %d: %d\n", irq,
+		       retval);
+
+	enable_irq(irq);
+	return retval;
+}
+
+/**
+ *	irq_set_mode_notifier - register a mode change notifier
+ *	@irq: Interrupt line
+ *	@dev_id: The cookie used to identify the irq handler and passed back
+ *		 to the notifier
+ *	@mode_notifier: The callback to be registered
+ *
+ *	This call registers a callback to notify the device about irq mode
+ *	change (threaded/normal mode). Mode change are triggered writing on
+ *	the 'threaded' procfs entry.
+ *	When running in threaded mode the irq thread task struct will be passed
+ *	to the notifer, or NULL elsewhere. It's up to the device update its
+ *	internal state accordingly
+ */
+int irq_set_mode_notifier(unsigned int irq, void *dev_id,
+			  mode_notifier_t notifier)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	struct irqaction *action;
+	unsigned long flags;
+	int ret = -EINVAL;
+
+	if (!desc)
+		return ret;
+
+	chip_bus_lock(desc);
+	raw_spin_lock_irqsave(&desc->lock, flags);
+
+	for_each_action_of_desc(desc, action)
+		if (action->dev_id == dev_id)
+			break;
+
+	if (!action || action->mode_notifier)
+		goto out;
+
+	/*
+	 * Sync current status, so that the device is fine if the irq has been
+	 * reconfigured before the notifer is registered
+	 */
+	action->mode_notifier = notifier;
+	if (notifier)
+		notifier(action->irq, action->dev_id, action->thread);
+	ret = 0;
+
+out:
+	raw_spin_unlock_irqrestore(&desc->lock, flags);
+	chip_bus_sync_unlock(desc);
+	return ret;
+}
+EXPORT_SYMBOL(irq_set_mode_notifier);
+#endif
+
 /**
  *	remove_irq - free an interrupt
  *	@irq: Interrupt line to free
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 4e1b947..01f155b 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -302,6 +302,51 @@ static int name_unique(unsigned int irq, struct irqaction *new_action)
 	return ret;
 }
 
+#ifdef CONFIG_IRQ_FORCED_THREADING
+static int irqaction_threaded_proc_show(struct seq_file *m, void *v)
+{
+	struct irqaction *action = (struct irqaction *)m->private;
+
+	seq_printf(m, "%d\n",
+		   test_bit(IRQTF_FORCED_THREAD, &action->thread_flags));
+	return 0;
+}
+
+static int irqaction_threaded_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, irqaction_threaded_proc_show, PDE_DATA(inode));
+}
+
+static ssize_t irqaction_threaded_proc_write(struct file *file,
+					     const char __user *buf,
+					     size_t count, loff_t *offs)
+{
+	struct irqaction *action = PDE_DATA(file_inode(file));
+	bool threaded;
+	size_t ret;
+
+	ret = kstrtobool_from_user(buf, count, &threaded);
+	if (ret)
+		return ret;
+
+	if (threaded == test_bit(IRQTF_FORCED_THREAD, &action->thread_flags))
+		goto out;
+
+	irq_reconfigure(action->irq, action, threaded);
+
+out:
+	return count;
+}
+
+static const struct file_operations irqaction_threaded_proc_fops = {
+	.open		= irqaction_threaded_proc_open,
+	.read		= seq_read,
+	.write		= irqaction_threaded_proc_write,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+#endif
+
 void register_handler_proc(unsigned int irq, struct irqaction *action)
 {
 	char name [MAX_NAMELEN];
@@ -316,8 +361,14 @@ void register_handler_proc(unsigned int irq, struct irqaction *action)
 
 	/* create /proc/irq/1234/handler/ */
 	action->dir = proc_mkdir(name, desc->dir);
+#ifdef CONFIG_IRQ_FORCED_THREADING
+	if (action->dir)
+		proc_create_data("threaded", 0644, action->dir,
+				 &irqaction_threaded_proc_fops, (void *)action);
+#endif
 }
 
+
 #undef MAX_NAMELEN
 
 #define MAX_NAMELEN 10
-- 
1.8.3.1
