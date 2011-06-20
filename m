From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] ixgbevf: provide 64 bit statistics
Date: Sun, 19 Jun 2011 17:58:25 -0700
Message-ID: <1308531518-17298-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51969 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491Ab1FTA7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:59:01 -0400
In-Reply-To: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Compute statistics per ring using 64 bits, and provide
network device stats in 64 bits.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Greg Rose <Gregory.v.rose@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf.h      |    6 +++---
 drivers/net/ixgbevf/ixgbevf_main.c |   33 ++++++++++++++++++++++++---------
 2 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index a2bbbb3..f060840 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -69,12 +69,12 @@ struct ixgbevf_ring {
 		struct ixgbevf_rx_buffer *rx_buffer_info;
 	};
 
+	u64 total_bytes;
+	u64 total_packets;
+
 	u16 head;
 	u16 tail;
 
-	unsigned int total_bytes;
-	unsigned int total_packets;
-
 	u16 reg_idx; /* holds the special value that gets the hardware register
 		      * offset associated with this ring, which is different
 		      * for DCB and RSS modes */
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 721417e..c1f9fa6 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -267,9 +267,6 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
 
-	netdev->stats.tx_bytes += total_bytes;
-	netdev->stats.tx_packets += total_packets;
-
 	return count < tx_ring->work_limit;
 }
 
@@ -597,8 +594,6 @@ next_desc:
 
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
-	adapter->netdev->stats.rx_bytes += total_rx_bytes;
-	adapter->netdev->stats.rx_packets += total_rx_packets;
 
 	return cleaned;
 }
@@ -2288,10 +2283,6 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 				adapter->stats.vfgotc);
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFMPRC, adapter->stats.last_vfmprc,
 				adapter->stats.vfmprc);
-
-	/* Fill out the OS statistics structure */
-	adapter->netdev->stats.multicast = adapter->stats.vfmprc -
-		adapter->stats.base_vfmprc;
 }
 
 /**
@@ -3248,11 +3239,35 @@ static void ixgbevf_shutdown(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
+static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
+						   struct rtnl_link_stats64 *stats)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	int i;
+
+	ixgbevf_update_stats(adapter);
+
+	stats->multicast = adapter->stats.vfmprc - adapter->stats.base_vfmprc;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		stats->rx_bytes += adapter->rx_ring[i].total_bytes;
+		stats->rx_packets += adapter->rx_ring[i].total_packets;
+	}
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		stats->tx_bytes += adapter->tx_ring[i].total_bytes;
+		stats->tx_packets += adapter->tx_ring[i].total_packets;
+	}
+
+	return stats;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= &ixgbevf_open,
 	.ndo_stop		= &ixgbevf_close,
 	.ndo_start_xmit		= &ixgbevf_xmit_frame,
 	.ndo_set_rx_mode	= &ixgbevf_set_rx_mode,
+	.ndo_get_stats64	= ixgbevf_get_stats,
 	.ndo_set_multicast_list	= &ixgbevf_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= &ixgbevf_set_mac,
-- 
1.7.5.4

