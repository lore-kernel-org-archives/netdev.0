From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/6] qed: Pass src/dst sizes when interacting with MFW
Date: Thu, 23 Mar 2017 15:50:16 +0200
Message-ID: <1490277020-31208-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46973 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753847AbdCWNuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:50:40 -0400
In-Reply-To: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

The driver interaction with management firmware involves a union
of all the data-members relating to the commands the driver prepares.

Current interface assumes the caller always passes such a union -
but thats cumbersome as well as risky [chancing a stack corruption
in case caller accidentally passes a smaller member instead of union].

Change implementation so that caller could pass a pointer to any
of the members instead of the union.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 119 ++++++++++++++++--------------
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |   6 +-
 2 files changed, 66 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 0d157de..8d18102 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -368,12 +368,12 @@ static bool qed_mcp_has_pending_cmd(struct qed_hwfn *p_hwfn)
 	p_mb_params->mcp_param = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_param);
 
 	/* Get the union data */
-	if (p_mb_params->p_data_dst != NULL) {
+	if (p_mb_params->p_data_dst != NULL && p_mb_params->data_dst_size) {
 		u32 union_data_addr = p_hwfn->mcp_info->drv_mb_addr +
 				      offsetof(struct public_drv_mb,
 					       union_data);
 		qed_memcpy_from(p_hwfn, p_ptt, p_mb_params->p_data_dst,
-				union_data_addr, sizeof(union drv_union_data));
+				union_data_addr, p_mb_params->data_dst_size);
 	}
 
 	p_cmd_elem->b_is_completed = true;
@@ -394,9 +394,9 @@ static void __qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
 	union_data_addr = p_hwfn->mcp_info->drv_mb_addr +
 			  offsetof(struct public_drv_mb, union_data);
 	memset(&union_data, 0, sizeof(union_data));
-	if (p_mb_params->p_data_src != NULL)
+	if (p_mb_params->p_data_src != NULL && p_mb_params->data_src_size)
 		memcpy(&union_data, p_mb_params->p_data_src,
-		       sizeof(union_data));
+		       p_mb_params->data_src_size);
 	qed_memcpy_to(p_hwfn, p_ptt, union_data_addr, &union_data,
 		      sizeof(union_data));
 
@@ -519,6 +519,7 @@ static int qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
 				 struct qed_ptt *p_ptt,
 				 struct qed_mcp_mb_params *p_mb_params)
 {
+	size_t union_data_size = sizeof(union drv_union_data);
 	u32 max_retries = QED_DRV_MB_MAX_RETRIES;
 	u32 delay = CHIP_MCP_RESP_ITER_US;
 
@@ -528,6 +529,15 @@ static int qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
 		return -EBUSY;
 	}
 
+	if (p_mb_params->data_src_size > union_data_size ||
+	    p_mb_params->data_dst_size > union_data_size) {
+		DP_ERR(p_hwfn,
+		       "The provided size is larger than the union data size [src_size %u, dst_size %u, union_data_size %zu]\n",
+		       p_mb_params->data_src_size,
+		       p_mb_params->data_dst_size, union_data_size);
+		return -EINVAL;
+	}
+
 	return _qed_mcp_cmd_and_union(p_hwfn, p_ptt, p_mb_params, max_retries,
 				      delay);
 }
@@ -540,11 +550,10 @@ int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
 		u32 *o_mcp_param)
 {
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data data_src;
+	struct mcp_mac wol_mac;
 	int rc;
 
 	memset(&mb_params, 0, sizeof(mb_params));
-	memset(&data_src, 0, sizeof(data_src));
 	mb_params.cmd = cmd;
 	mb_params.param = param;
 
@@ -553,17 +562,18 @@ int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
 	    (p_hwfn->cdev->wol_config == QED_OV_WOL_ENABLED)) {
 		u8 *p_mac = p_hwfn->cdev->wol_mac;
 
-		data_src.wol_mac.mac_upper = p_mac[0] << 8 | p_mac[1];
-		data_src.wol_mac.mac_lower = p_mac[2] << 24 | p_mac[3] << 16 |
-					     p_mac[4] << 8 | p_mac[5];
+		memset(&wol_mac, 0, sizeof(wol_mac));
+		wol_mac.mac_upper = p_mac[0] << 8 | p_mac[1];
+		wol_mac.mac_lower = p_mac[2] << 24 | p_mac[3] << 16 |
+				    p_mac[4] << 8 | p_mac[5];
 
 		DP_VERBOSE(p_hwfn,
 			   (QED_MSG_SP | NETIF_MSG_IFDOWN),
 			   "Setting WoL MAC: %pM --> [%08x,%08x]\n",
-			   p_mac, data_src.wol_mac.mac_upper,
-			   data_src.wol_mac.mac_lower);
+			   p_mac, wol_mac.mac_upper, wol_mac.mac_lower);
 
-		mb_params.p_data_src = &data_src;
+		mb_params.p_data_src = &wol_mac;
+		mb_params.data_src_size = sizeof(wol_mac);
 	}
 
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
@@ -584,13 +594,17 @@ int qed_mcp_nvm_rd_cmd(struct qed_hwfn *p_hwfn,
 		       u32 *o_mcp_param, u32 *o_txn_size, u32 *o_buf)
 {
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data union_data;
+	u8 raw_data[MCP_DRV_NVM_BUF_LEN];
 	int rc;
 
 	memset(&mb_params, 0, sizeof(mb_params));
 	mb_params.cmd = cmd;
 	mb_params.param = param;
-	mb_params.p_data_dst = &union_data;
+	mb_params.p_data_dst = raw_data;
+
+	/* Use the maximal value since the actual one is part of the response */
+	mb_params.data_dst_size = MCP_DRV_NVM_BUF_LEN;
+
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc)
 		return rc;
@@ -599,7 +613,7 @@ int qed_mcp_nvm_rd_cmd(struct qed_hwfn *p_hwfn,
 	*o_mcp_param = mb_params.mcp_param;
 
 	*o_txn_size = *o_mcp_param;
-	memcpy(o_buf, &union_data.raw_data, *o_txn_size);
+	memcpy(o_buf, raw_data, *o_txn_size);
 
 	return 0;
 }
@@ -619,6 +633,7 @@ int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 			  cdev->drv_type;
 	memcpy(&union_data.ver_str, cdev->ver_str, MCP_DRV_VER_STR_SIZE);
 	mb_params.p_data_src = &union_data;
+	mb_params.data_src_size = sizeof(union_data.ver_str);
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 
 	/* if mcp fails to respond we must abort */
@@ -688,7 +703,6 @@ int qed_mcp_ack_vf_flr(struct qed_hwfn *p_hwfn,
 	u32 func_addr = SECTION_ADDR(mfw_func_offsize,
 				     MCP_PF_ID(p_hwfn));
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data union_data;
 	int rc;
 	int i;
 
@@ -699,8 +713,8 @@ int qed_mcp_ack_vf_flr(struct qed_hwfn *p_hwfn,
 
 	memset(&mb_params, 0, sizeof(mb_params));
 	mb_params.cmd = DRV_MSG_CODE_VF_DISABLED_DONE;
-	memcpy(&union_data.ack_vf_disabled, vfs_to_ack, VF_MAX_STATIC / 8);
-	mb_params.p_data_src = &union_data;
+	mb_params.p_data_src = vfs_to_ack;
+	mb_params.data_src_size = VF_MAX_STATIC / 8;
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc) {
 		DP_NOTICE(p_hwfn, "Failed to pass ACK for VF flr to MFW\n");
@@ -883,33 +897,31 @@ int qed_mcp_set_link(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, bool b_up)
 {
 	struct qed_mcp_link_params *params = &p_hwfn->mcp_info->link_input;
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data union_data;
-	struct eth_phy_cfg *phy_cfg;
+	struct eth_phy_cfg phy_cfg;
 	int rc = 0;
 	u32 cmd;
 
 	/* Set the shmem configuration according to params */
-	phy_cfg = &union_data.drv_phy_cfg;
-	memset(phy_cfg, 0, sizeof(*phy_cfg));
+	memset(&phy_cfg, 0, sizeof(phy_cfg));
 	cmd = b_up ? DRV_MSG_CODE_INIT_PHY : DRV_MSG_CODE_LINK_RESET;
 	if (!params->speed.autoneg)
-		phy_cfg->speed = params->speed.forced_speed;
-	phy_cfg->pause |= (params->pause.autoneg) ? ETH_PAUSE_AUTONEG : 0;
-	phy_cfg->pause |= (params->pause.forced_rx) ? ETH_PAUSE_RX : 0;
-	phy_cfg->pause |= (params->pause.forced_tx) ? ETH_PAUSE_TX : 0;
-	phy_cfg->adv_speed = params->speed.advertised_speeds;
-	phy_cfg->loopback_mode = params->loopback_mode;
+		phy_cfg.speed = params->speed.forced_speed;
+	phy_cfg.pause |= (params->pause.autoneg) ? ETH_PAUSE_AUTONEG : 0;
+	phy_cfg.pause |= (params->pause.forced_rx) ? ETH_PAUSE_RX : 0;
+	phy_cfg.pause |= (params->pause.forced_tx) ? ETH_PAUSE_TX : 0;
+	phy_cfg.adv_speed = params->speed.advertised_speeds;
+	phy_cfg.loopback_mode = params->loopback_mode;
 
 	p_hwfn->b_drv_link_init = b_up;
 
 	if (b_up) {
 		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
 			   "Configuring Link: Speed 0x%08x, Pause 0x%08x, adv_speed 0x%08x, loopback 0x%08x, features 0x%08x\n",
-			   phy_cfg->speed,
-			   phy_cfg->pause,
-			   phy_cfg->adv_speed,
-			   phy_cfg->loopback_mode,
-			   phy_cfg->feature_config_flags);
+			   phy_cfg.speed,
+			   phy_cfg.pause,
+			   phy_cfg.adv_speed,
+			   phy_cfg.loopback_mode,
+			   phy_cfg.feature_config_flags);
 	} else {
 		DP_VERBOSE(p_hwfn, NETIF_MSG_LINK,
 			   "Resetting link\n");
@@ -917,7 +929,8 @@ int qed_mcp_set_link(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, bool b_up)
 
 	memset(&mb_params, 0, sizeof(mb_params));
 	mb_params.cmd = cmd;
-	mb_params.p_data_src = &union_data;
+	mb_params.p_data_src = &phy_cfg;
+	mb_params.data_src_size = sizeof(phy_cfg);
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 
 	/* if mcp fails to respond we must abort */
@@ -944,7 +957,6 @@ static void qed_mcp_send_protocol_stats(struct qed_hwfn *p_hwfn,
 	enum qed_mcp_protocol_type stats_type;
 	union qed_mcp_protocol_stats stats;
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data union_data;
 	u32 hsi_param;
 
 	switch (type) {
@@ -974,8 +986,8 @@ static void qed_mcp_send_protocol_stats(struct qed_hwfn *p_hwfn,
 	memset(&mb_params, 0, sizeof(mb_params));
 	mb_params.cmd = DRV_MSG_CODE_GET_STATS;
 	mb_params.param = hsi_param;
-	memcpy(&union_data, &stats, sizeof(stats));
-	mb_params.p_data_src = &union_data;
+	mb_params.p_data_src = &stats;
+	mb_params.data_src_size = sizeof(stats);
 	qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 }
 
@@ -1455,24 +1467,23 @@ int qed_mcp_config_vf_msix(struct qed_hwfn *p_hwfn,
 			 struct qed_ptt *p_ptt,
 			 struct qed_mcp_drv_version *p_ver)
 {
-	struct drv_version_stc *p_drv_version;
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data union_data;
+	struct drv_version_stc drv_version;
 	__be32 val;
 	u32 i;
 	int rc;
 
-	p_drv_version = &union_data.drv_version;
-	p_drv_version->version = p_ver->version;
-
+	memset(&drv_version, 0, sizeof(drv_version));
+	drv_version.version = p_ver->version;
 	for (i = 0; i < (MCP_DRV_VER_STR_SIZE - 4) / sizeof(u32); i++) {
 		val = cpu_to_be32(*((u32 *)&p_ver->name[i * sizeof(u32)]));
-		*(__be32 *)&p_drv_version->name[i * sizeof(u32)] = val;
+		*(__be32 *)&drv_version.name[i * sizeof(u32)] = val;
 	}
 
 	memset(&mb_params, 0, sizeof(mb_params));
 	mb_params.cmd = DRV_MSG_CODE_SET_VERSION;
-	mb_params.p_data_src = &union_data;
+	mb_params.p_data_src = &drv_version;
+	mb_params.data_src_size = sizeof(drv_version);
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc)
 		DP_ERR(p_hwfn, "MCP response failure, aborting\n");
@@ -1589,7 +1600,6 @@ int qed_mcp_ov_update_mac(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt, u8 *mac)
 {
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data union_data;
 	int rc;
 
 	memset(&mb_params, 0, sizeof(mb_params));
@@ -1597,8 +1607,9 @@ int qed_mcp_ov_update_mac(struct qed_hwfn *p_hwfn,
 	mb_params.param = DRV_MSG_CODE_VMAC_TYPE_MAC <<
 			  DRV_MSG_CODE_VMAC_TYPE_SHIFT;
 	mb_params.param |= MCP_PF_ID(p_hwfn);
-	ether_addr_copy(&union_data.raw_data[0], mac);
-	mb_params.p_data_src = &union_data;
+
+	mb_params.p_data_src = mac;
+	mb_params.data_src_size = 6;
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc)
 		DP_ERR(p_hwfn, "Failed to send mac address, rc = %d\n", rc);
@@ -1876,27 +1887,21 @@ int qed_mcp_get_resc_info(struct qed_hwfn *p_hwfn,
 			  u32 *p_mcp_resp, u32 *p_mcp_param)
 {
 	struct qed_mcp_mb_params mb_params;
-	union drv_union_data union_data;
 	int rc;
 
 	memset(&mb_params, 0, sizeof(mb_params));
-	memset(&union_data, 0, sizeof(union_data));
 	mb_params.cmd = DRV_MSG_GET_RESOURCE_ALLOC_MSG;
 	mb_params.param = QED_RESC_ALLOC_VERSION;
 
-	/* Need to have a sufficient large struct, as the cmd_and_union
-	 * is going to do memcpy from and to it.
-	 */
-	memcpy(&union_data.resource, p_resc_info, sizeof(*p_resc_info));
-
-	mb_params.p_data_src = &union_data;
-	mb_params.p_data_dst = &union_data;
+	mb_params.p_data_src = p_resc_info;
+	mb_params.data_src_size = sizeof(*p_resc_info);
+	mb_params.p_data_dst = p_resc_info;
+	mb_params.data_dst_size = sizeof(*p_resc_info);
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc)
 		return rc;
 
 	/* Copy the data back */
-	memcpy(p_resc_info, &union_data.resource, sizeof(*p_resc_info));
 	*p_mcp_resp = mb_params.mcp_resp;
 	*p_mcp_param = mb_params.mcp_param;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 0f7b268..f63693d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -516,8 +516,10 @@ struct qed_mcp_info {
 struct qed_mcp_mb_params {
 	u32			cmd;
 	u32			param;
-	union drv_union_data	*p_data_src;
-	union drv_union_data	*p_data_dst;
+	void			*p_data_src;
+	u8			data_src_size;
+	void			*p_data_dst;
+	u8			data_dst_size;
 	u32			mcp_resp;
 	u32			mcp_param;
 };
-- 
1.9.3
