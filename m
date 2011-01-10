From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] net: Add alloc_netdev_mqs function
Date: Sun, 9 Jan 2011 21:36:31 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1101092124040.3353@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23393 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab1AJFge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 00:36:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added alloc_netdev_mqs function which allows the number of transmit and
receive queues to be specified independenty.  alloc_netdev_mq was
changed to a macro to call the new function.  Also added
alloc_etherdev_mqs with same purpose.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/etherdevice.h |    4 +++-
 include/linux/netdevice.h   |   10 +++++++---
 net/core/dev.c              |   32 +++++++++++++++++++++-----------
 net/ethernet/eth.c          |   12 +++++++-----
 4 files changed, 38 insertions(+), 20 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index f16a010..bec8b82 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -48,8 +48,10 @@ extern int eth_validate_addr(struct net_device *dev);
 
 
 
-extern struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count);
+extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
+					    unsigned int rxqs);
 #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
+#define alloc_etherdev_mq(sizeof_priv, count) alloc_etherdev_mqs(sizeof_priv, count, count)
 
 /**
  * is_zero_ether_addr - Determine if give Ethernet address is all zeros.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0f6b1c9..132baf4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2191,11 +2191,15 @@ static inline void netif_addr_unlock_bh(struct net_device *dev)
 extern void		ether_setup(struct net_device *dev);
 
 /* Support for loadable net-drivers */
-extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
+extern struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *),
-				       unsigned int queue_count);
+				       unsigned int txqs, unsigned int rxqs);
 #define alloc_netdev(sizeof_priv, name, setup) \
-	alloc_netdev_mq(sizeof_priv, name, setup, 1)
+	alloc_netdev_mqs(sizeof_priv, name, setup, 1, 1)
+
+#define alloc_netdev_mq(sizeof_priv, name, setup, count) \
+	alloc_netdev_mqs(sizeof_priv, name, setup, count, count)
+
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index a215269..d13cd64 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5621,18 +5621,20 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 }
 
 /**
- *	alloc_netdev_mq - allocate network device
+ *	alloc_netdev_mqs - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
  *	@name:		device name format string
  *	@setup:		callback to initialize device
- *	@queue_count:	the number of subqueues to allocate
+ *	@txqs:		the number of TX subqueues to allocate
+ *	@rxqs:		the number of RX subqueues to allocate
  *
  *	Allocates a struct net_device with private data area for driver use
  *	and performs basic initialization.  Also allocates subquue structs
- *	for each queue on the device at the end of the netdevice.
+ *	for each queue on the device.
  */
-struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
-		void (*setup)(struct net_device *), unsigned int queue_count)
+struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
+		void (*setup)(struct net_device *),
+		unsigned int txqs, unsigned int rxqs)
 {
 	struct net_device *dev;
 	size_t alloc_size;
@@ -5640,12 +5642,20 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
-	if (queue_count < 1) {
+	if (txqs < 1) {
 		pr_err("alloc_netdev: Unable to allocate device "
 		       "with zero queues.\n");
 		return NULL;
 	}
 
+#ifdef CONFIG_RPS
+	if (rxqs < 1) {
+		pr_err("alloc_netdev: Unable to allocate device "
+		       "with zero RX queues.\n");
+		return NULL;
+	}
+#endif
+
 	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
 		/* ensure 32-byte alignment of private area */
@@ -5676,14 +5686,14 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev_net_set(dev, &init_net);
 
-	dev->num_tx_queues = queue_count;
-	dev->real_num_tx_queues = queue_count;
+	dev->num_tx_queues = txqs;
+	dev->real_num_tx_queues = txqs;
 	if (netif_alloc_netdev_queues(dev))
 		goto free_pcpu;
 
 #ifdef CONFIG_RPS
-	dev->num_rx_queues = queue_count;
-	dev->real_num_rx_queues = queue_count;
+	dev->num_rx_queues = rxqs;
+	dev->real_num_rx_queues = rxqs;
 	if (netif_alloc_rx_queues(dev))
 		goto free_pcpu;
 #endif
@@ -5711,7 +5721,7 @@ free_p:
 	kfree(p);
 	return NULL;
 }
-EXPORT_SYMBOL(alloc_netdev_mq);
+EXPORT_SYMBOL(alloc_netdev_mqs);
 
 /**
  *	free_netdev - free network device
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index f00ef2f..f9d7ac9 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -347,10 +347,11 @@ void ether_setup(struct net_device *dev)
 EXPORT_SYMBOL(ether_setup);
 
 /**
- * alloc_etherdev_mq - Allocates and sets up an Ethernet device
+ * alloc_etherdev_mqs - Allocates and sets up an Ethernet device
  * @sizeof_priv: Size of additional driver-private structure to be allocated
  *	for this Ethernet device
- * @queue_count: The number of queues this device has.
+ * @txqs: The number of TX queues this device has.
+ * @txqs: The number of RX queues this device has.
  *
  * Fill in the fields of the device structure with Ethernet-generic
  * values. Basically does everything except registering the device.
@@ -360,11 +361,12 @@ EXPORT_SYMBOL(ether_setup);
  * this private data area.
  */
 
-struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count)
+struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
+				      unsigned int rxqs)
 {
-	return alloc_netdev_mq(sizeof_priv, "eth%d", ether_setup, queue_count);
+	return alloc_netdev_mqs(sizeof_priv, "eth%d", ether_setup, txqs, rxqs);
 }
-EXPORT_SYMBOL(alloc_etherdev_mq);
+EXPORT_SYMBOL(alloc_etherdev_mqs);
 
 static size_t _format_mac_addr(char *buf, int buflen,
 			       const unsigned char *addr, int len)
-- 
1.7.3.1


