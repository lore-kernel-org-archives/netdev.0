From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 1/9] sky2: backout NAPI reschedule
Date: Mon, 08 May 2006 15:11:26 -0700
Message-ID: <20060508221228.153966000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12477 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751323AbWEHWXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003745
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:50 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNmrJ023542
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-backout-resched.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a backout of earlier patch.

The whole rescheduling hack was a bad idea. It doesn't really solve
the problem and it makes the code more complicated for no good reason.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -2105,7 +2105,6 @@ static int sky2_poll(struct net_device *
 	int work_done = 0;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
- restart_poll:
 	if (unlikely(status & ~Y2_IS_STAT_BMU)) {
 		if (status & Y2_IS_HW_ERR)
 			sky2_hw_intr(hw);
@@ -2136,7 +2135,7 @@ static int sky2_poll(struct net_device *
 	}
 
 	if (status & Y2_IS_STAT_BMU) {
-		work_done += sky2_status_intr(hw, work_limit - work_done);
+		work_done = sky2_status_intr(hw, work_limit);
 		*budget -= work_done;
 		dev0->quota -= work_done;
 
@@ -2148,22 +2147,9 @@ static int sky2_poll(struct net_device *
 
 	mod_timer(&hw->idle_timer, jiffies + HZ);
 
-	local_irq_disable();
-	__netif_rx_complete(dev0);
+	netif_rx_complete(dev0);
 
 	status = sky2_read32(hw, B0_Y2_SP_LISR);
-
-	if (unlikely(status)) {
-		/* More work pending, try and keep going */
-		if (__netif_rx_schedule_prep(dev0)) {
-			__netif_rx_reschedule(dev0, work_done);
-			status = sky2_read32(hw, B0_Y2_SP_EISR);
-			local_irq_enable();
-			goto restart_poll;
-		}
-	}
-
-	local_irq_enable();
 	return 0;
 }
 
@@ -2181,6 +2167,8 @@ static irqreturn_t sky2_intr(int irq, vo
 	prefetch(&hw->st_le[hw->st_idx]);
 	if (likely(__netif_rx_schedule_prep(dev0)))
 		__netif_rx_schedule(dev0);
+	else
+		printk(KERN_DEBUG PFX "irq race detected\n");
 
 	return IRQ_HANDLED;
 }
--- sky2.orig/include/linux/netdevice.h
+++ sky2/include/linux/netdevice.h
@@ -829,21 +829,19 @@ static inline void netif_rx_schedule(str
 		__netif_rx_schedule(dev);
 }
 
-
-static inline void  __netif_rx_reschedule(struct net_device *dev, int undo)
-{
-	dev->quota += undo;
-	list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-}
-
-/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete(). */
+/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().
+ * Do not inline this?
+ */
 static inline int netif_rx_reschedule(struct net_device *dev, int undo)
 {
 	if (netif_rx_schedule_prep(dev)) {
 		unsigned long flags;
+
+		dev->quota += undo;
+
 		local_irq_save(flags);
-		__netif_rx_reschedule(dev, undo);
+		list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
+		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 		local_irq_restore(flags);
 		return 1;
 	}

--

