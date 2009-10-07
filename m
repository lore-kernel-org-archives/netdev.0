From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] e1000e: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 18:14:26 +0530
Message-ID: <20091007124416.GA30096@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:53265 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758978AbZJGMpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:45:13 -0400
Received: by bwz6 with SMTP id 6so27950bwz.37
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:44:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the private adapter structure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/e1000e/e1000.h   |    1 -
 drivers/net/e1000e/ethtool.c |   18 +++++++++-------
 drivers/net/e1000e/netdev.c  |   43 ++++++++++++++++++++---------------------
 3 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 981936c..1211df9 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -315,7 +315,6 @@ struct e1000_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 1bf4d2a..8a78a14 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -43,6 +43,8 @@ struct e1000_stats {
 
 #define E1000_STAT(m) sizeof(((struct e1000_adapter *)0)->m), \
 		      offsetof(struct e1000_adapter, m)
+#define E1000_NETDEV_STAT(m) sizeof(((struct net_device *)0)->m), \
+		      offsetof(struct net_device, m)
 static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
 	{ "tx_packets", E1000_STAT(stats.gptc) },
@@ -52,21 +54,21 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "tx_broadcast", E1000_STAT(stats.bptc) },
 	{ "rx_multicast", E1000_STAT(stats.mprc) },
 	{ "tx_multicast", E1000_STAT(stats.mptc) },
-	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
-	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
-	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },
+	{ "rx_errors", E1000_NETDEV_STAT(stats.rx_errors) },
+	{ "tx_errors", E1000_NETDEV_STAT(stats.tx_errors) },
+	{ "tx_dropped", E1000_NETDEV_STAT(stats.tx_dropped) },
 	{ "multicast", E1000_STAT(stats.mprc) },
 	{ "collisions", E1000_STAT(stats.colc) },
-	{ "rx_length_errors", E1000_STAT(net_stats.rx_length_errors) },
-	{ "rx_over_errors", E1000_STAT(net_stats.rx_over_errors) },
+	{ "rx_length_errors", E1000_NETDEV_STAT(stats.rx_length_errors) },
+	{ "rx_over_errors", E1000_NETDEV_STAT(stats.rx_over_errors) },
 	{ "rx_crc_errors", E1000_STAT(stats.crcerrs) },
-	{ "rx_frame_errors", E1000_STAT(net_stats.rx_frame_errors) },
+	{ "rx_frame_errors", E1000_NETDEV_STAT(stats.rx_frame_errors) },
 	{ "rx_no_buffer_count", E1000_STAT(stats.rnbc) },
 	{ "rx_missed_errors", E1000_STAT(stats.mpc) },
 	{ "tx_aborted_errors", E1000_STAT(stats.ecol) },
 	{ "tx_carrier_errors", E1000_STAT(stats.tncrs) },
-	{ "tx_fifo_errors", E1000_STAT(net_stats.tx_fifo_errors) },
-	{ "tx_heartbeat_errors", E1000_STAT(net_stats.tx_heartbeat_errors) },
+	{ "tx_fifo_errors", E1000_NETDEV_STAT(stats.tx_fifo_errors) },
+	{ "tx_heartbeat_errors", E1000_NETDEV_STAT(stats.tx_heartbeat_errors) },
 	{ "tx_window_errors", E1000_STAT(stats.latecol) },
 	{ "tx_abort_late_coll", E1000_STAT(stats.latecol) },
 	{ "tx_deferred_ok", E1000_STAT(stats.dc) },
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0687c6a..21af398 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -560,8 +560,8 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
+	netdev->stats.rx_bytes += total_rx_bytes;
+	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -690,8 +690,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	}
 	adapter->total_tx_bytes += total_tx_bytes;
 	adapter->total_tx_packets += total_tx_packets;
-	adapter->net_stats.tx_bytes += total_tx_bytes;
-	adapter->net_stats.tx_packets += total_tx_packets;
+	netdev->stats.tx_bytes += total_tx_bytes;
+	netdev->stats.tx_packets += total_tx_packets;
 	return (count < tx_ring->count);
 }
 
@@ -871,8 +871,8 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
+	netdev->stats.rx_bytes += total_rx_bytes;
+	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -1051,8 +1051,8 @@ next_desc:
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
+	netdev->stats.rx_bytes += total_rx_bytes;
+	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -3287,6 +3287,7 @@ static void e1000_update_phy_info(unsigned long data)
  **/
 void e1000e_update_stats(struct e1000_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 phy_data;
@@ -3381,8 +3382,8 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.tsctfc += er32(TSCTFC);
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.multicast = adapter->stats.mprc;
-	adapter->net_stats.collisions = adapter->stats.colc;
+	netdev->stats.multicast = adapter->stats.mprc;
+	netdev->stats.collisions = adapter->stats.colc;
 
 	/* Rx Errors */
 
@@ -3390,22 +3391,22 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	 * RLEC on some newer hardware can be incorrect so build
 	 * our own version based on RUC and ROC
 	 */
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
 
@@ -4254,10 +4255,8 @@ static void e1000_reset_task(struct work_struct *work)
  **/
 static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-
 	/* only return the current stats */
-	return &adapter->net_stats;
+	return &netdev->stats;
 }
 
 /**
-- 
1.6.0.4

