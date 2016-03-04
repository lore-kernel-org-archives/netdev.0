From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/2] qed/qede: Add infrastructure support for hardware GRO
Date: Fri, 4 Mar 2016 12:35:05 -0500
Message-ID: <1457112906-4307-2-git-send-email-manish.chopra@qlogic.com>
References: <1457112906-4307-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:1310 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751114AbcCDSP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 13:15:28 -0500
In-Reply-To: <1457112906-4307-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds mainly structures and APIs prototype changes
in order to give support for qede slowpath/fastpath support
for the same.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hsi.h    |   14 ++++-
 drivers/net/ethernet/qlogic/qed/qed_l2.c     |   81 ++++++++++++++++++--------
 drivers/net/ethernet/qlogic/qede/qede_main.c |   17 +++--
 include/linux/qed/qed_eth_if.h               |   12 +++-
 4 files changed, 88 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 592e0e6..236db8a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -2919,7 +2919,19 @@ struct eth_vport_rx_mode {
 };
 
 struct eth_vport_tpa_param {
-	u64     reserved[2];
+	u8	tpa_ipv4_en_flg;
+	u8	tpa_ipv6_en_flg;
+	u8	tpa_ipv4_tunn_en_flg;
+	u8	tpa_ipv6_tunn_en_flg;
+	u8	tpa_pkt_split_flg;
+	u8	tpa_hdr_data_split_flg;
+	u8	tpa_gro_consistent_flg;
+	u8	tpa_max_aggs_num;
+	u16	tpa_max_size;
+	u16	tpa_min_size_to_start;
+	u16	tpa_min_size_to_cont;
+	u8	max_buff_num;
+	u8	reserved;
 };
 
 struct eth_vport_tx_mode {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 102ddc7..3f35c6c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -132,16 +132,29 @@ struct qed_sp_vport_update_params {
 	struct qed_filter_accept_flags	accept_flags;
 };
 
+enum qed_tpa_mode {
+	QED_TPA_MODE_NONE,
+	QED_TPA_MODE_UNUSED,
+	QED_TPA_MODE_GRO,
+	QED_TPA_MODE_MAX
+};
+
+struct qed_sp_vport_start_params {
+	enum qed_tpa_mode	tpa_mode;
+	bool			remove_inner_vlan;
+	bool			drop_ttl0;
+	u8			max_buffers_per_cqe;
+	u32			concrete_fid;
+	u16			opaque_fid;
+	u8			vport_id;
+	u16			mtu;
+};
+
 #define QED_MAX_SGES_NUM 16
 #define CRC32_POLY 0x1edc6f41
 
 static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
-			      u32 concrete_fid,
-			      u16 opaque_fid,
-			      u8 vport_id,
-			      u16 mtu,
-			      u8 drop_ttl0_flg,
-			      u8 inner_vlan_removal_en_flg)
+			      struct qed_sp_vport_start_params *p_params)
 {
 	struct vport_start_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent =  NULL;
@@ -150,13 +163,13 @@ static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 	u16 rx_mode = 0;
 	u8 abs_vport_id = 0;
 
-	rc = qed_fw_vport(p_hwfn, vport_id, &abs_vport_id);
+	rc = qed_fw_vport(p_hwfn, p_params->vport_id, &abs_vport_id);
 	if (rc != 0)
 		return rc;
 
 	memset(&init_data, 0, sizeof(init_data));
 	init_data.cid = qed_spq_get_cid(p_hwfn);
-	init_data.opaque_fid = opaque_fid;
+	init_data.opaque_fid = p_params->opaque_fid;
 	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
@@ -168,9 +181,9 @@ static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 	p_ramrod		= &p_ent->ramrod.vport_start;
 	p_ramrod->vport_id	= abs_vport_id;
 
-	p_ramrod->mtu			= cpu_to_le16(mtu);
-	p_ramrod->inner_vlan_removal_en = inner_vlan_removal_en_flg;
-	p_ramrod->drop_ttl0_en		= drop_ttl0_flg;
+	p_ramrod->mtu			= cpu_to_le16(p_params->mtu);
+	p_ramrod->inner_vlan_removal_en	= p_params->remove_inner_vlan;
+	p_ramrod->drop_ttl0_en		= p_params->drop_ttl0;
 
 	SET_FIELD(rx_mode, ETH_VPORT_RX_MODE_UCAST_DROP_ALL, 1);
 	SET_FIELD(rx_mode, ETH_VPORT_RX_MODE_MCAST_DROP_ALL, 1);
@@ -181,9 +194,26 @@ static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
 	memset(&p_ramrod->tpa_param, 0,
 	       sizeof(struct eth_vport_tpa_param));
 
+	p_ramrod->tpa_param.max_buff_num = p_params->max_buffers_per_cqe;
+
+	switch (p_params->tpa_mode) {
+	case QED_TPA_MODE_GRO:
+		p_ramrod->tpa_param.tpa_max_aggs_num = ETH_TPA_MAX_AGGS_NUM;
+		p_ramrod->tpa_param.tpa_max_size = (u16)-1;
+		p_ramrod->tpa_param.tpa_min_size_to_cont = p_params->mtu / 2;
+		p_ramrod->tpa_param.tpa_min_size_to_start = p_params->mtu / 2;
+		p_ramrod->tpa_param.tpa_ipv4_en_flg = 1;
+		p_ramrod->tpa_param.tpa_ipv6_en_flg = 1;
+		p_ramrod->tpa_param.tpa_pkt_split_flg = 1;
+		p_ramrod->tpa_param.tpa_gro_consistent_flg = 1;
+		break;
+	default:
+		break;
+	}
+
 	/* Software Function ID in hwfn (PFs are 0 - 15, VFs are 16 - 135) */
 	p_ramrod->sw_fid = qed_concrete_to_sw_fid(p_hwfn->cdev,
-						  concrete_fid);
+						  p_params->concrete_fid);
 
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
@@ -1592,24 +1622,25 @@ static void qed_register_eth_ops(struct qed_dev *cdev,
 }
 
 static int qed_start_vport(struct qed_dev *cdev,
-			   u8 vport_id,
-			   u16 mtu,
-			   u8 drop_ttl0_flg,
-			   u8 inner_vlan_removal_en_flg)
+			   struct qed_start_vport_params *params)
 {
 	int rc, i;
 
 	for_each_hwfn(cdev, i) {
+		struct qed_sp_vport_start_params start = { 0 };
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
-		rc = qed_sp_vport_start(p_hwfn,
-					p_hwfn->hw_info.concrete_fid,
-					p_hwfn->hw_info.opaque_fid,
-					vport_id,
-					mtu,
-					drop_ttl0_flg,
-					inner_vlan_removal_en_flg);
-
+		start.tpa_mode = params->gro_enable ? QED_TPA_MODE_GRO :
+							QED_TPA_MODE_NONE;
+		start.remove_inner_vlan = params->remove_inner_vlan;
+		start.drop_ttl0 = params->drop_ttl0;
+		start.opaque_fid = p_hwfn->hw_info.opaque_fid;
+		start.concrete_fid = p_hwfn->hw_info.concrete_fid;
+		start.vport_id = params->vport_id;
+		start.max_buffers_per_cqe = 16;
+		start.mtu = params->mtu;
+
+		rc = qed_sp_vport_start(p_hwfn, &start);
 		if (rc) {
 			DP_ERR(cdev, "Failed to start VPORT\n");
 			return rc;
@@ -1619,7 +1650,7 @@ static int qed_start_vport(struct qed_dev *cdev,
 
 		DP_VERBOSE(cdev, (QED_MSG_SPQ | NETIF_MSG_IFUP),
 			   "Started V-PORT %d with MTU %d\n",
-			   vport_id, mtu);
+			   start.vport_id, start.mtu);
 	}
 
 	qed_reset_vport_stats(cdev);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index ddd9e4a..f75f334 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2466,11 +2466,12 @@ static int qede_stop_queues(struct qede_dev *edev)
 static int qede_start_queues(struct qede_dev *edev)
 {
 	int rc, tc, i;
-	int vport_id = 0, drop_ttl0_flg = 1, vlan_removal_en = 1;
+	int vlan_removal_en = 1;
 	struct qed_dev *cdev = edev->cdev;
 	struct qed_update_vport_rss_params *rss_params = &edev->rss_params;
 	struct qed_update_vport_params vport_update_params;
 	struct qed_queue_start_common_params q_params;
+	struct qed_start_vport_params start = {0};
 
 	if (!edev->num_rss) {
 		DP_ERR(edev,
@@ -2478,10 +2479,12 @@ static int qede_start_queues(struct qede_dev *edev)
 		return -EINVAL;
 	}
 
-	rc = edev->ops->vport_start(cdev, vport_id,
-				    edev->ndev->mtu,
-				    drop_ttl0_flg,
-				    vlan_removal_en);
+	start.mtu = edev->ndev->mtu;
+	start.vport_id = 0;
+	start.drop_ttl0 = true;
+	start.remove_inner_vlan = vlan_removal_en;
+
+	rc = edev->ops->vport_start(cdev, &start);
 
 	if (rc) {
 		DP_ERR(edev, "Start V-PORT failed %d\n", rc);
@@ -2490,7 +2493,7 @@ static int qede_start_queues(struct qede_dev *edev)
 
 	DP_VERBOSE(edev, NETIF_MSG_IFUP,
 		   "Start vport ramrod passed, vport_id = %d, MTU = %d, vlan_removal_en = %d\n",
-		   vport_id, edev->ndev->mtu + 0xe, vlan_removal_en);
+		   start.vport_id, edev->ndev->mtu + 0xe, vlan_removal_en);
 
 	for_each_rss(i) {
 		struct qede_fastpath *fp = &edev->fp_array[i];
@@ -2555,7 +2558,7 @@ static int qede_start_queues(struct qede_dev *edev)
 
 	/* Prepare and send the vport enable */
 	memset(&vport_update_params, 0, sizeof(vport_update_params));
-	vport_update_params.vport_id = vport_id;
+	vport_update_params.vport_id = start.vport_id;
 	vport_update_params.update_vport_active_flg = 1;
 	vport_update_params.vport_active_flg = 1;
 
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index e53b0ca..e1d6983 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -39,6 +39,14 @@ struct qed_update_vport_params {
 	struct qed_update_vport_rss_params rss_params;
 };
 
+struct qed_start_vport_params {
+	bool remove_inner_vlan;
+	bool gro_enable;
+	bool drop_ttl0;
+	u8 vport_id;
+	u16 mtu;
+};
+
 struct qed_stop_rxq_params {
 	u8 rss_id;
 	u8 rx_queue_id;
@@ -118,9 +126,7 @@ struct qed_eth_ops {
 			     void *cookie);
 
 	int (*vport_start)(struct qed_dev *cdev,
-			   u8 vport_id, u16 mtu,
-			   u8 drop_ttl0_flg,
-			   u8 inner_vlan_removal_en_flg);
+			   struct qed_start_vport_params *params);
 
 	int (*vport_stop)(struct qed_dev *cdev,
 			  u8 vport_id);
-- 
1.7.1
