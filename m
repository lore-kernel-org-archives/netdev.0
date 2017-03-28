From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/7] qed: Correct HW stop flow
Date: Tue, 28 Mar 2017 15:12:50 +0300
Message-ID: <1490703176-429-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41196 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752028AbdC1MNn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 08:13:43 -0400
In-Reply-To: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

Management firmware is used as arbiter between different PFs
which are loading/unloading, but in order to use the synchronization
it offers the contending configurations need to be applied either
between their LOAD_REQ <-> LOAD_DONE or UNLOAD_REQ <-> UNLOAD_DONE
management firmware commands.

Existing HW stop flow utilizes 2 different functions: qed_hw_stop() and
qed_hw_reset() which don't abide this requirement; Most of the closure
is doing outside the scope of the unload request.

This patch removes qed_hw_reset() and places the relevant stop
functionality underneath the management firmware protection.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h         |   1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 146 ++++++++++----------------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |   8 --
 drivers/net/ethernet/qlogic/qed/qed_main.c    |  29 ++---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c     |  73 +++++++++----
 drivers/net/ethernet/qlogic/qed/qed_mcp.h     |  20 ++++
 6 files changed, 142 insertions(+), 135 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index ca30a27..90a1988 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -732,5 +732,6 @@ void qed_get_protocol_stats(struct qed_dev *cdev,
 			    enum qed_mcp_protocol_type type,
 			    union qed_mcp_protocol_stats *stats);
 int qed_slowpath_irq_req(struct qed_hwfn *hwfn);
+void qed_slowpath_irq_sync(struct qed_hwfn *p_hwfn);
 
 #endif /* _QED_H */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 11e45f0..cf95da5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1303,27 +1303,53 @@ void qed_hw_timers_stop_all(struct qed_dev *cdev)
 
 int qed_hw_stop(struct qed_dev *cdev)
 {
-	int rc = 0, t_rc;
+	struct qed_hwfn *p_hwfn;
+	struct qed_ptt *p_ptt;
+	int rc, rc2 = 0;
 	int j;
 
 	for_each_hwfn(cdev, j) {
-		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
-		struct qed_ptt *p_ptt = p_hwfn->p_main_ptt;
+		p_hwfn = &cdev->hwfns[j];
+		p_ptt = p_hwfn->p_main_ptt;
 
 		DP_VERBOSE(p_hwfn, NETIF_MSG_IFDOWN, "Stopping hw/fw\n");
 
 		if (IS_VF(cdev)) {
 			qed_vf_pf_int_cleanup(p_hwfn);
+			rc = qed_vf_pf_reset(p_hwfn);
+			if (rc) {
+				DP_NOTICE(p_hwfn,
+					  "qed_vf_pf_reset failed. rc = %d.\n",
+					  rc);
+				rc2 = -EINVAL;
+			}
 			continue;
 		}
 
 		/* mark the hw as uninitialized... */
 		p_hwfn->hw_init_done = false;
 
+		/* Send unload command to MCP */
+		rc = qed_mcp_unload_req(p_hwfn, p_ptt);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "Failed sending a UNLOAD_REQ command. rc = %d.\n",
+				  rc);
+			rc2 = -EINVAL;
+		}
+
+		qed_slowpath_irq_sync(p_hwfn);
+
+		/* After this point no MFW attentions are expected, e.g. prevent
+		 * race between pf stop and dcbx pf update.
+		 */
 		rc = qed_sp_pf_stop(p_hwfn);
-		if (rc)
+		if (rc) {
 			DP_NOTICE(p_hwfn,
-				  "Failed to close PF against FW. Continue to stop HW to prevent illegal host access by the device\n");
+				  "Failed to close PF against FW [rc = %d]. Continue to stop HW to prevent illegal host access by the device.\n",
+				  rc);
+			rc2 = -EINVAL;
+		}
 
 		qed_wr(p_hwfn, p_ptt,
 		       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x1);
@@ -1346,20 +1372,37 @@ int qed_hw_stop(struct qed_dev *cdev)
 
 		/* Need to wait 1ms to guarantee SBs are cleared */
 		usleep_range(1000, 2000);
+
+		/* Disable PF in HW blocks */
+		qed_wr(p_hwfn, p_ptt, DORQ_REG_PF_DB_ENABLE, 0);
+		qed_wr(p_hwfn, p_ptt, QM_REG_PF_EN, 0);
+
+		qed_mcp_unload_done(p_hwfn, p_ptt);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "Failed sending a UNLOAD_DONE command. rc = %d.\n",
+				  rc);
+			rc2 = -EINVAL;
+		}
 	}
 
 	if (IS_PF(cdev)) {
+		p_hwfn = QED_LEADING_HWFN(cdev);
+		p_ptt = QED_LEADING_HWFN(cdev)->p_main_ptt;
+
 		/* Disable DMAE in PXP - in CMT, this should only be done for
 		 * first hw-function, and only after all transactions have
 		 * stopped for all active hw-functions.
 		 */
-		t_rc = qed_change_pci_hwfn(&cdev->hwfns[0],
-					   cdev->hwfns[0].p_main_ptt, false);
-		if (t_rc != 0)
-			rc = t_rc;
+		rc = qed_change_pci_hwfn(p_hwfn, p_ptt, false);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "qed_change_pci_hwfn failed. rc = %d.\n", rc);
+			rc2 = -EINVAL;
+		}
 	}
 
-	return rc;
+	return rc2;
 }
 
 void qed_hw_stop_fastpath(struct qed_dev *cdev)
@@ -1404,89 +1447,6 @@ void qed_hw_start_fastpath(struct qed_hwfn *p_hwfn)
 	       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x0);
 }
 
-static int qed_reg_assert(struct qed_hwfn *p_hwfn,
-			  struct qed_ptt *p_ptt, u32 reg, bool expected)
-{
-	u32 assert_val = qed_rd(p_hwfn, p_ptt, reg);
-
-	if (assert_val != expected) {
-		DP_NOTICE(p_hwfn, "Value at address 0x%08x != 0x%08x\n",
-			  reg, expected);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-int qed_hw_reset(struct qed_dev *cdev)
-{
-	int rc = 0;
-	u32 unload_resp, unload_param;
-	u32 wol_param;
-	int i;
-
-	switch (cdev->wol_config) {
-	case QED_OV_WOL_DISABLED:
-		wol_param = DRV_MB_PARAM_UNLOAD_WOL_DISABLED;
-		break;
-	case QED_OV_WOL_ENABLED:
-		wol_param = DRV_MB_PARAM_UNLOAD_WOL_ENABLED;
-		break;
-	default:
-		DP_NOTICE(cdev,
-			  "Unknown WoL configuration %02x\n", cdev->wol_config);
-		/* Fallthrough */
-	case QED_OV_WOL_DEFAULT:
-		wol_param = DRV_MB_PARAM_UNLOAD_WOL_MCP;
-	}
-
-	for_each_hwfn(cdev, i) {
-		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
-
-		if (IS_VF(cdev)) {
-			rc = qed_vf_pf_reset(p_hwfn);
-			if (rc)
-				return rc;
-			continue;
-		}
-
-		DP_VERBOSE(p_hwfn, NETIF_MSG_IFDOWN, "Resetting hw/fw\n");
-
-		/* Check for incorrect states */
-		qed_reg_assert(p_hwfn, p_hwfn->p_main_ptt,
-			       QM_REG_USG_CNT_PF_TX, 0);
-		qed_reg_assert(p_hwfn, p_hwfn->p_main_ptt,
-			       QM_REG_USG_CNT_PF_OTHER, 0);
-
-		/* Disable PF in HW blocks */
-		qed_wr(p_hwfn, p_hwfn->p_main_ptt, DORQ_REG_PF_DB_ENABLE, 0);
-		qed_wr(p_hwfn, p_hwfn->p_main_ptt, QM_REG_PF_EN, 0);
-		qed_wr(p_hwfn, p_hwfn->p_main_ptt,
-		       TCFC_REG_STRONG_ENABLE_PF, 0);
-		qed_wr(p_hwfn, p_hwfn->p_main_ptt,
-		       CCFC_REG_STRONG_ENABLE_PF, 0);
-
-		/* Send unload command to MCP */
-		rc = qed_mcp_cmd(p_hwfn, p_hwfn->p_main_ptt,
-				 DRV_MSG_CODE_UNLOAD_REQ, wol_param,
-				 &unload_resp, &unload_param);
-		if (rc) {
-			DP_NOTICE(p_hwfn, "qed_hw_reset: UNLOAD_REQ failed\n");
-			unload_resp = FW_MSG_CODE_DRV_UNLOAD_ENGINE;
-		}
-
-		rc = qed_mcp_cmd(p_hwfn, p_hwfn->p_main_ptt,
-				 DRV_MSG_CODE_UNLOAD_DONE,
-				 0, &unload_resp, &unload_param);
-		if (rc) {
-			DP_NOTICE(p_hwfn, "qed_hw_reset: UNLOAD_DONE failed\n");
-			return rc;
-		}
-	}
-
-	return rc;
-}
-
 /* Free hwfn memory and resources acquired in hw_hwfn_prepare */
 static void qed_hw_hwfn_free(struct qed_hwfn *p_hwfn)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 6812003..e96eccf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -140,14 +140,6 @@ int qed_hw_init(struct qed_dev *cdev,
  */
 void qed_hw_start_fastpath(struct qed_hwfn *p_hwfn);
 
-/**
- * @brief qed_hw_reset -
- *
- * @param cdev
- *
- * @return int
- */
-int qed_hw_reset(struct qed_dev *cdev);
 
 /**
  * @brief qed_hw_prepare -
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 766c6f3..f2ae90a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -589,6 +589,19 @@ int qed_slowpath_irq_req(struct qed_hwfn *hwfn)
 	return rc;
 }
 
+void qed_slowpath_irq_sync(struct qed_hwfn *p_hwfn)
+{
+	struct qed_dev *cdev = p_hwfn->cdev;
+	u8 id = p_hwfn->my_id;
+	u32 int_mode;
+
+	int_mode = cdev->int_params.out.int_mode;
+	if (int_mode == QED_INT_MODE_MSIX)
+		synchronize_irq(cdev->int_params.msix_table[id].vector);
+	else
+		synchronize_irq(cdev->pdev->irq);
+}
+
 static void qed_slowpath_irq_free(struct qed_dev *cdev)
 {
 	int i;
@@ -631,19 +644,6 @@ static int qed_nic_stop(struct qed_dev *cdev)
 	return rc;
 }
 
-static int qed_nic_reset(struct qed_dev *cdev)
-{
-	int rc;
-
-	rc = qed_hw_reset(cdev);
-	if (rc)
-		return rc;
-
-	qed_resc_free(cdev);
-
-	return 0;
-}
-
 static int qed_nic_setup(struct qed_dev *cdev)
 {
 	int rc, i;
@@ -1043,7 +1043,8 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 	}
 
 	qed_disable_msix(cdev);
-	qed_nic_reset(cdev);
+
+	qed_resc_free(cdev);
 
 	qed_iov_wq_stop(cdev, true);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index ccea0ea..f2e5ab9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -550,32 +550,12 @@ int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
 		u32 *o_mcp_param)
 {
 	struct qed_mcp_mb_params mb_params;
-	struct mcp_mac wol_mac;
 	int rc;
 
 	memset(&mb_params, 0, sizeof(mb_params));
 	mb_params.cmd = cmd;
 	mb_params.param = param;
 
-	/* In case of UNLOAD_DONE, set the primary MAC */
-	if ((cmd == DRV_MSG_CODE_UNLOAD_DONE) &&
-	    (p_hwfn->cdev->wol_config == QED_OV_WOL_ENABLED)) {
-		u8 *p_mac = p_hwfn->cdev->wol_mac;
-
-		memset(&wol_mac, 0, sizeof(wol_mac));
-		wol_mac.mac_upper = p_mac[0] << 8 | p_mac[1];
-		wol_mac.mac_lower = p_mac[2] << 24 | p_mac[3] << 16 |
-				    p_mac[4] << 8 | p_mac[5];
-
-		DP_VERBOSE(p_hwfn,
-			   (QED_MSG_SP | NETIF_MSG_IFDOWN),
-			   "Setting WoL MAC: %pM --> [%08x,%08x]\n",
-			   p_mac, wol_mac.mac_upper, wol_mac.mac_lower);
-
-		mb_params.p_data_src = &wol_mac;
-		mb_params.data_src_size = sizeof(wol_mac);
-	}
-
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc)
 		return rc;
@@ -663,6 +643,59 @@ int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+int qed_mcp_unload_req(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 wol_param, mcp_resp, mcp_param;
+
+	switch (p_hwfn->cdev->wol_config) {
+	case QED_OV_WOL_DISABLED:
+		wol_param = DRV_MB_PARAM_UNLOAD_WOL_DISABLED;
+		break;
+	case QED_OV_WOL_ENABLED:
+		wol_param = DRV_MB_PARAM_UNLOAD_WOL_ENABLED;
+		break;
+	default:
+		DP_NOTICE(p_hwfn,
+			  "Unknown WoL configuration %02x\n",
+			  p_hwfn->cdev->wol_config);
+		/* Fallthrough */
+	case QED_OV_WOL_DEFAULT:
+		wol_param = DRV_MB_PARAM_UNLOAD_WOL_MCP;
+	}
+
+	return qed_mcp_cmd(p_hwfn, p_ptt, DRV_MSG_CODE_UNLOAD_REQ, wol_param,
+			   &mcp_resp, &mcp_param);
+}
+
+int qed_mcp_unload_done(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_mcp_mb_params mb_params;
+	struct mcp_mac wol_mac;
+
+	memset(&mb_params, 0, sizeof(mb_params));
+	mb_params.cmd = DRV_MSG_CODE_UNLOAD_DONE;
+
+	/* Set the primary MAC if WoL is enabled */
+	if (p_hwfn->cdev->wol_config == QED_OV_WOL_ENABLED) {
+		u8 *p_mac = p_hwfn->cdev->wol_mac;
+
+		memset(&wol_mac, 0, sizeof(wol_mac));
+		wol_mac.mac_upper = p_mac[0] << 8 | p_mac[1];
+		wol_mac.mac_lower = p_mac[2] << 24 | p_mac[3] << 16 |
+				    p_mac[4] << 8 | p_mac[5];
+
+		DP_VERBOSE(p_hwfn,
+			   (QED_MSG_SP | NETIF_MSG_IFDOWN),
+			   "Setting WoL MAC: %pM --> [%08x,%08x]\n",
+			   p_mac, wol_mac.mac_upper, wol_mac.mac_lower);
+
+		mb_params.p_data_src = &wol_mac;
+		mb_params.data_src_size = sizeof(wol_mac);
+	}
+
+	return qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
+}
+
 static void qed_mcp_handle_vf_flr(struct qed_hwfn *p_hwfn,
 				  struct qed_ptt *p_ptt)
 {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index f63693d..7d067d0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -593,6 +593,26 @@ int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 		     u32 *p_load_code);
 
 /**
+ * @brief Sends a UNLOAD_REQ message to the MFW
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @return int - 0 - Operation was successful.
+ */
+int qed_mcp_unload_req(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
+
+/**
+ * @brief Sends a UNLOAD_DONE message to the MFW
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ *
+ * @return int - 0 - Operation was successful.
+ */
+int qed_mcp_unload_done(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
+
+/**
  * @brief Read the MFW mailbox into Current buffer.
  *
  * @param p_hwfn
-- 
1.9.3
