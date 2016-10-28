From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 4/4] net: Add support for XPS with QoS via
 traffic classes
Date: Fri, 28 Oct 2016 11:50:13 -0400
Message-ID: <20161028154654.67826.25648.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161028154126.67826.76735.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, tom@herbertland.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20557 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753955AbcJ1Vu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 17:50:59 -0400
In-Reply-To: <20161028154126.67826.76735.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for setting and using XPS when QoS via traffic
classes is enabled.  With this change we will factor in the priority and
traffic class mapping of the packet and use that information to correctly
select the queue.

This allows us to define a set of queues for a given traffic class via
mqprio and then configure the XPS mapping for those queues so that the
traffic flows can avoid head-of-line blocking between the individual CPUs
if so desired.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: Mostly for loop updates based on changes in patch 3
    Replaced "i = 0; i < X; i++" with "i = X; i--;" as i was just a counter

 include/linux/netdevice.h |    4 +-
 net/core/dev.c            |  117 ++++++++++++++++++++++++++++++++-------------
 net/core/net-sysfs.c      |   31 ++++++++----
 3 files changed, 105 insertions(+), 47 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b60a156..56f90f7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -732,8 +732,8 @@ struct xps_dev_maps {
 	struct rcu_head rcu;
 	struct xps_map __rcu *cpu_map[0];
 };
-#define XPS_DEV_MAPS_SIZE (sizeof(struct xps_dev_maps) +		\
-    (nr_cpu_ids * sizeof(struct xps_map *)))
+#define XPS_DEV_MAPS_SIZE(_tcs) (sizeof(struct xps_dev_maps) +		\
+	(nr_cpu_ids * (_tcs) * sizeof(struct xps_map *)))
 #endif /* CONFIG_XPS */
 
 #define TC_MAX_QUEUE	16
diff --git a/net/core/dev.c b/net/core/dev.c
index fea7061..0ebb035 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2002,14 +2002,22 @@ static bool remove_xps_queue_cpu(struct net_device *dev,
 				 struct xps_dev_maps *dev_maps,
 				 int cpu, u16 offset, u16 count)
 {
-	int i, j;
+	int num_tc = dev->num_tc ? : 1;
+	bool active = false;
+	int tci;
 
-	for (i = count, j = offset; i--; j++) {
-		if (!remove_xps_queue(dev_maps, cpu, j))
-			break;
+	for (tci = cpu * num_tc; num_tc--; tci++) {
+		int i, j;
+
+		for (i = count, j = offset; i--; j++) {
+			if (!remove_xps_queue(dev_maps, cpu, j))
+				break;
+		}
+
+		active |= i < 0;
 	}
 
-	return i < 0;
+	return active;
 }
 
 static void netif_reset_xps_queues(struct net_device *dev, u16 offset,
@@ -2086,20 +2094,28 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 			u16 index)
 {
 	struct xps_dev_maps *dev_maps, *new_dev_maps = NULL;
+	int i, cpu, tci, numa_node_id = -2;
+	int maps_sz, num_tc = 1, tc = 0;
 	struct xps_map *map, *new_map;
-	int maps_sz = max_t(unsigned int, XPS_DEV_MAPS_SIZE, L1_CACHE_BYTES);
-	int cpu, numa_node_id = -2;
 	bool active = false;
 
+	if (dev->num_tc) {
+		num_tc = dev->num_tc;
+		tc = netdev_txq_to_tc(dev, index);
+		if (tc < 0)
+			return -EINVAL;
+	}
+
+	maps_sz = XPS_DEV_MAPS_SIZE(num_tc);
+	if (maps_sz < L1_CACHE_BYTES)
+		maps_sz = L1_CACHE_BYTES;
+
 	mutex_lock(&xps_map_mutex);
 
 	dev_maps = xmap_dereference(dev->xps_maps);
 
 	/* allocate memory for queue storage */
-	for_each_online_cpu(cpu) {
-		if (!cpumask_test_cpu(cpu, mask))
-			continue;
-
+	for_each_cpu_and(cpu, cpu_online_mask, mask) {
 		if (!new_dev_maps)
 			new_dev_maps = kzalloc(maps_sz, GFP_KERNEL);
 		if (!new_dev_maps) {
@@ -2107,25 +2123,38 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 			return -ENOMEM;
 		}
 
-		map = dev_maps ? xmap_dereference(dev_maps->cpu_map[cpu]) :
+		tci = cpu * num_tc + tc;
+		map = dev_maps ? xmap_dereference(dev_maps->cpu_map[tci]) :
 				 NULL;
 
 		map = expand_xps_map(map, cpu, index);
 		if (!map)
 			goto error;
 
-		RCU_INIT_POINTER(new_dev_maps->cpu_map[cpu], map);
+		RCU_INIT_POINTER(new_dev_maps->cpu_map[tci], map);
 	}
 
 	if (!new_dev_maps)
 		goto out_no_new_maps;
 
 	for_each_possible_cpu(cpu) {
+		/* copy maps belonging to foreign traffic classes */
+		for (i = tc, tci = cpu * num_tc; dev_maps && i--; tci++) {
+			/* fill in the new device map from the old device map */
+			map = xmap_dereference(dev_maps->cpu_map[tci]);
+			RCU_INIT_POINTER(new_dev_maps->cpu_map[tci], map);
+		}
+
+		/* We need to explicitly update tci as prevous loop
+		 * could break out early if dev_maps is NULL.
+		 */
+		tci = cpu * num_tc + tc;
+
 		if (cpumask_test_cpu(cpu, mask) && cpu_online(cpu)) {
 			/* add queue to CPU maps */
 			int pos = 0;
 
-			map = xmap_dereference(new_dev_maps->cpu_map[cpu]);
+			map = xmap_dereference(new_dev_maps->cpu_map[tci]);
 			while ((pos < map->len) && (map->queues[pos] != index))
 				pos++;
 
@@ -2139,26 +2168,36 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 #endif
 		} else if (dev_maps) {
 			/* fill in the new device map from the old device map */
-			map = xmap_dereference(dev_maps->cpu_map[cpu]);
-			RCU_INIT_POINTER(new_dev_maps->cpu_map[cpu], map);
+			map = xmap_dereference(dev_maps->cpu_map[tci]);
+			RCU_INIT_POINTER(new_dev_maps->cpu_map[tci], map);
 		}
 
+		/* copy maps belonging to foreign traffic classes */
+		for (i = num_tc - tc, tci++; dev_maps && --i; tci++) {
+			/* fill in the new device map from the old device map */
+			map = xmap_dereference(dev_maps->cpu_map[tci]);
+			RCU_INIT_POINTER(new_dev_maps->cpu_map[tci], map);
+		}
 	}
 
 	rcu_assign_pointer(dev->xps_maps, new_dev_maps);
 
 	/* Cleanup old maps */
-	if (dev_maps) {
-		for_each_possible_cpu(cpu) {
-			new_map = xmap_dereference(new_dev_maps->cpu_map[cpu]);
-			map = xmap_dereference(dev_maps->cpu_map[cpu]);
+	if (!dev_maps)
+		goto out_no_old_maps;
+
+	for_each_possible_cpu(cpu) {
+		for (i = num_tc, tci = cpu * num_tc; i--; tci++) {
+			new_map = xmap_dereference(new_dev_maps->cpu_map[tci]);
+			map = xmap_dereference(dev_maps->cpu_map[tci]);
 			if (map && map != new_map)
 				kfree_rcu(map, rcu);
 		}
-
-		kfree_rcu(dev_maps, rcu);
 	}
 
+	kfree_rcu(dev_maps, rcu);
+
+out_no_old_maps:
 	dev_maps = new_dev_maps;
 	active = true;
 
@@ -2173,11 +2212,12 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 
 	/* removes queue from unused CPUs */
 	for_each_possible_cpu(cpu) {
-		if (cpumask_test_cpu(cpu, mask) && cpu_online(cpu))
-			continue;
-
-		if (remove_xps_queue(dev_maps, cpu, index))
-			active = true;
+		for (i = tc, tci = cpu * num_tc; i--; tci++)
+			active |= remove_xps_queue(dev_maps, tci, index);
+		if (!cpumask_test_cpu(cpu, mask) || !cpu_online(cpu))
+			active |= remove_xps_queue(dev_maps, tci, index);
+		for (i = num_tc - tc, tci++; --i; tci++)
+			active |= remove_xps_queue(dev_maps, tci, index);
 	}
 
 	/* free map if not active */
@@ -2193,11 +2233,14 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 error:
 	/* remove any maps that we added */
 	for_each_possible_cpu(cpu) {
-		new_map = xmap_dereference(new_dev_maps->cpu_map[cpu]);
-		map = dev_maps ? xmap_dereference(dev_maps->cpu_map[cpu]) :
-				 NULL;
-		if (new_map && new_map != map)
-			kfree(new_map);
+		for (i = num_tc, tci = cpu * num_tc; i--; tci++) {
+			new_map = xmap_dereference(new_dev_maps->cpu_map[tci]);
+			map = dev_maps ?
+			      xmap_dereference(dev_maps->cpu_map[tci]) :
+			      NULL;
+			if (new_map && new_map != map)
+				kfree(new_map);
+		}
 	}
 
 	mutex_unlock(&xps_map_mutex);
@@ -3157,8 +3200,14 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 	rcu_read_lock();
 	dev_maps = rcu_dereference(dev->xps_maps);
 	if (dev_maps) {
-		map = rcu_dereference(
-		    dev_maps->cpu_map[skb->sender_cpu - 1]);
+		unsigned int tci = skb->sender_cpu - 1;
+
+		if (dev->num_tc) {
+			tci *= dev->num_tc;
+			tci += netdev_get_prio_tc_map(dev, skb->priority);
+		}
+
+		map = rcu_dereference(dev_maps->cpu_map[tci]);
 		if (map) {
 			if (map->len == 1)
 				queue_index = map->queues[0];
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index c4e4e7d..3b2b935 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1207,29 +1207,38 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
 			    struct netdev_queue_attribute *attribute, char *buf)
 {
 	struct net_device *dev = queue->dev;
+	int cpu, len, num_tc = 1, tc = 0;
 	struct xps_dev_maps *dev_maps;
 	cpumask_var_t mask;
 	unsigned long index;
-	int i, len;
 
 	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
 		return -ENOMEM;
 
 	index = get_netdev_queue_index(queue);
 
+	if (dev->num_tc) {
+		num_tc = dev->num_tc;
+		tc = netdev_txq_to_tc(dev, index);
+		if (tc < 0)
+			return -EINVAL;
+	}
+
 	rcu_read_lock();
 	dev_maps = rcu_dereference(dev->xps_maps);
 	if (dev_maps) {
-		for_each_possible_cpu(i) {
-			struct xps_map *map =
-			    rcu_dereference(dev_maps->cpu_map[i]);
-			if (map) {
-				int j;
-				for (j = 0; j < map->len; j++) {
-					if (map->queues[j] == index) {
-						cpumask_set_cpu(i, mask);
-						break;
-					}
+		for_each_possible_cpu(cpu) {
+			int i, tci = cpu * num_tc + tc;
+			struct xps_map *map;
+
+			map = rcu_dereference(dev_maps->cpu_map[tci]);
+			if (!map)
+				continue;
+
+			for (i = map->len; i--;) {
+				if (map->queues[i] == index) {
+					cpumask_set_cpu(cpu, mask);
+					break;
 				}
 			}
 		}
