From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next v2] bonding: make global bonding stats more reliable
Date: Thu, 25 Sep 2014 18:37:11 -0400
Message-ID: <1411684631-7509-1-git-send-email-gospo@cumulusnetworks.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48653 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412AbaIZONd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 10:13:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the code stands today, bonding stats are based simply on the stats
from the member interfaces.  If a member was to be removed from a bond,
the stats would instantly drop.  This would be confusing to an admin
would would suddonly see interface stats drop while traffic is still
flowing.

In addition to preventing the stats drops mentioned above, new members
will now be added to the bond and only traffic received after the member
was added to the bond will be counted as part of bonding stats.

v2: Changes suggested by Nik to properly allocate/free stats memory.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c | 85 +++++++++++++++++++++++++++--------------
 drivers/net/bonding/bonding.h   |  3 ++
 2 files changed, 60 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5390475..61333b1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1147,17 +1147,26 @@ static struct slave *bond_alloc_slave(struct bonding *bond)
 
 	slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!slave)
-		return NULL;
+		goto slave_fail;
+
+	slave->slave_stats = kzalloc(sizeof(struct rtnl_link_stats64),
+				     GFP_KERNEL);
+	if (!slave->slave_stats)
+		goto slave_stats_fail;
 
 	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		SLAVE_AD_INFO(slave) = kzalloc(sizeof(struct ad_slave_info),
 					       GFP_KERNEL);
-		if (!SLAVE_AD_INFO(slave)) {
-			kfree(slave);
-			return NULL;
-		}
+		if (!SLAVE_AD_INFO(slave))
+			goto slave_ad_fail;
 	}
 	return slave;
+slave_ad_fail:
+	kfree(slave->slave_stats);
+slave_stats_fail:
+	kfree(slave);
+slave_fail:
+	return NULL;
 }
 
 static void bond_free_slave(struct slave *slave)
@@ -1167,6 +1176,7 @@ static void bond_free_slave(struct slave *slave)
 	if (BOND_MODE(bond) == BOND_MODE_8023AD)
 		kfree(SLAVE_AD_INFO(slave));
 
+	kfree(slave->slave_stats);
 	kfree(slave);
 }
 
@@ -1344,6 +1354,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	slave_dev->priv_flags |= IFF_BONDING;
+	/* initialize slave stats */
+	dev_get_stats(new_slave->dev, new_slave->slave_stats);
 
 	if (bond_is_lb(bond)) {
 		/* bond_alb_init_slave() must be called before all other stages since
@@ -3085,38 +3097,43 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 	struct list_head *iter;
 	struct slave *slave;
 
-	memset(stats, 0, sizeof(*stats));
+	memcpy(stats, bond->bond_stats, sizeof(*stats));
 
 	bond_for_each_slave(bond, slave, iter) {
 		const struct rtnl_link_stats64 *sstats =
 			dev_get_stats(slave->dev, &temp);
+		struct rtnl_link_stats64 *pstats = slave->slave_stats;
 
-		stats->rx_packets += sstats->rx_packets;
-		stats->rx_bytes += sstats->rx_bytes;
-		stats->rx_errors += sstats->rx_errors;
-		stats->rx_dropped += sstats->rx_dropped;
+		stats->rx_packets +=  sstats->rx_packets - pstats->rx_packets;
+		stats->rx_bytes += sstats->rx_bytes - pstats->rx_bytes;
+		stats->rx_errors += sstats->rx_errors - pstats->rx_errors;
+		stats->rx_dropped += sstats->rx_dropped - pstats->rx_dropped;
 
-		stats->tx_packets += sstats->tx_packets;
-		stats->tx_bytes += sstats->tx_bytes;
-		stats->tx_errors += sstats->tx_errors;
-		stats->tx_dropped += sstats->tx_dropped;
+		stats->tx_packets += sstats->tx_packets - pstats->tx_packets;;
+		stats->tx_bytes += sstats->tx_bytes - pstats->tx_bytes;
+		stats->tx_errors += sstats->tx_errors - pstats->tx_errors;
+		stats->tx_dropped += sstats->tx_dropped - pstats->tx_dropped;
 
-		stats->multicast += sstats->multicast;
-		stats->collisions += sstats->collisions;
+		stats->multicast += sstats->multicast - pstats->multicast;
+		stats->collisions += sstats->collisions - pstats->collisions;
 
-		stats->rx_length_errors += sstats->rx_length_errors;
-		stats->rx_over_errors += sstats->rx_over_errors;
-		stats->rx_crc_errors += sstats->rx_crc_errors;
-		stats->rx_frame_errors += sstats->rx_frame_errors;
-		stats->rx_fifo_errors += sstats->rx_fifo_errors;
-		stats->rx_missed_errors += sstats->rx_missed_errors;
+		stats->rx_length_errors += sstats->rx_length_errors - pstats->rx_length_errors;
+		stats->rx_over_errors += sstats->rx_over_errors - pstats->rx_over_errors;
+		stats->rx_crc_errors += sstats->rx_crc_errors - pstats->rx_crc_errors;
+		stats->rx_frame_errors += sstats->rx_frame_errors - pstats->rx_frame_errors;
+		stats->rx_fifo_errors += sstats->rx_fifo_errors - pstats->rx_fifo_errors;
+		stats->rx_missed_errors += sstats->rx_missed_errors - pstats->rx_missed_errors;
 
-		stats->tx_aborted_errors += sstats->tx_aborted_errors;
-		stats->tx_carrier_errors += sstats->tx_carrier_errors;
-		stats->tx_fifo_errors += sstats->tx_fifo_errors;
-		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
-		stats->tx_window_errors += sstats->tx_window_errors;
+		stats->tx_aborted_errors += sstats->tx_aborted_errors - pstats->tx_aborted_errors;
+		stats->tx_carrier_errors += sstats->tx_carrier_errors - pstats->tx_carrier_errors;
+		stats->tx_fifo_errors += sstats->tx_fifo_errors - pstats->tx_fifo_errors;
+		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors - pstats->tx_heartbeat_errors;
+		stats->tx_window_errors += sstats->tx_window_errors - pstats->tx_window_errors;
+
+		/* save off the slave stats for the next run */
+		memcpy(pstats, sstats, sizeof(*sstats));
 	}
+	memcpy(bond->bond_stats, stats, sizeof(*stats));
 
 	return stats;
 }
@@ -3857,6 +3874,8 @@ static void bond_uninit(struct net_device *bond_dev)
 		__bond_release_one(bond_dev, slave->dev, true);
 	netdev_info(bond_dev, "Released all slaves\n");
 
+	kfree(bond->bond_stats);
+
 	list_del(&bond->bond_list);
 
 	bond_debug_unregister(bond);
@@ -4243,7 +4262,13 @@ static int bond_init(struct net_device *bond_dev)
 
 	bond->wq = create_singlethread_workqueue(bond_dev->name);
 	if (!bond->wq)
-		return -ENOMEM;
+		goto bond_wq_fail;
+
+	/* initialize persistent stats for the bond */
+	bond->bond_stats = kzalloc(sizeof(struct rtnl_link_stats64),
+				   GFP_KERNEL);
+	if (!bond->bond_stats)
+		goto bond_stats_fail;
 
 	bond_set_lockdep_class(bond_dev);
 
@@ -4259,6 +4284,10 @@ static int bond_init(struct net_device *bond_dev)
 		eth_hw_addr_random(bond_dev);
 
 	return 0;
+bond_stats_fail:
+	kfree(bond->wq);
+bond_wq_fail:
+	return -ENOMEM;
 }
 
 unsigned int bond_get_num_tx_queues(void)
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6140bf0..fe25265 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -24,6 +24,7 @@
 #include <linux/inetdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/reciprocal_div.h>
+#include <linux/if_link.h>
 
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -175,6 +176,7 @@ struct slave {
 	struct netpoll *np;
 #endif
 	struct kobject kobj;
+	struct rtnl_link_stats64 *slave_stats;
 };
 
 /*
@@ -224,6 +226,7 @@ struct bonding {
 	/* debugging support via debugfs */
 	struct	 dentry *debug_dir;
 #endif /* CONFIG_DEBUG_FS */
+	struct rtnl_link_stats64 *bond_stats;
 };
 
 #define bond_slave_get_rcu(dev) \
-- 
1.9.3
