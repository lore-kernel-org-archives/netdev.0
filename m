From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 4/5] be2net: some name changes for consistency
Date: Tue, 28 Jul 2009 14:23:10 +0530
Message-ID: <20090728085310.GA5009@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:4645 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752212AbZG1IxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:53:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_mbox_db_ring() has been changed to be_mbox_notify() (to be consistent with
be_mcc_notify()) and struct be_mcc_cq_entry changed to be_mcc_compl
to be consistent with rx/tx_compl.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   62 +++++++++++++++++++++---------------------
 drivers/net/benet/be_cmds.h |    4 +-
 drivers/net/benet/be_main.c |    2 +-
 3 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 7c1724e..ebf65c7 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -31,7 +31,7 @@ static void be_mcc_notify(struct be_adapter *adapter)
 /* To check if valid bit is set, check the entire word as we don't know
  * the endianness of the data (old entry is host endian while a new entry is
  * little endian) */
-static inline bool be_mcc_compl_is_new(struct be_mcc_cq_entry *compl)
+static inline bool be_mcc_compl_is_new(struct be_mcc_compl *compl)
 {
 	if (compl->flags != 0) {
 		compl->flags = le32_to_cpu(compl->flags);
@@ -43,13 +43,13 @@ static inline bool be_mcc_compl_is_new(struct be_mcc_cq_entry *compl)
 }
 
 /* Need to reset the entire word that houses the valid bit */
-static inline void be_mcc_compl_use(struct be_mcc_cq_entry *compl)
+static inline void be_mcc_compl_use(struct be_mcc_compl *compl)
 {
 	compl->flags = 0;
 }
 
 static int be_mcc_compl_process(struct be_adapter *adapter,
-	struct be_mcc_cq_entry *compl)
+	struct be_mcc_compl *compl)
 {
 	u16 compl_status, extd_status;
 
@@ -85,10 +85,10 @@ static inline bool is_link_state_evt(u32 trailer)
 				ASYNC_EVENT_CODE_LINK_STATE);
 }
 
-static struct be_mcc_cq_entry *be_mcc_compl_get(struct be_adapter *adapter)
+static struct be_mcc_compl *be_mcc_compl_get(struct be_adapter *adapter)
 {
 	struct be_queue_info *mcc_cq = &adapter->mcc_obj.cq;
-	struct be_mcc_cq_entry *compl = queue_tail_node(mcc_cq);
+	struct be_mcc_compl *compl = queue_tail_node(mcc_cq);
 
 	if (be_mcc_compl_is_new(compl)) {
 		queue_tail_inc(mcc_cq);
@@ -99,7 +99,7 @@ static struct be_mcc_cq_entry *be_mcc_compl_get(struct be_adapter *adapter)
 
 void be_process_mcc(struct be_adapter *adapter)
 {
-	struct be_mcc_cq_entry *compl;
+	struct be_mcc_compl *compl;
 	int num = 0;
 
 	spin_lock_bh(&adapter->mcc_cq_lock);
@@ -173,16 +173,16 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
  * Insert the mailbox address into the doorbell in two steps
  * Polls on the mbox doorbell till a command completion (or a timeout) occurs
  */
-static int be_mbox_db_ring(struct be_adapter *adapter)
+static int be_mbox_notify(struct be_adapter *adapter)
 {
 	int status;
 	u32 val = 0;
 	void __iomem *db = adapter->db + MPU_MAILBOX_DB_OFFSET;
 	struct be_dma_mem *mbox_mem = &adapter->mbox_mem;
 	struct be_mcc_mailbox *mbox = mbox_mem->va;
-	struct be_mcc_cq_entry *cqe = &mbox->cqe;
+	struct be_mcc_compl *compl = &mbox->compl;
 
-	memset(cqe, 0, sizeof(*cqe));
+	memset(compl, 0, sizeof(*compl));
 
 	val |= MPU_MAILBOX_DB_HI_MASK;
 	/* at bits 2 - 31 place mbox dma addr msb bits 34 - 63 */
@@ -204,9 +204,9 @@ static int be_mbox_db_ring(struct be_adapter *adapter)
 		return status;
 
 	/* A cq entry has been made now */
-	if (be_mcc_compl_is_new(cqe)) {
-		status = be_mcc_compl_process(adapter, &mbox->cqe);
-		be_mcc_compl_use(cqe);
+	if (be_mcc_compl_is_new(compl)) {
+		status = be_mcc_compl_process(adapter, &mbox->compl);
+		be_mcc_compl_use(compl);
 		if (status)
 			return status;
 	} else {
@@ -396,7 +396,7 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		eq->id = le16_to_cpu(resp->eq_id);
 		eq->created = true;
@@ -429,7 +429,7 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 		req->permanent = 0;
 	}
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status)
 		memcpy(mac_addr, resp->mac.addr, ETH_ALEN);
 
@@ -455,7 +455,7 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	req->if_id = cpu_to_le32(if_id);
 	memcpy(req->mac_address, mac_addr, ETH_ALEN);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_pmac_add *resp = embedded_payload(wrb);
 		*pmac_id = le32_to_cpu(resp->pmac_id);
@@ -482,7 +482,7 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 	req->if_id = cpu_to_le32(if_id);
 	req->pmac_id = cpu_to_le32(pmac_id);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	spin_unlock(&adapter->mbox_lock);
 
 	return status;
@@ -523,7 +523,7 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		cq->id = le16_to_cpu(resp->cq_id);
 		cq->created = true;
@@ -571,7 +571,7 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_mcc_create *resp = embedded_payload(wrb);
 		mccq->id = le16_to_cpu(resp->id);
@@ -618,7 +618,7 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_eth_tx_create *resp = embedded_payload(wrb);
 		txq->id = le16_to_cpu(resp->cid);
@@ -654,7 +654,7 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 	req->max_frame_size = cpu_to_le16(max_frame_size);
 	req->rss_queue = cpu_to_le32(rss);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_eth_rx_create *resp = embedded_payload(wrb);
 		rxq->id = le16_to_cpu(resp->id);
@@ -706,7 +706,7 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 	be_cmd_hdr_prepare(&req->hdr, subsys, opcode, sizeof(*req));
 	req->id = cpu_to_le16(q->id);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 
@@ -734,7 +734,7 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 flags, u8 *mac,
 	if (!pmac_invalid)
 		memcpy(req->mac_addr, mac, ETH_ALEN);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_if_create *resp = embedded_payload(wrb);
 		*if_handle = le32_to_cpu(resp->interface_id);
@@ -761,7 +761,7 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 		OPCODE_COMMON_NTWK_INTERFACE_DESTROY, sizeof(*req));
 
 	req->interface_id = cpu_to_le32(interface_id);
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 
@@ -791,7 +791,7 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
 	sge->len = cpu_to_le32(nonemb_cmd->size);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_stats *resp = nonemb_cmd->va;
 		be_dws_le_to_cpu(&resp->hw_stats, sizeof(resp->hw_stats));
@@ -818,7 +818,7 @@ int be_cmd_link_status_query(struct be_adapter *adapter,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req));
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
 		if (resp->mac_speed != PHY_LINK_SPEED_ZERO)
@@ -843,7 +843,7 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FW_VERSION, sizeof(*req));
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
 		strncpy(fw_ver, resp->firmware_version_string, FW_VER_LEN);
@@ -873,7 +873,7 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 	req->delay[0].phase = 0;
 	req->delay[0].delay_multiplier = cpu_to_le32(eqd);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 	return status;
@@ -903,7 +903,7 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 			req->num_vlan * sizeof(vtag_array[0]));
 	}
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 	return status;
@@ -999,7 +999,7 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 	req->tx_flow_control = cpu_to_le16((u16)tx_fc);
 	req->rx_flow_control = cpu_to_le16((u16)rx_fc);
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 	return status;
@@ -1020,7 +1020,7 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FLOW_CONTROL, sizeof(*req));
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_flow_control *resp =
 						embedded_payload(wrb);
@@ -1047,7 +1047,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_QUERY_FIRMWARE_CONFIG, sizeof(*req));
 
-	status = be_mbox_db_ring(adapter);
+	status = be_mbox_notify(adapter);
 	if (!status) {
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
 		*port_num = le32_to_cpu(resp->phys_port);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 164ab92..5c5de35 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -69,7 +69,7 @@ enum {
 #define CQE_STATUS_EXTD_MASK		0xFFFF
 #define CQE_STATUS_EXTD_SHIFT		0	/* bits 0 - 15 */
 
-struct be_mcc_cq_entry {
+struct be_mcc_compl {
 	u32 status;		/* dword 0 */
 	u32 tag0;		/* dword 1 */
 	u32 tag1;		/* dword 2 */
@@ -106,7 +106,7 @@ struct be_async_event_link_state {
 
 struct be_mcc_mailbox {
 	struct be_mcc_wrb wrb;
-	struct be_mcc_cq_entry cqe;
+	struct be_mcc_compl compl;
 };
 
 #define CMD_SUBSYSTEM_COMMON	0x1
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ab5fcc0..ef82a52 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1058,7 +1058,7 @@ static int be_mcc_queues_create(struct be_adapter *adapter)
 	/* Alloc MCC compl queue */
 	cq = &adapter->mcc_obj.cq;
 	if (be_queue_alloc(adapter, cq, MCC_CQ_LEN,
-			sizeof(struct be_mcc_cq_entry)))
+			sizeof(struct be_mcc_compl)))
 		goto err;
 
 	/* Ask BE to create MCC compl queue; share TX's eq */
-- 
1.6.0.4

