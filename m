From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/6] qed: Fix error flow on slowpath start
Date: Wed, 2 Mar 2016 20:26:03 +0200
Message-ID: <1456943165-15198-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:54066 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756306AbcCBS01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:26:27 -0500
In-Reply-To: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of problems when initializing the chip, the error flows aren't
being properly done. Specifically, it's possible that the chip would be
left in a configuration allowing it [internally] to access the host
memory, causing fatal problems in the device that would require power
cycle to overcome.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 89 +++++++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |  9 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c    | 10 +--
 3 files changed, 64 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index d08078f..c3f293d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -756,10 +756,54 @@ int qed_hw_init(struct qed_dev *cdev,
 }
 
 #define QED_HW_STOP_RETRY_LIMIT (10)
+static inline void qed_hw_timers_stop(struct qed_dev *cdev,
+				      struct qed_hwfn *p_hwfn,
+				      struct qed_ptt *p_ptt)
+{
+	int i;
+
+	/* close timers */
+	qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_CONN, 0x0);
+	qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_TASK, 0x0);
+
+	for (i = 0; i < QED_HW_STOP_RETRY_LIMIT; i++) {
+		if ((!qed_rd(p_hwfn, p_ptt,
+			     TM_REG_PF_SCAN_ACTIVE_CONN)) &&
+		    (!qed_rd(p_hwfn, p_ptt,
+			     TM_REG_PF_SCAN_ACTIVE_TASK)))
+			break;
+
+		/* Dependent on number of connection/tasks, possibly
+		 * 1ms sleep is required between polls
+		 */
+		usleep_range(1000, 2000);
+	}
+
+	if (i < QED_HW_STOP_RETRY_LIMIT)
+		return;
+
+	DP_NOTICE(p_hwfn,
+		  "Timers linear scans are not over [Connection %02x Tasks %02x]\n",
+		  (u8)qed_rd(p_hwfn, p_ptt, TM_REG_PF_SCAN_ACTIVE_CONN),
+		  (u8)qed_rd(p_hwfn, p_ptt, TM_REG_PF_SCAN_ACTIVE_TASK));
+}
+
+void qed_hw_timers_stop_all(struct qed_dev *cdev)
+{
+	int j;
+
+	for_each_hwfn(cdev, j) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
+		struct qed_ptt *p_ptt = p_hwfn->p_main_ptt;
+
+		qed_hw_timers_stop(cdev, p_hwfn, p_ptt);
+	}
+}
+
 int qed_hw_stop(struct qed_dev *cdev)
 {
 	int rc = 0, t_rc;
-	int i, j;
+	int j;
 
 	for_each_hwfn(cdev, j) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
@@ -772,7 +816,8 @@ int qed_hw_stop(struct qed_dev *cdev)
 
 		rc = qed_sp_pf_stop(p_hwfn);
 		if (rc)
-			return rc;
+			DP_NOTICE(p_hwfn,
+				  "Failed to close PF against FW. Continue to stop HW to prevent illegal host access by the device\n");
 
 		qed_wr(p_hwfn, p_ptt,
 		       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x1);
@@ -783,24 +828,7 @@ int qed_hw_stop(struct qed_dev *cdev)
 		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_ROCE, 0x0);
 		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_OPENFLOW, 0x0);
 
-		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_CONN, 0x0);
-		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_TASK, 0x0);
-		for (i = 0; i < QED_HW_STOP_RETRY_LIMIT; i++) {
-			if ((!qed_rd(p_hwfn, p_ptt,
-				     TM_REG_PF_SCAN_ACTIVE_CONN)) &&
-			    (!qed_rd(p_hwfn, p_ptt,
-				     TM_REG_PF_SCAN_ACTIVE_TASK)))
-				break;
-
-			usleep_range(1000, 2000);
-		}
-		if (i == QED_HW_STOP_RETRY_LIMIT)
-			DP_NOTICE(p_hwfn,
-				  "Timers linear scans are not over [Connection %02x Tasks %02x]\n",
-				  (u8)qed_rd(p_hwfn, p_ptt,
-					     TM_REG_PF_SCAN_ACTIVE_CONN),
-				  (u8)qed_rd(p_hwfn, p_ptt,
-					     TM_REG_PF_SCAN_ACTIVE_TASK));
+		qed_hw_timers_stop(cdev, p_hwfn, p_ptt);
 
 		/* Disable Attention Generation */
 		qed_int_igu_disable_int(p_hwfn, p_ptt);
@@ -829,7 +857,7 @@ int qed_hw_stop(struct qed_dev *cdev)
 
 void qed_hw_stop_fastpath(struct qed_dev *cdev)
 {
-	int i, j;
+	int j;
 
 	for_each_hwfn(cdev, j) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
@@ -848,25 +876,6 @@ void qed_hw_stop_fastpath(struct qed_dev *cdev)
 		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_ROCE, 0x0);
 		qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_OPENFLOW, 0x0);
 
-		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_CONN, 0x0);
-		qed_wr(p_hwfn, p_ptt, TM_REG_PF_ENABLE_TASK, 0x0);
-		for (i = 0; i < QED_HW_STOP_RETRY_LIMIT; i++) {
-			if ((!qed_rd(p_hwfn, p_ptt,
-				     TM_REG_PF_SCAN_ACTIVE_CONN)) &&
-			    (!qed_rd(p_hwfn, p_ptt,
-				     TM_REG_PF_SCAN_ACTIVE_TASK)))
-				break;
-
-			usleep_range(1000, 2000);
-		}
-		if (i == QED_HW_STOP_RETRY_LIMIT)
-			DP_NOTICE(p_hwfn,
-				  "Timers linear scans are not over [Connection %02x Tasks %02x]\n",
-				  (u8)qed_rd(p_hwfn, p_ptt,
-					     TM_REG_PF_SCAN_ACTIVE_CONN),
-				  (u8)qed_rd(p_hwfn, p_ptt,
-					     TM_REG_PF_SCAN_ACTIVE_TASK));
-
 		qed_int_igu_init_pure_rt(p_hwfn, p_ptt, false, false);
 
 		/* Need to wait 1ms to guarantee SBs are cleared */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 155f26b..d6c7ddf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -78,6 +78,15 @@ int qed_hw_init(struct qed_dev *cdev,
 		const u8 *bin_fw_data);
 
 /**
+ * @brief qed_hw_timers_stop_all - stop the timers HW block
+ *
+ * @param cdev
+ *
+ * @return void
+ */
+void qed_hw_timers_stop_all(struct qed_dev *cdev);
+
+/**
  * @brief qed_hw_stop -
  *
  * @param cdev
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index caa689e..26d40db 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -779,7 +779,7 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	rc = qed_hw_init(cdev, true, cdev->int_params.out.int_mode,
 			 true, data);
 	if (rc)
-		goto err3;
+		goto err2;
 
 	DP_INFO(cdev,
 		"HW initialization and function start completed successfully\n");
@@ -798,12 +798,14 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 		return rc;
 	}
 
+	qed_reset_vport_stats(cdev);
+
 	return 0;
 
-err3:
-	qed_free_stream_mem(cdev);
-	qed_slowpath_irq_free(cdev);
 err2:
+	qed_hw_timers_stop_all(cdev);
+	qed_slowpath_irq_free(cdev);
+	qed_free_stream_mem(cdev);
 	qed_disable_msix(cdev);
 err1:
 	qed_resc_free(cdev);
-- 
1.9.3
