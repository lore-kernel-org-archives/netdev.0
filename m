From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] igb: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 18:12:56 +0530
Message-ID: <20091007124245.GA30070@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:65345 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759078AbZJGMno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:43:44 -0400
Received: by fxm27 with SMTP id 27so4550688fxm.17
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:43:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/igb/igb.h         |    1 -
 drivers/net/igb/igb_ethtool.c |   20 +++++++++++---------
 drivers/net/igb/igb_main.c    |   39 +++++++++++++++++++--------------------
 3 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 7126fea..b805b1c 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -256,7 +256,6 @@ struct igb_adapter {
 	struct net_device *netdev;
 	struct napi_struct napi;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 	struct cyclecounter cycles;
 	struct timecounter clock;
 	struct timecompare compare;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index d004c35..d46c321 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -45,6 +45,8 @@ struct igb_stats {
 
 #define IGB_STAT(m) FIELD_SIZEOF(struct igb_adapter, m), \
 		      offsetof(struct igb_adapter, m)
+#define IGB_NETDEV_STAT(m) FIELD_SIZEOF(struct net_device, m), \
+		      offsetof(struct net_device, m)
 static const struct igb_stats igb_gstrings_stats[] = {
 	{ "rx_packets", IGB_STAT(stats.gprc) },
 	{ "tx_packets", IGB_STAT(stats.gptc) },
@@ -54,22 +56,22 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	{ "tx_broadcast", IGB_STAT(stats.bptc) },
 	{ "rx_multicast", IGB_STAT(stats.mprc) },
 	{ "tx_multicast", IGB_STAT(stats.mptc) },
-	{ "rx_errors", IGB_STAT(net_stats.rx_errors) },
-	{ "tx_errors", IGB_STAT(net_stats.tx_errors) },
-	{ "tx_dropped", IGB_STAT(net_stats.tx_dropped) },
+	{ "rx_errors", IGB_NETDEV_STAT(stats.rx_errors) },
+	{ "tx_errors", IGB_NETDEV_STAT(stats.tx_errors) },
+	{ "tx_dropped", IGB_NETDEV_STAT(stats.tx_dropped) },
 	{ "multicast", IGB_STAT(stats.mprc) },
 	{ "collisions", IGB_STAT(stats.colc) },
-	{ "rx_length_errors", IGB_STAT(net_stats.rx_length_errors) },
-	{ "rx_over_errors", IGB_STAT(net_stats.rx_over_errors) },
+	{ "rx_length_errors", IGB_NETDEV_STAT(stats.rx_length_errors) },
+	{ "rx_over_errors", IGB_NETDEV_STAT(stats.rx_over_errors) },
 	{ "rx_crc_errors", IGB_STAT(stats.crcerrs) },
-	{ "rx_frame_errors", IGB_STAT(net_stats.rx_frame_errors) },
+	{ "rx_frame_errors", IGB_NETDEV_STAT(stats.rx_frame_errors) },
 	{ "rx_no_buffer_count", IGB_STAT(stats.rnbc) },
-	{ "rx_queue_drop_packet_count", IGB_STAT(net_stats.rx_fifo_errors) },
+	{ "rx_queue_drop_packet_count", IGB_NETDEV_STAT(stats.rx_fifo_errors) },
 	{ "rx_missed_errors", IGB_STAT(stats.mpc) },
 	{ "tx_aborted_errors", IGB_STAT(stats.ecol) },
 	{ "tx_carrier_errors", IGB_STAT(stats.tncrs) },
-	{ "tx_fifo_errors", IGB_STAT(net_stats.tx_fifo_errors) },
-	{ "tx_heartbeat_errors", IGB_STAT(net_stats.tx_heartbeat_errors) },
+	{ "tx_fifo_errors", IGB_NETDEV_STAT(stats.tx_fifo_errors) },
+	{ "tx_heartbeat_errors", IGB_NETDEV_STAT(stats.tx_heartbeat_errors) },
 	{ "tx_window_errors", IGB_STAT(stats.latecol) },
 	{ "tx_abort_late_coll", IGB_STAT(stats.latecol) },
 	{ "tx_deferred_ok", IGB_STAT(stats.dc) },
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 83c0837..428d504 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3534,10 +3534,8 @@ static void igb_reset_task(struct work_struct *work)
  **/
 static struct net_device_stats *igb_get_stats(struct net_device *netdev)
 {
-	struct igb_adapter *adapter = netdev_priv(netdev);
-
 	/* only return the current stats */
-	return &adapter->net_stats;
+	return &netdev->stats;
 }
 
 /**
@@ -3623,6 +3621,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 
 void igb_update_stats(struct igb_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 phy_tmp;
@@ -3712,8 +3711,8 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->stats.icrxdmtc += rd32(E1000_ICRXDMTC);
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.multicast = adapter->stats.mprc;
-	adapter->net_stats.collisions = adapter->stats.colc;
+	netdev->stats.multicast = adapter->stats.mprc;
+	netdev->stats.collisions = adapter->stats.colc;
 
 	/* Rx Errors */
 
@@ -3734,7 +3733,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 			adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
 			rqdpc_total += adapter->rx_ring[i].rx_stats.drops;
 		}
-		adapter->net_stats.rx_fifo_errors = rqdpc_total;
+		netdev->stats.rx_fifo_errors = rqdpc_total;
 	}
 
 	/* Note RNBC (Receive No Buffers Count) is an not an exact
@@ -3742,26 +3741,26 @@ void igb_update_stats(struct igb_adapter *adapter)
 	 * one of the reason for saving it in rx_fifo_errors, as its
 	 * potentially not a true drop.
 	 */
-	adapter->net_stats.rx_fifo_errors += adapter->stats.rnbc;
+	netdev->stats.rx_fifo_errors += adapter->stats.rnbc;
 
 	/* RLEC on some newer hardware can be incorrect so build
 	 * our own version based on RUC and ROC */
-	adapter->net_stats.rx_errors = adapter->stats.rxerrc +
+	netdev->stats.rx_errors = adapter->stats.rxerrc +
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.ruc + adapter->stats.roc +
 		adapter->stats.cexterr;
-	adapter->net_stats.rx_length_errors = adapter->stats.ruc +
+	netdev->stats.rx_length_errors = adapter->stats.ruc +
 					      adapter->stats.roc;
-	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
-	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
-	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
+	netdev->stats.rx_crc_errors = adapter->stats.crcerrs;
+	netdev->stats.rx_frame_errors = adapter->stats.algnerrc;
+	netdev->stats.rx_missed_errors = adapter->stats.mpc;
 
 	/* Tx Errors */
-	adapter->net_stats.tx_errors = adapter->stats.ecol +
+	netdev->stats.tx_errors = adapter->stats.ecol +
 				       adapter->stats.latecol;
-	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
-	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
-	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
+	netdev->stats.tx_aborted_errors = adapter->stats.ecol;
+	netdev->stats.tx_window_errors = adapter->stats.latecol;
+	netdev->stats.tx_carrier_errors = adapter->stats.tncrs;
 
 	/* Tx Dropped needs to be maintained elsewhere */
 
@@ -4640,8 +4639,8 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 	tx_ring->total_packets += total_packets;
 	tx_ring->tx_stats.bytes += total_bytes;
 	tx_ring->tx_stats.packets += total_packets;
-	adapter->net_stats.tx_bytes += total_bytes;
-	adapter->net_stats.tx_packets += total_packets;
+	netdev->stats.tx_bytes += total_bytes;
+	netdev->stats.tx_packets += total_packets;
 	return (count < tx_ring->count);
 }
 
@@ -4884,8 +4883,8 @@ next_desc:
 	rx_ring->total_bytes += total_bytes;
 	rx_ring->rx_stats.packets += total_packets;
 	rx_ring->rx_stats.bytes += total_bytes;
-	adapter->net_stats.rx_bytes += total_bytes;
-	adapter->net_stats.rx_packets += total_packets;
+	netdev->stats.rx_bytes += total_bytes;
+	netdev->stats.rx_packets += total_packets;
 	return cleaned;
 }
 
-- 
1.6.0.4

