From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] move tg3 netif_* to netdevice.h
Date: Mon, 1 Sep 2003 14:27:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901182708.GA2084@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok for me to commit, and send to 2.4+2.6 upstream?

I have it queued locally, but it touches stuff you've been touching
lately...


===== drivers/net/tg3.c 1.82 vs edited =====
--- 1.82/drivers/net/tg3.c	Tue Aug 19 23:53:17 2003
+++ edited/drivers/net/tg3.c	Mon Sep  1 14:19:58 2003
@@ -237,38 +237,6 @@
 	tg3_cond_int(tp);
 }
 
-/* these netif_xxx funcs should be moved into generic net layer */
-static void netif_poll_disable(struct net_device *dev)
-{
-	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(1);
-	}
-}
-
-static inline void netif_poll_enable(struct net_device *dev)
-{
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
-
-/* same as netif_rx_complete, except that local_irq_save(flags)
- * has already been issued
- */
-static inline void __netif_rx_complete(struct net_device *dev)
-{
-	if (!test_bit(__LINK_STATE_RX_SCHED, &dev->state)) BUG();
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
-
-static inline void netif_tx_disable(struct net_device *dev)
-{
-	spin_lock_bh(&dev->xmit_lock);
-	netif_stop_queue(dev);
-	spin_unlock_bh(&dev->xmit_lock);
-}
-
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	netif_poll_disable(tp->dev);
===== include/linux/netdevice.h 1.52 vs edited =====
--- 1.52/include/linux/netdevice.h	Wed Aug 20 00:01:19 2003
+++ edited/include/linux/netdevice.h	Mon Sep  1 14:23:06 2003
@@ -832,6 +832,38 @@
 	local_irq_restore(flags);
 }
 
+static inline void netif_poll_disable(struct net_device *dev)
+{
+	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
+		/* No hurry. */
+		current->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(1);
+	}
+}
+
+static inline void netif_poll_enable(struct net_device *dev)
+{
+	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+}
+
+/* same as netif_rx_complete, except that local_irq_save(flags)
+ * has already been issued
+ */
+static inline void __netif_rx_complete(struct net_device *dev)
+{
+	if (!test_bit(__LINK_STATE_RX_SCHED, &dev->state)) BUG();
+	list_del(&dev->poll_list);
+	smp_mb__before_clear_bit();
+	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+}
+
+static inline void netif_tx_disable(struct net_device *dev)
+{
+	spin_lock_bh(&dev->xmit_lock);
+	netif_stop_queue(dev);
+	spin_unlock_bh(&dev->xmit_lock);
+}
+
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
 
 extern void		ether_setup(struct net_device *dev);
===== net/core/dev.c 1.95 vs edited =====
--- 1.95/net/core/dev.c	Wed Aug 20 00:04:26 2003
+++ edited/net/core/dev.c	Mon Sep  1 14:23:40 2003
@@ -845,11 +845,7 @@
 	 * engine, but this requires more changes in devices. */
 
 	smp_mb__after_clear_bit(); /* Commit netif_running(). */
-	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
-		/* No hurry. */
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(1);
-	}
+	netif_poll_disable(dev);
 
 	/*
 	 *	Call the device specific close. This cannot fail.
@@ -1657,7 +1653,7 @@
 
 	list_del(&backlog_dev->poll_list);
 	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &backlog_dev->state);
+	netif_poll_enable(backlog_dev);
 
 	if (queue->throttle) {
 		queue->throttle = 0;
