From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 1/2] be2net: Refactored be_cmds.c file.
Date: Thu, 27 Oct 2011 22:42:13 +0530
Message-ID: <4a6db0ab-eddf-4cf2-8139-c152244745ce@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:6192 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755203Ab1J0Lpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 07:45:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moved the .sge. field's population inside be_cmd_hdr_prepare.
Populating wrb->tag0 and tag1 inside be_cmd_hdr_prepare

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |  396 ++++++++-------------------
 1 files changed, 114 insertions(+), 282 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index e0ff961..83b8a46 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -428,28 +428,33 @@ static inline struct be_sge *nonembedded_sgl(struct be_mcc_wrb *wrb)
 	return &wrb->payload.sgl[0];
 }
 
-/* Don't touch the hdr after it's prepared */
-static void be_wrb_hdr_prepare(struct be_mcc_wrb *wrb, int payload_len,
-				bool embedded, u8 sge_cnt, u32 opcode)
-{
-	if (embedded)
-		wrb->embedded |= MCC_WRB_EMBEDDED_MASK;
-	else
-		wrb->embedded |= (sge_cnt & MCC_WRB_SGE_CNT_MASK) <<
-				MCC_WRB_SGE_CNT_SHIFT;
-	wrb->payload_length = payload_len;
-	wrb->tag0 = opcode;
-	be_dws_cpu_to_le(wrb, 8);
-}
 
 /* Don't touch the hdr after it's prepared */
-static void be_cmd_hdr_prepare(struct be_cmd_req_hdr *req_hdr,
-				u8 subsystem, u8 opcode, int cmd_len)
+/* mem will be NULL for embedded commands */
+static void be_wrb_cmd_hdr_prepare(struct be_cmd_req_hdr *req_hdr,
+				u8 subsystem, u8 opcode, int cmd_len,
+				struct be_mcc_wrb *wrb, struct be_dma_mem *mem)
 {
+	struct be_sge *sge;
+
 	req_hdr->opcode = opcode;
 	req_hdr->subsystem = subsystem;
 	req_hdr->request_length = cpu_to_le32(cmd_len - sizeof(*req_hdr));
 	req_hdr->version = 0;
+
+	wrb->tag0 = opcode;
+	wrb->tag1 = subsystem;
+	wrb->payload_length = cmd_len;
+	if (mem) {
+		wrb->embedded |= (1 & MCC_WRB_SGE_CNT_MASK) <<
+			MCC_WRB_SGE_CNT_SHIFT;
+		sge = nonembedded_sgl(wrb);
+		sge->pa_hi = cpu_to_le32(upper_32_bits(mem->dma));
+		sge->pa_lo = cpu_to_le32(mem->dma & 0xFFFFFFFF);
+		sge->len = cpu_to_le32(mem->size);
+	} else
+		wrb->embedded |= MCC_WRB_EMBEDDED_MASK;
+	be_dws_cpu_to_le(wrb, 8);
 }
 
 static void be_cmd_page_addrs_prepare(struct phys_addr *pages, u32 max_pages,
@@ -586,10 +591,8 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0, OPCODE_COMMON_EQ_CREATE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_EQ_CREATE, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_EQ_CREATE, sizeof(*req), wrb, NULL);
 
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 
@@ -632,12 +635,8 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_NTWK_MAC_QUERY);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_MAC_QUERY, sizeof(*req));
-
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_MAC_QUERY, sizeof(*req), wrb, NULL);
 	req->type = type;
 	if (permanent) {
 		req->permanent = 1;
@@ -674,11 +673,8 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_NTWK_PMAC_ADD);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_PMAC_ADD, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_PMAC_ADD, sizeof(*req), wrb, NULL);
 
 	req->hdr.domain = domain;
 	req->if_id = cpu_to_le32(if_id);
@@ -711,11 +707,8 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id, u32 dom)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_NTWK_PMAC_DEL);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_PMAC_DEL, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_PMAC_DEL, sizeof(*req), wrb, NULL);
 
 	req->hdr.domain = dom;
 	req->if_id = cpu_to_le32(if_id);
@@ -746,11 +739,8 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 	req = embedded_payload(wrb);
 	ctxt = &req->context;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_CQ_CREATE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_CQ_CREATE, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_CQ_CREATE, sizeof(*req), wrb, NULL);
 
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 	if (lancer_chip(adapter)) {
@@ -822,11 +812,8 @@ int be_cmd_mccq_ext_create(struct be_adapter *adapter,
 	req = embedded_payload(wrb);
 	ctxt = &req->context;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_MCC_CREATE_EXT);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			OPCODE_COMMON_MCC_CREATE_EXT, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_MCC_CREATE_EXT, sizeof(*req), wrb, NULL);
 
 	req->num_pages = cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 	if (lancer_chip(adapter)) {
@@ -882,11 +869,8 @@ int be_cmd_mccq_org_create(struct be_adapter *adapter,
 	req = embedded_payload(wrb);
 	ctxt = &req->context;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_MCC_CREATE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			OPCODE_COMMON_MCC_CREATE, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_MCC_CREATE, sizeof(*req), wrb, NULL);
 
 	req->num_pages = cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 
@@ -943,11 +927,8 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 	req = embedded_payload(wrb);
 	ctxt = &req->context;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_ETH_TX_CREATE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH, OPCODE_ETH_TX_CREATE,
-		sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+		OPCODE_ETH_TX_CREATE, sizeof(*req), wrb, NULL);
 
 	if (lancer_chip(adapter)) {
 		req->hdr.version = 1;
@@ -999,11 +980,8 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_ETH_RX_CREATE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH, OPCODE_ETH_RX_CREATE,
-		sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+				OPCODE_ETH_RX_CREATE, sizeof(*req), wrb, NULL);
 
 	req->cq_id = cpu_to_le16(cq_id);
 	req->frag_size = fls(frag_size) - 1;
@@ -1071,9 +1049,8 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 		BUG();
 	}
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0, opcode);
-
-	be_cmd_hdr_prepare(&req->hdr, subsys, opcode, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, subsys, opcode, sizeof(*req), wrb,
+				NULL);
 	req->id = cpu_to_le16(q->id);
 
 	status = be_mbox_notify_wait(adapter);
@@ -1100,9 +1077,8 @@ int be_cmd_rxq_destroy(struct be_adapter *adapter, struct be_queue_info *q)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0, OPCODE_ETH_RX_DESTROY);
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH, OPCODE_ETH_RX_DESTROY,
-		sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+			OPCODE_ETH_RX_DESTROY, sizeof(*req), wrb, NULL);
 	req->id = cpu_to_le16(q->id);
 
 	status = be_mcc_notify_wait(adapter);
@@ -1133,12 +1109,8 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_NTWK_INTERFACE_CREATE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_INTERFACE_CREATE, sizeof(*req));
-
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_INTERFACE_CREATE, sizeof(*req), wrb, NULL);
 	req->hdr.domain = domain;
 	req->capability_flags = cpu_to_le32(cap_flags);
 	req->enable_flags = cpu_to_le32(en_flags);
@@ -1182,12 +1154,8 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id, u32 domain)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_NTWK_INTERFACE_DESTROY);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_INTERFACE_DESTROY, sizeof(*req));
-
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_INTERFACE_DESTROY, sizeof(*req), wrb, NULL);
 	req->hdr.domain = domain;
 	req->interface_id = cpu_to_le32(interface_id);
 
@@ -1205,7 +1173,6 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_hdr *hdr;
-	struct be_sge *sge;
 	int status = 0;
 
 	if (MODULO(adapter->work_counter, be_get_temp_freq) == 0)
@@ -1219,22 +1186,13 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 		goto err;
 	}
 	hdr = nonemb_cmd->va;
-	sge = nonembedded_sgl(wrb);
 
-	be_wrb_hdr_prepare(wrb, nonemb_cmd->size, false, 1,
-			OPCODE_ETH_GET_STATISTICS);
-
-	be_cmd_hdr_prepare(hdr, CMD_SUBSYSTEM_ETH,
-		OPCODE_ETH_GET_STATISTICS, nonemb_cmd->size);
+	be_wrb_cmd_hdr_prepare(hdr, CMD_SUBSYSTEM_ETH,
+		OPCODE_ETH_GET_STATISTICS, nonemb_cmd->size, wrb, nonemb_cmd);
 
 	if (adapter->generation == BE_GEN3)
 		hdr->version = 1;
 
-	wrb->tag1 = CMD_SUBSYSTEM_ETH;
-	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
-	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(nonemb_cmd->size);
-
 	be_mcc_notify(adapter);
 	adapter->stats_cmd_sent = true;
 
@@ -1250,7 +1208,6 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 
 	struct be_mcc_wrb *wrb;
 	struct lancer_cmd_req_pport_stats *req;
-	struct be_sge *sge;
 	int status = 0;
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -1261,23 +1218,14 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 		goto err;
 	}
 	req = nonemb_cmd->va;
-	sge = nonembedded_sgl(wrb);
-
-	be_wrb_hdr_prepare(wrb, nonemb_cmd->size, false, 1,
-			OPCODE_ETH_GET_PPORT_STATS);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
-			OPCODE_ETH_GET_PPORT_STATS, nonemb_cmd->size);
 
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+			OPCODE_ETH_GET_PPORT_STATS, nonemb_cmd->size, wrb,
+			nonemb_cmd);
 
 	req->cmd_params.params.pport_num = cpu_to_le16(adapter->port_num);
 	req->cmd_params.params.reset_stats = 0;
 
-	wrb->tag1 = CMD_SUBSYSTEM_ETH;
-	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
-	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(nonemb_cmd->size);
-
 	be_mcc_notify(adapter);
 	adapter->stats_cmd_sent = true;
 
@@ -1303,11 +1251,8 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_NTWK_LINK_STATUS_QUERY);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req), wrb, NULL);
 
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
@@ -1343,11 +1288,9 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES, sizeof(*req),
+		wrb, NULL);
 
 	wrb->tag1 = mccq_index;
 
@@ -1374,11 +1317,8 @@ int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_MANAGE_FAT);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_MANAGE_FAT, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_MANAGE_FAT, sizeof(*req), wrb, NULL);
 	req->fat_operation = cpu_to_le32(QUERY_FAT);
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
@@ -1397,7 +1337,6 @@ void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 	struct be_dma_mem get_fat_cmd;
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_fat *req;
-	struct be_sge *sge;
 	u32 offset = 0, total_size, buf_size,
 				log_offset = sizeof(u32), payload_len;
 	int status;
@@ -1430,18 +1369,11 @@ void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 			goto err;
 		}
 		req = get_fat_cmd.va;
-		sge = nonembedded_sgl(wrb);
 
 		payload_len = sizeof(struct be_cmd_req_get_fat) + buf_size;
-		be_wrb_hdr_prepare(wrb, payload_len, false, 1,
-				OPCODE_COMMON_MANAGE_FAT);
-
-		be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-				OPCODE_COMMON_MANAGE_FAT, payload_len);
-
-		sge->pa_hi = cpu_to_le32(upper_32_bits(get_fat_cmd.dma));
-		sge->pa_lo = cpu_to_le32(get_fat_cmd.dma & 0xFFFFFFFF);
-		sge->len = cpu_to_le32(get_fat_cmd.size);
+		be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+				OPCODE_COMMON_MANAGE_FAT, payload_len, wrb,
+				&get_fat_cmd);
 
 		req->fat_operation = cpu_to_le32(RETRIEVE_FAT);
 		req->read_log_offset = cpu_to_le32(log_offset);
@@ -1485,11 +1417,9 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
 	}
 
 	req = embedded_payload(wrb);
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-				OPCODE_COMMON_GET_FW_VERSION);
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-				OPCODE_COMMON_GET_FW_VERSION, sizeof(*req));
 
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_GET_FW_VERSION, sizeof(*req), wrb, NULL);
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
@@ -1520,11 +1450,8 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_MODIFY_EQ_DELAY);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_MODIFY_EQ_DELAY, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_MODIFY_EQ_DELAY, sizeof(*req), wrb, NULL);
 
 	req->num_eq = cpu_to_le32(1);
 	req->delay[0].eq_id = cpu_to_le32(eq_id);
@@ -1555,11 +1482,8 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_NTWK_VLAN_CONFIG);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_VLAN_CONFIG, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_VLAN_CONFIG, sizeof(*req), wrb, NULL);
 
 	req->interface_id = if_id;
 	req->promiscuous = promiscuous;
@@ -1582,7 +1506,6 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 	struct be_mcc_wrb *wrb;
 	struct be_dma_mem *mem = &adapter->rx_filter;
 	struct be_cmd_req_rx_filter *req = mem->va;
-	struct be_sge *sge;
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -1592,16 +1515,10 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 		status = -EBUSY;
 		goto err;
 	}
-	sge = nonembedded_sgl(wrb);
-	sge->pa_hi = cpu_to_le32(upper_32_bits(mem->dma));
-	sge->pa_lo = cpu_to_le32(mem->dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(mem->size);
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
-				OPCODE_COMMON_NTWK_RX_FILTER);
-
 	memset(req, 0, sizeof(*req));
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-				OPCODE_COMMON_NTWK_RX_FILTER, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+				OPCODE_COMMON_NTWK_RX_FILTER, sizeof(*req),
+				wrb, mem);
 
 	req->if_id = cpu_to_le32(adapter->if_handle);
 	if (flags & IFF_PROMISC) {
@@ -1646,11 +1563,8 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_SET_FLOW_CONTROL);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_SET_FLOW_CONTROL, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_SET_FLOW_CONTROL, sizeof(*req), wrb, NULL);
 
 	req->tx_flow_control = cpu_to_le16((u16)tx_fc);
 	req->rx_flow_control = cpu_to_le16((u16)rx_fc);
@@ -1678,11 +1592,8 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_GET_FLOW_CONTROL);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_GET_FLOW_CONTROL, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_GET_FLOW_CONTROL, sizeof(*req), wrb, NULL);
 
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
@@ -1711,11 +1622,8 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_QUERY_FIRMWARE_CONFIG);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_QUERY_FIRMWARE_CONFIG, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_QUERY_FIRMWARE_CONFIG, sizeof(*req), wrb, NULL);
 
 	status = be_mbox_notify_wait(adapter);
 	if (!status) {
@@ -1742,11 +1650,8 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_FUNCTION_RESET);
-
-	be_cmd_hdr_prepare(req, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_FUNCTION_RESET, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(req, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_FUNCTION_RESET, sizeof(*req), wrb, NULL);
 
 	status = be_mbox_notify_wait(adapter);
 
@@ -1768,11 +1673,8 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-		OPCODE_ETH_RSS_CONFIG);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
-		OPCODE_ETH_RSS_CONFIG, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+		OPCODE_ETH_RSS_CONFIG, sizeof(*req), wrb, NULL);
 
 	req->if_id = cpu_to_le32(adapter->if_handle);
 	req->enable_rss = cpu_to_le16(RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4);
@@ -1804,11 +1706,8 @@ int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_ENABLE_DISABLE_BEACON);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_ENABLE_DISABLE_BEACON, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_ENABLE_DISABLE_BEACON, sizeof(*req), wrb, NULL);
 
 	req->port_num = port_num;
 	req->beacon_state = state;
@@ -1838,11 +1737,8 @@ int be_cmd_get_beacon_state(struct be_adapter *adapter, u8 port_num, u32 *state)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-			OPCODE_COMMON_GET_BEACON_STATE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_GET_BEACON_STATE, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_GET_BEACON_STATE, sizeof(*req), wrb, NULL);
 
 	req->port_num = port_num;
 
@@ -1879,13 +1775,10 @@ int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(struct lancer_cmd_req_write_object),
-			true, 1, OPCODE_COMMON_WRITE_OBJECT);
-	wrb->tag1 = CMD_SUBSYSTEM_COMMON;
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 				OPCODE_COMMON_WRITE_OBJECT,
-				sizeof(struct lancer_cmd_req_write_object));
+				sizeof(struct lancer_cmd_req_write_object), wrb,
+				NULL);
 
 	ctxt = &req->context;
 	AMAP_SET_BITS(struct amap_lancer_write_obj_context,
@@ -1938,7 +1831,6 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_write_flashrom *req;
-	struct be_sge *sge;
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -1950,17 +1842,9 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 		goto err_unlock;
 	}
 	req = cmd->va;
-	sge = nonembedded_sgl(wrb);
-
-	be_wrb_hdr_prepare(wrb, cmd->size, false, 1,
-			OPCODE_COMMON_WRITE_FLASHROM);
-	wrb->tag1 = CMD_SUBSYSTEM_COMMON;
 
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_WRITE_FLASHROM, cmd->size);
-	sge->pa_hi = cpu_to_le32(upper_32_bits(cmd->dma));
-	sge->pa_lo = cpu_to_le32(cmd->dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(cmd->size);
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_WRITE_FLASHROM, cmd->size, wrb, cmd);
 
 	req->params.op_type = cpu_to_le32(flash_type);
 	req->params.op_code = cpu_to_le32(flash_opcode);
@@ -1998,11 +1882,8 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req)+4, true, 0,
-			OPCODE_COMMON_READ_FLASHROM);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_READ_FLASHROM, sizeof(*req)+4);
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_READ_FLASHROM, sizeof(*req)+4, wrb, NULL);
 
 	req->params.op_type = cpu_to_le32(IMG_TYPE_REDBOOT);
 	req->params.op_code = cpu_to_le32(FLASHROM_OPER_REPORT);
@@ -2023,7 +1904,6 @@ int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_acpi_wol_magic_config *req;
-	struct be_sge *sge;
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -2034,19 +1914,12 @@ int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 		goto err;
 	}
 	req = nonemb_cmd->va;
-	sge = nonembedded_sgl(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
-			OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
-		OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
+		OPCODE_ETH_ACPI_WOL_MAGIC_CONFIG, sizeof(*req), wrb,
+		nonemb_cmd);
 	memcpy(req->magic_mac, mac, ETH_ALEN);
 
-	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
-	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(nonemb_cmd->size);
-
 	status = be_mcc_notify_wait(adapter);
 
 err:
@@ -2071,12 +1944,9 @@ int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-				OPCODE_LOWLEVEL_SET_LOOPBACK_MODE);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
-			OPCODE_LOWLEVEL_SET_LOOPBACK_MODE,
-			sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
+			OPCODE_LOWLEVEL_SET_LOOPBACK_MODE, sizeof(*req), wrb,
+			NULL);
 
 	req->src_port = port_num;
 	req->dest_port = port_num;
@@ -2106,11 +1976,8 @@ int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-				OPCODE_LOWLEVEL_LOOPBACK_TEST);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
-			OPCODE_LOWLEVEL_LOOPBACK_TEST, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
+			OPCODE_LOWLEVEL_LOOPBACK_TEST, sizeof(*req), wrb, NULL);
 	req->hdr.timeout = cpu_to_le32(4);
 
 	req->pattern = cpu_to_le64(pattern);
@@ -2136,7 +2003,6 @@ int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_ddrdma_test *req;
-	struct be_sge *sge;
 	int status;
 	int i, j = 0;
 
@@ -2148,15 +2014,8 @@ int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 		goto err;
 	}
 	req = cmd->va;
-	sge = nonembedded_sgl(wrb);
-	be_wrb_hdr_prepare(wrb, cmd->size, false, 1,
-				OPCODE_LOWLEVEL_HOST_DDR_DMA);
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
-			OPCODE_LOWLEVEL_HOST_DDR_DMA, cmd->size);
-
-	sge->pa_hi = cpu_to_le32(upper_32_bits(cmd->dma));
-	sge->pa_lo = cpu_to_le32(cmd->dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(cmd->size);
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
+			OPCODE_LOWLEVEL_HOST_DDR_DMA, cmd->size, wrb, cmd);
 
 	req->pattern = cpu_to_le64(pattern);
 	req->byte_count = cpu_to_le32(byte_cnt);
@@ -2201,15 +2060,9 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 	req = nonemb_cmd->va;
 	sge = nonembedded_sgl(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
-			OPCODE_COMMON_SEEPROM_READ);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			OPCODE_COMMON_SEEPROM_READ, sizeof(*req));
-
-	sge->pa_hi = cpu_to_le32(upper_32_bits(nonemb_cmd->dma));
-	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(nonemb_cmd->size);
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_SEEPROM_READ, sizeof(*req), wrb,
+			nonemb_cmd);
 
 	status = be_mcc_notify_wait(adapter);
 
@@ -2223,7 +2076,6 @@ int be_cmd_get_phy_info(struct be_adapter *adapter,
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_phy_info *req;
-	struct be_sge *sge;
 	struct be_dma_mem cmd;
 	int status;
 
@@ -2244,18 +2096,10 @@ int be_cmd_get_phy_info(struct be_adapter *adapter,
 	}
 
 	req = cmd.va;
-	sge = nonembedded_sgl(wrb);
-
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
-				OPCODE_COMMON_GET_PHY_DETAILS);
 
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			OPCODE_COMMON_GET_PHY_DETAILS,
-			sizeof(*req));
-
-	sge->pa_hi = cpu_to_le32(upper_32_bits(cmd.dma));
-	sge->pa_lo = cpu_to_le32(cmd.dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(cmd.size);
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_GET_PHY_DETAILS, sizeof(*req),
+			wrb, &cmd);
 
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
@@ -2288,11 +2132,8 @@ int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain)
 
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-				OPCODE_COMMON_SET_QOS);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			OPCODE_COMMON_SET_QOS, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_SET_QOS, sizeof(*req), wrb, NULL);
 
 	req->hdr.domain = domain;
 	req->valid_bits = cpu_to_le32(BE_QOS_BITS_NIC);
@@ -2310,7 +2151,6 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_cntl_attribs *req;
 	struct be_cmd_resp_cntl_attribs *resp;
-	struct be_sge *sge;
 	int status;
 	int payload_len = max(sizeof(*req), sizeof(*resp));
 	struct mgmt_controller_attrib *attribs;
@@ -2335,15 +2175,10 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 		goto err;
 	}
 	req = attribs_cmd.va;
-	sge = nonembedded_sgl(wrb);
 
-	be_wrb_hdr_prepare(wrb, payload_len, false, 1,
-			OPCODE_COMMON_GET_CNTL_ATTRIBUTES);
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			 OPCODE_COMMON_GET_CNTL_ATTRIBUTES, payload_len);
-	sge->pa_hi = cpu_to_le32(upper_32_bits(attribs_cmd.dma));
-	sge->pa_lo = cpu_to_le32(attribs_cmd.dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(attribs_cmd.size);
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			 OPCODE_COMMON_GET_CNTL_ATTRIBUTES, payload_len, wrb,
+			&attribs_cmd);
 
 	status = be_mbox_notify_wait(adapter);
 	if (!status) {
@@ -2376,11 +2211,8 @@ int be_cmd_req_native_mode(struct be_adapter *adapter)
 
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
-		OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP);
-
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP, sizeof(*req));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP, sizeof(*req), wrb, NULL);
 
 	req->valid_cap_flags = cpu_to_le32(CAPABILITY_SW_TIMESTAMPS |
 				CAPABILITY_BE3_NATIVE_ERX_API);
-- 
1.5.6.1
