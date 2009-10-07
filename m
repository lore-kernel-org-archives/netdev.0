From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] e1000: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 18:12:23 +0530
Message-ID: <20091007124213.GA30056@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:62579 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758924AbZJGMmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:42:45 -0400
Received: by mail-bw0-f210.google.com with SMTP id 6so25663bwz.37
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:42:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/e1000/e1000.h         |    1 -
 drivers/net/e1000/e1000_ethtool.c |   12 ++++++----
 drivers/net/e1000/e1000_main.c    |   41 ++++++++++++++++++-------------------
 3 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 42e2b7e..a566528 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -302,7 +302,6 @@ struct e1000_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 490b2b7..e25b339 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -39,6 +39,8 @@ struct e1000_stats {
 
 #define E1000_STAT(m) FIELD_SIZEOF(struct e1000_adapter, m), \
 		      offsetof(struct e1000_adapter, m)
+#define E1000_NETDEV_STAT(m) FIELD_SIZEOF(struct net_device, m), \
+		      offsetof(struct net_device, m)
 static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
 	{ "tx_packets", E1000_STAT(stats.gptc) },
@@ -50,19 +52,19 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "tx_multicast", E1000_STAT(stats.mptc) },
 	{ "rx_errors", E1000_STAT(stats.rxerrc) },
 	{ "tx_errors", E1000_STAT(stats.txerrc) },
-	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },
+	{ "tx_dropped", E1000_NETDEV_STAT(stats.tx_dropped) },
 	{ "multicast", E1000_STAT(stats.mprc) },
 	{ "collisions", E1000_STAT(stats.colc) },
 	{ "rx_length_errors", E1000_STAT(stats.rlerrc) },
-	{ "rx_over_errors", E1000_STAT(net_stats.rx_over_errors) },
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
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index bcd192c..6a61414 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3101,10 +3101,8 @@ static void e1000_reset_task(struct work_struct *work)
 
 static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-
 	/* only return the current stats */
-	return &adapter->net_stats;
+	return &netdev->stats;
 }
 
 /**
@@ -3196,6 +3194,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 void e1000_update_stats(struct e1000_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long flags;
@@ -3288,32 +3287,32 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	}
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.multicast = adapter->stats.mprc;
-	adapter->net_stats.collisions = adapter->stats.colc;
+	netdev->stats.multicast = adapter->stats.mprc;
+	netdev->stats.collisions = adapter->stats.colc;
 
 	/* Rx Errors */
 
 	/* RLEC on some newer hardware can be incorrect so build
 	* our own version based on RUC and ROC */
-	adapter->net_stats.rx_errors = adapter->stats.rxerrc +
+	netdev->stats.rx_errors = adapter->stats.rxerrc +
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.ruc + adapter->stats.roc +
 		adapter->stats.cexterr;
 	adapter->stats.rlerrc = adapter->stats.ruc + adapter->stats.roc;
-	adapter->net_stats.rx_length_errors = adapter->stats.rlerrc;
-	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
-	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
-	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
+	netdev->stats.rx_length_errors = adapter->stats.rlerrc;
+	netdev->stats.rx_crc_errors = adapter->stats.crcerrs;
+	netdev->stats.rx_frame_errors = adapter->stats.algnerrc;
+	netdev->stats.rx_missed_errors = adapter->stats.mpc;
 
 	/* Tx Errors */
 	adapter->stats.txerrc = adapter->stats.ecol + adapter->stats.latecol;
-	adapter->net_stats.tx_errors = adapter->stats.txerrc;
-	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
-	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
-	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
+	netdev->stats.tx_errors = adapter->stats.txerrc;
+	netdev->stats.tx_aborted_errors = adapter->stats.ecol;
+	netdev->stats.tx_window_errors = adapter->stats.latecol;
+	netdev->stats.tx_carrier_errors = adapter->stats.tncrs;
 	if (hw->bad_tx_carr_stats_fd &&
 	    adapter->link_duplex == FULL_DUPLEX) {
-		adapter->net_stats.tx_carrier_errors = 0;
+		netdev->stats.tx_carrier_errors = 0;
 		adapter->stats.tncrs = 0;
 	}
 
@@ -3514,8 +3513,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	}
 	adapter->total_tx_bytes += total_tx_bytes;
 	adapter->total_tx_packets += total_tx_packets;
-	adapter->net_stats.tx_bytes += total_tx_bytes;
-	adapter->net_stats.tx_packets += total_tx_packets;
+	netdev->stats.tx_bytes += total_tx_bytes;
+	netdev->stats.tx_packets += total_tx_packets;
 	return (count < tx_ring->count);
 }
 
@@ -3767,8 +3766,8 @@ next_desc:
 
 	adapter->total_rx_packets += total_rx_packets;
 	adapter->total_rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
+	netdev->stats.rx_bytes += total_rx_bytes;
+	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
@@ -3916,8 +3915,8 @@ next_desc:
 
 	adapter->total_rx_packets += total_rx_packets;
 	adapter->total_rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
+	netdev->stats.rx_bytes += total_rx_bytes;
+	netdev->stats.rx_packets += total_rx_packets;
 	return cleaned;
 }
 
-- 
1.6.0.4

