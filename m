From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 14/14] qed*: Tx-switching configuration
Date: Wed, 11 May 2016 16:36:25 +0300
Message-ID: <1462973785-32532-15-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:13231 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932694AbcEKNh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:37:29 -0400
In-Reply-To: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device should be configured by default to VEB once VFs are active.
This changes the configuration of both PFs' and VFs' vports into enabling
tx-switching once sriov is enabled.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_l2.c          |  4 ++++
 drivers/net/ethernet/qlogic/qed/qed_l2.h          |  1 +
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  1 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  5 ++++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       |  1 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c          | 12 ++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c      | 24 ++++++++++++++++++++++-
 include/linux/qed/qed_eth_if.h                    |  2 ++
 include/linux/qed/qed_if.h                        |  1 +
 11 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index acaa286..6fb6016 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -688,7 +688,8 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 		qed_int_igu_enable(p_hwfn, p_ptt, int_mode);
 
 		/* send function start command */
-		rc = qed_sp_pf_start(p_hwfn, p_tunn, p_hwfn->cdev->mf_mode);
+		rc = qed_sp_pf_start(p_hwfn, p_tunn, p_hwfn->cdev->mf_mode,
+				     allow_npar_tx_switch);
 		if (rc)
 			DP_NOTICE(p_hwfn, "Function start ramrod failed\n");
 	}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index e0275a7..8fba87dd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -99,6 +99,8 @@ int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
 		break;
 	}
 
+	p_ramrod->tx_switching_en = p_params->tx_switching;
+
 	/* Software Function ID in hwfn (PFs are 0 - 15, VFs are 16 - 135) */
 	p_ramrod->sw_fid = qed_concrete_to_sw_fid(p_hwfn->cdev,
 						  p_params->concrete_fid);
@@ -1792,6 +1794,8 @@ static int qed_update_vport(struct qed_dev *cdev,
 		params->update_vport_active_flg;
 	sp_params.vport_active_rx_flg = params->vport_active_flg;
 	sp_params.vport_active_tx_flg = params->vport_active_flg;
+	sp_params.update_tx_switching_flg = params->update_tx_switching_flg;
+	sp_params.tx_switching_flg = params->tx_switching_flg;
 	sp_params.accept_any_vlan = params->accept_any_vlan;
 	sp_params.update_accept_any_vlan_flg =
 		params->update_accept_any_vlan_flg;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index a04fb7f..0021145 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -94,6 +94,7 @@ enum qed_tpa_mode {
 struct qed_sp_vport_start_params {
 	enum qed_tpa_mode tpa_mode;
 	bool remove_inner_vlan;
+	bool tx_switching;
 	bool only_untagged;
 	bool drop_ttl0;
 	u8 max_buffers_per_cqe;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index dcb782c..6ffc21d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -216,6 +216,7 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 		dev_info->fw_rev = FW_REVISION_VERSION;
 		dev_info->fw_eng = FW_ENGINEERING_VERSION;
 		dev_info->mf_mode = cdev->mf_mode;
+		dev_info->tx_switching = true;
 	} else {
 		qed_vf_get_fw_version(&cdev->hwfns[0], &dev_info->fw_major,
 				      &dev_info->fw_minor, &dev_info->fw_rev,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index c2999cb..ab5549f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -344,13 +344,14 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
  * @param p_hwfn
  * @param p_tunn
  * @param mode
+ * @param allow_npar_tx_switch
  *
  * @return int
  */
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 		    struct qed_tunn_start_params *p_tunn,
-		    enum qed_mf_mode mode);
+		    enum qed_mf_mode mode, bool allow_npar_tx_switch);
 
 /**
  * @brief qed_sp_pf_stop - PF Function Stop Ramrod
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index ed90947..8c555ed 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -299,7 +299,7 @@ qed_tunn_set_pf_start_params(struct qed_hwfn *p_hwfn,
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 		    struct qed_tunn_start_params *p_tunn,
-		    enum qed_mf_mode mode)
+		    enum qed_mf_mode mode, bool allow_npar_tx_switch)
 {
 	struct pf_start_ramrod_data *p_ramrod = NULL;
 	u16 sb = qed_int_get_sp_sb_id(p_hwfn);
@@ -358,6 +358,9 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 				     &p_ramrod->tunnel_config);
 	p_hwfn->hw_info.personality = PERSONALITY_ETH;
 
+	if (IS_MF_SI(p_hwfn))
+		p_ramrod->allow_npar_tx_switching = allow_npar_tx_switch;
+
 	if (p_hwfn->cdev->p_iov_info) {
 		struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 6af8fd9f..d4df406 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1490,6 +1490,7 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 
 	params.tpa_mode = start->tpa_mode;
 	params.remove_inner_vlan = start->inner_vlan_removal;
+	params.tx_switching = true;
 
 	params.only_untagged = vf_info->bulletin.p_virt->default_only_untagged;
 	params.drop_ttl0 = false;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index db14e23..72e69c0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -633,6 +633,18 @@ int qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
 		}
 	}
 
+	if (p_params->update_tx_switching_flg) {
+		struct vfpf_vport_update_tx_switch_tlv *p_tx_switch_tlv;
+
+		size = sizeof(struct vfpf_vport_update_tx_switch_tlv);
+		tlv = CHANNEL_TLV_VPORT_UPDATE_TX_SWITCH;
+		p_tx_switch_tlv = qed_add_tlv(p_hwfn, &p_iov->offset,
+					      tlv, size);
+		resp_size += sizeof(struct pfvf_def_resp_tlv);
+
+		p_tx_switch_tlv->tx_switching = p_params->tx_switching_flg;
+	}
+
 	if (p_params->update_approx_mcast_flg) {
 		struct vfpf_vport_update_mcast_bin_tlv *p_mcast_tlv;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 90c3e1e..1755d4a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -137,10 +137,26 @@ static int qede_set_vf_mac(struct net_device *ndev, int vfidx, u8 *mac)
 static int qede_sriov_configure(struct pci_dev *pdev, int num_vfs_param)
 {
 	struct qede_dev *edev = netdev_priv(pci_get_drvdata(pdev));
+	struct qed_dev_info *qed_info = &edev->dev_info.common;
+	int rc;
 
 	DP_VERBOSE(edev, QED_MSG_IOV, "Requested %d VFs\n", num_vfs_param);
 
-	return edev->ops->iov->configure(edev->cdev, num_vfs_param);
+	rc = edev->ops->iov->configure(edev->cdev, num_vfs_param);
+
+	/* Enable/Disable Tx switching for PF */
+	if ((rc == num_vfs_param) && netif_running(edev->ndev) &&
+	    qed_info->mf_mode != QED_MF_NPAR && qed_info->tx_switching) {
+		struct qed_update_vport_params params;
+
+		memset(&params, 0, sizeof(params));
+		params.vport_id = 0;
+		params.update_tx_switching_flg = 1;
+		params.tx_switching_flg = num_vfs_param ? 1 : 0;
+		edev->ops->vport_update(edev->cdev, &params);
+	}
+
+	return rc;
 }
 #endif
 
@@ -3293,6 +3309,12 @@ static int qede_start_queues(struct qede_dev *edev)
 	vport_update_params.update_vport_active_flg = 1;
 	vport_update_params.vport_active_flg = 1;
 
+	if ((qed_info->mf_mode == QED_MF_NPAR || pci_num_vf(edev->pdev)) &&
+	    qed_info->tx_switching) {
+		vport_update_params.update_tx_switching_flg = 1;
+		vport_update_params.tx_switching_flg = 1;
+	}
+
 	/* Fill struct with RSS params */
 	if (QEDE_RSS_CNT(edev) > 1) {
 		vport_update_params.update_rss_flg = 1;
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index e0f6e64..6ae8cb4 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -35,6 +35,8 @@ struct qed_update_vport_params {
 	u8 vport_id;
 	u8 update_vport_active_flg;
 	u8 vport_active_flg;
+	u8 update_tx_switching_flg;
+	u8 tx_switching_flg;
 	u8 update_accept_any_vlan_flg;
 	u8 accept_any_vlan;
 	u8 update_rss_flg;
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 76a6f16..0fd8f24 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -93,6 +93,7 @@ struct qed_dev_info {
 
 	u32		flash_size;
 	u8		mf_mode;
+	bool		tx_switching;
 };
 
 enum qed_sb_type {
-- 
1.9.3
