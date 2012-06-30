From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 02/10] net: Add functions netif_reset_xps_queue and
	netif_set_xps_queue
Date: Fri, 29 Jun 2012 17:16:23 -0700
Message-ID: <20120630001623.29939.36063.stgit@gitlad.jf.intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59124 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755927Ab2F3AQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:16:04 -0400
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two functions, netif_reset_xps_queue and
netif_set_xps_queue.  The main idea behind these to functions is to provide
a mechanism through which drivers can update their defaults in regards to
XPS.

Currently no such mechanism exists and as a result we cannot use XPS for
things such as ATR which would require a basic configuration to start in
which the Tx queues are mapped to CPUs via a 1:1 mapping.  With this change
I am making it possible for drivers such as ixgbe to be able to use the XPS
feature by controlling the default configuration.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/netdevice.h |   13 ++++
 net/core/dev.c            |  155 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-sysfs.c      |  148 +------------------------------------------
 3 files changed, 173 insertions(+), 143 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3329d70..e9e74b7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2072,6 +2072,19 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 		__netif_schedule(txq->qdisc);
 }
 
+#ifdef CONFIG_XPS
+extern void netif_reset_xps_queue(struct net_device *dev, u16 index);
+extern int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask,
+			       u16 index);
+#else
+static inline int netif_set_xps_queue(struct net_device *dev,
+				      struct cpumask *mask,
+				      u16 index)
+{
+	return 0;
+}
+#endif
+
 /*
  * Returns a Tx hash for the given packet when dev->real_num_tx_queues is used
  * as a distribution range limit for the returned value.
diff --git a/net/core/dev.c b/net/core/dev.c
index b31a9ff..4c0981b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1728,6 +1728,161 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 	}
 }
 
+#ifdef CONFIG_XPS
+static DEFINE_MUTEX(xps_map_mutex);
+#define xmap_dereference(P)		\
+	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
+
+void netif_reset_xps_queue(struct net_device *dev, u16 index)
+{
+	struct xps_dev_maps *dev_maps;
+	struct xps_map *map;
+	int i, pos, nonempty = 0;
+
+	mutex_lock(&xps_map_mutex);
+	dev_maps = xmap_dereference(dev->xps_maps);
+
+	if (!dev_maps)
+		goto out_no_maps;
+
+	for_each_possible_cpu(i) {
+		map = xmap_dereference(dev_maps->cpu_map[i]);
+		if (!map)
+			continue;
+
+		for (pos = 0; pos < map->len; pos++)
+			if (map->queues[pos] == index)
+				break;
+
+		if (pos < map->len) {
+			if (map->len > 1) {
+				map->queues[pos] = map->queues[--map->len];
+			} else {
+				RCU_INIT_POINTER(dev_maps->cpu_map[i], NULL);
+				kfree_rcu(map, rcu);
+				map = NULL;
+			}
+		}
+		if (map)
+			nonempty = 1;
+	}
+
+	if (!nonempty) {
+		RCU_INIT_POINTER(dev->xps_maps, NULL);
+		kfree_rcu(dev_maps, rcu);
+	}
+
+out_no_maps:
+	mutex_unlock(&xps_map_mutex);
+}
+
+int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask, u16 index)
+{
+	int i, cpu, pos, map_len, alloc_len, need_set;
+	struct xps_map *map, *new_map;
+	struct xps_dev_maps *dev_maps, *new_dev_maps;
+	int nonempty = 0;
+	int numa_node_id = -2;
+	int maps_sz = max_t(unsigned int, XPS_DEV_MAPS_SIZE, L1_CACHE_BYTES);
+
+	new_dev_maps = kzalloc(maps_sz, GFP_KERNEL);
+	if (!new_dev_maps)
+		return -ENOMEM;
+
+	mutex_lock(&xps_map_mutex);
+
+	dev_maps = xmap_dereference(dev->xps_maps);
+
+	for_each_possible_cpu(cpu) {
+		map = dev_maps ?
+			xmap_dereference(dev_maps->cpu_map[cpu]) : NULL;
+		new_map = map;
+		if (map) {
+			for (pos = 0; pos < map->len; pos++)
+				if (map->queues[pos] == index)
+					break;
+			map_len = map->len;
+			alloc_len = map->alloc_len;
+		} else
+			pos = map_len = alloc_len = 0;
+
+		need_set = cpumask_test_cpu(cpu, mask) && cpu_online(cpu);
+#ifdef CONFIG_NUMA
+		if (need_set) {
+			if (numa_node_id == -2)
+				numa_node_id = cpu_to_node(cpu);
+			else if (numa_node_id != cpu_to_node(cpu))
+				numa_node_id = -1;
+		}
+#endif
+		if (need_set && pos >= map_len) {
+			/* Need to add queue to this CPU's map */
+			if (map_len >= alloc_len) {
+				alloc_len = alloc_len ?
+				    2 * alloc_len : XPS_MIN_MAP_ALLOC;
+				new_map = kzalloc_node(XPS_MAP_SIZE(alloc_len),
+						       GFP_KERNEL,
+						       cpu_to_node(cpu));
+				if (!new_map)
+					goto error;
+				new_map->alloc_len = alloc_len;
+				for (i = 0; i < map_len; i++)
+					new_map->queues[i] = map->queues[i];
+				new_map->len = map_len;
+			}
+			new_map->queues[new_map->len++] = index;
+		} else if (!need_set && pos < map_len) {
+			/* Need to remove queue from this CPU's map */
+			if (map_len > 1)
+				new_map->queues[pos] =
+				    new_map->queues[--new_map->len];
+			else
+				new_map = NULL;
+		}
+		RCU_INIT_POINTER(new_dev_maps->cpu_map[cpu], new_map);
+	}
+
+	/* Cleanup old maps */
+	for_each_possible_cpu(cpu) {
+		map = dev_maps ?
+			xmap_dereference(dev_maps->cpu_map[cpu]) : NULL;
+		if (map && xmap_dereference(new_dev_maps->cpu_map[cpu]) != map)
+			kfree_rcu(map, rcu);
+		if (new_dev_maps->cpu_map[cpu])
+			nonempty = 1;
+	}
+
+	if (nonempty) {
+		rcu_assign_pointer(dev->xps_maps, new_dev_maps);
+	} else {
+		kfree(new_dev_maps);
+		RCU_INIT_POINTER(dev->xps_maps, NULL);
+	}
+
+	if (dev_maps)
+		kfree_rcu(dev_maps, rcu);
+
+	netdev_queue_numa_node_write(netdev_get_tx_queue(dev, index),
+				     (numa_node_id >= 0) ? numa_node_id :
+				     NUMA_NO_NODE);
+
+	mutex_unlock(&xps_map_mutex);
+
+	return 0;
+error:
+	mutex_unlock(&xps_map_mutex);
+
+	if (new_dev_maps)
+		for_each_possible_cpu(i)
+			kfree(rcu_dereference_protected(
+				new_dev_maps->cpu_map[i],
+				1));
+	kfree(new_dev_maps);
+	return -ENOMEM;
+}
+EXPORT_SYMBOL(netif_set_xps_queue);
+
+#endif
 /*
  * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
  * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7260717..092d338 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -963,54 +963,14 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
 	return len;
 }
 
-static DEFINE_MUTEX(xps_map_mutex);
-#define xmap_dereference(P)		\
-	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
-
 static void xps_queue_release(struct netdev_queue *queue)
 {
 	struct net_device *dev = queue->dev;
-	struct xps_dev_maps *dev_maps;
-	struct xps_map *map;
 	unsigned long index;
-	int i, pos, nonempty = 0;
 
 	index = get_netdev_queue_index(queue);
 
-	mutex_lock(&xps_map_mutex);
-	dev_maps = xmap_dereference(dev->xps_maps);
-
-	if (dev_maps) {
-		for_each_possible_cpu(i) {
-			map = xmap_dereference(dev_maps->cpu_map[i]);
-			if (!map)
-				continue;
-
-			for (pos = 0; pos < map->len; pos++)
-				if (map->queues[pos] == index)
-					break;
-
-			if (pos < map->len) {
-				if (map->len > 1)
-					map->queues[pos] =
-					    map->queues[--map->len];
-				else {
-					RCU_INIT_POINTER(dev_maps->cpu_map[i],
-					    NULL);
-					kfree_rcu(map, rcu);
-					map = NULL;
-				}
-			}
-			if (map)
-				nonempty = 1;
-		}
-
-		if (!nonempty) {
-			RCU_INIT_POINTER(dev->xps_maps, NULL);
-			kfree_rcu(dev_maps, rcu);
-		}
-	}
-	mutex_unlock(&xps_map_mutex);
+	netif_reset_xps_queue(dev, index);
 }
 
 static ssize_t store_xps_map(struct netdev_queue *queue,
@@ -1018,13 +978,9 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 		      const char *buf, size_t len)
 {
 	struct net_device *dev = queue->dev;
-	cpumask_var_t mask;
-	int err, i, cpu, pos, map_len, alloc_len, need_set;
 	unsigned long index;
-	struct xps_map *map, *new_map;
-	struct xps_dev_maps *dev_maps, *new_dev_maps;
-	int nonempty = 0;
-	int numa_node_id = -2;
+	cpumask_var_t mask;
+	int err;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -1040,105 +996,11 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 		return err;
 	}
 
-	new_dev_maps = kzalloc(max_t(unsigned int,
-	    XPS_DEV_MAPS_SIZE, L1_CACHE_BYTES), GFP_KERNEL);
-	if (!new_dev_maps) {
-		free_cpumask_var(mask);
-		return -ENOMEM;
-	}
-
-	mutex_lock(&xps_map_mutex);
-
-	dev_maps = xmap_dereference(dev->xps_maps);
-
-	for_each_possible_cpu(cpu) {
-		map = dev_maps ?
-			xmap_dereference(dev_maps->cpu_map[cpu]) : NULL;
-		new_map = map;
-		if (map) {
-			for (pos = 0; pos < map->len; pos++)
-				if (map->queues[pos] == index)
-					break;
-			map_len = map->len;
-			alloc_len = map->alloc_len;
-		} else
-			pos = map_len = alloc_len = 0;
-
-		need_set = cpumask_test_cpu(cpu, mask) && cpu_online(cpu);
-#ifdef CONFIG_NUMA
-		if (need_set) {
-			if (numa_node_id == -2)
-				numa_node_id = cpu_to_node(cpu);
-			else if (numa_node_id != cpu_to_node(cpu))
-				numa_node_id = -1;
-		}
-#endif
-		if (need_set && pos >= map_len) {
-			/* Need to add queue to this CPU's map */
-			if (map_len >= alloc_len) {
-				alloc_len = alloc_len ?
-				    2 * alloc_len : XPS_MIN_MAP_ALLOC;
-				new_map = kzalloc_node(XPS_MAP_SIZE(alloc_len),
-						       GFP_KERNEL,
-						       cpu_to_node(cpu));
-				if (!new_map)
-					goto error;
-				new_map->alloc_len = alloc_len;
-				for (i = 0; i < map_len; i++)
-					new_map->queues[i] = map->queues[i];
-				new_map->len = map_len;
-			}
-			new_map->queues[new_map->len++] = index;
-		} else if (!need_set && pos < map_len) {
-			/* Need to remove queue from this CPU's map */
-			if (map_len > 1)
-				new_map->queues[pos] =
-				    new_map->queues[--new_map->len];
-			else
-				new_map = NULL;
-		}
-		RCU_INIT_POINTER(new_dev_maps->cpu_map[cpu], new_map);
-	}
-
-	/* Cleanup old maps */
-	for_each_possible_cpu(cpu) {
-		map = dev_maps ?
-			xmap_dereference(dev_maps->cpu_map[cpu]) : NULL;
-		if (map && xmap_dereference(new_dev_maps->cpu_map[cpu]) != map)
-			kfree_rcu(map, rcu);
-		if (new_dev_maps->cpu_map[cpu])
-			nonempty = 1;
-	}
-
-	if (nonempty) {
-		rcu_assign_pointer(dev->xps_maps, new_dev_maps);
-	} else {
-		kfree(new_dev_maps);
-		RCU_INIT_POINTER(dev->xps_maps, NULL);
-	}
-
-	if (dev_maps)
-		kfree_rcu(dev_maps, rcu);
-
-	netdev_queue_numa_node_write(queue, (numa_node_id >= 0) ? numa_node_id :
-					    NUMA_NO_NODE);
-
-	mutex_unlock(&xps_map_mutex);
+	err = netif_set_xps_queue(dev, mask, index);
 
 	free_cpumask_var(mask);
-	return len;
 
-error:
-	mutex_unlock(&xps_map_mutex);
-
-	if (new_dev_maps)
-		for_each_possible_cpu(i)
-			kfree(rcu_dereference_protected(
-				new_dev_maps->cpu_map[i],
-				1));
-	kfree(new_dev_maps);
-	free_cpumask_var(mask);
-	return -ENOMEM;
+	return err ? : len;
 }
 
 static struct netdev_queue_attribute xps_cpus_attribute =
