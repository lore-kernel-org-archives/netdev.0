From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/4] e1000e: convert to stats64
Date: Sat, 22 Jan 2011 03:56:13 -0800
Message-ID: <1295697376-2984-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Flavio Leitner <fleitner@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38728 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802Ab1AVL4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 06:56:30 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the patch provided by Flavio Leitner <fleitner@redhat.com>
Provides accurate stats at the time user reads them.

v2: fixed whitespace/merging issues (by Jeff Kirsher)
v3: fixed namespacing issues (by Bruce Allan)

CC: Flavio Leitner <fleitner@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
---
 drivers/net/e1000e/e1000.h   |    5 ++-
 drivers/net/e1000e/ethtool.c |   37 +++++++++++----------
 drivers/net/e1000e/netdev.c  |   72 +++++++++++++++++++++++++++++++++---------
 3 files changed, 80 insertions(+), 34 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index e610e13..00bf595 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -364,6 +364,7 @@ struct e1000_adapter {
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
 
+	spinlock_t stats64_lock;
 	struct e1000_hw_stats stats;
 	struct e1000_phy_info phy_info;
 	struct e1000_phy_stats phy_stats;
@@ -494,7 +495,9 @@ extern int e1000e_setup_rx_resources(struct e1000_adapter *adapter);
 extern int e1000e_setup_tx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_rx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_tx_resources(struct e1000_adapter *adapter);
-extern void e1000e_update_stats(struct e1000_adapter *adapter);
+extern struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
+                                                    struct rtnl_link_stats64
+                                                    *stats);
 extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_get_hw_control(struct e1000_adapter *adapter);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index fa08b63..dfa44de 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -46,15 +46,15 @@ struct e1000_stats {
 };
 
 #define E1000_STAT(str, m) { \
-			.stat_string = str, \
-			.type = E1000_STATS, \
-			.sizeof_stat = sizeof(((struct e1000_adapter *)0)->m), \
-			.stat_offset = offsetof(struct e1000_adapter, m) }
+		.stat_string = str, \
+		.type = E1000_STATS, \
+		.sizeof_stat = sizeof(((struct e1000_adapter *)0)->m), \
+		.stat_offset = offsetof(struct e1000_adapter, m) }
 #define E1000_NETDEV_STAT(str, m) { \
-			.stat_string = str, \
-			.type = NETDEV_STATS, \
-			.sizeof_stat = sizeof(((struct net_device *)0)->m), \
-			.stat_offset = offsetof(struct net_device, m) }
+		.stat_string = str, \
+		.type = NETDEV_STATS, \
+		.sizeof_stat = sizeof(((struct rtnl_link_stats64 *)0)->m), \
+		.stat_offset = offsetof(struct rtnl_link_stats64, m) }
 
 static const struct e1000_stats e1000_gstrings_stats[] = {
 	E1000_STAT("rx_packets", stats.gprc),
@@ -65,21 +65,21 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	E1000_STAT("tx_broadcast", stats.bptc),
 	E1000_STAT("rx_multicast", stats.mprc),
 	E1000_STAT("tx_multicast", stats.mptc),
-	E1000_NETDEV_STAT("rx_errors", stats.rx_errors),
-	E1000_NETDEV_STAT("tx_errors", stats.tx_errors),
-	E1000_NETDEV_STAT("tx_dropped", stats.tx_dropped),
+	E1000_NETDEV_STAT("rx_errors", rx_errors),
+	E1000_NETDEV_STAT("tx_errors", tx_errors),
+	E1000_NETDEV_STAT("tx_dropped", tx_dropped),
 	E1000_STAT("multicast", stats.mprc),
 	E1000_STAT("collisions", stats.colc),
-	E1000_NETDEV_STAT("rx_length_errors", stats.rx_length_errors),
-	E1000_NETDEV_STAT("rx_over_errors", stats.rx_over_errors),
+	E1000_NETDEV_STAT("rx_length_errors", rx_length_errors),
+	E1000_NETDEV_STAT("rx_over_errors", rx_over_errors),
 	E1000_STAT("rx_crc_errors", stats.crcerrs),
-	E1000_NETDEV_STAT("rx_frame_errors", stats.rx_frame_errors),
+	E1000_NETDEV_STAT("rx_frame_errors", rx_frame_errors),
 	E1000_STAT("rx_no_buffer_count", stats.rnbc),
 	E1000_STAT("rx_missed_errors", stats.mpc),
 	E1000_STAT("tx_aborted_errors", stats.ecol),
 	E1000_STAT("tx_carrier_errors", stats.tncrs),
-	E1000_NETDEV_STAT("tx_fifo_errors", stats.tx_fifo_errors),
-	E1000_NETDEV_STAT("tx_heartbeat_errors", stats.tx_heartbeat_errors),
+	E1000_NETDEV_STAT("tx_fifo_errors", tx_fifo_errors),
+	E1000_NETDEV_STAT("tx_heartbeat_errors", tx_heartbeat_errors),
 	E1000_STAT("tx_window_errors", stats.latecol),
 	E1000_STAT("tx_abort_late_coll", stats.latecol),
 	E1000_STAT("tx_deferred_ok", stats.dc),
@@ -1982,14 +1982,15 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 				    u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct rtnl_link_stats64 net_stats;
 	int i;
 	char *p = NULL;
 
-	e1000e_update_stats(adapter);
+	e1000e_get_stats64(netdev, &net_stats);
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		switch (e1000_gstrings_stats[i].type) {
 		case NETDEV_STATS:
-			p = (char *) netdev +
+			p = (char *) &net_stats +
 					e1000_gstrings_stats[i].stat_offset;
 			break;
 		case E1000_STATS:
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1c18f26..1c2f33d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -900,8 +900,6 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	netdev->stats.rx_bytes += total_rx_bytes;
-	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -1057,8 +1055,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	}
 	adapter->total_tx_bytes += total_tx_bytes;
 	adapter->total_tx_packets += total_tx_packets;
-	netdev->stats.tx_bytes += total_tx_bytes;
-	netdev->stats.tx_packets += total_tx_packets;
 	return count < tx_ring->count;
 }
 
@@ -1245,8 +1241,6 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	netdev->stats.rx_bytes += total_rx_bytes;
-	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -1426,8 +1420,6 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	netdev->stats.rx_bytes += total_rx_bytes;
-	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -3338,6 +3330,8 @@ int e1000e_up(struct e1000_adapter *adapter)
 	return 0;
 }
 
+static void e1000e_update_stats(struct e1000_adapter *adapter);
+
 void e1000e_down(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -3372,6 +3366,11 @@ void e1000e_down(struct e1000_adapter *adapter)
 	del_timer_sync(&adapter->phy_info_timer);
 
 	netif_carrier_off(netdev);
+
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter);
+	spin_unlock(&adapter->stats64_lock);
+
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
@@ -3413,6 +3412,8 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
+	spin_lock_init(&adapter->stats64_lock);
+
 	e1000e_set_interrupt_capability(adapter);
 
 	if (e1000_alloc_queues(adapter))
@@ -3886,7 +3887,7 @@ release:
  * e1000e_update_stats - Update the board statistics counters
  * @adapter: board private structure
  **/
-void e1000e_update_stats(struct e1000_adapter *adapter)
+static void e1000e_update_stats(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
@@ -4285,7 +4286,9 @@ static void e1000_watchdog_task(struct work_struct *work)
 	}
 
 link_up:
+	spin_lock(&adapter->stats64_lock);
 	e1000e_update_stats(adapter);
+	spin_unlock(&adapter->stats64_lock);
 
 	mac->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
@@ -4897,16 +4900,55 @@ static void e1000_reset_task(struct work_struct *work)
 }
 
 /**
- * e1000_get_stats - Get System Network Statistics
+ * e1000_get_stats64 - Get System Network Statistics
  * @netdev: network interface device structure
+ * @stats: rtnl_link_stats64 pointer
  *
  * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
  **/
-static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
+struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
+                                             struct rtnl_link_stats64 *stats)
 {
-	/* only return the current stats */
-	return &netdev->stats;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	memset(stats, 0, sizeof(struct rtnl_link_stats64));
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter);
+	/* Fill out the OS statistics structure */
+	stats->rx_bytes = adapter->stats.gorc;
+	stats->rx_packets = adapter->stats.gprc;
+	stats->tx_bytes = adapter->stats.gotc;
+	stats->tx_packets = adapter->stats.gptc;
+	stats->multicast = adapter->stats.mprc;
+	stats->collisions = adapter->stats.colc;
+
+	/* Rx Errors */
+
+	/*
+	 * RLEC on some newer hardware can be incorrect so build
+	 * our own version based on RUC and ROC
+	 */
+	stats->rx_errors = adapter->stats.rxerrc +
+		adapter->stats.crcerrs + adapter->stats.algnerrc +
+		adapter->stats.ruc + adapter->stats.roc +
+		adapter->stats.cexterr;
+	stats->rx_length_errors = adapter->stats.ruc +
+					      adapter->stats.roc;
+	stats->rx_crc_errors = adapter->stats.crcerrs;
+	stats->rx_frame_errors = adapter->stats.algnerrc;
+	stats->rx_missed_errors = adapter->stats.mpc;
+
+	/* Tx Errors */
+	stats->tx_errors = adapter->stats.ecol +
+				       adapter->stats.latecol;
+	stats->tx_aborted_errors = adapter->stats.ecol;
+	stats->tx_window_errors = adapter->stats.latecol;
+	stats->tx_carrier_errors = adapter->stats.tncrs;
+
+	/* Tx Dropped needs to be maintained elsewhere */
+
+	spin_unlock(&adapter->stats64_lock);
+	return stats;
 }
 
 /**
@@ -5675,7 +5717,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_open		= e1000_open,
 	.ndo_stop		= e1000_close,
 	.ndo_start_xmit		= e1000_xmit_frame,
-	.ndo_get_stats		= e1000_get_stats,
+	.ndo_get_stats64	= e1000e_get_stats64,
 	.ndo_set_multicast_list	= e1000_set_multi,
 	.ndo_set_mac_address	= e1000_set_mac,
 	.ndo_change_mtu		= e1000_change_mtu,
-- 
1.7.3.4

