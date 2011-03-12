From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 14/21] ixgbe: IEEE 802.1Qaz, implement priority assignment table
Date: Sat, 12 Mar 2011 04:20:21 -0800
Message-ID: <1299932428-3114-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918Ab1CLMUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:55 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This patch adds support to use the priority assignment
table in the ieee_ets structure to map priorities to
traffic classes. Previously ixgbe only supported a
1:1 mapping. Now we can enable and disable hardware
DCB support when multiple traffic classes are actually
being used. This allows the default case all priorities
mapped to traffic class 0 to work in normal hardware
mode and utilize the full packet buffer.

This patch does not address putting the hardware in
4TC mode so packet buffer space may be underutilized
in this case. A follow up patch can address this
optimization. But at least we have the hooks to do
this now.

Also CEE will behave as it always has and map priorities
1:1 with traffic classes.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb.c       |   13 ++++++++-----
 drivers/net/ixgbe/ixgbe_dcb.h       |    4 ++--
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   17 ++++++++++-------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    9 ++++++---
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |   12 ++++++++++--
 5 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index e2e7a29..e7b551a 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -246,6 +246,8 @@ s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw,
 	u8 bwgid[MAX_TRAFFIC_CLASS];
 	u16 refill[MAX_TRAFFIC_CLASS];
 	u16 max[MAX_TRAFFIC_CLASS];
+	/* CEE does not define a priority to tc mapping so map 1:1 */
+	u8 prio_tc[MAX_TRAFFIC_CLASS] = {0, 1, 2, 3, 4, 5, 6, 7};
 
 	/* Unpack CEE standard containers */
 	ixgbe_dcb_unpack_pfc(dcb_config, &pfc_en);
@@ -264,7 +266,7 @@ s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw,
 	case ixgbe_mac_X540:
 		ret = ixgbe_dcb_hw_config_82599(hw, dcb_config->rx_pba_cfg,
 						pfc_en, refill, max, bwgid,
-						ptype);
+						ptype, prio_tc);
 		break;
 	default:
 		break;
@@ -292,7 +294,8 @@ s32 ixgbe_dcb_hw_pfc_config(struct ixgbe_hw *hw, u8 pfc_en)
 }
 
 s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
-			    u16 *refill, u16 *max, u8 *bwg_id, u8 *prio_type)
+			    u16 *refill, u16 *max, u8 *bwg_id,
+			    u8 *prio_type, u8 *prio_tc)
 {
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
@@ -306,11 +309,11 @@ s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		ixgbe_dcb_config_rx_arbiter_82599(hw, refill, max,
-						  bwg_id, prio_type);
+						  bwg_id, prio_type, prio_tc);
 		ixgbe_dcb_config_tx_desc_arbiter_82599(hw, refill, max,
 						       bwg_id, prio_type);
-		ixgbe_dcb_config_tx_data_arbiter_82599(hw, refill, max,
-						       bwg_id, prio_type);
+		ixgbe_dcb_config_tx_data_arbiter_82599(hw, refill, max, bwg_id,
+						       prio_type, prio_tc);
 		break;
 	default:
 		break;
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 515bc27..944838f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -159,8 +159,8 @@ s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *,
 				   struct ixgbe_dcb_config *, int, u8);
 
 /* DCB hw initialization */
-s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
-			    u16 *refill, u16 *max, u8 *bwg_id, u8 *prio_type);
+s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw, u16 *refill, u16 *max,
+			    u8 *bwg_id, u8 *prio_type, u8 *tc_prio);
 s32 ixgbe_dcb_hw_pfc_config(struct ixgbe_hw *hw, u8 pfc_en);
 s32 ixgbe_dcb_hw_config(struct ixgbe_hw *, struct ixgbe_dcb_config *);
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index beaa1c1..0a482bb 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -85,7 +85,8 @@ s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
 				      u16 *refill,
 				      u16 *max,
 				      u8 *bwg_id,
-				      u8 *prio_type)
+				      u8 *prio_type,
+				      u8 *prio_tc)
 {
 	u32    reg           = 0;
 	u32    credit_refill = 0;
@@ -102,7 +103,7 @@ s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
 	/* Map all traffic classes to their UP, 1 to 1 */
 	reg = 0;
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-		reg |= (i << (i * IXGBE_RTRUP2TC_UP_SHIFT));
+		reg |= (prio_tc[i] << (i * IXGBE_RTRUP2TC_UP_SHIFT));
 	IXGBE_WRITE_REG(hw, IXGBE_RTRUP2TC, reg);
 
 	/* Configure traffic class credits and priority */
@@ -194,7 +195,8 @@ s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
 					   u16 *refill,
 					   u16 *max,
 					   u8 *bwg_id,
-					   u8 *prio_type)
+					   u8 *prio_type,
+					   u8 *prio_tc)
 {
 	u32 reg;
 	u8 i;
@@ -211,7 +213,7 @@ s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
 	/* Map all traffic classes to their UP, 1 to 1 */
 	reg = 0;
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-		reg |= (i << (i * IXGBE_RTTUP2TC_UP_SHIFT));
+		reg |= (prio_tc[i] << (i * IXGBE_RTTUP2TC_UP_SHIFT));
 	IXGBE_WRITE_REG(hw, IXGBE_RTTUP2TC, reg);
 
 	/* Configure traffic class credits and priority */
@@ -424,15 +426,16 @@ static s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
  */
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
 			      u8 rx_pba, u8 pfc_en, u16 *refill,
-			      u16 *max, u8 *bwg_id, u8 *prio_type)
+			      u16 *max, u8 *bwg_id, u8 *prio_type, u8 *prio_tc)
 {
 	ixgbe_dcb_config_packet_buffers_82599(hw, rx_pba);
 	ixgbe_dcb_config_82599(hw);
-	ixgbe_dcb_config_rx_arbiter_82599(hw, refill, max, bwg_id, prio_type);
+	ixgbe_dcb_config_rx_arbiter_82599(hw, refill, max, bwg_id,
+					  prio_type, prio_tc);
 	ixgbe_dcb_config_tx_desc_arbiter_82599(hw, refill, max,
 					       bwg_id, prio_type);
 	ixgbe_dcb_config_tx_data_arbiter_82599(hw, refill, max,
-					       bwg_id, prio_type);
+					       bwg_id, prio_type, prio_tc);
 	ixgbe_dcb_config_pfc_82599(hw, pfc_en);
 	ixgbe_dcb_config_tc_stats_82599(hw);
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 0b39ab4..148fd8b 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -109,7 +109,8 @@ s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
 					u16 *refill,
 					u16 *max,
 					u8 *bwg_id,
-					u8 *prio_type);
+					u8 *prio_type,
+					u8 *prio_tc);
 
 s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
 						u16 *refill,
@@ -121,10 +122,12 @@ s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
 						u16 *refill,
 						u16 *max,
 						u8 *bwg_id,
-						u8 *prio_type);
+						u8 *prio_type,
+						u8 *prio_tc);
 
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
 			      u8 rx_pba, u8 pfc_en, u16 *refill,
-			      u16 *max, u8 *bwg_id, u8 *prio_type);
+			      u16 *max, u8 *bwg_id, u8 *prio_type,
+			      u8 *prio_tc);
 
 #endif /* _DCB_82599_CONFIG_H */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 8abef8d..fec4c72 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -416,6 +416,8 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	if (adapter->dcb_set_bitmap & (BIT_PG_TX|BIT_PG_RX)) {
 		u16 refill[MAX_TRAFFIC_CLASS], max[MAX_TRAFFIC_CLASS];
 		u8 bwg_id[MAX_TRAFFIC_CLASS], prio_type[MAX_TRAFFIC_CLASS];
+		/* Priority to TC mapping in CEE case default to 1:1 */
+		u8 prio_tc[MAX_TRAFFIC_CLASS] = {0, 1, 2, 3, 4, 5, 6, 7};
 		int max_frame = adapter->netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 
 #ifdef CONFIG_FCOE
@@ -437,7 +439,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 				      DCB_TX_CONFIG, prio_type);
 
 		ixgbe_dcb_hw_ets_config(&adapter->hw, refill, max,
-					bwg_id, prio_type);
+					bwg_id, prio_type, prio_tc);
 	}
 
 	if (adapter->dcb_cfg.pfc_mode_enable)
@@ -645,6 +647,7 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 	__u8 prio_type[IEEE_8021QAZ_MAX_TCS];
 	int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i, err;
+	__u64 *p = (__u64 *) ets->prio_tc;
 	/* naively give each TC a bwg to map onto CEE hardware */
 	__u8 bwg_id[IEEE_8021QAZ_MAX_TCS] = {0, 1, 2, 3, 4, 5, 6, 7};
 
@@ -679,9 +682,14 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 		}
 	}
 
+	if (*p)
+		ixgbe_dcbnl_set_state(dev, 1);
+	else
+		ixgbe_dcbnl_set_state(dev, 0);
+
 	ixgbe_ieee_credits(ets->tc_tx_bw, refill, max, max_frame);
 	err = ixgbe_dcb_hw_ets_config(&adapter->hw, refill, max,
-				      bwg_id, prio_type);
+				      bwg_id, prio_type, ets->prio_tc);
 	return err;
 }
 
-- 
1.7.4

