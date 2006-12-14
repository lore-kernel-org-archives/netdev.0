From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/4] net: rearrange functions in netdevice.h
Date: Thu, 14 Dec 2006 12:48:18 -0800
Message-ID: <20061214204901.047161000@osdl.org>
References: <20061214204814.631279000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56880 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932900AbWLNUwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 15:52:44 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netdevice-reorg.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use existing inline functions rather than having multiple
copies of same code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.20-rc1.orig/include/linux/netdevice.h
+++ linux-2.6.20-rc1/include/linux/netdevice.h
@@ -615,9 +615,14 @@ static inline int unregister_gifconf(uns
 
 extern void __netif_schedule(struct net_device *dev);
 
+static inline int netif_queue_stopped(const struct net_device *dev)
+{
+	return test_bit(__LINK_STATE_XOFF, &dev->state);
+}
+
 static inline void netif_schedule(struct net_device *dev)
 {
-	if (!test_bit(__LINK_STATE_XOFF, &dev->state))
+	if (!netif_queue_stopped(dev))
 		__netif_schedule(dev);
 }
 
@@ -645,11 +650,6 @@ static inline void netif_stop_queue(stru
 	set_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
-static inline int netif_queue_stopped(const struct net_device *dev)
-{
-	return test_bit(__LINK_STATE_XOFF, &dev->state);
-}
-
 static inline int netif_running(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_START, &dev->state);
@@ -841,15 +841,20 @@ extern int netif_rx_reschedule(struct ne
  * it completes the work. The device cannot be out of poll list at this
  * moment, it is BUG().
  */
-static inline void netif_rx_complete(struct net_device *dev)
+static inline void __netif_rx_complete(struct net_device *dev)
 {
-	unsigned long flags;
-
-	local_irq_save(flags);
 	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
 	list_del(&dev->poll_list);
 	smp_mb__before_clear_bit();
 	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+}
+
+static inline void netif_rx_complete(struct net_device *dev)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__netif_rx_complete(dev);
 	local_irq_restore(flags);
 }
 
@@ -865,17 +870,6 @@ static inline void netif_poll_enable(str
 	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
 }
 
-/* same as netif_rx_complete, except that local_irq_save(flags)
- * has already been issued
- */
-static inline void __netif_rx_complete(struct net_device *dev)
-{
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
-
 static inline void netif_tx_lock(struct net_device *dev)
 {
 	spin_lock(&dev->_xmit_lock);

-- 

