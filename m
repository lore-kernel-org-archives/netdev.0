From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 01/14] 8390: add common net_device ops
Date: Tue, 25 Nov 2008 17:14:20 -0800
Message-ID: <20081126011545.258038314@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58781 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbYKZBSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:46 -0500
Content-Disposition: inline; filename=8390-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the defactoring of ei_XXX functions in 8390 and 8390p.
Remove the tx_timeout hack since no driver including the 3c503
overrides tx_timeout at this time, looks like a legacy thing.

Also, since several drivers all have same hooks, provide common
netdev_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/8390.c    |   39 +++++++++++++++++++++++++++++++++++++++
 drivers/net/8390.h    |   18 ++++++++++++++----
 drivers/net/8390p.c   |   39 +++++++++++++++++++++++++++++++++++++++
 drivers/net/lib8390.c |   19 +++++--------------
 4 files changed, 97 insertions(+), 18 deletions(-)

--- a/drivers/net/8390.c	2008-11-25 17:08:44.000000000 -0800
+++ b/drivers/net/8390.c	2008-11-25 17:08:47.000000000 -0800
@@ -17,6 +17,30 @@ int ei_close(struct net_device *dev)
 }
 EXPORT_SYMBOL(ei_close);
 
+int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	return __ei_start_xmit(skb, dev);
+}
+EXPORT_SYMBOL(ei_start_xmit);
+
+struct net_device_stats *ei_get_stats(struct net_device *dev)
+{
+	return __ei_get_stats(dev);
+}
+EXPORT_SYMBOL(ei_get_stats);
+
+void ei_set_multicast_list(struct net_device *dev)
+{
+	__ei_set_multicast_list(dev);
+}
+EXPORT_SYMBOL(ei_set_multicast_list);
+
+void ei_tx_timeout(struct net_device *dev)
+{
+	__ei_tx_timeout(dev);
+}
+EXPORT_SYMBOL(ei_tx_timeout);
+
 irqreturn_t ei_interrupt(int irq, void *dev_id)
 {
 	return __ei_interrupt(irq, dev_id);
@@ -31,6 +55,21 @@ void ei_poll(struct net_device *dev)
 EXPORT_SYMBOL(ei_poll);
 #endif
 
+const struct net_device_ops ei_netdev_ops = {
+	.ndo_open		= ei_open,
+	.ndo_stop		= ei_close,
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ei_poll,
+#endif
+};
+EXPORT_SYMBOL(ei_netdev_ops);
+
 struct net_device *__alloc_ei_netdev(int size)
 {
 	return ____alloc_ei_netdev(size);
--- a/drivers/net/8390.h	2008-11-25 17:08:44.000000000 -0800
+++ b/drivers/net/8390.h	2008-11-25 17:09:33.000000000 -0800
@@ -33,16 +33,19 @@ extern void ei_poll(struct net_device *d
 extern void eip_poll(struct net_device *dev);
 #endif
 
-extern void ei_tx_timeout(struct net_device *dev);
-extern int ei_start_xmit(struct sk_buff *skb, struct net_device *dev);
-extern void ei_set_multicast_list(struct net_device *dev);
-extern struct net_device_stats *ei_get_stats(struct net_device *dev);
 
 /* Without I/O delay - non ISA or later chips */
 extern void NS8390_init(struct net_device *dev, int startp);
 extern int ei_open(struct net_device *dev);
 extern int ei_close(struct net_device *dev);
 extern irqreturn_t ei_interrupt(int irq, void *dev_id);
+extern void ei_tx_timeout(struct net_device *dev);
+extern int ei_start_xmit(struct sk_buff *skb, struct net_device *dev);
+extern void ei_set_multicast_list(struct net_device *dev);
+extern struct net_device_stats *ei_get_stats(struct net_device *dev);
+
+extern const struct net_device_ops ei_netdev_ops;
+
 extern struct net_device *__alloc_ei_netdev(int size);
 static inline struct net_device *alloc_ei_netdev(void)
 {
@@ -54,6 +57,13 @@ extern void NS8390p_init(struct net_devi
 extern int eip_open(struct net_device *dev);
 extern int eip_close(struct net_device *dev);
 extern irqreturn_t eip_interrupt(int irq, void *dev_id);
+extern void eip_tx_timeout(struct net_device *dev);
+extern int eip_start_xmit(struct sk_buff *skb, struct net_device *dev);
+extern void eip_set_multicast_list(struct net_device *dev);
+extern struct net_device_stats *eip_get_stats(struct net_device *dev);
+
+extern const struct net_device_ops eip_netdev_ops;
+
 extern struct net_device *__alloc_eip_netdev(int size);
 static inline struct net_device *alloc_eip_netdev(void)
 {
--- a/drivers/net/8390p.c	2008-11-25 17:08:44.000000000 -0800
+++ b/drivers/net/8390p.c	2008-11-25 17:08:47.000000000 -0800
@@ -22,6 +22,30 @@ int eip_close(struct net_device *dev)
 }
 EXPORT_SYMBOL(eip_close);
 
+int eip_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	return __ei_start_xmit(skb, dev);
+}
+EXPORT_SYMBOL(eip_start_xmit);
+
+struct net_device_stats *eip_get_stats(struct net_device *dev)
+{
+	return __ei_get_stats(dev);
+}
+EXPORT_SYMBOL(eip_get_stats);
+
+void eip_set_multicast_list(struct net_device *dev)
+{
+	__ei_set_multicast_list(dev);
+}
+EXPORT_SYMBOL(eip_set_multicast_list);
+
+void eip_tx_timeout(struct net_device *dev)
+{
+	__ei_tx_timeout(dev);
+}
+EXPORT_SYMBOL(eip_tx_timeout);
+
 irqreturn_t eip_interrupt(int irq, void *dev_id)
 {
 	return __ei_interrupt(irq, dev_id);
@@ -36,6 +60,21 @@ void eip_poll(struct net_device *dev)
 EXPORT_SYMBOL(eip_poll);
 #endif
 
+const struct net_device_ops eip_netdev_ops = {
+	.ndo_open		= eip_open,
+	.ndo_stop		= eip_close,
+	.ndo_start_xmit		= eip_start_xmit,
+	.ndo_tx_timeout		= eip_tx_timeout,
+	.ndo_get_stats		= eip_get_stats,
+	.ndo_set_multicast_list = eip_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= eip_poll,
+#endif
+};
+EXPORT_SYMBOL(eip_netdev_ops);
+
 struct net_device *__alloc_eip_netdev(int size)
 {
 	return ____alloc_ei_netdev(size);
--- a/drivers/net/lib8390.c	2008-11-25 17:08:44.000000000 -0800
+++ b/drivers/net/lib8390.c	2008-11-25 17:08:47.000000000 -0800
@@ -205,12 +205,6 @@ static int __ei_open(struct net_device *
 	unsigned long flags;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 
-	/* The card I/O part of the driver (e.g. 3c503) can hook a Tx timeout
-	    wrapper that does e.g. media check & then calls ei_tx_timeout. */
-#ifdef CONFIG_COMPAT_NET_DEV_OPS
-	if (dev->tx_timeout == NULL)
-		 dev->tx_timeout = ei_tx_timeout;
-#endif
 	if (dev->watchdog_timeo <= 0)
 		 dev->watchdog_timeo = TX_TIMEOUT;
 
@@ -259,7 +253,7 @@ static int __ei_close(struct net_device 
  * completed (or failed) - i.e. never posted a Tx related interrupt.
  */
 
-void ei_tx_timeout(struct net_device *dev)
+static void __ei_tx_timeout(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -296,7 +290,6 @@ void ei_tx_timeout(struct net_device *de
 	enable_irq_lockdep(dev->irq);
 	netif_wake_queue(dev);
 }
-EXPORT_SYMBOL_GPL(ei_tx_timeout);
 
 /**
  * ei_start_xmit - begin packet transmission
@@ -306,7 +299,7 @@ EXPORT_SYMBOL_GPL(ei_tx_timeout);
  * Sends a packet to an 8390 network device.
  */
 
-int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -423,7 +416,6 @@ int ei_start_xmit(struct sk_buff *skb, s
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(ei_start_xmit);
 
 /**
  * ei_interrupt - handle the interrupts from an 8390
@@ -885,7 +877,7 @@ static void ei_rx_overrun(struct net_dev
  *	Collect the stats. This is called unlocked and from several contexts.
  */
 
-struct net_device_stats *ei_get_stats(struct net_device *dev)
+static struct net_device_stats *__ei_get_stats(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -904,7 +896,6 @@ struct net_device_stats *ei_get_stats(st
 
 	return &dev->stats;
 }
-EXPORT_SYMBOL_GPL(ei_get_stats);
 
 /*
  * Form the 64 bit 8390 multicast table from the linked list of addresses
@@ -995,7 +986,7 @@ static void do_set_multicast_list(struct
  *	not called too often. Must protect against both bh and irq users
  */
 
-void ei_set_multicast_list(struct net_device *dev)
+static void __ei_set_multicast_list(struct net_device *dev)
 {
 	unsigned long flags;
 	struct ei_device *ei_local = (struct ei_device*)netdev_priv(dev);
@@ -1004,7 +995,6 @@ void ei_set_multicast_list(struct net_de
 	do_set_multicast_list(dev);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 }
-EXPORT_SYMBOL_GPL(ei_set_multicast_list);
 
 /**
  * ethdev_setup - init rest of 8390 device struct
@@ -1024,6 +1014,7 @@ static void ethdev_setup(struct net_devi
 	dev->hard_start_xmit = ei_start_xmit;
 	dev->get_stats	= ei_get_stats;
 	dev->set_multicast_list = ei_set_multicast_list;
+	dev->tx_timeout = __ei_tx_timeout;
 #endif
 	ether_setup(dev);
 


