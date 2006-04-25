From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] sky2: reschedule if irq still pending
Date: Tue, 25 Apr 2006 10:58:50 -0700
Message-ID: <20060425175951.185516000@localhost.localdomain>
References: <20060425175849.372221000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27777 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932258AbWDYVCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 17:02:34 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-edge.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a workaround for the case edge-triggered irq's. Several users
seem to have broken configurations sharing edge-triggered irq's. To avoid
losing IRQ's, reshedule if more work arrives.

The changes to netdevice.h are to extract the part that puts device
back in list into separate inline.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2-2.6.17.orig/drivers/net/sky2.c	2006-04-25 10:48:44.000000000 -0700
+++ sky2-2.6.17/drivers/net/sky2.c	2006-04-25 10:48:47.000000000 -0700
@@ -2093,6 +2093,7 @@
 	int work_done = 0;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
+ restart_poll:
 	if (unlikely(status & ~Y2_IS_STAT_BMU)) {
 		if (status & Y2_IS_HW_ERR)
 			sky2_hw_intr(hw);
@@ -2123,7 +2124,7 @@
 	}
 
 	if (status & Y2_IS_STAT_BMU) {
-		work_done = sky2_status_intr(hw, work_limit);
+		work_done += sky2_status_intr(hw, work_limit - work_done);
 		*budget -= work_done;
 		dev0->quota -= work_done;
 
@@ -2133,9 +2134,22 @@
 		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
 	}
 
-	netif_rx_complete(dev0);
+	local_irq_disable();
+	__netif_rx_complete(dev0);
 
 	status = sky2_read32(hw, B0_Y2_SP_LISR);
+
+	if (unlikely(status)) {
+		/* More work pending, try and keep going */
+		if (__netif_rx_schedule_prep(dev0)) {
+			__netif_rx_reschedule(dev0, work_done);
+			status = sky2_read32(hw, B0_Y2_SP_EISR);
+			local_irq_enable();
+			goto restart_poll;
+		}
+	}
+
+	local_irq_enable();
 	return 0;
 }
 
@@ -2153,8 +2167,6 @@
 	prefetch(&hw->st_le[hw->st_idx]);
 	if (likely(__netif_rx_schedule_prep(dev0)))
 		__netif_rx_schedule(dev0);
-	else
-		printk(KERN_DEBUG PFX "irq race detected\n");
 
 	return IRQ_HANDLED;
 }
--- sky2-2.6.17.orig/include/linux/netdevice.h	2006-04-25 10:48:44.000000000 -0700
+++ sky2-2.6.17/include/linux/netdevice.h	2006-04-25 10:48:47.000000000 -0700
@@ -829,19 +829,21 @@
 		__netif_rx_schedule(dev);
 }
 
-/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().
- * Do not inline this?
- */
+
+static inline void  __netif_rx_reschedule(struct net_device *dev, int undo)
+{
+	dev->quota += undo;
+	list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
+	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+}
+
+/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete(). */
 static inline int netif_rx_reschedule(struct net_device *dev, int undo)
 {
 	if (netif_rx_schedule_prep(dev)) {
 		unsigned long flags;
-
-		dev->quota += undo;
-
 		local_irq_save(flags);
-		list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+		__netif_rx_reschedule(dev, undo);
 		local_irq_restore(flags);
 		return 1;
 	}

--

