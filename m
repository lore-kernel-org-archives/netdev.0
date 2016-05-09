From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 12/14] qed*: IOV support spoof-checking
Date: Mon, 9 May 2016 16:19:21 +0300
Message-ID: <1462799963-23547-13-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:36810 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753340AbcEINUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:20:34 -0400
In-Reply-To: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support in `ndo_set_vf_spoofchk' for allowing PF control over
its VF spoof-checking configuration.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  4 ++
 drivers/net/ethernet/qlogic/qed/qed_l2.h     |  2 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 91 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h  |  2 +
 drivers/net/ethernet/qlogic/qede/qede_main.c | 11 ++++
 include/linux/qed/qed_iov_if.h               |  2 +
 6 files changed, 112 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 8d83250..e0275a7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -381,6 +381,10 @@ int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	p_ramrod->common.tx_switching_en = p_params->tx_switching_flg;
 	p_cmn->update_tx_switching_en_flg = p_params->update_tx_switching_flg;
 
+	p_cmn->anti_spoofing_en = p_params->anti_spoofing_en;
+	val = p_params->update_anti_spoofing_en_flg;
+	p_ramrod->common.update_anti_spoofing_en_flg = val;
+
 	rc = qed_sp_vport_update_rss(p_hwfn, p_ramrod, p_rss_params);
 	if (rc) {
 		/* Return spq entry which is taken in qed_sp_init_request()*/
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index fad30ae..a04fb7f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -149,6 +149,8 @@ struct qed_sp_vport_update_params {
 	u8				update_tx_switching_flg;
 	u8				tx_switching_flg;
 	u8				update_approx_mcast_flg;
+	u8				update_anti_spoofing_en_flg;
+	u8				anti_spoofing_en;
 	u8				update_accept_any_vlan_flg;
 	u8				accept_any_vlan;
 	unsigned long			bins[8];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index c9a3bb6..804102c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1234,6 +1234,39 @@ out:
 			     sizeof(struct pfvf_acquire_resp_tlv), vfpf_status);
 }
 
+static int __qed_iov_spoofchk_set(struct qed_hwfn *p_hwfn,
+				  struct qed_vf_info *p_vf, bool val)
+{
+	struct qed_sp_vport_update_params params;
+	int rc;
+
+	if (val == p_vf->spoof_chk) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Spoofchk value[%d] is already configured\n", val);
+		return 0;
+	}
+
+	memset(&params, 0, sizeof(struct qed_sp_vport_update_params));
+	params.opaque_fid = p_vf->opaque_fid;
+	params.vport_id = p_vf->vport_id;
+	params.update_anti_spoofing_en_flg = 1;
+	params.anti_spoofing_en = val;
+
+	rc = qed_sp_vport_update(p_hwfn, &params, QED_SPQ_MODE_EBLOCK, NULL);
+	if (rc) {
+		p_vf->spoof_chk = val;
+		p_vf->req_spoofchk_val = p_vf->spoof_chk;
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Spoofchk val[%d] configured\n", val);
+	} else {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Spoofchk configuration[val:%d] failed for VF[%d]\n",
+			   val, p_vf->relative_vf_id);
+	}
+
+	return rc;
+}
+
 static int qed_iov_reconfigure_unicast_vlan(struct qed_hwfn *p_hwfn,
 					    struct qed_vf_info *p_vf)
 {
@@ -1476,6 +1509,8 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 
 		/* Force configuration if needed on the newly opened vport */
 		qed_iov_configure_vport_forced(p_hwfn, vf, *p_bitmap);
+
+		__qed_iov_spoofchk_set(p_hwfn, vf, vf->req_spoofchk_val);
 	}
 	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_VPORT_START,
 			     sizeof(struct pfvf_def_resp_tlv), status);
@@ -1489,6 +1524,7 @@ static void qed_iov_vf_mbx_stop_vport(struct qed_hwfn *p_hwfn,
 	int rc;
 
 	vf->vport_instance--;
+	vf->spoof_chk = false;
 
 	rc = qed_sp_vport_stop(p_hwfn, vf->opaque_fid, vf->vport_id);
 	if (rc != 0) {
@@ -2782,6 +2818,17 @@ void qed_iov_bulletin_set_forced_vlan(struct qed_hwfn *p_hwfn,
 	qed_iov_configure_vport_forced(p_hwfn, vf_info, feature);
 }
 
+static bool qed_iov_vf_has_vport_instance(struct qed_hwfn *p_hwfn, int vfid)
+{
+	struct qed_vf_info *p_vf_info;
+
+	p_vf_info = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!p_vf_info)
+		return false;
+
+	return !!p_vf_info->vport_instance;
+}
+
 bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
 {
 	struct qed_vf_info *p_vf_info;
@@ -2793,6 +2840,34 @@ bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
 	return p_vf_info->state == VF_STOPPED;
 }
 
+int qed_iov_spoofchk_set(struct qed_hwfn *p_hwfn, int vfid, bool val)
+{
+	struct qed_vf_info *vf;
+	int rc = -EINVAL;
+
+	if (!qed_iov_pf_sanity_check(p_hwfn, vfid)) {
+		DP_NOTICE(p_hwfn,
+			  "SR-IOV sanity check failed, can't set spoofchk\n");
+		goto out;
+	}
+
+	vf = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!vf)
+		goto out;
+
+	if (!qed_iov_vf_has_vport_instance(p_hwfn, vfid)) {
+		/* After VF VPORT start PF will configure spoof check */
+		vf->req_spoofchk_val = val;
+		rc = 0;
+		goto out;
+	}
+
+	rc = __qed_iov_spoofchk_set(p_hwfn, vf, val);
+
+out:
+	return rc;
+}
+
 static u8 *qed_iov_bulletin_get_forced_mac(struct qed_hwfn *p_hwfn,
 					   u16 rel_vf_id)
 {
@@ -3179,6 +3254,21 @@ static int qed_set_vf_link_state(struct qed_dev *cdev,
 	return 0;
 }
 
+static int qed_spoof_configure(struct qed_dev *cdev, int vfid, bool val)
+{
+	int i, rc = -EINVAL;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		rc = qed_iov_spoofchk_set(p_hwfn, vfid, val);
+		if (rc)
+			break;
+	}
+
+	return rc;
+}
+
 static int qed_configure_max_vf_rate(struct qed_dev *cdev, int vfid, int rate)
 {
 	int i;
@@ -3417,5 +3507,6 @@ const struct qed_iov_hv_ops qed_iov_ops_pass = {
 	.set_mac = &qed_sriov_pf_set_mac,
 	.set_vlan = &qed_sriov_pf_set_vlan,
 	.set_link_state = &qed_set_vf_link_state,
+	.set_spoof = &qed_spoof_configure,
 	.set_rate = &qed_set_vf_rate,
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index ab3d291..c8667c6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -154,6 +154,8 @@ struct qed_vf_info {
 	u16 igu_sbs[QED_MAX_VF_CHAINS_PER_PF];
 	u8 num_active_rxqs;
 	struct qed_public_vf_info p_vf_info;
+	bool spoof_chk;
+	bool req_spoofchk_val;
 
 	/* Stores the configuration requested by VF */
 	struct qed_vf_shadow_config shadow_config;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index e702aba..aa01363 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1802,6 +1802,16 @@ static int qede_set_vf_rate(struct net_device *dev, int vfidx,
 					max_tx_rate);
 }
 
+static int qede_set_vf_spoofchk(struct net_device *dev, int vfidx, bool val)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	if (!edev->ops)
+		return -EINVAL;
+
+	return edev->ops->iov->set_spoof(edev->cdev, vfidx, val);
+}
+
 static int qede_set_vf_link_state(struct net_device *dev, int vfidx,
 				  int link_state)
 {
@@ -2142,6 +2152,7 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_get_stats64 = qede_get_stats64,
 #ifdef CONFIG_QED_SRIOV
 	.ndo_set_vf_link_state = qede_set_vf_link_state,
+	.ndo_set_vf_spoofchk = qede_set_vf_spoofchk,
 	.ndo_set_vf_rate = qede_set_vf_rate,
 #endif
 #ifdef CONFIG_QEDE_VXLAN
diff --git a/include/linux/qed/qed_iov_if.h b/include/linux/qed/qed_iov_if.h
index f364f2b..2596d30 100644
--- a/include/linux/qed/qed_iov_if.h
+++ b/include/linux/qed/qed_iov_if.h
@@ -22,6 +22,8 @@ struct qed_iov_hv_ops {
 	int (*set_link_state) (struct qed_dev *cdev, int vf_id,
 			       int link_state);
 
+	int (*set_spoof) (struct qed_dev *cdev, int vfid, bool val);
+
 	int (*set_rate) (struct qed_dev *cdev, int vfid,
 			 u32 min_rate, u32 max_rate);
 };
-- 
1.9.3
