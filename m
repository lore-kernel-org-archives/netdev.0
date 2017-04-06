From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: igbvf: Use net_device_stats from struct net_device
Date: Thu,  6 Apr 2017 08:45:22 +0200
Message-ID: <20170406064522.13096-1-tklauser@distanz.ch>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:38506 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752504AbdDFGpa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 02:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in
struct igbvf_adapter, use stats from struct net_device. Also remove the
now unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/intel/igbvf/igbvf.h  |  1 -
 drivers/net/ethernet/intel/igbvf/netdev.c | 26 +++++---------------------
 2 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
index 6f4290d6dc9f..11c7238e612c 100644
--- a/drivers/net/ethernet/intel/igbvf/igbvf.h
+++ b/drivers/net/ethernet/intel/igbvf/igbvf.h
@@ -241,7 +241,6 @@ struct igbvf_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 	spinlock_t stats_lock; /* prevent concurrent stats updates */
 
 	/* structs defined in e1000_hw.h */
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 839ba110f7fb..0707d08f7d47 100644
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
 
@@ -1798,7 +1798,7 @@ void igbvf_update_stats(struct igbvf_adapter *adapter)
 	UPDATE_VF_COUNTER(VFGPRLBC, gprlbc);
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.multicast = adapter->stats.mprc;
+	adapter->netdev->stats.multicast = adapter->stats.mprc;
 }
 
 static void igbvf_print_link_info(struct igbvf_adapter *adapter)
@@ -2334,21 +2334,6 @@ static void igbvf_reset_task(struct work_struct *work)
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
@@ -2635,7 +2620,6 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_open		= igbvf_open,
 	.ndo_stop		= igbvf_close,
 	.ndo_start_xmit		= igbvf_xmit_frame,
-	.ndo_get_stats		= igbvf_get_stats,
 	.ndo_set_rx_mode	= igbvf_set_multi,
 	.ndo_set_mac_address	= igbvf_set_mac,
 	.ndo_change_mtu		= igbvf_change_mtu,
-- 
2.12.2.399.g034667a45805
