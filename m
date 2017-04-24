From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 5/6] qed/qede: Add UDP ports in bulletin board
Date: Mon, 24 Apr 2017 10:00:48 -0700
Message-ID: <20170424170049.16027-6-manish.chopra@cavium.com>
References: <20170424170049.16027-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0050.outbound.protection.outlook.com ([104.47.32.50]:55031
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S975168AbdDXRBp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:01:45 -0400
In-Reply-To: <20170424170049.16027-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for UDP ports in bulletin board
to notify UDP ports change to the VFs

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c       | 19 +++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    | 23 +++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h    |  9 +++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.c       | 16 ++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h       |  4 +++-
 drivers/net/ethernet/qlogic/qede/qede.h        |  1 +
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 11 +++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c   |  1 +
 include/linux/qed/qed_eth_if.h                 |  1 +
 9 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 03216ba..b8bd119 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2304,11 +2304,30 @@ static int qed_tunn_configure(struct qed_dev *cdev,
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *hwfn = &cdev->hwfns[i];
+		struct qed_tunnel_info *tun;
+
+		tun = &hwfn->cdev->tunnel;
 
 		rc = qed_sp_pf_update_tunn_cfg(hwfn, &tunn_info,
 					       QED_SPQ_MODE_EBLOCK, NULL);
 		if (rc)
 			return rc;
+
+		if (IS_PF_SRIOV(hwfn)) {
+			u16 vxlan_port, geneve_port;
+			int j;
+
+			vxlan_port = tun->vxlan_port.port;
+			geneve_port = tun->geneve_port.port;
+
+			qed_for_each_vf(hwfn, j) {
+				qed_iov_bulletin_set_udp_ports(hwfn, j,
+							       vxlan_port,
+							       geneve_port);
+			}
+
+			qed_schedule_iov(hwfn, QED_IOV_WQ_BULLETIN_UPDATE_FLAG);
+		}
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 92a3ee1..85672f6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3511,6 +3511,29 @@ static void qed_iov_bulletin_set_forced_vlan(struct qed_hwfn *p_hwfn,
 	qed_iov_configure_vport_forced(p_hwfn, vf_info, feature);
 }
 
+void qed_iov_bulletin_set_udp_ports(struct qed_hwfn *p_hwfn,
+				    int vfid, u16 vxlan_port, u16 geneve_port)
+{
+	struct qed_vf_info *vf_info;
+
+	vf_info = qed_iov_get_vf_info(p_hwfn, (u16)vfid, true);
+	if (!vf_info) {
+		DP_NOTICE(p_hwfn->cdev,
+			  "Can not set udp ports, invalid vfid [%d]\n", vfid);
+		return;
+	}
+
+	if (vf_info->b_malicious) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Can not set udp ports to malicious VF [%d]\n",
+			   vfid);
+		return;
+	}
+
+	vf_info->bulletin.p_virt->vxlan_udp_port = vxlan_port;
+	vf_info->bulletin.p_virt->geneve_udp_port = geneve_port;
+}
+
 static bool qed_iov_vf_has_vport_instance(struct qed_hwfn *p_hwfn, int vfid)
 {
 	struct qed_vf_info *p_vf_info;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 8e96b1d..81a497c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -270,6 +270,9 @@ enum qed_iov_wq_flag {
  */
 u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn, u16 rel_vf_id);
 
+void qed_iov_bulletin_set_udp_ports(struct qed_hwfn *p_hwfn,
+				    int vfid, u16 vxlan_port, u16 geneve_port);
+
 /**
  * @brief Read sriov related information and allocated resources
  *  reads from configuraiton space, shmem, etc.
@@ -378,6 +381,12 @@ static inline u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn,
 	return MAX_NUM_VFS;
 }
 
+static inline void
+qed_iov_bulletin_set_udp_ports(struct qed_hwfn *p_hwfn, int vfid,
+			       u16 vxlan_port, u16 geneve_port)
+{
+}
+
 static inline int qed_iov_hw_info(struct qed_hwfn *p_hwfn)
 {
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 7987865..01cbbe6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -1251,6 +1251,18 @@ static bool qed_vf_bulletin_get_forced_mac(struct qed_hwfn *hwfn,
 	return true;
 }
 
+static void
+qed_vf_bulletin_get_udp_ports(struct qed_hwfn *p_hwfn,
+			      u16 *p_vxlan_port, u16 *p_geneve_port)
+{
+	struct qed_bulletin_content *p_bulletin;
+
+	p_bulletin = &p_hwfn->vf_iov_info->bulletin_shadow;
+
+	*p_vxlan_port = p_bulletin->vxlan_udp_port;
+	*p_geneve_port = p_bulletin->geneve_udp_port;
+}
+
 void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
 			   u16 *fw_major, u16 *fw_minor,
 			   u16 *fw_rev, u16 *fw_eng)
@@ -1270,12 +1282,16 @@ static void qed_handle_bulletin_change(struct qed_hwfn *hwfn)
 	struct qed_eth_cb_ops *ops = hwfn->cdev->protocol_ops.eth;
 	u8 mac[ETH_ALEN], is_mac_exist, is_mac_forced;
 	void *cookie = hwfn->cdev->ops_cookie;
+	u16 vxlan_port, geneve_port;
 
+	qed_vf_bulletin_get_udp_ports(hwfn, &vxlan_port, &geneve_port);
 	is_mac_exist = qed_vf_bulletin_get_forced_mac(hwfn, mac,
 						      &is_mac_forced);
 	if (is_mac_exist && cookie)
 		ops->force_mac(cookie, mac, !!is_mac_forced);
 
+	ops->ports_update(cookie, vxlan_port, geneve_port);
+
 	/* Always update link configuration according to bulletin */
 	qed_link_update(hwfn);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 105c0ed..6cca145 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -513,7 +513,9 @@ struct qed_bulletin_content {
 	u8 partner_rx_flow_ctrl_en;
 	u8 partner_adv_pause;
 	u8 sfp_tx_fault;
-	u8 padding4[6];
+	u16 vxlan_udp_port;
+	u16 geneve_udp_port;
+	u8 padding4[2];
 
 	u32 speed;
 	u32 partner_adv_speed;
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 26699a7..766a79d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -480,6 +480,7 @@ irqreturn_t qede_msix_fp_int(int irq, void *fp_cookie);
 
 /* Filtering function definitions */
 void qede_force_mac(void *dev, u8 *mac, bool forced);
+void qede_udp_ports_update(void *dev, u16 vxlan_port, u16 geneve_port);
 int qede_set_mac_addr(struct net_device *ndev, void *p);
 
 int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 4fa2c88..eb56520 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -480,6 +480,17 @@ int qede_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 }
 #endif
 
+void qede_udp_ports_update(void *dev, u16 vxlan_port, u16 geneve_port)
+{
+	struct qede_dev *edev = dev;
+
+	if (edev->vxlan_dst_port != vxlan_port)
+		edev->vxlan_dst_port = 0;
+
+	if (edev->geneve_dst_port != geneve_port)
+		edev->geneve_dst_port = 0;
+}
+
 void qede_force_mac(void *dev, u8 *mac, bool forced)
 {
 	struct qede_dev *edev = dev;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f57c823..292e2dc 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -231,6 +231,7 @@ static struct qed_eth_cb_ops qede_ll_ops = {
 		.link_update = qede_link_update,
 	},
 	.force_mac = qede_force_mac,
+	.ports_update = qede_udp_ports_update,
 };
 
 static int qede_netdev_event(struct notifier_block *this, unsigned long event,
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 1eba803c..15fa7c6 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -158,6 +158,7 @@ struct qed_tunn_params {
 struct qed_eth_cb_ops {
 	struct qed_common_cb_ops common;
 	void (*force_mac) (void *dev, u8 *mac, bool forced);
+	void (*ports_update)(void *dev, u16 vxlan_port, u16 geneve_port);
 };
 
 #define QED_MAX_PHC_DRIFT_PPB   291666666
-- 
2.7.2
