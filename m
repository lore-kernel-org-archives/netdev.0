From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/7] qed: hw_init() to receive parameter-struct
Date: Tue, 28 Mar 2017 15:12:51 +0300
Message-ID: <1490703176-429-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41201 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752028AbdC1MN5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 08:13:57 -0400
In-Reply-To: <1490703176-429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll soon need additional information, so start by changing
the infrastructure to receive the initializing variables
via a parameter struct.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 21 +++++++++---------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h | 31 ++++++++++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_main.c    | 12 ++++++++---
 3 files changed, 37 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index cf95da5..1092998 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1106,25 +1106,20 @@ static void qed_reset_mb_shadow(struct qed_hwfn *p_hwfn,
 	       p_hwfn->mcp_info->mfw_mb_cur, p_hwfn->mcp_info->mfw_mb_length);
 }
 
-int qed_hw_init(struct qed_dev *cdev,
-		struct qed_tunn_start_params *p_tunn,
-		bool b_hw_start,
-		enum qed_int_mode int_mode,
-		bool allow_npar_tx_switch,
-		const u8 *bin_fw_data)
+int qed_hw_init(struct qed_dev *cdev, struct qed_hw_init_params *p_params)
 {
 	u32 load_code, param, drv_mb_param;
 	bool b_default_mtu = true;
 	struct qed_hwfn *p_hwfn;
 	int rc = 0, mfw_rc, i;
 
-	if ((int_mode == QED_INT_MODE_MSI) && (cdev->num_hwfns > 1)) {
+	if ((p_params->int_mode == QED_INT_MODE_MSI) && (cdev->num_hwfns > 1)) {
 		DP_NOTICE(cdev, "MSI mode is not supported for CMT devices\n");
 		return -EINVAL;
 	}
 
 	if (IS_PF(cdev)) {
-		rc = qed_init_fw_data(cdev, bin_fw_data);
+		rc = qed_init_fw_data(cdev, p_params->bin_fw_data);
 		if (rc)
 			return rc;
 	}
@@ -1181,11 +1176,15 @@ int qed_hw_init(struct qed_dev *cdev,
 		/* Fall into */
 		case FW_MSG_CODE_DRV_LOAD_FUNCTION:
 			rc = qed_hw_init_pf(p_hwfn, p_hwfn->p_main_ptt,
-					    p_tunn, p_hwfn->hw_info.hw_mode,
-					    b_hw_start, int_mode,
-					    allow_npar_tx_switch);
+					    p_params->p_tunn,
+					    p_hwfn->hw_info.hw_mode,
+					    p_params->b_hw_start,
+					    p_params->int_mode,
+					    p_params->allow_npar_tx_switch);
 			break;
 		default:
+			DP_NOTICE(p_hwfn,
+				  "Unexpected load code [0x%08x]", load_code);
 			rc = -EINVAL;
 			break;
 		}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index e96eccf..8f45f46 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -82,26 +82,31 @@ void qed_init_dp(struct qed_dev *cdev,
  */
 void qed_resc_setup(struct qed_dev *cdev);
 
+struct qed_hw_init_params {
+	/* Tunneling parameters */
+	struct qed_tunn_start_params *p_tunn;
+
+	bool b_hw_start;
+
+	/* Interrupt mode [msix, inta, etc.] to use */
+	enum qed_int_mode int_mode;
+
+	/* NPAR tx switching to be used for vports for tx-switching */
+	bool allow_npar_tx_switch;
+
+	/* Binary fw data pointer in binary fw file */
+	const u8 *bin_fw_data;
+};
+
 /**
  * @brief qed_hw_init -
  *
  * @param cdev
- * @param p_tunn
- * @param b_hw_start
- * @param int_mode - interrupt mode [msix, inta, etc.] to use.
- * @param allow_npar_tx_switch - npar tx switching to be used
- *	  for vports configured for tx-switching.
- * @param bin_fw_data - binary fw data pointer in binary fw file.
- *			Pass NULL if not using binary fw file.
+ * @param p_params
  *
  * @return int
  */
-int qed_hw_init(struct qed_dev *cdev,
-		struct qed_tunn_start_params *p_tunn,
-		bool b_hw_start,
-		enum qed_int_mode int_mode,
-		bool allow_npar_tx_switch,
-		const u8 *bin_fw_data);
+int qed_hw_init(struct qed_dev *cdev, struct qed_hw_init_params *p_params);
 
 /**
  * @brief qed_hw_timers_stop_all - stop the timers HW block
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index f2ae90a..ae0ab3b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -901,6 +901,7 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 static int qed_slowpath_start(struct qed_dev *cdev,
 			      struct qed_slowpath_params *params)
 {
+	struct qed_hw_init_params hw_init_params;
 	struct qed_tunn_start_params tunn_info;
 	struct qed_mcp_drv_version drv_version;
 	const u8 *data = NULL;
@@ -966,9 +967,14 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	tunn_info.tunn_clss_ipgre = QED_TUNN_CLSS_MAC_VLAN;
 
 	/* Start the slowpath */
-	rc = qed_hw_init(cdev, &tunn_info, true,
-			 cdev->int_params.out.int_mode,
-			 true, data);
+	memset(&hw_init_params, 0, sizeof(hw_init_params));
+	hw_init_params.p_tunn = &tunn_info;
+	hw_init_params.b_hw_start = true;
+	hw_init_params.int_mode = cdev->int_params.out.int_mode;
+	hw_init_params.allow_npar_tx_switch = true;
+	hw_init_params.bin_fw_data = data;
+
+	rc = qed_hw_init(cdev, &hw_init_params);
 	if (rc)
 		goto err2;
 
-- 
1.9.3
