From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 09/14] qed*: Support PVID configuration
Date: Wed, 11 May 2016 16:36:20 +0300
Message-ID: <1462973785-32532-10-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49909 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932545AbcEKNhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:37:11 -0400
In-Reply-To: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for PF control over the VF vlan configuration.
I.e., `ip link ... vf <x> vlan <vid>' should now be supported.

 1. <vid> != 0 => VF receives [unknowingly] only traffic tagged by
    <vid> and tags all outgoing traffic sent by VF with <vid>.
 2. <vid> == 0 ==> Remove the pvid configuration, reverting to previous.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c    |   9 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  14 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.h     |   6 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 364 ++++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.h  |  26 ++
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |  18 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.h     |  19 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c |  18 ++
 include/linux/qed/qed_iov_if.h               |   1 +
 9 files changed, 468 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 9d01a16..e75e73a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1104,9 +1104,16 @@ static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 	u8 num_funcs = p_hwfn->num_funcs_on_engine;
 	u32 *resc_num = p_hwfn->hw_info.resc_num;
 	struct qed_sb_cnt_info sb_cnt_info;
-	int i;
+	int i, max_vf_vlan_filters;
 
 	memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
+
+#ifdef CONFIG_QED_SRIOV
+	max_vf_vlan_filters = QED_ETH_MAX_VF_NUM_VLAN_FILTERS;
+#else
+	max_vf_vlan_filters = 0;
+#endif
+
 	qed_int_get_num_sbs(p_hwfn, &sb_cnt_info);
 
 	resc_num[QED_SB] = min_t(u32,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 80f0b85..7fb6b82 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -114,7 +114,8 @@ int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 					     p_params->mtu,
 					     p_params->remove_inner_vlan,
 					     p_params->tpa_mode,
-					     p_params->max_buffers_per_cqe);
+					     p_params->max_buffers_per_cqe,
+					     p_params->only_untagged);
 	}
 
 	return qed_sp_eth_vport_start(p_hwfn, p_params);
@@ -367,6 +368,16 @@ int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	p_cmn->inner_vlan_removal_en = p_params->inner_vlan_removal_flg;
 	val = p_params->update_inner_vlan_removal_flg;
 	p_cmn->update_inner_vlan_removal_en_flg = val;
+
+	p_cmn->default_vlan_en = p_params->default_vlan_enable_flg;
+	val = p_params->update_default_vlan_enable_flg;
+	p_cmn->update_default_vlan_en_flg = val;
+
+	p_cmn->default_vlan = cpu_to_le16(p_params->default_vlan);
+	p_cmn->update_default_vlan_flg = p_params->update_default_vlan_flg;
+
+	p_cmn->silent_vlan_removal_en = p_params->silent_vlan_removal_flg;
+
 	p_ramrod->common.tx_switching_en = p_params->tx_switching_flg;
 	p_cmn->update_tx_switching_en_flg = p_params->update_tx_switching_flg;
 
@@ -1702,6 +1713,7 @@ static int qed_start_vport(struct qed_dev *cdev,
 		start.tpa_mode = params->gro_enable ? QED_TPA_MODE_GRO :
 							QED_TPA_MODE_NONE;
 		start.remove_inner_vlan = params->remove_inner_vlan;
+		start.only_untagged = true;	/* untagged only */
 		start.drop_ttl0 = params->drop_ttl0;
 		start.opaque_fid = p_hwfn->hw_info.opaque_fid;
 		start.concrete_fid = p_hwfn->hw_info.concrete_fid;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index f9e677a..fad30ae 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -94,6 +94,7 @@ enum qed_tpa_mode {
 struct qed_sp_vport_start_params {
 	enum qed_tpa_mode tpa_mode;
 	bool remove_inner_vlan;
+	bool only_untagged;
 	bool drop_ttl0;
 	u8 max_buffers_per_cqe;
 	u32 concrete_fid;
@@ -140,6 +141,11 @@ struct qed_sp_vport_update_params {
 	u8				vport_active_tx_flg;
 	u8				update_inner_vlan_removal_flg;
 	u8				inner_vlan_removal_flg;
+	u8				silent_vlan_removal_flg;
+	u8				update_default_vlan_enable_flg;
+	u8				default_vlan_enable_flg;
+	u8				update_default_vlan_flg;
+	u16				default_vlan;
 	u8				update_tx_switching_flg;
 	u8				tx_switching_flg;
 	u8				update_approx_mcast_flg;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 29a53dd..77d44ba 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1075,6 +1075,7 @@ static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
 	p_vf->vport_instance = 0;
 	p_vf->num_mac_filters = 0;
 	p_vf->num_vlan_filters = 0;
+	p_vf->configured_features = 0;
 
 	/* If VF previously requested less resources, go back to default */
 	p_vf->num_rxqs = p_vf->num_sbs;
@@ -1085,6 +1086,7 @@ static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
 	for (i = 0; i < QED_MAX_VF_CHAINS_PER_PF; i++)
 		p_vf->vf_queues[i].rxq_active = 0;
 
+	memset(&p_vf->shadow_config, 0, sizeof(p_vf->shadow_config));
 	qed_iov_clean_vf(p_hwfn, p_vf->relative_vf_id);
 }
 
@@ -1232,6 +1234,149 @@ out:
 			     sizeof(struct pfvf_acquire_resp_tlv), vfpf_status);
 }
 
+static int qed_iov_reconfigure_unicast_vlan(struct qed_hwfn *p_hwfn,
+					    struct qed_vf_info *p_vf)
+{
+	struct qed_filter_ucast filter;
+	int rc = 0;
+	int i;
+
+	memset(&filter, 0, sizeof(filter));
+	filter.is_rx_filter = 1;
+	filter.is_tx_filter = 1;
+	filter.vport_to_add_to = p_vf->vport_id;
+	filter.opcode = QED_FILTER_ADD;
+
+	/* Reconfigure vlans */
+	for (i = 0; i < QED_ETH_VF_NUM_VLAN_FILTERS + 1; i++) {
+		if (!p_vf->shadow_config.vlans[i].used)
+			continue;
+
+		filter.type = QED_FILTER_VLAN;
+		filter.vlan = p_vf->shadow_config.vlans[i].vid;
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "Reconfiguring VLAN [0x%04x] for VF [%04x]\n",
+			   filter.vlan, p_vf->relative_vf_id);
+		rc = qed_sp_eth_filter_ucast(p_hwfn,
+					     p_vf->opaque_fid,
+					     &filter,
+					     QED_SPQ_MODE_CB, NULL);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "Failed to configure VLAN [%04x] to VF [%04x]\n",
+				  filter.vlan, p_vf->relative_vf_id);
+			break;
+		}
+	}
+
+	return rc;
+}
+
+static int
+qed_iov_reconfigure_unicast_shadow(struct qed_hwfn *p_hwfn,
+				   struct qed_vf_info *p_vf, u64 events)
+{
+	int rc = 0;
+
+	if ((events & (1 << VLAN_ADDR_FORCED)) &&
+	    !(p_vf->configured_features & (1 << VLAN_ADDR_FORCED)))
+		rc = qed_iov_reconfigure_unicast_vlan(p_hwfn, p_vf);
+
+	return rc;
+}
+
+static int qed_iov_configure_vport_forced(struct qed_hwfn *p_hwfn,
+					  struct qed_vf_info *p_vf, u64 events)
+{
+	int rc = 0;
+	struct qed_filter_ucast filter;
+
+	if (!p_vf->vport_instance)
+		return -EINVAL;
+
+	if (events & (1 << VLAN_ADDR_FORCED)) {
+		struct qed_sp_vport_update_params vport_update;
+		u8 removal;
+		int i;
+
+		memset(&filter, 0, sizeof(filter));
+		filter.type = QED_FILTER_VLAN;
+		filter.is_rx_filter = 1;
+		filter.is_tx_filter = 1;
+		filter.vport_to_add_to = p_vf->vport_id;
+		filter.vlan = p_vf->bulletin.p_virt->pvid;
+		filter.opcode = filter.vlan ? QED_FILTER_REPLACE :
+					      QED_FILTER_FLUSH;
+
+		/* Send the ramrod */
+		rc = qed_sp_eth_filter_ucast(p_hwfn, p_vf->opaque_fid,
+					     &filter, QED_SPQ_MODE_CB, NULL);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "PF failed to configure VLAN for VF\n");
+			return rc;
+		}
+
+		/* Update the default-vlan & silent vlan stripping */
+		memset(&vport_update, 0, sizeof(vport_update));
+		vport_update.opaque_fid = p_vf->opaque_fid;
+		vport_update.vport_id = p_vf->vport_id;
+		vport_update.update_default_vlan_enable_flg = 1;
+		vport_update.default_vlan_enable_flg = filter.vlan ? 1 : 0;
+		vport_update.update_default_vlan_flg = 1;
+		vport_update.default_vlan = filter.vlan;
+
+		vport_update.update_inner_vlan_removal_flg = 1;
+		removal = filter.vlan ? 1
+				      : p_vf->shadow_config.inner_vlan_removal;
+		vport_update.inner_vlan_removal_flg = removal;
+		vport_update.silent_vlan_removal_flg = filter.vlan ? 1 : 0;
+		rc = qed_sp_vport_update(p_hwfn,
+					 &vport_update,
+					 QED_SPQ_MODE_EBLOCK, NULL);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "PF failed to configure VF vport for vlan\n");
+			return rc;
+		}
+
+		/* Update all the Rx queues */
+		for (i = 0; i < QED_MAX_VF_CHAINS_PER_PF; i++) {
+			u16 qid;
+
+			if (!p_vf->vf_queues[i].rxq_active)
+				continue;
+
+			qid = p_vf->vf_queues[i].fw_rx_qid;
+
+			rc = qed_sp_eth_rx_queues_update(p_hwfn, qid,
+							 1, 0, 1,
+							 QED_SPQ_MODE_EBLOCK,
+							 NULL);
+			if (rc) {
+				DP_NOTICE(p_hwfn,
+					  "Failed to send Rx update fo queue[0x%04x]\n",
+					  qid);
+				return rc;
+			}
+		}
+
+		if (filter.vlan)
+			p_vf->configured_features |= 1 << VLAN_ADDR_FORCED;
+		else
+			p_vf->configured_features &= ~(1 << VLAN_ADDR_FORCED);
+	}
+
+	/* If forced features are terminated, we need to configure the shadow
+	 * configuration back again.
+	 */
+	if (events)
+		qed_iov_reconfigure_unicast_shadow(p_hwfn, p_vf, events);
+
+	return rc;
+}
+
 static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 				       struct qed_ptt *p_ptt,
 				       struct qed_vf_info *vf)
@@ -1241,6 +1386,7 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 	struct vfpf_vport_start_tlv *start;
 	u8 status = PFVF_STATUS_SUCCESS;
 	struct qed_vf_info *vf_info;
+	u64 *p_bitmap;
 	int sb_id;
 	int rc;
 
@@ -1272,10 +1418,24 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 	qed_iov_enable_vf_traffic(p_hwfn, p_ptt, vf);
 
 	vf->mtu = start->mtu;
+	vf->shadow_config.inner_vlan_removal = start->inner_vlan_removal;
+
+	/* Take into consideration configuration forced by hypervisor;
+	 * If none is configured, use the supplied VF values [for old
+	 * vfs that would still be fine, since they passed '0' as padding].
+	 */
+	p_bitmap = &vf_info->bulletin.p_virt->valid_bitmap;
+	if (!(*p_bitmap & (1 << VFPF_BULLETIN_UNTAGGED_DEFAULT_FORCED))) {
+		u8 vf_req = start->only_untagged;
+
+		vf_info->bulletin.p_virt->default_only_untagged = vf_req;
+		*p_bitmap |= 1 << VFPF_BULLETIN_UNTAGGED_DEFAULT;
+	}
 
 	params.tpa_mode = start->tpa_mode;
 	params.remove_inner_vlan = start->inner_vlan_removal;
 
+	params.only_untagged = vf_info->bulletin.p_virt->default_only_untagged;
 	params.drop_ttl0 = false;
 	params.concrete_fid = vf->concrete_fid;
 	params.opaque_fid = vf->opaque_fid;
@@ -1290,6 +1450,9 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 		status = PFVF_STATUS_FAILURE;
 	} else {
 		vf->vport_instance++;
+
+		/* Force configuration if needed on the newly opened vport */
+		qed_iov_configure_vport_forced(p_hwfn, vf, *p_bitmap);
 	}
 	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_VPORT_START,
 			     sizeof(struct pfvf_def_resp_tlv), status);
@@ -1311,6 +1474,10 @@ static void qed_iov_vf_mbx_stop_vport(struct qed_hwfn *p_hwfn,
 		status = PFVF_STATUS_FAILURE;
 	}
 
+	/* Forget the configuration on the vport */
+	vf->configured_features = 0;
+	memset(&vf->shadow_config, 0, sizeof(vf->shadow_config));
+
 	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_VPORT_TEARDOWN,
 			     sizeof(struct pfvf_def_resp_tlv), status);
 }
@@ -1634,8 +1801,13 @@ qed_iov_vp_update_vlan_param(struct qed_hwfn *p_hwfn,
 	if (!p_vlan_tlv)
 		return;
 
-	p_data->update_inner_vlan_removal_flg = 1;
-	p_data->inner_vlan_removal_flg = p_vlan_tlv->remove_vlan;
+	p_vf->shadow_config.inner_vlan_removal = p_vlan_tlv->remove_vlan;
+
+	/* Ignore the VF request if we're forcing a vlan */
+	if (!(p_vf->configured_features & (1 << VLAN_ADDR_FORCED))) {
+		p_data->update_inner_vlan_removal_flg = 1;
+		p_data->inner_vlan_removal_flg = p_vlan_tlv->remove_vlan;
+	}
 
 	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_VLAN_STRIP;
 }
@@ -1886,6 +2058,67 @@ out:
 	qed_iov_send_response(p_hwfn, p_ptt, vf, length, status);
 }
 
+static int qed_iov_vf_update_unicast_shadow(struct qed_hwfn *p_hwfn,
+					    struct qed_vf_info *p_vf,
+					    struct qed_filter_ucast *p_params)
+{
+	int i;
+
+	if (p_params->type == QED_FILTER_MAC)
+		return 0;
+
+	/* First remove entries and then add new ones */
+	if (p_params->opcode == QED_FILTER_REMOVE) {
+		for (i = 0; i < QED_ETH_VF_NUM_VLAN_FILTERS + 1; i++)
+			if (p_vf->shadow_config.vlans[i].used &&
+			    p_vf->shadow_config.vlans[i].vid ==
+			    p_params->vlan) {
+				p_vf->shadow_config.vlans[i].used = false;
+				break;
+			}
+		if (i == QED_ETH_VF_NUM_VLAN_FILTERS + 1) {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "VF [%d] - Tries to remove a non-existing vlan\n",
+				   p_vf->relative_vf_id);
+			return -EINVAL;
+		}
+	} else if (p_params->opcode == QED_FILTER_REPLACE ||
+		   p_params->opcode == QED_FILTER_FLUSH) {
+		for (i = 0; i < QED_ETH_VF_NUM_VLAN_FILTERS + 1; i++)
+			p_vf->shadow_config.vlans[i].used = false;
+	}
+
+	/* In forced mode, we're willing to remove entries - but we don't add
+	 * new ones.
+	 */
+	if (p_vf->bulletin.p_virt->valid_bitmap & (1 << VLAN_ADDR_FORCED))
+		return 0;
+
+	if (p_params->opcode == QED_FILTER_ADD ||
+	    p_params->opcode == QED_FILTER_REPLACE) {
+		for (i = 0; i < QED_ETH_VF_NUM_VLAN_FILTERS + 1; i++) {
+			if (p_vf->shadow_config.vlans[i].used)
+				continue;
+
+			p_vf->shadow_config.vlans[i].used = true;
+			p_vf->shadow_config.vlans[i].vid = p_params->vlan;
+			break;
+		}
+
+		if (i == QED_ETH_VF_NUM_VLAN_FILTERS + 1) {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "VF [%d] - Tries to configure more than %d vlan filters\n",
+				   p_vf->relative_vf_id,
+				   QED_ETH_VF_NUM_VLAN_FILTERS + 1);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
 int qed_iov_chk_ucast(struct qed_hwfn *hwfn,
 		      int vfid, struct qed_filter_ucast *params)
 {
@@ -1907,6 +2140,7 @@ static void qed_iov_vf_mbx_ucast_filter(struct qed_hwfn *p_hwfn,
 					struct qed_ptt *p_ptt,
 					struct qed_vf_info *vf)
 {
+	struct qed_bulletin_content *p_bulletin = vf->bulletin.p_virt;
 	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
 	struct vfpf_ucast_filter_tlv *req;
 	u8 status = PFVF_STATUS_SUCCESS;
@@ -1946,6 +2180,25 @@ static void qed_iov_vf_mbx_ucast_filter(struct qed_hwfn *p_hwfn,
 		goto out;
 	}
 
+	/* Update shadow copy of the VF configuration */
+	if (qed_iov_vf_update_unicast_shadow(p_hwfn, vf, &params)) {
+		status = PFVF_STATUS_FAILURE;
+		goto out;
+	}
+
+	/* Determine if the unicast filtering is acceptible by PF */
+	if ((p_bulletin->valid_bitmap & (1 << VLAN_ADDR_FORCED)) &&
+	    (params.type == QED_FILTER_VLAN ||
+	     params.type == QED_FILTER_MAC_VLAN)) {
+		/* Once VLAN is forced or PVID is set, do not allow
+		 * to add/replace any further VLANs.
+		 */
+		if (params.opcode == QED_FILTER_ADD ||
+		    params.opcode == QED_FILTER_REPLACE)
+			status = PFVF_STATUS_FORCED;
+		goto out;
+	}
+
 	rc = qed_iov_chk_ucast(p_hwfn, vf->relative_vf_id, &params);
 	if (rc) {
 		status = PFVF_STATUS_FAILURE;
@@ -2449,6 +2702,29 @@ static int qed_iov_copy_vf_msg(struct qed_hwfn *p_hwfn, struct qed_ptt *ptt,
 	return 0;
 }
 
+void qed_iov_bulletin_set_forced_vlan(struct qed_hwfn *p_hwfn,
+				      u16 pvid, int vfid)
+{
+	struct qed_vf_info *vf_info;
+	u64 feature;
+
+	vf_info = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!vf_info) {
+		DP_NOTICE(p_hwfn->cdev,
+			  "Can not set forced MAC, invalid vfid [%d]\n", vfid);
+		return;
+	}
+
+	feature = 1 << VLAN_ADDR_FORCED;
+	vf_info->bulletin.p_virt->pvid = pvid;
+	if (pvid)
+		vf_info->bulletin.p_virt->valid_bitmap |= feature;
+	else
+		vf_info->bulletin.p_virt->valid_bitmap &= ~feature;
+
+	qed_iov_configure_vport_forced(p_hwfn, vf_info, feature);
+}
+
 bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
 {
 	struct qed_vf_info *p_vf_info;
@@ -2460,6 +2736,20 @@ bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
 	return p_vf_info->state == VF_STOPPED;
 }
 
+u16 qed_iov_bulletin_get_forced_vlan(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
+{
+	struct qed_vf_info *p_vf;
+
+	p_vf = qed_iov_get_vf_info(p_hwfn, rel_vf_id, true);
+	if (!p_vf || !p_vf->bulletin.p_virt)
+		return 0;
+
+	if (!(p_vf->bulletin.p_virt->valid_bitmap & (1 << VLAN_ADDR_FORCED)))
+		return 0;
+
+	return p_vf->bulletin.p_virt->pvid;
+}
+
 /**
  * qed_schedule_iov - schedules IOV task for VF and PF
  * @hwfn: hardware function pointer
@@ -2609,6 +2899,38 @@ static int qed_sriov_configure(struct qed_dev *cdev, int num_vfs_param)
 		return qed_sriov_disable(cdev, true);
 }
 
+static int qed_sriov_pf_set_vlan(struct qed_dev *cdev, u16 vid, int vfid)
+{
+	int i;
+
+	if (!IS_QED_SRIOV(cdev) || !IS_PF_SRIOV_ALLOC(&cdev->hwfns[0])) {
+		DP_VERBOSE(cdev, QED_MSG_IOV,
+			   "Cannot set a VF MAC; Sriov is not enabled\n");
+		return -EINVAL;
+	}
+
+	if (!qed_iov_is_valid_vfid(&cdev->hwfns[0], vfid, true)) {
+		DP_VERBOSE(cdev, QED_MSG_IOV,
+			   "Cannot set VF[%d] MAC (VF is not active)\n", vfid);
+		return -EINVAL;
+	}
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *hwfn = &cdev->hwfns[i];
+		struct qed_public_vf_info *vf_info;
+
+		vf_info = qed_iov_get_public_vf_info(hwfn, vfid, true);
+		if (!vf_info)
+			continue;
+
+		/* Set the forced vlan, and schedule the IOV task */
+		vf_info->forced_vlan = vid;
+		qed_schedule_iov(hwfn, QED_IOV_WQ_SET_UNICAST_FILTER_FLAG);
+	}
+
+	return 0;
+}
+
 void qed_inform_vf_link_state(struct qed_hwfn *hwfn)
 {
 	struct qed_mcp_link_capabilities caps;
@@ -2671,6 +2993,38 @@ static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
 	qed_ptt_release(hwfn, ptt);
 }
 
+static void qed_handle_pf_set_vf_unicast(struct qed_hwfn *hwfn)
+{
+	int i;
+
+	qed_for_each_vf(hwfn, i) {
+		struct qed_public_vf_info *info;
+		bool update = false;
+
+		info = qed_iov_get_public_vf_info(hwfn, i, true);
+		if (!info)
+			continue;
+
+		/* Update data on bulletin board */
+
+		if (qed_iov_bulletin_get_forced_vlan(hwfn, i) ^
+		    info->forced_vlan) {
+			DP_VERBOSE(hwfn,
+				   QED_MSG_IOV,
+				   "Handling PF setting of pvid [0x%04x] to VF 0x%02x [Abs 0x%02x]\n",
+				   info->forced_vlan,
+				   i,
+				   hwfn->cdev->p_iov_info->first_vf_in_pf + i);
+			qed_iov_bulletin_set_forced_vlan(hwfn,
+							 info->forced_vlan, i);
+			update = true;
+		}
+
+		if (update)
+			qed_schedule_iov(hwfn, QED_IOV_WQ_BULLETIN_UPDATE_FLAG);
+	}
+}
+
 static void qed_handle_bulletin_post(struct qed_hwfn *hwfn)
 {
 	struct qed_ptt *ptt;
@@ -2715,6 +3069,11 @@ void qed_iov_pf_task(struct work_struct *work)
 
 	if (test_and_clear_bit(QED_IOV_WQ_MSG_FLAG, &hwfn->iov_task_flags))
 		qed_handle_vf_msg(hwfn);
+
+	if (test_and_clear_bit(QED_IOV_WQ_SET_UNICAST_FILTER_FLAG,
+			       &hwfn->iov_task_flags))
+		qed_handle_pf_set_vf_unicast(hwfn);
+
 	if (test_and_clear_bit(QED_IOV_WQ_BULLETIN_UPDATE_FLAG,
 			       &hwfn->iov_task_flags))
 		qed_handle_bulletin_post(hwfn);
@@ -2774,4 +3133,5 @@ int qed_iov_wq_start(struct qed_dev *cdev)
 
 const struct qed_iov_hv_ops qed_iov_ops_pass = {
 	.configure = &qed_sriov_configure,
+	.set_vlan = &qed_sriov_pf_set_vlan,
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 2c94b44..e65f403 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -24,6 +24,9 @@
 #define QED_MAX_VF_CHAINS_PER_PF 16
 #define QED_ETH_VF_NUM_VLAN_FILTERS 2
 
+#define QED_ETH_MAX_VF_NUM_VLAN_FILTERS	\
+	(MAX_NUM_VFS * QED_ETH_VF_NUM_VLAN_FILTERS)
+
 enum qed_iov_vport_update_flag {
 	QED_IOV_VP_UPDATE_ACTIVATE,
 	QED_IOV_VP_UPDATE_VLAN_STRIP,
@@ -40,6 +43,7 @@ struct qed_public_vf_info {
 	/* These copies will later be reflected in the bulletin board,
 	 * but this copy should be newer.
 	 */
+	u16 forced_vlan;
 	u8 mac[ETH_ALEN];
 };
 
@@ -98,6 +102,18 @@ enum vf_state {
 	VF_STOPPED		/* VF, Stopped */
 };
 
+struct qed_vf_vlan_shadow {
+	bool used;
+	u16 vid;
+};
+
+struct qed_vf_shadow_config {
+	/* Shadow copy of all guest vlans */
+	struct qed_vf_vlan_shadow vlans[QED_ETH_VF_NUM_VLAN_FILTERS + 1];
+
+	u8 inner_vlan_removal;
+};
+
 /* PFs maintain an array of this structure, per VF */
 struct qed_vf_info {
 	struct qed_iov_vf_mbx vf_mbx;
@@ -131,6 +147,16 @@ struct qed_vf_info {
 	u16 igu_sbs[QED_MAX_VF_CHAINS_PER_PF];
 	u8 num_active_rxqs;
 	struct qed_public_vf_info p_vf_info;
+
+	/* Stores the configuration requested by VF */
+	struct qed_vf_shadow_config shadow_config;
+
+	/* A bitfield using bulletin's valid-map bits, used to indicate
+	 * which of the bulletin board features have been configured.
+	 */
+	u64 configured_features;
+#define QED_IOV_CONFIGURED_FEATURES_MASK        ((1 << MAC_ADDR_FORCED) | \
+						 (1 << VLAN_ADDR_FORCED))
 };
 
 /* This structure is part of qed_hwfn and used only for PFs that have sriov
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index e788954..3c8911d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -474,7 +474,7 @@ int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
 			  u16 mtu,
 			  u8 inner_vlan_removal,
 			  enum qed_tpa_mode tpa_mode,
-			  u8 max_buffers_per_cqe)
+			  u8 max_buffers_per_cqe, u8 only_untagged)
 {
 	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
 	struct vfpf_vport_start_tlv *req;
@@ -489,6 +489,7 @@ int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
 	req->inner_vlan_removal = inner_vlan_removal;
 	req->tpa_mode = tpa_mode;
 	req->max_buffers_per_cqe = max_buffers_per_cqe;
+	req->only_untagged = only_untagged;
 
 	/* status blocks */
 	for (i = 0; i < p_hwfn->vf_iov_info->acquire_resp.resc.num_sbs; i++)
@@ -547,6 +548,8 @@ qed_vf_handle_vp_update_is_needed(struct qed_hwfn *p_hwfn,
 		return !!p_data->update_tx_switching_flg;
 	case CHANNEL_TLV_VPORT_UPDATE_VLAN_STRIP:
 		return !!p_data->update_inner_vlan_removal_flg;
+	case CHANNEL_TLV_VPORT_UPDATE_ACCEPT_ANY_VLAN:
+		return !!p_data->update_accept_any_vlan_flg;
 	case CHANNEL_TLV_VPORT_UPDATE_MCAST:
 		return !!p_data->update_approx_mcast_flg;
 	case CHANNEL_TLV_VPORT_UPDATE_ACCEPT_PARAM:
@@ -696,6 +699,19 @@ int qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
 		       sizeof(rss_params->rss_key));
 	}
 
+	if (p_params->update_accept_any_vlan_flg) {
+		struct vfpf_vport_update_accept_any_vlan_tlv *p_any_vlan_tlv;
+
+		size = sizeof(struct vfpf_vport_update_accept_any_vlan_tlv);
+		tlv = CHANNEL_TLV_VPORT_UPDATE_ACCEPT_ANY_VLAN;
+		p_any_vlan_tlv = qed_add_tlv(p_hwfn, &p_iov->offset, tlv, size);
+
+		resp_size += sizeof(struct pfvf_def_resp_tlv);
+		p_any_vlan_tlv->accept_any_vlan = p_params->accept_any_vlan;
+		p_any_vlan_tlv->update_accept_any_vlan_flg =
+		    p_params->update_accept_any_vlan_flg;
+	}
+
 	/* add list termination tlv */
 	qed_add_tlv(p_hwfn, &p_iov->offset,
 		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index f2b46fd..463834f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -417,6 +417,16 @@ union pfvf_tlvs {
 	struct pfvf_start_queue_resp_tlv queue_start;
 };
 
+enum qed_bulletin_bit {
+	/* Alert the VF that a forced VLAN was set by the PF */
+	VLAN_ADDR_FORCED = 2,
+
+	/* Indicate that `default_only_untagged' contains actual data */
+	VFPF_BULLETIN_UNTAGGED_DEFAULT = 3,
+	VFPF_BULLETIN_UNTAGGED_DEFAULT_FORCED = 4,
+
+};
+
 struct qed_bulletin_content {
 	/* crc of structure to ensure is not in mid-update */
 	u32 crc;
@@ -465,6 +475,10 @@ struct qed_bulletin_content {
 	u32 partner_adv_speed;
 
 	u32 capability_speed;
+
+	/* Forced vlan */
+	u16 pvid;
+	u16 padding5;
 };
 
 struct qed_bulletin {
@@ -737,7 +751,7 @@ int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
 			  u16 mtu,
 			  u8 inner_vlan_removal,
 			  enum qed_tpa_mode tpa_mode,
-			  u8 max_buffers_per_cqe);
+			  u8 max_buffers_per_cqe, u8 only_untagged);
 
 /**
  * @brief qed_vf_pf_vport_stop - stop the VF's vport
@@ -898,7 +912,8 @@ static inline int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
 					u16 mtu,
 					u8 inner_vlan_removal,
 					enum qed_tpa_mode tpa_mode,
-					u8 max_buffers_per_cqe)
+					u8 max_buffers_per_cqe,
+					u8 only_untagged)
 {
 	return -EINVAL;
 }
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 57e3426..d3cb672 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -103,6 +103,21 @@ static int qede_alloc_rx_buffer(struct qede_dev *edev,
 static void qede_link_update(void *dev, struct qed_link_output *link);
 
 #ifdef CONFIG_QED_SRIOV
+static int qede_set_vf_vlan(struct net_device *ndev, int vf, u16 vlan, u8 qos)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	if (vlan > 4095) {
+		DP_NOTICE(edev, "Illegal vlan value %d\n", vlan);
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(edev, QED_MSG_IOV, "Setting Vlan 0x%04x to VF [%d]\n",
+		   vlan, vf);
+
+	return edev->ops->iov->set_vlan(edev->cdev, vlan, vf);
+}
+
 static int qede_sriov_configure(struct pci_dev *pdev, int num_vfs_param)
 {
 	struct qede_dev *edev = netdev_priv(pci_get_drvdata(pdev));
@@ -2071,6 +2086,9 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_set_mac_address = qede_set_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_change_mtu = qede_change_mtu,
+#ifdef CONFIG_QED_SRIOV
+	.ndo_set_vf_vlan = qede_set_vf_vlan,
+#endif
 	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = qede_vlan_rx_kill_vid,
 	.ndo_get_stats64 = qede_get_stats64,
diff --git a/include/linux/qed/qed_iov_if.h b/include/linux/qed/qed_iov_if.h
index c53bfa6..825c007 100644
--- a/include/linux/qed/qed_iov_if.h
+++ b/include/linux/qed/qed_iov_if.h
@@ -15,6 +15,7 @@
 struct qed_iov_hv_ops {
 	int (*configure)(struct qed_dev *cdev, int num_vfs_param);
 
+	int (*set_vlan) (struct qed_dev *cdev, u16 vid, int vfid);
 };
 
 #endif
-- 
1.9.3
