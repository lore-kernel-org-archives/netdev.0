From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: Make better use of memory allocations in one-buffer mode w/ RSC
Date: Fri, 16 Sep 2011 19:15:49 -0700
Message-ID: <1316225752-1709-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42810 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215Ab1IQCQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:16:00 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch improves the memory utilization with RSC when in one-buffer
mode.  This is accomplished by making the default buffer sizes match up
with the standard memory allocation sizes minus 1K for shared info and
padding overhead.  By doing this CPU utilization when doing large receives
can be reduced by as much as 8%.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   11 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   41 ++++++++++++++-------
 3 files changed, 35 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 209286c..2c9fdf8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -72,10 +72,13 @@
 
 /* Supported Rx Buffer Sizes */
 #define IXGBE_RXBUFFER_512   512    /* Used for packet split */
-#define IXGBE_RXBUFFER_2048  2048
-#define IXGBE_RXBUFFER_4096  4096
-#define IXGBE_RXBUFFER_8192  8192
-#define IXGBE_MAX_RXBUFFER   16384  /* largest size for a single descriptor */
+#define IXGBE_RXBUFFER_2K   2048
+#define IXGBE_RXBUFFER_3K   3072
+#define IXGBE_RXBUFFER_4K   4096
+#define IXGBE_RXBUFFER_7K   7168
+#define IXGBE_RXBUFFER_8K   8192
+#define IXGBE_RXBUFFER_15K  15360
+#define IXGBE_MAX_RXBUFFER  16384  /* largest size for a single descriptor */
 
 /*
  * NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN mans we
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index b8410bc..46f4ecf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1539,7 +1539,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	rx_ring->dev = &adapter->pdev->dev;
 	rx_ring->netdev = adapter->netdev;
 	rx_ring->reg_idx = adapter->rx_ring[0]->reg_idx;
-	rx_ring->rx_buf_len = IXGBE_RXBUFFER_2048;
+	rx_ring->rx_buf_len = IXGBE_RXBUFFER_2K;
 	rx_ring->numa_node = adapter->node;
 
 	err = ixgbe_setup_rx_resources(rx_ring);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ce59dc6..a4103ef 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -499,7 +499,7 @@ rx_ring_summary:
 					   rx_ring->rx_buf_len, true);
 
 					if (rx_ring->rx_buf_len
-						< IXGBE_RXBUFFER_2048)
+						< IXGBE_RXBUFFER_2K)
 						print_hex_dump(KERN_INFO, "",
 						  DUMP_PREFIX_ADDRESS, 16, 1,
 						  phys_to_virt(
@@ -2644,9 +2644,9 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
 #endif
 	} else {
-		if (rx_buf_len < IXGBE_RXBUFFER_4096)
+		if (rx_buf_len < IXGBE_RXBUFFER_4K)
 			rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
-		else if (rx_buf_len < IXGBE_RXBUFFER_8192)
+		else if (rx_buf_len < IXGBE_RXBUFFER_8K)
 			rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
 		else
 			rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
@@ -2879,17 +2879,6 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82599EB)
 		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
 
-	/* Set the RX buffer length according to the mode */
-	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-		rx_buf_len = IXGBE_RX_HDR_SIZE;
-	} else {
-		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
-		    (netdev->mtu <= ETH_DATA_LEN))
-			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
-		else
-			rx_buf_len = ALIGN(max_frame + VLAN_HLEN, 1024);
-	}
-
 #ifdef IXGBE_FCOE
 	/* adjust max frame to be able to do baby jumbo for FCoE */
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
@@ -2905,6 +2894,30 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_MHADD, mhadd);
 	}
 
+	/* MHADD will allow an extra 4 bytes past for vlan tagged frames */
+	max_frame += VLAN_HLEN;
+
+	/* Set the RX buffer length according to the mode */
+	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+		rx_buf_len = IXGBE_RX_HDR_SIZE;
+	} else {
+		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
+		    (netdev->mtu <= ETH_DATA_LEN))
+			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
+		/*
+		 * Make best use of allocation by using all but 1K of a
+		 * power of 2 allocation that will be used for skb->head.
+		 */
+		else if (max_frame <= IXGBE_RXBUFFER_3K)
+			rx_buf_len = IXGBE_RXBUFFER_3K;
+		else if (max_frame <= IXGBE_RXBUFFER_7K)
+			rx_buf_len = IXGBE_RXBUFFER_7K;
+		else if (max_frame <= IXGBE_RXBUFFER_15K)
+			rx_buf_len = IXGBE_RXBUFFER_15K;
+		else
+			rx_buf_len = IXGBE_MAX_RXBUFFER;
+	}
+
 	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
 	/* set jumbo enable since MHADD.MFS is keeping size locked at max_frame */
 	hlreg0 |= IXGBE_HLREG0_JUMBOEN;
-- 
1.7.6
