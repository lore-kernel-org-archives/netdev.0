From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 1/4] be2net: Add MCC queue mechanism for BE cmds
Date: Thu, 18 Jun 2009 15:32:59 +0530
Message-ID: <20090618100259.GA12667@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:13656 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753298AbZFRKDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 06:03:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currenlty all cmds use the blocking MCC mbox to post cmds. An mbox cmd is protected
via a spin_lock(cmd_lock) and not spin_lock_bh() as it is undesirable
to disable BHs while a blocking mbox cmd is in progress (and take long to finish.)
This can lockup a cmd in progress in process context. Instead cmds that may be
called in BH context must use the MCC queue to post cmds. The cmd completions
are rcvd in a separate completion queue and the events are placed in the tx-event
queue.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |   95 +++++++++++-----
 drivers/net/benet/be_cmds.c |  258 +++++++++++++++++++++++++++++++++----------
 drivers/net/benet/be_cmds.h |   40 +++++++-
 drivers/net/benet/be_hw.h   |    8 +-
 drivers/net/benet/be_main.c |  215 ++++++++++++++++++++++++------------
 5 files changed, 455 insertions(+), 161 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index b4bb06f..ef5be13 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -65,7 +65,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define TX_CQ_LEN		1024
 #define RX_Q_LEN		1024	/* Does not support any other value */
 #define RX_CQ_LEN		1024
-#define MCC_Q_LEN		64	/* total size not to exceed 8 pages */
+#define MCC_Q_LEN		128	/* total size not to exceed 8 pages */
 #define MCC_CQ_LEN		256
 
 #define BE_NAPI_WEIGHT		64
@@ -91,6 +91,61 @@ struct be_queue_info {
 	atomic_t used;	/* Number of valid elements in the queue */
 };
 
+static inline u32 MODULO(u16 val, u16 limit)
+{
+	BUG_ON(limit & (limit - 1));
+	return val & (limit - 1);
+}
+
+static inline void index_adv(u16 *index, u16 val, u16 limit)
+{
+	*index = MODULO((*index + val), limit);
+}
+
+static inline void index_inc(u16 *index, u16 limit)
+{
+	*index = MODULO((*index + 1), limit);
+}
+
+static inline void *queue_head_node(struct be_queue_info *q)
+{
+	return q->dma_mem.va + q->head * q->entry_size;
+}
+
+static inline void *queue_tail_node(struct be_queue_info *q)
+{
+	return q->dma_mem.va + q->tail * q->entry_size;
+}
+
+static inline void queue_head_inc(struct be_queue_info *q)
+{
+	index_inc(&q->head, q->len);
+}
+
+static inline void queue_tail_inc(struct be_queue_info *q)
+{
+	index_inc(&q->tail, q->len);
+}
+
+
+struct be_eq_obj {
+	struct be_queue_info q;
+	char desc[32];
+
+	/* Adaptive interrupt coalescing (AIC) info */
+	bool enable_aic;
+	u16 min_eqd;		/* in usecs */
+	u16 max_eqd;		/* in usecs */
+	u16 cur_eqd;		/* in usecs */
+
+	struct napi_struct napi;
+};
+
+struct be_mcc_obj {
+	struct be_queue_info q;
+	struct be_queue_info cq;
+};
+
 struct be_ctrl_info {
 	u8 __iomem *csr;
 	u8 __iomem *db;		/* Door Bell */
@@ -98,11 +153,16 @@ struct be_ctrl_info {
 	int pci_func;
 
 	/* Mbox used for cmd request/response */
-	spinlock_t cmd_lock;	/* For serializing cmds to BE card */
+	spinlock_t mbox_lock;	/* For serializing mbox cmds to BE card */
 	struct be_dma_mem mbox_mem;
 	/* Mbox mem is adjusted to align to 16 bytes. The allocated addr
 	 * is stored for freeing purpose */
 	struct be_dma_mem mbox_mem_alloced;
+
+	/* MCC Rings */
+	struct be_mcc_obj mcc_obj;
+	spinlock_t mcc_lock;	/* For serializing mcc cmds to BE card */
+	spinlock_t mcc_cq_lock;
 };
 
 #include "be_cmds.h"
@@ -150,19 +210,6 @@ struct be_stats_obj {
 	struct be_dma_mem cmd;
 };
 
-struct be_eq_obj {
-	struct be_queue_info q;
-	char desc[32];
-
-	/* Adaptive interrupt coalescing (AIC) info */
-	bool enable_aic;
-	u16 min_eqd;		/* in usecs */
-	u16 max_eqd;		/* in usecs */
-	u16 cur_eqd;		/* in usecs */
-
-	struct napi_struct napi;
-};
-
 struct be_tx_obj {
 	struct be_queue_info q;
 	struct be_queue_info cq;
@@ -235,22 +282,6 @@ extern struct ethtool_ops be_ethtool_ops;
 
 #define BE_SET_NETDEV_OPS(netdev, ops)	(netdev->netdev_ops = ops)
 
-static inline u32 MODULO(u16 val, u16 limit)
-{
-	BUG_ON(limit & (limit - 1));
-	return val & (limit - 1);
-}
-
-static inline void index_adv(u16 *index, u16 val, u16 limit)
-{
-	*index = MODULO((*index + val), limit);
-}
-
-static inline void index_inc(u16 *index, u16 limit)
-{
-	*index = MODULO((*index + 1), limit);
-}
-
 #define PAGE_SHIFT_4K		12
 #define PAGE_SIZE_4K		(1 << PAGE_SHIFT_4K)
 
@@ -339,4 +370,6 @@ static inline u8 is_udp_pkt(struct sk_buff *skb)
 	return val;
 }
 
+extern void be_cq_notify(struct be_ctrl_info *ctrl, u16 qid, bool arm,
+		u16 num_popped);
 #endif				/* BE_H */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index d444aed..f1ec191 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -17,6 +17,90 @@
 
 #include "be.h"
 
+void be_mcc_notify(struct be_ctrl_info *ctrl)
+{
+	struct be_queue_info *mccq = &ctrl->mcc_obj.q;
+	u32 val = 0;
+
+	val |= mccq->id & DB_MCCQ_RING_ID_MASK;
+	val |= 1 << DB_MCCQ_NUM_POSTED_SHIFT;
+	iowrite32(val, ctrl->db + DB_MCCQ_OFFSET);
+}
+
+/* To check if valid bit is set, check the entire word as we don't know
+ * the endianness of the data (old entry is host endian while a new entry is
+ * little endian) */
+static inline bool be_mcc_compl_is_new(struct be_mcc_cq_entry *compl)
+{
+	if (compl->flags != 0) {
+		compl->flags = le32_to_cpu(compl->flags);
+		BUG_ON((compl->flags & CQE_FLAGS_VALID_MASK) == 0);
+		return true;
+	} else {
+		return false;
+	}
+}
+
+/* Need to reset the entire word that houses the valid bit */
+static inline void be_mcc_compl_use(struct be_mcc_cq_entry *compl)
+{
+	compl->flags = 0;
+}
+
+static int be_mcc_compl_process(struct be_ctrl_info *ctrl,
+	struct be_mcc_cq_entry *compl)
+{
+	u16 compl_status, extd_status;
+
+	/* Just swap the status to host endian; mcc tag is opaquely copied
+	 * from mcc_wrb */
+	be_dws_le_to_cpu(compl, 4);
+
+	compl_status = (compl->status >> CQE_STATUS_COMPL_SHIFT) &
+				CQE_STATUS_COMPL_MASK;
+	if (compl_status != MCC_STATUS_SUCCESS) {
+		extd_status = (compl->status >> CQE_STATUS_EXTD_SHIFT) &
+				CQE_STATUS_EXTD_MASK;
+		printk(KERN_WARNING DRV_NAME
+			" error in cmd completion: status(compl/extd)=%d/%d\n",
+			compl_status, extd_status);
+		return -1;
+	}
+	return 0;
+}
+
+
+static struct be_mcc_cq_entry *be_mcc_compl_get(struct be_ctrl_info *ctrl)
+{
+	struct be_queue_info *mcc_cq = &ctrl->mcc_obj.cq;
+	struct be_mcc_cq_entry *compl = queue_tail_node(mcc_cq);
+
+	if (be_mcc_compl_is_new(compl)) {
+		queue_tail_inc(mcc_cq);
+		return compl;
+	}
+	return NULL;
+}
+
+void be_process_mcc(struct be_ctrl_info *ctrl)
+{
+	struct be_mcc_cq_entry *compl;
+	int num = 0;
+
+	spin_lock_bh(&ctrl->mcc_cq_lock);
+	while ((compl = be_mcc_compl_get(ctrl))) {
+		if (!(compl->flags & CQE_FLAGS_ASYNC_MASK)) {
+			be_mcc_compl_process(ctrl, compl);
+			atomic_dec(&ctrl->mcc_obj.q.used);
+		}
+		be_mcc_compl_use(compl);
+		num++;
+	}
+	if (num)
+		be_cq_notify(ctrl, ctrl->mcc_obj.cq.id, true, num);
+	spin_unlock_bh(&ctrl->mcc_cq_lock);
+}
+
 static int be_mbox_db_ready_wait(void __iomem *db)
 {
 	int cnt = 0, wait = 5;
@@ -44,11 +128,11 @@ static int be_mbox_db_ready_wait(void __iomem *db)
 
 /*
  * Insert the mailbox address into the doorbell in two steps
+ * Polls on the mbox doorbell till a command completion (or a timeout) occurs
  */
 static int be_mbox_db_ring(struct be_ctrl_info *ctrl)
 {
 	int status;
-	u16 compl_status, extd_status;
 	u32 val = 0;
 	void __iomem *db = ctrl->db + MPU_MAILBOX_DB_OFFSET;
 	struct be_dma_mem *mbox_mem = &ctrl->mbox_mem;
@@ -79,24 +163,17 @@ static int be_mbox_db_ring(struct be_ctrl_info *ctrl)
 	if (status != 0)
 		return status;
 
-	/* compl entry has been made now */
-	be_dws_le_to_cpu(cqe, sizeof(*cqe));
-	if (!(cqe->flags & CQE_FLAGS_VALID_MASK)) {
-		printk(KERN_WARNING DRV_NAME ": ERROR invalid mbox compl\n");
+	/* A cq entry has been made now */
+	if (be_mcc_compl_is_new(cqe)) {
+		status = be_mcc_compl_process(ctrl, &mbox->cqe);
+		be_mcc_compl_use(cqe);
+		if (status)
+			return status;
+	} else {
+		printk(KERN_WARNING DRV_NAME "invalid mailbox completion\n");
 		return -1;
 	}
-
-	compl_status = (cqe->status >> CQE_STATUS_COMPL_SHIFT) &
-				CQE_STATUS_COMPL_MASK;
-	if (compl_status != MCC_STATUS_SUCCESS) {
-		extd_status = (cqe->status >> CQE_STATUS_EXTD_SHIFT) &
-				CQE_STATUS_EXTD_MASK;
-		printk(KERN_WARNING DRV_NAME
-			": ERROR in cmd compl. status(compl/extd)=%d/%d\n",
-			compl_status, extd_status);
-	}
-
-	return compl_status;
+	return 0;
 }
 
 static int be_POST_stage_get(struct be_ctrl_info *ctrl, u16 *stage)
@@ -235,6 +312,18 @@ static inline struct be_mcc_wrb *wrb_from_mbox(struct be_dma_mem *mbox_mem)
 	return &((struct be_mcc_mailbox *)(mbox_mem->va))->wrb;
 }
 
+static inline struct be_mcc_wrb *wrb_from_mcc(struct be_queue_info *mccq)
+{
+	struct be_mcc_wrb *wrb = NULL;
+	if (atomic_read(&mccq->used) < mccq->len) {
+		wrb = queue_head_node(mccq);
+		queue_head_inc(mccq);
+		atomic_inc(&mccq->used);
+		memset(wrb, 0, sizeof(*wrb));
+	}
+	return wrb;
+}
+
 int be_cmd_eq_create(struct be_ctrl_info *ctrl,
 		struct be_queue_info *eq, int eq_delay)
 {
@@ -244,7 +333,7 @@ int be_cmd_eq_create(struct be_ctrl_info *ctrl,
 	struct be_dma_mem *q_mem = &eq->dma_mem;
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -272,7 +361,7 @@ int be_cmd_eq_create(struct be_ctrl_info *ctrl,
 		eq->id = le16_to_cpu(resp->eq_id);
 		eq->created = true;
 	}
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -284,7 +373,7 @@ int be_cmd_mac_addr_query(struct be_ctrl_info *ctrl, u8 *mac_addr,
 	struct be_cmd_resp_mac_query *resp = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -304,7 +393,7 @@ int be_cmd_mac_addr_query(struct be_ctrl_info *ctrl, u8 *mac_addr,
 	if (!status)
 		memcpy(mac_addr, resp->mac.addr, ETH_ALEN);
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -315,7 +404,7 @@ int be_cmd_pmac_add(struct be_ctrl_info *ctrl, u8 *mac_addr,
 	struct be_cmd_req_pmac_add *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -332,7 +421,7 @@ int be_cmd_pmac_add(struct be_ctrl_info *ctrl, u8 *mac_addr,
 		*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -342,7 +431,7 @@ int be_cmd_pmac_del(struct be_ctrl_info *ctrl, u32 if_id, u32 pmac_id)
 	struct be_cmd_req_pmac_del *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -354,7 +443,7 @@ int be_cmd_pmac_del(struct be_ctrl_info *ctrl, u32 if_id, u32 pmac_id)
 	req->pmac_id = cpu_to_le32(pmac_id);
 
 	status = be_mbox_db_ring(ctrl);
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 
 	return status;
 }
@@ -370,7 +459,7 @@ int be_cmd_cq_create(struct be_ctrl_info *ctrl,
 	void *ctxt = &req->context;
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -388,7 +477,7 @@ int be_cmd_cq_create(struct be_ctrl_info *ctrl,
 	AMAP_SET_BITS(struct amap_cq_context, solevent, ctxt, sol_evts);
 	AMAP_SET_BITS(struct amap_cq_context, eventable, ctxt, 1);
 	AMAP_SET_BITS(struct amap_cq_context, eqid, ctxt, eq->id);
-	AMAP_SET_BITS(struct amap_cq_context, armed, ctxt, 0);
+	AMAP_SET_BITS(struct amap_cq_context, armed, ctxt, 1);
 	AMAP_SET_BITS(struct amap_cq_context, func, ctxt, ctrl->pci_func);
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
@@ -399,7 +488,56 @@ int be_cmd_cq_create(struct be_ctrl_info *ctrl,
 		cq->id = le16_to_cpu(resp->cq_id);
 		cq->created = true;
 	}
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
+
+	return status;
+}
+
+static u32 be_encoded_q_len(int q_len)
+{
+	u32 len_encoded = fls(q_len); /* log2(len) + 1 */
+	if (len_encoded == 16)
+		len_encoded = 0;
+	return len_encoded;
+}
+
+int be_cmd_mccq_create(struct be_ctrl_info *ctrl,
+			struct be_queue_info *mccq,
+			struct be_queue_info *cq)
+{
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_cmd_req_mcc_create *req = embedded_payload(wrb);
+	struct be_dma_mem *q_mem = &mccq->dma_mem;
+	void *ctxt = &req->context;
+	int status;
+
+	spin_lock(&ctrl->mbox_lock);
+	memset(wrb, 0, sizeof(*wrb));
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_MCC_CREATE, sizeof(*req));
+
+	req->num_pages = PAGES_4K_SPANNED(q_mem->va, q_mem->size);
+
+	AMAP_SET_BITS(struct amap_mcc_context, fid, ctxt, ctrl->pci_func);
+	AMAP_SET_BITS(struct amap_mcc_context, valid, ctxt, 1);
+	AMAP_SET_BITS(struct amap_mcc_context, ring_size, ctxt,
+		be_encoded_q_len(mccq->len));
+	AMAP_SET_BITS(struct amap_mcc_context, cq_id, ctxt, cq->id);
+
+	be_dws_cpu_to_le(ctxt, sizeof(req->context));
+
+	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
+
+	status = be_mbox_db_ring(ctrl);
+	if (!status) {
+		struct be_cmd_resp_mcc_create *resp = embedded_payload(wrb);
+		mccq->id = le16_to_cpu(resp->id);
+		mccq->created = true;
+	}
+	spin_unlock(&ctrl->mbox_lock);
 
 	return status;
 }
@@ -415,7 +553,7 @@ int be_cmd_txq_create(struct be_ctrl_info *ctrl,
 	int status;
 	u32 len_encoded;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -446,7 +584,7 @@ int be_cmd_txq_create(struct be_ctrl_info *ctrl,
 		txq->id = le16_to_cpu(resp->cid);
 		txq->created = true;
 	}
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 
 	return status;
 }
@@ -460,7 +598,7 @@ int be_cmd_rxq_create(struct be_ctrl_info *ctrl,
 	struct be_dma_mem *q_mem = &rxq->dma_mem;
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -482,7 +620,7 @@ int be_cmd_rxq_create(struct be_ctrl_info *ctrl,
 		rxq->id = le16_to_cpu(resp->id);
 		rxq->created = true;
 	}
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 
 	return status;
 }
@@ -496,7 +634,7 @@ int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
 	u8 subsys = 0, opcode = 0;
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -518,6 +656,10 @@ int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
 		subsys = CMD_SUBSYSTEM_ETH;
 		opcode = OPCODE_ETH_RX_DESTROY;
 		break;
+	case QTYPE_MCCQ:
+		subsys = CMD_SUBSYSTEM_COMMON;
+		opcode = OPCODE_COMMON_MCC_DESTROY;
+		break;
 	default:
 		printk(KERN_WARNING DRV_NAME ":bad Q type in Q destroy cmd\n");
 		status = -1;
@@ -528,7 +670,7 @@ int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
 
 	status = be_mbox_db_ring(ctrl);
 err:
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 
 	return status;
 }
@@ -541,7 +683,7 @@ int be_cmd_if_create(struct be_ctrl_info *ctrl, u32 flags, u8 *mac,
 	struct be_cmd_req_if_create *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -562,7 +704,7 @@ int be_cmd_if_create(struct be_ctrl_info *ctrl, u32 flags, u8 *mac,
 			*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -572,7 +714,7 @@ int be_cmd_if_destroy(struct be_ctrl_info *ctrl, u32 interface_id)
 	struct be_cmd_req_if_destroy *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -583,7 +725,7 @@ int be_cmd_if_destroy(struct be_ctrl_info *ctrl, u32 interface_id)
 	req->interface_id = cpu_to_le32(interface_id);
 	status = be_mbox_db_ring(ctrl);
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 
 	return status;
 }
@@ -598,7 +740,7 @@ int be_cmd_get_stats(struct be_ctrl_info *ctrl, struct be_dma_mem *nonemb_cmd)
 	struct be_sge *sge = nonembedded_sgl(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	memset(req, 0, sizeof(*req));
@@ -617,7 +759,7 @@ int be_cmd_get_stats(struct be_ctrl_info *ctrl, struct be_dma_mem *nonemb_cmd)
 		be_dws_le_to_cpu(&resp->hw_stats, sizeof(resp->hw_stats));
 	}
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -628,7 +770,7 @@ int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
 	struct be_cmd_req_link_status *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -646,7 +788,7 @@ int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
 		link->speed = PHY_LINK_SPEED_ZERO;
 	}
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -656,7 +798,7 @@ int be_cmd_get_fw_ver(struct be_ctrl_info *ctrl, char *fw_ver)
 	struct be_cmd_req_get_fw_version *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -670,7 +812,7 @@ int be_cmd_get_fw_ver(struct be_ctrl_info *ctrl, char *fw_ver)
 		strncpy(fw_ver, resp->firmware_version_string, FW_VER_LEN);
 	}
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -681,7 +823,7 @@ int be_cmd_modify_eqd(struct be_ctrl_info *ctrl, u32 eq_id, u32 eqd)
 	struct be_cmd_req_modify_eq_delay *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -696,7 +838,7 @@ int be_cmd_modify_eqd(struct be_ctrl_info *ctrl, u32 eq_id, u32 eqd)
 
 	status = be_mbox_db_ring(ctrl);
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -707,7 +849,7 @@ int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id, u16 *vtag_array,
 	struct be_cmd_req_vlan_config *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -726,7 +868,7 @@ int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id, u16 *vtag_array,
 
 	status = be_mbox_db_ring(ctrl);
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -736,7 +878,7 @@ int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
 	struct be_cmd_req_promiscuous_config *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -751,7 +893,7 @@ int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
 
 	status = be_mbox_db_ring(ctrl);
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -762,7 +904,7 @@ int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id, u8 *mac_table,
 	struct be_cmd_req_mcast_mac_config *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -780,7 +922,7 @@ int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id, u8 *mac_table,
 
 	status = be_mbox_db_ring(ctrl);
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -790,7 +932,7 @@ int be_cmd_set_flow_control(struct be_ctrl_info *ctrl, u32 tx_fc, u32 rx_fc)
 	struct be_cmd_req_set_flow_control *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 
@@ -804,7 +946,7 @@ int be_cmd_set_flow_control(struct be_ctrl_info *ctrl, u32 tx_fc, u32 rx_fc)
 
 	status = be_mbox_db_ring(ctrl);
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -814,7 +956,7 @@ int be_cmd_get_flow_control(struct be_ctrl_info *ctrl, u32 *tx_fc, u32 *rx_fc)
 	struct be_cmd_req_get_flow_control *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 
@@ -831,7 +973,7 @@ int be_cmd_get_flow_control(struct be_ctrl_info *ctrl, u32 *tx_fc, u32 *rx_fc)
 		*rx_fc = le16_to_cpu(resp->rx_flow_control);
 	}
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
 
@@ -841,7 +983,7 @@ int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num)
 	struct be_cmd_req_query_fw_cfg *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->cmd_lock);
+	spin_lock(&ctrl->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 
@@ -856,6 +998,6 @@ int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num)
 		*port_num = le32_to_cpu(resp->phys_port);
 	}
 
-	spin_unlock(&ctrl->cmd_lock);
+	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index e499e2d..0a9189d 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -101,6 +101,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_FIRMWARE_CONFIG			42
 #define OPCODE_COMMON_NTWK_INTERFACE_CREATE 		50
 #define OPCODE_COMMON_NTWK_INTERFACE_DESTROY 		51
+#define OPCODE_COMMON_MCC_DESTROY        		53
 #define OPCODE_COMMON_CQ_DESTROY        		54
 #define OPCODE_COMMON_EQ_DESTROY        		55
 #define OPCODE_COMMON_QUERY_FIRMWARE_CONFIG		58
@@ -269,6 +270,38 @@ struct be_cmd_resp_cq_create {
 	u16 rsvd0;
 } __packed;
 
+/******************** Create MCCQ ***************************/
+/* Pseudo amap definition in which each bit of the actual structure is defined
+ * as a byte: used to calculate offset/shift/mask of each field */
+struct amap_mcc_context {
+	u8 con_index[14];
+	u8 rsvd0[2];
+	u8 ring_size[4];
+	u8 fetch_wrb;
+	u8 fetch_r2t;
+	u8 cq_id[10];
+	u8 prod_index[14];
+	u8 fid[8];
+	u8 pdid[9];
+	u8 valid;
+	u8 rsvd1[32];
+	u8 rsvd2[32];
+} __packed;
+
+struct be_cmd_req_mcc_create {
+	struct be_cmd_req_hdr hdr;
+	u16 num_pages;
+	u16 rsvd0;
+	u8 context[sizeof(struct amap_mcc_context) / 8];
+	struct phys_addr pages[8];
+} __packed;
+
+struct be_cmd_resp_mcc_create {
+	struct be_cmd_resp_hdr hdr;
+	u16 id;
+	u16 rsvd0;
+} __packed;
+
 /******************** Create TxQ ***************************/
 #define BE_ETH_TX_RING_TYPE_STANDARD    	2
 #define BE_ULP1_NUM				1
@@ -341,7 +374,8 @@ enum {
 	QTYPE_EQ = 1,
 	QTYPE_CQ,
 	QTYPE_TXQ,
-	QTYPE_RXQ
+	QTYPE_RXQ,
+	QTYPE_MCCQ
 };
 
 struct be_cmd_req_q_destroy {
@@ -657,6 +691,9 @@ extern int be_cmd_cq_create(struct be_ctrl_info *ctrl,
 			struct be_queue_info *cq, struct be_queue_info *eq,
 			bool sol_evts, bool no_delay,
 			int num_cqe_dma_coalesce);
+extern int be_cmd_mccq_create(struct be_ctrl_info *ctrl,
+			struct be_queue_info *mccq,
+			struct be_queue_info *cq);
 extern int be_cmd_txq_create(struct be_ctrl_info *ctrl,
 			struct be_queue_info *txq,
 			struct be_queue_info *cq);
@@ -686,3 +723,4 @@ extern int be_cmd_set_flow_control(struct be_ctrl_info *ctrl,
 extern int be_cmd_get_flow_control(struct be_ctrl_info *ctrl,
 			u32 *tx_fc, u32 *rx_fc);
 extern int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num);
+extern void be_process_mcc(struct be_ctrl_info *ctrl);
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index b132aa4..b02e805 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -61,7 +61,7 @@
 /* Clear the interrupt for this eq */
 #define DB_EQ_CLR_SHIFT			(9)	/* bit 9 */
 /* Must be 1 */
-#define DB_EQ_EVNT_SHIFT			(10)	/* bit 10 */
+#define DB_EQ_EVNT_SHIFT		(10)	/* bit 10 */
 /* Number of event entries processed */
 #define DB_EQ_NUM_POPPED_SHIFT		(16)	/* bits 16 - 28 */
 /* Rearm bit */
@@ -88,6 +88,12 @@
 /* Number of rx frags posted */
 #define DB_RQ_NUM_POSTED_SHIFT		(24)	/* bits 24 - 31 */
 
+/********** MCC door bell ************/
+#define DB_MCCQ_OFFSET 			0x140
+#define DB_MCCQ_RING_ID_MASK		0x7FF	/* bits 0 - 10 */
+/* Number of entries posted */
+#define DB_MCCQ_NUM_POSTED_SHIFT	(16)	/* bits 16 - 29 */
+
 /*
  * BE descriptors: host memory data structures whose formats
  * are hardwired in BE silicon.
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 66bb568..a4ce80e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -60,26 +60,6 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 	return 0;
 }
 
-static inline void *queue_head_node(struct be_queue_info *q)
-{
-	return q->dma_mem.va + q->head * q->entry_size;
-}
-
-static inline void *queue_tail_node(struct be_queue_info *q)
-{
-	return q->dma_mem.va + q->tail * q->entry_size;
-}
-
-static inline void queue_head_inc(struct be_queue_info *q)
-{
-	index_inc(&q->head, q->len);
-}
-
-static inline void queue_tail_inc(struct be_queue_info *q)
-{
-	index_inc(&q->tail, q->len);
-}
-
 static void be_intr_set(struct be_ctrl_info *ctrl, bool enable)
 {
 	u8 __iomem *addr = ctrl->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET;
@@ -127,7 +107,7 @@ static void be_eq_notify(struct be_ctrl_info *ctrl, u16 qid,
 	iowrite32(val, ctrl->db + DB_EQ_OFFSET);
 }
 
-static void be_cq_notify(struct be_ctrl_info *ctrl, u16 qid,
+void be_cq_notify(struct be_ctrl_info *ctrl, u16 qid,
 		bool arm, u16 num_popped)
 {
 	u32 val = 0;
@@ -960,10 +940,8 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 	return;
 }
 
-static struct be_eth_tx_compl *
-be_tx_compl_get(struct be_adapter *adapter)
+static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
 {
-	struct be_queue_info *tx_cq = &adapter->tx_obj.cq;
 	struct be_eth_tx_compl *txcp = queue_tail_node(tx_cq);
 
 	if (txcp->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] == 0)
@@ -1051,6 +1029,59 @@ static void be_tx_q_clean(struct be_adapter *adapter)
 	}
 }
 
+static void be_mcc_queues_destroy(struct be_adapter *adapter)
+{
+	struct be_queue_info *q;
+	struct be_ctrl_info *ctrl = &adapter->ctrl;
+
+	q = &ctrl->mcc_obj.q;
+	if (q->created)
+		be_cmd_q_destroy(ctrl, q, QTYPE_MCCQ);
+	be_queue_free(adapter, q);
+
+	q = &ctrl->mcc_obj.cq;
+	if (q->created)
+		be_cmd_q_destroy(ctrl, q, QTYPE_CQ);
+	be_queue_free(adapter, q);
+}
+
+/* Must be called only after TX qs are created as MCC shares TX EQ */
+static int be_mcc_queues_create(struct be_adapter *adapter)
+{
+	struct be_queue_info *q, *cq;
+	struct be_ctrl_info *ctrl = &adapter->ctrl;
+
+	/* Alloc MCC compl queue */
+	cq = &ctrl->mcc_obj.cq;
+	if (be_queue_alloc(adapter, cq, MCC_CQ_LEN,
+			sizeof(struct be_mcc_cq_entry)))
+		goto err;
+
+	/* Ask BE to create MCC compl queue; share TX's eq */
+	if (be_cmd_cq_create(ctrl, cq, &adapter->tx_eq.q, false, true, 0))
+		goto mcc_cq_free;
+
+	/* Alloc MCC queue */
+	q = &ctrl->mcc_obj.q;
+	if (be_queue_alloc(adapter, q, MCC_Q_LEN, sizeof(struct be_mcc_wrb)))
+		goto mcc_cq_destroy;
+
+	/* Ask BE to create MCC queue */
+	if (be_cmd_mccq_create(ctrl, q, cq))
+		goto mcc_q_free;
+
+	return 0;
+
+mcc_q_free:
+	be_queue_free(adapter, q);
+mcc_cq_destroy:
+	be_cmd_q_destroy(ctrl, cq, QTYPE_CQ);
+mcc_cq_free:
+	be_queue_free(adapter, cq);
+err:
+	return -1;
+}
+
 static void be_tx_queues_destroy(struct be_adapter *adapter)
 {
 	struct be_queue_info *q;
@@ -1263,7 +1294,7 @@ static irqreturn_t be_msix_rx(int irq, void *dev)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t be_msix_tx(int irq, void *dev)
+static irqreturn_t be_msix_tx_mcc(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
 
@@ -1324,40 +1355,51 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-/* For TX we don't honour budget; consume everything */
-int be_poll_tx(struct napi_struct *napi, int budget)
+void be_process_tx(struct be_adapter *adapter)
 {
-	struct be_eq_obj *tx_eq = container_of(napi, struct be_eq_obj, napi);
-	struct be_adapter *adapter =
-		container_of(tx_eq, struct be_adapter, tx_eq);
-	struct be_tx_obj *tx_obj = &adapter->tx_obj;
-	struct be_queue_info *tx_cq = &tx_obj->cq;
-	struct be_queue_info *txq = &tx_obj->q;
+	struct be_queue_info *txq = &adapter->tx_obj.q;
+	struct be_queue_info *tx_cq = &adapter->tx_obj.cq;
 	struct be_eth_tx_compl *txcp;
 	u32 num_cmpl = 0;
 	u16 end_idx;
 
-	while ((txcp = be_tx_compl_get(adapter))) {
+	while ((txcp = be_tx_compl_get(tx_cq))) {
 		end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
 					wrb_index, txcp);
 		be_tx_compl_process(adapter, end_idx);
 		num_cmpl++;
 	}
 
-	/* As Tx wrbs have been freed up, wake up netdev queue if
-	 * it was stopped due to lack of tx wrbs.
-	 */
-	if (netif_queue_stopped(adapter->netdev) &&
+	if (num_cmpl) {
+		be_cq_notify(&adapter->ctrl, tx_cq->id, true, num_cmpl);
+
+		/* As Tx wrbs have been freed up, wake up netdev queue if
+		 * it was stopped due to lack of tx wrbs.
+		 */
+		if (netif_queue_stopped(adapter->netdev) &&
 			atomic_read(&txq->used) < txq->len / 2) {
-		netif_wake_queue(adapter->netdev);
+			netif_wake_queue(adapter->netdev);
+		}
+
+		drvr_stats(adapter)->be_tx_events++;
+		drvr_stats(adapter)->be_tx_compl += num_cmpl;
 	}
+}
+
+/* As TX and MCC share the same EQ check for both TX and MCC completions.
+ * For TX/MCC we don't honour budget; consume everything
+ */
+static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
+{
+	struct be_eq_obj *tx_eq = container_of(napi, struct be_eq_obj, napi);
+	struct be_adapter *adapter =
+		container_of(tx_eq, struct be_adapter, tx_eq);
 
 	napi_complete(napi);
 
-	be_cq_notify(&adapter->ctrl, tx_cq->id, true, num_cmpl);
+	be_process_tx(adapter);
 
-	drvr_stats(adapter)->be_tx_events++;
-	drvr_stats(adapter)->be_tx_compl += num_cmpl;
+	be_process_mcc(&adapter->ctrl);
 
 	return 1;
 }
@@ -1419,7 +1461,7 @@ static int be_msix_register(struct be_adapter *adapter)
 
 	sprintf(tx_eq->desc, "%s-tx", netdev->name);
 	vec = be_msix_vec_get(adapter, tx_eq->q.id);
-	status = request_irq(vec, be_msix_tx, 0, tx_eq->desc, adapter);
+	status = request_irq(vec, be_msix_tx_mcc, 0, tx_eq->desc, adapter);
 	if (status)
 		goto err;
 
@@ -1495,6 +1537,34 @@ static int be_open(struct net_device *netdev)
 	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
+
+	/* First time posting */
+	be_post_rx_frags(adapter);
+
+	napi_enable(&rx_eq->napi);
+	napi_enable(&tx_eq->napi);
+
+	be_irq_register(adapter);
+
+	be_intr_set(ctrl, true);
+
+	/* The evt queues are created in unarmed state; arm them */
+	be_eq_notify(ctrl, rx_eq->q.id, true, false, 0);
+	be_eq_notify(ctrl, tx_eq->q.id, true, false, 0);
+
+	/* Rx compl queue may be in unarmed state; rearm it */
+	be_cq_notify(ctrl, adapter->rx_obj.cq.id, true, 0);
+
+	be_link_status_update(adapter);
+
+	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
+	return 0;
+}
+
+static int be_setup(struct be_adapter *adapter)
+{
+	struct be_ctrl_info *ctrl = &adapter->ctrl;
+	struct net_device *netdev = adapter->netdev;
 	u32 if_flags;
 	int status;
 
@@ -1521,29 +1591,14 @@ static int be_open(struct net_device *netdev)
 	if (status != 0)
 		goto tx_qs_destroy;
 
-	/* First time posting */
-	be_post_rx_frags(adapter);
-
-	napi_enable(&rx_eq->napi);
-	napi_enable(&tx_eq->napi);
-
-	be_irq_register(adapter);
-
-	be_intr_set(ctrl, true);
-
-	/* The evt queues are created in the unarmed state; arm them */
-	be_eq_notify(ctrl, rx_eq->q.id, true, false, 0);
-	be_eq_notify(ctrl, tx_eq->q.id, true, false, 0);
-
-	/* The compl queues are created in the unarmed state; arm them */
-	be_cq_notify(ctrl, adapter->rx_obj.cq.id, true, 0);
-	be_cq_notify(ctrl, adapter->tx_obj.cq.id, true, 0);
-
-	be_link_status_update(adapter);
+	status = be_mcc_queues_create(adapter);
+	if (status != 0)
+		goto rx_qs_destroy;
 
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 
+rx_qs_destroy:
+	be_rx_queues_destroy(adapter);
 tx_qs_destroy:
 	be_tx_queues_destroy(adapter);
 if_destroy:
@@ -1552,6 +1607,19 @@ do_none:
 	return status;
 }
 
+static int be_clear(struct be_adapter *adapter)
+{
+	struct be_ctrl_info *ctrl = &adapter->ctrl;
+
+	be_rx_queues_destroy(adapter);
+	be_tx_queues_destroy(adapter);
+
+	be_cmd_if_destroy(ctrl, adapter->if_handle);
+
+	be_mcc_queues_destroy(adapter);
+	return 0;
+}
+
 static int be_close(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -1581,10 +1649,6 @@ static int be_close(struct net_device *netdev)
 	napi_disable(&rx_eq->napi);
 	napi_disable(&tx_eq->napi);
 
-	be_rx_queues_destroy(adapter);
-	be_tx_queues_destroy(adapter);
-
-	be_cmd_if_destroy(ctrl, adapter->if_handle);
 	return 0;
 }
 
@@ -1673,7 +1737,7 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netif_napi_add(netdev, &adapter->rx_eq.napi, be_poll_rx,
 		BE_NAPI_WEIGHT);
-	netif_napi_add(netdev, &adapter->tx_eq.napi, be_poll_tx,
+	netif_napi_add(netdev, &adapter->tx_eq.napi, be_poll_tx_mcc,
 		BE_NAPI_WEIGHT);
 
 	netif_carrier_off(netdev);
@@ -1755,7 +1819,9 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	mbox_mem_align->va = PTR_ALIGN(mbox_mem_alloc->va, 16);
 	mbox_mem_align->dma = PTR_ALIGN(mbox_mem_alloc->dma, 16);
 	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
-	spin_lock_init(&ctrl->cmd_lock);
+	spin_lock_init(&ctrl->mbox_lock);
+	spin_lock_init(&ctrl->mcc_lock);
+	spin_lock_init(&ctrl->mcc_cq_lock);
 
 	val = ioread32(ctrl->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET);
 	ctrl->pci_func = (val >> MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT) &
@@ -1793,6 +1859,8 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 	unregister_netdev(adapter->netdev);
 
+	be_clear(adapter);
+
 	be_stats_cleanup(adapter);
 
 	be_ctrl_cleanup(adapter);
@@ -1890,13 +1958,18 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	be_netdev_init(netdev);
 	SET_NETDEV_DEV(netdev, &adapter->pdev->dev);
 
+	status = be_setup(adapter);
+	if (status)
+		goto stats_clean;
 	status = register_netdev(netdev);
 	if (status != 0)
-		goto stats_clean;
+		goto unsetup;
 
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
 	return 0;
 
+unsetup:
+	be_clear(adapter);
 stats_clean:
 	be_stats_cleanup(adapter);
 ctrl_clean:
@@ -1921,6 +1994,7 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (netif_running(netdev)) {
 		rtnl_lock();
 		be_close(netdev);
+		be_clear(adapter);
 		rtnl_unlock();
 	}
 
@@ -1947,6 +2021,7 @@ static int be_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		rtnl_lock();
+		be_setup(adapter);
 		be_open(netdev);
 		rtnl_unlock();
 	}
-- 
1.6.0.4

