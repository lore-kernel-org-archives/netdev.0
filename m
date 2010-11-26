From: Tom Herbert <therbert@google.com>
Subject: [PATCH] xps: Add CONFIG_XPS
Date: Fri, 26 Nov 2010 10:36:09 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1011261033070.20580@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:31293 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090Ab0KZSgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 13:36:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds XPS_CONFIG option to enable and disable XPS.  This is
done in the same manner as RPS_CONFIG.  This is also fixes build
failure in XPS code when SMP is not enabled.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   52 ++++++++++++++++++++++++--------------------
 net/Kconfig               |    5 ++++
 net/core/dev.c            |    9 +++++--
 net/core/net-sysfs.c      |   47 +++++++++++++++++++++++++++++-----------
 net/core/net-sysfs.h      |    3 --
 5 files changed, 73 insertions(+), 43 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index badf928..bb8ee72 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -534,30 +534,6 @@ struct rps_map {
 #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
 
 /*
- * This structure holds an XPS map which can be of variable length.  The
- * map is an array of queues.
- */
-struct xps_map {
-	unsigned int len;
-	unsigned int alloc_len;
-	struct rcu_head rcu;
-	u16 queues[0];
-};
-#define XPS_MAP_SIZE(_num) (sizeof(struct xps_map) + (_num * sizeof(u16)))
-#define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))	\
-    / sizeof(u16))
-
-/*
- * This structure holds all XPS maps for device.  Maps are indexed by CPU.
- */
-struct xps_dev_maps {
-	struct rcu_head rcu;
-	struct xps_map *cpu_map[0];
-};
-#define XPS_DEV_MAPS_SIZE (sizeof(struct xps_dev_maps) +		\
-    (nr_cpu_ids * sizeof(struct xps_map *)))
-
-/*
  * The rps_dev_flow structure contains the mapping of a flow to a CPU and the
  * tail pointer for that CPU's input queue at the time of last enqueue.
  */
@@ -624,6 +600,32 @@ struct netdev_rx_queue {
 } ____cacheline_aligned_in_smp;
 #endif /* CONFIG_RPS */
 
+#ifdef CONFIG_XPS
+/*
+ * This structure holds an XPS map which can be of variable length.  The
+ * map is an array of queues.
+ */
+struct xps_map {
+	unsigned int len;
+	unsigned int alloc_len;
+	struct rcu_head rcu;
+	u16 queues[0];
+};
+#define XPS_MAP_SIZE(_num) (sizeof(struct xps_map) + (_num * sizeof(u16)))
+#define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))	\
+    / sizeof(u16))
+
+/*
+ * This structure holds all XPS maps for device.  Maps are indexed by CPU.
+ */
+struct xps_dev_maps {
+	struct rcu_head rcu;
+	struct xps_map *cpu_map[0];
+};
+#define XPS_DEV_MAPS_SIZE (sizeof(struct xps_dev_maps) +		\
+    (nr_cpu_ids * sizeof(struct xps_map *)))
+#endif /* CONFIG_XPS */
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1044,7 +1046,9 @@ struct net_device {
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
 
+#ifdef CONFIG_XPS
 	struct xps_dev_maps	*xps_maps;
+#endif
 
 	/* These may be needed for future network-power-down code. */
 
diff --git a/net/Kconfig b/net/Kconfig
index 55fd82e..126c2af 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -220,6 +220,11 @@ config RPS
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
 
+config XPS
+	boolean
+	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
+	default y
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/dev.c b/net/core/dev.c
index c852f00..3259d2c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1567,6 +1567,9 @@ int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 
 		rc = netdev_queue_update_kobjects(dev, dev->real_num_tx_queues,
 						  txq);
+		if (rc)
+			return rc;
+
 		if (txq < dev->real_num_tx_queues)
 			qdisc_reset_all_tx_gt(dev, txq);
 	}
@@ -2148,7 +2151,7 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
-#ifdef CONFIG_RPS
+#ifdef CONFIG_XPS
 	struct xps_dev_maps *dev_maps;
 	struct xps_map *map;
 	int queue_index = -1;
@@ -5085,9 +5088,9 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
+#ifdef CONFIG_RPS
 static int netif_alloc_rx_queues(struct net_device *dev)
 {
-#ifdef CONFIG_RPS
 	unsigned int i, count = dev->num_rx_queues;
 	struct netdev_rx_queue *rx;
 
@@ -5102,9 +5105,9 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 
 	for (i = 0; i < count; i++)
 		rx[i].dev = dev;
-#endif
 	return 0;
 }
+#endif
 
 static int netif_alloc_netdev_queues(struct net_device *dev)
 {
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 68dbbfd..99c1129 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -751,10 +751,12 @@ static int rx_queue_add_kobject(struct net_device *net, int index)
 
 	return error;
 }
+#endif /* CONFIG_RPS */
 
 int
 net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 {
+#ifdef CONFIG_RPS
 	int i;
 	int error = 0;
 
@@ -770,8 +772,12 @@ net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 		kobject_put(&net->_rx[i].kobj);
 
 	return error;
+#else
+	return 0;
+#endif
 }
 
+#ifdef CONFIG_XPS
 /*
  * netdev_queue sysfs structures and functions.
  */
@@ -1090,10 +1096,12 @@ static int netdev_queue_add_kobject(struct net_device *net, int index)
 
 	return error;
 }
+#endif /* CONFIG_XPS */
 
 int
 netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 {
+#ifdef CONFIG_XPS
 	int i;
 	int error = 0;
 
@@ -1109,27 +1117,36 @@ netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 		kobject_put(&net->_tx[i].kobj);
 
 	return error;
+#else
+	return 0;
+#endif
 }
 
 static int register_queue_kobjects(struct net_device *net)
 {
-	int error = 0, txq = 0, rxq = 0;
+	int error = 0, txq = 0, rxq = 0, real_rx = 0, real_tx = 0;
 
+#if defined(CONFIG_RPS) || defined(CONFIG_XPS)
 	net->queues_kset = kset_create_and_add("queues",
 	    NULL, &net->dev.kobj);
 	if (!net->queues_kset)
 		return -ENOMEM;
+#endif
+
+#ifdef CONFIG_RPS
+	real_rx = net->real_num_rx_queues;
+#endif
+	real_tx = net->real_num_tx_queues;
 
-	error = net_rx_queue_update_kobjects(net, 0, net->real_num_rx_queues);
+	error = net_rx_queue_update_kobjects(net, 0, real_rx);
 	if (error)
 		goto error;
-	rxq = net->real_num_rx_queues;
+	rxq = real_rx;
 
-	error = netdev_queue_update_kobjects(net, 0,
-					     net->real_num_tx_queues);
+	error = netdev_queue_update_kobjects(net, 0, real_tx);
 	if (error)
 		goto error;
-	txq = net->real_num_tx_queues;
+	txq = real_tx;
 
 	return 0;
 
@@ -1141,11 +1158,19 @@ error:
 
 static void remove_queue_kobjects(struct net_device *net)
 {
-	net_rx_queue_update_kobjects(net, net->real_num_rx_queues, 0);
-	netdev_queue_update_kobjects(net, net->real_num_tx_queues, 0);
+	int real_rx = 0, real_tx = 0;
+
+#ifdef CONFIG_RPS
+	real_rx = net->real_num_rx_queues;
+#endif
+	real_tx = net->real_num_tx_queues;
+
+	net_rx_queue_update_kobjects(net, real_rx, 0);
+	netdev_queue_update_kobjects(net, real_tx, 0);
+#if defined(CONFIG_RPS) || defined(CONFIG_XPS)
 	kset_unregister(net->queues_kset);
+#endif
 }
-#endif /* CONFIG_RPS */
 
 static const void *net_current_ns(void)
 {
@@ -1244,9 +1269,7 @@ void netdev_unregister_kobject(struct net_device * net)
 
 	kobject_get(&dev->kobj);
 
-#ifdef CONFIG_RPS
 	remove_queue_kobjects(net);
-#endif
 
 	device_del(dev);
 }
@@ -1285,13 +1308,11 @@ int netdev_register_kobject(struct net_device *net)
 	if (error)
 		return error;
 
-#ifdef CONFIG_RPS
 	error = register_queue_kobjects(net);
 	if (error) {
 		device_del(dev);
 		return error;
 	}
-#endif
 
 	return error;
 }
diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
index 25ec2ee..bd7751e 100644
--- a/net/core/net-sysfs.h
+++ b/net/core/net-sysfs.h
@@ -4,11 +4,8 @@
 int netdev_kobject_init(void);
 int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
-#ifdef CONFIG_RPS
 int net_rx_queue_update_kobjects(struct net_device *, int old_num, int new_num);
 int netdev_queue_update_kobjects(struct net_device *net,
 				 int old_num, int new_num);
 
 #endif
-
-#endif
-- 
1.7.3.1

