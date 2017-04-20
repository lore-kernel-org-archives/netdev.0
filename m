From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] igbvf: Use net_device_stats from struct net_device
Date: Thu, 20 Apr 2017 16:33:35 -0700
Message-ID: <20170420233335.34900-8-jeffrey.t.kirsher@intel.com>
References: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Cc: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:35690 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947164AbdDTXdu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 19:33:50 -0400
In-Reply-To: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

Instead of using a private copy of struct net_device_stats in
struct igbvf_adapter, use stats from struct net_device. Also remove the
now unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/igbvf.h  |  1 -
 drivers/net/ethernet/intel/igbvf/netdev.c | 26 +++++---------------------
 2 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
index 2a53ed84d9fc..bf69f01f8467 100644
--- a/drivers/net/ethernet/intel/igbvf/igbvf.h
+++ b/drivers/net/ethernet/intel/igbvf/igbvf.h
@@ -243,7 +243,6 @@ struct igbvf_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 	spinlock_t stats_lock; /* prevent concurrent stats updates */
 
 	/* structs defined in e1000_hw.h */
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 6029854b6a70..1b9cbbe88f6f 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -400,8 +400,8 @@ static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
 
 	adapter->total_rx_packets += total_packets;
 	adapter->total_rx_bytes += total_bytes;
-	adapter->net_stats.rx_bytes += total_bytes;
-	adapter->net_stats.rx_packets += total_packets;
+	netdev->stats.rx_bytes += total_bytes;
+	netdev->stats.rx_packets += total_packets;
 	return cleaned;
 }
 
@@ -864,8 +864,8 @@ static bool igbvf_clean_tx_irq(struct igbvf_ring *tx_ring)
 		}
 	}
 
-	adapter->net_stats.tx_bytes += total_bytes;
-	adapter->net_stats.tx_packets += total_packets;
+	netdev->stats.tx_bytes += total_bytes;
+	netdev->stats.tx_packets += total_packets;
 	return count < tx_ring->count;
 }
 
@@ -1838,7 +1838,7 @@ void igbvf_update_stats(struct igbvf_adapter *adapter)
 	UPDATE_VF_COUNTER(VFGPRLBC, gprlbc);
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.multicast = adapter->stats.mprc;
+	adapter->netdev->stats.multicast = adapter->stats.mprc;
 }
 
 static void igbvf_print_link_info(struct igbvf_adapter *adapter)
@@ -2374,21 +2374,6 @@ static void igbvf_reset_task(struct work_struct *work)
 }
 
 /**
- * igbvf_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- **/
-static struct net_device_stats *igbvf_get_stats(struct net_device *netdev)
-{
-	struct igbvf_adapter *adapter = netdev_priv(netdev);
-
-	/* only return the current stats */
-	return &adapter->net_stats;
-}
-
-/**
  * igbvf_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -2675,7 +2660,6 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_open		= igbvf_open,
 	.ndo_stop		= igbvf_close,
 	.ndo_start_xmit		= igbvf_xmit_frame,
-	.ndo_get_stats		= igbvf_get_stats,
 	.ndo_set_rx_mode	= igbvf_set_rx_mode,
 	.ndo_set_mac_address	= igbvf_set_mac,
 	.ndo_change_mtu		= igbvf_change_mtu,
-- 
2.12.2
