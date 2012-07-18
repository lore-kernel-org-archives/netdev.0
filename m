From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] ixgbe: Update the logic for ixgbe_cache_ring_dcb and DCB RSS configuration
Date: Tue, 17 Jul 2012 19:20:43 -0700
Message-ID: <1342578045-17778-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099Ab2GRCUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:20:51 -0400
In-Reply-To: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change cleans up some of the logic in an attempt to try and simplify
things for how we are configuring DCB w/ RSS.

In this patch I basically did 3 things.  I updated the logic for getting
the first register index.  I applied the fact that all TCs get the same
number of queues to simplify the looping logic in caching the DCB ring
register.  Finally I updated how we configure the RQTC register to match
the fact that all TCs are assigned the same number of queues.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   80 ++++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   12 ++--
 2 files changed, 42 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index c03d771..4c3822f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -42,42 +42,37 @@ static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
-		*tx = tc << 2;
-		*rx = tc << 3;
+		/* TxQs/TC: 4	RxQs/TC: 8 */
+		*tx = tc << 2; /* 0, 4,  8, 12, 16, 20, 24, 28 */
+		*rx = tc << 3; /* 0, 8, 16, 24, 32, 40, 48, 56 */
 		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		if (num_tcs > 4) {
-			if (tc < 3) {
-				*tx = tc << 5;
-				*rx = tc << 4;
-			} else if (tc <  5) {
-				*tx = ((tc + 2) << 4);
-				*rx = tc << 4;
-			} else if (tc < num_tcs) {
-				*tx = ((tc + 8) << 3);
-				*rx = tc << 4;
-			}
+			/*
+			 * TCs    : TC0/1 TC2/3 TC4-7
+			 * TxQs/TC:    32    16     8
+			 * RxQs/TC:    16    16    16
+			 */
+			*rx = tc << 4;
+			if (tc < 3)
+				*tx = tc << 5;		/*   0,  32,  64 */
+			else if (tc < 5)
+				*tx = (tc + 2) << 4;	/*  80,  96 */
+			else
+				*tx = (tc + 8) << 3;	/* 104, 112, 120 */
 		} else {
-			*rx =  tc << 5;
-			switch (tc) {
-			case 0:
-				*tx =  0;
-				break;
-			case 1:
-				*tx = 64;
-				break;
-			case 2:
-				*tx = 96;
-				break;
-			case 3:
-				*tx = 112;
-				break;
-			default:
-				break;
-			}
+			/*
+			 * TCs    : TC0 TC1 TC2/3
+			 * TxQs/TC:  64  32    16
+			 * RxQs/TC:  32  32    32
+			 */
+			*rx = tc << 5;
+			if (tc < 2)
+				*tx = tc << 6;		/*  0,  64 */
+			else
+				*tx = (tc + 4) << 4;	/* 96, 112 */
 		}
-		break;
 	default:
 		break;
 	}
@@ -90,25 +85,26 @@ static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
  * Cache the descriptor ring offsets for DCB to the assigned rings.
  *
  **/
-static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
+static bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 {
 	struct net_device *dev = adapter->netdev;
-	int i, j, k;
+	unsigned int tx_idx, rx_idx;
+	int tc, offset, rss_i, i;
 	u8 num_tcs = netdev_get_num_tc(dev);
 
-	if (!num_tcs)
+	/* verify we have DCB queueing enabled before proceeding */
+	if (num_tcs <= 1)
 		return false;
 
-	for (i = 0, k = 0; i < num_tcs; i++) {
-		unsigned int tx_s, rx_s;
-		u16 count = dev->tc_to_txq[i].count;
+	rss_i = adapter->ring_feature[RING_F_RSS].indices;
 
-		ixgbe_get_first_reg_idx(adapter, i, &tx_s, &rx_s);
-		for (j = 0; j < count; j++, k++) {
-			adapter->tx_ring[k]->reg_idx = tx_s + j;
-			adapter->rx_ring[k]->reg_idx = rx_s + j;
-			adapter->tx_ring[k]->dcb_tc = i;
-			adapter->rx_ring[k]->dcb_tc = i;
+	for (tc = 0, offset = 0; tc < num_tcs; tc++, offset += rss_i) {
+		ixgbe_get_first_reg_idx(adapter, tc, &tx_idx, &rx_idx);
+		for (i = 0; i < rss_i; i++, tx_idx++, rx_idx++) {
+			adapter->tx_ring[offset + i]->reg_idx = tx_idx;
+			adapter->rx_ring[offset + i]->reg_idx = rx_idx;
+			adapter->tx_ring[offset + i]->dcb_tc = tc;
+			adapter->rx_ring[offset + i]->dcb_tc = tc;
 		}
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7f2aa22..32c8cd6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3608,20 +3608,16 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 
 	/* Enable RSS Hash per TC */
 	if (hw->mac.type != ixgbe_mac_82598EB) {
-		int i;
-		u32 reg = 0;
-		u8 msb = 0;
-		u8 rss_i = adapter->netdev->tc_to_txq[0].count - 1;
+		u32 msb = 0;
+		u16 rss_i = adapter->ring_feature[RING_F_RSS].indices - 1;
 
 		while (rss_i) {
 			msb++;
 			rss_i >>= 1;
 		}
 
-		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-			reg |= msb << IXGBE_RQTC_SHIFT_TC(i);
-
-		IXGBE_WRITE_REG(hw, IXGBE_RQTC, reg);
+		/* write msb to all 8 TCs in one write */
+		IXGBE_WRITE_REG(hw, IXGBE_RQTC, msb * 0x11111111);
 	}
 }
 #endif
-- 
1.7.10.4
