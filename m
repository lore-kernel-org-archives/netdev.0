From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 05/12] bnx2x: propagate DCBX negotiation
Date: Sun, 13 Nov 2011 14:47:22 +0200
Message-ID: <1321188449-5822-6-git-send-email-dmitry@broadcom.com>
References: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3135 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752548Ab1KMMrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 07:47:47 -0500
In-Reply-To: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need propagate the DCBX results from PMF to other functions
on the same port, in order to properly update netdev structure
and allow following new ETS and PFC configurations.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   54 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c  |   53 ++++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   25 +---------
 4 files changed, 90 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3f80c11..e9a91a3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1927,7 +1927,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		break;
 	}
 
-	if (!bp->port.pmf)
+	if (bp->port.pmf)
+		bnx2x_update_drv_flags(bp, DRV_FLAGS_DCB_CONFIGURED, 0);
+	else
 		bnx2x__link_status_update(bp);
 
 	/* start the timer */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index c1d7833..59f1291 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1499,4 +1499,58 @@ static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
 void bnx2x_get_iscsi_info(struct bnx2x *bp);
 #endif
 
+/* returns func by VN for current port */
+static inline int func_by_vn(struct bnx2x *bp, int vn)
+{
+	return 2 * vn + BP_PORT(bp);
+}
+
+/**
+ * bnx2x_link_sync_notify - send notification to other functions.
+ *
+ * @bp:		driver handle
+ *
+ */
+static inline void bnx2x_link_sync_notify(struct bnx2x *bp)
+{
+	int func;
+	int vn;
+
+	/* Set the attention towards other drivers on the same port */
+	for (vn = VN_0; vn < BP_MAX_VN_NUM(bp); vn++) {
+		if (vn == BP_VN(bp))
+			continue;
+
+		func = func_by_vn(bp, vn);
+		REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
+		       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
+	}
+}
+
+/**
+ * bnx2x_update_drv_flags - update flags in shmem
+ *
+ * @bp:		driver handle
+ * @flags:	flags to update
+ * @set:	set or clear
+ *
+ */
+static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)
+{
+	if (SHMEM2_HAS(bp, drv_flags)) {
+		u32 drv_flags;
+		bnx2x_acquire_hw_lock(bp, HW_LOCK_DRV_FLAGS);
+		drv_flags = SHMEM2_RD(bp, drv_flags);
+
+		if (set)
+			SET_FLAGS(drv_flags, flags);
+		else
+			RESET_FLAGS(drv_flags, flags);
+
+		SHMEM2_WR(bp, drv_flags, drv_flags);
+		DP(NETIF_MSG_HW, "drv_flags 0x%08x\n", drv_flags);
+		bnx2x_release_hw_lock(bp, HW_LOCK_DRV_FLAGS);
+	}
+}
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 5cba9d7..a0598fd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -685,24 +685,6 @@ int bnx2x_dcbnl_update_applist(struct bnx2x *bp, bool delall)
 }
 #endif
 
-static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)
-{
-	if (SHMEM2_HAS(bp, drv_flags)) {
-		u32 drv_flags;
-		bnx2x_acquire_hw_lock(bp, HW_LOCK_DRV_FLAGS);
-		drv_flags = SHMEM2_RD(bp, drv_flags);
-
-		if (set)
-			SET_FLAGS(drv_flags, flags);
-		else
-			RESET_FLAGS(drv_flags, flags);
-
-		SHMEM2_WR(bp, drv_flags, drv_flags);
-		DP(NETIF_MSG_HW, "drv_flags 0x%08x\n", drv_flags);
-		bnx2x_release_hw_lock(bp, HW_LOCK_DRV_FLAGS);
-	}
-}
-
 static inline void bnx2x_dcbx_update_tc_mapping(struct bnx2x *bp)
 {
 	u8 prio, cos;
@@ -755,18 +737,26 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 			/* mark DCBX result for PMF migration */
 			bnx2x_update_drv_flags(bp, DRV_FLAGS_DCB_CONFIGURED, 1);
 #ifdef BCM_DCBNL
-			/**
+			/*
 			 * Add new app tlvs to dcbnl
 			 */
 			bnx2x_dcbnl_update_applist(bp, false);
 #endif
-			bnx2x_dcbx_stop_hw_tx(bp);
-
-			/* reconfigure the netdevice with the results of the new
+			/*
+			 * reconfigure the netdevice with the results of the new
 			 * dcbx negotiation.
 			 */
 			bnx2x_dcbx_update_tc_mapping(bp);
 
+			/*
+			 * allow other funtions to update their netdevices
+			 * accordingly
+			 */
+			if (IS_MF(bp))
+				bnx2x_link_sync_notify(bp);
+
+			bnx2x_dcbx_stop_hw_tx(bp);
+
 			return;
 		}
 	case BNX2X_DCBX_STATE_TX_PAUSED:
@@ -775,6 +765,7 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 
 		bnx2x_dcbx_update_ets_params(bp);
 		bnx2x_dcbx_resume_hw_tx(bp);
+
 		return;
 	case BNX2X_DCBX_STATE_TX_RELEASED:
 		DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_TX_RELEASED\n");
@@ -1863,7 +1854,7 @@ static void bnx2x_dcbx_fw_struct(struct bnx2x *bp,
 void bnx2x_dcbx_pmf_update(struct bnx2x *bp)
 {
 	/* if we need to syncronize DCBX result from prev PMF
-	 * read it from shmem and update bp accordingly
+	 * read it from shmem and update bp and netdev accordingly
 	 */
 	if (SHMEM2_HAS(bp, drv_flags) &&
 	   GET_FLAGS(SHMEM2_RD(bp, drv_flags), DRV_FLAGS_DCB_CONFIGURED)) {
@@ -1875,6 +1866,22 @@ void bnx2x_dcbx_pmf_update(struct bnx2x *bp)
 					  bp->dcbx_error);
 		bnx2x_get_dcbx_drv_param(bp, &bp->dcbx_local_feat,
 					 bp->dcbx_error);
+#ifdef BCM_DCBNL
+		/*
+		 * Add new app tlvs to dcbnl
+		 */
+		bnx2x_dcbnl_update_applist(bp, false);
+		/*
+		 * Send a notification for the new negotiated parameters
+		 */
+		dcbnl_cee_notify(bp->dev, RTM_GETDCB, DCB_CMD_CEE_GET, 0, 0);
+#endif
+		/*
+		 * reconfigure the netdevice with the results of the new
+		 * dcbx negotiation.
+		 */
+		bnx2x_dcbx_update_tc_mapping(bp);
+
 	}
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 26dc539..967c41b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2318,12 +2318,6 @@ static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
 					CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
 }
 
-/* returns func by VN for current port */
-static inline int func_by_vn(struct bnx2x *bp, int vn)
-{
-	return 2 * vn + BP_PORT(bp);
-}
-
 static void bnx2x_init_vn_minmax(struct bnx2x *bp, int vn)
 {
 	struct rate_shaping_vars_per_vn m_rs_vn;
@@ -2475,22 +2469,6 @@ static void bnx2x_cmng_fns_init(struct bnx2x *bp, u8 read_cfg, u8 cmng_type)
 	   "rate shaping and fairness are disabled\n");
 }
 
-static inline void bnx2x_link_sync_notify(struct bnx2x *bp)
-{
-	int func;
-	int vn;
-
-	/* Set the attention towards other drivers on the same port */
-	for (vn = VN_0; vn < BP_MAX_VN_NUM(bp); vn++) {
-		if (vn == BP_VN(bp))
-			continue;
-
-		func = func_by_vn(bp, vn);
-		REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
-		       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
-	}
-}
-
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
 {
@@ -2549,6 +2527,9 @@ void bnx2x__link_status_update(struct bnx2x *bp)
 	if (bp->state != BNX2X_STATE_OPEN)
 		return;
 
+	/* read updated dcb configuration */
+	bnx2x_dcbx_pmf_update(bp);
+
 	bnx2x_link_status_update(&bp->link_params, &bp->link_vars);
 
 	if (bp->link_vars.link_up)
-- 
1.7.7.2
