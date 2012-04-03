From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] ixgbe: driver fix for link flap
Date: Tue,  3 Apr 2012 15:28:57 -0700
Message-ID: <1333492139-32697-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1333492139-32697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Multanen, Eric W" <eric.w.multanen@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28712 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775Ab2DCW3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:29:03 -0400
In-Reply-To: <1333492139-32697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Multanen, Eric W" <eric.w.multanen@intel.com>

Fix up code so that changes in DCB settings
are detected only when ixgbe_dcbnl_set_all is called.
Previously, a series of 'change' commands followed by
a call to ixgbe_dcbnl_set_all() would always be handled
as a HW change - even if the net change was zero.
This patch checks for this case of no actual change and
skips going through the HW set process.

Without this fix, the link could reset and result in
a link flap.

The core change in this patch is to check for changes
in the ixgbe_copy_dcb_cfg() routine - and return
a bitmask of detected changes.  The other
places where changes were detected previously can be removed.

Signed-off-by: Eric Multanen <eric.w.multanen@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |  164 +++++++++++------------
 1 files changed, 80 insertions(+), 84 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index dde65f9..652e4b0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -44,62 +44,94 @@
 #define DCB_NO_HW_CHG   1  /* DCB configuration did not change */
 #define DCB_HW_CHG      2  /* DCB configuration changed, no reset */
 
-int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
-                       struct ixgbe_dcb_config *dst_dcb_cfg, int tc_max)
+int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *scfg,
+		       struct ixgbe_dcb_config *dcfg, int tc_max)
 {
-	struct tc_configuration *src_tc_cfg = NULL;
-	struct tc_configuration *dst_tc_cfg = NULL;
-	int i;
+	struct tc_configuration *src = NULL;
+	struct tc_configuration *dst = NULL;
+	int i, j;
+	int tx = DCB_TX_CONFIG;
+	int rx = DCB_RX_CONFIG;
+	int changes = 0;
 
-	if (!src_dcb_cfg || !dst_dcb_cfg)
-		return -EINVAL;
+	if (!scfg || !dcfg)
+		return changes;
 
 	for (i = DCB_PG_ATTR_TC_0; i < tc_max + DCB_PG_ATTR_TC_0; i++) {
-		src_tc_cfg = &src_dcb_cfg->tc_config[i - DCB_PG_ATTR_TC_0];
-		dst_tc_cfg = &dst_dcb_cfg->tc_config[i - DCB_PG_ATTR_TC_0];
+		src = &scfg->tc_config[i - DCB_PG_ATTR_TC_0];
+		dst = &dcfg->tc_config[i - DCB_PG_ATTR_TC_0];
 
-		dst_tc_cfg->path[DCB_TX_CONFIG].prio_type =
-				src_tc_cfg->path[DCB_TX_CONFIG].prio_type;
+		if (dst->path[tx].prio_type != src->path[tx].prio_type) {
+			dst->path[tx].prio_type = src->path[tx].prio_type;
+			changes |= BIT_PG_TX;
+		}
 
-		dst_tc_cfg->path[DCB_TX_CONFIG].bwg_id =
-				src_tc_cfg->path[DCB_TX_CONFIG].bwg_id;
+		if (dst->path[tx].bwg_id != src->path[tx].bwg_id) {
+			dst->path[tx].bwg_id = src->path[tx].bwg_id;
+			changes |= BIT_PG_TX;
+		}
 
-		dst_tc_cfg->path[DCB_TX_CONFIG].bwg_percent =
-				src_tc_cfg->path[DCB_TX_CONFIG].bwg_percent;
+		if (dst->path[tx].bwg_percent != src->path[tx].bwg_percent) {
+			dst->path[tx].bwg_percent = src->path[tx].bwg_percent;
+			changes |= BIT_PG_TX;
+		}
 
-		dst_tc_cfg->path[DCB_TX_CONFIG].up_to_tc_bitmap =
-				src_tc_cfg->path[DCB_TX_CONFIG].up_to_tc_bitmap;
+		if (dst->path[tx].up_to_tc_bitmap !=
+				src->path[tx].up_to_tc_bitmap) {
+			dst->path[tx].up_to_tc_bitmap =
+				src->path[tx].up_to_tc_bitmap;
+			changes |= (BIT_PG_TX | BIT_PFC | BIT_APP_UPCHG);
+		}
 
-		dst_tc_cfg->path[DCB_RX_CONFIG].prio_type =
-				src_tc_cfg->path[DCB_RX_CONFIG].prio_type;
+		if (dst->path[rx].prio_type != src->path[rx].prio_type) {
+			dst->path[rx].prio_type = src->path[rx].prio_type;
+			changes |= BIT_PG_RX;
+		}
 
-		dst_tc_cfg->path[DCB_RX_CONFIG].bwg_id =
-				src_tc_cfg->path[DCB_RX_CONFIG].bwg_id;
+		if (dst->path[rx].bwg_id != src->path[rx].bwg_id) {
+			dst->path[rx].bwg_id = src->path[rx].bwg_id;
+			changes |= BIT_PG_RX;
+		}
 
-		dst_tc_cfg->path[DCB_RX_CONFIG].bwg_percent =
-				src_tc_cfg->path[DCB_RX_CONFIG].bwg_percent;
+		if (dst->path[rx].bwg_percent != src->path[rx].bwg_percent) {
+			dst->path[rx].bwg_percent = src->path[rx].bwg_percent;
+			changes |= BIT_PG_RX;
+		}
 
-		dst_tc_cfg->path[DCB_RX_CONFIG].up_to_tc_bitmap =
-				src_tc_cfg->path[DCB_RX_CONFIG].up_to_tc_bitmap;
+		if (dst->path[rx].up_to_tc_bitmap !=
+				src->path[rx].up_to_tc_bitmap) {
+			dst->path[rx].up_to_tc_bitmap =
+				src->path[rx].up_to_tc_bitmap;
+			changes |= (BIT_PG_RX | BIT_PFC | BIT_APP_UPCHG);
+		}
 	}
 
 	for (i = DCB_PG_ATTR_BW_ID_0; i < DCB_PG_ATTR_BW_ID_MAX; i++) {
-		dst_dcb_cfg->bw_percentage[DCB_TX_CONFIG]
-			[i-DCB_PG_ATTR_BW_ID_0] = src_dcb_cfg->bw_percentage
-				[DCB_TX_CONFIG][i-DCB_PG_ATTR_BW_ID_0];
-		dst_dcb_cfg->bw_percentage[DCB_RX_CONFIG]
-			[i-DCB_PG_ATTR_BW_ID_0] = src_dcb_cfg->bw_percentage
-				[DCB_RX_CONFIG][i-DCB_PG_ATTR_BW_ID_0];
+		j = i - DCB_PG_ATTR_BW_ID_0;
+		if (dcfg->bw_percentage[tx][j] != scfg->bw_percentage[tx][j]) {
+			dcfg->bw_percentage[tx][j] = scfg->bw_percentage[tx][j];
+			changes |= BIT_PG_TX;
+		}
+		if (dcfg->bw_percentage[rx][j] != scfg->bw_percentage[rx][j]) {
+			dcfg->bw_percentage[rx][j] = scfg->bw_percentage[rx][j];
+			changes |= BIT_PG_RX;
+		}
 	}
 
 	for (i = DCB_PFC_UP_ATTR_0; i < DCB_PFC_UP_ATTR_MAX; i++) {
-		dst_dcb_cfg->tc_config[i - DCB_PFC_UP_ATTR_0].dcb_pfc =
-			src_dcb_cfg->tc_config[i - DCB_PFC_UP_ATTR_0].dcb_pfc;
+		j = i - DCB_PFC_UP_ATTR_0;
+		if (dcfg->tc_config[j].dcb_pfc != scfg->tc_config[j].dcb_pfc) {
+			dcfg->tc_config[j].dcb_pfc = scfg->tc_config[j].dcb_pfc;
+			changes |= BIT_PFC;
+		}
 	}
 
-	dst_dcb_cfg->pfc_mode_enable = src_dcb_cfg->pfc_mode_enable;
+	if (dcfg->pfc_mode_enable != scfg->pfc_mode_enable) {
+		dcfg->pfc_mode_enable = scfg->pfc_mode_enable;
+		changes |= BIT_PFC;
+	}
 
-	return 0;
+	return changes;
 }
 
 static u8 ixgbe_dcbnl_get_state(struct net_device *netdev)
@@ -179,20 +211,6 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_tx(struct net_device *netdev, int tc,
 	if (up_map != DCB_ATTR_VALUE_UNDEFINED)
 		adapter->temp_dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap =
 			up_map;
-
-	if ((adapter->temp_dcb_cfg.tc_config[tc].path[0].prio_type !=
-	     adapter->dcb_cfg.tc_config[tc].path[0].prio_type) ||
-	    (adapter->temp_dcb_cfg.tc_config[tc].path[0].bwg_id !=
-	     adapter->dcb_cfg.tc_config[tc].path[0].bwg_id) ||
-	    (adapter->temp_dcb_cfg.tc_config[tc].path[0].bwg_percent !=
-	     adapter->dcb_cfg.tc_config[tc].path[0].bwg_percent) ||
-	    (adapter->temp_dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap))
-		adapter->dcb_set_bitmap |= BIT_PG_TX;
-
-	if (adapter->temp_dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap)
-		adapter->dcb_set_bitmap |= BIT_PFC | BIT_APP_UPCHG;
 }
 
 static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
@@ -201,10 +219,6 @@ static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	adapter->temp_dcb_cfg.bw_percentage[0][bwg_id] = bw_pct;
-
-	if (adapter->temp_dcb_cfg.bw_percentage[0][bwg_id] !=
-	    adapter->dcb_cfg.bw_percentage[0][bwg_id])
-		adapter->dcb_set_bitmap |= BIT_PG_TX;
 }
 
 static void ixgbe_dcbnl_set_pg_tc_cfg_rx(struct net_device *netdev, int tc,
@@ -223,20 +237,6 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_rx(struct net_device *netdev, int tc,
 	if (up_map != DCB_ATTR_VALUE_UNDEFINED)
 		adapter->temp_dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap =
 			up_map;
-
-	if ((adapter->temp_dcb_cfg.tc_config[tc].path[1].prio_type !=
-	     adapter->dcb_cfg.tc_config[tc].path[1].prio_type) ||
-	    (adapter->temp_dcb_cfg.tc_config[tc].path[1].bwg_id !=
-	     adapter->dcb_cfg.tc_config[tc].path[1].bwg_id) ||
-	    (adapter->temp_dcb_cfg.tc_config[tc].path[1].bwg_percent !=
-	     adapter->dcb_cfg.tc_config[tc].path[1].bwg_percent) ||
-	    (adapter->temp_dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap))
-		adapter->dcb_set_bitmap |= BIT_PG_RX;
-
-	if (adapter->temp_dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap)
-		adapter->dcb_set_bitmap |= BIT_PFC;
 }
 
 static void ixgbe_dcbnl_set_pg_bwg_cfg_rx(struct net_device *netdev, int bwg_id,
@@ -245,10 +245,6 @@ static void ixgbe_dcbnl_set_pg_bwg_cfg_rx(struct net_device *netdev, int bwg_id,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	adapter->temp_dcb_cfg.bw_percentage[1][bwg_id] = bw_pct;
-
-	if (adapter->temp_dcb_cfg.bw_percentage[1][bwg_id] !=
-	    adapter->dcb_cfg.bw_percentage[1][bwg_id])
-		adapter->dcb_set_bitmap |= BIT_PG_RX;
 }
 
 static void ixgbe_dcbnl_get_pg_tc_cfg_tx(struct net_device *netdev, int tc,
@@ -298,10 +294,8 @@ static void ixgbe_dcbnl_set_pfc_cfg(struct net_device *netdev, int priority,
 
 	adapter->temp_dcb_cfg.tc_config[priority].dcb_pfc = setting;
 	if (adapter->temp_dcb_cfg.tc_config[priority].dcb_pfc !=
-	    adapter->dcb_cfg.tc_config[priority].dcb_pfc) {
-		adapter->dcb_set_bitmap |= BIT_PFC;
+	    adapter->dcb_cfg.tc_config[priority].dcb_pfc)
 		adapter->temp_dcb_cfg.pfc_mode_enable = true;
-	}
 }
 
 static void ixgbe_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
@@ -336,7 +330,8 @@ static void ixgbe_dcbnl_devreset(struct net_device *dev)
 static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int ret, i;
+	int ret = DCB_NO_HW_CHG;
+	int i;
 #ifdef IXGBE_FCOE
 	struct dcb_app app = {
 			      .selector = DCB_APP_IDTYPE_ETHTYPE,
@@ -355,12 +350,13 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 
 	/* Fail command if not in CEE mode */
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
-		return 1;
+		return ret;
 
-	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
-				 MAX_TRAFFIC_CLASS);
-	if (ret)
-		return DCB_NO_HW_CHG;
+	adapter->dcb_set_bitmap |= ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg,
+						      &adapter->dcb_cfg,
+						      MAX_TRAFFIC_CLASS);
+	if (!adapter->dcb_set_bitmap)
+		return ret;
 
 	if (adapter->dcb_cfg.pfc_mode_enable) {
 		switch (adapter->hw.mac.type) {
@@ -420,6 +416,8 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 
 		for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
 			netdev_set_prio_tc_map(netdev, i, prio_tc[i]);
+
+		ret = DCB_HW_CHG_RST;
 	}
 
 	if (adapter->dcb_set_bitmap & BIT_PFC) {
@@ -430,7 +428,8 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 				     DCB_TX_CONFIG, prio_tc);
 		ixgbe_dcb_unpack_pfc(&adapter->dcb_cfg, &pfc_en);
 		ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc_en, prio_tc);
-		ret = DCB_HW_CHG;
+		if (ret != DCB_HW_CHG_RST)
+			ret = DCB_HW_CHG;
 	}
 
 	if (adapter->dcb_cfg.pfc_mode_enable)
@@ -531,9 +530,6 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	adapter->temp_dcb_cfg.pfc_mode_enable = state;
-	if (adapter->temp_dcb_cfg.pfc_mode_enable !=
-		adapter->dcb_cfg.pfc_mode_enable)
-		adapter->dcb_set_bitmap |= BIT_PFC;
 }
 
 /**
-- 
1.7.7.6
