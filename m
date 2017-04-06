From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: i40evf: Use net_device_stats from struct net_device
Date: Thu,  6 Apr 2017 08:46:28 +0200
Message-ID: <20170406064628.13459-1-tklauser@distanz.ch>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:38534 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933265AbdDFGqe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 02:46:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in
struct i40evf_adapter, use stats from struct net_device. Also remove the
now unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 16 ----------------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 22 +++++++++++-----------
 3 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index d61ecf655091..66d4880b5c14 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -253,7 +253,6 @@ struct i40evf_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 
 	struct i40e_hw hw; /* defined in i40e_type.h */
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index fb2811c23024..1e36561b428a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2231,21 +2231,6 @@ static int i40evf_close(struct net_device *netdev)
 }
 
 /**
- * i40evf_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- **/
-static struct net_device_stats *i40evf_get_stats(struct net_device *netdev)
-{
-	struct i40evf_adapter *adapter = netdev_priv(netdev);
-
-	/* only return the current stats */
-	return &adapter->net_stats;
-}
-
-/**
  * i40evf_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -2351,7 +2336,6 @@ static const struct net_device_ops i40evf_netdev_ops = {
 	.ndo_open		= i40evf_open,
 	.ndo_stop		= i40evf_close,
 	.ndo_start_xmit		= i40evf_xmit_frame,
-	.ndo_get_stats		= i40evf_get_stats,
 	.ndo_set_rx_mode	= i40evf_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= i40evf_set_mac,
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 032be8d3928a..91121de0d928 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -958,17 +958,17 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 	case I40E_VIRTCHNL_OP_GET_STATS: {
 		struct i40e_eth_stats *stats =
 			(struct i40e_eth_stats *)msg;
-		adapter->net_stats.rx_packets = stats->rx_unicast +
-						 stats->rx_multicast +
-						 stats->rx_broadcast;
-		adapter->net_stats.tx_packets = stats->tx_unicast +
-						 stats->tx_multicast +
-						 stats->tx_broadcast;
-		adapter->net_stats.rx_bytes = stats->rx_bytes;
-		adapter->net_stats.tx_bytes = stats->tx_bytes;
-		adapter->net_stats.tx_errors = stats->tx_errors;
-		adapter->net_stats.rx_dropped = stats->rx_discards;
-		adapter->net_stats.tx_dropped = stats->tx_discards;
+		netdev->stats.rx_packets = stats->rx_unicast +
+					   stats->rx_multicast +
+					   stats->rx_broadcast;
+		netdev->stats.tx_packets = stats->tx_unicast +
+					   stats->tx_multicast +
+					   stats->tx_broadcast;
+		netdev->stats.rx_bytes = stats->rx_bytes;
+		netdev->stats.tx_bytes = stats->tx_bytes;
+		netdev->stats.tx_errors = stats->tx_errors;
+		netdev->stats.rx_dropped = stats->rx_discards;
+		netdev->stats.tx_dropped = stats->tx_discards;
 		adapter->current_stats = *stats;
 		}
 		break;
-- 
2.12.2.399.g034667a45805
