From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/8] qed: Don't use main-ptt in unrelated flows
Date: Thu, 6 Apr 2017 15:58:29 +0300
Message-ID: <1491483515-13502-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rahul Verma <Rahul.Verma@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53180 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752033AbdDFM7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:59:06 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Verma <Rahul.Verma@cavium.com>

In order to access HW registers driver needs to acquire a PTT entry
[mapping between bar memory and internal chip address].
Since acquiring PTT entries could fail [at least in theory] as their
number is finite and other flows can hold them, we reserve special PTT
entries for 'important' enough flows - ones we want to guarantee that
would not be susceptible to such issues.

One such special entry is the 'main' PTT which is meant to be used in
flows such as chip initialization and de-initialization.
However, there are other flows that are also using that same entry
for their own purpose, and might run concurrently with the original
flows [notice that for most cases using the main-ptt by mistake, such
a race is still impossible, at least today].

This patch re-organizes the various functions that currently use the
main_ptt in one of two ways:

  - If a function shouldn't use the main_ptt it starts acquiring and
    releasing it's own PTT entry and use it instead. Notice if those
    functions previously couldn't fail, they now can [as acquisition
    might fail].

  - Change the prototypes so that the main_ptt would be received as
    a parameter [instead of explicitly accessing it].
    This prevents the future risk of adding codes that introduces new
    use-cases for flows using the main_ptt, ones that might be in race
    with the actual 'main' flows.

Signed-off-by: Rahul Verma <Rahul.Verma@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c     |  8 ++--
 drivers/net/ethernet/qlogic/qed/qed_cxt.h     |  9 ++--
 drivers/net/ethernet/qlogic/qed/qed_dev.c     | 67 ++++++++++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |  8 ++--
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c    | 10 +++-
 drivers/net/ethernet/qlogic/qed/qed_l2.c      | 14 +++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c     | 49 ++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_spq.c     | 20 ++++++--
 8 files changed, 124 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index 485b8b2..15ef6eb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -1438,7 +1438,7 @@ static void qed_cdu_init_pf(struct qed_hwfn *p_hwfn)
 	}
 }
 
-void qed_qm_init_pf(struct qed_hwfn *p_hwfn)
+void qed_qm_init_pf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
 	struct qed_qm_pf_rt_init_params params;
 	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
@@ -1464,7 +1464,7 @@ void qed_qm_init_pf(struct qed_hwfn *p_hwfn)
 	params.pq_params = qm_info->qm_pq_params;
 	params.vport_params = qm_info->qm_vport_params;
 
-	qed_qm_pf_rt_init(p_hwfn, p_hwfn->p_main_ptt, &params);
+	qed_qm_pf_rt_init(p_hwfn, p_ptt, &params);
 }
 
 /* CM PF */
@@ -1822,9 +1822,9 @@ void qed_cxt_hw_init_common(struct qed_hwfn *p_hwfn)
 	qed_prs_init_common(p_hwfn);
 }
 
-void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn)
+void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
-	qed_qm_init_pf(p_hwfn);
+	qed_qm_init_pf(p_hwfn, p_ptt);
 	qed_cm_init_pf(p_hwfn);
 	qed_dq_init_pf(p_hwfn);
 	qed_cdu_init_pf(p_hwfn);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
index f34b288..53ad532 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -172,19 +172,18 @@ u32 qed_cxt_get_proto_cid_count(struct qed_hwfn *p_hwfn,
 /**
  * @brief qed_cxt_hw_init_pf - Initailze ILT and DQ, PF phase, per path.
  *
- *
- *
  * @param p_hwfn
+ * @param p_ptt
  */
-void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn);
+void qed_cxt_hw_init_pf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 
 /**
  * @brief qed_qm_init_pf - Initailze the QM PF phase, per path
  *
  * @param p_hwfn
+ * @param p_ptt
  */
-
-void qed_qm_init_pf(struct qed_hwfn *p_hwfn);
+void qed_qm_init_pf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 
 /**
  * @brief Reconfigures QM pf on the fly
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2498785..2df83be 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -75,7 +75,8 @@ enum BAR_ID {
 	BAR_ID_1        /* Used for doorbells */
 };
 
-static u32 qed_hw_bar_size(struct qed_hwfn *p_hwfn, enum BAR_ID bar_id)
+static u32 qed_hw_bar_size(struct qed_hwfn *p_hwfn,
+			   struct qed_ptt *p_ptt, enum BAR_ID bar_id)
 {
 	u32 bar_reg = (bar_id == BAR_ID_0 ?
 		       PGLUE_B_REG_PF_BAR0_SIZE : PGLUE_B_REG_PF_BAR1_SIZE);
@@ -84,7 +85,7 @@ static u32 qed_hw_bar_size(struct qed_hwfn *p_hwfn, enum BAR_ID bar_id)
 	if (IS_VF(p_hwfn->cdev))
 		return 1 << 17;
 
-	val = qed_rd(p_hwfn, p_hwfn->p_main_ptt, bar_reg);
+	val = qed_rd(p_hwfn, p_ptt, bar_reg);
 	if (val)
 		return 1 << (val + 15);
 
@@ -780,7 +781,7 @@ int qed_qm_reconf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	qed_init_clear_rt_data(p_hwfn);
 
 	/* prepare QM portion of runtime array */
-	qed_qm_init_pf(p_hwfn);
+	qed_qm_init_pf(p_hwfn, p_ptt);
 
 	/* activate init tool on runtime array */
 	rc = qed_init_run(p_hwfn, p_ptt, PHASE_QM_PF, p_hwfn->rel_pf_id,
@@ -1320,7 +1321,7 @@ enum QED_ROCE_EDPM_MODE {
 	int rc = 0;
 	u8 cond;
 
-	db_bar_size = qed_hw_bar_size(p_hwfn, BAR_ID_1);
+	db_bar_size = qed_hw_bar_size(p_hwfn, p_ptt, BAR_ID_1);
 	if (p_hwfn->cdev->num_hwfns > 1)
 		db_bar_size /= 2;
 
@@ -1431,7 +1432,7 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 		p_hwfn->qm_info.pf_rl = 100000;
 	}
 
-	qed_cxt_hw_init_pf(p_hwfn);
+	qed_cxt_hw_init_pf(p_hwfn, p_ptt);
 
 	qed_int_igu_init_rt(p_hwfn);
 
@@ -1852,18 +1853,21 @@ int qed_hw_stop(struct qed_dev *cdev)
 	return rc2;
 }
 
-void qed_hw_stop_fastpath(struct qed_dev *cdev)
+int qed_hw_stop_fastpath(struct qed_dev *cdev)
 {
 	int j;
 
 	for_each_hwfn(cdev, j) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[j];
-		struct qed_ptt *p_ptt = p_hwfn->p_main_ptt;
+		struct qed_ptt *p_ptt;
 
 		if (IS_VF(cdev)) {
 			qed_vf_pf_int_cleanup(p_hwfn);
 			continue;
 		}
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt)
+			return -EAGAIN;
 
 		DP_VERBOSE(p_hwfn,
 			   NETIF_MSG_IFDOWN, "Shutting down the fastpath\n");
@@ -1881,17 +1885,28 @@ void qed_hw_stop_fastpath(struct qed_dev *cdev)
 
 		/* Need to wait 1ms to guarantee SBs are cleared */
 		usleep_range(1000, 2000);
+		qed_ptt_release(p_hwfn, p_ptt);
 	}
+
+	return 0;
 }
 
-void qed_hw_start_fastpath(struct qed_hwfn *p_hwfn)
+int qed_hw_start_fastpath(struct qed_hwfn *p_hwfn)
 {
+	struct qed_ptt *p_ptt;
+
 	if (IS_VF(p_hwfn->cdev))
-		return;
+		return 0;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EAGAIN;
 
 	/* Re-open incoming traffic */
-	qed_wr(p_hwfn, p_hwfn->p_main_ptt,
-	       NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x0);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x0);
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return 0;
 }
 
 /* Free hwfn memory and resources acquired in hw_hwfn_prepare */
@@ -2697,9 +2712,9 @@ static void qed_hw_info_port_num(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	return qed_hw_get_resc(p_hwfn, p_ptt);
 }
 
-static int qed_get_dev_info(struct qed_dev *cdev)
+static int qed_get_dev_info(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
-	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_dev *cdev = p_hwfn->cdev;
 	u16 device_id_mask;
 	u32 tmp;
 
@@ -2721,15 +2736,13 @@ static int qed_get_dev_info(struct qed_dev *cdev)
 		return -EBUSY;
 	}
 
-	cdev->chip_num = (u16)qed_rd(p_hwfn, p_hwfn->p_main_ptt,
-				     MISCS_REG_CHIP_NUM);
-	cdev->chip_rev = (u16)qed_rd(p_hwfn, p_hwfn->p_main_ptt,
-				     MISCS_REG_CHIP_REV);
+	cdev->chip_num = (u16)qed_rd(p_hwfn, p_ptt, MISCS_REG_CHIP_NUM);
+	cdev->chip_rev = (u16)qed_rd(p_hwfn, p_ptt, MISCS_REG_CHIP_REV);
+
 	MASK_FIELD(CHIP_REV, cdev->chip_rev);
 
 	/* Learn number of HW-functions */
-	tmp = qed_rd(p_hwfn, p_hwfn->p_main_ptt,
-		     MISCS_REG_CMT_ENABLED_FOR_PAIR);
+	tmp = qed_rd(p_hwfn, p_ptt, MISCS_REG_CMT_ENABLED_FOR_PAIR);
 
 	if (tmp & (1 << p_hwfn->rel_pf_id)) {
 		DP_NOTICE(cdev->hwfns, "device in CMT mode\n");
@@ -2738,11 +2751,10 @@ static int qed_get_dev_info(struct qed_dev *cdev)
 		cdev->num_hwfns = 1;
 	}
 
-	cdev->chip_bond_id = qed_rd(p_hwfn, p_hwfn->p_main_ptt,
+	cdev->chip_bond_id = qed_rd(p_hwfn, p_ptt,
 				    MISCS_REG_CHIP_TEST_REG) >> 4;
 	MASK_FIELD(CHIP_BOND_ID, cdev->chip_bond_id);
-	cdev->chip_metal = (u16)qed_rd(p_hwfn, p_hwfn->p_main_ptt,
-				       MISCS_REG_CHIP_METAL);
+	cdev->chip_metal = (u16)qed_rd(p_hwfn, p_ptt, MISCS_REG_CHIP_METAL);
 	MASK_FIELD(CHIP_METAL, cdev->chip_metal);
 
 	DP_INFO(cdev->hwfns,
@@ -2795,7 +2807,7 @@ static int qed_hw_prepare_single(struct qed_hwfn *p_hwfn,
 
 	/* First hwfn learns basic information, e.g., number of hwfns */
 	if (!p_hwfn->my_id) {
-		rc = qed_get_dev_info(p_hwfn->cdev);
+		rc = qed_get_dev_info(p_hwfn, p_hwfn->p_main_ptt);
 		if (rc)
 			goto err1;
 	}
@@ -2866,11 +2878,14 @@ int qed_hw_prepare(struct qed_dev *cdev,
 		u8 __iomem *addr;
 
 		/* adjust bar offset for second engine */
-		addr = cdev->regview + qed_hw_bar_size(p_hwfn, BAR_ID_0) / 2;
+		addr = cdev->regview +
+		       qed_hw_bar_size(p_hwfn, p_hwfn->p_main_ptt,
+				       BAR_ID_0) / 2;
 		p_regview = addr;
 
-		/* adjust doorbell bar offset for second engine */
-		addr = cdev->doorbells + qed_hw_bar_size(p_hwfn, BAR_ID_1) / 2;
+		addr = cdev->doorbells +
+		       qed_hw_bar_size(p_hwfn, p_hwfn->p_main_ptt,
+				       BAR_ID_1) / 2;
 		p_doorbell = addr;
 
 		/* prepare second hw function */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 2c6637f..341636d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -165,17 +165,19 @@ struct qed_hw_init_params {
  *
  * @param cdev
  *
+ * @return int
  */
-void qed_hw_stop_fastpath(struct qed_dev *cdev);
+int qed_hw_stop_fastpath(struct qed_dev *cdev);
 
 /**
  * @brief qed_hw_start_fastpath -restart fastpath traffic,
  *		only if hw_stop_fastpath was called
  *
- * @param cdev
+ * @param p_hwfn
  *
+ * @return int
  */
-void qed_hw_start_fastpath(struct qed_hwfn *p_hwfn);
+int qed_hw_start_fastpath(struct qed_hwfn *p_hwfn);
 
 
 /**
diff --git a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
index f4b9534..21a58ff 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_fcoe.c
@@ -340,10 +340,10 @@ struct qed_fcoe_conn {
 
 static int
 qed_sp_fcoe_func_stop(struct qed_hwfn *p_hwfn,
+		      struct qed_ptt *p_ptt,
 		      enum spq_mode comp_mode,
 		      struct qed_spq_comp_cb *p_comp_addr)
 {
-	struct qed_ptt *p_ptt = p_hwfn->p_main_ptt;
 	struct qed_spq_entry *p_ent = NULL;
 	struct qed_sp_init_data init_data;
 	u32 active_segs = 0;
@@ -765,6 +765,7 @@ static struct qed_hash_fcoe_con *qed_fcoe_get_hash(struct qed_dev *cdev,
 
 static int qed_fcoe_stop(struct qed_dev *cdev)
 {
+	struct qed_ptt *p_ptt;
 	int rc;
 
 	if (!(cdev->flags & QED_FLAG_STORAGE_STARTED)) {
@@ -778,10 +779,15 @@ static int qed_fcoe_stop(struct qed_dev *cdev)
 		return -EINVAL;
 	}
 
+	p_ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
+	if (!p_ptt)
+		return -EAGAIN;
+
 	/* Stop the fcoe */
-	rc = qed_sp_fcoe_func_stop(QED_LEADING_HWFN(cdev),
+	rc = qed_sp_fcoe_func_stop(QED_LEADING_HWFN(cdev), p_ptt,
 				   QED_SPQ_MODE_EBLOCK, NULL);
 	cdev->flags &= ~QED_FLAG_STORAGE_STARTED;
+	qed_ptt_release(QED_LEADING_HWFN(cdev), p_ptt);
 
 	return rc;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 9900f7a..d56441d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1929,7 +1929,11 @@ static int qed_start_vport(struct qed_dev *cdev,
 			return rc;
 		}
 
-		qed_hw_start_fastpath(p_hwfn);
+		rc = qed_hw_start_fastpath(p_hwfn);
+		if (rc) {
+			DP_ERR(cdev, "Failed to start VPORT fastpath\n");
+			return rc;
+		}
 
 		DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
 			   "Started V-PORT %d with MTU %d\n",
@@ -2172,7 +2176,13 @@ static int qed_start_txq(struct qed_dev *cdev,
 #define QED_HW_STOP_RETRY_LIMIT (10)
 static int qed_fastpath_stop(struct qed_dev *cdev)
 {
-	qed_hw_stop_fastpath(cdev);
+	int rc;
+
+	rc = qed_hw_stop_fastpath(cdev);
+	if (rc) {
+		DP_ERR(cdev, "Failed to stop Fastpath\n");
+		return rc;
+	}
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 708c601..2e447f9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1407,13 +1407,21 @@ int qed_ll2_establish_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 	struct qed_ll2_info *p_ll2_conn;
 	struct qed_ll2_rx_queue *p_rx;
 	struct qed_ll2_tx_queue *p_tx;
+	struct qed_ptt *p_ptt;
 	int rc = -EINVAL;
 	u32 i, capacity;
 	u8 qid;
 
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EAGAIN;
+
 	p_ll2_conn = qed_ll2_handle_sanity_lock(p_hwfn, connection_handle);
-	if (!p_ll2_conn)
-		return -EINVAL;
+	if (!p_ll2_conn) {
+		rc = -EINVAL;
+		goto out;
+	}
+
 	p_rx = &p_ll2_conn->rx_queue;
 	p_tx = &p_ll2_conn->tx_queue;
 
@@ -1446,7 +1454,9 @@ int qed_ll2_establish_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 	p_tx->cur_completing_frag_num = 0;
 	*p_tx->p_fw_cons = 0;
 
-	qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_CORE, &p_ll2_conn->cid);
+	rc = qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_CORE, &p_ll2_conn->cid);
+	if (rc)
+		goto out;
 
 	qid = p_hwfn->hw_info.resc_start[QED_LL2_QUEUE] + connection_handle;
 	p_ll2_conn->queue_id = qid;
@@ -1460,26 +1470,28 @@ int qed_ll2_establish_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 
 	rc = qed_ll2_establish_connection_rx(p_hwfn, p_ll2_conn);
 	if (rc)
-		return rc;
+		goto out;
 
 	rc = qed_sp_ll2_tx_queue_start(p_hwfn, p_ll2_conn);
 	if (rc)
-		return rc;
+		goto out;
 
 	if (p_hwfn->hw_info.personality != QED_PCI_ETH_ROCE)
-		qed_wr(p_hwfn, p_hwfn->p_main_ptt, PRS_REG_USE_LIGHT_L2, 1);
+		qed_wr(p_hwfn, p_ptt, PRS_REG_USE_LIGHT_L2, 1);
 
 	qed_ll2_establish_connection_ooo(p_hwfn, p_ll2_conn);
 
 	if (p_ll2_conn->conn.conn_type == QED_LL2_TYPE_FCOE) {
-		qed_llh_add_protocol_filter(p_hwfn, p_hwfn->p_main_ptt,
+		qed_llh_add_protocol_filter(p_hwfn, p_ptt,
 					    0x8906, 0,
 					    QED_LLH_FILTER_ETHERTYPE);
-		qed_llh_add_protocol_filter(p_hwfn, p_hwfn->p_main_ptt,
+		qed_llh_add_protocol_filter(p_hwfn, p_ptt,
 					    0x8914, 0,
 					    QED_LLH_FILTER_ETHERTYPE);
 	}
 
+out:
+	qed_ptt_release(p_hwfn, p_ptt);
 	return rc;
 }
 
@@ -1830,23 +1842,30 @@ int qed_ll2_terminate_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 {
 	struct qed_ll2_info *p_ll2_conn = NULL;
 	int rc = -EINVAL;
+	struct qed_ptt *p_ptt;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EAGAIN;
 
 	p_ll2_conn = qed_ll2_handle_sanity_lock(p_hwfn, connection_handle);
-	if (!p_ll2_conn)
-		return -EINVAL;
+	if (!p_ll2_conn) {
+		rc = -EINVAL;
+		goto out;
+	}
 
 	/* Stop Tx & Rx of connection, if needed */
 	if (QED_LL2_TX_REGISTERED(p_ll2_conn)) {
 		rc = qed_sp_ll2_tx_queue_stop(p_hwfn, p_ll2_conn);
 		if (rc)
-			return rc;
+			goto out;
 		qed_ll2_txq_flush(p_hwfn, connection_handle);
 	}
 
 	if (QED_LL2_RX_REGISTERED(p_ll2_conn)) {
 		rc = qed_sp_ll2_rx_queue_stop(p_hwfn, p_ll2_conn);
 		if (rc)
-			return rc;
+			goto out;
 		qed_ll2_rxq_flush(p_hwfn, connection_handle);
 	}
 
@@ -1854,14 +1873,16 @@ int qed_ll2_terminate_connection(struct qed_hwfn *p_hwfn, u8 connection_handle)
 		qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
 
 	if (p_ll2_conn->conn.conn_type == QED_LL2_TYPE_FCOE) {
-		qed_llh_remove_protocol_filter(p_hwfn, p_hwfn->p_main_ptt,
+		qed_llh_remove_protocol_filter(p_hwfn, p_ptt,
 					       0x8906, 0,
 					       QED_LLH_FILTER_ETHERTYPE);
-		qed_llh_remove_protocol_filter(p_hwfn, p_hwfn->p_main_ptt,
+		qed_llh_remove_protocol_filter(p_hwfn, p_ptt,
 					       0x8914, 0,
 					       QED_LLH_FILTER_ETHERTYPE);
 	}
 
+out:
+	qed_ptt_release(p_hwfn, p_ptt);
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 13f7155..f6423a1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -119,6 +119,7 @@ static int qed_spq_block(struct qed_hwfn *p_hwfn,
 			 u8 *p_fw_ret, bool skip_quick_poll)
 {
 	struct qed_spq_comp_done *comp_done;
+	struct qed_ptt *p_ptt;
 	int rc;
 
 	/* A relatively short polling period w/o sleeping, to allow the FW to
@@ -135,8 +136,14 @@ static int qed_spq_block(struct qed_hwfn *p_hwfn,
 	if (!rc)
 		return 0;
 
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt) {
+		DP_NOTICE(p_hwfn, "ptt, failed to acquire\n");
+		return -EAGAIN;
+	}
+
 	DP_INFO(p_hwfn, "Ramrod is stuck, requesting MCP drain\n");
-	rc = qed_mcp_drain(p_hwfn, p_hwfn->p_main_ptt);
+	rc = qed_mcp_drain(p_hwfn, p_ptt);
 	if (rc) {
 		DP_NOTICE(p_hwfn, "MCP drain failed\n");
 		goto err;
@@ -145,15 +152,18 @@ static int qed_spq_block(struct qed_hwfn *p_hwfn,
 	/* Retry after drain */
 	rc = __qed_spq_block(p_hwfn, p_ent, p_fw_ret, true);
 	if (!rc)
-		return 0;
+		goto out;
 
 	comp_done = (struct qed_spq_comp_done *)p_ent->comp_cb.cookie;
-	if (comp_done->done == 1) {
+	if (comp_done->done == 1)
 		if (p_fw_ret)
 			*p_fw_ret = comp_done->fw_return_code;
-		return 0;
-	}
+out:
+	qed_ptt_release(p_hwfn, p_ptt);
+	return 0;
+
 err:
+	qed_ptt_release(p_hwfn, p_ptt);
 	DP_NOTICE(p_hwfn,
 		  "Ramrod is stuck [CID %08x cmd %02x protocol %02x echo %04x]\n",
 		  le32_to_cpu(p_ent->elem.hdr.cid),
-- 
1.9.3
