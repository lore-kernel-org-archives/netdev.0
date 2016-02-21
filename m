From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/5] qed: Change metadata needed for SPQ entries
Date: Sun, 21 Feb 2016 11:40:09 +0200
Message-ID: <1456047611-11222-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:13331 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751449AbcBURpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:45:04 -0500
In-Reply-To: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each configuration element send via ramrod requires a Slow Path Queue
entry. This slightly changes the way such an entry is configured, but
contains mostly semantic changes [where more parameters are gathered
in a sub-struct instead of being directly passed].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c          | 139 ++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |  11 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  52 ++++----
 3 files changed, 95 insertions(+), 107 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 73feaf7..8d1bc7e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -142,9 +142,9 @@ static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 			      u8 drop_ttl0_flg,
 			      u8 inner_vlan_removal_en_flg)
 {
-	struct qed_sp_init_request_params params;
 	struct vport_start_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent =  NULL;
+	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
 	u16 rx_mode = 0;
 	u8 abs_vport_id = 0;
@@ -153,16 +153,14 @@ static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 	if (rc != 0)
 		return rc;
 
-	memset(&params, 0, sizeof(params));
-	params.ramrod_data_size = sizeof(*p_ramrod);
-	params.comp_mode = QED_SPQ_MODE_EBLOCK;
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
-				 qed_spq_get_cid(p_hwfn),
-				 opaque_fid,
 				 ETH_RAMROD_VPORT_START,
-				 PROTOCOLID_ETH,
-				 &params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -362,7 +360,7 @@ qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 {
 	struct qed_rss_params *p_rss_params = p_params->rss_params;
 	struct vport_update_ramrod_data_cmn *p_cmn;
-	struct qed_sp_init_request_params sp_params;
+	struct qed_sp_init_data init_data;
 	struct vport_update_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent = NULL;
 	u8 abs_vport_id = 0;
@@ -372,17 +370,15 @@ qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	if (rc != 0)
 		return rc;
 
-	memset(&sp_params, 0, sizeof(sp_params));
-	sp_params.ramrod_data_size = sizeof(*p_ramrod);
-	sp_params.comp_mode = comp_mode;
-	sp_params.p_comp_data = p_comp_data;
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_params->opaque_fid;
+	init_data.comp_mode = comp_mode;
+	init_data.p_comp_data = p_comp_data;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
-				 qed_spq_get_cid(p_hwfn),
-				 p_params->opaque_fid,
 				 ETH_RAMROD_VPORT_UPDATE,
-				 PROTOCOLID_ETH,
-				 &sp_params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -416,8 +412,8 @@ static int qed_sp_vport_stop(struct qed_hwfn *p_hwfn,
 			     u16 opaque_fid,
 			     u8 vport_id)
 {
-	struct qed_sp_init_request_params sp_params;
 	struct vport_stop_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
 	struct qed_spq_entry *p_ent;
 	u8 abs_vport_id = 0;
 	int rc;
@@ -426,16 +422,14 @@ static int qed_sp_vport_stop(struct qed_hwfn *p_hwfn,
 	if (rc != 0)
 		return rc;
 
-	memset(&sp_params, 0, sizeof(sp_params));
-	sp_params.ramrod_data_size = sizeof(*p_ramrod);
-	sp_params.comp_mode = QED_SPQ_MODE_EBLOCK;
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
-				 qed_spq_get_cid(p_hwfn),
-				 opaque_fid,
 				 ETH_RAMROD_VPORT_STOP,
-				 PROTOCOLID_ETH,
-				 &sp_params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -514,8 +508,8 @@ qed_sp_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
 			    u16 cqe_pbl_size)
 {
 	struct rx_queue_start_ramrod_data *p_ramrod = NULL;
-	struct qed_sp_init_request_params sp_params;
 	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
 	struct qed_hw_cid_data *p_rx_cid;
 	u16 abs_rx_q_id = 0;
 	u8 abs_vport_id = 0;
@@ -540,15 +534,15 @@ qed_sp_eth_rxq_start_ramrod(struct qed_hwfn *p_hwfn,
 		   opaque_fid, cid, params->queue_id, params->vport_id,
 		   params->sb);
 
-	memset(&sp_params, 0, sizeof(params));
-	sp_params.comp_mode = QED_SPQ_MODE_EBLOCK;
-	sp_params.ramrod_data_size = sizeof(*p_ramrod);
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = cid;
+	init_data.opaque_fid = opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
-				 cid, opaque_fid,
 				 ETH_RAMROD_RX_QUEUE_START,
-				 PROTOCOLID_ETH,
-				 &sp_params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -640,21 +634,20 @@ static int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
 {
 	struct qed_hw_cid_data *p_rx_cid = &p_hwfn->p_rx_cids[rx_queue_id];
 	struct rx_queue_stop_ramrod_data *p_ramrod = NULL;
-	struct qed_sp_init_request_params sp_params;
 	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
 	u16 abs_rx_q_id = 0;
 	int rc = -EINVAL;
 
-	memset(&sp_params, 0, sizeof(sp_params));
-	sp_params.ramrod_data_size = sizeof(*p_ramrod);
-	sp_params.comp_mode = QED_SPQ_MODE_EBLOCK;
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = p_rx_cid->cid;
+	init_data.opaque_fid = p_rx_cid->opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
-				 p_rx_cid->cid,
-				 p_rx_cid->opaque_fid,
 				 ETH_RAMROD_RX_QUEUE_STOP,
-				 PROTOCOLID_ETH,
-				 &sp_params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -692,8 +685,8 @@ qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
 			    union qed_qm_pq_params *p_pq_params)
 {
 	struct tx_queue_start_ramrod_data *p_ramrod = NULL;
-	struct qed_sp_init_request_params sp_params;
 	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
 	struct qed_hw_cid_data *p_tx_cid;
 	u8 abs_vport_id;
 	int rc = -EINVAL;
@@ -708,15 +701,15 @@ qed_sp_eth_txq_start_ramrod(struct qed_hwfn  *p_hwfn,
 	if (rc)
 		return rc;
 
-	memset(&sp_params, 0, sizeof(sp_params));
-	sp_params.ramrod_data_size = sizeof(*p_ramrod);
-	sp_params.comp_mode = QED_SPQ_MODE_EBLOCK;
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = cid;
+	init_data.opaque_fid = opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
-	rc = qed_sp_init_request(p_hwfn, &p_ent, cid,
-				 opaque_fid,
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
 				 ETH_RAMROD_TX_QUEUE_START,
-				 PROTOCOLID_ETH,
-				 &sp_params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -796,20 +789,19 @@ static int qed_sp_eth_tx_queue_stop(struct qed_hwfn *p_hwfn,
 				    u16 tx_queue_id)
 {
 	struct qed_hw_cid_data *p_tx_cid = &p_hwfn->p_tx_cids[tx_queue_id];
-	struct qed_sp_init_request_params sp_params;
 	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
 
-	memset(&sp_params, 0, sizeof(sp_params));
-	sp_params.ramrod_data_size = sizeof(struct tx_queue_stop_ramrod_data);
-	sp_params.comp_mode = QED_SPQ_MODE_EBLOCK;
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = p_tx_cid->cid;
+	init_data.opaque_fid = p_tx_cid->opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
-				 p_tx_cid->cid,
-				 p_tx_cid->opaque_fid,
 				 ETH_RAMROD_TX_QUEUE_STOP,
-				 PROTOCOLID_ETH,
-				 &sp_params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -866,9 +858,9 @@ qed_filter_ucast_common(struct qed_hwfn *p_hwfn,
 {
 	u8 vport_to_add_to = 0, vport_to_remove_from = 0;
 	struct vport_filter_update_ramrod_data *p_ramrod;
-	struct qed_sp_init_request_params sp_params;
 	struct eth_filter_cmd *p_first_filter;
 	struct eth_filter_cmd *p_second_filter;
+	struct qed_sp_init_data init_data;
 	enum eth_filter_action action;
 	int rc;
 
@@ -882,17 +874,16 @@ qed_filter_ucast_common(struct qed_hwfn *p_hwfn,
 	if (rc)
 		return rc;
 
-	memset(&sp_params, 0, sizeof(sp_params));
-	sp_params.ramrod_data_size = sizeof(**pp_ramrod);
-	sp_params.comp_mode = comp_mode;
-	sp_params.p_comp_data = p_comp_data;
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = opaque_fid;
+	init_data.comp_mode = comp_mode;
+	init_data.p_comp_data = p_comp_data;
 
 	rc = qed_sp_init_request(p_hwfn, pp_ent,
-				 qed_spq_get_cid(p_hwfn),
-				 opaque_fid,
 				 ETH_RAMROD_FILTERS_UPDATE,
-				 PROTOCOLID_ETH,
-				 &sp_params);
+				 PROTOCOLID_ETH, &init_data);
 	if (rc)
 		return rc;
 
@@ -1116,8 +1107,8 @@ qed_sp_eth_filter_mcast(struct qed_hwfn *p_hwfn,
 {
 	unsigned long bins[ETH_MULTICAST_MAC_BINS_IN_REGS];
 	struct vport_update_ramrod_data *p_ramrod = NULL;
-	struct qed_sp_init_request_params sp_params;
 	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
 	u8 abs_vport_id = 0;
 	int rc, i;
 
@@ -1133,18 +1124,16 @@ qed_sp_eth_filter_mcast(struct qed_hwfn *p_hwfn,
 			return rc;
 	}
 
-	memset(&sp_params, 0, sizeof(sp_params));
-	sp_params.ramrod_data_size = sizeof(*p_ramrod);
-	sp_params.comp_mode = comp_mode;
-	sp_params.p_comp_data = p_comp_data;
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = comp_mode;
+	init_data.p_comp_data = p_comp_data;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
-				 qed_spq_get_cid(p_hwfn),
-				 p_hwfn->hw_info.opaque_fid,
 				 ETH_RAMROD_VPORT_UPDATE,
-				 PROTOCOLID_ETH,
-				 &sp_params);
-
+				 PROTOCOLID_ETH, &init_data);
 	if (rc) {
 		DP_ERR(p_hwfn, "Multi-cast command failed %d\n", rc);
 		return rc;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index 8a83609..d39f914 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -311,19 +311,20 @@ void qed_consq_free(struct qed_hwfn *p_hwfn,
 #define QED_SP_EQ_COMPLETION  0x01
 #define QED_SP_CQE_COMPLETION 0x02
 
-struct qed_sp_init_request_params {
-	size_t			ramrod_data_size;
+struct qed_sp_init_data {
+	u32			cid;
+	u16			opaque_fid;
+
+	/* Information regarding operation upon sending & completion */
 	enum spq_mode		comp_mode;
 	struct qed_spq_comp_cb *p_comp_data;
 };
 
 int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 			struct qed_spq_entry **pp_ent,
-			u32 cid,
-			u16 opaque_fid,
 			u8 cmd,
 			u8 protocol,
-			struct qed_sp_init_request_params *p_params);
+			struct qed_sp_init_data *p_data);
 
 /**
  * @brief qed_sp_pf_start - PF Function Start Ramrod
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 33090f6..e271ef9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -23,15 +23,13 @@
 
 int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 			struct qed_spq_entry **pp_ent,
-			u32 cid,
-			u16 opaque_fid,
 			u8 cmd,
 			u8 protocol,
-			struct qed_sp_init_request_params *p_params)
+			struct qed_sp_init_data *p_data)
 {
-	int rc = -EINVAL;
+	u32 opaque_cid = p_data->opaque_fid << 16 | p_data->cid;
 	struct qed_spq_entry *p_ent = NULL;
-	u32 opaque_cid = opaque_fid << 16 | cid;
+	int rc;
 
 	if (!pp_ent)
 		return -ENOMEM;
@@ -48,7 +46,7 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 	p_ent->elem.hdr.protocol_id	= protocol;
 
 	p_ent->priority		= QED_SPQ_PRIORITY_NORMAL;
-	p_ent->comp_mode	= p_params->comp_mode;
+	p_ent->comp_mode	= p_data->comp_mode;
 	p_ent->comp_done.done	= 0;
 
 	switch (p_ent->comp_mode) {
@@ -57,17 +55,17 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 		break;
 
 	case QED_SPQ_MODE_BLOCK:
-		if (!p_params->p_comp_data)
+		if (!p_data->p_comp_data)
 			return -EINVAL;
 
-		p_ent->comp_cb.cookie = p_params->p_comp_data->cookie;
+		p_ent->comp_cb.cookie = p_data->p_comp_data->cookie;
 		break;
 
 	case QED_SPQ_MODE_CB:
-		if (!p_params->p_comp_data)
+		if (!p_data->p_comp_data)
 			p_ent->comp_cb.function = NULL;
 		else
-			p_ent->comp_cb = *p_params->p_comp_data;
+			p_ent->comp_cb = *p_data->p_comp_data;
 		break;
 
 	default:
@@ -83,8 +81,8 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 		   D_TRINE(p_ent->comp_mode, QED_SPQ_MODE_EBLOCK,
 			   QED_SPQ_MODE_BLOCK, "MODE_EBLOCK", "MODE_BLOCK",
 			   "MODE_CB"));
-	if (p_params->ramrod_data_size)
-		memset(&p_ent->ramrod, 0, p_params->ramrod_data_size);
+
+	memset(&p_ent->ramrod, 0, sizeof(p_ent->ramrod));
 
 	return 0;
 }
@@ -92,28 +90,26 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 		    enum qed_mf_mode mode)
 {
-	struct qed_sp_init_request_params params;
 	struct pf_start_ramrod_data *p_ramrod = NULL;
 	u16 sb = qed_int_get_sp_sb_id(p_hwfn);
 	u8 sb_index = p_hwfn->p_eq->eq_sb_index;
 	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
 
 	/* update initial eq producer */
 	qed_eq_prod_update(p_hwfn,
 			   qed_chain_get_prod_idx(&p_hwfn->p_eq->chain));
 
-	memset(&params, 0, sizeof(params));
-	params.ramrod_data_size = sizeof(*p_ramrod);
-	params.comp_mode = QED_SPQ_MODE_EBLOCK;
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
-	rc = qed_sp_init_request(p_hwfn,
-				 &p_ent,
-				 qed_spq_get_cid(p_hwfn),
-				 p_hwfn->hw_info.opaque_fid,
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
 				 COMMON_RAMROD_PF_START,
 				 PROTOCOLID_COMMON,
-				 &params);
+				 &init_data);
 	if (rc)
 		return rc;
 
@@ -163,17 +159,19 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 
 int qed_sp_pf_stop(struct qed_hwfn *p_hwfn)
 {
-	struct qed_sp_init_request_params params;
 	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
 
-	memset(&params, 0, sizeof(params));
-	params.comp_mode = QED_SPQ_MODE_EBLOCK;
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
-	rc = qed_sp_init_request(p_hwfn, &p_ent, qed_spq_get_cid(p_hwfn),
-				 p_hwfn->hw_info.opaque_fid,
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
 				 COMMON_RAMROD_PF_STOP, PROTOCOLID_COMMON,
-				 &params);
+				 &init_data);
 	if (rc)
 		return rc;
 
-- 
1.9.3
