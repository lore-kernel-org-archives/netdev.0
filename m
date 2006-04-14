From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] sir: switch to a workqueue
Date: Fri, 14 Apr 2006 20:20:15 +0200
Message-ID: <20060414182015.GA20662@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:43144 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751370AbWDNSUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:20:33 -0400
To: info@mdiehl.de, jt@hpl.hp.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sir_kthread.c pretty much duplicates the workqueue functionality.
Switch it to use a workqueue instead.  It could probably use
schedule_work/schedule_delayed_work instead of having it's own
waitqueue, but I'd rather leave that to the maintainer.  The file
should probably get a name that still makes sense or merged into
sir-dev.c now, but again that's up to the maintainer.

Note: I don't have the hardware so this is just compile-tested.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/drivers/net/irda/sir-dev.h
===================================================================
--- linux-2.6.orig/drivers/net/irda/sir-dev.h	2006-01-31 12:23:36.000000000 +0100
+++ linux-2.6/drivers/net/irda/sir-dev.h	2006-04-14 15:08:14.000000000 +0200
@@ -15,23 +15,15 @@
 #define IRDA_SIR_H
 
 #include <linux/netdevice.h>
+#include <linux/workqueue.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>		// iobuff_t
 
-/* FIXME: unify irda_request with sir_fsm! */
-
-struct irda_request {
-	struct list_head lh_request;
-	unsigned long pending;
-	void (*func)(void *);
-	void *data;
-	struct timer_list timer;
-};
 
 struct sir_fsm {
 	struct semaphore	sem;
-	struct irda_request	rq;
+	struct work_struct	work;
 	unsigned		state, substate;
 	int			param;
 	int			result;
Index: linux-2.6/drivers/net/irda/sir_dev.c
===================================================================
--- linux-2.6.orig/drivers/net/irda/sir_dev.c	2006-04-14 15:02:46.000000000 +0200
+++ linux-2.6/drivers/net/irda/sir_dev.c	2006-04-14 15:03:15.000000000 +0200
@@ -619,10 +619,6 @@
 	spin_lock_init(&dev->tx_lock);
 	init_MUTEX(&dev->fsm.sem);
 
-	INIT_LIST_HEAD(&dev->fsm.rq.lh_request);
-	dev->fsm.rq.pending = 0;
-	init_timer(&dev->fsm.rq.timer);
-
 	dev->drv = drv;
 	dev->netdev = ndev;
 
Index: linux-2.6/drivers/net/irda/sir_kthread.c
===================================================================
--- linux-2.6.orig/drivers/net/irda/sir_kthread.c	2006-04-14 14:54:08.000000000 +0200
+++ linux-2.6/drivers/net/irda/sir_kthread.c	2006-04-14 15:10:56.000000000 +0200
@@ -14,159 +14,14 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/init.h>
-#include <linux/smp_lock.h>
-#include <linux/completion.h>
 #include <linux/delay.h>
-
 #include <net/irda/irda.h>
 
 #include "sir-dev.h"
 
-/**************************************************************************
- *
- * kIrDAd kernel thread and config state machine
- *
- */
-
-struct irda_request_queue {
-	struct list_head request_list;
-	spinlock_t lock;
-	task_t *thread;
-	struct completion exit;
-	wait_queue_head_t kick, done;
-	atomic_t num_pending;
-};
-
-static struct irda_request_queue irda_rq_queue;
-
-static int irda_queue_request(struct irda_request *rq)
-{
-	int ret = 0;
-	unsigned long flags;
-
-	if (!test_and_set_bit(0, &rq->pending)) {
-		spin_lock_irqsave(&irda_rq_queue.lock, flags);
-		list_add_tail(&rq->lh_request, &irda_rq_queue.request_list);
-		wake_up(&irda_rq_queue.kick);
-		atomic_inc(&irda_rq_queue.num_pending);
-		spin_unlock_irqrestore(&irda_rq_queue.lock, flags);
-		ret = 1;
-	}
-	return ret;
-}
-
-static void irda_request_timer(unsigned long data)
-{
-	struct irda_request *rq = (struct irda_request *)data;
-	unsigned long flags;
-	
-	spin_lock_irqsave(&irda_rq_queue.lock, flags);
-	list_add_tail(&rq->lh_request, &irda_rq_queue.request_list);
-	wake_up(&irda_rq_queue.kick);
-	spin_unlock_irqrestore(&irda_rq_queue.lock, flags);
-}
-
-static int irda_queue_delayed_request(struct irda_request *rq, unsigned long delay)
-{
-	int ret = 0;
-	struct timer_list *timer = &rq->timer;
 
-	if (!test_and_set_bit(0, &rq->pending)) {
-		timer->expires = jiffies + delay;
-		timer->function = irda_request_timer;
-		timer->data = (unsigned long)rq;
-		atomic_inc(&irda_rq_queue.num_pending);
-		add_timer(timer);
-		ret = 1;
-	}
-	return ret;
-}
-
-static void run_irda_queue(void)
-{
-	unsigned long flags;
-	struct list_head *entry, *tmp;
-	struct irda_request *rq;
-
-	spin_lock_irqsave(&irda_rq_queue.lock, flags);
-	list_for_each_safe(entry, tmp, &irda_rq_queue.request_list) {
-		rq = list_entry(entry, struct irda_request, lh_request);
-		list_del_init(entry);
-		spin_unlock_irqrestore(&irda_rq_queue.lock, flags);
-
-		clear_bit(0, &rq->pending);
-		rq->func(rq->data);
-
-		if (atomic_dec_and_test(&irda_rq_queue.num_pending))
-			wake_up(&irda_rq_queue.done);
-
-		spin_lock_irqsave(&irda_rq_queue.lock, flags);
-	}
-	spin_unlock_irqrestore(&irda_rq_queue.lock, flags);
-}		
-
-static int irda_thread(void *startup)
-{
-	DECLARE_WAITQUEUE(wait, current);
-
-	daemonize("kIrDAd");
-
-	irda_rq_queue.thread = current;
-
-	complete((struct completion *)startup);
-
-	while (irda_rq_queue.thread != NULL) {
-
-		/* We use TASK_INTERRUPTIBLE, rather than
-		 * TASK_UNINTERRUPTIBLE.  Andrew Morton made this
-		 * change ; he told me that it is safe, because "signal
-		 * blocking is now handled in daemonize()", he added
-		 * that the problem is that "uninterruptible sleep
-		 * contributes to load average", making user worry.
-		 * Jean II */
-		set_task_state(current, TASK_INTERRUPTIBLE);
-		add_wait_queue(&irda_rq_queue.kick, &wait);
-		if (list_empty(&irda_rq_queue.request_list))
-			schedule();
-		else
-			__set_task_state(current, TASK_RUNNING);
-		remove_wait_queue(&irda_rq_queue.kick, &wait);
-
-		/* make swsusp happy with our thread */
-		try_to_freeze();
-
-		run_irda_queue();
-	}
-
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,35)
-	reparent_to_init();
-#endif
-	complete_and_exit(&irda_rq_queue.exit, 0);
-	/* never reached */
-	return 0;
-}
-
-
-static void flush_irda_queue(void)
-{
-	if (atomic_read(&irda_rq_queue.num_pending)) {
-
-		DECLARE_WAITQUEUE(wait, current);
-
-		if (!list_empty(&irda_rq_queue.request_list))
-			run_irda_queue();
-
-		set_task_state(current, TASK_UNINTERRUPTIBLE);
-		add_wait_queue(&irda_rq_queue.done, &wait);
-		if (atomic_read(&irda_rq_queue.num_pending))
-			schedule();
-		else
-			__set_task_state(current, TASK_RUNNING);
-		remove_wait_queue(&irda_rq_queue.done, &wait);
-	}
-}
+static struct workqueue_struct *irda_wq;
 
 /* substate handler of the config-fsm to handle the cases where we want
  * to wait for transmit completion before changing the port configuration
@@ -413,7 +268,7 @@
 		fsm->state = next_state;
 	} while(!delay);
 
-	irda_queue_delayed_request(&fsm->rq, msecs_to_jiffies(delay));
+	queue_delayed_work(irda_wq, &fsm->work, msecs_to_jiffies(delay));
 }
 
 /* schedule some device configuration task for execution by kIrDAd
@@ -424,7 +279,6 @@
 int sirdev_schedule_request(struct sir_dev *dev, int initial_state, unsigned param)
 {
 	struct sir_fsm *fsm = &dev->fsm;
-	int xmit_was_down;
 
 	IRDA_DEBUG(2, "%s - state=0x%04x / param=%u\n", __FUNCTION__, initial_state, param);
 
@@ -443,7 +297,6 @@
 		return -ESTALE;		/* or better EPIPE? */
 	}
 
-	xmit_was_down = netif_queue_stopped(dev->netdev);
 	netif_stop_queue(dev->netdev);
 	atomic_set(&dev->enable_rx, 0);
 
@@ -451,58 +304,27 @@
 	fsm->param = param;
 	fsm->result = 0;
 
-	INIT_LIST_HEAD(&fsm->rq.lh_request);
-	fsm->rq.pending = 0;
-	fsm->rq.func = irda_config_fsm;
-	fsm->rq.data = dev;
-
-	if (!irda_queue_request(&fsm->rq)) {	/* returns 0 on error! */
-		atomic_set(&dev->enable_rx, 1);
-		if (!xmit_was_down)
-			netif_wake_queue(dev->netdev);		
-		up(&fsm->sem);
-		return -EAGAIN;
-	}
+	INIT_WORK(&fsm->work, irda_config_fsm, dev);
+	queue_work(irda_wq, &fsm->work);
 	return 0;
 }
 
-static int __init irda_thread_create(void)
+static int __init irda_thread_init(void)
 {
-	struct completion startup;
-	int pid;
-
-	spin_lock_init(&irda_rq_queue.lock);
-	irda_rq_queue.thread = NULL;
-	INIT_LIST_HEAD(&irda_rq_queue.request_list);
-	init_waitqueue_head(&irda_rq_queue.kick);
-	init_waitqueue_head(&irda_rq_queue.done);
-	atomic_set(&irda_rq_queue.num_pending, 0);
-
-	init_completion(&startup);
-	pid = kernel_thread(irda_thread, &startup, CLONE_FS|CLONE_FILES);
-	if (pid <= 0)
-		return -EAGAIN;
-	else
-		wait_for_completion(&startup);
-
+	irda_wq = create_singlethread_workqueue("irda_wq");
+	if (!irda_wq)
+		return -ENOMEM;
 	return 0;
 }
 
-static void __exit irda_thread_join(void)
+static void __exit irda_thread_exit(void)
 {
-	if (irda_rq_queue.thread) {
-		flush_irda_queue();
-		init_completion(&irda_rq_queue.exit);
-		irda_rq_queue.thread = NULL;
-		wake_up(&irda_rq_queue.kick);		
-		wait_for_completion(&irda_rq_queue.exit);
-	}
+	destroy_workqueue(irda_wq);
 }
 
-module_init(irda_thread_create);
-module_exit(irda_thread_join);
+module_init(irda_thread_init);
+module_exit(irda_thread_exit);
 
 MODULE_AUTHOR("Martin Diehl <info@mdiehl.de>");
 MODULE_DESCRIPTION("IrDA SIR core");
 MODULE_LICENSE("GPL");
-
