From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 5/5] qed: Acquire/release ptt_ptp lock when enabling/disabling PTP.
Date: Wed, 26 Apr 2017 09:00:53 -0700
Message-ID: <20170426160053.8356-6-sudarsana.kalluru@cavium.com>
References: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0041.outbound.protection.outlook.com ([104.47.42.41]:42496
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759733AbdDZQBh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:01:37 -0400
In-Reply-To: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the code for acquiring/releasing ptt_ptp lock to ptp specific
implementations i.e., ptp_enable()/disable() respectively.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h      |  7 +++++--
 drivers/net/ethernet/qlogic/qed/qed_main.c | 12 ------------
 drivers/net/ethernet/qlogic/qed/qed_ptp.c  | 15 ++++++++++++++-
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 3f8d07b..c07191c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -474,6 +474,11 @@ struct qed_hwfn {
 	struct qed_ptt			*p_main_ptt;
 	struct qed_ptt			*p_dpc_ptt;
 
+	/* PTP will be used only by the leading function.
+	 * Usage of all PTP-apis should be synchronized as result.
+	 */
+	struct qed_ptt *p_ptp_ptt;
+
 	struct qed_sb_sp_info		*p_sp_sb;
 	struct qed_sb_attn_info		*p_sb_attn;
 
@@ -532,8 +537,6 @@ struct qed_hwfn {
 
 	struct qed_ptt *p_arfs_ptt;
 
-	/* p_ptp_ptt is valid for leading HWFN only */
-	struct qed_ptt *p_ptp_ptt;
 	struct qed_simd_fp_handler	simd_proto_handler[64];
 
 #ifdef CONFIG_QED_SRIOV
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index a919260..8a5a064 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -956,13 +956,6 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 			}
 		}
 #endif
-		p_ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
-		if (p_ptt) {
-			QED_LEADING_HWFN(cdev)->p_ptp_ptt = p_ptt;
-		} else {
-			DP_NOTICE(cdev, "Failed to acquire PTT for PTP\n");
-			goto err;
-		}
 	}
 
 	cdev->rx_coalesce_usecs = QED_DEFAULT_RX_USECS;
@@ -1076,9 +1069,6 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 		qed_ptt_release(QED_LEADING_HWFN(cdev),
 				QED_LEADING_HWFN(cdev)->p_arfs_ptt);
 #endif
-	if (IS_PF(cdev) && QED_LEADING_HWFN(cdev)->p_ptp_ptt)
-		qed_ptt_release(QED_LEADING_HWFN(cdev),
-				QED_LEADING_HWFN(cdev)->p_ptp_ptt);
 
 	qed_iov_wq_stop(cdev, false);
 
@@ -1098,8 +1088,6 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 			qed_ptt_release(QED_LEADING_HWFN(cdev),
 					QED_LEADING_HWFN(cdev)->p_arfs_ptt);
 #endif
-		qed_ptt_release(QED_LEADING_HWFN(cdev),
-				QED_LEADING_HWFN(cdev)->p_ptp_ptt);
 		qed_free_stream_mem(cdev);
 		if (IS_QED_ETH_IF(cdev))
 			qed_sriov_disable(cdev, true);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ptp.c b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
index c0a3cbd..1871ebf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ptp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
@@ -324,13 +324,23 @@ static int qed_ptp_hw_adjfreq(struct qed_dev *cdev, s32 ppb)
 static int qed_ptp_hw_enable(struct qed_dev *cdev)
 {
 	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
-	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
+	struct qed_ptt *p_ptt;
 	int rc;
 
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt) {
+		DP_NOTICE(p_hwfn, "Failed to acquire PTT for PTP\n");
+		return -EBUSY;
+	}
+
+	p_hwfn->p_ptp_ptt = p_ptt;
+
 	rc = qed_ptp_res_lock(p_hwfn, p_ptt);
 	if (rc) {
 		DP_INFO(p_hwfn,
 			"Couldn't acquire the resource lock, skip ptp enable for this PF\n");
+		qed_ptt_release(p_hwfn, p_ptt);
+		p_hwfn->p_ptp_ptt = NULL;
 		return rc;
 	}
 
@@ -402,6 +412,9 @@ static int qed_ptp_hw_disable(struct qed_dev *cdev)
 	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_PTP_EN, 0x0);
 	qed_wr(p_hwfn, p_ptt, NIG_REG_TX_PTP_EN, 0x0);
 
+	qed_ptt_release(p_hwfn, p_ptt);
+	p_hwfn->p_ptp_ptt = NULL;
+
 	return 0;
 }
 
-- 
1.8.3.1
