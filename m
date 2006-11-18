From: Laurent Riffard <laurent.riffard@free.fr>
Subject: [PATCH] bonding: fix an oops when slave device does not provide get_stats
Date: Sat, 18 Nov 2006 12:03:04 +0100
Message-ID: <20061118110349.174515111@calimero.antadix>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp9.orange.fr ([193.252.22.22]:22037 "EHLO
	smtp-msa-out09.orange.fr") by vger.kernel.org with ESMTP
	id S1754332AbWKRLG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 06:06:58 -0500
Received: from [192.168.1.9] (ALyon-251-1-32-45.w81-251.abo.wanadoo.fr [81.251.142.45])
	by mwinf0907.orange.fr (SMTP Server) with ESMTP id 806161C0014E
	for <netdev@vger.kernel.org>; Sat, 18 Nov 2006 12:06:56 +0100 (CET)
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bonding-fix-oops-when-slave-has-no-get_stats.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bonding driver unconditionnaly dereference get_stats function pointer
for each of its slave device. This patch 
- adds a check for NULL dev->get_stats pointer in bond_get_stats
- prints a notice when the bonding device enslave a device without
  get_stats function.

Signed-off-by: Laurent Riffard <laurent.riffard@free.fr>
---
 drivers/net/bonding/bond_main.c |   61 ++++++++++++++++++++++------------------
 1 file changed, 35 insertions(+), 26 deletions(-)

Index: linux-2.6-mm/drivers/net/bonding/bond_main.c
===================================================================
--- linux-2.6-mm.orig/drivers/net/bonding/bond_main.c
+++ linux-2.6-mm/drivers/net/bonding/bond_main.c
@@ -1336,6 +1336,13 @@ int bond_enslave(struct net_device *bond
 		goto err_undo_flags;
 	}
 
+	if (slave_dev->get_stats == NULL) {
+		printk(KERN_NOTICE DRV_NAME
+			": %s: the driver for slave device %s does not provide "
+			"get_stats function, network statistics will be "
+			"inaccurate.\n", bond_dev->name, slave_dev->name);
+	}
+
 	new_slave = kmalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
 		res = -ENOMEM;
@@ -3605,33 +3612,35 @@ static struct net_device_stats *bond_get
 	read_lock_bh(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
-		sstats = slave->dev->get_stats(slave->dev);
+		if (slave->dev->get_stats) {
+			sstats = slave->dev->get_stats(slave->dev);
 
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
+			stats->rx_packets += sstats->rx_packets;
+			stats->rx_bytes += sstats->rx_bytes;
+			stats->rx_errors += sstats->rx_errors;
+			stats->rx_dropped += sstats->rx_dropped;
+
+			stats->tx_packets += sstats->tx_packets;
+			stats->tx_bytes += sstats->tx_bytes;
+			stats->tx_errors += sstats->tx_errors;
+			stats->tx_dropped += sstats->tx_dropped;
+
+			stats->multicast += sstats->multicast;
+			stats->collisions += sstats->collisions;
+
+			stats->rx_length_errors += sstats->rx_length_errors;
+			stats->rx_over_errors += sstats->rx_over_errors;
+			stats->rx_crc_errors += sstats->rx_crc_errors;
+			stats->rx_frame_errors += sstats->rx_frame_errors;
+			stats->rx_fifo_errors += sstats->rx_fifo_errors;
+			stats->rx_missed_errors += sstats->rx_missed_errors;
+
+			stats->tx_aborted_errors += sstats->tx_aborted_errors;
+			stats->tx_carrier_errors += sstats->tx_carrier_errors;
+			stats->tx_fifo_errors += sstats->tx_fifo_errors;
+			stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
+			stats->tx_window_errors += sstats->tx_window_errors;
+		}
 	}
 
 	read_unlock_bh(&bond->lock);

--
