From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] ixgbevf: provide 64 bit statistics
Date: Sat, 27 Aug 2011 00:09:28 -0700
Message-ID: <1314428971-7676-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2448 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865Ab1H0HJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Aug 2011 03:09:36 -0400
In-Reply-To: <1314428971-7676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Compute statistics per ring using 64 bits, and provide
network device stats in 64 bits.

It should make this driver multiqueue operations faster (no more cache
line ping pongs on netdev->stats structure)

Use u64_stats_sync infrastructure so that its safe on 32bit arches as
well.

Based on a prior patch from Stephen Hemminger

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    8 ++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   52 +++++++++++++++++----
 2 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 8857df4..e6c9d1a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -34,6 +34,7 @@
 #include <linux/io.h>
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
+#include <linux/u64_stats_sync.h>
 
 #include "vf.h"
 
@@ -71,12 +72,13 @@ struct ixgbevf_ring {
 		struct ixgbevf_rx_buffer *rx_buffer_info;
 	};
 
+	u64			total_bytes;
+	u64			total_packets;
+	struct u64_stats_sync	syncp;
+
 	u16 head;
 	u16 tail;
 
-	unsigned int total_bytes;
-	unsigned int total_packets;
-
 	u16 reg_idx; /* holds the special value that gets the hardware register
 		      * offset associated with this ring, which is different
 		      * for DCB and RSS modes */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 936532f..bc12dd8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -270,11 +270,10 @@ cont_loop:
 		IXGBE_WRITE_REG(hw, IXGBE_VTEICS, tx_ring->v_idx);
 	}
 
+	u64_stats_update_begin(&tx_ring->syncp);
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
-
-	netdev->stats.tx_bytes += total_bytes;
-	netdev->stats.tx_packets += total_packets;
+	u64_stats_update_end(&tx_ring->syncp);
 
 	return count < tx_ring->work_limit;
 }
@@ -597,10 +596,10 @@ next_desc:
 	if (cleaned_count)
 		ixgbevf_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
 
+	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
-	adapter->netdev->stats.rx_bytes += total_rx_bytes;
-	adapter->netdev->stats.rx_packets += total_rx_packets;
+	u64_stats_update_end(&rx_ring->syncp);
 
 	return cleaned;
 }
@@ -2260,10 +2259,6 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 				adapter->stats.vfgotc);
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFMPRC, adapter->stats.last_vfmprc,
 				adapter->stats.vfmprc);
-
-	/* Fill out the OS statistics structure */
-	adapter->netdev->stats.multicast = adapter->stats.vfmprc -
-		adapter->stats.base_vfmprc;
 }
 
 /**
@@ -3220,11 +3215,50 @@ static void ixgbevf_shutdown(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
+static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
+						struct rtnl_link_stats64 *stats)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	unsigned int start;
+	u64 bytes, packets;
+	const struct ixgbevf_ring *ring;
+	int i;
+
+	ixgbevf_update_stats(adapter);
+
+	stats->multicast = adapter->stats.vfmprc - adapter->stats.base_vfmprc;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		ring = &adapter->rx_ring[i];
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			bytes = ring->total_bytes;
+			packets = ring->total_packets;
+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		stats->rx_bytes += bytes;
+		stats->rx_packets += packets;
+	}
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		ring = &adapter->tx_ring[i];
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			bytes = ring->total_bytes;
+			packets = ring->total_packets;
+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		stats->tx_bytes += bytes;
+		stats->tx_packets += packets;
+	}
+
+	return stats;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbevf_open,
 	.ndo_stop		= ixgbevf_close,
 	.ndo_start_xmit		= ixgbevf_xmit_frame,
 	.ndo_set_rx_mode	= ixgbevf_set_rx_mode,
+	.ndo_get_stats64	= ixgbevf_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbevf_set_mac,
 	.ndo_change_mtu		= ixgbevf_change_mtu,
-- 
1.7.6
