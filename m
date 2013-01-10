From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH v2 03/10] net: Rewrite netif_reset_xps_queue to allow for
 better code reuse
Date: Thu, 10 Jan 2013 10:57:17 -0800
Message-ID: <20130110185710.29578.9182.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46883 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754756Ab3AJS6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 13:58:52 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does a minor refactor on netif_reset_xps_queue to address a few
items I noticed.

First is the fact that we are doing removal of queues in both
netif_reset_xps_queue and netif_set_xps_queue.  Since there is no need to
have the code in two places I am pushing it out into a separate function
and will come back in another patch and reuse the code in
netif_set_xps_queue.

The second item this change addresses is the fact that the Tx queues were
not getting their numa_node value cleared as a part of the XPS queue reset.
This patch resolves that by resetting the numa_node value if the dev_maps
value is set.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |   56 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 76126fb..fccee52 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1862,45 +1862,55 @@ static DEFINE_MUTEX(xps_map_mutex);
 #define xmap_dereference(P)		\
 	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
 
-void netif_reset_xps_queue(struct net_device *dev, u16 index)
+static struct xps_map *remove_xps_queue(struct xps_dev_maps *dev_maps,
+					int cpu, u16 index)
 {
-	struct xps_dev_maps *dev_maps;
-	struct xps_map *map;
-	int i, pos, nonempty = 0;
-
-	mutex_lock(&xps_map_mutex);
-	dev_maps = xmap_dereference(dev->xps_maps);
-
-	if (!dev_maps)
-		goto out_no_maps;
+	struct xps_map *map = NULL;
+	int pos;
 
-	for_each_possible_cpu(i) {
-		map = xmap_dereference(dev_maps->cpu_map[i]);
-		if (!map)
-			continue;
-
-		for (pos = 0; pos < map->len; pos++)
-			if (map->queues[pos] == index)
-				break;
+	if (dev_maps)
+		map = xmap_dereference(dev_maps->cpu_map[cpu]);
 
-		if (pos < map->len) {
+	for (pos = 0; map && pos < map->len; pos++) {
+		if (map->queues[pos] == index) {
 			if (map->len > 1) {
 				map->queues[pos] = map->queues[--map->len];
 			} else {
-				RCU_INIT_POINTER(dev_maps->cpu_map[i], NULL);
+				RCU_INIT_POINTER(dev_maps->cpu_map[cpu], NULL);
 				kfree_rcu(map, rcu);
 				map = NULL;
 			}
+			break;
 		}
-		if (map)
-			nonempty = 1;
 	}
 
-	if (!nonempty) {
+	return map;
+}
+
+void netif_reset_xps_queue(struct net_device *dev, u16 index)
+{
+	struct xps_dev_maps *dev_maps;
+	int cpu;
+	bool active = false;
+
+	mutex_lock(&xps_map_mutex);
+	dev_maps = xmap_dereference(dev->xps_maps);
+
+	if (!dev_maps)
+		goto out_no_maps;
+
+	for_each_possible_cpu(cpu) {
+		if (remove_xps_queue(dev_maps, cpu, index))
+			active = true;
+	}
+
+	if (!active) {
 		RCU_INIT_POINTER(dev->xps_maps, NULL);
 		kfree_rcu(dev_maps, rcu);
 	}
 
+	netdev_queue_numa_node_write(netdev_get_tx_queue(dev, index),
+				     NUMA_NO_NODE);
 out_no_maps:
 	mutex_unlock(&xps_map_mutex);
 }
