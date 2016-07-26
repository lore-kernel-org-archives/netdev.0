From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/3] qed*: Trivial modifications
Date: Tue, 26 Jul 2016 16:58:36 +0300
Message-ID: <1469541517-29934-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1469541517-29934-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:55318 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752056AbcGZN6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 09:58:54 -0400
In-Reply-To: <1469541517-29934-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change qed* code in trivial manner; This isn't necessarily
semantic-only, but the end result is the same, i.e., no change
should occur from user perspective. Changes include:
  - Using temporary variables to better fit 80-character restrictions.
  - Removal of unused variables & code with no effect.
[plus some additional minor modifications].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c      | 11 +++++----
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c | 14 +++++-------
 drivers/net/ethernet/qlogic/qed/qed_int.c      | 11 ++-------
 drivers/net/ethernet/qlogic/qed/qed_l2.c       | 31 ++++++++++++--------------
 drivers/net/ethernet/qlogic/qed/qed_mcp.c      |  4 +---
 drivers/net/ethernet/qlogic/qede/qede_main.c   |  3 ---
 6 files changed, 28 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 1356e17..da23169 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -540,8 +540,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 	cdev->reset_stats = kzalloc(sizeof(*cdev->reset_stats), GFP_KERNEL);
 	if (!cdev->reset_stats) {
 		DP_NOTICE(cdev, "Failed to allocate reset statistics\n");
-		rc = -ENOMEM;
-		goto alloc_err;
+		goto alloc_no_mem;
 	}
 
 	return 0;
@@ -1468,11 +1467,11 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	link_temp = qed_rd(p_hwfn, p_ptt,
 			   port_cfg_addr +
 			   offsetof(struct nvm_cfg1_port, speed_cap_mask));
-	link->speed.advertised_speeds =
-		link_temp & NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_MASK;
+	link_temp &= NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_MASK;
+	link->speed.advertised_speeds = link_temp;
 
-	p_hwfn->mcp_info->link_capabilities.speed_capabilities =
-						link->speed.advertised_speeds;
+	link_temp = link->speed.advertised_speeds;
+	p_hwfn->mcp_info->link_capabilities.speed_capabilities = link_temp;
 
 	link_temp = qed_rd(p_hwfn, p_ptt,
 			   port_cfg_addr +
diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
index 57044ee..b7a4b27 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_ops.c
@@ -295,17 +295,15 @@ static int qed_init_cmd_wr(struct qed_hwfn *p_hwfn,
 
 	switch (GET_FIELD(data, INIT_WRITE_OP_SOURCE)) {
 	case INIT_SRC_INLINE:
-		qed_wr(p_hwfn, p_ptt, addr,
-		       le32_to_cpu(arg->inline_val));
+		data = le32_to_cpu(p_cmd->args.inline_val);
+		qed_wr(p_hwfn, p_ptt, addr, data);
 		break;
 	case INIT_SRC_ZEROS:
-		if (b_must_dmae ||
-		    (b_can_dmae && (le32_to_cpu(arg->zeros_count) >= 64)))
-			rc = qed_init_fill_dmae(p_hwfn, p_ptt, addr, 0,
-						le32_to_cpu(arg->zeros_count));
+		data = le32_to_cpu(p_cmd->args.zeros_count);
+		if (b_must_dmae || (b_can_dmae && (data >= 64)))
+			rc = qed_init_fill_dmae(p_hwfn, p_ptt, addr, 0, data);
 		else
-			qed_init_fill(p_hwfn, p_ptt, addr, 0,
-				      le32_to_cpu(arg->zeros_count));
+			qed_init_fill(p_hwfn, p_ptt, addr, 0, data);
 		break;
 	case INIT_SRC_ARRAY:
 		rc = qed_init_cmd_array(p_hwfn, p_ptt, p_cmd,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 2afa7a0..a701b76 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -2413,12 +2413,6 @@ void qed_init_cau_sb_entry(struct qed_hwfn *p_hwfn,
 	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_SB_TIMESET0, 0x7F);
 	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_SB_TIMESET1, 0x7F);
 
-	/* setting the time resultion to a fixed value ( = 1) */
-	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_TIMER_RES0,
-		  QED_CAU_DEF_RX_TIMER_RES);
-	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_TIMER_RES1,
-		  QED_CAU_DEF_TX_TIMER_RES);
-
 	cau_state = CAU_HC_DISABLE_STATE;
 
 	if (cdev->int_coalescing_mode == QED_COAL_MODE_ENABLE) {
@@ -3133,10 +3127,9 @@ int qed_int_alloc(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		return rc;
 	}
 	rc = qed_int_sb_attn_alloc(p_hwfn, p_ptt);
-	if (rc) {
+	if (rc)
 		DP_ERR(p_hwfn->cdev, "Failed to allocate sb attn mem\n");
-		return rc;
-	}
+
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index abb2902..1f8ff9b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -305,14 +305,14 @@ qed_sp_update_mcast_bin(struct qed_hwfn *p_hwfn,
 	memset(&p_ramrod->approx_mcast.bins, 0,
 	       sizeof(p_ramrod->approx_mcast.bins));
 
-	if (p_params->update_approx_mcast_flg) {
-		p_ramrod->common.update_approx_mcast_flg = 1;
-		for (i = 0; i < ETH_MULTICAST_MAC_BINS_IN_REGS; i++) {
-			u32 *p_bins = (u32 *)p_params->bins;
-			__le32 val = cpu_to_le32(p_bins[i]);
+	if (!p_params->update_approx_mcast_flg)
+		return;
 
-			p_ramrod->approx_mcast.bins[i] = val;
-		}
+	p_ramrod->common.update_approx_mcast_flg = 1;
+	for (i = 0; i < ETH_MULTICAST_MAC_BINS_IN_REGS; i++) {
+		u32 *p_bins = (u32 *)p_params->bins;
+
+		p_ramrod->approx_mcast.bins[i] = cpu_to_le32(p_bins[i]);
 	}
 }
 
@@ -360,8 +360,8 @@ int qed_sp_vport_update(struct qed_hwfn *p_hwfn,
 	p_cmn->tx_active_flg = p_params->vport_active_tx_flg;
 	p_cmn->update_tx_active_flg = p_params->update_vport_active_tx_flg;
 	p_cmn->accept_any_vlan = p_params->accept_any_vlan;
-	p_cmn->update_accept_any_vlan_flg =
-			p_params->update_accept_any_vlan_flg;
+	val = p_params->update_accept_any_vlan_flg;
+	p_cmn->update_accept_any_vlan_flg = val;
 
 	p_cmn->inner_vlan_removal_en = p_params->inner_vlan_removal_flg;
 	val = p_params->update_inner_vlan_removal_flg;
@@ -1183,17 +1183,14 @@ qed_sp_eth_filter_mcast(struct qed_hwfn *p_hwfn,
 	u8 abs_vport_id = 0;
 	int rc, i;
 
-	if (p_filter_cmd->opcode == QED_FILTER_ADD) {
+	if (p_filter_cmd->opcode == QED_FILTER_ADD)
 		rc = qed_fw_vport(p_hwfn, p_filter_cmd->vport_to_add_to,
 				  &abs_vport_id);
-		if (rc)
-			return rc;
-	} else {
+	else
 		rc = qed_fw_vport(p_hwfn, p_filter_cmd->vport_to_remove_from,
 				  &abs_vport_id);
-		if (rc)
-			return rc;
-	}
+	if (rc)
+		return rc;
 
 	/* Get SPQ entry */
 	memset(&init_data, 0, sizeof(init_data));
@@ -1833,8 +1830,8 @@ static int qed_update_vport(struct qed_dev *cdev,
 		       QED_RSS_IND_TABLE_SIZE * sizeof(u16));
 		memcpy(sp_rss_params.rss_key, params->rss_params.rss_key,
 		       QED_RSS_KEY_SIZE * sizeof(u32));
+		sp_params.rss_params = &sp_rss_params;
 	}
-	sp_params.rss_params = &sp_rss_params;
 
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index b65c549..ad86262 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -161,9 +161,7 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 
 	size = MFW_DRV_MSG_MAX_DWORDS(p_info->mfw_mb_length) * sizeof(u32);
 	p_info->mfw_mb_cur = kzalloc(size, GFP_KERNEL);
-	p_info->mfw_mb_shadow =
-		kzalloc(sizeof(u32) * MFW_DRV_MSG_MAX_DWORDS(
-				p_info->mfw_mb_length), GFP_KERNEL);
+	p_info->mfw_mb_shadow = kzalloc(size, GFP_KERNEL);
 	if (!p_info->mfw_mb_shadow || !p_info->mfw_mb_addr)
 		goto err;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 598a462..0bf0e55 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2701,9 +2701,6 @@ static int qede_alloc_rx_buffer(struct qede_dev *edev,
 	struct eth_rx_bd *rx_bd;
 	dma_addr_t mapping;
 	struct page *data;
-	u16 rx_buf_size;
-
-	rx_buf_size = rxq->rx_buf_size;
 
 	data = alloc_pages(GFP_ATOMIC, 0);
 	if (unlikely(!data)) {
-- 
1.9.3
