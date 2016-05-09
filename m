From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 07/14] qed: Align TLVs
Date: Mon, 9 May 2016 16:19:16 +0300
Message-ID: <1462799963-23547-8-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:15991 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753340AbcEINUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:20:19 -0400
In-Reply-To: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the VF infrastructure is supposed to offer backward/forward
compatibility, the various types associated with VF<->PF communication
should be aligned across all various platforms that support IOV
on our family of adapters.

This adds a couple of currently missing values, specifically aligning
the enum for the various TLVs possible in the communication between them.

It then adds the PF implementation for some of those missing VF requests.
This support isn't really necessary for the Linux VF as those VFs aren't
requiring it [at least today], but are required by VFs running on other
OSes. LRO is an example of one such configuration.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c    |  92 ++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_l2.h    |  52 +++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 169 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |   4 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c    |   6 +
 drivers/net/ethernet/qlogic/qed/qed_vf.h    |  54 ++++++++-
 6 files changed, 375 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 9f88f2f..80f0b85 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -265,6 +265,38 @@ qed_sp_update_accept_mode(struct qed_hwfn *p_hwfn,
 }
 
 static void
+qed_sp_vport_update_sge_tpa(struct qed_hwfn *p_hwfn,
+			    struct vport_update_ramrod_data *p_ramrod,
+			    struct qed_sge_tpa_params *p_params)
+{
+	struct eth_vport_tpa_param *p_tpa;
+
+	if (!p_params) {
+		p_ramrod->common.update_tpa_param_flg = 0;
+		p_ramrod->common.update_tpa_en_flg = 0;
+		p_ramrod->common.update_tpa_param_flg = 0;
+		return;
+	}
+
+	p_ramrod->common.update_tpa_en_flg = p_params->update_tpa_en_flg;
+	p_tpa = &p_ramrod->tpa_param;
+	p_tpa->tpa_ipv4_en_flg = p_params->tpa_ipv4_en_flg;
+	p_tpa->tpa_ipv6_en_flg = p_params->tpa_ipv6_en_flg;
+	p_tpa->tpa_ipv4_tunn_en_flg = p_params->tpa_ipv4_tunn_en_flg;
+	p_tpa->tpa_ipv6_tunn_en_flg = p_params->tpa_ipv6_tunn_en_flg;
+
+	p_ramrod->common.update_tpa_param_flg = p_params->update_tpa_param_flg;
+	p_tpa->max_buff_num = p_params->max_buffers_per_cqe;
+	p_tpa->tpa_pkt_split_flg = p_params->tpa_pkt_split_flg;
+	p_tpa->tpa_hdr_data_split_flg = p_params->tpa_hdr_data_split_flg;
+	p_tpa->tpa_gro_consistent_flg = p_params->tpa_gro_consistent_flg;
+	p_tpa->tpa_max_aggs_num = p_params->tpa_max_aggs_num;
+	p_tpa->tpa_max_size = p_params->tpa_max_size;
+	p_tpa->tpa_min_size_to_start = p_params->tpa_min_size_to_start;
+	p_tpa->tpa_min_size_to_cont = p_params->tpa_min_size_to_cont;
+}
+
+static void
 qed_sp_update_mcast_bin(struct qed_hwfn *p_hwfn,
 			struct vport_update_ramrod_data *p_ramrod,
 			struct qed_sp_vport_update_params *p_params)
@@ -295,7 +327,7 @@ int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	struct qed_sp_init_data init_data;
 	struct vport_update_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent = NULL;
-	u8 abs_vport_id = 0;
+	u8 abs_vport_id = 0, val;
 	int rc = -EINVAL;
 
 	if (IS_VF(p_hwfn->cdev)) {
@@ -331,6 +363,13 @@ int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	p_cmn->accept_any_vlan = p_params->accept_any_vlan;
 	p_cmn->update_accept_any_vlan_flg =
 			p_params->update_accept_any_vlan_flg;
+
+	p_cmn->inner_vlan_removal_en = p_params->inner_vlan_removal_flg;
+	val = p_params->update_inner_vlan_removal_flg;
+	p_cmn->update_inner_vlan_removal_en_flg = val;
+	p_ramrod->common.tx_switching_en = p_params->tx_switching_flg;
+	p_cmn->update_tx_switching_en_flg = p_params->update_tx_switching_flg;
+
 	rc = qed_sp_vport_update_rss(p_hwfn, p_ramrod, p_rss_params);
 	if (rc) {
 		/* Return spq entry which is taken in qed_sp_init_request()*/
@@ -342,6 +381,7 @@ int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	qed_sp_update_mcast_bin(p_hwfn, p_ramrod, p_params);
 
 	qed_sp_update_accept_mode(p_hwfn, p_ramrod, p_params->accept_flags);
+	qed_sp_vport_update_sge_tpa(p_hwfn, p_ramrod, p_params->sge_tpa_params);
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
@@ -590,6 +630,56 @@ qed_sp_eth_rx_queue_start(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+int qed_sp_eth_rx_queues_update(struct qed_hwfn *p_hwfn,
+				u16 rx_queue_id,
+				u8 num_rxqs,
+				u8 complete_cqe_flg,
+				u8 complete_event_flg,
+				enum spq_mode comp_mode,
+				struct qed_spq_comp_cb *p_comp_data)
+{
+	struct rx_queue_update_ramrod_data *p_ramrod = NULL;
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	struct qed_hw_cid_data *p_rx_cid;
+	u16 qid, abs_rx_q_id = 0;
+	int rc = -EINVAL;
+	u8 i;
+
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.comp_mode = comp_mode;
+	init_data.p_comp_data = p_comp_data;
+
+	for (i = 0; i < num_rxqs; i++) {
+		qid = rx_queue_id + i;
+		p_rx_cid = &p_hwfn->p_rx_cids[qid];
+
+		/* Get SPQ entry */
+		init_data.cid = p_rx_cid->cid;
+		init_data.opaque_fid = p_rx_cid->opaque_fid;
+
+		rc = qed_sp_init_request(p_hwfn, &p_ent,
+					 ETH_RAMROD_RX_QUEUE_UPDATE,
+					 PROTOCOLID_ETH, &init_data);
+		if (rc)
+			return rc;
+
+		p_ramrod = &p_ent->ramrod.rx_queue_update;
+
+		qed_fw_vport(p_hwfn, p_rx_cid->vport_id, &p_ramrod->vport_id);
+		qed_fw_l2_queue(p_hwfn, qid, &abs_rx_q_id);
+		p_ramrod->rx_queue_id = cpu_to_le16(abs_rx_q_id);
+		p_ramrod->complete_cqe_flg = complete_cqe_flg;
+		p_ramrod->complete_event_flg = complete_event_flg;
+
+		rc = qed_spq_post(p_hwfn, p_ent, NULL);
+		if (rc)
+			return rc;
+	}
+
+	return rc;
+}
+
 int qed_sp_eth_rx_queue_stop(struct qed_hwfn *p_hwfn,
 			     u16 rx_queue_id,
 			     bool eq_completion_only, bool cqe_completion)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index 3b65a45..f9e677a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -16,6 +16,25 @@
 #include "qed_hw.h"
 #include "qed_sp.h"
 
+struct qed_sge_tpa_params {
+	u8 max_buffers_per_cqe;
+
+	u8 update_tpa_en_flg;
+	u8 tpa_ipv4_en_flg;
+	u8 tpa_ipv6_en_flg;
+	u8 tpa_ipv4_tunn_en_flg;
+	u8 tpa_ipv6_tunn_en_flg;
+
+	u8 update_tpa_param_flg;
+	u8 tpa_pkt_split_flg;
+	u8 tpa_hdr_data_split_flg;
+	u8 tpa_gro_consistent_flg;
+	u8 tpa_max_aggs_num;
+	u16 tpa_max_size;
+	u16 tpa_min_size_to_start;
+	u16 tpa_min_size_to_cont;
+};
+
 enum qed_filter_opcode {
 	QED_FILTER_ADD,
 	QED_FILTER_REMOVE,
@@ -119,12 +138,17 @@ struct qed_sp_vport_update_params {
 	u8				vport_active_rx_flg;
 	u8				update_vport_active_tx_flg;
 	u8				vport_active_tx_flg;
+	u8				update_inner_vlan_removal_flg;
+	u8				inner_vlan_removal_flg;
+	u8				update_tx_switching_flg;
+	u8				tx_switching_flg;
 	u8				update_approx_mcast_flg;
 	u8				update_accept_any_vlan_flg;
 	u8				accept_any_vlan;
 	unsigned long			bins[8];
 	struct qed_rss_params		*rss_params;
 	struct qed_filter_accept_flags	accept_flags;
+	struct qed_sge_tpa_params	*sge_tpa_params;
 };
 
 int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
@@ -152,6 +176,34 @@ int qed_sp_eth_filter_ucast(struct qed_hwfn *p_hwfn,
 			    enum spq_mode comp_mode,
 			    struct qed_spq_comp_cb *p_comp_data);
 
+/**
+ * @brief qed_sp_rx_eth_queues_update -
+ *
+ * This ramrod updates an RX queue. It is used for setting the active state
+ * of the queue and updating the TPA and SGE parameters.
+ *
+ * @note At the moment - only used by non-linux VFs.
+ *
+ * @param p_hwfn
+ * @param rx_queue_id		RX Queue ID
+ * @param num_rxqs		Allow to update multiple rx
+ *				queues, from rx_queue_id to
+ *				(rx_queue_id + num_rxqs)
+ * @param complete_cqe_flg	Post completion to the CQE Ring if set
+ * @param complete_event_flg	Post completion to the Event Ring if set
+ *
+ * @return int
+ */
+
+int
+qed_sp_eth_rx_queues_update(struct qed_hwfn *p_hwfn,
+			    u16 rx_queue_id,
+			    u8 num_rxqs,
+			    u8 complete_cqe_flg,
+			    u8 complete_event_flg,
+			    enum spq_mode comp_mode,
+			    struct qed_spq_comp_cb *p_comp_data);
+
 int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
 			   struct qed_sp_vport_start_params *p_params);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index f6540c0..29a53dd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -961,12 +961,20 @@ static u16 qed_iov_vport_to_tlv(struct qed_hwfn *p_hwfn,
 	switch (flag) {
 	case QED_IOV_VP_UPDATE_ACTIVATE:
 		return CHANNEL_TLV_VPORT_UPDATE_ACTIVATE;
+	case QED_IOV_VP_UPDATE_VLAN_STRIP:
+		return CHANNEL_TLV_VPORT_UPDATE_VLAN_STRIP;
+	case QED_IOV_VP_UPDATE_TX_SWITCH:
+		return CHANNEL_TLV_VPORT_UPDATE_TX_SWITCH;
 	case QED_IOV_VP_UPDATE_MCAST:
 		return CHANNEL_TLV_VPORT_UPDATE_MCAST;
 	case QED_IOV_VP_UPDATE_ACCEPT_PARAM:
 		return CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM;
 	case QED_IOV_VP_UPDATE_RSS:
 		return CHANNEL_TLV_VPORT_UPDATE_RSS;
+	case QED_IOV_VP_UPDATE_ACCEPT_ANY_VLAN:
+		return CHANNEL_TLV_VPORT_UPDATE_ACCEPT_ANY_VLAN;
+	case QED_IOV_VP_UPDATE_SGE_TPA:
+		return CHANNEL_TLV_VPORT_UPDATE_SGE_TPA;
 	default:
 		return 0;
 	}
@@ -1516,6 +1524,51 @@ static void qed_iov_vf_mbx_stop_txqs(struct qed_hwfn *p_hwfn,
 			     length, status);
 }
 
+static void qed_iov_vf_mbx_update_rxqs(struct qed_hwfn *p_hwfn,
+				       struct qed_ptt *p_ptt,
+				       struct qed_vf_info *vf)
+{
+	u16 length = sizeof(struct pfvf_def_resp_tlv);
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct vfpf_update_rxq_tlv *req;
+	u8 status = PFVF_STATUS_SUCCESS;
+	u8 complete_event_flg;
+	u8 complete_cqe_flg;
+	u16 qid;
+	int rc;
+	u8 i;
+
+	req = &mbx->req_virt->update_rxq;
+	complete_cqe_flg = !!(req->flags & VFPF_RXQ_UPD_COMPLETE_CQE_FLAG);
+	complete_event_flg = !!(req->flags & VFPF_RXQ_UPD_COMPLETE_EVENT_FLAG);
+
+	for (i = 0; i < req->num_rxqs; i++) {
+		qid = req->rx_qid + i;
+
+		if (!vf->vf_queues[qid].rxq_active) {
+			DP_NOTICE(p_hwfn, "VF rx_qid = %d isn`t active!\n",
+				  qid);
+			status = PFVF_STATUS_FAILURE;
+			break;
+		}
+
+		rc = qed_sp_eth_rx_queues_update(p_hwfn,
+						 vf->vf_queues[qid].fw_rx_qid,
+						 1,
+						 complete_cqe_flg,
+						 complete_event_flg,
+						 QED_SPQ_MODE_EBLOCK, NULL);
+
+		if (rc) {
+			status = PFVF_STATUS_FAILURE;
+			break;
+		}
+	}
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_UPDATE_RXQ,
+			     length, status);
+}
+
 void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
 			       void *p_tlvs_list, u16 req_type)
 {
@@ -1568,6 +1621,45 @@ qed_iov_vp_update_act_param(struct qed_hwfn *p_hwfn,
 }
 
 static void
+qed_iov_vp_update_vlan_param(struct qed_hwfn *p_hwfn,
+			     struct qed_sp_vport_update_params *p_data,
+			     struct qed_vf_info *p_vf,
+			     struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct vfpf_vport_update_vlan_strip_tlv *p_vlan_tlv;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_VLAN_STRIP;
+
+	p_vlan_tlv = (struct vfpf_vport_update_vlan_strip_tlv *)
+		     qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt, tlv);
+	if (!p_vlan_tlv)
+		return;
+
+	p_data->update_inner_vlan_removal_flg = 1;
+	p_data->inner_vlan_removal_flg = p_vlan_tlv->remove_vlan;
+
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_VLAN_STRIP;
+}
+
+static void
+qed_iov_vp_update_tx_switch(struct qed_hwfn *p_hwfn,
+			    struct qed_sp_vport_update_params *p_data,
+			    struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct vfpf_vport_update_tx_switch_tlv *p_tx_switch_tlv;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_TX_SWITCH;
+
+	p_tx_switch_tlv = (struct vfpf_vport_update_tx_switch_tlv *)
+			  qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt,
+						   tlv);
+	if (!p_tx_switch_tlv)
+		return;
+
+	p_data->update_tx_switching_flg = 1;
+	p_data->tx_switching_flg = p_tx_switch_tlv->tx_switching;
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_TX_SWITCH;
+}
+
+static void
 qed_iov_vp_update_mcast_bin_param(struct qed_hwfn *p_hwfn,
 				  struct qed_sp_vport_update_params *p_data,
 				  struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
@@ -1608,6 +1700,26 @@ qed_iov_vp_update_accept_flag(struct qed_hwfn *p_hwfn,
 }
 
 static void
+qed_iov_vp_update_accept_any_vlan(struct qed_hwfn *p_hwfn,
+				  struct qed_sp_vport_update_params *p_data,
+				  struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct vfpf_vport_update_accept_any_vlan_tlv *p_accept_any_vlan;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_ACCEPT_ANY_VLAN;
+
+	p_accept_any_vlan = (struct vfpf_vport_update_accept_any_vlan_tlv *)
+			    qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt,
+						     tlv);
+	if (!p_accept_any_vlan)
+		return;
+
+	p_data->accept_any_vlan = p_accept_any_vlan->accept_any_vlan;
+	p_data->update_accept_any_vlan_flg =
+		    p_accept_any_vlan->update_accept_any_vlan_flg;
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_ACCEPT_ANY_VLAN;
+}
+
+static void
 qed_iov_vp_update_rss_param(struct qed_hwfn *p_hwfn,
 			    struct qed_vf_info *vf,
 			    struct qed_sp_vport_update_params *p_data,
@@ -1671,12 +1783,61 @@ qed_iov_vp_update_rss_param(struct qed_hwfn *p_hwfn,
 	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_RSS;
 }
 
+static void
+qed_iov_vp_update_sge_tpa_param(struct qed_hwfn *p_hwfn,
+				struct qed_vf_info *vf,
+				struct qed_sp_vport_update_params *p_data,
+				struct qed_sge_tpa_params *p_sge_tpa,
+				struct qed_iov_vf_mbx *p_mbx, u16 *tlvs_mask)
+{
+	struct vfpf_vport_update_sge_tpa_tlv *p_sge_tpa_tlv;
+	u16 tlv = CHANNEL_TLV_VPORT_UPDATE_SGE_TPA;
+
+	p_sge_tpa_tlv = (struct vfpf_vport_update_sge_tpa_tlv *)
+	    qed_iov_search_list_tlvs(p_hwfn, p_mbx->req_virt, tlv);
+
+	if (!p_sge_tpa_tlv) {
+		p_data->sge_tpa_params = NULL;
+		return;
+	}
+
+	memset(p_sge_tpa, 0, sizeof(struct qed_sge_tpa_params));
+
+	p_sge_tpa->update_tpa_en_flg =
+	    !!(p_sge_tpa_tlv->update_sge_tpa_flags & VFPF_UPDATE_TPA_EN_FLAG);
+	p_sge_tpa->update_tpa_param_flg =
+	    !!(p_sge_tpa_tlv->update_sge_tpa_flags &
+		VFPF_UPDATE_TPA_PARAM_FLAG);
+
+	p_sge_tpa->tpa_ipv4_en_flg =
+	    !!(p_sge_tpa_tlv->sge_tpa_flags & VFPF_TPA_IPV4_EN_FLAG);
+	p_sge_tpa->tpa_ipv6_en_flg =
+	    !!(p_sge_tpa_tlv->sge_tpa_flags & VFPF_TPA_IPV6_EN_FLAG);
+	p_sge_tpa->tpa_pkt_split_flg =
+	    !!(p_sge_tpa_tlv->sge_tpa_flags & VFPF_TPA_PKT_SPLIT_FLAG);
+	p_sge_tpa->tpa_hdr_data_split_flg =
+	    !!(p_sge_tpa_tlv->sge_tpa_flags & VFPF_TPA_HDR_DATA_SPLIT_FLAG);
+	p_sge_tpa->tpa_gro_consistent_flg =
+	    !!(p_sge_tpa_tlv->sge_tpa_flags & VFPF_TPA_GRO_CONSIST_FLAG);
+
+	p_sge_tpa->tpa_max_aggs_num = p_sge_tpa_tlv->tpa_max_aggs_num;
+	p_sge_tpa->tpa_max_size = p_sge_tpa_tlv->tpa_max_size;
+	p_sge_tpa->tpa_min_size_to_start = p_sge_tpa_tlv->tpa_min_size_to_start;
+	p_sge_tpa->tpa_min_size_to_cont = p_sge_tpa_tlv->tpa_min_size_to_cont;
+	p_sge_tpa->max_buffers_per_cqe = p_sge_tpa_tlv->max_buffers_per_cqe;
+
+	p_data->sge_tpa_params = p_sge_tpa;
+
+	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_SGE_TPA;
+}
+
 static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 					struct qed_ptt *p_ptt,
 					struct qed_vf_info *vf)
 {
 	struct qed_sp_vport_update_params params;
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct qed_sge_tpa_params sge_tpa_params;
 	struct qed_rss_params rss_params;
 	u8 status = PFVF_STATUS_SUCCESS;
 	u16 tlvs_mask = 0;
@@ -1692,10 +1853,15 @@ static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 	 * from VF in struct qed_sp_vport_update_params.
 	 */
 	qed_iov_vp_update_act_param(p_hwfn, &params, mbx, &tlvs_mask);
+	qed_iov_vp_update_vlan_param(p_hwfn, &params, vf, mbx, &tlvs_mask);
+	qed_iov_vp_update_tx_switch(p_hwfn, &params, mbx, &tlvs_mask);
 	qed_iov_vp_update_mcast_bin_param(p_hwfn, &params, mbx, &tlvs_mask);
 	qed_iov_vp_update_accept_flag(p_hwfn, &params, mbx, &tlvs_mask);
 	qed_iov_vp_update_rss_param(p_hwfn, vf, &params, &rss_params,
 				    mbx, &tlvs_mask);
+	qed_iov_vp_update_accept_any_vlan(p_hwfn, &params, mbx, &tlvs_mask);
+	qed_iov_vp_update_sge_tpa_param(p_hwfn, vf, &params,
+					&sge_tpa_params, mbx, &tlvs_mask);
 
 	/* Just log a message if there is no single extended tlv in buffer.
 	 * When all features of vport update ramrod would be requested by VF
@@ -2144,6 +2310,9 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 		case CHANNEL_TLV_STOP_TXQS:
 			qed_iov_vf_mbx_stop_txqs(p_hwfn, p_ptt, p_vf);
 			break;
+		case CHANNEL_TLV_UPDATE_RXQ:
+			qed_iov_vf_mbx_update_rxqs(p_hwfn, p_ptt, p_vf);
+			break;
 		case CHANNEL_TLV_VPORT_UPDATE:
 			qed_iov_vf_mbx_vport_update(p_hwfn, p_ptt, p_vf);
 			break;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 0f5689b..2c94b44 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -26,9 +26,13 @@
 
 enum qed_iov_vport_update_flag {
 	QED_IOV_VP_UPDATE_ACTIVATE,
+	QED_IOV_VP_UPDATE_VLAN_STRIP,
+	QED_IOV_VP_UPDATE_TX_SWITCH,
 	QED_IOV_VP_UPDATE_MCAST,
 	QED_IOV_VP_UPDATE_ACCEPT_PARAM,
 	QED_IOV_VP_UPDATE_RSS,
+	QED_IOV_VP_UPDATE_ACCEPT_ANY_VLAN,
+	QED_IOV_VP_UPDATE_SGE_TPA,
 	QED_IOV_VP_UPDATE_MAX,
 };
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 05b3cca..e788954 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -543,6 +543,10 @@ qed_vf_handle_vp_update_is_needed(struct qed_hwfn *p_hwfn,
 	case CHANNEL_TLV_VPORT_UPDATE_ACTIVATE:
 		return !!(p_data->update_vport_active_rx_flg ||
 			  p_data->update_vport_active_tx_flg);
+	case CHANNEL_TLV_VPORT_UPDATE_TX_SWITCH:
+		return !!p_data->update_tx_switching_flg;
+	case CHANNEL_TLV_VPORT_UPDATE_VLAN_STRIP:
+		return !!p_data->update_inner_vlan_removal_flg;
 	case CHANNEL_TLV_VPORT_UPDATE_MCAST:
 		return !!p_data->update_approx_mcast_flg;
 	case CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM:
@@ -550,6 +554,8 @@ qed_vf_handle_vp_update_is_needed(struct qed_hwfn *p_hwfn,
 			  p_data->accept_flags.update_tx_mode_config);
 	case CHANNEL_TLV_VPORT_UPDATE_RSS:
 		return !!p_data->rss_params;
+	case CHANNEL_TLV_VPORT_UPDATE_SGE_TPA:
+		return !!p_data->sge_tpa_params;
 	default:
 		DP_INFO(p_hwfn, "Unexpected vport-update TLV[%d]\n",
 			tlv);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 2d24965..f2b46fd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -311,6 +311,18 @@ struct vfpf_vport_update_activate_tlv {
 	u8 active_tx;
 };
 
+struct vfpf_vport_update_tx_switch_tlv {
+	struct channel_tlv tl;
+	u8 tx_switching;
+	u8 padding[3];
+};
+
+struct vfpf_vport_update_vlan_strip_tlv {
+	struct channel_tlv tl;
+	u8 remove_vlan;
+	u8 padding[3];
+};
+
 struct vfpf_vport_update_mcast_bin_tlv {
 	struct channel_tlv tl;
 	u8 padding[4];
@@ -326,6 +338,40 @@ struct vfpf_vport_update_accept_param_tlv {
 	u8 tx_accept_filter;
 };
 
+struct vfpf_vport_update_accept_any_vlan_tlv {
+	struct channel_tlv tl;
+	u8 update_accept_any_vlan_flg;
+	u8 accept_any_vlan;
+
+	u8 padding[2];
+};
+
+struct vfpf_vport_update_sge_tpa_tlv {
+	struct channel_tlv tl;
+
+	u16 sge_tpa_flags;
+#define VFPF_TPA_IPV4_EN_FLAG		BIT(0)
+#define VFPF_TPA_IPV6_EN_FLAG		BIT(1)
+#define VFPF_TPA_PKT_SPLIT_FLAG		BIT(2)
+#define VFPF_TPA_HDR_DATA_SPLIT_FLAG	BIT(3)
+#define VFPF_TPA_GRO_CONSIST_FLAG	BIT(4)
+
+	u8 update_sge_tpa_flags;
+#define VFPF_UPDATE_SGE_DEPRECATED_FLAG	BIT(0)
+#define VFPF_UPDATE_TPA_EN_FLAG		BIT(1)
+#define VFPF_UPDATE_TPA_PARAM_FLAG	BIT(2)
+
+	u8 max_buffers_per_cqe;
+
+	u16 deprecated_sge_buff_size;
+	u16 tpa_max_size;
+	u16 tpa_min_size_to_start;
+	u16 tpa_min_size_to_cont;
+
+	u8 tpa_max_aggs_num;
+	u8 padding[7];
+};
+
 /* Primary tlv as a header for various extended tlvs for
  * various functionalities in vport update ramrod.
  */
@@ -356,6 +402,7 @@ union vfpf_tlvs {
 	struct vfpf_start_txq_tlv start_txq;
 	struct vfpf_stop_rxqs_tlv stop_rxqs;
 	struct vfpf_stop_txqs_tlv stop_txqs;
+	struct vfpf_update_rxq_tlv update_rxq;
 	struct vfpf_vport_start_tlv start_vport;
 	struct vfpf_vport_update_tlv vport_update;
 	struct vfpf_ucast_filter_tlv ucast_filter;
@@ -436,21 +483,26 @@ enum {
 	CHANNEL_TLV_START_TXQ,
 	CHANNEL_TLV_STOP_RXQS,
 	CHANNEL_TLV_STOP_TXQS,
+	CHANNEL_TLV_UPDATE_RXQ,
 	CHANNEL_TLV_INT_CLEANUP,
 	CHANNEL_TLV_CLOSE,
 	CHANNEL_TLV_RELEASE,
 	CHANNEL_TLV_LIST_END,
 	CHANNEL_TLV_UCAST_FILTER,
 	CHANNEL_TLV_VPORT_UPDATE_ACTIVATE,
+	CHANNEL_TLV_VPORT_UPDATE_TX_SWITCH,
+	CHANNEL_TLV_VPORT_UPDATE_VLAN_STRIP,
 	CHANNEL_TLV_VPORT_UPDATE_MCAST,
 	CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM,
 	CHANNEL_TLV_VPORT_UPDATE_RSS,
+	CHANNEL_TLV_VPORT_UPDATE_ACCEPT_ANY_VLAN,
+	CHANNEL_TLV_VPORT_UPDATE_SGE_TPA,
 	CHANNEL_TLV_MAX,
 
 	/* Required for iterating over vport-update tlvs.
 	 * Will break in case non-sequential vport-update tlvs.
 	 */
-	CHANNEL_TLV_VPORT_UPDATE_MAX = CHANNEL_TLV_VPORT_UPDATE_RSS + 1,
+	CHANNEL_TLV_VPORT_UPDATE_MAX = CHANNEL_TLV_VPORT_UPDATE_SGE_TPA + 1,
 };
 
 /* This data is held in the qed_hwfn structure for VFs only. */
-- 
1.9.3
