From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 13/14] qed*: support ndo_get_vf_config
Date: Wed, 11 May 2016 16:36:24 +0300
Message-ID: <1462973785-32532-14-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49916 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932694AbcEKNhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:37:25 -0400
In-Reply-To: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows the user to view the VF configuration by observing the PF's
device.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 93 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c | 12 ++++
 include/linux/qed/qed_iov_if.h               |  3 +
 3 files changed, 108 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 804102c..6af8fd9f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -2588,6 +2588,30 @@ void qed_iov_set_link(struct qed_hwfn *p_hwfn,
 	p_bulletin->capability_speed = p_caps->speed_capabilities;
 }
 
+static void qed_iov_get_link(struct qed_hwfn *p_hwfn,
+			     u16 vfid,
+			     struct qed_mcp_link_params *p_params,
+			     struct qed_mcp_link_state *p_link,
+			     struct qed_mcp_link_capabilities *p_caps)
+{
+	struct qed_vf_info *p_vf = qed_iov_get_vf_info(p_hwfn,
+						       vfid,
+						       false);
+	struct qed_bulletin_content *p_bulletin;
+
+	if (!p_vf)
+		return;
+
+	p_bulletin = p_vf->bulletin.p_virt;
+
+	if (p_params)
+		__qed_vf_get_link_params(p_hwfn, p_params, p_bulletin);
+	if (p_link)
+		__qed_vf_get_link_state(p_hwfn, p_link, p_bulletin);
+	if (p_caps)
+		__qed_vf_get_link_caps(p_hwfn, p_caps, p_bulletin);
+}
+
 static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 				    struct qed_ptt *p_ptt, int vfid)
 {
@@ -2840,6 +2864,17 @@ bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
 	return p_vf_info->state == VF_STOPPED;
 }
 
+static bool qed_iov_spoofchk_get(struct qed_hwfn *p_hwfn, int vfid)
+{
+	struct qed_vf_info *vf_info;
+
+	vf_info = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!vf_info)
+		return false;
+
+	return vf_info->spoof_chk;
+}
+
 int qed_iov_spoofchk_set(struct qed_hwfn *p_hwfn, int vfid, bool val)
 {
 	struct qed_vf_info *vf;
@@ -2937,6 +2972,23 @@ int qed_iov_configure_min_tx_rate(struct qed_dev *cdev, int vfid, u32 rate)
 	return qed_configure_vport_wfq(cdev, vport_id, rate);
 }
 
+static int qed_iov_get_vf_min_rate(struct qed_hwfn *p_hwfn, int vfid)
+{
+	struct qed_wfq_data *vf_vp_wfq;
+	struct qed_vf_info *vf_info;
+
+	vf_info = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!vf_info)
+		return 0;
+
+	vf_vp_wfq = &p_hwfn->qm_info.wfq_data[vf_info->vport_id];
+
+	if (vf_vp_wfq->configured)
+		return vf_vp_wfq->min_speed;
+	else
+		return 0;
+}
+
 /**
  * qed_schedule_iov - schedules IOV task for VF and PF
  * @hwfn: hardware function pointer
@@ -3153,6 +3205,46 @@ static int qed_sriov_pf_set_vlan(struct qed_dev *cdev, u16 vid, int vfid)
 	return 0;
 }
 
+static int qed_get_vf_config(struct qed_dev *cdev,
+			     int vf_id, struct ifla_vf_info *ivi)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_public_vf_info *vf_info;
+	struct qed_mcp_link_state link;
+	u32 tx_rate;
+
+	/* Sanitize request */
+	if (IS_VF(cdev))
+		return -EINVAL;
+
+	if (!qed_iov_is_valid_vfid(&cdev->hwfns[0], vf_id, true)) {
+		DP_VERBOSE(cdev, QED_MSG_IOV,
+			   "VF index [%d] isn't active\n", vf_id);
+		return -EINVAL;
+	}
+
+	vf_info = qed_iov_get_public_vf_info(hwfn, vf_id, true);
+
+	qed_iov_get_link(hwfn, vf_id, NULL, &link, NULL);
+
+	/* Fill information about VF */
+	ivi->vf = vf_id;
+
+	if (is_valid_ether_addr(vf_info->forced_mac))
+		ether_addr_copy(ivi->mac, vf_info->forced_mac);
+	else
+		ether_addr_copy(ivi->mac, vf_info->mac);
+
+	ivi->vlan = vf_info->forced_vlan;
+	ivi->spoofchk = qed_iov_spoofchk_get(hwfn, vf_id);
+	ivi->linkstate = vf_info->link_state;
+	tx_rate = vf_info->tx_rate;
+	ivi->max_tx_rate = tx_rate ? tx_rate : link.speed;
+	ivi->min_tx_rate = qed_iov_get_vf_min_rate(hwfn, vf_id);
+
+	return 0;
+}
+
 void qed_inform_vf_link_state(struct qed_hwfn *hwfn)
 {
 	struct qed_mcp_link_capabilities caps;
@@ -3506,6 +3598,7 @@ const struct qed_iov_hv_ops qed_iov_ops_pass = {
 	.configure = &qed_sriov_configure,
 	.set_mac = &qed_sriov_pf_set_mac,
 	.set_vlan = &qed_sriov_pf_set_vlan,
+	.get_config = &qed_get_vf_config,
 	.set_link_state = &qed_set_vf_link_state,
 	.set_spoof = &qed_spoof_configure,
 	.set_rate = &qed_set_vf_rate,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index aa01363..90c3e1e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1793,6 +1793,17 @@ static struct rtnl_link_stats64 *qede_get_stats64(
 }
 
 #ifdef CONFIG_QED_SRIOV
+static int qede_get_vf_config(struct net_device *dev, int vfidx,
+			      struct ifla_vf_info *ivi)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	if (!edev->ops)
+		return -EINVAL;
+
+	return edev->ops->iov->get_config(edev->cdev, vfidx, ivi);
+}
+
 static int qede_set_vf_rate(struct net_device *dev, int vfidx,
 			    int min_tx_rate, int max_tx_rate)
 {
@@ -2153,6 +2164,7 @@ static const struct net_device_ops qede_netdev_ops = {
 #ifdef CONFIG_QED_SRIOV
 	.ndo_set_vf_link_state = qede_set_vf_link_state,
 	.ndo_set_vf_spoofchk = qede_set_vf_spoofchk,
+	.ndo_get_vf_config = qede_get_vf_config,
 	.ndo_set_vf_rate = qede_set_vf_rate,
 #endif
 #ifdef CONFIG_QEDE_VXLAN
diff --git a/include/linux/qed/qed_iov_if.h b/include/linux/qed/qed_iov_if.h
index 2596d30..5a4f8d0 100644
--- a/include/linux/qed/qed_iov_if.h
+++ b/include/linux/qed/qed_iov_if.h
@@ -19,6 +19,9 @@ struct qed_iov_hv_ops {
 
 	int (*set_vlan) (struct qed_dev *cdev, u16 vid, int vfid);
 
+	int (*get_config) (struct qed_dev *cdev, int vf_id,
+			   struct ifla_vf_info *ivi);
+
 	int (*set_link_state) (struct qed_dev *cdev, int vf_id,
 			       int link_state);
 
-- 
1.9.3
