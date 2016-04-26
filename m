From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/3] qed: Add PF min bandwidth configuration support
Date: Tue, 26 Apr 2016 10:56:10 -0400
Message-ID: <1461682570-745-4-git-send-email-manish.chopra@qlogic.com>
References: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57831 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752270AbcDZPiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 11:38:14 -0400
In-Reply-To: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for PF minimum bandwidth update
or configuration notified by management firmware.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c          | 71 ++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |  2 +
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    | 15 +++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c          | 10 ++-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h          |  7 +++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |  1 +
 6 files changed, 104 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 4e99108..b500c86 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -220,9 +220,13 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 
 	qm_info->start_vport = (u8)RESC_START(p_hwfn, QED_VPORT);
 
+	for (i = 0; i < qm_info->num_vports; i++)
+		qm_info->qm_vport_params[i].vport_wfq = 1;
+
 	qm_info->pf_wfq = 0;
 	qm_info->pf_rl = 0;
 	qm_info->vport_rl_en = 1;
+	qm_info->vport_wfq_en = 1;
 
 	return 0;
 
@@ -1841,3 +1845,70 @@ int qed_configure_pf_max_bandwidth(struct qed_dev *cdev, u8 max_bw)
 
 	return rc;
 }
+
+int __qed_configure_pf_min_bandwidth(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_mcp_link_state *p_link,
+				     u8 min_bw)
+{
+	int rc = 0;
+
+	p_hwfn->mcp_info->func_info.bandwidth_min = min_bw;
+	p_hwfn->qm_info.pf_wfq = min_bw;
+
+	if (!p_link->line_speed)
+		return rc;
+
+	p_link->min_pf_rate = (p_link->line_speed * min_bw) / 100;
+
+	rc = qed_init_pf_wfq(p_hwfn, p_ptt, p_hwfn->rel_pf_id, min_bw);
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+		   "Configured MIN bandwidth to be %d Mb/sec\n",
+		   p_link->min_pf_rate);
+
+	return rc;
+}
+
+/* Main API to configure PF min bandwidth where bw range is [1-100] */
+int qed_configure_pf_min_bandwidth(struct qed_dev *cdev, u8 min_bw)
+{
+	int i, rc = -EINVAL;
+
+	if (min_bw < 1 || min_bw > 100) {
+		DP_NOTICE(cdev, "PF min bw valid range is [1-100]\n");
+		return rc;
+	}
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		struct qed_hwfn *p_lead = QED_LEADING_HWFN(cdev);
+		struct qed_mcp_link_state *p_link;
+		struct qed_ptt *p_ptt;
+
+		p_link = &p_lead->mcp_info->link_output;
+
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt)
+			return -EBUSY;
+
+		rc = __qed_configure_pf_min_bandwidth(p_hwfn, p_ptt,
+						      p_link, min_bw);
+		if (rc) {
+			qed_ptt_release(p_hwfn, p_ptt);
+			return rc;
+		}
+
+		if (p_link->min_pf_rate) {
+			u32 min_rate = p_link->min_pf_rate;
+
+			rc = __qed_configure_vp_wfq_on_link_change(p_hwfn,
+								   p_ptt,
+								   min_rate);
+		}
+
+		qed_ptt_release(p_hwfn, p_ptt);
+	}
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 81cf625..5aa78a9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -5116,6 +5116,8 @@ struct hw_set_image {
 	struct hw_set_info	hw_sets[1];
 };
 
+int qed_init_pf_wfq(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+		    u8 pf_id, u16 pf_wfq);
 int qed_init_vport_wfq(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 		       u16 first_tx_pq_id[NUM_OF_TCS], u16 vport_wfq);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
index e646987..e8a3b9d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -712,6 +712,21 @@ int qed_qm_pf_rt_init(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+int qed_init_pf_wfq(struct qed_hwfn *p_hwfn,
+		    struct qed_ptt *p_ptt,
+		    u8 pf_id, u16 pf_wfq)
+{
+	u32 inc_val = QM_WFQ_INC_VAL(pf_wfq);
+
+	if (!inc_val || inc_val > QM_WFQ_MAX_INC_VAL) {
+		DP_NOTICE(p_hwfn, "Invalid PF WFQ weight configuration");
+		return -1;
+	}
+
+	qed_wr(p_hwfn, p_ptt, QM_REG_WFQPFWEIGHT + pf_id * 4, inc_val);
+	return 0;
+}
+
 int qed_init_pf_rl(struct qed_hwfn *p_hwfn,
 		   struct qed_ptt *p_ptt,
 		   u8 pf_id,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 578b09c..cb46dbd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -472,8 +472,8 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 				       bool b_reset)
 {
 	struct qed_mcp_link_state *p_link;
+	u8 max_bw, min_bw;
 	u32 status = 0;
-	u8 max_bw;
 
 	p_link = &p_hwfn->mcp_info->link_output;
 	memset(p_link, 0, sizeof(*p_link));
@@ -534,10 +534,15 @@ static void qed_mcp_handle_link_change(struct qed_hwfn *p_hwfn,
 		p_link->line_speed = 0;
 
 	max_bw = p_hwfn->mcp_info->func_info.bandwidth_max;
+	min_bw = p_hwfn->mcp_info->func_info.bandwidth_min;
 
-	/* Correct speed according to bandwidth allocation */
+	/* Max bandwidth configuration */
 	__qed_configure_pf_max_bandwidth(p_hwfn, p_ptt, p_link, max_bw);
 
+	/* Min bandwidth configuration */
+	__qed_configure_pf_min_bandwidth(p_hwfn, p_ptt, p_link, min_bw);
+	qed_configure_vp_wfq_on_link_change(p_hwfn->cdev, p_link->min_pf_rate);
+
 	p_link->an = !!(status & LINK_STATUS_AUTO_NEGOTIATE_ENABLED);
 	p_link->an_complete = !!(status &
 				 LINK_STATUS_AUTO_NEGOTIATE_COMPLETE);
@@ -710,6 +715,7 @@ static void qed_mcp_update_bw(struct qed_hwfn *p_hwfn,
 
 	p_info = &p_hwfn->mcp_info->func_info;
 
+	qed_configure_pf_min_bandwidth(p_hwfn->cdev, p_info->bandwidth_min);
 	qed_configure_pf_max_bandwidth(p_hwfn->cdev, p_info->bandwidth_max);
 
 	/* Acknowledge the MFW */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 29a51ad..608bcb2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -40,6 +40,8 @@ struct qed_mcp_link_capabilities {
 struct qed_mcp_link_state {
 	bool    link_up;
 
+	u32	min_pf_rate;
+
 	/* Actual link speed in Mb/s */
 	u32	line_speed;
 
@@ -394,9 +396,14 @@ int qed_mcp_reset(struct qed_hwfn *p_hwfn,
  * @return true iff MFW is running and mcp_info is initialized
  */
 bool qed_mcp_is_init(struct qed_hwfn *p_hwfn);
+int qed_configure_pf_min_bandwidth(struct qed_dev *cdev, u8 min_bw);
 int qed_configure_pf_max_bandwidth(struct qed_dev *cdev, u8 max_bw);
 int __qed_configure_pf_max_bandwidth(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt,
 				     struct qed_mcp_link_state *p_link,
 				     u8 max_bw);
+int __qed_configure_pf_min_bandwidth(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt,
+				     struct qed_mcp_link_state *p_link,
+				     u8 min_bw);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index d2f5730..bf4d7cc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -458,5 +458,6 @@
 #define PBF_REG_NGE_COMP_VER			0xd80524UL
 #define PRS_REG_NGE_COMP_VER			0x1f0878UL
 
+#define QM_REG_WFQPFWEIGHT	0x2f4e80UL
 #define QM_REG_WFQVPWEIGHT	0x2fa000UL
 #endif
-- 
2.7.2
