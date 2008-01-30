From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/7] bonding: fix race that causes invalid statistics
Date: Tue, 29 Jan 2008 18:07:46 -0800
Message-ID: <1201658872418-git-send-email-fubar@us.ibm.com>
References: <12016588691476-git-send-email-fubar@us.ibm.com>
 <12016588701127-git-send-email-fubar@us.ibm.com>
 <12016588714065-git-send-email-fubar@us.ibm.com>
 <12016588712034-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Chris Snook <csnook@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:32852 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbYA3CH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:07:59 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U14SBg023837
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 20:04:28 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U27rNw205170
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:53 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U27rsP015855
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:53 -0700
In-Reply-To: <12016588712034-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

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
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   57 ++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 63866da..0cc853e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3775,41 +3775,44 @@ static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
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
+	memcpy(stats, &local_stats, sizeof(struct net_device_stats));
 
 	read_unlock_bh(&bond->lock);
 
-- 
1.5.3.4.206.g58ba4-dirty

