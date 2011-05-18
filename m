From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next] bnx2x: add support for retrieving dcb peer
 configuration
Date: Wed, 18 May 2011 15:55:31 +0300
Message-ID: <1305723331.14458.13.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3218 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932798Ab1ERLCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 07:02:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to the bnx2x for retrieving dcb peer (remote)
configuration from the embedded DCBX stack.

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h     |    4 +
 drivers/net/bnx2x/bnx2x_dcb.c |  152 ++++++++++++++++++++++++++++++++++-------
 2 files changed, 131 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 16a76f0..668a578 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1242,6 +1242,10 @@ struct bnx2x {
 	/* DCBX Negotiation results */
 	struct dcbx_features			dcbx_local_feat;
 	u32					dcbx_error;
+#ifdef BCM_DCBNL
+	struct dcbx_features			dcbx_remote_feat;
+	u32					dcbx_remote_flags;
+#endif
 	u32					pending_max;
 };
 
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index 0f83092..410a49e 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -485,6 +485,36 @@ static void bnx2x_dcbx_update_ets_params(struct bnx2x *bp)
 	}
 }
 
+#ifdef BCM_DCBNL
+static int bnx2x_dcbx_read_shmem_remote_mib(struct bnx2x *bp)
+{
+	struct lldp_remote_mib remote_mib = {0};
+	u32 dcbx_remote_mib_offset = SHMEM2_RD(bp, dcbx_remote_mib_offset);
+	int rc;
+
+	DP(NETIF_MSG_LINK, "dcbx_remote_mib_offset 0x%x\n",
+	   dcbx_remote_mib_offset);
+
+	if (SHMEM_DCBX_REMOTE_MIB_NONE == dcbx_remote_mib_offset) {
+		BNX2X_ERR("FW doesn't support dcbx_remote_mib_offset\n");
+		return -EINVAL;
+	}
+
+	rc = bnx2x_dcbx_read_mib(bp, (u32 *)&remote_mib, dcbx_remote_mib_offset,
+				 DCBX_READ_REMOTE_MIB);
+
+	if (rc) {
+		BNX2X_ERR("Faild to read remote mib from FW\n");
+		return rc;
+	}
+
+	/* save features and flags */
+	bp->dcbx_remote_feat = remote_mib.features;
+	bp->dcbx_remote_flags = remote_mib.flags;
+	return 0;
+}
+#endif
+
 static int bnx2x_dcbx_read_shmem_neg_results(struct bnx2x *bp)
 {
 	struct lldp_local_mib local_mib = {0};
@@ -601,6 +631,10 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 			 * negotiation results
 			 */
 			bnx2x_dcbnl_update_applist(bp, true);
+
+			/* Read rmeote mib if dcbx is in the FW */
+			if (bnx2x_dcbx_read_shmem_remote_mib(bp))
+				return;
 #endif
 			/* Read neg results if dcbx is in the FW */
 			if (bnx2x_dcbx_read_shmem_neg_results(bp))
@@ -2031,7 +2065,6 @@ static u8 bnx2x_dcbnl_set_dcbx(struct net_device *netdev, u8 state)
 	return 0;
 }
 
-
 static u8 bnx2x_dcbnl_get_featcfg(struct net_device *netdev, int featid,
 				  u8 *flags)
 {
@@ -2111,31 +2144,100 @@ static u8 bnx2x_dcbnl_set_featcfg(struct net_device *netdev, int featid,
 	return rval;
 }
 
+static int bnx2x_peer_appinfo(struct net_device *netdev,
+			      struct dcb_peer_app_info *info, u16* app_count)
+{
+	int i;
+	struct bnx2x *bp = netdev_priv(netdev);
+
+	DP(NETIF_MSG_LINK, "APP-INFO\n");
+
+	info->willing = (bp->dcbx_remote_flags & DCBX_APP_REM_WILLING) ?: 0;
+	info->error = (bp->dcbx_remote_flags & DCBX_APP_RX_ERROR) ?: 0;
+	*app_count = 0;
+
+	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++)
+		if (bp->dcbx_remote_feat.app.app_pri_tbl[i].appBitfield &
+		    DCBX_APP_ENTRY_VALID)
+			(*app_count)++;
+	return 0;
+}
+
+static int bnx2x_peer_apptable(struct net_device *netdev,
+			       struct dcb_app *table)
+{
+	int i, j;
+	struct bnx2x *bp = netdev_priv(netdev);
+
+	DP(NETIF_MSG_LINK, "APP-TABLE\n");
+
+	for (i = 0, j = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
+		struct dcbx_app_priority_entry *ent =
+			&bp->dcbx_remote_feat.app.app_pri_tbl[i];
+
+		if (ent->appBitfield & DCBX_APP_ENTRY_VALID) {
+			table[j].selector = bnx2x_dcbx_dcbnl_app_idtype(ent);
+			table[j].priority = bnx2x_dcbx_dcbnl_app_up(ent);
+			table[j++].protocol = ent->app_id;
+		}
+	}
+	return 0;
+}
+
+static int bnx2x_cee_peer_getpg(struct net_device *netdev, struct cee_pg *pg)
+{
+	int i;
+	struct bnx2x *bp = netdev_priv(netdev);
+
+	pg->willing = (bp->dcbx_remote_flags & DCBX_ETS_REM_WILLING) ?: 0;
+
+	for (i = 0; i < CEE_DCBX_MAX_PGS; i++) {
+		pg->pg_bw[i] =
+			DCBX_PG_BW_GET(bp->dcbx_remote_feat.ets.pg_bw_tbl, i);
+		pg->prio_pg[i] =
+			DCBX_PRI_PG_GET(bp->dcbx_remote_feat.ets.pri_pg_tbl, i);
+	}
+	return 0;
+}
+
+static int bnx2x_cee_peer_getpfc(struct net_device *netdev,
+				 struct cee_pfc *pfc)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	pfc->tcs_supported = bp->dcbx_remote_feat.pfc.pfc_caps;
+	pfc->pfc_en = bp->dcbx_remote_feat.pfc.pri_en_bitmap;
+	return 0;
+}
+
 const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops = {
-	.getstate       = bnx2x_dcbnl_get_state,
-	.setstate       = bnx2x_dcbnl_set_state,
-	.getpermhwaddr  = bnx2x_dcbnl_get_perm_hw_addr,
-	.setpgtccfgtx   = bnx2x_dcbnl_set_pg_tccfg_tx,
-	.setpgbwgcfgtx  = bnx2x_dcbnl_set_pg_bwgcfg_tx,
-	.setpgtccfgrx   = bnx2x_dcbnl_set_pg_tccfg_rx,
-	.setpgbwgcfgrx  = bnx2x_dcbnl_set_pg_bwgcfg_rx,
-	.getpgtccfgtx   = bnx2x_dcbnl_get_pg_tccfg_tx,
-	.getpgbwgcfgtx  = bnx2x_dcbnl_get_pg_bwgcfg_tx,
-	.getpgtccfgrx   = bnx2x_dcbnl_get_pg_tccfg_rx,
-	.getpgbwgcfgrx  = bnx2x_dcbnl_get_pg_bwgcfg_rx,
-	.setpfccfg      = bnx2x_dcbnl_set_pfc_cfg,
-	.getpfccfg      = bnx2x_dcbnl_get_pfc_cfg,
-	.setall         = bnx2x_dcbnl_set_all,
-	.getcap         = bnx2x_dcbnl_get_cap,
-	.getnumtcs      = bnx2x_dcbnl_get_numtcs,
-	.setnumtcs      = bnx2x_dcbnl_set_numtcs,
-	.getpfcstate    = bnx2x_dcbnl_get_pfc_state,
-	.setpfcstate    = bnx2x_dcbnl_set_pfc_state,
-	.setapp         = bnx2x_dcbnl_set_app_up,
-	.getdcbx        = bnx2x_dcbnl_get_dcbx,
-	.setdcbx        = bnx2x_dcbnl_set_dcbx,
-	.getfeatcfg     = bnx2x_dcbnl_get_featcfg,
-	.setfeatcfg     = bnx2x_dcbnl_set_featcfg,
+	.getstate		= bnx2x_dcbnl_get_state,
+	.setstate		= bnx2x_dcbnl_set_state,
+	.getpermhwaddr		= bnx2x_dcbnl_get_perm_hw_addr,
+	.setpgtccfgtx		= bnx2x_dcbnl_set_pg_tccfg_tx,
+	.setpgbwgcfgtx		= bnx2x_dcbnl_set_pg_bwgcfg_tx,
+	.setpgtccfgrx		= bnx2x_dcbnl_set_pg_tccfg_rx,
+	.setpgbwgcfgrx		= bnx2x_dcbnl_set_pg_bwgcfg_rx,
+	.getpgtccfgtx		= bnx2x_dcbnl_get_pg_tccfg_tx,
+	.getpgbwgcfgtx		= bnx2x_dcbnl_get_pg_bwgcfg_tx,
+	.getpgtccfgrx		= bnx2x_dcbnl_get_pg_tccfg_rx,
+	.getpgbwgcfgrx		= bnx2x_dcbnl_get_pg_bwgcfg_rx,
+	.setpfccfg		= bnx2x_dcbnl_set_pfc_cfg,
+	.getpfccfg		= bnx2x_dcbnl_get_pfc_cfg,
+	.setall			= bnx2x_dcbnl_set_all,
+	.getcap			= bnx2x_dcbnl_get_cap,
+	.getnumtcs		= bnx2x_dcbnl_get_numtcs,
+	.setnumtcs		= bnx2x_dcbnl_set_numtcs,
+	.getpfcstate		= bnx2x_dcbnl_get_pfc_state,
+	.setpfcstate		= bnx2x_dcbnl_set_pfc_state,
+	.setapp			= bnx2x_dcbnl_set_app_up,
+	.getdcbx		= bnx2x_dcbnl_get_dcbx,
+	.setdcbx		= bnx2x_dcbnl_set_dcbx,
+	.getfeatcfg		= bnx2x_dcbnl_get_featcfg,
+	.setfeatcfg		= bnx2x_dcbnl_set_featcfg,
+	.peer_getappinfo	= bnx2x_peer_appinfo,
+	.peer_getapptable	= bnx2x_peer_apptable,
+	.cee_peer_getpg		= bnx2x_cee_peer_getpg,
+	.cee_peer_getpfc	= bnx2x_cee_peer_getpfc,
 };
 
 #endif /* BCM_DCBNL */
-- 
1.7.3.5




