From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/5] be2net: Use GET_PROFILE_CONFIG V1 cmd for BE3-R
Date: Mon, 22 Apr 2013 14:58:17 +0530
Message-ID: <1366622898-1416-5-git-send-email-sathya.perla@emulex.com>
References: <1366622898-1416-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:12514 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730Ab3DVJZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 05:25:47 -0400
In-Reply-To: <1366622898-1416-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Use GET_PROFILE_CONFIG_V1 cmd for BE3-R, to query the maximum number of
TX rings available per function. On SH-R the same is queried via the
GET_FUNCTION_CONFIG cmd.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   95 +++++++++++++++++++++------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   14 +++-
 drivers/net/ethernet/emulex/benet/be_main.c |   10 ++-
 3 files changed, 93 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index d60be68..d6291ab 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2946,7 +2946,8 @@ static struct be_nic_resource_desc *be_get_nic_desc(u8 *buf, u32 desc_count,
 			break;
 		}
 
-		if (desc->desc_type == NIC_RESOURCE_DESC_TYPE_ID)
+		if (desc->desc_type == NIC_RESOURCE_DESC_TYPE_V0 ||
+		    desc->desc_type == NIC_RESOURCE_DESC_TYPE_V1)
 			break;
 
 		desc = (void *)desc + desc->desc_len;
@@ -3020,23 +3021,41 @@ err:
 	return status;
 }
 
- /* Uses sync mcc */
-int be_cmd_get_profile_config(struct be_adapter *adapter, u32 *cap_flags,
-			      u8 domain)
+/* Uses mbox */
+int be_cmd_get_profile_config_mbox(struct be_adapter *adapter,
+				   u8 domain, struct be_dma_mem *cmd)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_profile_config *req;
 	int status;
-	struct be_dma_mem cmd;
 
-	memset(&cmd, 0, sizeof(struct be_dma_mem));
-	cmd.size = sizeof(struct be_cmd_resp_get_profile_config);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size,
-				      &cmd.dma);
-	if (!cmd.va) {
-		dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
-		return -ENOMEM;
-	}
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+	wrb = wrb_from_mbox(adapter);
+
+	req = cmd->va;
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_GET_PROFILE_CONFIG,
+			       cmd->size, wrb, cmd);
+
+	req->type = ACTIVE_PROFILE_TYPE;
+	req->hdr.domain = domain;
+	if (!lancer_chip(adapter))
+		req->hdr.version = 1;
+
+	status = be_mbox_notify_wait(adapter);
+
+	mutex_unlock(&adapter->mbox_lock);
+	return status;
+}
+
+/* Uses sync mcc */
+int be_cmd_get_profile_config_mccq(struct be_adapter *adapter,
+				   u8 domain, struct be_dma_mem *cmd)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_profile_config *req;
+	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
@@ -3046,16 +3065,47 @@ int be_cmd_get_profile_config(struct be_adapter *adapter, u32 *cap_flags,
 		goto err;
 	}
 
-	req = cmd.va;
-
+	req = cmd->va;
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 			       OPCODE_COMMON_GET_PROFILE_CONFIG,
-			       cmd.size, wrb, &cmd);
+			       cmd->size, wrb, cmd);
 
 	req->type = ACTIVE_PROFILE_TYPE;
 	req->hdr.domain = domain;
+	if (!lancer_chip(adapter))
+		req->hdr.version = 1;
 
 	status = be_mcc_notify_wait(adapter);
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
+/* Uses sync mcc, if MCCQ is already created otherwise mbox */
+int be_cmd_get_profile_config(struct be_adapter *adapter, u32 *cap_flags,
+			      u16 *txq_count, u8 domain)
+{
+	struct be_queue_info *mccq = &adapter->mcc_obj.q;
+	struct be_dma_mem cmd;
+	int status;
+
+	memset(&cmd, 0, sizeof(struct be_dma_mem));
+	if (!lancer_chip(adapter))
+		cmd.size = sizeof(struct be_cmd_resp_get_profile_config_v1);
+	else
+		cmd.size = sizeof(struct be_cmd_resp_get_profile_config);
+	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size,
+				      &cmd.dma);
+	if (!cmd.va) {
+		dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
+		return -ENOMEM;
+	}
+
+	if (!mccq->created)
+		status = be_cmd_get_profile_config_mbox(adapter, domain, &cmd);
+	else
+		status = be_cmd_get_profile_config_mccq(adapter, domain, &cmd);
 	if (!status) {
 		struct be_cmd_resp_get_profile_config *resp = cmd.va;
 		u32 desc_count = le32_to_cpu(resp->desc_count);
@@ -3068,12 +3118,15 @@ int be_cmd_get_profile_config(struct be_adapter *adapter, u32 *cap_flags,
 			status = -EINVAL;
 			goto err;
 		}
-		*cap_flags = le32_to_cpu(desc->cap_flags);
+		if (cap_flags)
+			*cap_flags = le32_to_cpu(desc->cap_flags);
+		if (txq_count)
+			*txq_count = le32_to_cpu(desc->txq_count);
 	}
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
-	pci_free_consistent(adapter->pdev, cmd.size,
-			    cmd.va, cmd.dma);
+	if (cmd.va)
+		pci_free_consistent(adapter->pdev, cmd.size,
+				    cmd.va, cmd.dma);
 	return status;
 }
 
@@ -3102,7 +3155,7 @@ int be_cmd_set_profile_config(struct be_adapter *adapter, u32 bps,
 	req->hdr.domain = domain;
 	req->desc_count = cpu_to_le32(1);
 
-	req->nic_desc.desc_type = NIC_RESOURCE_DESC_TYPE_ID;
+	req->nic_desc.desc_type = NIC_RESOURCE_DESC_TYPE_V0;
 	req->nic_desc.desc_len = RESOURCE_DESC_SIZE;
 	req->nic_desc.flags = (1 << QUN) | (1 << IMM) | (1 << NOSV);
 	req->nic_desc.pf_num = adapter->pf_number;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index e959785..4603320 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1687,9 +1687,11 @@ struct be_cmd_req_set_ext_fat_caps {
 	struct be_fat_conf_params set_params;
 };
 
-#define RESOURCE_DESC_SIZE			72
-#define NIC_RESOURCE_DESC_TYPE_ID		0x41
+#define RESOURCE_DESC_SIZE			88
+#define NIC_RESOURCE_DESC_TYPE_V0		0x41
+#define NIC_RESOURCE_DESC_TYPE_V1		0x51
 #define MAX_RESOURCE_DESC			4
+#define MAX_RESOURCE_DESC_V1			32
 
 /* QOS unit number */
 #define QUN					4
@@ -1755,6 +1757,12 @@ struct be_cmd_resp_get_profile_config {
 	u8 func_param[MAX_RESOURCE_DESC * RESOURCE_DESC_SIZE];
 };
 
+struct be_cmd_resp_get_profile_config_v1 {
+	struct be_cmd_req_hdr hdr;
+	u32 desc_count;
+	u8 func_param[MAX_RESOURCE_DESC_V1 * RESOURCE_DESC_SIZE];
+};
+
 struct be_cmd_req_set_profile_config {
 	struct be_cmd_req_hdr hdr;
 	u32 rsvd;
@@ -1917,7 +1925,7 @@ extern int lancer_test_and_set_rdy_state(struct be_adapter *adapter);
 extern int be_cmd_query_port_name(struct be_adapter *adapter, u8 *port_name);
 extern int be_cmd_get_func_config(struct be_adapter *adapter);
 extern int be_cmd_get_profile_config(struct be_adapter *adapter, u32 *cap_flags,
-				     u8 domain);
+				     u16 *txq_count, u8 domain);
 
 extern int be_cmd_set_profile_config(struct be_adapter *adapter, u32 bps,
 				     u8 domain);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b5252d0..c1254cb 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2719,7 +2719,8 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 
 	for_all_vfs(adapter, vf_cfg, vf) {
 		if (!BE3_chip(adapter))
-			be_cmd_get_profile_config(adapter, &cap_flags, vf + 1);
+			be_cmd_get_profile_config(adapter, &cap_flags,
+						  NULL, vf + 1);
 
 		/* If a FW profile exists, then cap_flags are updated */
 		en_flags = cap_flags & (BE_IF_FLAGS_UNTAGGED |
@@ -2883,11 +2884,14 @@ static void be_get_resources(struct be_adapter *adapter)
 	u16 dev_num_vfs;
 	int pos, status;
 	bool profile_present = false;
+	u16 txq_count = 0;
 
 	if (!BEx_chip(adapter)) {
 		status = be_cmd_get_func_config(adapter);
 		if (!status)
 			profile_present = true;
+	} else if (BE3_chip(adapter) && be_physfn(adapter)) {
+		be_cmd_get_profile_config(adapter, NULL, &txq_count, 0);
 	}
 
 	if (profile_present) {
@@ -2925,7 +2929,9 @@ static void be_get_resources(struct be_adapter *adapter)
 			adapter->max_vlans = BE_NUM_VLANS_SUPPORTED;
 
 		adapter->max_mcast_mac = BE_MAX_MC;
-		adapter->max_tx_queues = MAX_TX_QS;
+		adapter->max_tx_queues = txq_count ? txq_count : MAX_TX_QS;
+		adapter->max_tx_queues = min_t(u16, adapter->max_tx_queues,
+					       MAX_TX_QS);
 		adapter->max_rss_queues = (adapter->be3_native) ?
 					   BE3_MAX_RSS_QS : BE2_MAX_RSS_QS;
 		adapter->max_event_queues = BE3_MAX_RSS_QS;
-- 
1.7.1
