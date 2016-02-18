From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/2] qed: Lay infrastructure for vlan filtering offload
Date: Thu, 18 Feb 2016 17:00:39 +0200
Message-ID: <1455807640-28165-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1455807640-28165-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32147 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1426020AbcBRPBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:01:05 -0500
In-Reply-To: <1455807640-28165-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, interfaces are working in vlan-promisc mode; But once
vlan filtering offloaded would be supported, we'll need a method to
control it directly [e.g., when setting device to PROMISC, or when
running out of vlan credits].

This adds the necessary API for L2 client to manually choose whether to
accept all vlans or only those for which filters were configured.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 23 +++++++++++++++++++----
 include/linux/qed/qed_eth_if.h           |  2 ++
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 978d07a..63f2287 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -124,6 +124,8 @@ struct qed_sp_vport_update_params {
 	u8				update_vport_active_tx_flg;
 	u8				vport_active_tx_flg;
 	u8				update_approx_mcast_flg;
+	u8				update_accept_any_vlan_flg;
+	u8				accept_any_vlan;
 	unsigned long			bins[8];
 	struct qed_rss_params		*rss_params;
 	struct qed_filter_accept_flags	accept_flags;
@@ -393,7 +395,9 @@ qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	p_cmn->update_rx_active_flg = p_params->update_vport_active_rx_flg;
 	p_cmn->tx_active_flg = p_params->vport_active_tx_flg;
 	p_cmn->update_tx_active_flg = p_params->update_vport_active_tx_flg;
-
+	p_cmn->accept_any_vlan = p_params->accept_any_vlan;
+	p_cmn->update_accept_any_vlan_flg =
+			p_params->update_accept_any_vlan_flg;
 	rc = qed_sp_vport_update_rss(p_hwfn, p_ramrod, p_rss_params);
 	if (rc) {
 		/* Return spq entry which is taken in qed_sp_init_request()*/
@@ -444,8 +448,10 @@ static int qed_sp_vport_stop(struct qed_hwfn *p_hwfn,
 static int qed_filter_accept_cmd(struct qed_dev *cdev,
 				 u8 vport,
 				 struct qed_filter_accept_flags accept_flags,
-				 enum spq_mode comp_mode,
-				 struct qed_spq_comp_cb *p_comp_data)
+				 u8 update_accept_any_vlan,
+				 u8 accept_any_vlan,
+				enum spq_mode comp_mode,
+				struct qed_spq_comp_cb *p_comp_data)
 {
 	struct qed_sp_vport_update_params vport_update_params;
 	int i, rc;
@@ -454,6 +460,8 @@ static int qed_filter_accept_cmd(struct qed_dev *cdev,
 	memset(&vport_update_params, 0, sizeof(vport_update_params));
 	vport_update_params.vport_id = vport;
 	vport_update_params.accept_flags = accept_flags;
+	vport_update_params.update_accept_any_vlan_flg = update_accept_any_vlan;
+	vport_update_params.accept_any_vlan = accept_any_vlan;
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
@@ -471,6 +479,10 @@ static int qed_filter_accept_cmd(struct qed_dev *cdev,
 			   "Accept filter configured, flags = [Rx]%x [Tx]%x\n",
 			   accept_flags.rx_accept_filter,
 			   accept_flags.tx_accept_filter);
+		if (update_accept_any_vlan)
+			DP_VERBOSE(p_hwfn, QED_MSG_SP,
+				   "accept_any_vlan=%d configured\n",
+				   accept_any_vlan);
 	}
 
 	return 0;
@@ -1347,6 +1359,9 @@ static int qed_update_vport(struct qed_dev *cdev,
 		params->update_vport_active_flg;
 	sp_params.vport_active_rx_flg = params->vport_active_flg;
 	sp_params.vport_active_tx_flg = params->vport_active_flg;
+	sp_params.accept_any_vlan = params->accept_any_vlan;
+	sp_params.update_accept_any_vlan_flg =
+		params->update_accept_any_vlan_flg;
 
 	/* RSS - is a bit tricky, since upper-layer isn't familiar with hwfns.
 	 * We need to re-fix the rss values per engine for CMT.
@@ -1566,7 +1581,7 @@ static int qed_configure_filter_rx_mode(struct qed_dev *cdev,
 	else if (type == QED_FILTER_RX_MODE_TYPE_MULTI_PROMISC)
 		accept_flags.rx_accept_filter |= QED_ACCEPT_MCAST_UNMATCHED;
 
-	return qed_filter_accept_cmd(cdev, 0, accept_flags,
+	return qed_filter_accept_cmd(cdev, 0, accept_flags, false, false,
 				     QED_SPQ_MODE_CB, NULL);
 }
 
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 81ab178..e53b0ca 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -33,6 +33,8 @@ struct qed_update_vport_params {
 	u8 vport_id;
 	u8 update_vport_active_flg;
 	u8 vport_active_flg;
+	u8 update_accept_any_vlan_flg;
+	u8 accept_any_vlan;
 	u8 update_rss_flg;
 	struct qed_update_vport_rss_params rss_params;
 };
-- 
1.9.3
