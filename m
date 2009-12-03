From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 1/4] be2net: Changes to print fw command
 opcode when command is failed by controller.
Date: Thu, 3 Dec 2009 21:42:06 +0530
Message-ID: <20091203161155.GA1278@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:49814 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752001AbZLCQL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 11:11:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a firmware command fails, only the failure codes are printed.
It is difficult to co-relate this to the actual command that has failed.
These changes will now print the command code that has failed.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   89 +++++++++++++++++++++++++++---------------
 1 files changed, 57 insertions(+), 32 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 8bd5315..5ec61de 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -71,8 +71,8 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 		extd_status = (compl->status >> CQE_STATUS_EXTD_SHIFT) &
 				CQE_STATUS_EXTD_MASK;
 		dev_warn(&adapter->pdev->dev,
-			"Error in cmd completion: status(compl/extd)=%d/%d\n",
-			compl_status, extd_status);
+		"Error in cmd completion - opcode %d, compl %d, extd %d\n",
+			compl->tag0, compl_status, extd_status);
 	}
 	return compl_status;
 }
@@ -277,7 +277,7 @@ static inline struct be_sge *nonembedded_sgl(struct be_mcc_wrb *wrb)
 
 /* Don't touch the hdr after it's prepared */
 static void be_wrb_hdr_prepare(struct be_mcc_wrb *wrb, int payload_len,
-				bool embedded, u8 sge_cnt)
+				bool embedded, u8 sge_cnt, u32 opcode)
 {
 	if (embedded)
 		wrb->embedded |= MCC_WRB_EMBEDDED_MASK;
@@ -285,6 +285,7 @@ static void be_wrb_hdr_prepare(struct be_mcc_wrb *wrb, int payload_len,
 		wrb->embedded |= (sge_cnt & MCC_WRB_SGE_CNT_MASK) <<
 				MCC_WRB_SGE_CNT_SHIFT;
 	wrb->payload_length = payload_len;
+	wrb->tag0 = opcode;
 	be_dws_cpu_to_le(wrb, 20);
 }
 
@@ -425,7 +426,7 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0, OPCODE_COMMON_EQ_CREATE);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_EQ_CREATE, sizeof(*req));
@@ -469,7 +470,8 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_MAC_QUERY);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_MAC_QUERY, sizeof(*req));
@@ -509,7 +511,8 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_PMAC_ADD);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_PMAC_ADD, sizeof(*req));
@@ -544,7 +547,8 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_PMAC_DEL);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_PMAC_DEL, sizeof(*req));
@@ -576,7 +580,8 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 	req = embedded_payload(wrb);
 	ctxt = &req->context;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_CQ_CREATE);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_CQ_CREATE, sizeof(*req));
@@ -633,7 +638,8 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 	req = embedded_payload(wrb);
 	ctxt = &req->context;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_MCC_CREATE);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 			OPCODE_COMMON_MCC_CREATE, sizeof(*req));
@@ -677,7 +683,8 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 	req = embedded_payload(wrb);
 	ctxt = &req->context;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_ETH_TX_CREATE);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH, OPCODE_ETH_TX_CREATE,
 		sizeof(*req));
@@ -724,7 +731,8 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_ETH_RX_CREATE);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH, OPCODE_ETH_RX_CREATE,
 		sizeof(*req));
@@ -765,8 +773,6 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
-
 	switch (queue_type) {
 	case QTYPE_EQ:
 		subsys = CMD_SUBSYSTEM_COMMON;
@@ -791,6 +797,9 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 	default:
 		BUG();
 	}
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0, opcode);
+
 	be_cmd_hdr_prepare(&req->hdr, subsys, opcode, sizeof(*req));
 	req->id = cpu_to_le16(q->id);
 
@@ -816,7 +825,8 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_INTERFACE_CREATE);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_INTERFACE_CREATE, sizeof(*req));
@@ -851,7 +861,8 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_INTERFACE_DESTROY);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_INTERFACE_DESTROY, sizeof(*req));
@@ -886,8 +897,8 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	req = nonemb_cmd->va;
 	sge = nonembedded_sgl(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1);
-	wrb->tag0 = OPCODE_ETH_GET_STATISTICS;
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+			OPCODE_ETH_GET_STATISTICS);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
 		OPCODE_ETH_GET_STATISTICS, sizeof(*req));
@@ -921,7 +932,8 @@ int be_cmd_link_status_query(struct be_adapter *adapter,
 
 	*link_up = false;
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_LINK_STATUS_QUERY);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req));
@@ -953,7 +965,8 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_GET_FW_VERSION);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FW_VERSION, sizeof(*req));
@@ -986,7 +999,8 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_MODIFY_EQ_DELAY);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_MODIFY_EQ_DELAY, sizeof(*req));
@@ -1020,7 +1034,8 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_VLAN_CONFIG);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_VLAN_CONFIG, sizeof(*req));
@@ -1059,7 +1074,7 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0, OPCODE_ETH_PROMISCUOUS);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
 		OPCODE_ETH_PROMISCUOUS, sizeof(*req));
@@ -1099,7 +1114,8 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 	sge = nonembedded_sgl(wrb);
 	memset(req, 0, sizeof(*req));
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+			OPCODE_COMMON_NTWK_MULTICAST_SET);
 	sge->pa_hi = cpu_to_le32(upper_32_bits(mem->dma));
 	sge->pa_lo = cpu_to_le32(mem->dma & 0xFFFFFFFF);
 	sge->len = cpu_to_le32(mem->size);
@@ -1143,7 +1159,8 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_SET_FLOW_CONTROL);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_SET_FLOW_CONTROL, sizeof(*req));
@@ -1174,7 +1191,8 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_GET_FLOW_CONTROL);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FLOW_CONTROL, sizeof(*req));
@@ -1204,7 +1222,8 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num, u32 *cap)
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_QUERY_FIRMWARE_CONFIG);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_QUERY_FIRMWARE_CONFIG, sizeof(*req));
@@ -1232,7 +1251,8 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	wrb = wrb_from_mbox(adapter);
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_FUNCTION_RESET);
 
 	be_cmd_hdr_prepare(req, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_FUNCTION_RESET, sizeof(*req));
@@ -1260,7 +1280,8 @@ int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_ENABLE_DISABLE_BEACON);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_ENABLE_DISABLE_BEACON, sizeof(*req));
@@ -1293,7 +1314,8 @@ int be_cmd_get_beacon_state(struct be_adapter *adapter, u8 port_num, u32 *state)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_GET_BEACON_STATE);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_BEACON_STATE, sizeof(*req));
@@ -1329,7 +1351,8 @@ int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(struct be_cmd_resp_port_type), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(struct be_cmd_resp_port_type), true, 0,
+			OPCODE_COMMON_READ_TRANSRECV_DATA);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_READ_TRANSRECV_DATA, sizeof(*req));
@@ -1365,7 +1388,8 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	req = cmd->va;
 	sge = nonembedded_sgl(wrb);
 
-	be_wrb_hdr_prepare(wrb, cmd->size, false, 1);
+	be_wrb_hdr_prepare(wrb, cmd->size, false, 1,
+			OPCODE_COMMON_WRITE_FLASHROM);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_WRITE_FLASHROM, cmd->size);
@@ -1399,7 +1423,8 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc)
 	}
 	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req)+4, true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req)+4, true, 0,
+			OPCODE_COMMON_READ_FLASHROM);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_READ_FLASHROM, sizeof(*req)+4);
-- 
1.6.3.3

