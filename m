From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 11/14] qed*: IOV link control
Date: Mon, 9 May 2016 16:19:20 +0300
Message-ID: <1462799963-23547-12-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:58603 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753340AbcEINUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:20:31 -0400
In-Reply-To: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support in 2 ndo that allow PF to tweak the VF's view of the
link - `ndo_set_vf_link_state' to allow it a view independent of the PF's,
and `ndo_set_vf_rate' which would allow the PF to limit the VF speed.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h        |   2 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c    |  76 +++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 164 +++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h  |   6 +
 drivers/net/ethernet/qlogic/qede/qede_main.c |  26 +++++
 include/linux/qed/qed_iov_if.h               |   6 +
 6 files changed, 280 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index d7da645..77323fc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -554,8 +554,10 @@ static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
 
 #define PURE_LB_TC 8
 
+int qed_configure_vport_wfq(struct qed_dev *cdev, u16 vp_id, u32 rate);
 void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate);
 
+void qed_clean_wfq_db(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 #define QED_LEADING_HWFN(dev)   (&dev->hwfns[0])
 
 /* Other Linux specific common definitions */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index e75e73a..acaa286 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1889,6 +1889,32 @@ static int qed_init_wfq_param(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static int __qed_configure_vport_wfq(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt, u16 vp_id, u32 rate)
+{
+	struct qed_mcp_link_state *p_link;
+	int rc = 0;
+
+	p_link = &p_hwfn->cdev->hwfns[0].mcp_info->link_output;
+
+	if (!p_link->min_pf_rate) {
+		p_hwfn->qm_info.wfq_data[vp_id].min_speed = rate;
+		p_hwfn->qm_info.wfq_data[vp_id].configured = true;
+		return rc;
+	}
+
+	rc = qed_init_wfq_param(p_hwfn, vp_id, rate, p_link->min_pf_rate);
+
+	if (rc == 0)
+		qed_configure_wfq_for_all_vports(p_hwfn, p_ptt,
+						 p_link->min_pf_rate);
+	else
+		DP_NOTICE(p_hwfn,
+			  "Validation failed while configuring min rate\n");
+
+	return rc;
+}
+
 static int __qed_configure_vp_wfq_on_link_change(struct qed_hwfn *p_hwfn,
 						 struct qed_ptt *p_ptt,
 						 u32 min_pf_rate)
@@ -1923,6 +1949,42 @@ static int __qed_configure_vp_wfq_on_link_change(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+/* Main API for qed clients to configure vport min rate.
+ * vp_id - vport id in PF Range[0 - (total_num_vports_per_pf - 1)]
+ * rate - Speed in Mbps needs to be assigned to a given vport.
+ */
+int qed_configure_vport_wfq(struct qed_dev *cdev, u16 vp_id, u32 rate)
+{
+	int i, rc = -EINVAL;
+
+	/* Currently not supported; Might change in future */
+	if (cdev->num_hwfns > 1) {
+		DP_NOTICE(cdev,
+			  "WFQ configuration is not supported for this device\n");
+		return rc;
+	}
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		struct qed_ptt *p_ptt;
+
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt)
+			return -EBUSY;
+
+		rc = __qed_configure_vport_wfq(p_hwfn, p_ptt, vp_id, rate);
+
+		if (!rc) {
+			qed_ptt_release(p_hwfn, p_ptt);
+			return rc;
+		}
+
+		qed_ptt_release(p_hwfn, p_ptt);
+	}
+
+	return rc;
+}
+
 /* API to configure WFQ from mcp link change */
 void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate)
 {
@@ -2069,3 +2131,17 @@ int qed_configure_pf_min_bandwidth(struct qed_dev *cdev, u8 min_bw)
 
 	return rc;
 }
+
+void qed_clean_wfq_db(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	struct qed_mcp_link_state *p_link;
+
+	p_link = &p_hwfn->mcp_info->link_output;
+
+	if (p_link->min_pf_rate)
+		qed_disable_wfq_for_all_vports(p_hwfn, p_ptt,
+					       p_link->min_pf_rate);
+
+	memset(p_hwfn->qm_info.wfq_data, 0,
+	       sizeof(*p_hwfn->qm_info.wfq_data) * p_hwfn->qm_info.num_vports);
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index c1b7919..c9a3bb6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -2822,6 +2822,46 @@ u16 qed_iov_bulletin_get_forced_vlan(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
 	return p_vf->bulletin.p_virt->pvid;
 }
 
+static int qed_iov_configure_tx_rate(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt, int vfid, int val)
+{
+	struct qed_vf_info *vf;
+	u8 abs_vp_id = 0;
+	int rc;
+
+	vf = qed_iov_get_vf_info(p_hwfn, (u16)vfid, true);
+	if (!vf)
+		return -EINVAL;
+
+	rc = qed_fw_vport(p_hwfn, vf->vport_id, &abs_vp_id);
+	if (rc)
+		return rc;
+
+	return qed_init_vport_rl(p_hwfn, p_ptt, abs_vp_id, (u32)val);
+}
+
+int qed_iov_configure_min_tx_rate(struct qed_dev *cdev, int vfid, u32 rate)
+{
+	struct qed_vf_info *vf;
+	u8 vport_id;
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		if (!qed_iov_pf_sanity_check(p_hwfn, vfid)) {
+			DP_NOTICE(p_hwfn,
+				  "SR-IOV sanity check failed, can't set min rate\n");
+			return -EINVAL;
+		}
+	}
+
+	vf = qed_iov_get_vf_info(QED_LEADING_HWFN(cdev), (u16)vfid, true);
+	vport_id = vf->vport_id;
+
+	return qed_configure_vport_wfq(cdev, vport_id, rate);
+}
+
 /**
  * qed_schedule_iov - schedules IOV task for VF and PF
  * @hwfn: hardware function pointer
@@ -2871,6 +2911,9 @@ int qed_sriov_disable(struct qed_dev *cdev, bool pci_enabled)
 			return -EBUSY;
 		}
 
+		/* Clean WFQ db and configure equal weight for all vports */
+		qed_clean_wfq_db(hwfn, ptt);
+
 		qed_for_each_vf(hwfn, j) {
 			int k;
 
@@ -3047,17 +3090,136 @@ void qed_inform_vf_link_state(struct qed_hwfn *hwfn)
 
 	/* Update bulletin of all future possible VFs with link configuration */
 	for (i = 0; i < hwfn->cdev->p_iov_info->total_vfs; i++) {
+		struct qed_public_vf_info *vf_info;
+
+		vf_info = qed_iov_get_public_vf_info(hwfn, i, false);
+		if (!vf_info)
+			continue;
+
 		memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
 		memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
 		memcpy(&caps, qed_mcp_get_link_capabilities(hwfn),
 		       sizeof(caps));
 
+		/* Modify link according to the VF's configured link state */
+		switch (vf_info->link_state) {
+		case IFLA_VF_LINK_STATE_DISABLE:
+			link.link_up = false;
+			break;
+		case IFLA_VF_LINK_STATE_ENABLE:
+			link.link_up = true;
+			/* Set speed according to maximum supported by HW.
+			 * that is 40G for regular devices and 100G for CMT
+			 * mode devices.
+			 */
+			link.speed = (hwfn->cdev->num_hwfns > 1) ?
+				     100000 : 40000;
+		default:
+			/* In auto mode pass PF link image to VF */
+			break;
+		}
+
+		if (link.link_up && vf_info->tx_rate) {
+			struct qed_ptt *ptt;
+			int rate;
+
+			rate = min_t(int, vf_info->tx_rate, link.speed);
+
+			ptt = qed_ptt_acquire(hwfn);
+			if (!ptt) {
+				DP_NOTICE(hwfn, "Failed to acquire PTT\n");
+				return;
+			}
+
+			if (!qed_iov_configure_tx_rate(hwfn, ptt, i, rate)) {
+				vf_info->tx_rate = rate;
+				link.speed = rate;
+			}
+
+			qed_ptt_release(hwfn, ptt);
+		}
+
 		qed_iov_set_link(hwfn, i, &params, &link, &caps);
 	}
 
 	qed_schedule_iov(hwfn, QED_IOV_WQ_BULLETIN_UPDATE_FLAG);
 }
 
+static int qed_set_vf_link_state(struct qed_dev *cdev,
+				 int vf_id, int link_state)
+{
+	int i;
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
+	/* Handle configuration of link state */
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *hwfn = &cdev->hwfns[i];
+		struct qed_public_vf_info *vf;
+
+		vf = qed_iov_get_public_vf_info(hwfn, vf_id, true);
+		if (!vf)
+			continue;
+
+		if (vf->link_state == link_state)
+			continue;
+
+		vf->link_state = link_state;
+		qed_inform_vf_link_state(&cdev->hwfns[i]);
+	}
+
+	return 0;
+}
+
+static int qed_configure_max_vf_rate(struct qed_dev *cdev, int vfid, int rate)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		struct qed_public_vf_info *vf;
+
+		if (!qed_iov_pf_sanity_check(p_hwfn, vfid)) {
+			DP_NOTICE(p_hwfn,
+				  "SR-IOV sanity check failed, can't set tx rate\n");
+			return -EINVAL;
+		}
+
+		vf = qed_iov_get_public_vf_info(p_hwfn, vfid, true);
+
+		vf->tx_rate = rate;
+
+		qed_inform_vf_link_state(p_hwfn);
+	}
+
+	return 0;
+}
+
+static int qed_set_vf_rate(struct qed_dev *cdev,
+			   int vfid, u32 min_rate, u32 max_rate)
+{
+	int rc_min = 0, rc_max = 0;
+
+	if (max_rate)
+		rc_max = qed_configure_max_vf_rate(cdev, vfid, max_rate);
+
+	if (min_rate)
+		rc_min = qed_iov_configure_min_tx_rate(cdev, vfid, min_rate);
+
+	if (rc_max | rc_min)
+		return -EINVAL;
+
+	return 0;
+}
+
 static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
 {
 	u64 events[QED_VF_ARRAY_LENGTH];
@@ -3254,4 +3416,6 @@ const struct qed_iov_hv_ops qed_iov_ops_pass = {
 	.configure = &qed_sriov_configure,
 	.set_mac = &qed_sriov_pf_set_mac,
 	.set_vlan = &qed_sriov_pf_set_vlan,
+	.set_link_state = &qed_set_vf_link_state,
+	.set_rate = &qed_set_vf_rate,
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index e38ea98..ab3d291 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -46,6 +46,12 @@ struct qed_public_vf_info {
 	u8 forced_mac[ETH_ALEN];
 	u16 forced_vlan;
 	u8 mac[ETH_ALEN];
+
+	/* IFLA_VF_LINK_STATE_<X> */
+	int link_state;
+
+	/* Currently configured Tx rate in MB/sec. 0 if unconfigured */
+	int tx_rate;
 };
 
 /* This struct is part of qed_dev and contains data relevant to all hwfns;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index aa2cc49..e702aba 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1792,6 +1792,28 @@ static struct rtnl_link_stats64 *qede_get_stats64(
 	return stats;
 }
 
+#ifdef CONFIG_QED_SRIOV
+static int qede_set_vf_rate(struct net_device *dev, int vfidx,
+			    int min_tx_rate, int max_tx_rate)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	return edev->ops->iov->set_rate(edev->cdev, vfidx, max_tx_rate,
+					max_tx_rate);
+}
+
+static int qede_set_vf_link_state(struct net_device *dev, int vfidx,
+				  int link_state)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	if (!edev->ops)
+		return -EINVAL;
+
+	return edev->ops->iov->set_link_state(edev->cdev, vfidx, link_state);
+}
+#endif
+
 static void qede_config_accept_any_vlan(struct qede_dev *edev, bool action)
 {
 	struct qed_update_vport_params params;
@@ -2118,6 +2140,10 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = qede_vlan_rx_kill_vid,
 	.ndo_get_stats64 = qede_get_stats64,
+#ifdef CONFIG_QED_SRIOV
+	.ndo_set_vf_link_state = qede_set_vf_link_state,
+	.ndo_set_vf_rate = qede_set_vf_rate,
+#endif
 #ifdef CONFIG_QEDE_VXLAN
 	.ndo_add_vxlan_port = qede_add_vxlan_port,
 	.ndo_del_vxlan_port = qede_del_vxlan_port,
diff --git a/include/linux/qed/qed_iov_if.h b/include/linux/qed/qed_iov_if.h
index 7a67fbf..f364f2b 100644
--- a/include/linux/qed/qed_iov_if.h
+++ b/include/linux/qed/qed_iov_if.h
@@ -18,6 +18,12 @@ struct qed_iov_hv_ops {
 	int (*set_mac) (struct qed_dev *cdev, u8 *mac, int vfid);
 
 	int (*set_vlan) (struct qed_dev *cdev, u16 vid, int vfid);
+
+	int (*set_link_state) (struct qed_dev *cdev, int vf_id,
+			       int link_state);
+
+	int (*set_rate) (struct qed_dev *cdev, int vfid,
+			 u32 min_rate, u32 max_rate);
 };
 
 #endif
-- 
1.9.3
