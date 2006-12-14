From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/4] net: uninline netif_rx_reschedule
Date: Thu, 14 Dec 2006 12:48:16 -0800
Message-ID: <20061214204900.888889000@osdl.org>
References: <20061214204814.631279000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56881 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932906AbWLNUwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 15:52:45 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netif_rx_reschedule.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move netif_rx_reschedule out of line, so that softnet_data can be
made local.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.20-rc1.orig/include/linux/netdevice.h
+++ linux-2.6.20-rc1/include/linux/netdevice.h
@@ -851,21 +851,7 @@ static inline void netif_rx_schedule(str
 /* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().
  * Do not inline this?
  */
-static inline int netif_rx_reschedule(struct net_device *dev, int undo)
-{
-	if (netif_rx_schedule_prep(dev)) {
-		unsigned long flags;
-
-		dev->quota += undo;
-
-		local_irq_save(flags);
-		list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-		local_irq_restore(flags);
-		return 1;
-	}
-	return 0;
-}
+extern int netif_rx_reschedule(struct net_device *dev, int undo);
 
 /* Remove interface from poll list: it must be in the poll list
  * on current cpu. This primitive is called by dev->poll(), when
--- linux-2.6.20-rc1.orig/net/core/dev.c
+++ linux-2.6.20-rc1/net/core/dev.c
@@ -1132,6 +1132,23 @@ void __netif_rx_schedule(struct net_devi
 }
 EXPORT_SYMBOL(__netif_rx_schedule);
 
+int netif_rx_reschedule(struct net_device *dev, int undo)
+{
+	if (netif_rx_schedule_prep(dev)) {
+		unsigned long flags;
+
+		dev->quota += undo;
+
+		local_irq_save(flags);
+		list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
+		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+		local_irq_restore(flags);
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(netif_rx_reschedule);
+
 void dev_kfree_skb_any(struct sk_buff *skb)
 {
 	if (in_irq() || irqs_disabled())

-- 

