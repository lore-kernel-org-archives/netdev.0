From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4 04/10] xps: Add xps_queue_release function
Date: Mon, 28 Nov 2011 18:33:02 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111281818120.24370@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f74.google.com ([74.125.83.74]:39523 "EHLO
	mail-ee0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab1K2Cj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 21:39:58 -0500
Received: by eeuu44 with SMTP id u44so51273eeu.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 18:39:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the xps specific parts in netdev_queue_release into
its own function which netdev_queue_release can call.  This allows
netdev_queue_release to be more generic (for adding new attributes
to tx queues).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/net-sysfs.c |   89 ++++++++++++++++++++++++++-----------------------
 1 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index db6c2f8..b17c14a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -910,6 +910,52 @@ static DEFINE_MUTEX(xps_map_mutex);
 #define xmap_dereference(P)		\
 	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
 
+static void xps_queue_release(struct netdev_queue *queue)
+{
+	struct net_device *dev = queue->dev;
+	struct xps_dev_maps *dev_maps;
+	struct xps_map *map;
+	unsigned long index;
+	int i, pos, nonempty = 0;
+
+	index = get_netdev_queue_index(queue);
+
+	mutex_lock(&xps_map_mutex);
+	dev_maps = xmap_dereference(dev->xps_maps);
+
+	if (dev_maps) {
+		for_each_possible_cpu(i) {
+			map = xmap_dereference(dev_maps->cpu_map[i]);
+			if (!map)
+				continue;
+
+			for (pos = 0; pos < map->len; pos++)
+				if (map->queues[pos] == index)
+					break;
+
+			if (pos < map->len) {
+				if (map->len > 1)
+					map->queues[pos] =
+					    map->queues[--map->len];
+				else {
+					RCU_INIT_POINTER(dev_maps->cpu_map[i],
+					    NULL);
+					kfree_rcu(map, rcu);
+					map = NULL;
+				}
+			}
+			if (map)
+				nonempty = 1;
+		}
+
+		if (!nonempty) {
+			RCU_INIT_POINTER(dev->xps_maps, NULL);
+			kfree_rcu(dev_maps, rcu);
+		}
+	}
+	mutex_unlock(&xps_map_mutex);
+}
+
 static ssize_t store_xps_map(struct netdev_queue *queue,
 		      struct netdev_queue_attribute *attribute,
 		      const char *buf, size_t len)
@@ -1054,49 +1100,8 @@ static struct attribute *netdev_queue_default_attrs[] = {
 static void netdev_queue_release(struct kobject *kobj)
 {
 	struct netdev_queue *queue = to_netdev_queue(kobj);
-	struct net_device *dev = queue->dev;
-	struct xps_dev_maps *dev_maps;
-	struct xps_map *map;
-	unsigned long index;
-	int i, pos, nonempty = 0;
-
-	index = get_netdev_queue_index(queue);
-
-	mutex_lock(&xps_map_mutex);
-	dev_maps = xmap_dereference(dev->xps_maps);
 
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
-
-	mutex_unlock(&xps_map_mutex);
+	xps_queue_release(queue);
 
 	memset(kobj, 0, sizeof(*kobj));
 	dev_put(queue->dev);
-- 
1.7.3.1
