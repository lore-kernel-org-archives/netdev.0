From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 2/3] net: Refactor removal of queues from XPS map
 and apply on num_tc changes
Date: Thu, 27 Oct 2016 11:40:09 -0400
Message-ID: <20161027154009.13989.25522.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161027153539.13989.14349.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, tom@herbertland.com,
        intel-wired-lan@lists.osuosl.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:5216 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936436AbcJ0Vkv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:40:51 -0400
In-Reply-To: <20161027153539.13989.14349.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the code for removing queues from the XPS map and makes
it so that we can apply the code any time we change either the number of
traffic classes or the mapping of a given block of queues.  This way we
avoid having queues pulling traffic from a foreign traffic class.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |   79 ++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 56 insertions(+), 23 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d4d45bf..d124081 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1953,32 +1953,56 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 #define xmap_dereference(P)		\
 	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
 
-static struct xps_map *remove_xps_queue(struct xps_dev_maps *dev_maps,
-					int cpu, u16 index)
+static bool remove_xps_queue(struct xps_dev_maps *dev_maps,
+			     int tci, u16 index)
 {
 	struct xps_map *map = NULL;
 	int pos;
 
 	if (dev_maps)
-		map = xmap_dereference(dev_maps->cpu_map[cpu]);
+		map = xmap_dereference(dev_maps->cpu_map[tci]);
+	if (!map)
+		return false;
 
-	for (pos = 0; map && pos < map->len; pos++) {
-		if (map->queues[pos] == index) {
-			if (map->len > 1) {
-				map->queues[pos] = map->queues[--map->len];
-			} else {
-				RCU_INIT_POINTER(dev_maps->cpu_map[cpu], NULL);
-				kfree_rcu(map, rcu);
-				map = NULL;
-			}
+	for (pos = map->len; pos--;) {
+		if (map->queues[pos] != index)
+			continue;
+
+		if (map->len > 1) {
+			map->queues[pos] = map->queues[--map->len];
 			break;
 		}
+
+		RCU_INIT_POINTER(dev_maps->cpu_map[tci], NULL);
+		kfree_rcu(map, rcu);
+		return false;
 	}
 
-	return map;
+	return true;
 }
 
-static void netif_reset_xps_queues_gt(struct net_device *dev, u16 index)
+static bool remove_xps_queue_cpu(struct net_device *dev,
+				 struct xps_dev_maps *dev_maps,
+				 int cpu, u16 offset, u16 count)
+{
+	bool active = false;
+	int i;
+
+	count += offset;
+	i = count;
+
+	do {
+		if (i-- == offset) {
+			active = true;
+			break;
+		}
+	} while (remove_xps_queue(dev_maps, cpu, i));
+
+	return active;
+}
+
+static void netif_reset_xps_queues(struct net_device *dev, u16 offset,
+				   u16 count)
 {
 	struct xps_dev_maps *dev_maps;
 	int cpu, i;
@@ -1990,21 +2014,16 @@ static void netif_reset_xps_queues_gt(struct net_device *dev, u16 index)
 	if (!dev_maps)
 		goto out_no_maps;
 
-	for_each_possible_cpu(cpu) {
-		for (i = index; i < dev->num_tx_queues; i++) {
-			if (!remove_xps_queue(dev_maps, cpu, i))
-				break;
-		}
-		if (i == dev->num_tx_queues)
-			active = true;
-	}
+	for_each_possible_cpu(cpu)
+		active |= remove_xps_queue_cpu(dev, dev_maps, cpu, offset,
+					       count);
 
 	if (!active) {
 		RCU_INIT_POINTER(dev->xps_maps, NULL);
 		kfree_rcu(dev_maps, rcu);
 	}
 
-	for (i = index; i < dev->num_tx_queues; i++)
+	for (i = offset + (count - 1); count--; i--)
 		netdev_queue_numa_node_write(netdev_get_tx_queue(dev, i),
 					     NUMA_NO_NODE);
 
@@ -2012,6 +2031,11 @@ static void netif_reset_xps_queues_gt(struct net_device *dev, u16 index)
 	mutex_unlock(&xps_map_mutex);
 }
 
+static void netif_reset_xps_queues_gt(struct net_device *dev, u16 index)
+{
+	netif_reset_xps_queues(dev, index, dev->num_tx_queues - index);
+}
+
 static struct xps_map *expand_xps_map(struct xps_map *map,
 				      int cpu, u16 index)
 {
@@ -2175,6 +2199,9 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 #endif
 void netdev_reset_tc(struct net_device *dev)
 {
+#ifdef CONFIG_XPS
+	netif_reset_xps_queues_gt(dev, 0);
+#endif
 	dev->num_tc = 0;
 	memset(dev->tc_to_txq, 0, sizeof(dev->tc_to_txq));
 	memset(dev->prio_tc_map, 0, sizeof(dev->prio_tc_map));
@@ -2186,6 +2213,9 @@ int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset)
 	if (tc >= dev->num_tc)
 		return -EINVAL;
 
+#ifdef CONFIG_XPS
+	netif_reset_xps_queues(dev, offset, count);
+#endif
 	dev->tc_to_txq[tc].count = count;
 	dev->tc_to_txq[tc].offset = offset;
 	return 0;
@@ -2197,6 +2227,9 @@ int netdev_set_num_tc(struct net_device *dev, u8 num_tc)
 	if (num_tc > TC_MAX_QUEUE)
 		return -EINVAL;
 
+#ifdef CONFIG_XPS
+	netif_reset_xps_queues_gt(dev, 0);
+#endif
 	dev->num_tc = num_tc;
 	return 0;
 }
