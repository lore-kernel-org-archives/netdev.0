From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH v2 05/10] net: Add support for XPS without sysfs being
 defined
Date: Thu, 10 Jan 2013 10:57:46 -0800
Message-ID: <20130110185741.29578.16197.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46659 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961Ab3AJS7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 13:59:21 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
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
index 59fe9da..aa7ad8a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2104,7 +2104,6 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 }
 
 #ifdef CONFIG_XPS
-extern void netif_reset_xps_queue(struct net_device *dev, u16 index);
 extern int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask,
 			       u16 index);
 #else
diff --git a/net/Kconfig b/net/Kconfig
index 30b48f5..3cc5be0 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -232,7 +232,7 @@ config RFS_ACCEL
 
 config XPS
 	boolean
-	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
+	depends on SMP && USE_GENERIC_SMP_HELPERS
 	default y
 
 config NETPRIO_CGROUP
diff --git a/net/core/dev.c b/net/core/dev.c
index 715d8d4..095d22f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1887,10 +1887,10 @@ static struct xps_map *remove_xps_queue(struct xps_dev_maps *dev_maps,
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
@@ -1900,7 +1900,11 @@ void netif_reset_xps_queue(struct net_device *dev, u16 index)
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
 
@@ -1909,8 +1913,10 @@ void netif_reset_xps_queue(struct net_device *dev, u16 index)
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
@@ -2096,8 +2102,12 @@ int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
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
@@ -5899,6 +5909,10 @@ static void rollback_registered_many(struct list_head *head)
 
 		/* Remove entries from kobject tree */
 		netdev_unregister_kobject(dev);
+#ifdef CONFIG_XPS
+		/* Remove XPS queueing entries */
+		netif_reset_xps_queues_gt(dev, 0);
+#endif
 	}
 
 	synchronize_net();
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ad489d..a5b89a6 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1002,16 +1002,6 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
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
@@ -1058,10 +1048,6 @@ static void netdev_queue_release(struct kobject *kobj)
 {
 	struct netdev_queue *queue = to_netdev_queue(kobj);
 
-#ifdef CONFIG_XPS
-	xps_queue_release(queue);
-#endif
-
 	memset(kobj, 0, sizeof(*kobj));
 	dev_put(queue->dev);
 }
