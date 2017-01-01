From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 09/12] qed*: Add support for ndo_set_vf_trust
Date: Sun, 1 Jan 2017 13:57:08 +0200
Message-ID: <1483271831-25890-10-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51448 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932204AbdAAL61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:27 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trusted VFs would be allowed to receive promiscuous and
multicast promiscuous data.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    | 128 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h    |   9 ++
 drivers/net/ethernet/qlogic/qede/qede_filter.c |  20 ++--
 drivers/net/ethernet/qlogic/qede/qede_main.c   |  11 +++
 include/linux/qed/qed_iov_if.h                 |   2 +
 5 files changed, 162 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index b22baf5..b121364 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1225,6 +1225,9 @@ static void qed_iov_clean_vf(struct qed_hwfn *p_hwfn, u8 vfid)
 
 	/* Clear the VF mac */
 	memset(vf_info->mac, 0, ETH_ALEN);
+
+	vf_info->rx_accept_mode = 0;
+	vf_info->tx_accept_mode = 0;
 }
 
 static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
@@ -2433,6 +2436,39 @@ void *qed_iov_search_list_tlvs(struct qed_hwfn *p_hwfn,
 	*tlvs_mask |= 1 << QED_IOV_VP_UPDATE_SGE_TPA;
 }
 
+static int qed_iov_pre_update_vport(struct qed_hwfn *hwfn,
+				    u8 vfid,
+				    struct qed_sp_vport_update_params *params,
+				    u16 *tlvs)
+{
+	u8 mask = QED_ACCEPT_UCAST_UNMATCHED | QED_ACCEPT_MCAST_UNMATCHED;
+	struct qed_filter_accept_flags *flags = &params->accept_flags;
+	struct qed_public_vf_info *vf_info;
+
+	/* Untrusted VFs can't even be trusted to know that fact.
+	 * Simply indicate everything is configured fine, and trace
+	 * configuration 'behind their back'.
+	 */
+	if (!(*tlvs & BIT(QED_IOV_VP_UPDATE_ACCEPT_PARAM)))
+		return 0;
+
+	vf_info = qed_iov_get_public_vf_info(hwfn, vfid, true);
+
+	if (flags->update_rx_mode_config) {
+		vf_info->rx_accept_mode = flags->rx_accept_filter;
+		if (!vf_info->is_trusted_configured)
+			flags->rx_accept_filter &= ~mask;
+	}
+
+	if (flags->update_tx_mode_config) {
+		vf_info->tx_accept_mode = flags->tx_accept_filter;
+		if (!vf_info->is_trusted_configured)
+			flags->tx_accept_filter &= ~mask;
+	}
+
+	return 0;
+}
+
 static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 					struct qed_ptt *p_ptt,
 					struct qed_vf_info *vf)
@@ -2487,6 +2523,13 @@ static void qed_iov_vf_mbx_vport_update(struct qed_hwfn *p_hwfn,
 	qed_iov_vp_update_rss_param(p_hwfn, vf, &params, p_rss_params,
 				    mbx, &tlvs_mask, &tlvs_accepted);
 
+	if (qed_iov_pre_update_vport(p_hwfn, vf->relative_vf_id,
+				     &params, &tlvs_accepted)) {
+		tlvs_accepted = 0;
+		status = PFVF_STATUS_NOT_SUPPORTED;
+		goto out;
+	}
+
 	if (!tlvs_accepted) {
 		if (tlvs_mask)
 			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
@@ -3936,6 +3979,32 @@ static int qed_set_vf_rate(struct qed_dev *cdev,
 	return 0;
 }
 
+static int qed_set_vf_trust(struct qed_dev *cdev, int vfid, bool trust)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *hwfn = &cdev->hwfns[i];
+		struct qed_public_vf_info *vf;
+
+		if (!qed_iov_pf_sanity_check(hwfn, vfid)) {
+			DP_NOTICE(hwfn,
+				  "SR-IOV sanity check failed, can't set trust\n");
+			return -EINVAL;
+		}
+
+		vf = qed_iov_get_public_vf_info(hwfn, vfid, true);
+
+		if (vf->is_trusted_request == trust)
+			return 0;
+		vf->is_trusted_request = trust;
+
+		qed_schedule_iov(hwfn, QED_IOV_WQ_TRUST_FLAG);
+	}
+
+	return 0;
+}
+
 static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
 {
 	u64 events[QED_VF_ARRAY_LENGTH];
@@ -4040,6 +4109,61 @@ static void qed_handle_bulletin_post(struct qed_hwfn *hwfn)
 	qed_ptt_release(hwfn, ptt);
 }
 
+static void qed_iov_handle_trust_change(struct qed_hwfn *hwfn)
+{
+	struct qed_sp_vport_update_params params;
+	struct qed_filter_accept_flags *flags;
+	struct qed_public_vf_info *vf_info;
+	struct qed_vf_info *vf;
+	u8 mask;
+	int i;
+
+	mask = QED_ACCEPT_UCAST_UNMATCHED | QED_ACCEPT_MCAST_UNMATCHED;
+	flags = &params.accept_flags;
+
+	qed_for_each_vf(hwfn, i) {
+		/* Need to make sure current requested configuration didn't
+		 * flip so that we'll end up configuring something that's not
+		 * needed.
+		 */
+		vf_info = qed_iov_get_public_vf_info(hwfn, i, true);
+		if (vf_info->is_trusted_configured ==
+		    vf_info->is_trusted_request)
+			continue;
+		vf_info->is_trusted_configured = vf_info->is_trusted_request;
+
+		/* Validate that the VF has a configured vport */
+		vf = qed_iov_get_vf_info(hwfn, i, true);
+		if (!vf->vport_instance)
+			continue;
+
+		memset(&params, 0, sizeof(params));
+		params.opaque_fid = vf->opaque_fid;
+		params.vport_id = vf->vport_id;
+
+		if (vf_info->rx_accept_mode & mask) {
+			flags->update_rx_mode_config = 1;
+			flags->rx_accept_filter = vf_info->rx_accept_mode;
+		}
+
+		if (vf_info->tx_accept_mode & mask) {
+			flags->update_tx_mode_config = 1;
+			flags->tx_accept_filter = vf_info->tx_accept_mode;
+		}
+
+		/* Remove if needed; Otherwise this would set the mask */
+		if (!vf_info->is_trusted_configured) {
+			flags->rx_accept_filter &= ~mask;
+			flags->tx_accept_filter &= ~mask;
+		}
+
+		if (flags->update_rx_mode_config ||
+		    flags->update_tx_mode_config)
+			qed_sp_vport_update(hwfn, &params,
+					    QED_SPQ_MODE_EBLOCK, NULL);
+	}
+}
+
 static void qed_iov_pf_task(struct work_struct *work)
 
 {
@@ -4075,6 +4199,9 @@ static void qed_iov_pf_task(struct work_struct *work)
 	if (test_and_clear_bit(QED_IOV_WQ_BULLETIN_UPDATE_FLAG,
 			       &hwfn->iov_task_flags))
 		qed_handle_bulletin_post(hwfn);
+
+	if (test_and_clear_bit(QED_IOV_WQ_TRUST_FLAG, &hwfn->iov_task_flags))
+		qed_iov_handle_trust_change(hwfn);
 }
 
 void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first)
@@ -4137,4 +4264,5 @@ int qed_iov_wq_start(struct qed_dev *cdev)
 	.set_link_state = &qed_set_vf_link_state,
 	.set_spoof = &qed_spoof_configure,
 	.set_rate = &qed_set_vf_rate,
+	.set_trust = &qed_set_vf_trust,
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 1738d5b..0a2e3a3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -80,6 +80,14 @@ struct qed_public_vf_info {
 
 	/* Currently configured Tx rate in MB/sec. 0 if unconfigured */
 	int tx_rate;
+
+	/* Trusted VFs can configure promiscuous mode.
+	 * Also store shadow promisc configuration if needed.
+	 */
+	bool is_trusted_configured;
+	bool is_trusted_request;
+	u8 rx_accept_mode;
+	u8 tx_accept_mode;
 };
 
 struct qed_iov_vf_init_params {
@@ -245,6 +253,7 @@ enum qed_iov_wq_flag {
 	QED_IOV_WQ_BULLETIN_UPDATE_FLAG,
 	QED_IOV_WQ_STOP_WQ_FLAG,
 	QED_IOV_WQ_FLR_FLAG,
+	QED_IOV_WQ_TRUST_FLAG,
 };
 
 #ifdef CONFIG_QED_SRIOV
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 03e2a81..107c3fd 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -714,11 +714,13 @@ void qede_config_rx_mode(struct net_device *ndev)
 		goto out;
 
 	/* Check for promiscuous */
-	if ((ndev->flags & IFF_PROMISC) ||
-	    (uc_count > edev->dev_info.num_mac_filters - 1)) {
+	if (ndev->flags & IFF_PROMISC)
 		accept_flags = QED_FILTER_RX_MODE_TYPE_PROMISC;
-	} else {
-		/* Add MAC filters according to the unicast secondary macs */
+	else
+		accept_flags = QED_FILTER_RX_MODE_TYPE_REGULAR;
+
+	/* Configure all filters regardless, in case promisc is rejected */
+	if (uc_count < edev->dev_info.num_mac_filters) {
 		int i;
 
 		temp = uc_macs;
@@ -731,12 +733,14 @@ void qede_config_rx_mode(struct net_device *ndev)
 
 			temp += ETH_ALEN;
 		}
-
-		rc = qede_configure_mcast_filtering(ndev, &accept_flags);
-		if (rc)
-			goto out;
+	} else {
+		accept_flags = QED_FILTER_RX_MODE_TYPE_PROMISC;
 	}
 
+	rc = qede_configure_mcast_filtering(ndev, &accept_flags);
+	if (rc)
+		goto out;
+
 	/* take care of VLAN mode */
 	if (ndev->flags & IFF_PROMISC) {
 		qede_config_accept_any_vlan(edev, true);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 88d47d6..b58509f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -475,6 +475,16 @@ static int qede_set_vf_link_state(struct net_device *dev, int vfidx,
 
 	return edev->ops->iov->set_link_state(edev->cdev, vfidx, link_state);
 }
+
+static int qede_set_vf_trust(struct net_device *dev, int vfidx, bool setting)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	if (!edev->ops)
+		return -EINVAL;
+
+	return edev->ops->iov->set_trust(edev->cdev, vfidx, setting);
+}
 #endif
 
 static const struct net_device_ops qede_netdev_ops = {
@@ -488,6 +498,7 @@ static int qede_set_vf_link_state(struct net_device *dev, int vfidx,
 #ifdef CONFIG_QED_SRIOV
 	.ndo_set_vf_mac = qede_set_vf_mac,
 	.ndo_set_vf_vlan = qede_set_vf_vlan,
+	.ndo_set_vf_trust = qede_set_vf_trust,
 #endif
 	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = qede_vlan_rx_kill_vid,
diff --git a/include/linux/qed/qed_iov_if.h b/include/linux/qed/qed_iov_if.h
index b1f9791..ac2e6a3 100644
--- a/include/linux/qed/qed_iov_if.h
+++ b/include/linux/qed/qed_iov_if.h
@@ -53,6 +53,8 @@ struct qed_iov_hv_ops {
 
 	int (*set_rate) (struct qed_dev *cdev, int vfid,
 			 u32 min_rate, u32 max_rate);
+
+	int (*set_trust) (struct qed_dev *cdev, int vfid, bool trust);
 };
 
 #endif
-- 
1.9.3
