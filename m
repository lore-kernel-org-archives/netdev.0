From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v6 4/6] net-sysfs: add support for device-specific rx queue sysfs attributes
Date: Thu, 16 Jan 2014 22:23:28 -0800
Message-ID: <1389939810-14998-5-git-send-email-mwdalton@google.com>
References: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:44752 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaAQGXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:23:41 -0500
Received: by mail-ie0-f202.google.com with SMTP id x13so905707ief.5
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 22:23:40 -0800 (PST)
In-Reply-To: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend existing support for netdevice receive queue sysfs attributes to
permit a device-specific attribute group. Initial use case for this
support will be to allow the virtio-net device to export per-receive
queue mergeable receive buffer size.

Signed-off-by: Michael Dalton <mwdalton@google.com>
---
v4->v5: Handle sysfs_create_group failure. Call sysfs_remove_group when
        removing a RX queue kobj if a device-specific group exists.
v3->v4: Simplify by removing loop in get_netdev_rx_queue_index.

 include/linux/netdevice.h | 35 +++++++++++++++++++++++++++++----
 net/core/dev.c            | 12 ++++++------
 net/core/net-sysfs.c      | 50 +++++++++++++++++++++++++++--------------------
 3 files changed, 66 insertions(+), 31 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d7668b88..e985231 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -668,15 +668,28 @@ extern struct rps_sock_flow_table __rcu *rps_sock_flow_table;
 bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index, u32 flow_id,
 			 u16 filter_id);
 #endif
+#endif /* CONFIG_RPS */
 
 /* This structure contains an instance of an RX queue. */
 struct netdev_rx_queue {
+#ifdef CONFIG_RPS
 	struct rps_map __rcu		*rps_map;
 	struct rps_dev_flow_table __rcu	*rps_flow_table;
+#endif
 	struct kobject			kobj;
 	struct net_device		*dev;
 } ____cacheline_aligned_in_smp;
-#endif /* CONFIG_RPS */
+
+/*
+ * RX queue sysfs structures and functions.
+ */
+struct rx_queue_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct netdev_rx_queue *queue,
+	    struct rx_queue_attribute *attr, char *buf);
+	ssize_t (*store)(struct netdev_rx_queue *queue,
+	    struct rx_queue_attribute *attr, const char *buf, size_t len);
+};
 
 #ifdef CONFIG_XPS
 /*
@@ -1313,7 +1326,7 @@ struct net_device {
 						   unicast) */
 
 
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	struct netdev_rx_queue	*_rx;
 
 	/* Number of RX queues allocated at register_netdev() time */
@@ -1424,6 +1437,8 @@ struct net_device {
 	struct device		dev;
 	/* space for optional device, statistics, and wireless sysfs groups */
 	const struct attribute_group *sysfs_groups[4];
+	/* space for optional per-rx queue attributes */
+	const struct attribute_group *sysfs_rx_queue_group;
 
 	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
@@ -2375,7 +2390,7 @@ static inline bool netif_is_multiqueue(const struct net_device *dev)
 
 int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq);
 
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq);
 #else
 static inline int netif_set_real_num_rx_queues(struct net_device *dev,
@@ -2394,7 +2409,7 @@ static inline int netif_copy_real_num_queues(struct net_device *to_dev,
 					   from_dev->real_num_tx_queues);
 	if (err)
 		return err;
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	return netif_set_real_num_rx_queues(to_dev,
 					    from_dev->real_num_rx_queues);
 #else
@@ -2402,6 +2417,18 @@ static inline int netif_copy_real_num_queues(struct net_device *to_dev,
 #endif
 }
 
+#ifdef CONFIG_SYSFS
+static inline unsigned int get_netdev_rx_queue_index(
+		struct netdev_rx_queue *queue)
+{
+	struct net_device *dev = queue->dev;
+	int index = queue - dev->_rx;
+
+	BUG_ON(index >= dev->num_rx_queues);
+	return index;
+}
+#endif
+
 #define DEFAULT_MAX_NUM_RSS_QUEUES	(8)
 int netif_get_num_default_rss_queues(void);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index f87bedd..288df62 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2083,7 +2083,7 @@ int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 }
 EXPORT_SYMBOL(netif_set_real_num_tx_queues);
 
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 /**
  *	netif_set_real_num_rx_queues - set actual number of RX queues used
  *	@dev: Network device
@@ -5764,7 +5764,7 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 static int netif_alloc_rx_queues(struct net_device *dev)
 {
 	unsigned int i, count = dev->num_rx_queues;
@@ -6309,7 +6309,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		return NULL;
 	}
 
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	if (rxqs < 1) {
 		pr_err("alloc_netdev: Unable to allocate device with zero RX queues\n");
 		return NULL;
@@ -6365,7 +6365,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	if (netif_alloc_netdev_queues(dev))
 		goto free_all;
 
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	dev->num_rx_queues = rxqs;
 	dev->real_num_rx_queues = rxqs;
 	if (netif_alloc_rx_queues(dev))
@@ -6385,7 +6385,7 @@ free_all:
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
 	netif_free_tx_queues(dev);
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	kfree(dev->_rx);
 #endif
 
@@ -6410,7 +6410,7 @@ void free_netdev(struct net_device *dev)
 	release_net(dev_net(dev));
 
 	netif_free_tx_queues(dev);
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	kfree(dev->_rx);
 #endif
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 49843bf..7eeadee 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -498,17 +498,7 @@ static struct attribute_group wireless_group = {
 #define net_class_groups	NULL
 #endif /* CONFIG_SYSFS */
 
-#ifdef CONFIG_RPS
-/*
- * RX queue sysfs structures and functions.
- */
-struct rx_queue_attribute {
-	struct attribute attr;
-	ssize_t (*show)(struct netdev_rx_queue *queue,
-	    struct rx_queue_attribute *attr, char *buf);
-	ssize_t (*store)(struct netdev_rx_queue *queue,
-	    struct rx_queue_attribute *attr, const char *buf, size_t len);
-};
+#ifdef CONFIG_SYSFS
 #define to_rx_queue_attr(_attr) container_of(_attr,		\
     struct rx_queue_attribute, attr)
 
@@ -543,6 +533,7 @@ static const struct sysfs_ops rx_queue_sysfs_ops = {
 	.store = rx_queue_attr_store,
 };
 
+#ifdef CONFIG_RPS
 static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 			    struct rx_queue_attribute *attribute, char *buf)
 {
@@ -718,16 +709,20 @@ static struct rx_queue_attribute rps_cpus_attribute =
 static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute =
 	__ATTR(rps_flow_cnt, S_IRUGO | S_IWUSR,
 	    show_rps_dev_flow_table_cnt, store_rps_dev_flow_table_cnt);
+#endif /* CONFIG_RPS */
 
 static struct attribute *rx_queue_default_attrs[] = {
+#ifdef CONFIG_RPS
 	&rps_cpus_attribute.attr,
 	&rps_dev_flow_table_cnt_attribute.attr,
+#endif
 	NULL
 };
 
 static void rx_queue_release(struct kobject *kobj)
 {
 	struct netdev_rx_queue *queue = to_rx_queue(kobj);
+#ifdef CONFIG_RPS
 	struct rps_map *map;
 	struct rps_dev_flow_table *flow_table;
 
@@ -743,6 +738,7 @@ static void rx_queue_release(struct kobject *kobj)
 		RCU_INIT_POINTER(queue->rps_flow_table, NULL);
 		call_rcu(&flow_table->rcu, rps_dev_flow_table_release);
 	}
+#endif
 
 	memset(kobj, 0, sizeof(*kobj));
 	dev_put(queue->dev);
@@ -763,25 +759,36 @@ static int rx_queue_add_kobject(struct net_device *net, int index)
 	kobj->kset = net->queues_kset;
 	error = kobject_init_and_add(kobj, &rx_queue_ktype, NULL,
 	    "rx-%u", index);
-	if (error) {
-		kobject_put(kobj);
-		return error;
+	if (error)
+		goto exit;
+
+	if (net->sysfs_rx_queue_group) {
+		error = sysfs_create_group(kobj, net->sysfs_rx_queue_group);
+		if (error)
+			goto exit;
 	}
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
 	return error;
+exit:
+	kobject_put(kobj);
+	return error;
 }
-#endif /* CONFIG_RPS */
+#endif /* CONFIG_SYFS */
 
 int
 net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 {
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	int i;
 	int error = 0;
 
+#ifndef CONFIG_RPS
+	if (!net->sysfs_rx_queue_group)
+		return 0;
+#endif
 	for (i = old_num; i < new_num; i++) {
 		error = rx_queue_add_kobject(net, i);
 		if (error) {
@@ -790,8 +797,12 @@ net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 		}
 	}
 
-	while (--i >= new_num)
+	while (--i >= new_num) {
+		if (net->sysfs_rx_queue_group)
+			sysfs_remove_group(&net->_rx[i].kobj,
+					   net->sysfs_rx_queue_group);
 		kobject_put(&net->_rx[i].kobj);
+	}
 
 	return error;
 #else
@@ -1155,9 +1166,6 @@ static int register_queue_kobjects(struct net_device *net)
 	    NULL, &net->dev.kobj);
 	if (!net->queues_kset)
 		return -ENOMEM;
-#endif
-
-#ifdef CONFIG_RPS
 	real_rx = net->real_num_rx_queues;
 #endif
 	real_tx = net->real_num_tx_queues;
@@ -1184,7 +1192,7 @@ static void remove_queue_kobjects(struct net_device *net)
 {
 	int real_rx = 0, real_tx = 0;
 
-#ifdef CONFIG_RPS
+#ifdef CONFIG_SYSFS
 	real_rx = net->real_num_rx_queues;
 #endif
 	real_tx = net->real_num_tx_queues;
-- 
1.8.5.2
