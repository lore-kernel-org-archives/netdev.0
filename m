From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 05/10] net: Add support for XPS without SYSFS being defined
Date: Fri, 29 Jun 2012 17:16:38 -0700
Message-ID: <20120630001638.29939.92025.stgit@gitlad.jf.intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32308 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999Ab2F3AQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:16:20 -0400
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes it so that we can support transmit packet steering without
sysfs needing to be enabled.  The reason for making this change is to make
it so that a driver can make use of the XPS even while the sysfs portion of
the interface is not present.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/netdevice.h |    1 -
 net/Kconfig               |    2 +-
 net/core/dev.c            |   26 ++++++++++++++++++++------
 net/core/net-sysfs.c      |   14 --------------
 4 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e9e74b7..db27be2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2073,7 +2073,6 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 }
 
 #ifdef CONFIG_XPS
-extern void netif_reset_xps_queue(struct net_device *dev, u16 index);
 extern int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask,
 			       u16 index);
 #else
diff --git a/net/Kconfig b/net/Kconfig
index 245831b..fcc5657 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -230,7 +230,7 @@ config RFS_ACCEL
 
 config XPS
 	boolean
-	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
+	depends on SMP && USE_GENERIC_SMP_HELPERS
 	default y
 
 config NETPRIO_CGROUP
diff --git a/net/core/dev.c b/net/core/dev.c
index 5f0550b..894faf1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1758,10 +1758,10 @@ static struct xps_map *remove_xps_queue(struct xps_dev_maps *dev_maps,
 	return map;
 }
 
-void netif_reset_xps_queue(struct net_device *dev, u16 index)
+static void netif_reset_xps_queues_gt(struct net_device *dev, u16 index)
 {
 	struct xps_dev_maps *dev_maps;
-	int cpu;
+	int cpu, i;
 	bool active = false;
 
 	mutex_lock(&xps_map_mutex);
@@ -1771,7 +1771,11 @@ void netif_reset_xps_queue(struct net_device *dev, u16 index)
 		goto out_no_maps;
 
 	for_each_possible_cpu(cpu) {
-		if (remove_xps_queue(dev_maps, cpu, index))
+		for (i = index; i < dev->num_tx_queues; i++) {
+			if (!remove_xps_queue(dev_maps, cpu, i))
+				break;
+		}
+		if (i == dev->num_tx_queues)
 			active = true;
 	}
 
@@ -1780,8 +1784,10 @@ void netif_reset_xps_queue(struct net_device *dev, u16 index)
 		kfree_rcu(dev_maps, rcu);
 	}
 
-	netdev_queue_numa_node_write(netdev_get_tx_queue(dev, index),
-				     NUMA_NO_NODE);
+	for (i = index; i < dev->num_tx_queues; i++)
+		netdev_queue_numa_node_write(netdev_get_tx_queue(dev, i),
+					     NUMA_NO_NODE);
+
 out_no_maps:
 	mutex_unlock(&xps_map_mutex);
 }
@@ -1967,8 +1973,12 @@ int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 		if (dev->num_tc)
 			netif_setup_tc(dev, txq);
 
-		if (txq < dev->real_num_tx_queues)
+		if (txq < dev->real_num_tx_queues) {
 			qdisc_reset_all_tx_gt(dev, txq);
+#ifdef CONFIG_XPS
+			netif_reset_xps_queues_gt(dev, txq);
+#endif
+		}
 	}
 
 	dev->real_num_tx_queues = txq;
@@ -5460,6 +5470,10 @@ static void rollback_registered_many(struct list_head *head)
 
 		/* Remove entries from kobject tree */
 		netdev_unregister_kobject(dev);
+#ifdef CONFIG_XPS
+		/* Remove XPS queueing entries */
+		netif_reset_xps_queues_gt(dev, 0);
+#endif
 	}
 
 	/* Process any work delayed until the end of the batch */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 092d338..42bb496 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -963,16 +963,6 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
 	return len;
 }
 
-static void xps_queue_release(struct netdev_queue *queue)
-{
-	struct net_device *dev = queue->dev;
-	unsigned long index;
-
-	index = get_netdev_queue_index(queue);
-
-	netif_reset_xps_queue(dev, index);
-}
-
 static ssize_t store_xps_map(struct netdev_queue *queue,
 		      struct netdev_queue_attribute *attribute,
 		      const char *buf, size_t len)
@@ -1019,10 +1009,6 @@ static void netdev_queue_release(struct kobject *kobj)
 {
 	struct netdev_queue *queue = to_netdev_queue(kobj);
 
-#ifdef CONFIG_XPS
-	xps_queue_release(queue);
-#endif
-
 	memset(kobj, 0, sizeof(*kobj));
 	dev_put(queue->dev);
 }
