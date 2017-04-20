From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40evf: Use net_device_stats from struct net_device
Date: Wed, 19 Apr 2017 18:57:37 -0700
Message-ID: <20170420015750.6828-2-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:29694 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1765268AbdDTB5z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:57:55 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

Instead of using a private copy of struct net_device_stats in
struct i40evf_adapter, use stats from struct net_device. Also remove the
now unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 16 ----------------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 22 +++++++++++-----------
 3 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 35ded19e9cc2..7bbd11abed08 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -252,7 +252,6 @@ struct i40evf_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 
 	struct i40e_hw hw; /* defined in i40e_type.h */
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 12a930e879af..671913c74bf8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2243,21 +2243,6 @@ static int i40evf_close(struct net_device *netdev)
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
@@ -2363,7 +2348,6 @@ static const struct net_device_ops i40evf_netdev_ops = {
 	.ndo_open		= i40evf_open,
 	.ndo_stop		= i40evf_close,
 	.ndo_start_xmit		= i40evf_xmit_frame,
-	.ndo_get_stats		= i40evf_get_stats,
 	.ndo_set_rx_mode	= i40evf_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= i40evf_set_mac,
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 3bccfbb1db14..deb2cb8dac6b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -960,17 +960,17 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
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
2.12.2
