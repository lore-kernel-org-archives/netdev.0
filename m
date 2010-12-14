From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] e1000e: convert to stats64
Date: Tue, 14 Dec 2010 18:32:15 -0200
Message-ID: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
Cc: e1000-devel@lists.sourceforge.net,
	Flavio Leitner <fleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759597Ab0LNUcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 15:32:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provides accurate stats at the time user reads them.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/e1000e/e1000.h   |    5 ++-
 drivers/net/e1000e/ethtool.c |   27 +++++++++-------
 drivers/net/e1000e/netdev.c  |   68 ++++++++++++++++++++++++-----------------
 3 files changed, 59 insertions(+), 41 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index fdc67fe..5a5e944 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -363,6 +363,8 @@ struct e1000_adapter {
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
 
+	spinlock_t stats64_lock;
+	struct rtnl_link_stats64 stats64;
 	struct e1000_hw_stats stats;
 	struct e1000_phy_info phy_info;
 	struct e1000_phy_stats phy_stats;
@@ -492,7 +494,8 @@ extern int e1000e_setup_rx_resources(struct e1000_adapter *adapter);
 extern int e1000e_setup_tx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_rx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_tx_resources(struct e1000_adapter *adapter);
-extern void e1000e_update_stats(struct e1000_adapter *adapter);
+extern void e1000e_update_stats(struct e1000_adapter *adapter,
+				struct rtnl_link_stats64 *net_stats);
 extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8984d16..07e4d7c 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -49,8 +49,8 @@ struct e1000_stats {
 				sizeof(((struct e1000_adapter *)0)->m), \
 		      		offsetof(struct e1000_adapter, m)
 #define E1000_NETDEV_STAT(m)	NETDEV_STATS, \
-				sizeof(((struct net_device *)0)->m), \
-				offsetof(struct net_device, m)
+				sizeof(((struct rtnl_link_stats64 *)0)->m), \
+				offsetof(struct rtnl_link_stats64, m)
 
 static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
@@ -61,21 +61,21 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "tx_broadcast", E1000_STAT(stats.bptc) },
 	{ "rx_multicast", E1000_STAT(stats.mprc) },
 	{ "tx_multicast", E1000_STAT(stats.mptc) },
-	{ "rx_errors", E1000_NETDEV_STAT(stats.rx_errors) },
-	{ "tx_errors", E1000_NETDEV_STAT(stats.tx_errors) },
-	{ "tx_dropped", E1000_NETDEV_STAT(stats.tx_dropped) },
+	{ "rx_errors", E1000_NETDEV_STAT(rx_errors) },
+	{ "tx_errors", E1000_NETDEV_STAT(tx_errors) },
+	{ "tx_dropped", E1000_NETDEV_STAT(tx_dropped) },
 	{ "multicast", E1000_STAT(stats.mprc) },
 	{ "collisions", E1000_STAT(stats.colc) },
-	{ "rx_length_errors", E1000_NETDEV_STAT(stats.rx_length_errors) },
-	{ "rx_over_errors", E1000_NETDEV_STAT(stats.rx_over_errors) },
+	{ "rx_length_errors", E1000_NETDEV_STAT(rx_length_errors) },
+	{ "rx_over_errors", E1000_NETDEV_STAT(rx_over_errors) },
 	{ "rx_crc_errors", E1000_STAT(stats.crcerrs) },
-	{ "rx_frame_errors", E1000_NETDEV_STAT(stats.rx_frame_errors) },
+	{ "rx_frame_errors", E1000_NETDEV_STAT(rx_frame_errors) },
 	{ "rx_no_buffer_count", E1000_STAT(stats.rnbc) },
 	{ "rx_missed_errors", E1000_STAT(stats.mpc) },
 	{ "tx_aborted_errors", E1000_STAT(stats.ecol) },
 	{ "tx_carrier_errors", E1000_STAT(stats.tncrs) },
-	{ "tx_fifo_errors", E1000_NETDEV_STAT(stats.tx_fifo_errors) },
-	{ "tx_heartbeat_errors", E1000_NETDEV_STAT(stats.tx_heartbeat_errors) },
+	{ "tx_fifo_errors", E1000_NETDEV_STAT(tx_fifo_errors) },
+	{ "tx_heartbeat_errors", E1000_NETDEV_STAT(tx_heartbeat_errors) },
 	{ "tx_window_errors", E1000_STAT(stats.latecol) },
 	{ "tx_abort_late_coll", E1000_STAT(stats.latecol) },
 	{ "tx_deferred_ok", E1000_STAT(stats.dc) },
@@ -1972,14 +1972,16 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 				    u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct rtnl_link_stats64 *net_stats = &adapter->stats64;
 	int i;
 	char *p = NULL;
 
-	e1000e_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter, net_stats);
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		switch (e1000_gstrings_stats[i].type) {
 		case NETDEV_STATS:
-			p = (char *) netdev +
+			p = (char *) net_stats +
 					e1000_gstrings_stats[i].stat_offset;
 			break;
 		case E1000_STATS:
@@ -1991,6 +1993,7 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
+	spin_unlock(&adapter->stats64_lock);
 }
 
 static void e1000_get_strings(struct net_device *netdev, u32 stringset,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c4ca162..0b919ab 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -894,8 +894,6 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	netdev->stats.rx_bytes += total_rx_bytes;
-	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -1051,8 +1049,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	}
 	adapter->total_tx_bytes += total_tx_bytes;
 	adapter->total_tx_packets += total_tx_packets;
-	netdev->stats.tx_bytes += total_tx_bytes;
-	netdev->stats.tx_packets += total_tx_packets;
 	return count < tx_ring->count;
 }
 
@@ -1240,8 +1236,6 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	netdev->stats.rx_bytes += total_rx_bytes;
-	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -1421,8 +1415,6 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	netdev->stats.rx_bytes += total_rx_bytes;
-	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -3367,6 +3359,11 @@ void e1000e_down(struct e1000_adapter *adapter)
 	del_timer_sync(&adapter->phy_info_timer);
 
 	netif_carrier_off(netdev);
+
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter, &adapter->stats64);
+	spin_unlock(&adapter->stats64_lock);
+
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
@@ -3408,6 +3405,8 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
+	spin_lock_init(&adapter->stats64_lock);
+
 	e1000e_set_interrupt_capability(adapter);
 
 	if (e1000_alloc_queues(adapter))
@@ -3880,9 +3879,9 @@ release:
  * e1000e_update_stats - Update the board statistics counters
  * @adapter: board private structure
  **/
-void e1000e_update_stats(struct e1000_adapter *adapter)
+void e1000e_update_stats(struct e1000_adapter *adapter,
+			 struct rtnl_link_stats64 *net_stats)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -3950,8 +3949,12 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.tsctfc += er32(TSCTFC);
 
 	/* Fill out the OS statistics structure */
-	netdev->stats.multicast = adapter->stats.mprc;
-	netdev->stats.collisions = adapter->stats.colc;
+	net_stats->rx_bytes = adapter->stats.gorc;
+	net_stats->rx_packets = adapter->stats.gprc;
+	net_stats->tx_bytes = adapter->stats.gotc;
+	net_stats->tx_packets = adapter->stats.gptc;
+	net_stats->multicast = adapter->stats.mprc;
+	net_stats->collisions = adapter->stats.colc;
 
 	/* Rx Errors */
 
@@ -3959,22 +3962,22 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	 * RLEC on some newer hardware can be incorrect so build
 	 * our own version based on RUC and ROC
 	 */
-	netdev->stats.rx_errors = adapter->stats.rxerrc +
+	net_stats->rx_errors = adapter->stats.rxerrc +
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.ruc + adapter->stats.roc +
 		adapter->stats.cexterr;
-	netdev->stats.rx_length_errors = adapter->stats.ruc +
+	net_stats->rx_length_errors = adapter->stats.ruc +
 					      adapter->stats.roc;
-	netdev->stats.rx_crc_errors = adapter->stats.crcerrs;
-	netdev->stats.rx_frame_errors = adapter->stats.algnerrc;
-	netdev->stats.rx_missed_errors = adapter->stats.mpc;
+	net_stats->rx_crc_errors = adapter->stats.crcerrs;
+	net_stats->rx_frame_errors = adapter->stats.algnerrc;
+	net_stats->rx_missed_errors = adapter->stats.mpc;
 
 	/* Tx Errors */
-	netdev->stats.tx_errors = adapter->stats.ecol +
+	net_stats->tx_errors = adapter->stats.ecol +
 				       adapter->stats.latecol;
-	netdev->stats.tx_aborted_errors = adapter->stats.ecol;
-	netdev->stats.tx_window_errors = adapter->stats.latecol;
-	netdev->stats.tx_carrier_errors = adapter->stats.tncrs;
+	net_stats->tx_aborted_errors = adapter->stats.ecol;
+	net_stats->tx_window_errors = adapter->stats.latecol;
+	net_stats->tx_carrier_errors = adapter->stats.tncrs;
 
 	/* Tx Dropped needs to be maintained elsewhere */
 
@@ -4279,7 +4282,9 @@ static void e1000_watchdog_task(struct work_struct *work)
 	}
 
 link_up:
-	e1000e_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter, &adapter->stats64);
+	spin_unlock(&adapter->stats64_lock);
 
 	mac->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
@@ -4891,16 +4896,23 @@ static void e1000_reset_task(struct work_struct *work)
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
+static struct rtnl_link_stats64 *e1000_get_stats64(struct net_device *netdev,
+						   struct rtnl_link_stats64 *stats)
 {
-	/* only return the current stats */
-	return &netdev->stats;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter, &adapter->stats64);
+	memcpy(stats, &adapter->stats64, sizeof(*stats));
+	spin_unlock(&adapter->stats64_lock);
+
+	return stats;
 }
 
 /**
@@ -5624,7 +5636,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_open		= e1000_open,
 	.ndo_stop		= e1000_close,
 	.ndo_start_xmit		= e1000_xmit_frame,
-	.ndo_get_stats		= e1000_get_stats,
+	.ndo_get_stats64	= e1000_get_stats64,
 	.ndo_set_multicast_list	= e1000_set_multi,
 	.ndo_set_mac_address	= e1000_set_mac,
 	.ndo_change_mtu		= e1000_change_mtu,
-- 
1.7.3.1

