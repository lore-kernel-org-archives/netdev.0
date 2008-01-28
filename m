From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] bonding: fix race that causes invalid statistics
Date: Mon, 28 Jan 2008 18:38:25 -0500
Message-ID: <20080128233825.GA21912@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, csnook@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837AbYA1Xju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 18:39:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've seen reports of invalid stats in /proc/net/dev for bonding
interfaces, and found it's a pretty easy problem to reproduce.  Since
the current code zeros the bonding stats when a read is requested and a
pointer to that data is returned to the caller we cannot guarantee that
the caller has completely accessed the data before a successive call to
request the stats zeroes the stats again.

This patch creates a new stack variable to keep track of the updated
stats and copies the data from that variable into the bonding stats
structure.  This ensures that the value for any of the bonding stats
should not incorrectly return zero for any of the bonding statistics.
This does use more stack space and require an extra memcpy, but it seems
like a fair trade-off for consistently correct bonding statistics.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Chris Snook <csnook@redhat.com>

---

 bond_main.c |   57 ++++++++++++++++++++++++++++++---------------------------
 1 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 49a1982..901de6d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3769,41 +3769,44 @@ static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
 	struct net_device_stats *stats = &(bond->stats), *sstats;
+	struct net_device_stats local_stats;
 	struct slave *slave;
 	int i;
 
-	memset(stats, 0, sizeof(struct net_device_stats));
+	memset(&local_stats, 0, sizeof(struct net_device_stats));
 
 	read_lock_bh(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		sstats = slave->dev->get_stats(slave->dev);
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
+		local_stats.rx_packets += sstats->rx_packets;
+		local_stats.rx_bytes += sstats->rx_bytes;
+		local_stats.rx_errors += sstats->rx_errors;
+		local_stats.rx_dropped += sstats->rx_dropped;
+
+		local_stats.tx_packets += sstats->tx_packets;
+		local_stats.tx_bytes += sstats->tx_bytes;
+		local_stats.tx_errors += sstats->tx_errors;
+		local_stats.tx_dropped += sstats->tx_dropped;
+
+		local_stats.multicast += sstats->multicast;
+		local_stats.collisions += sstats->collisions;
+
+		local_stats.rx_length_errors += sstats->rx_length_errors;
+		local_stats.rx_over_errors += sstats->rx_over_errors;
+		local_stats.rx_crc_errors += sstats->rx_crc_errors;
+		local_stats.rx_frame_errors += sstats->rx_frame_errors;
+		local_stats.rx_fifo_errors += sstats->rx_fifo_errors;
+		local_stats.rx_missed_errors += sstats->rx_missed_errors;
+
+		local_stats.tx_aborted_errors += sstats->tx_aborted_errors;
+		local_stats.tx_carrier_errors += sstats->tx_carrier_errors;
+		local_stats.tx_fifo_errors += sstats->tx_fifo_errors;
+		local_stats.tx_heartbeat_errors += sstats->tx_heartbeat_errors;
+		local_stats.tx_window_errors += sstats->tx_window_errors;
+	}
+
+	memcpy(stats,&local_stats,sizeof(net_device_stats));
 
 	read_unlock_bh(&bond->lock);
 
