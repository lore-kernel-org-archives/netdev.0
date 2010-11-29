From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] xps: add __rcu annotations
Date: Mon, 29 Nov 2010 08:43:02 +0100
Message-ID: <1291016582.29196.136.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49466 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562Ab0K2HnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 02:43:09 -0500
Received: by wwa36 with SMTP id 36so4375414wwa.1
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 23:43:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid sparse warnings : add __rcu annotations and use
rcu_dereference_protected() where necessary.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |    4 ++--
 net/core/net-sysfs.c      |   24 +++++++++++++++---------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9ae4544..4b0c7f3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -622,7 +622,7 @@ struct xps_map {
  */
 struct xps_dev_maps {
 	struct rcu_head rcu;
-	struct xps_map *cpu_map[0];
+	struct xps_map __rcu *cpu_map[0];
 };
 #define XPS_DEV_MAPS_SIZE (sizeof(struct xps_dev_maps) +		\
     (nr_cpu_ids * sizeof(struct xps_map *)))
@@ -1049,7 +1049,7 @@ struct net_device {
 	spinlock_t		tx_global_lock;
 
 #ifdef CONFIG_XPS
-	struct xps_dev_maps	*xps_maps;
+	struct xps_dev_maps __rcu *xps_maps;
 #endif
 
 	/* These may be needed for future network-power-down code. */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 99c1129..3ba2103 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -899,6 +899,8 @@ static void xps_dev_maps_release(struct rcu_head *rcu)
 }
 
 static DEFINE_MUTEX(xps_map_mutex);
+#define xmap_dereference(P)		\
+	rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
 
 static ssize_t store_xps_map(struct netdev_queue *queue,
 		      struct netdev_queue_attribute *attribute,
@@ -935,11 +937,12 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 
 	mutex_lock(&xps_map_mutex);
 
-	dev_maps = dev->xps_maps;
+	dev_maps = xmap_dereference(dev->xps_maps);
 
 	for_each_possible_cpu(cpu) {
-		new_map = map = dev_maps ? dev_maps->cpu_map[cpu] : NULL;
-
+		map = dev_maps ?
+			xmap_dereference(dev_maps->cpu_map[cpu]) : NULL;
+		new_map = map;
 		if (map) {
 			for (pos = 0; pos < map->len; pos++)
 				if (map->queues[pos] == index)
@@ -974,13 +977,14 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 			else
 				new_map = NULL;
 		}
-		new_dev_maps->cpu_map[cpu] = new_map;
+		RCU_INIT_POINTER(new_dev_maps->cpu_map[cpu], new_map);
 	}
 
 	/* Cleanup old maps */
 	for_each_possible_cpu(cpu) {
-		map = dev_maps ? dev_maps->cpu_map[cpu] : NULL;
-		if (map && new_dev_maps->cpu_map[cpu] != map)
+		map = dev_maps ?
+			xmap_dereference(dev_maps->cpu_map[cpu]) : NULL;
+		if (map && xmap_dereference(new_dev_maps->cpu_map[cpu]) != map)
 			call_rcu(&map->rcu, xps_map_release);
 		if (new_dev_maps->cpu_map[cpu])
 			nonempty = 1;
@@ -1006,7 +1010,9 @@ error:
 
 	if (new_dev_maps)
 		for_each_possible_cpu(i)
-			kfree(new_dev_maps->cpu_map[i]);
+			kfree(rcu_dereference_protected(
+				new_dev_maps->cpu_map[i],
+				1));
 	kfree(new_dev_maps);
 	free_cpumask_var(mask);
 	return -ENOMEM;
@@ -1032,11 +1038,11 @@ static void netdev_queue_release(struct kobject *kobj)
 	index = get_netdev_queue_index(queue);
 
 	mutex_lock(&xps_map_mutex);
-	dev_maps = dev->xps_maps;
+	dev_maps = xmap_dereference(dev->xps_maps);
 
 	if (dev_maps) {
 		for_each_possible_cpu(i) {
-			map  = dev_maps->cpu_map[i];
+			map = xmap_dereference(dev_maps->cpu_map[i]);
 			if (!map)
 				continue;
 


