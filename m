From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 09/15] ixgbe: DCB, do not reset on CEE pg changes
Date: Fri, 11 Feb 2011 09:20:56 -0800
Message-ID: <1297444862-32091-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46175 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757851Ab1BKRVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:23 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The 82599 and 82598 devices do not require hardware resets to
configure CEE pg settings. This patch changes DCB configuration
to set the CEE pg values directly from the dcbnl ops routine.

This reduces the number of resets seen on the wire and allows
LLDP to reach a steady state faster.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb.h    |    4 +++
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   48 +++++++++++++++++++++++++++----------
 2 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 4e4a641..e593511 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -148,6 +148,10 @@ struct ixgbe_dcb_config {
 
 /* DCB driver APIs */
 void ixgbe_dcb_unpack_pfc(struct ixgbe_dcb_config *cfg, u8 *pfc_en);
+void ixgbe_dcb_unpack_refill(struct ixgbe_dcb_config *, int, u16 *);
+void ixgbe_dcb_unpack_max(struct ixgbe_dcb_config *, u16 *);
+void ixgbe_dcb_unpack_bwgid(struct ixgbe_dcb_config *, int, u8 *);
+void ixgbe_dcb_unpack_prio(struct ixgbe_dcb_config *, int, u8 *);
 
 /* DCB credits calculation */
 s32 ixgbe_ieee_credits(__u8 *bw, __u16 *refill, __u16 *max, int max_frame);
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index e75a3c9..b3a8d24 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -225,10 +225,8 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_tx(struct net_device *netdev, int tc,
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[0].bwg_percent !=
 	     adapter->dcb_cfg.tc_config[tc].path[0].bwg_percent) ||
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap)) {
+	     adapter->dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap))
 		adapter->dcb_set_bitmap |= BIT_PG_TX;
-		adapter->dcb_set_bitmap |= BIT_RESETLINK;
-	}
 }
 
 static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
@@ -239,10 +237,8 @@ static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
 	adapter->temp_dcb_cfg.bw_percentage[0][bwg_id] = bw_pct;
 
 	if (adapter->temp_dcb_cfg.bw_percentage[0][bwg_id] !=
-	    adapter->dcb_cfg.bw_percentage[0][bwg_id]) {
+	    adapter->dcb_cfg.bw_percentage[0][bwg_id])
 		adapter->dcb_set_bitmap |= BIT_PG_TX;
-		adapter->dcb_set_bitmap |= BIT_RESETLINK;
-	}
 }
 
 static void ixgbe_dcbnl_set_pg_tc_cfg_rx(struct net_device *netdev, int tc,
@@ -269,10 +265,8 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_rx(struct net_device *netdev, int tc,
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[1].bwg_percent !=
 	     adapter->dcb_cfg.tc_config[tc].path[1].bwg_percent) ||
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap)) {
+	     adapter->dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap))
 		adapter->dcb_set_bitmap |= BIT_PG_RX;
-		adapter->dcb_set_bitmap |= BIT_RESETLINK;
-	}
 }
 
 static void ixgbe_dcbnl_set_pg_bwg_cfg_rx(struct net_device *netdev, int bwg_id,
@@ -283,10 +277,8 @@ static void ixgbe_dcbnl_set_pg_bwg_cfg_rx(struct net_device *netdev, int bwg_id,
 	adapter->temp_dcb_cfg.bw_percentage[1][bwg_id] = bw_pct;
 
 	if (adapter->temp_dcb_cfg.bw_percentage[1][bwg_id] !=
-	    adapter->dcb_cfg.bw_percentage[1][bwg_id]) {
+	    adapter->dcb_cfg.bw_percentage[1][bwg_id])
 		adapter->dcb_set_bitmap |= BIT_PG_RX;
-		adapter->dcb_set_bitmap |= BIT_RESETLINK;
-	}
 }
 
 static void ixgbe_dcbnl_get_pg_tc_cfg_tx(struct net_device *netdev, int tc,
@@ -421,7 +413,9 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 				ixgbe_up(adapter);
 		}
 		ret = DCB_HW_CHG_RST;
-	} else if (adapter->dcb_set_bitmap & BIT_PFC) {
+	}
+
+	if (adapter->dcb_set_bitmap & BIT_PFC) {
 		u8 pfc_en;
 		ixgbe_dcb_unpack_pfc(&adapter->dcb_cfg, &pfc_en);
 
@@ -431,6 +425,34 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 			ixgbe_dcb_config_pfc_82599(&adapter->hw, pfc_en);
 		ret = DCB_HW_CHG;
 	}
+
+	if (adapter->dcb_set_bitmap & (BIT_PG_TX|BIT_PG_RX)) {
+		u16 refill[MAX_TRAFFIC_CLASS], max[MAX_TRAFFIC_CLASS];
+		u8 bwg_id[MAX_TRAFFIC_CLASS], prio_type[MAX_TRAFFIC_CLASS];
+		int max_frame = adapter->netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+
+#ifdef CONFIG_FCOE
+		if (adapter->netdev->features & NETIF_F_FCOE_MTU)
+			max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
+#endif
+
+		ixgbe_dcb_calculate_tc_credits(&adapter->hw, &adapter->dcb_cfg,
+					       max_frame, DCB_TX_CONFIG);
+		ixgbe_dcb_calculate_tc_credits(&adapter->hw, &adapter->dcb_cfg,
+					       max_frame, DCB_RX_CONFIG);
+
+		ixgbe_dcb_unpack_refill(&adapter->dcb_cfg,
+					DCB_TX_CONFIG, refill);
+		ixgbe_dcb_unpack_max(&adapter->dcb_cfg, max);
+		ixgbe_dcb_unpack_bwgid(&adapter->dcb_cfg,
+				       DCB_TX_CONFIG, bwg_id);
+		ixgbe_dcb_unpack_prio(&adapter->dcb_cfg,
+				      DCB_TX_CONFIG, prio_type);
+
+		ixgbe_dcb_hw_ets_config(&adapter->hw, refill, max,
+					bwg_id, prio_type);
+	}
+
 	if (adapter->dcb_cfg.pfc_mode_enable)
 		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
 
-- 
1.7.4

