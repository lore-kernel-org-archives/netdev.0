From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 1/3] [AF_IUCV/IUCV]: smp_call_function deadlock
Date: Thu, 19 Apr 2007 11:11:45 +0200
Message-ID: <20070419091145.GC14586@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:65134 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993220AbXDSJKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 05:10:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Heiko Carstens <heiko.carstens@de.ibm.com>
From: Ursula Braun <braunu@de.ibm.com>

Calling smp_call_function can lead to a deadlock if it is called
from tasklet context. 
Fixing this deadlock requires to move the smp_call_function from the
tasklet context to a work queue. To do that queue the path pending
interrupts to a separate list and move the path cleanup out of
iucv_path_sever to iucv_path_connect and iucv_path_pending.
This creates a new requirement for iucv_path_connect: it may not be
called from tasklet context anymore. 
Also fixed compile problem for CONFIG_HOTPLUG_CPU=n and
another one when walking the cpu_online mask. When doing this, 
we must disable cpu hotplug.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/net/iucv/iucv.h |    2
 net/iucv/iucv.c         |  207 ++++++++++++++++++++++++++++++------------------
 2 files changed, 133 insertions(+), 76 deletions(-)

diff --git a/include/net/iucv/iucv.h b/include/net/iucv/iucv.h
index 746e741..fd70adb 100644
--- a/include/net/iucv/iucv.h
+++ b/include/net/iucv/iucv.h
@@ -16,7 +16,7 @@
  * completed a register, it can exploit the other functions.
  * For furthur reference on all IUCV functionality, refer to the
  * CP Programming Services book, also available on the web thru
- * www.ibm.com/s390/vm/pubs, manual # SC24-5760
+ * www.vm.ibm.com/pubs, manual # SC24-6084
  *
  * Definition of Return Codes
  * - All positive return codes including zero are reflected back
diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index 1b10d57..903bdb6 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -90,20 +90,43 @@ struct iucv_irq_data {
 	u32 res2[8];
 };
 
-struct iucv_work {
+struct iucv_irq_list {
 	struct list_head list;
 	struct iucv_irq_data data;
 };
 
-static LIST_HEAD(iucv_work_queue);
-static DEFINE_SPINLOCK(iucv_work_lock);
-
 static struct iucv_irq_data *iucv_irq_data;
 static cpumask_t iucv_buffer_cpumask = CPU_MASK_NONE;
 static cpumask_t iucv_irq_cpumask = CPU_MASK_NONE;
 
-static void iucv_tasklet_handler(unsigned long);
-static DECLARE_TASKLET(iucv_tasklet, iucv_tasklet_handler,0);
+/*
+ * Queue of interrupt buffers lock for delivery via the tasklet
+ * (fast but can't call smp_call_function).
+ */
+static LIST_HEAD(iucv_task_queue);
+
+/*
+ * The tasklet for fast delivery of iucv interrupts.
+ */
+static void iucv_tasklet_fn(unsigned long);
+static DECLARE_TASKLET(iucv_tasklet, iucv_tasklet_fn,0);
+
+/*
+ * Queue of interrupt buffers for delivery via a work queue
+ * (slower but can call smp_call_function).
+ */
+static LIST_HEAD(iucv_work_queue);
+
+/*
+ * The work element to deliver path pending interrupts.
+ */
+static void iucv_work_fn(struct work_struct *work);
+static DECLARE_WORK(iucv_work, iucv_work_fn);
+
+/*
+ * Spinlock protecting task and work queue.
+ */
+static DEFINE_SPINLOCK(iucv_queue_lock);
 
 enum iucv_command_codes {
 	IUCV_QUERY = 0,
@@ -147,10 +170,10 @@ static unsigned long iucv_max_pathid;
 static DEFINE_SPINLOCK(iucv_table_lock);
 
 /*
- * iucv_tasklet_cpu: contains the number of the cpu executing the tasklet.
- * Needed for iucv_path_sever called from tasklet.
+ * iucv_active_cpu: contains the number of the cpu executing the tasklet
+ * or the work handler. Needed for iucv_path_sever called from tasklet.
  */
-static int iucv_tasklet_cpu = -1;
+static int iucv_active_cpu = -1;
 
 /*
  * Mutex and wait queue for iucv_register/iucv_unregister.
@@ -449,17 +472,19 @@ static void iucv_setmask_mp(void)
 {
 	int cpu;
 
+	preempt_disable();
 	for_each_online_cpu(cpu)
 		/* Enable all cpus with a declared buffer. */
 		if (cpu_isset(cpu, iucv_buffer_cpumask) &&
 		    !cpu_isset(cpu, iucv_irq_cpumask))
 			smp_call_function_on(iucv_allow_cpu, NULL, 0, 1, cpu);
+	preempt_enable();
 }
 
 /**
  * iucv_setmask_up
  *
- * Allow iucv interrupts on a single cpus.
+ * Allow iucv interrupts on a single cpu.
  */
 static void iucv_setmask_up(void)
 {
@@ -493,8 +518,10 @@ static int iucv_enable(void)
 		goto out;
 	/* Declare per cpu buffers. */
 	rc = -EIO;
+	preempt_disable();
 	for_each_online_cpu(cpu)
 		smp_call_function_on(iucv_declare_cpu, NULL, 0, 1, cpu);
+	preempt_enable();
 	if (cpus_empty(iucv_buffer_cpumask))
 		/* No cpu could declare an iucv buffer. */
 		goto out_path;
@@ -519,7 +546,6 @@ static void iucv_disable(void)
 	kfree(iucv_path_table);
 }
 
-#ifdef CONFIG_HOTPLUG_CPU
 static int __cpuinit iucv_cpu_notify(struct notifier_block *self,
 				     unsigned long action, void *hcpu)
 {
@@ -565,7 +591,6 @@ static int __cpuinit iucv_cpu_notify(struct notifier_block *self,
 static struct notifier_block iucv_cpu_notifier = {
 	.notifier_call = iucv_cpu_notify,
 };
-#endif
 
 /**
  * iucv_sever_pathid
@@ -586,48 +611,49 @@ static int iucv_sever_pathid(u16 pathid, u8 userdata[16])
 	return iucv_call_b2f0(IUCV_SEVER, parm);
 }
 
+#ifdef CONFIG_SMP
 /**
- * __iucv_cleanup_pathid
+ * __iucv_cleanup_queue
  * @dummy: unused dummy argument
  *
  * Nop function called via smp_call_function to force work items from
  * pending external iucv interrupts to the work queue.
  */
-static void __iucv_cleanup_pathid(void *dummy)
+static void __iucv_cleanup_queue(void *dummy)
 {
 }
+#endif
 
 /**
- * iucv_cleanup_pathid
- * @pathid: 16 bit pathid
+ * iucv_cleanup_queue
  *
  * Function called after a path has been severed to find all remaining
  * work items for the now stale pathid. The caller needs to hold the
  * iucv_table_lock.
  */
-static void iucv_cleanup_pathid(u16 pathid)
+static void iucv_cleanup_queue(void)
 {
-	struct iucv_work *p, *n;
+	struct iucv_irq_list *p, *n;
 
 	/*
-	 * Path is severed, the pathid can be reused immediatly on
-	 * a iucv connect or a connection pending interrupt.
-	 * iucv_path_connect and connection pending interrupt will
-	 * wait until the iucv_table_lock is released before the
-	 * recycled pathid enters the system.
-	 * Force remaining interrupts to the work queue, then
-	 * scan the work queue for items of this path.
+	 * When a path is severed, the pathid can be reused immediatly
+	 * on a iucv connect or a connection pending interrupt. Remove
+	 * all entries from the task queue that refer to a stale pathid
+	 * (iucv_path_table[ix] == NULL). Only then do the iucv connect
+	 * or deliver the connection pending interrupt. To get all the
+	 * pending interrupts force them to the work queue by calling
+	 * an empty function on all cpus.
 	 */
-	smp_call_function(__iucv_cleanup_pathid, NULL, 0, 1);
-	spin_lock_irq(&iucv_work_lock);
-	list_for_each_entry_safe(p, n, &iucv_work_queue, list) {
-		/* Remove work items for pathid except connection pending */
-		if (p->data.ippathid == pathid && p->data.iptype != 0x01) {
+	smp_call_function(__iucv_cleanup_queue, NULL, 0, 1);
+	spin_lock_irq(&iucv_queue_lock);
+	list_for_each_entry_safe(p, n, &iucv_task_queue, list) {
+		/* Remove stale work items from the task queue. */
+		if (iucv_path_table[p->data.ippathid] == NULL) {
 			list_del(&p->list);
 			kfree(p);
 		}
 	}
-	spin_unlock_irq(&iucv_work_lock);
+	spin_unlock_irq(&iucv_queue_lock);
 }
 
 /**
@@ -686,7 +712,6 @@ void iucv_unregister(struct iucv_handler *handler, int smp)
 		iucv_sever_pathid(p->pathid, NULL);
 		iucv_path_table[p->pathid] = NULL;
 		list_del(&p->list);
-		iucv_cleanup_pathid(p->pathid);
 		iucv_path_free(p);
 	}
 	spin_unlock_bh(&iucv_table_lock);
@@ -759,9 +784,9 @@ int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
 	union iucv_param *parm;
 	int rc;
 
-	preempt_disable();
-	if (iucv_tasklet_cpu != smp_processor_id())
-		spin_lock_bh(&iucv_table_lock);
+	BUG_ON(in_atomic());
+	spin_lock_bh(&iucv_table_lock);
+	iucv_cleanup_queue();
 	parm = percpu_ptr(iucv_param, smp_processor_id());
 	memset(parm, 0, sizeof(union iucv_param));
 	parm->ctrl.ipmsglim = path->msglim;
@@ -796,9 +821,7 @@ int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
 			rc = -EIO;
 		}
 	}
-	if (iucv_tasklet_cpu != smp_processor_id())
-		spin_unlock_bh(&iucv_table_lock);
-	preempt_enable();
+	spin_unlock_bh(&iucv_table_lock);
 	return rc;
 }
 
@@ -869,15 +892,14 @@ int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
 
 
 	preempt_disable();
-	if (iucv_tasklet_cpu != smp_processor_id())
+	if (iucv_active_cpu != smp_processor_id())
 		spin_lock_bh(&iucv_table_lock);
 	rc = iucv_sever_pathid(path->pathid, userdata);
 	if (!rc) {
 		iucv_path_table[path->pathid] = NULL;
 		list_del_init(&path->list);
-		iucv_cleanup_pathid(path->pathid);
 	}
-	if (iucv_tasklet_cpu != smp_processor_id())
+	if (iucv_active_cpu != smp_processor_id())
 		spin_unlock_bh(&iucv_table_lock);
 	preempt_enable();
 	return rc;
@@ -1246,8 +1268,7 @@ static void iucv_path_complete(struct iucv_irq_data *data)
 	struct iucv_path_complete *ipc = (void *) data;
 	struct iucv_path *path = iucv_path_table[ipc->ippathid];
 
-	BUG_ON(!path || !path->handler);
-	if (path->handler->path_complete)
+	if (path && path->handler && path->handler->path_complete)
 		path->handler->path_complete(path, ipc->ipuser);
 }
 
@@ -1275,14 +1296,14 @@ static void iucv_path_severed(struct iucv_irq_data *data)
 	struct iucv_path_severed *ips = (void *) data;
 	struct iucv_path *path = iucv_path_table[ips->ippathid];
 
-	BUG_ON(!path || !path->handler);
+	if (!path || !path->handler)	/* Already severed */
+		return;
 	if (path->handler->path_severed)
 		path->handler->path_severed(path, ips->ipuser);
 	else {
 		iucv_sever_pathid(path->pathid, NULL);
 		iucv_path_table[path->pathid] = NULL;
 		list_del_init(&path->list);
-		iucv_cleanup_pathid(path->pathid);
 		iucv_path_free(path);
 	}
 }
@@ -1311,8 +1332,7 @@ static void iucv_path_quiesced(struct iucv_irq_data *data)
 	struct iucv_path_quiesced *ipq = (void *) data;
 	struct iucv_path *path = iucv_path_table[ipq->ippathid];
 
-	BUG_ON(!path || !path->handler);
-	if (path->handler->path_quiesced)
+	if (path && path->handler && path->handler->path_quiesced)
 		path->handler->path_quiesced(path, ipq->ipuser);
 }
 
@@ -1340,8 +1360,7 @@ static void iucv_path_resumed(struct iucv_irq_data *data)
 	struct iucv_path_resumed *ipr = (void *) data;
 	struct iucv_path *path = iucv_path_table[ipr->ippathid];
 
-	BUG_ON(!path || !path->handler);
-	if (path->handler->path_resumed)
+	if (path && path->handler && path->handler->path_resumed)
 		path->handler->path_resumed(path, ipr->ipuser);
 }
 
@@ -1373,8 +1392,7 @@ static void iucv_message_complete(struct iucv_irq_data *data)
 	struct iucv_path *path = iucv_path_table[imc->ippathid];
 	struct iucv_message msg;
 
-	BUG_ON(!path || !path->handler);
-	if (path->handler->message_complete) {
+	if (path && path->handler && path->handler->message_complete) {
 		msg.flags = imc->ipflags1;
 		msg.id = imc->ipmsgid;
 		msg.audit = imc->ipaudit;
@@ -1419,8 +1437,7 @@ static void iucv_message_pending(struct iucv_irq_data *data)
 	struct iucv_path *path = iucv_path_table[imp->ippathid];
 	struct iucv_message msg;
 
-	BUG_ON(!path || !path->handler);
-	if (path->handler->message_pending) {
+	if (path && path->handler && path->handler->message_pending) {
 		msg.flags = imp->ipflags1;
 		msg.id = imp->ipmsgid;
 		msg.class = imp->iptrgcls;
@@ -1435,17 +1452,16 @@ static void iucv_message_pending(struct iucv_irq_data *data)
 }
 
 /**
- * iucv_tasklet_handler:
+ * iucv_tasklet_fn:
  *
  * This tasklet loops over the queue of irq buffers created by
  * iucv_external_interrupt, calls the appropriate action handler
  * and then frees the buffer.
  */
-static void iucv_tasklet_handler(unsigned long ignored)
+static void iucv_tasklet_fn(unsigned long ignored)
 {
 	typedef void iucv_irq_fn(struct iucv_irq_data *);
 	static iucv_irq_fn *irq_fn[] = {
-		[0x01] = iucv_path_pending,
 		[0x02] = iucv_path_complete,
 		[0x03] = iucv_path_severed,
 		[0x04] = iucv_path_quiesced,
@@ -1455,38 +1471,70 @@ static void iucv_tasklet_handler(unsigned long ignored)
 		[0x08] = iucv_message_pending,
 		[0x09] = iucv_message_pending,
 	};
-	struct iucv_work *p;
+	struct list_head task_queue = LIST_HEAD_INIT(task_queue);
+	struct iucv_irq_list *p, *n;
 
 	/* Serialize tasklet, iucv_path_sever and iucv_path_connect. */
 	spin_lock(&iucv_table_lock);
-	iucv_tasklet_cpu = smp_processor_id();
+	iucv_active_cpu = smp_processor_id();
 
-	spin_lock_irq(&iucv_work_lock);
-	while (!list_empty(&iucv_work_queue)) {
-		p = list_entry(iucv_work_queue.next, struct iucv_work, list);
+	spin_lock_irq(&iucv_queue_lock);
+	list_splice_init(&iucv_task_queue, &task_queue);
+	spin_unlock_irq(&iucv_queue_lock);
+
+	list_for_each_entry_safe(p, n, &task_queue, list) {
 		list_del_init(&p->list);
-		spin_unlock_irq(&iucv_work_lock);
 		irq_fn[p->data.iptype](&p->data);
 		kfree(p);
-		spin_lock_irq(&iucv_work_lock);
 	}
-	spin_unlock_irq(&iucv_work_lock);
 
-	iucv_tasklet_cpu = -1;
+	iucv_active_cpu = -1;
 	spin_unlock(&iucv_table_lock);
 }
 
 /**
+ * iucv_work_fn:
+ *
+ * This work function loops over the queue of path pending irq blocks
+ * created by iucv_external_interrupt, calls the appropriate action
+ * handler and then frees the buffer.
+ */
+static void iucv_work_fn(struct work_struct *work)
+{
+	typedef void iucv_irq_fn(struct iucv_irq_data *);
+	struct list_head work_queue = LIST_HEAD_INIT(work_queue);
+	struct iucv_irq_list *p, *n;
+
+	/* Serialize tasklet, iucv_path_sever and iucv_path_connect. */
+	spin_lock_bh(&iucv_table_lock);
+	iucv_active_cpu = smp_processor_id();
+
+	spin_lock_irq(&iucv_queue_lock);
+	list_splice_init(&iucv_work_queue, &work_queue);
+	spin_unlock_irq(&iucv_queue_lock);
+
+	iucv_cleanup_queue();
+	list_for_each_entry_safe(p, n, &work_queue, list) {
+		list_del_init(&p->list);
+		iucv_path_pending(&p->data);
+		kfree(p);
+	}
+
+	iucv_active_cpu = -1;
+	spin_unlock_bh(&iucv_table_lock);
+}
+
+/**
  * iucv_external_interrupt
  * @code: irq code
  *
  * Handles external interrupts coming in from CP.
- * Places the interrupt buffer on a queue and schedules iucv_tasklet_handler().
+ * Places the interrupt buffer on a queue and schedules iucv_tasklet_fn().
  */
 static void iucv_external_interrupt(u16 code)
 {
 	struct iucv_irq_data *p;
-	struct iucv_work *work;
+	struct iucv_irq_list *work;
 
 	p = percpu_ptr(iucv_irq_data, smp_processor_id());
 	if (p->ippathid >= iucv_max_pathid) {
@@ -1500,16 +1548,23 @@ static void iucv_external_interrupt(u16 code)
 		printk(KERN_ERR "iucv_do_int: unknown iucv interrupt\n");
 		return;
 	}
-	work = kmalloc(sizeof(struct iucv_work), GFP_ATOMIC);
+	work = kmalloc(sizeof(struct iucv_irq_list), GFP_ATOMIC);
 	if (!work) {
 		printk(KERN_WARNING "iucv_external_interrupt: out of memory\n");
 		return;
 	}
 	memcpy(&work->data, p, sizeof(work->data));
-	spin_lock(&iucv_work_lock);
-	list_add_tail(&work->list, &iucv_work_queue);
-	spin_unlock(&iucv_work_lock);
-	tasklet_schedule(&iucv_tasklet);
+	spin_lock(&iucv_queue_lock);
+	if (p->iptype == 0x01) {
+		/* Path pending interrupt. */
+		list_add_tail(&work->list, &iucv_work_queue);
+		schedule_work(&iucv_work);
+	} else {
+		/* The other interrupts. */
+		list_add_tail(&work->list, &iucv_task_queue);
+		tasklet_schedule(&iucv_tasklet);
+	}
+	spin_unlock(&iucv_queue_lock);
 }
 
 /**
@@ -1579,12 +1634,14 @@ out:
  */
 static void iucv_exit(void)
 {
-	struct iucv_work *p, *n;
+	struct iucv_irq_list *p, *n;
 
-	spin_lock_irq(&iucv_work_lock);
+	spin_lock_irq(&iucv_queue_lock);
+	list_for_each_entry_safe(p, n, &iucv_task_queue, list)
+		kfree(p);
 	list_for_each_entry_safe(p, n, &iucv_work_queue, list)
 		kfree(p);
-	spin_unlock_irq(&iucv_work_lock);
+	spin_unlock_irq(&iucv_queue_lock);
 	unregister_hotcpu_notifier(&iucv_cpu_notifier);
 	percpu_free(iucv_param);
 	percpu_free(iucv_irq_data);
-- 
1.5.0.1

