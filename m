From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/3] qed: Add vport WFQ configuration APIs
Date: Tue, 26 Apr 2016 10:56:08 -0400
Message-ID: <1461682570-745-2-git-send-email-manish.chopra@qlogic.com>
References: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57830 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752541AbcDZPiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 11:38:14 -0400
In-Reply-To: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds relevant APIs needed to configure WFQ
(Weighted fair queueing) values for the vports. WFQ configuration
is used per vport basis when minimum bandwidth update/configuration
is notified to the PF by the management firmware.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h              |  11 ++
 drivers/net/ethernet/qlogic/qed/qed_dev.c          | 188 ++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |   2 +
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    |  25 +++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |   1 +
 5 files changed, 223 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 33e2ed6..cceac32 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -32,6 +32,8 @@ extern const struct qed_common_ops qed_common_ops_pass;
 #define NAME_SIZE 16
 #define VER_SIZE 16
 
+#define QED_WFQ_UNIT	100
+
 /* cau states */
 enum qed_coalescing_mode {
 	QED_COAL_MODE_DISABLE,
@@ -237,6 +239,12 @@ struct qed_dmae_info {
 	struct dmae_cmd *p_dmae_cmd;
 };
 
+struct qed_wfq_data {
+	/* when feature is configured for at least 1 vport */
+	u32	min_speed;
+	bool	configured;
+};
+
 struct qed_qm_info {
 	struct init_qm_pq_params	*qm_pq_params;
 	struct init_qm_vport_params	*qm_vport_params;
@@ -257,6 +265,7 @@ struct qed_qm_info {
 	bool				vport_wfq_en;
 	u8				pf_wfq;
 	u32				pf_rl;
+	struct qed_wfq_data		*wfq_data;
 };
 
 struct storm_stats {
@@ -526,6 +535,8 @@ static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
 
 #define PURE_LB_TC 8
 
+void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate);
+
 #define QED_LEADING_HWFN(dev)   (&dev->hwfns[0])
 
 /* Other Linux specific common definitions */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index bdae5a5..28e0619 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -105,6 +105,8 @@ static void qed_qm_info_free(struct qed_hwfn *p_hwfn)
 	qm_info->qm_vport_params = NULL;
 	kfree(qm_info->qm_port_params);
 	qm_info->qm_port_params = NULL;
+	kfree(qm_info->wfq_data);
+	qm_info->wfq_data = NULL;
 }
 
 void qed_resc_free(struct qed_dev *cdev)
@@ -175,6 +177,11 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 	if (!qm_info->qm_port_params)
 		goto alloc_err;
 
+	qm_info->wfq_data = kcalloc(num_vports, sizeof(*qm_info->wfq_data),
+				    GFP_KERNEL);
+	if (!qm_info->wfq_data)
+		goto alloc_err;
+
 	vport_id = (u8)RESC_START(p_hwfn, QED_VPORT);
 
 	/* First init per-TC PQs */
@@ -221,10 +228,7 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 
 alloc_err:
 	DP_NOTICE(p_hwfn, "Failed to allocate memory for QM params\n");
-	kfree(qm_info->qm_pq_params);
-	kfree(qm_info->qm_vport_params);
-	kfree(qm_info->qm_port_params);
-
+	qed_qm_info_free(p_hwfn);
 	return -ENOMEM;
 }
 
@@ -1595,3 +1599,179 @@ int qed_fw_rss_eng(struct qed_hwfn *p_hwfn,
 
 	return 0;
 }
+
+/* Calculate final WFQ values for all vports and configure them.
+ * After this configuration each vport will have
+ * approx min rate =  min_pf_rate * (vport_wfq / QED_WFQ_UNIT)
+ */
+static void qed_configure_wfq_for_all_vports(struct qed_hwfn *p_hwfn,
+					     struct qed_ptt *p_ptt,
+					     u32 min_pf_rate)
+{
+	struct init_qm_vport_params *vport_params;
+	int i;
+
+	vport_params = p_hwfn->qm_info.qm_vport_params;
+
+	for (i = 0; i < p_hwfn->qm_info.num_vports; i++) {
+		u32 wfq_speed = p_hwfn->qm_info.wfq_data[i].min_speed;
+
+		vport_params[i].vport_wfq = (wfq_speed * QED_WFQ_UNIT) /
+						min_pf_rate;
+		qed_init_vport_wfq(p_hwfn, p_ptt,
+				   vport_params[i].first_tx_pq_id,
+				   vport_params[i].vport_wfq);
+	}
+}
+
+static void qed_init_wfq_default_param(struct qed_hwfn *p_hwfn,
+				       u32 min_pf_rate)
+
+{
+	int i;
+
+	for (i = 0; i < p_hwfn->qm_info.num_vports; i++)
+		p_hwfn->qm_info.qm_vport_params[i].vport_wfq = 1;
+}
+
+static void qed_disable_wfq_for_all_vports(struct qed_hwfn *p_hwfn,
+					   struct qed_ptt *p_ptt,
+					   u32 min_pf_rate)
+{
+	struct init_qm_vport_params *vport_params;
+	int i;
+
+	vport_params = p_hwfn->qm_info.qm_vport_params;
+
+	for (i = 0; i < p_hwfn->qm_info.num_vports; i++) {
+		qed_init_wfq_default_param(p_hwfn, min_pf_rate);
+		qed_init_vport_wfq(p_hwfn, p_ptt,
+				   vport_params[i].first_tx_pq_id,
+				   vport_params[i].vport_wfq);
+	}
+}
+
+/* This function performs several validations for WFQ
+ * configuration and required min rate for a given vport
+ * 1. req_rate must be greater than one percent of min_pf_rate.
+ * 2. req_rate should not cause other vports [not configured for WFQ explicitly]
+ *    rates to get less than one percent of min_pf_rate.
+ * 3. total_req_min_rate [all vports min rate sum] shouldn't exceed min_pf_rate.
+ */
+static int qed_init_wfq_param(struct qed_hwfn *p_hwfn,
+			      u16 vport_id, u32 req_rate,
+			      u32 min_pf_rate)
+{
+	u32 total_req_min_rate = 0, total_left_rate = 0, left_rate_per_vp = 0;
+	int non_requested_count = 0, req_count = 0, i, num_vports;
+
+	num_vports = p_hwfn->qm_info.num_vports;
+
+	/* Accounting for the vports which are configured for WFQ explicitly */
+	for (i = 0; i < num_vports; i++) {
+		u32 tmp_speed;
+
+		if ((i != vport_id) &&
+		    p_hwfn->qm_info.wfq_data[i].configured) {
+			req_count++;
+			tmp_speed = p_hwfn->qm_info.wfq_data[i].min_speed;
+			total_req_min_rate += tmp_speed;
+		}
+	}
+
+	/* Include current vport data as well */
+	req_count++;
+	total_req_min_rate += req_rate;
+	non_requested_count = num_vports - req_count;
+
+	if (req_rate < min_pf_rate / QED_WFQ_UNIT) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Vport [%d] - Requested rate[%d Mbps] is less than one percent of configured PF min rate[%d Mbps]\n",
+			   vport_id, req_rate, min_pf_rate);
+		return -EINVAL;
+	}
+
+	if (num_vports > QED_WFQ_UNIT) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Number of vports is greater than %d\n",
+			   QED_WFQ_UNIT);
+		return -EINVAL;
+	}
+
+	if (total_req_min_rate > min_pf_rate) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Total requested min rate for all vports[%d Mbps] is greater than configured PF min rate[%d Mbps]\n",
+			   total_req_min_rate, min_pf_rate);
+		return -EINVAL;
+	}
+
+	total_left_rate	= min_pf_rate - total_req_min_rate;
+
+	left_rate_per_vp = total_left_rate / non_requested_count;
+	if (left_rate_per_vp <  min_pf_rate / QED_WFQ_UNIT) {
+		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
+			   "Non WFQ configured vports rate [%d Mbps] is less than one percent of configured PF min rate[%d Mbps]\n",
+			   left_rate_per_vp, min_pf_rate);
+		return -EINVAL;
+	}
+
+	p_hwfn->qm_info.wfq_data[vport_id].min_speed = req_rate;
+	p_hwfn->qm_info.wfq_data[vport_id].configured = true;
+
+	for (i = 0; i < num_vports; i++) {
+		if (p_hwfn->qm_info.wfq_data[i].configured)
+			continue;
+
+		p_hwfn->qm_info.wfq_data[i].min_speed = left_rate_per_vp;
+	}
+
+	return 0;
+}
+
+static int __qed_configure_vp_wfq_on_link_change(struct qed_hwfn *p_hwfn,
+						 struct qed_ptt *p_ptt,
+						 u32 min_pf_rate)
+{
+	bool use_wfq = false;
+	int rc = 0;
+	u16 i;
+
+	/* Validate all pre configured vports for wfq */
+	for (i = 0; i < p_hwfn->qm_info.num_vports; i++) {
+		u32 rate;
+
+		if (!p_hwfn->qm_info.wfq_data[i].configured)
+			continue;
+
+		rate = p_hwfn->qm_info.wfq_data[i].min_speed;
+		use_wfq = true;
+
+		rc = qed_init_wfq_param(p_hwfn, i, rate, min_pf_rate);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "WFQ validation failed while configuring min rate\n");
+			break;
+		}
+	}
+
+	if (!rc && use_wfq)
+		qed_configure_wfq_for_all_vports(p_hwfn, p_ptt, min_pf_rate);
+	else
+		qed_disable_wfq_for_all_vports(p_hwfn, p_ptt, min_pf_rate);
+
+	return rc;
+}
+
+/* API to configure WFQ from mcp link change */
+void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		__qed_configure_vp_wfq_on_link_change(p_hwfn,
+						      p_hwfn->p_dpc_ptt,
+						      min_pf_rate);
+	}
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 15e02ab..7d5ed0c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -5116,4 +5116,6 @@ struct hw_set_image {
 	struct hw_set_info	hw_sets[1];
 };
 
+int qed_init_vport_wfq(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+		       u16 first_tx_pq_id[NUM_OF_TCS], u16 vport_wfq);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
index 1dd5324..e646987 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -732,6 +732,31 @@ int qed_init_pf_rl(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+int qed_init_vport_wfq(struct qed_hwfn *p_hwfn,
+		       struct qed_ptt *p_ptt,
+		       u16 first_tx_pq_id[NUM_OF_TCS],
+		       u16 vport_wfq)
+{
+	u32 inc_val = QM_WFQ_INC_VAL(vport_wfq);
+	u8 tc;
+
+	if (!inc_val || inc_val > QM_WFQ_MAX_INC_VAL) {
+		DP_NOTICE(p_hwfn, "Invalid VPORT WFQ weight configuration");
+		return -1;
+	}
+
+	for (tc = 0; tc < NUM_OF_TCS; tc++) {
+		u16 vport_pq_id = first_tx_pq_id[tc];
+
+		if (vport_pq_id != QM_INVALID_PQ_ID)
+			qed_wr(p_hwfn, p_ptt,
+			       QM_REG_WFQVPWEIGHT + vport_pq_id * 4,
+			       inc_val);
+	}
+
+	return 0;
+}
+
 int qed_init_vport_rl(struct qed_hwfn *p_hwfn,
 		      struct qed_ptt *p_ptt,
 		      u8 vport_id,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 55451a4..d2f5730 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -458,4 +458,5 @@
 #define PBF_REG_NGE_COMP_VER			0xd80524UL
 #define PRS_REG_NGE_COMP_VER			0x1f0878UL
 
+#define QM_REG_WFQVPWEIGHT	0x2fa000UL
 #endif
-- 
2.7.2
