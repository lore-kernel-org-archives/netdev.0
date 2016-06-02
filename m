From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/2] net: Add function to allow configuration of RPS
Date: Wed, 01 Jun 2016 18:17:18 -0700
Message-ID: <20160602011718.9319.31286.stgit@localhost.localdomain>
References: <20160602010741.9319.56926.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35359 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbcFBBRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 21:17:20 -0400
Received: by mail-pf0-f176.google.com with SMTP id g64so24385368pfb.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 18:17:20 -0700 (PDT)
In-Reply-To: <20160602010741.9319.56926.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gives drivers the ability to set their own default RPS
configuration.  The general idea is to allow drivers that might benefit
from enabling RPS an opportunity to configure it for themselves.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdevice.h |    9 ++++++++
 net/core/dev.c            |   51 ++++++++++++++++++++++++++++++++++++++++++++-
 net/core/net-sysfs.c      |   45 +++++++---------------------------------
 3 files changed, 67 insertions(+), 38 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f45929ce8157..329d554c9219 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -684,6 +684,15 @@ static inline void rps_record_sock_flow(struct rps_sock_flow_table *table,
 bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index, u32 flow_id,
 			 u16 filter_id);
 #endif
+int netif_set_rps_cpus(struct net_device *dev, const struct cpumask *mask,
+		       u16 index);
+#else
+static inline int netif_set_rps_cpus(struct net_device *dev,
+				     const struct cpumask *mask,
+				     u16 index)
+{
+	return 0;
+}
 #endif /* CONFIG_RPS */
 
 /* This structure contains an instance of an RX queue. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff431d570..efdcc917cf02 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1934,7 +1934,7 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 		return;
 	}
 
-	/* Invalidated prio to tc mappings set to TC0 */
+	/* Invaldated prio to tc mappings set to TC0 */
 	for (i = 1; i < TC_BITMASK + 1; i++) {
 		int q = netdev_get_prio_tc_map(dev, i);
 
@@ -1947,6 +1947,55 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 	}
 }
 
+#ifdef CONFIG_RPS
+int netif_set_rps_cpus(struct net_device *dev, const struct cpumask *mask,
+		       u16 index)
+{
+	static DEFINE_MUTEX(rps_map_mutex);
+	struct netdev_rx_queue *queue;
+	struct rps_map *old_map, *map;
+	int cpu, map_sz;
+
+	if (index >= dev->real_num_rx_queues)
+		return -EINVAL;
+
+	map_sz = max_t(unsigned int,
+		       L1_CACHE_BYTES,
+		       RPS_MAP_SIZE(cpumask_weight(mask)));
+	map = kzalloc(map_sz, GFP_KERNEL);
+
+	if (!map)
+		return -ENOMEM;
+
+	for_each_cpu_and(cpu, mask, cpu_online_mask)
+		map->cpus[map->len++] = cpu;
+
+	if (!map->len) {
+		kfree(map);
+		map = NULL;
+	}
+
+	queue = dev->_rx + index;
+	mutex_lock(&rps_map_mutex);
+
+	old_map = rcu_dereference_protected(queue->rps_map,
+					    mutex_is_locked(&rps_map_mutex));
+	rcu_assign_pointer(queue->rps_map, map);
+
+	if (map)
+		static_key_slow_inc(&rps_needed);
+	if (old_map)
+		static_key_slow_dec(&rps_needed);
+
+	mutex_unlock(&rps_map_mutex);
+
+	if (old_map)
+		kfree_rcu(old_map, rcu);
+
+	return 0;
+}
+EXPORT_SYMBOL(netif_set_rps_cpus);
+#endif /* CONFIG_RPS */
 #ifdef CONFIG_XPS
 static DEFINE_MUTEX(xps_map_mutex);
 #define xmap_dereference(P)		\
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2b3f76fe65f4..1d270744b296 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -690,10 +690,10 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 		      struct rx_queue_attribute *attribute,
 		      const char *buf, size_t len)
 {
-	struct rps_map *old_map, *map;
+	struct net_device *dev = queue->dev;
+	unsigned long index;
 	cpumask_var_t mask;
-	int err, cpu, i;
-	static DEFINE_MUTEX(rps_map_mutex);
+	int err;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -701,48 +701,19 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
 		return -ENOMEM;
 
+	index = get_netdev_rx_queue_index(queue);
+
 	err = bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
 	if (err) {
 		free_cpumask_var(mask);
 		return err;
 	}
 
-	map = kzalloc(max_t(unsigned int,
-	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CACHE_BYTES),
-	    GFP_KERNEL);
-	if (!map) {
-		free_cpumask_var(mask);
-		return -ENOMEM;
-	}
-
-	i = 0;
-	for_each_cpu_and(cpu, mask, cpu_online_mask)
-		map->cpus[i++] = cpu;
-
-	if (i)
-		map->len = i;
-	else {
-		kfree(map);
-		map = NULL;
-	}
-
-	mutex_lock(&rps_map_mutex);
-	old_map = rcu_dereference_protected(queue->rps_map,
-					    mutex_is_locked(&rps_map_mutex));
-	rcu_assign_pointer(queue->rps_map, map);
-
-	if (map)
-		static_key_slow_inc(&rps_needed);
-	if (old_map)
-		static_key_slow_dec(&rps_needed);
-
-	mutex_unlock(&rps_map_mutex);
-
-	if (old_map)
-		kfree_rcu(old_map, rcu);
+	err = netif_set_rps_cpus(dev, mask, index);
 
 	free_cpumask_var(mask);
-	return len;
+
+	return err ? : len;
 }
 
 static ssize_t show_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
