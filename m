From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net: fix some cmds to use mccq instead of
	mbox
Date: Thu, 17 Sep 2009 10:13:31 +0530
Message-ID: <20090917044331.GA14568@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:20135 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751243AbZIQEno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 00:43:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All cmds issued to BE after the creation of mccq must now use the mcc-q
(and not mbox) to avoid a hw issue that results in mbox poll timeout.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |  412 ++++++++++++++++++++++++++-----------------
 drivers/net/benet/be_cmds.h |    5 +-
 drivers/net/benet/be_main.c |   42 +++---
 4 files changed, 271 insertions(+), 189 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 13b72ce..684c6fe 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -362,5 +362,6 @@ static inline u8 is_udp_pkt(struct sk_buff *skb)
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
+extern void netdev_stats_update(struct be_adapter *adapter);
 extern int be_load_fw(struct be_adapter *adapter, u8 *func);
 #endif				/* BE_H */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 1db0924..3dd76c4 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -59,15 +59,22 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 
 	compl_status = (compl->status >> CQE_STATUS_COMPL_SHIFT) &
 				CQE_STATUS_COMPL_MASK;
-	if (compl_status != MCC_STATUS_SUCCESS) {
+	if (compl_status == MCC_STATUS_SUCCESS) {
+		if (compl->tag0 == OPCODE_ETH_GET_STATISTICS) {
+			struct be_cmd_resp_get_stats *resp =
+						adapter->stats.cmd.va;
+			be_dws_le_to_cpu(&resp->hw_stats,
+						sizeof(resp->hw_stats));
+			netdev_stats_update(adapter);
+		}
+	} else if (compl_status != MCC_STATUS_NOT_SUPPORTED) {
 		extd_status = (compl->status >> CQE_STATUS_EXTD_SHIFT) &
 				CQE_STATUS_EXTD_MASK;
 		dev_warn(&adapter->pdev->dev,
 			"Error in cmd completion: status(compl/extd)=%d/%d\n",
 			compl_status, extd_status);
-		return -1;
 	}
-	return 0;
+	return compl_status;
 }
 
 /* Link state evt is a string of bytes; no need for endian swapping */
@@ -97,10 +104,10 @@ static struct be_mcc_compl *be_mcc_compl_get(struct be_adapter *adapter)
 	return NULL;
 }
 
-void be_process_mcc(struct be_adapter *adapter)
+int be_process_mcc(struct be_adapter *adapter)
 {
 	struct be_mcc_compl *compl;
-	int num = 0;
+	int num = 0, status = 0;
 
 	spin_lock_bh(&adapter->mcc_cq_lock);
 	while ((compl = be_mcc_compl_get(adapter))) {
@@ -111,38 +118,47 @@ void be_process_mcc(struct be_adapter *adapter)
 			/* Interpret compl as a async link evt */
 			be_async_link_state_process(adapter,
 				(struct be_async_event_link_state *) compl);
-		} else {
-			be_mcc_compl_process(adapter, compl);
-			atomic_dec(&adapter->mcc_obj.q.used);
+		} else if (compl->flags & CQE_FLAGS_COMPLETED_MASK) {
+				status = be_mcc_compl_process(adapter, compl);
+				atomic_dec(&adapter->mcc_obj.q.used);
 		}
 		be_mcc_compl_use(compl);
 		num++;
 	}
+
 	if (num)
 		be_cq_notify(adapter, adapter->mcc_obj.cq.id, true, num);
+
 	spin_unlock_bh(&adapter->mcc_cq_lock);
+	return status;
 }
 
 /* Wait till no more pending mcc requests are present */
-static void be_mcc_wait_compl(struct be_adapter *adapter)
+static int be_mcc_wait_compl(struct be_adapter *adapter)
 {
-#define mcc_timeout		50000 /* 5s timeout */
-	int i;
+#define mcc_timeout		120000 /* 12s timeout */
+	int i, status;
 	for (i = 0; i < mcc_timeout; i++) {
-		be_process_mcc(adapter);
+		status = be_process_mcc(adapter);
+		if (status)
+			return status;
+
 		if (atomic_read(&adapter->mcc_obj.q.used) == 0)
 			break;
 		udelay(100);
 	}
-	if (i == mcc_timeout)
+	if (i == mcc_timeout) {
 		dev_err(&adapter->pdev->dev, "mccq poll timed out\n");
+		return -1;
+	}
+	return 0;
 }
 
 /* Notify MCC requests and wait for completion */
-static void be_mcc_notify_wait(struct be_adapter *adapter)
+static int be_mcc_notify_wait(struct be_adapter *adapter)
 {
 	be_mcc_notify(adapter);
-	be_mcc_wait_compl(adapter);
+	return be_mcc_wait_compl(adapter);
 }
 
 static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
@@ -173,7 +189,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
  * Insert the mailbox address into the doorbell in two steps
  * Polls on the mbox doorbell till a command completion (or a timeout) occurs
  */
-static int be_mbox_notify(struct be_adapter *adapter)
+static int be_mbox_notify_wait(struct be_adapter *adapter)
 {
 	int status;
 	u32 val = 0;
@@ -182,8 +198,6 @@ static int be_mbox_notify(struct be_adapter *adapter)
 	struct be_mcc_mailbox *mbox = mbox_mem->va;
 	struct be_mcc_compl *compl = &mbox->compl;
 
-	memset(compl, 0, sizeof(*compl));
-
 	val |= MPU_MAILBOX_DB_HI_MASK;
 	/* at bits 2 - 31 place mbox dma addr msb bits 34 - 63 */
 	val |= (upper_32_bits(mbox_mem->dma) >> 2) << 2;
@@ -310,34 +324,40 @@ static u32 eq_delay_to_mult(u32 usec_delay)
 	return multiplier;
 }
 
-static inline struct be_mcc_wrb *wrb_from_mbox(struct be_dma_mem *mbox_mem)
+static inline struct be_mcc_wrb *wrb_from_mbox(struct be_adapter *adapter)
 {
-	return &((struct be_mcc_mailbox *)(mbox_mem->va))->wrb;
+	struct be_dma_mem *mbox_mem = &adapter->mbox_mem;
+	struct be_mcc_wrb *wrb
+		= &((struct be_mcc_mailbox *)(mbox_mem->va))->wrb;
+	memset(wrb, 0, sizeof(*wrb));
+	return wrb;
 }
 
-static inline struct be_mcc_wrb *wrb_from_mcc(struct be_queue_info *mccq)
+static struct be_mcc_wrb *wrb_from_mccq(struct be_adapter *adapter)
 {
-	struct be_mcc_wrb *wrb = NULL;
-	if (atomic_read(&mccq->used) < mccq->len) {
-		wrb = queue_head_node(mccq);
-		queue_head_inc(mccq);
-		atomic_inc(&mccq->used);
-		memset(wrb, 0, sizeof(*wrb));
-	}
+	struct be_queue_info *mccq = &adapter->mcc_obj.q;
+	struct be_mcc_wrb *wrb;
+
+	BUG_ON(atomic_read(&mccq->used) >= mccq->len);
+	wrb = queue_head_node(mccq);
+	queue_head_inc(mccq);
+	atomic_inc(&mccq->used);
+	memset(wrb, 0, sizeof(*wrb));
 	return wrb;
 }
 
 int be_cmd_eq_create(struct be_adapter *adapter,
 		struct be_queue_info *eq, int eq_delay)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_eq_create *req = embedded_payload(wrb);
-	struct be_cmd_resp_eq_create *resp = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_eq_create *req;
 	struct be_dma_mem *q_mem = &eq->dma_mem;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -359,25 +379,29 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
+		struct be_cmd_resp_eq_create *resp = embedded_payload(wrb);
 		eq->id = le16_to_cpu(resp->eq_id);
 		eq->created = true;
 	}
+
 	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
+/* Uses mbox */
 int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 			u8 type, bool permanent, u32 if_handle)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_mac_query *req = embedded_payload(wrb);
-	struct be_cmd_resp_mac_query *resp = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_mac_query *req;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -388,27 +412,32 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	if (permanent) {
 		req->permanent = 1;
 	} else {
-		req->if_id = cpu_to_le16((u16)if_handle);
+		req->if_id = cpu_to_le16((u16) if_handle);
 		req->permanent = 0;
 	}
 
-	status = be_mbox_notify(adapter);
-	if (!status)
+	status = be_mbox_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_mac_query *resp = embedded_payload(wrb);
 		memcpy(mac_addr, resp->mac.addr, ETH_ALEN);
+	}
 
 	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
+/* Uses synchronous MCCQ */
 int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 		u32 if_id, u32 *pmac_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_pmac_add *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_pmac_add *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -418,24 +447,27 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	req->if_id = cpu_to_le32(if_id);
 	memcpy(req->mac_address, mac_addr, ETH_ALEN);
 
-	status = be_mbox_notify(adapter);
+	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_pmac_add *resp = embedded_payload(wrb);
 		*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
+/* Uses synchronous MCCQ */
 int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_pmac_del *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_pmac_del *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -445,25 +477,29 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 	req->if_id = cpu_to_le32(if_id);
 	req->pmac_id = cpu_to_le32(pmac_id);
 
-	status = be_mbox_notify(adapter);
-	spin_unlock(&adapter->mbox_lock);
+	status = be_mcc_notify_wait(adapter);
+
+	spin_unlock_bh(&adapter->mcc_lock);
 
 	return status;
 }
 
+/* Uses Mbox */
 int be_cmd_cq_create(struct be_adapter *adapter,
 		struct be_queue_info *cq, struct be_queue_info *eq,
 		bool sol_evts, bool no_delay, int coalesce_wm)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_cq_create *req = embedded_payload(wrb);
-	struct be_cmd_resp_cq_create *resp = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_cq_create *req;
 	struct be_dma_mem *q_mem = &cq->dma_mem;
-	void *ctxt = &req->context;
+	void *ctxt;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
+	ctxt = &req->context;
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -486,11 +522,13 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
+		struct be_cmd_resp_cq_create *resp = embedded_payload(wrb);
 		cq->id = le16_to_cpu(resp->cq_id);
 		cq->created = true;
 	}
+
 	spin_unlock(&adapter->mbox_lock);
 
 	return status;
@@ -508,14 +546,17 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 			struct be_queue_info *mccq,
 			struct be_queue_info *cq)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_mcc_create *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_mcc_create *req;
 	struct be_dma_mem *q_mem = &mccq->dma_mem;
-	void *ctxt = &req->context;
+	void *ctxt;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
+	ctxt = &req->context;
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -534,7 +575,7 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_mcc_create *resp = embedded_payload(wrb);
 		mccq->id = le16_to_cpu(resp->id);
@@ -549,15 +590,17 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 			struct be_queue_info *txq,
 			struct be_queue_info *cq)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_eth_tx_create *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_eth_tx_create *req;
 	struct be_dma_mem *q_mem = &txq->dma_mem;
-	void *ctxt = &req->context;
+	void *ctxt;
 	int status;
-	u32 len_encoded;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
+	ctxt = &req->context;
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -568,10 +611,8 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 	req->ulp_num = BE_ULP1_NUM;
 	req->type = BE_ETH_TX_RING_TYPE_STANDARD;
 
-	len_encoded = fls(txq->len); /* log2(len) + 1 */
-	if (len_encoded == 16)
-		len_encoded = 0;
-	AMAP_SET_BITS(struct amap_tx_context, tx_ring_size, ctxt, len_encoded);
+	AMAP_SET_BITS(struct amap_tx_context, tx_ring_size, ctxt,
+		be_encoded_q_len(txq->len));
 	AMAP_SET_BITS(struct amap_tx_context, pci_func_id, ctxt,
 			be_pci_func(adapter));
 	AMAP_SET_BITS(struct amap_tx_context, ctx_valid, ctxt, 1);
@@ -581,28 +622,32 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_eth_tx_create *resp = embedded_payload(wrb);
 		txq->id = le16_to_cpu(resp->cid);
 		txq->created = true;
 	}
+
 	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
+/* Uses mbox */
 int be_cmd_rxq_create(struct be_adapter *adapter,
 		struct be_queue_info *rxq, u16 cq_id, u16 frag_size,
 		u16 max_frame_size, u32 if_id, u32 rss)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_eth_rx_create *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_eth_rx_create *req;
 	struct be_dma_mem *q_mem = &rxq->dma_mem;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -617,29 +662,34 @@ int be_cmd_rxq_create(struct be_adapter *adapter,
 	req->max_frame_size = cpu_to_le16(max_frame_size);
 	req->rss_queue = cpu_to_le32(rss);
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_eth_rx_create *resp = embedded_payload(wrb);
 		rxq->id = le16_to_cpu(resp->id);
 		rxq->created = true;
 	}
+
 	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
-/* Generic destroyer function for all types of queues */
+/* Generic destroyer function for all types of queues
+ * Uses Mbox
+ */
 int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 		int queue_type)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_q_destroy *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_q_destroy *req;
 	u8 subsys = 0, opcode = 0;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
 
-	memset(wrb, 0, sizeof(*wrb));
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
+
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
 	switch (queue_type) {
@@ -669,23 +719,27 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 	be_cmd_hdr_prepare(&req->hdr, subsys, opcode, sizeof(*req));
 	req->id = cpu_to_le16(q->id);
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
-/* Create an rx filtering policy configuration on an i/f */
+/* Create an rx filtering policy configuration on an i/f
+ * Uses mbox
+ */
 int be_cmd_if_create(struct be_adapter *adapter, u32 flags, u8 *mac,
 		bool pmac_invalid, u32 *if_handle, u32 *pmac_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_if_create *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_if_create *req;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -694,10 +748,11 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 flags, u8 *mac,
 
 	req->capability_flags = cpu_to_le32(flags);
 	req->enable_flags = cpu_to_le32(flags);
+	req->pmac_invalid = pmac_invalid;
 	if (!pmac_invalid)
 		memcpy(req->mac_addr, mac, ETH_ALEN);
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_if_create *resp = embedded_payload(wrb);
 		*if_handle = le32_to_cpu(resp->interface_id);
@@ -709,14 +764,17 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 flags, u8 *mac,
 	return status;
 }
 
+/* Uses mbox */
 int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_if_destroy *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_if_destroy *req;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -724,7 +782,8 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 		OPCODE_COMMON_NTWK_INTERFACE_DESTROY, sizeof(*req));
 
 	req->interface_id = cpu_to_le32(interface_id);
-	status = be_mbox_notify(adapter);
+
+	status = be_mbox_notify_wait(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 
@@ -733,20 +792,22 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 
 /* Get stats is a non embedded command: the request is not embedded inside
  * WRB but is a separate dma memory block
+ * Uses asynchronous MCC
  */
 int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_get_stats *req = nonemb_cmd->va;
-	struct be_sge *sge = nonembedded_sgl(wrb);
-	int status;
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_stats *req;
+	struct be_sge *sge;
 
-	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&adapter->mcc_lock);
 
-	memset(req, 0, sizeof(*req));
+	wrb = wrb_from_mccq(adapter);
+	req = nonemb_cmd->va;
+	sge = nonembedded_sgl(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1);
+	wrb->tag0 = OPCODE_ETH_GET_STATISTICS;
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
 		OPCODE_ETH_GET_STATISTICS, sizeof(*req));
@@ -754,59 +815,61 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
 	sge->len = cpu_to_le32(nonemb_cmd->size);
 
-	status = be_mbox_notify(adapter);
-	if (!status) {
-		struct be_cmd_resp_get_stats *resp = nonemb_cmd->va;
-		be_dws_le_to_cpu(&resp->hw_stats, sizeof(resp->hw_stats));
-	}
+	be_mcc_notify(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
-	return status;
+	spin_unlock_bh(&adapter->mcc_lock);
+	return 0;
 }
 
+/* Uses synchronous mcc */
 int be_cmd_link_status_query(struct be_adapter *adapter,
 			bool *link_up)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_link_status *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_link_status *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
 
 	*link_up = false;
-	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req));
 
-	status = be_mbox_notify(adapter);
+	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
 		if (resp->mac_speed != PHY_LINK_SPEED_ZERO)
 			*link_up = true;
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
+/* Uses Mbox */
 int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_get_fw_version *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_fw_version *req;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FW_VERSION, sizeof(*req));
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
 		strncpy(fw_ver, resp->firmware_version_string, FW_VER_LEN);
@@ -816,15 +879,18 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 	return status;
 }
 
-/* set the EQ delay interval of an EQ to specified value */
+/* set the EQ delay interval of an EQ to specified value
+ * Uses async mcc
+ */
 int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_modify_eq_delay *req = embedded_payload(wrb);
-	int status;
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_modify_eq_delay *req;
 
-	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -836,21 +902,24 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 	req->delay[0].phase = 0;
 	req->delay[0].delay_multiplier = cpu_to_le32(eqd);
 
-	status = be_mbox_notify(adapter);
+	be_mcc_notify(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
-	return status;
+	spin_unlock_bh(&adapter->mcc_lock);
+	return 0;
 }
 
+/* Uses sycnhronous mcc */
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 			u32 num, bool untagged, bool promiscuous)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_vlan_config *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_vlan_config *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -866,23 +935,24 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 			req->num_vlan * sizeof(vtag_array[0]));
 	}
 
-	status = be_mbox_notify(adapter);
+	status = be_mcc_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
-/* Use MCC for this command as it may be called in BH context */
+/* Uses MCC for this command as it may be called in BH context
+ * Uses synchronous mcc
+ */
 int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_promiscuous_config *req;
+	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mcc(&adapter->mcc_obj.q);
-	BUG_ON(!wrb);
-
+	wrb = wrb_from_mccq(adapter);
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -895,14 +965,14 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 	else
 		req->port0_promiscuous = en;
 
-	be_mcc_notify_wait(adapter);
+	status = be_mcc_notify_wait(adapter);
 
 	spin_unlock_bh(&adapter->mcc_lock);
-	return 0;
+	return status;
 }
 
 /*
- * Use MCC for this command as it may be called in BH context
+ * Uses MCC for this command as it may be called in BH context
  * (mc == NULL) => multicast promiscous
  */
 int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
@@ -914,9 +984,7 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 
 	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mcc(&adapter->mcc_obj.q);
-	BUG_ON(!wrb);
-
+	wrb = wrb_from_mccq(adapter);
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -944,15 +1012,17 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 	return 0;
 }
 
+/* Uses synchrounous mcc */
 int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_set_flow_control *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_flow_control *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	spin_lock_bh(&adapter->mcc_lock);
 
-	memset(wrb, 0, sizeof(*wrb));
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -962,28 +1032,30 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 	req->tx_flow_control = cpu_to_le16((u16)tx_fc);
 	req->rx_flow_control = cpu_to_le16((u16)rx_fc);
 
-	status = be_mbox_notify(adapter);
+	status = be_mcc_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
+/* Uses sycn mcc */
 int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_get_flow_control *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_flow_control *req;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
+	spin_lock_bh(&adapter->mcc_lock);
 
-	memset(wrb, 0, sizeof(*wrb));
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FLOW_CONTROL, sizeof(*req));
 
-	status = be_mbox_notify(adapter);
+	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_flow_control *resp =
 						embedded_payload(wrb);
@@ -991,26 +1063,28 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 		*rx_fc = le16_to_cpu(resp->rx_flow_control);
 	}
 
-	spin_unlock(&adapter->mbox_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
+/* Uses mbox */
 int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_query_fw_cfg *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_query_fw_cfg *req;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
 
-	memset(wrb, 0, sizeof(*wrb));
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_QUERY_FIRMWARE_CONFIG, sizeof(*req));
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
 		*port_num = le32_to_cpu(resp->phys_port);
@@ -1020,22 +1094,24 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num)
 	return status;
 }
 
+/* Uses mbox */
 int be_cmd_reset_function(struct be_adapter *adapter)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
-	struct be_cmd_req_hdr *req = embedded_payload(wrb);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_hdr *req;
 	int status;
 
 	spin_lock(&adapter->mbox_lock);
 
-	memset(wrb, 0, sizeof(*wrb));
+	wrb = wrb_from_mbox(adapter);
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
 	be_cmd_hdr_prepare(req, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_FUNCTION_RESET, sizeof(*req));
 
-	status = be_mbox_notify(adapter);
+	status = be_mbox_notify_wait(adapter);
 
 	spin_unlock(&adapter->mbox_lock);
 	return status;
@@ -1044,13 +1120,17 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			u32 flash_type, u32 flash_opcode, u32 buf_size)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
+	struct be_mcc_wrb *wrb;
 	struct be_cmd_write_flashrom *req = cmd->va;
-	struct be_sge *sge = nonembedded_sgl(wrb);
+	struct be_sge *sge;
 	int status;
 
-	spin_lock(&adapter->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
+	sge = nonembedded_sgl(wrb);
+
 	be_wrb_hdr_prepare(wrb, cmd->size, false, 1);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
@@ -1063,8 +1143,8 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	req->params.op_code = cpu_to_le32(flash_opcode);
 	req->params.data_buf_size = cpu_to_le32(buf_size);
 
-	status = be_mbox_notify(adapter);
+	status = be_mcc_notify_wait(adapter);
 
-	spin_unlock(&adapter->mbox_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index fd7028e..93e432f 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -61,7 +61,8 @@ enum {
 /* The command is completing because the queue was getting flushed */
 	MCC_STATUS_QUEUE_FLUSHING = 0x4,
 /* The command is completing with a DMA error */
-	MCC_STATUS_DMA_FAILED = 0x5
+	MCC_STATUS_DMA_FAILED = 0x5,
+	MCC_STATUS_NOT_SUPPORTED = 0x66
 };
 
 #define CQE_STATUS_COMPL_MASK		0xFFFF
@@ -761,7 +762,7 @@ extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 			u32 *tx_fc, u32 *rx_fc);
 extern int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
-extern void be_process_mcc(struct be_adapter *adapter);
+extern int be_process_mcc(struct be_adapter *adapter);
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ce11bba..409cf05 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -135,7 +135,7 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	return status;
 }
 
-static void netdev_stats_update(struct be_adapter *adapter)
+void netdev_stats_update(struct be_adapter *adapter)
 {
 	struct be_hw_stats *hw_stats = hw_stats_from_cmd(adapter->stats.cmd.va);
 	struct be_rxf_stats *rxf_stats = &hw_stats->rxf;
@@ -431,8 +431,7 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 }
 
 static netdev_tx_t be_xmit(struct sk_buff *skb,
-				 struct net_device *netdev)
-
+			struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_tx_obj *tx_obj = &adapter->tx_obj;
@@ -490,11 +489,11 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
  * program them in BE.  If more than BE_NUM_VLANS_SUPPORTED are configured,
  * set the BE in promiscuous VLAN mode.
  */
-static void be_vid_config(struct net_device *netdev)
+static int be_vid_config(struct be_adapter *adapter)
 {
-	struct be_adapter *adapter = netdev_priv(netdev);
 	u16 vtag[BE_NUM_VLANS_SUPPORTED];
 	u16 ntags = 0, i;
+	int status;
 
 	if (adapter->num_vlans <= BE_NUM_VLANS_SUPPORTED)  {
 		/* Construct VLAN Table to give to HW */
@@ -504,12 +503,13 @@ static void be_vid_config(struct net_device *netdev)
 				ntags++;
 			}
 		}
-		be_cmd_vlan_config(adapter, adapter->if_handle,
-			vtag, ntags, 1, 0);
+		status = be_cmd_vlan_config(adapter, adapter->if_handle,
+					vtag, ntags, 1, 0);
 	} else {
-		be_cmd_vlan_config(adapter, adapter->if_handle,
-			NULL, 0, 1, 1);
+		status = be_cmd_vlan_config(adapter, adapter->if_handle,
+					NULL, 0, 1, 1);
 	}
+	return status;
 }
 
 static void be_vlan_register(struct net_device *netdev, struct vlan_group *grp)
@@ -532,7 +532,7 @@ static void be_vlan_add_vid(struct net_device *netdev, u16 vid)
 	adapter->num_vlans++;
 	adapter->vlan_tag[vid] = 1;
 
-	be_vid_config(netdev);
+	be_vid_config(adapter);
 }
 
 static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
@@ -543,7 +543,7 @@ static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 	adapter->vlan_tag[vid] = 0;
 
 	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
-	be_vid_config(netdev);
+	be_vid_config(adapter);
 }
 
 static void be_set_multicast_list(struct net_device *netdev)
@@ -1444,12 +1444,8 @@ static void be_worker(struct work_struct *work)
 {
 	struct be_adapter *adapter =
 		container_of(work, struct be_adapter, work.work);
-	int status;
 
-	/* Get Stats */
-	status = be_cmd_get_stats(adapter, &adapter->stats.cmd);
-	if (!status)
-		netdev_stats_update(adapter);
+	be_cmd_get_stats(adapter, &adapter->stats.cmd);
 
 	/* Set EQ delay */
 	be_rx_eqd_update(adapter);
@@ -1622,11 +1618,6 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto do_none;
 
-	be_vid_config(netdev);
-
-	status = be_cmd_set_flow_control(adapter, true, true);
-	if (status != 0)
-		goto if_destroy;
 
 	status = be_tx_queues_create(adapter);
 	if (status != 0)
@@ -1640,8 +1631,17 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto rx_qs_destroy;
 
+	status = be_vid_config(adapter);
+	if (status != 0)
+		goto mccqs_destroy;
+
+	status = be_cmd_set_flow_control(adapter, true, true);
+	if (status != 0)
+		goto mccqs_destroy;
 	return 0;
 
+mccqs_destroy:
+	be_mcc_queues_destroy(adapter);
 rx_qs_destroy:
 	be_rx_queues_destroy(adapter);
 tx_qs_destroy:
-- 
1.6.0.4

