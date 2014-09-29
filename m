From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next v4] bonding: make global bonding stats more reliable
Date: Sun, 28 Sep 2014 22:34:37 -0400
Message-ID: <1411958077-13160-1-git-send-email-gospo@cumulusnetworks.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:42484 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbaI2T1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the code stands today, bonding stats are based simply on the stats
from the member interfaces.  If a member was to be removed from a bond,
the stats would instantly drop.  This would be confusing to an admin
would would suddonly see interface stats drop while traffic is still
flowing.

In addition to preventing the stats drops mentioned above, new members
will now be added to the bond and only traffic received after the member
was added to the bond will be counted as part of bonding stats.  Bonding
counters will also be updated when any slaves are dropped to make sure
the reported stats are reliable.

v2: Changes suggested by Nik to properly allocate/free stats memory.
v3: Properly destroy workqueue and fix netlink configuration path.
v4: Moved cached stats into bonding and slave structs as there does not
seem to be a complexity/performance benefit to using alloc'd memory vs
in-struct memory.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c | 68 ++++++++++++++++++++++++-----------------
 drivers/net/bonding/bonding.h   |  3 ++
 2 files changed, 43 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5390475..c2adc27 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -208,6 +208,8 @@ static int lacp_fast;
 
 static int bond_init(struct net_device *bond_dev);
 static void bond_uninit(struct net_device *bond_dev);
+static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
+						struct rtnl_link_stats64 *stats);
 
 /*---------------------------- General routines -----------------------------*/
 
@@ -1344,6 +1346,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	slave_dev->priv_flags |= IFF_BONDING;
+	/* initialize slave stats */
+	dev_get_stats(new_slave->dev, &new_slave->slave_stats);
 
 	if (bond_is_lb(bond)) {
 		/* bond_alb_init_slave() must be called before all other stages since
@@ -1652,6 +1656,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	bond_sysfs_slave_del(slave);
 
+	/* recompute stats just before removing the slave */
+	bond_get_stats(bond->dev, &bond->bond_stats);
+
 	bond_upper_dev_unlink(bond_dev, slave_dev);
 	/* unregister rx_handler early so bond_handle_frame wouldn't be called
 	 * for this slave anymore.
@@ -3085,38 +3092,43 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 	struct list_head *iter;
 	struct slave *slave;
 
-	memset(stats, 0, sizeof(*stats));
+	memcpy(stats, &bond->bond_stats, sizeof(*stats));
 
 	bond_for_each_slave(bond, slave, iter) {
 		const struct rtnl_link_stats64 *sstats =
 			dev_get_stats(slave->dev, &temp);
-
-		stats->rx_packets += sstats->rx_packets;
-		stats->rx_bytes += sstats->rx_bytes;
-		stats->rx_errors += sstats->rx_errors;
-		stats->rx_dropped += sstats->rx_dropped;
-
-		stats->tx_packets += sstats->tx_packets;
-		stats->tx_bytes += sstats->tx_bytes;
-		stats->tx_errors += sstats->tx_errors;
-		stats->tx_dropped += sstats->tx_dropped;
-
-		stats->multicast += sstats->multicast;
-		stats->collisions += sstats->collisions;
-
-		stats->rx_length_errors += sstats->rx_length_errors;
-		stats->rx_over_errors += sstats->rx_over_errors;
-		stats->rx_crc_errors += sstats->rx_crc_errors;
-		stats->rx_frame_errors += sstats->rx_frame_errors;
-		stats->rx_fifo_errors += sstats->rx_fifo_errors;
-		stats->rx_missed_errors += sstats->rx_missed_errors;
-
-		stats->tx_aborted_errors += sstats->tx_aborted_errors;
-		stats->tx_carrier_errors += sstats->tx_carrier_errors;
-		stats->tx_fifo_errors += sstats->tx_fifo_errors;
-		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
-		stats->tx_window_errors += sstats->tx_window_errors;
-	}
+		struct rtnl_link_stats64 *pstats = &slave->slave_stats;
+
+		stats->rx_packets +=  sstats->rx_packets - pstats->rx_packets;
+		stats->rx_bytes += sstats->rx_bytes - pstats->rx_bytes;
+		stats->rx_errors += sstats->rx_errors - pstats->rx_errors;
+		stats->rx_dropped += sstats->rx_dropped - pstats->rx_dropped;
+
+		stats->tx_packets += sstats->tx_packets - pstats->tx_packets;;
+		stats->tx_bytes += sstats->tx_bytes - pstats->tx_bytes;
+		stats->tx_errors += sstats->tx_errors - pstats->tx_errors;
+		stats->tx_dropped += sstats->tx_dropped - pstats->tx_dropped;
+
+		stats->multicast += sstats->multicast - pstats->multicast;
+		stats->collisions += sstats->collisions - pstats->collisions;
+
+		stats->rx_length_errors += sstats->rx_length_errors - pstats->rx_length_errors;
+		stats->rx_over_errors += sstats->rx_over_errors - pstats->rx_over_errors;
+		stats->rx_crc_errors += sstats->rx_crc_errors - pstats->rx_crc_errors;
+		stats->rx_frame_errors += sstats->rx_frame_errors - pstats->rx_frame_errors;
+		stats->rx_fifo_errors += sstats->rx_fifo_errors - pstats->rx_fifo_errors;
+		stats->rx_missed_errors += sstats->rx_missed_errors - pstats->rx_missed_errors;
+
+		stats->tx_aborted_errors += sstats->tx_aborted_errors - pstats->tx_aborted_errors;
+		stats->tx_carrier_errors += sstats->tx_carrier_errors - pstats->tx_carrier_errors;
+		stats->tx_fifo_errors += sstats->tx_fifo_errors - pstats->tx_fifo_errors;
+		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors - pstats->tx_heartbeat_errors;
+		stats->tx_window_errors += sstats->tx_window_errors - pstats->tx_window_errors;
+
+		/* save off the slave stats for the next run */
+		memcpy(pstats, sstats, sizeof(*sstats));
+	}
+	memcpy(&bond->bond_stats, stats, sizeof(*stats));
 
 	return stats;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6140bf0..57917e6 100644
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
+	struct rtnl_link_stats64 slave_stats;
 };
 
 /*
@@ -224,6 +226,7 @@ struct bonding {
 	/* debugging support via debugfs */
 	struct	 dentry *debug_dir;
 #endif /* CONFIG_DEBUG_FS */
+	struct rtnl_link_stats64 bond_stats;
 };
 
 #define bond_slave_get_rcu(dev) \
-- 
1.9.3
