From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 10/14] qed*: Support forced MAC
Date: Mon, 9 May 2016 16:19:19 +0300
Message-ID: <1462799963-23547-11-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:65415 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399AbcEINU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:20:28 -0400
In-Reply-To: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows the PF to enforce the VF's mac.
i.e., by using `ip link ... vf <x> mac <value>'.

While a MAC is forced, PF would prevent the VF from configuring any other
MAC.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c     |   9 ++
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 120 +++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h  |   1 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |  47 +++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h     |  21 +++++
 drivers/net/ethernet/qlogic/qede/qede_main.c |  31 +++++++
 include/linux/qed/qed_eth_if.h               |   3 +
 include/linux/qed/qed_iov_if.h               |   2 +
 8 files changed, 234 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 7fb6b82..8d83250 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1701,6 +1701,14 @@ static void qed_register_eth_ops(struct qed_dev *cdev,
 		qed_vf_start_iov_wq(cdev);
 }
 
+static bool qed_check_mac(struct qed_dev *cdev, u8 *mac)
+{
+	if (IS_PF(cdev))
+		return true;
+
+	return qed_vf_check_mac(&cdev->hwfns[0], mac);
+}
+
 static int qed_start_vport(struct qed_dev *cdev,
 			   struct qed_start_vport_params *params)
 {
@@ -2149,6 +2157,7 @@ static const struct qed_eth_ops qed_eth_ops_pass = {
 #endif
 	.fill_dev_info = &qed_fill_eth_dev_info,
 	.register_ops = &qed_register_eth_ops,
+	.check_mac = &qed_check_mac,
 	.vport_start = &qed_start_vport,
 	.vport_stop = &qed_stop_vport,
 	.vport_update = &qed_update_vport,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 77d44ba..c1b7919 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1295,6 +1295,29 @@ static int qed_iov_configure_vport_forced(struct qed_hwfn *p_hwfn,
 	if (!p_vf->vport_instance)
 		return -EINVAL;
 
+	if (events & (1 << MAC_ADDR_FORCED)) {
+		/* Since there's no way [currently] of removing the MAC,
+		 * we can always assume this means we need to force it.
+		 */
+		memset(&filter, 0, sizeof(filter));
+		filter.type = QED_FILTER_MAC;
+		filter.opcode = QED_FILTER_REPLACE;
+		filter.is_rx_filter = 1;
+		filter.is_tx_filter = 1;
+		filter.vport_to_add_to = p_vf->vport_id;
+		ether_addr_copy(filter.mac, p_vf->bulletin.p_virt->mac);
+
+		rc = qed_sp_eth_filter_ucast(p_hwfn, p_vf->opaque_fid,
+					     &filter, QED_SPQ_MODE_CB, NULL);
+		if (rc) {
+			DP_NOTICE(p_hwfn,
+				  "PF failed to configure MAC for VF\n");
+			return rc;
+		}
+
+		p_vf->configured_features |= 1 << MAC_ADDR_FORCED;
+	}
+
 	if (events & (1 << VLAN_ADDR_FORCED)) {
 		struct qed_sp_vport_update_params vport_update;
 		u8 removal;
@@ -2199,6 +2222,16 @@ static void qed_iov_vf_mbx_ucast_filter(struct qed_hwfn *p_hwfn,
 		goto out;
 	}
 
+	if ((p_bulletin->valid_bitmap & (1 << MAC_ADDR_FORCED)) &&
+	    (params.type == QED_FILTER_MAC ||
+	     params.type == QED_FILTER_MAC_VLAN)) {
+		if (!ether_addr_equal(p_bulletin->mac, params.mac) ||
+		    (params.opcode != QED_FILTER_ADD &&
+		     params.opcode != QED_FILTER_REPLACE))
+			status = PFVF_STATUS_FORCED;
+		goto out;
+	}
+
 	rc = qed_iov_chk_ucast(p_hwfn, vf->relative_vf_id, &params);
 	if (rc) {
 		status = PFVF_STATUS_FAILURE;
@@ -2702,6 +2735,30 @@ static int qed_iov_copy_vf_msg(struct qed_hwfn *p_hwfn, struct qed_ptt *ptt,
 	return 0;
 }
 
+static void qed_iov_bulletin_set_forced_mac(struct qed_hwfn *p_hwfn,
+					    u8 *mac, int vfid)
+{
+	struct qed_vf_info *vf_info;
+	u64 feature;
+
+	vf_info = qed_iov_get_vf_info(p_hwfn, (u16)vfid, true);
+	if (!vf_info) {
+		DP_NOTICE(p_hwfn->cdev,
+			  "Can not set forced MAC, invalid vfid [%d]\n", vfid);
+		return;
+	}
+
+	feature = 1 << MAC_ADDR_FORCED;
+	memcpy(vf_info->bulletin.p_virt->mac, mac, ETH_ALEN);
+
+	vf_info->bulletin.p_virt->valid_bitmap |= feature;
+	/* Forced MAC will disable MAC_ADDR */
+	vf_info->bulletin.p_virt->valid_bitmap &=
+				~(1 << VFPF_BULLETIN_MAC_ADDR);
+
+	qed_iov_configure_vport_forced(p_hwfn, vf_info, feature);
+}
+
 void qed_iov_bulletin_set_forced_vlan(struct qed_hwfn *p_hwfn,
 				      u16 pvid, int vfid)
 {
@@ -2736,6 +2793,21 @@ bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
 	return p_vf_info->state == VF_STOPPED;
 }
 
+static u8 *qed_iov_bulletin_get_forced_mac(struct qed_hwfn *p_hwfn,
+					   u16 rel_vf_id)
+{
+	struct qed_vf_info *p_vf;
+
+	p_vf = qed_iov_get_vf_info(p_hwfn, rel_vf_id, true);
+	if (!p_vf || !p_vf->bulletin.p_virt)
+		return NULL;
+
+	if (!(p_vf->bulletin.p_virt->valid_bitmap & (1 << MAC_ADDR_FORCED)))
+		return NULL;
+
+	return p_vf->bulletin.p_virt->mac;
+}
+
 u16 qed_iov_bulletin_get_forced_vlan(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
 {
 	struct qed_vf_info *p_vf;
@@ -2899,6 +2971,38 @@ static int qed_sriov_configure(struct qed_dev *cdev, int num_vfs_param)
 		return qed_sriov_disable(cdev, true);
 }
 
+static int qed_sriov_pf_set_mac(struct qed_dev *cdev, u8 *mac, int vfid)
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
+		/* Set the forced MAC, and schedule the IOV task */
+		ether_addr_copy(vf_info->forced_mac, mac);
+		qed_schedule_iov(hwfn, QED_IOV_WQ_SET_UNICAST_FILTER_FLAG);
+	}
+
+	return 0;
+}
+
 static int qed_sriov_pf_set_vlan(struct qed_dev *cdev, u16 vid, int vfid)
 {
 	int i;
@@ -3000,12 +3104,27 @@ static void qed_handle_pf_set_vf_unicast(struct qed_hwfn *hwfn)
 	qed_for_each_vf(hwfn, i) {
 		struct qed_public_vf_info *info;
 		bool update = false;
+		u8 *mac;
 
 		info = qed_iov_get_public_vf_info(hwfn, i, true);
 		if (!info)
 			continue;
 
 		/* Update data on bulletin board */
+		mac = qed_iov_bulletin_get_forced_mac(hwfn, i);
+		if (is_valid_ether_addr(info->forced_mac) &&
+		    (!mac || !ether_addr_equal(mac, info->forced_mac))) {
+			DP_VERBOSE(hwfn,
+				   QED_MSG_IOV,
+				   "Handling PF setting of VF MAC to VF 0x%02x [Abs 0x%02x]\n",
+				   i,
+				   hwfn->cdev->p_iov_info->first_vf_in_pf + i);
+
+			/* Update bulletin board with forced MAC */
+			qed_iov_bulletin_set_forced_mac(hwfn,
+							info->forced_mac, i);
+			update = true;
+		}
 
 		if (qed_iov_bulletin_get_forced_vlan(hwfn, i) ^
 		    info->forced_vlan) {
@@ -3133,5 +3252,6 @@ int qed_iov_wq_start(struct qed_dev *cdev)
 
 const struct qed_iov_hv_ops qed_iov_ops_pass = {
 	.configure = &qed_sriov_configure,
+	.set_mac = &qed_sriov_pf_set_mac,
 	.set_vlan = &qed_sriov_pf_set_vlan,
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index e65f403..e38ea98 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -43,6 +43,7 @@ struct qed_public_vf_info {
 	/* These copies will later be reflected in the bulletin board,
 	 * but this copy should be newer.
 	 */
+	u8 forced_mac[ETH_ALEN];
 	u16 forced_vlan;
 	u8 mac[ETH_ALEN];
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 3c8911d..db14e23 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/crc32.h>
+#include <linux/etherdevice.h>
 #include "qed.h"
 #include "qed_sriov.h"
 #include "qed_vf.h"
@@ -1004,6 +1005,43 @@ void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn, u8 *num_vlan_filters)
 	*num_vlan_filters = p_vf->acquire_resp.resc.num_vlan_filters;
 }
 
+bool qed_vf_check_mac(struct qed_hwfn *p_hwfn, u8 *mac)
+{
+	struct qed_bulletin_content *bulletin;
+
+	bulletin = &p_hwfn->vf_iov_info->bulletin_shadow;
+	if (!(bulletin->valid_bitmap & (1 << MAC_ADDR_FORCED)))
+		return true;
+
+	/* Forbid VF from changing a MAC enforced by PF */
+	if (ether_addr_equal(bulletin->mac, mac))
+		return false;
+
+	return false;
+}
+
+bool qed_vf_bulletin_get_forced_mac(struct qed_hwfn *hwfn,
+				    u8 *dst_mac, u8 *p_is_forced)
+{
+	struct qed_bulletin_content *bulletin;
+
+	bulletin = &hwfn->vf_iov_info->bulletin_shadow;
+
+	if (bulletin->valid_bitmap & (1 << MAC_ADDR_FORCED)) {
+		if (p_is_forced)
+			*p_is_forced = 1;
+	} else if (bulletin->valid_bitmap & (1 << VFPF_BULLETIN_MAC_ADDR)) {
+		if (p_is_forced)
+			*p_is_forced = 0;
+	} else {
+		return false;
+	}
+
+	ether_addr_copy(dst_mac, bulletin->mac);
+
+	return true;
+}
+
 void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
 			   u16 *fw_major, u16 *fw_minor,
 			   u16 *fw_rev, u16 *fw_eng)
@@ -1020,6 +1058,15 @@ void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
 
 static void qed_handle_bulletin_change(struct qed_hwfn *hwfn)
 {
+	struct qed_eth_cb_ops *ops = hwfn->cdev->protocol_ops.eth;
+	u8 mac[ETH_ALEN], is_mac_exist, is_mac_forced;
+	void *cookie = hwfn->cdev->ops_cookie;
+
+	is_mac_exist = qed_vf_bulletin_get_forced_mac(hwfn, mac,
+						      &is_mac_forced);
+	if (is_mac_exist && is_mac_forced && cookie)
+		ops->force_mac(cookie, mac);
+
 	/* Always update link configuration according to bulletin */
 	qed_link_update(hwfn);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 463834f..ae0b92f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -418,6 +418,8 @@ union pfvf_tlvs {
 };
 
 enum qed_bulletin_bit {
+	/* Alert the VF that a forced MAC was set by the PF */
+	MAC_ADDR_FORCED = 0,
 	/* Alert the VF that a forced VLAN was set by the PF */
 	VLAN_ADDR_FORCED = 2,
 
@@ -425,6 +427,10 @@ enum qed_bulletin_bit {
 	VFPF_BULLETIN_UNTAGGED_DEFAULT = 3,
 	VFPF_BULLETIN_UNTAGGED_DEFAULT_FORCED = 4,
 
+	/* Alert the VF that suggested mac was sent by the PF.
+	 * MAC_ADDR will be disabled in case MAC_ADDR_FORCED is set.
+	 */
+	VFPF_BULLETIN_MAC_ADDR = 5
 };
 
 struct qed_bulletin_content {
@@ -602,6 +608,16 @@ void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn,
 				 u8 *num_vlan_filters);
 
 /**
+ * @brief Check if VF can set a MAC address
+ *
+ * @param p_hwfn
+ * @param mac
+ *
+ * @return bool
+ */
+bool qed_vf_check_mac(struct qed_hwfn *p_hwfn, u8 *mac);
+
+/**
  * @brief Set firmware version information in dev_info from VFs acquire response tlv
  *
  * @param p_hwfn
@@ -841,6 +857,11 @@ static inline void qed_vf_get_num_vlan_filters(struct qed_hwfn *p_hwfn,
 {
 }
 
+static inline bool qed_vf_check_mac(struct qed_hwfn *p_hwfn, u8 *mac)
+{
+	return false;
+}
+
 static inline void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
 					 u16 *fw_major, u16 *fw_minor,
 					 u16 *fw_rev, u16 *fw_eng)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index d3cb672..aa2cc49 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -118,6 +118,22 @@ static int qede_set_vf_vlan(struct net_device *ndev, int vf, u16 vlan, u8 qos)
 	return edev->ops->iov->set_vlan(edev->cdev, vlan, vf);
 }
 
+static int qede_set_vf_mac(struct net_device *ndev, int vfidx, u8 *mac)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	DP_VERBOSE(edev, QED_MSG_IOV,
+		   "Setting MAC %02x:%02x:%02x:%02x:%02x:%02x to VF [%d]\n",
+		   mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], vfidx);
+
+	if (!is_valid_ether_addr(mac)) {
+		DP_VERBOSE(edev, QED_MSG_IOV, "MAC address isn't valid\n");
+		return -EINVAL;
+	}
+
+	return edev->ops->iov->set_mac(edev->cdev, mac, vfidx);
+}
+
 static int qede_sriov_configure(struct pci_dev *pdev, int num_vfs_param)
 {
 	struct qede_dev *edev = netdev_priv(pci_get_drvdata(pdev));
@@ -138,10 +154,19 @@ static struct pci_driver qede_pci_driver = {
 #endif
 };
 
+static void qede_force_mac(void *dev, u8 *mac)
+{
+	struct qede_dev *edev = dev;
+
+	ether_addr_copy(edev->ndev->dev_addr, mac);
+	ether_addr_copy(edev->primary_mac, mac);
+}
+
 static struct qed_eth_cb_ops qede_ll_ops = {
 	{
 		.link_update = qede_link_update,
 	},
+	.force_mac = qede_force_mac,
 };
 
 static int qede_netdev_event(struct notifier_block *this, unsigned long event,
@@ -2087,6 +2112,7 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_change_mtu = qede_change_mtu,
 #ifdef CONFIG_QED_SRIOV
+	.ndo_set_vf_mac = qede_set_vf_mac,
 	.ndo_set_vf_vlan = qede_set_vf_vlan,
 #endif
 	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
@@ -3514,6 +3540,11 @@ static int qede_set_mac_addr(struct net_device *ndev, void *p)
 		return -EFAULT;
 	}
 
+	if (!edev->ops->check_mac(edev->cdev, addr->sa_data)) {
+		DP_NOTICE(edev, "qed prevents setting MAC\n");
+		return -EINVAL;
+	}
+
 	ether_addr_copy(ndev->dev_addr, addr->sa_data);
 
 	if (!netif_running(ndev))  {
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index acfafca..e0f6e64 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -122,6 +122,7 @@ struct qed_tunn_params {
 
 struct qed_eth_cb_ops {
 	struct qed_common_cb_ops common;
+	void (*force_mac) (void *dev, u8 *mac);
 };
 
 struct qed_eth_ops {
@@ -137,6 +138,8 @@ struct qed_eth_ops {
 			     struct qed_eth_cb_ops *ops,
 			     void *cookie);
 
+	 bool(*check_mac) (struct qed_dev *cdev, u8 *mac);
+
 	int (*vport_start)(struct qed_dev *cdev,
 			   struct qed_start_vport_params *params);
 
diff --git a/include/linux/qed/qed_iov_if.h b/include/linux/qed/qed_iov_if.h
index 825c007..7a67fbf 100644
--- a/include/linux/qed/qed_iov_if.h
+++ b/include/linux/qed/qed_iov_if.h
@@ -15,6 +15,8 @@
 struct qed_iov_hv_ops {
 	int (*configure)(struct qed_dev *cdev, int num_vfs_param);
 
+	int (*set_mac) (struct qed_dev *cdev, u8 *mac, int vfid);
+
 	int (*set_vlan) (struct qed_dev *cdev, u16 vid, int vfid);
 };
 
-- 
1.9.3
