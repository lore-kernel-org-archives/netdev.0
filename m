From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 1/5] be2net: get rid of be_ctrl_info
	struct/abstraction
Date: Tue, 28 Jul 2009 14:22:03 +0530
Message-ID: <20090728085203.GA4961@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:4420 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750997AbZG1IwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:52:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently only the be_ctrl_info struct ptr (instead of adapter) is
 passed to all the routines in be_cmds.c. Instead pass be_adapter
ptr to allow access to all its fields. Merge the contents of struct be_ctrl_info
into be_adapter. The resulting code is simpler.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h         |   47 +++----
 drivers/net/benet/be_cmds.c    |  293 ++++++++++++++++++++--------------------
 drivers/net/benet/be_cmds.h    |   51 ++++----
 drivers/net/benet/be_ethtool.c |   12 +-
 drivers/net/benet/be_main.c    |  229 ++++++++++++++-----------------
 5 files changed, 299 insertions(+), 333 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 41cddbe..d8a157f 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -71,6 +71,8 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MAX_RX_POST 		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
 
+#define FW_VER_LEN		32
+
 struct be_dma_mem {
 	void *va;
 	dma_addr_t dma;
@@ -123,7 +125,6 @@ static inline void queue_tail_inc(struct be_queue_info *q)
 	index_inc(&q->tail, q->len);
 }
 
-
 struct be_eq_obj {
 	struct be_queue_info q;
 	char desc[32];
@@ -142,31 +143,6 @@ struct be_mcc_obj {
 	struct be_queue_info cq;
 };
 
-struct be_ctrl_info {
-	u8 __iomem *csr;
-	u8 __iomem *db;		/* Door Bell */
-	u8 __iomem *pcicfg;	/* PCI config space */
-	int pci_func;
-
-	/* Mbox used for cmd request/response */
-	spinlock_t mbox_lock;	/* For serializing mbox cmds to BE card */
-	struct be_dma_mem mbox_mem;
-	/* Mbox mem is adjusted to align to 16 bytes. The allocated addr
-	 * is stored for freeing purpose */
-	struct be_dma_mem mbox_mem_alloced;
-
-	/* MCC Rings */
-	struct be_mcc_obj mcc_obj;
-	spinlock_t mcc_lock;	/* For serializing mcc cmds to BE card */
-	spinlock_t mcc_cq_lock;
-
-	/* MCC Async callback */
-	void (*async_cb)(void *adapter, bool link_up);
-	void *adapter_ctxt;
-};
-
-#include "be_cmds.h"
-
 struct be_drvr_stats {
 	u32 be_tx_reqs;		/* number of TX requests initiated */
 	u32 be_tx_stops;	/* number of times TX Q was stopped */
@@ -234,8 +210,20 @@ struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
 
-	/* Mbox, pci config, csr address information */
-	struct be_ctrl_info ctrl;
+	u8 __iomem *csr;
+	u8 __iomem *db;		/* Door Bell */
+	u8 __iomem *pcicfg;	/* PCI config space */
+	int pci_func;
+
+	spinlock_t mbox_lock;	/* For serializing mbox cmds to BE card */
+	struct be_dma_mem mbox_mem;
+	/* Mbox mem is adjusted to align to 16 bytes. The allocated addr
+	 * is stored for freeing purpose */
+	struct be_dma_mem mbox_mem_alloced;
+
+	struct be_mcc_obj mcc_obj;
+	spinlock_t mcc_lock;	/* For serializing mcc cmds to BE card */
+	spinlock_t mcc_cq_lock;
 
 	struct msix_entry msix_entries[BE_NUM_MSIX_VECTORS];
 	bool msix_enabled;
@@ -366,6 +354,7 @@ static inline u8 is_udp_pkt(struct sk_buff *skb)
 	return val;
 }
 
-extern void be_cq_notify(struct be_ctrl_info *ctrl, u16 qid, bool arm,
+extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
+extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
 #endif				/* BE_H */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 583517e..20278b9 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -16,15 +16,16 @@
  */
 
 #include "be.h"
+#include "be_cmds.h"
 
-static void be_mcc_notify(struct be_ctrl_info *ctrl)
+static void be_mcc_notify(struct be_adapter *adapter)
 {
-	struct be_queue_info *mccq = &ctrl->mcc_obj.q;
+	struct be_queue_info *mccq = &adapter->mcc_obj.q;
 	u32 val = 0;
 
 	val |= mccq->id & DB_MCCQ_RING_ID_MASK;
 	val |= 1 << DB_MCCQ_NUM_POSTED_SHIFT;
-	iowrite32(val, ctrl->db + DB_MCCQ_OFFSET);
+	iowrite32(val, adapter->db + DB_MCCQ_OFFSET);
 }
 
 /* To check if valid bit is set, check the entire word as we don't know
@@ -47,7 +48,7 @@ static inline void be_mcc_compl_use(struct be_mcc_cq_entry *compl)
 	compl->flags = 0;
 }
 
-static int be_mcc_compl_process(struct be_ctrl_info *ctrl,
+static int be_mcc_compl_process(struct be_adapter *adapter,
 	struct be_mcc_cq_entry *compl)
 {
 	u16 compl_status, extd_status;
@@ -70,11 +71,11 @@ static int be_mcc_compl_process(struct be_ctrl_info *ctrl,
 }
 
 /* Link state evt is a string of bytes; no need for endian swapping */
-static void be_async_link_state_process(struct be_ctrl_info *ctrl,
+static void be_async_link_state_process(struct be_adapter *adapter,
 		struct be_async_event_link_state *evt)
 {
-	ctrl->async_cb(ctrl->adapter_ctxt,
-		evt->port_link_status == ASYNC_EVENT_LINK_UP ? true : false);
+	be_link_status_update(adapter,
+		evt->port_link_status == ASYNC_EVENT_LINK_UP);
 }
 
 static inline bool is_link_state_evt(u32 trailer)
@@ -84,9 +85,9 @@ static inline bool is_link_state_evt(u32 trailer)
 				ASYNC_EVENT_CODE_LINK_STATE);
 }
 
-static struct be_mcc_cq_entry *be_mcc_compl_get(struct be_ctrl_info *ctrl)
+static struct be_mcc_cq_entry *be_mcc_compl_get(struct be_adapter *adapter)
 {
-	struct be_queue_info *mcc_cq = &ctrl->mcc_obj.cq;
+	struct be_queue_info *mcc_cq = &adapter->mcc_obj.cq;
 	struct be_mcc_cq_entry *compl = queue_tail_node(mcc_cq);
 
 	if (be_mcc_compl_is_new(compl)) {
@@ -96,40 +97,40 @@ static struct be_mcc_cq_entry *be_mcc_compl_get(struct be_ctrl_info *ctrl)
 	return NULL;
 }
 
-void be_process_mcc(struct be_ctrl_info *ctrl)
+void be_process_mcc(struct be_adapter *adapter)
 {
 	struct be_mcc_cq_entry *compl;
 	int num = 0;
 
-	spin_lock_bh(&ctrl->mcc_cq_lock);
-	while ((compl = be_mcc_compl_get(ctrl))) {
+	spin_lock_bh(&adapter->mcc_cq_lock);
+	while ((compl = be_mcc_compl_get(adapter))) {
 		if (compl->flags & CQE_FLAGS_ASYNC_MASK) {
 			/* Interpret flags as an async trailer */
 			BUG_ON(!is_link_state_evt(compl->flags));
 
 			/* Interpret compl as a async link evt */
-			be_async_link_state_process(ctrl,
+			be_async_link_state_process(adapter,
 				(struct be_async_event_link_state *) compl);
 		} else {
-			be_mcc_compl_process(ctrl, compl);
-			atomic_dec(&ctrl->mcc_obj.q.used);
+			be_mcc_compl_process(adapter, compl);
+			atomic_dec(&adapter->mcc_obj.q.used);
 		}
 		be_mcc_compl_use(compl);
 		num++;
 	}
 	if (num)
-		be_cq_notify(ctrl, ctrl->mcc_obj.cq.id, true, num);
-	spin_unlock_bh(&ctrl->mcc_cq_lock);
+		be_cq_notify(adapter, adapter->mcc_obj.cq.id, true, num);
+	spin_unlock_bh(&adapter->mcc_cq_lock);
 }
 
 /* Wait till no more pending mcc requests are present */
-static void be_mcc_wait_compl(struct be_ctrl_info *ctrl)
+static void be_mcc_wait_compl(struct be_adapter *adapter)
 {
 #define mcc_timeout		50000 /* 5s timeout */
 	int i;
 	for (i = 0; i < mcc_timeout; i++) {
-		be_process_mcc(ctrl);
-		if (atomic_read(&ctrl->mcc_obj.q.used) == 0)
+		be_process_mcc(adapter);
+		if (atomic_read(&adapter->mcc_obj.q.used) == 0)
 			break;
 		udelay(100);
 	}
@@ -138,10 +139,10 @@ static void be_mcc_wait_compl(struct be_ctrl_info *ctrl)
 }
 
 /* Notify MCC requests and wait for completion */
-static void be_mcc_notify_wait(struct be_ctrl_info *ctrl)
+static void be_mcc_notify_wait(struct be_adapter *adapter)
 {
-	be_mcc_notify(ctrl);
-	be_mcc_wait_compl(ctrl);
+	be_mcc_notify(adapter);
+	be_mcc_wait_compl(adapter);
 }
 
 static int be_mbox_db_ready_wait(void __iomem *db)
@@ -173,12 +174,12 @@ static int be_mbox_db_ready_wait(void __iomem *db)
  * Insert the mailbox address into the doorbell in two steps
  * Polls on the mbox doorbell till a command completion (or a timeout) occurs
  */
-static int be_mbox_db_ring(struct be_ctrl_info *ctrl)
+static int be_mbox_db_ring(struct be_adapter *adapter)
 {
 	int status;
 	u32 val = 0;
-	void __iomem *db = ctrl->db + MPU_MAILBOX_DB_OFFSET;
-	struct be_dma_mem *mbox_mem = &ctrl->mbox_mem;
+	void __iomem *db = adapter->db + MPU_MAILBOX_DB_OFFSET;
+	struct be_dma_mem *mbox_mem = &adapter->mbox_mem;
 	struct be_mcc_mailbox *mbox = mbox_mem->va;
 	struct be_mcc_cq_entry *cqe = &mbox->cqe;
 
@@ -208,7 +209,7 @@ static int be_mbox_db_ring(struct be_ctrl_info *ctrl)
 
 	/* A cq entry has been made now */
 	if (be_mcc_compl_is_new(cqe)) {
-		status = be_mcc_compl_process(ctrl, &mbox->cqe);
+		status = be_mcc_compl_process(adapter, &mbox->cqe);
 		be_mcc_compl_use(cqe);
 		if (status)
 			return status;
@@ -219,9 +220,9 @@ static int be_mbox_db_ring(struct be_ctrl_info *ctrl)
 	return 0;
 }
 
-static int be_POST_stage_get(struct be_ctrl_info *ctrl, u16 *stage)
+static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 {
-	u32 sem = ioread32(ctrl->csr + MPU_EP_SEMAPHORE_OFFSET);
+	u32 sem = ioread32(adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
 
 	*stage = sem & EP_SEMAPHORE_POST_STAGE_MASK;
 	if ((sem >> EP_SEMAPHORE_POST_ERR_SHIFT) & EP_SEMAPHORE_POST_ERR_MASK)
@@ -230,11 +231,11 @@ static int be_POST_stage_get(struct be_ctrl_info *ctrl, u16 *stage)
 		return 0;
 }
 
-static int be_POST_stage_poll(struct be_ctrl_info *ctrl, u16 poll_stage)
+static int be_POST_stage_poll(struct be_adapter *adapter, u16 poll_stage)
 {
 	u16 stage, cnt, error;
 	for (cnt = 0; cnt < 5000; cnt++) {
-		error = be_POST_stage_get(ctrl, &stage);
+		error = be_POST_stage_get(adapter, &stage);
 		if (error)
 			return -1;
 
@@ -248,11 +249,11 @@ static int be_POST_stage_poll(struct be_ctrl_info *ctrl, u16 poll_stage)
 }
 
 
-int be_cmd_POST(struct be_ctrl_info *ctrl)
+int be_cmd_POST(struct be_adapter *adapter)
 {
 	u16 stage, error;
 
-	error = be_POST_stage_get(ctrl, &stage);
+	error = be_POST_stage_get(adapter, &stage);
 	if (error)
 		goto err;
 
@@ -263,14 +264,14 @@ int be_cmd_POST(struct be_ctrl_info *ctrl)
 		goto err;
 
 	/* On awaiting host rdy, reset and again poll on awaiting host rdy */
-	iowrite32(POST_STAGE_BE_RESET, ctrl->csr + MPU_EP_SEMAPHORE_OFFSET);
-	error = be_POST_stage_poll(ctrl, POST_STAGE_AWAITING_HOST_RDY);
+	iowrite32(POST_STAGE_BE_RESET, adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
+	error = be_POST_stage_poll(adapter, POST_STAGE_AWAITING_HOST_RDY);
 	if (error)
 		goto err;
 
 	/* Now kickoff POST and poll on armfw ready */
-	iowrite32(POST_STAGE_HOST_RDY, ctrl->csr + MPU_EP_SEMAPHORE_OFFSET);
-	error = be_POST_stage_poll(ctrl, POST_STAGE_ARMFW_RDY);
+	iowrite32(POST_STAGE_HOST_RDY, adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
+	error = be_POST_stage_poll(adapter, POST_STAGE_ARMFW_RDY);
 	if (error)
 		goto err;
 
@@ -367,16 +368,16 @@ static inline struct be_mcc_wrb *wrb_from_mcc(struct be_queue_info *mccq)
 	return wrb;
 }
 
-int be_cmd_eq_create(struct be_ctrl_info *ctrl,
+int be_cmd_eq_create(struct be_adapter *adapter,
 		struct be_queue_info *eq, int eq_delay)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_eq_create *req = embedded_payload(wrb);
 	struct be_cmd_resp_eq_create *resp = embedded_payload(wrb);
 	struct be_dma_mem *q_mem = &eq->dma_mem;
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -387,7 +388,7 @@ int be_cmd_eq_create(struct be_ctrl_info *ctrl,
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 
 	AMAP_SET_BITS(struct amap_eq_context, func, req->context,
-			ctrl->pci_func);
+			adapter->pci_func);
 	AMAP_SET_BITS(struct amap_eq_context, valid, req->context, 1);
 	/* 4byte eqe*/
 	AMAP_SET_BITS(struct amap_eq_context, size, req->context, 0);
@@ -399,24 +400,24 @@ int be_cmd_eq_create(struct be_ctrl_info *ctrl,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		eq->id = le16_to_cpu(resp->eq_id);
 		eq->created = true;
 	}
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_mac_addr_query(struct be_ctrl_info *ctrl, u8 *mac_addr,
+int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 			u8 type, bool permanent, u32 if_handle)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_mac_query *req = embedded_payload(wrb);
 	struct be_cmd_resp_mac_query *resp = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -432,22 +433,22 @@ int be_cmd_mac_addr_query(struct be_ctrl_info *ctrl, u8 *mac_addr,
 		req->permanent = 0;
 	}
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status)
 		memcpy(mac_addr, resp->mac.addr, ETH_ALEN);
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_pmac_add(struct be_ctrl_info *ctrl, u8 *mac_addr,
+int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 		u32 if_id, u32 *pmac_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_pmac_add *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -458,23 +459,23 @@ int be_cmd_pmac_add(struct be_ctrl_info *ctrl, u8 *mac_addr,
 	req->if_id = cpu_to_le32(if_id);
 	memcpy(req->mac_address, mac_addr, ETH_ALEN);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_pmac_add *resp = embedded_payload(wrb);
 		*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_pmac_del(struct be_ctrl_info *ctrl, u32 if_id, u32 pmac_id)
+int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_pmac_del *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -485,24 +486,24 @@ int be_cmd_pmac_del(struct be_ctrl_info *ctrl, u32 if_id, u32 pmac_id)
 	req->if_id = cpu_to_le32(if_id);
 	req->pmac_id = cpu_to_le32(pmac_id);
 
-	status = be_mbox_db_ring(ctrl);
-	spin_unlock(&ctrl->mbox_lock);
+	status = be_mbox_db_ring(adapter);
+	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
-int be_cmd_cq_create(struct be_ctrl_info *ctrl,
+int be_cmd_cq_create(struct be_adapter *adapter,
 		struct be_queue_info *cq, struct be_queue_info *eq,
 		bool sol_evts, bool no_delay, int coalesce_wm)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_cq_create *req = embedded_payload(wrb);
 	struct be_cmd_resp_cq_create *resp = embedded_payload(wrb);
 	struct be_dma_mem *q_mem = &cq->dma_mem;
 	void *ctxt = &req->context;
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -521,17 +522,17 @@ int be_cmd_cq_create(struct be_ctrl_info *ctrl,
 	AMAP_SET_BITS(struct amap_cq_context, eventable, ctxt, 1);
 	AMAP_SET_BITS(struct amap_cq_context, eqid, ctxt, eq->id);
 	AMAP_SET_BITS(struct amap_cq_context, armed, ctxt, 1);
-	AMAP_SET_BITS(struct amap_cq_context, func, ctxt, ctrl->pci_func);
+	AMAP_SET_BITS(struct amap_cq_context, func, ctxt, adapter->pci_func);
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		cq->id = le16_to_cpu(resp->cq_id);
 		cq->created = true;
 	}
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -544,17 +545,17 @@ static u32 be_encoded_q_len(int q_len)
 	return len_encoded;
 }
 
-int be_cmd_mccq_create(struct be_ctrl_info *ctrl,
+int be_cmd_mccq_create(struct be_adapter *adapter,
 			struct be_queue_info *mccq,
 			struct be_queue_info *cq)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_mcc_create *req = embedded_payload(wrb);
 	struct be_dma_mem *q_mem = &mccq->dma_mem;
 	void *ctxt = &req->context;
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -564,7 +565,7 @@ int be_cmd_mccq_create(struct be_ctrl_info *ctrl,
 
 	req->num_pages = PAGES_4K_SPANNED(q_mem->va, q_mem->size);
 
-	AMAP_SET_BITS(struct amap_mcc_context, fid, ctxt, ctrl->pci_func);
+	AMAP_SET_BITS(struct amap_mcc_context, fid, ctxt, adapter->pci_func);
 	AMAP_SET_BITS(struct amap_mcc_context, valid, ctxt, 1);
 	AMAP_SET_BITS(struct amap_mcc_context, ring_size, ctxt,
 		be_encoded_q_len(mccq->len));
@@ -574,29 +575,29 @@ int be_cmd_mccq_create(struct be_ctrl_info *ctrl,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_mcc_create *resp = embedded_payload(wrb);
 		mccq->id = le16_to_cpu(resp->id);
 		mccq->created = true;
 	}
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
-int be_cmd_txq_create(struct be_ctrl_info *ctrl,
+int be_cmd_txq_create(struct be_adapter *adapter,
 			struct be_queue_info *txq,
 			struct be_queue_info *cq)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_eth_tx_create *req = embedded_payload(wrb);
 	struct be_dma_mem *q_mem = &txq->dma_mem;
 	void *ctxt = &req->context;
 	int status;
 	u32 len_encoded;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -613,7 +614,7 @@ int be_cmd_txq_create(struct be_ctrl_info *ctrl,
 		len_encoded = 0;
 	AMAP_SET_BITS(struct amap_tx_context, tx_ring_size, ctxt, len_encoded);
 	AMAP_SET_BITS(struct amap_tx_context, pci_func_id, ctxt,
-			ctrl->pci_func);
+			adapter->pci_func);
 	AMAP_SET_BITS(struct amap_tx_context, ctx_valid, ctxt, 1);
 	AMAP_SET_BITS(struct amap_tx_context, cq_id_send, ctxt, cq->id);
 
@@ -621,27 +622,27 @@ int be_cmd_txq_create(struct be_ctrl_info *ctrl,
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_eth_tx_create *resp = embedded_payload(wrb);
 		txq->id = le16_to_cpu(resp->cid);
 		txq->created = true;
 	}
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
-int be_cmd_rxq_create(struct be_ctrl_info *ctrl,
+int be_cmd_rxq_create(struct be_adapter *adapter,
 		struct be_queue_info *rxq, u16 cq_id, u16 frag_size,
 		u16 max_frame_size, u32 if_id, u32 rss)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_eth_rx_create *req = embedded_payload(wrb);
 	struct be_dma_mem *q_mem = &rxq->dma_mem;
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -657,27 +658,27 @@ int be_cmd_rxq_create(struct be_ctrl_info *ctrl,
 	req->max_frame_size = cpu_to_le16(max_frame_size);
 	req->rss_queue = cpu_to_le32(rss);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_eth_rx_create *resp = embedded_payload(wrb);
 		rxq->id = le16_to_cpu(resp->id);
 		rxq->created = true;
 	}
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
 /* Generic destroyer function for all types of queues */
-int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
+int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 		int queue_type)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_q_destroy *req = embedded_payload(wrb);
 	u8 subsys = 0, opcode = 0;
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -711,22 +712,22 @@ int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
 	be_cmd_hdr_prepare(&req->hdr, subsys, opcode, sizeof(*req));
 	req->id = cpu_to_le16(q->id);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 err:
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
 
 /* Create an rx filtering policy configuration on an i/f */
-int be_cmd_if_create(struct be_ctrl_info *ctrl, u32 flags, u8 *mac,
+int be_cmd_if_create(struct be_adapter *adapter, u32 flags, u8 *mac,
 		bool pmac_invalid, u32 *if_handle, u32 *pmac_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_if_create *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -739,7 +740,7 @@ int be_cmd_if_create(struct be_ctrl_info *ctrl, u32 flags, u8 *mac,
 	if (!pmac_invalid)
 		memcpy(req->mac_addr, mac, ETH_ALEN);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_if_create *resp = embedded_payload(wrb);
 		*if_handle = le32_to_cpu(resp->interface_id);
@@ -747,17 +748,17 @@ int be_cmd_if_create(struct be_ctrl_info *ctrl, u32 flags, u8 *mac,
 			*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_if_destroy(struct be_ctrl_info *ctrl, u32 interface_id)
+int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_if_destroy *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -766,9 +767,9 @@ int be_cmd_if_destroy(struct be_ctrl_info *ctrl, u32 interface_id)
 		OPCODE_COMMON_NTWK_INTERFACE_DESTROY, sizeof(*req));
 
 	req->interface_id = cpu_to_le32(interface_id);
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 
 	return status;
 }
@@ -776,14 +777,14 @@ int be_cmd_if_destroy(struct be_ctrl_info *ctrl, u32 interface_id)
 /* Get stats is a non embedded command: the request is not embedded inside
  * WRB but is a separate dma memory block
  */
-int be_cmd_get_stats(struct be_ctrl_info *ctrl, struct be_dma_mem *nonemb_cmd)
+int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_get_stats *req = nonemb_cmd->va;
 	struct be_sge *sge = nonembedded_sgl(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	memset(req, 0, sizeof(*req));
@@ -796,24 +797,24 @@ int be_cmd_get_stats(struct be_ctrl_info *ctrl, struct be_dma_mem *nonemb_cmd)
 	sge->pa_lo = cpu_to_le32(nonemb_cmd->dma & 0xFFFFFFFF);
 	sge->len = cpu_to_le32(nonemb_cmd->size);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_stats *resp = nonemb_cmd->va;
 		be_dws_le_to_cpu(&resp->hw_stats, sizeof(resp->hw_stats));
 	}
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
+int be_cmd_link_status_query(struct be_adapter *adapter,
 			bool *link_up)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_link_status *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 
 	*link_up = false;
 	memset(wrb, 0, sizeof(*wrb));
@@ -823,24 +824,24 @@ int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req));
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
 		if (resp->mac_speed != PHY_LINK_SPEED_ZERO)
 			*link_up = true;
 	}
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_get_fw_ver(struct be_ctrl_info *ctrl, char *fw_ver)
+int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_get_fw_version *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -848,24 +849,24 @@ int be_cmd_get_fw_ver(struct be_ctrl_info *ctrl, char *fw_ver)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FW_VERSION, sizeof(*req));
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
 		strncpy(fw_ver, resp->firmware_version_string, FW_VER_LEN);
 	}
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
 /* set the EQ delay interval of an EQ to specified value */
-int be_cmd_modify_eqd(struct be_ctrl_info *ctrl, u32 eq_id, u32 eqd)
+int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_modify_eq_delay *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -878,20 +879,20 @@ int be_cmd_modify_eqd(struct be_ctrl_info *ctrl, u32 eq_id, u32 eqd)
 	req->delay[0].phase = 0;
 	req->delay[0].delay_multiplier = cpu_to_le32(eqd);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id, u16 *vtag_array,
+int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 			u32 num, bool untagged, bool promiscuous)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_vlan_config *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 	memset(wrb, 0, sizeof(*wrb));
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -908,21 +909,21 @@ int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id, u16 *vtag_array,
 			req->num_vlan * sizeof(vtag_array[0]));
 	}
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
 /* Use MCC for this command as it may be called in BH context */
-int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
+int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_promiscuous_config *req;
 
-	spin_lock_bh(&ctrl->mcc_lock);
+	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mcc(&ctrl->mcc_obj.q);
+	wrb = wrb_from_mcc(&adapter->mcc_obj.q);
 	BUG_ON(!wrb);
 
 	req = embedded_payload(wrb);
@@ -937,9 +938,9 @@ int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
 	else
 		req->port0_promiscuous = en;
 
-	be_mcc_notify_wait(ctrl);
+	be_mcc_notify_wait(adapter);
 
-	spin_unlock_bh(&ctrl->mcc_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 	return 0;
 }
 
@@ -947,16 +948,16 @@ int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
  * Use MCC for this command as it may be called in BH context
  * (mc == NULL) => multicast promiscous
  */
-int be_cmd_multicast_set(struct be_ctrl_info *ctrl, u32 if_id,
+int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 		struct dev_mc_list *mc_list, u32 mc_count)
 {
 #define BE_MAX_MC		32 /* set mcast promisc if > 32 */
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_mcast_mac_config *req;
 
-	spin_lock_bh(&ctrl->mcc_lock);
+	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mcc(&ctrl->mcc_obj.q);
+	wrb = wrb_from_mcc(&adapter->mcc_obj.q);
 	BUG_ON(!wrb);
 
 	req = embedded_payload(wrb);
@@ -979,20 +980,20 @@ int be_cmd_multicast_set(struct be_ctrl_info *ctrl, u32 if_id,
 		req->promiscuous = 1;
 	}
 
-	be_mcc_notify_wait(ctrl);
+	be_mcc_notify_wait(adapter);
 
-	spin_unlock_bh(&ctrl->mcc_lock);
+	spin_unlock_bh(&adapter->mcc_lock);
 
 	return 0;
 }
 
-int be_cmd_set_flow_control(struct be_ctrl_info *ctrl, u32 tx_fc, u32 rx_fc)
+int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_set_flow_control *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 
@@ -1004,19 +1005,19 @@ int be_cmd_set_flow_control(struct be_ctrl_info *ctrl, u32 tx_fc, u32 rx_fc)
 	req->tx_flow_control = cpu_to_le16((u16)tx_fc);
 	req->rx_flow_control = cpu_to_le16((u16)rx_fc);
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_get_flow_control(struct be_ctrl_info *ctrl, u32 *tx_fc, u32 *rx_fc)
+int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_get_flow_control *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 
@@ -1025,7 +1026,7 @@ int be_cmd_get_flow_control(struct be_ctrl_info *ctrl, u32 *tx_fc, u32 *rx_fc)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_FLOW_CONTROL, sizeof(*req));
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_flow_control *resp =
 						embedded_payload(wrb);
@@ -1033,17 +1034,17 @@ int be_cmd_get_flow_control(struct be_ctrl_info *ctrl, u32 *tx_fc, u32 *rx_fc)
 		*rx_fc = le16_to_cpu(resp->rx_flow_control);
 	}
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
 
-int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num)
+int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
 	struct be_cmd_req_query_fw_cfg *req = embedded_payload(wrb);
 	int status;
 
-	spin_lock(&ctrl->mbox_lock);
+	spin_lock(&adapter->mbox_lock);
 
 	memset(wrb, 0, sizeof(*wrb));
 
@@ -1052,12 +1053,12 @@ int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_QUERY_FIRMWARE_CONFIG, sizeof(*req));
 
-	status = be_mbox_db_ring(ctrl);
+	status = be_mbox_db_ring(adapter);
 	if (!status) {
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
 		*port_num = le32_to_cpu(resp->phys_port);
 	}
 
-	spin_unlock(&ctrl->mbox_lock);
+	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 747626d..164ab92 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -634,7 +634,6 @@ struct be_cmd_resp_link_status {
 } __packed;
 
 /******************** Get FW Version *******************/
-#define FW_VER_LEN			32
 struct be_cmd_req_get_fw_version {
 	struct be_cmd_req_hdr hdr;
 	u8 rsvd0[FW_VER_LEN];
@@ -697,52 +696,52 @@ struct be_cmd_resp_query_fw_cfg {
 	u32 rsvd[26];
 };
 
-extern int be_pci_fnum_get(struct be_ctrl_info *ctrl);
-extern int be_cmd_POST(struct be_ctrl_info *ctrl);
-extern int be_cmd_mac_addr_query(struct be_ctrl_info *ctrl, u8 *mac_addr,
+extern int be_pci_fnum_get(struct be_adapter *adapter);
+extern int be_cmd_POST(struct be_adapter *adapter);
+extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 			u8 type, bool permanent, u32 if_handle);
-extern int be_cmd_pmac_add(struct be_ctrl_info *ctrl, u8 *mac_addr,
+extern int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 			u32 if_id, u32 *pmac_id);
-extern int be_cmd_pmac_del(struct be_ctrl_info *ctrl, u32 if_id, u32 pmac_id);
-extern int be_cmd_if_create(struct be_ctrl_info *ctrl, u32 if_flags, u8 *mac,
+extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id);
+extern int be_cmd_if_create(struct be_adapter *adapter, u32 if_flags, u8 *mac,
 			bool pmac_invalid, u32 *if_handle, u32 *pmac_id);
-extern int be_cmd_if_destroy(struct be_ctrl_info *ctrl, u32 if_handle);
-extern int be_cmd_eq_create(struct be_ctrl_info *ctrl,
+extern int be_cmd_if_destroy(struct be_adapter *adapter, u32 if_handle);
+extern int be_cmd_eq_create(struct be_adapter *adapter,
 			struct be_queue_info *eq, int eq_delay);
-extern int be_cmd_cq_create(struct be_ctrl_info *ctrl,
+extern int be_cmd_cq_create(struct be_adapter *adapter,
 			struct be_queue_info *cq, struct be_queue_info *eq,
 			bool sol_evts, bool no_delay,
 			int num_cqe_dma_coalesce);
-extern int be_cmd_mccq_create(struct be_ctrl_info *ctrl,
+extern int be_cmd_mccq_create(struct be_adapter *adapter,
 			struct be_queue_info *mccq,
 			struct be_queue_info *cq);
-extern int be_cmd_txq_create(struct be_ctrl_info *ctrl,
+extern int be_cmd_txq_create(struct be_adapter *adapter,
 			struct be_queue_info *txq,
 			struct be_queue_info *cq);
-extern int be_cmd_rxq_create(struct be_ctrl_info *ctrl,
+extern int be_cmd_rxq_create(struct be_adapter *adapter,
 			struct be_queue_info *rxq, u16 cq_id,
 			u16 frag_size, u16 max_frame_size, u32 if_id,
 			u32 rss);
-extern int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
+extern int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 			int type);
-extern int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
+extern int be_cmd_link_status_query(struct be_adapter *adapter,
 			bool *link_up);
-extern int be_cmd_reset(struct be_ctrl_info *ctrl);
-extern int be_cmd_get_stats(struct be_ctrl_info *ctrl,
+extern int be_cmd_reset(struct be_adapter *adapter);
+extern int be_cmd_get_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
-extern int be_cmd_get_fw_ver(struct be_ctrl_info *ctrl, char *fw_ver);
+extern int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver);
 
-extern int be_cmd_modify_eqd(struct be_ctrl_info *ctrl, u32 eq_id, u32 eqd);
-extern int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id,
+extern int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd);
+extern int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id,
 			u16 *vtag_array, u32 num, bool untagged,
 			bool promiscuous);
-extern int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl,
+extern int be_cmd_promiscuous_config(struct be_adapter *adapter,
 			u8 port_num, bool en);
-extern int be_cmd_multicast_set(struct be_ctrl_info *ctrl, u32 if_id,
+extern int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 			struct dev_mc_list *mc_list, u32 mc_count);
-extern int be_cmd_set_flow_control(struct be_ctrl_info *ctrl,
+extern int be_cmd_set_flow_control(struct be_adapter *adapter,
 			u32 tx_fc, u32 rx_fc);
-extern int be_cmd_get_flow_control(struct be_ctrl_info *ctrl,
+extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 			u32 *tx_fc, u32 *rx_fc);
-extern int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num);
-extern void be_process_mcc(struct be_ctrl_info *ctrl);
+extern int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num);
+extern void be_process_mcc(struct be_adapter *adapter);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index f3f0f91..c480c19 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -16,6 +16,7 @@
  */
 
 #include "be.h"
+#include "be_cmds.h"
 #include <linux/ethtool.h>
 
 struct be_ethtool_stat {
@@ -148,7 +149,6 @@ static int
 be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	u32 tx_max, tx_min, tx_cur;
@@ -176,7 +176,7 @@ be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 	if (tx_cur > BE_MAX_EQD)
 		tx_cur = BE_MAX_EQD;
 	if (tx_eq->cur_eqd != tx_cur) {
-		status = be_cmd_modify_eqd(ctrl, tx_eq->q.id, tx_cur);
+		status = be_cmd_modify_eqd(adapter, tx_eq->q.id, tx_cur);
 		if (!status)
 			tx_eq->cur_eqd = tx_cur;
 	}
@@ -196,7 +196,8 @@ be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 		if (rx_cur > BE_MAX_EQD)
 			rx_cur = BE_MAX_EQD;
 		if (rx_eq->cur_eqd != rx_cur) {
-			status = be_cmd_modify_eqd(ctrl, rx_eq->q.id, rx_cur);
+			status = be_cmd_modify_eqd(adapter, rx_eq->q.id,
+					rx_cur);
 			if (!status)
 				rx_eq->cur_eqd = rx_cur;
 		}
@@ -310,8 +311,7 @@ be_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	be_cmd_get_flow_control(&adapter->ctrl, &ecmd->tx_pause,
-		&ecmd->rx_pause);
+	be_cmd_get_flow_control(adapter, &ecmd->tx_pause, &ecmd->rx_pause);
 	ecmd->autoneg = 0;
 }
 
@@ -324,7 +324,7 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	if (ecmd->autoneg != 0)
 		return -EINVAL;
 
-	status = be_cmd_set_flow_control(&adapter->ctrl, ecmd->tx_pause,
+	status = be_cmd_set_flow_control(adapter, ecmd->tx_pause,
 			ecmd->rx_pause);
 	if (!status)
 		dev_warn(&adapter->pdev->dev, "Pause param set failed.\n");
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c56487e..da5341f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -16,6 +16,7 @@
  */
 
 #include "be.h"
+#include "be_cmds.h"
 #include <asm/div64.h>
 
 MODULE_VERSION(DRV_VER);
@@ -60,9 +61,9 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 	return 0;
 }
 
-static void be_intr_set(struct be_ctrl_info *ctrl, bool enable)
+static void be_intr_set(struct be_adapter *adapter, bool enable)
 {
-	u8 __iomem *addr = ctrl->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET;
+	u8 __iomem *addr = adapter->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET;
 	u32 reg = ioread32(addr);
 	u32 enabled = reg & MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
 	if (!enabled && enable) {
@@ -77,23 +78,23 @@ static void be_intr_set(struct be_ctrl_info *ctrl, bool enable)
 	iowrite32(reg, addr);
 }
 
-static void be_rxq_notify(struct be_ctrl_info *ctrl, u16 qid, u16 posted)
+static void be_rxq_notify(struct be_adapter *adapter, u16 qid, u16 posted)
 {
 	u32 val = 0;
 	val |= qid & DB_RQ_RING_ID_MASK;
 	val |= posted << DB_RQ_NUM_POSTED_SHIFT;
-	iowrite32(val, ctrl->db + DB_RQ_OFFSET);
+	iowrite32(val, adapter->db + DB_RQ_OFFSET);
 }
 
-static void be_txq_notify(struct be_ctrl_info *ctrl, u16 qid, u16 posted)
+static void be_txq_notify(struct be_adapter *adapter, u16 qid, u16 posted)
 {
 	u32 val = 0;
 	val |= qid & DB_TXULP_RING_ID_MASK;
 	val |= (posted & DB_TXULP_NUM_POSTED_MASK) << DB_TXULP_NUM_POSTED_SHIFT;
-	iowrite32(val, ctrl->db + DB_TXULP1_OFFSET);
+	iowrite32(val, adapter->db + DB_TXULP1_OFFSET);
 }
 
-static void be_eq_notify(struct be_ctrl_info *ctrl, u16 qid,
+static void be_eq_notify(struct be_adapter *adapter, u16 qid,
 		bool arm, bool clear_int, u16 num_popped)
 {
 	u32 val = 0;
@@ -104,18 +105,17 @@ static void be_eq_notify(struct be_ctrl_info *ctrl, u16 qid,
 		val |= 1 << DB_EQ_CLR_SHIFT;
 	val |= 1 << DB_EQ_EVNT_SHIFT;
 	val |= num_popped << DB_EQ_NUM_POPPED_SHIFT;
-	iowrite32(val, ctrl->db + DB_EQ_OFFSET);
+	iowrite32(val, adapter->db + DB_EQ_OFFSET);
 }
 
-void be_cq_notify(struct be_ctrl_info *ctrl, u16 qid,
-		bool arm, u16 num_popped)
+void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm, u16 num_popped)
 {
 	u32 val = 0;
 	val |= qid & DB_CQ_RING_ID_MASK;
 	if (arm)
 		val |= 1 << DB_CQ_REARM_SHIFT;
 	val |= num_popped << DB_CQ_NUM_POPPED_SHIFT;
-	iowrite32(val, ctrl->db + DB_CQ_OFFSET);
+	iowrite32(val, adapter->db + DB_CQ_OFFSET);
 }
 
 
@@ -126,12 +126,12 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	int status = 0;
 
 	if (netif_running(netdev)) {
-		status = be_cmd_pmac_del(&adapter->ctrl, adapter->if_handle,
+		status = be_cmd_pmac_del(adapter, adapter->if_handle,
 				adapter->pmac_id);
 		if (status)
 			return status;
 
-		status = be_cmd_pmac_add(&adapter->ctrl, (u8 *)addr->sa_data,
+		status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
 				adapter->if_handle, &adapter->pmac_id);
 	}
 
@@ -214,9 +214,8 @@ static void netdev_stats_update(struct be_adapter *adapter)
 	dev_stats->tx_window_errors = 0;
 }
 
-void be_link_status_update(void *ctxt, bool link_up)
+void be_link_status_update(struct be_adapter *adapter, bool link_up)
 {
-	struct be_adapter *adapter = ctxt;
 	struct net_device *netdev = adapter->netdev;
 
 	/* If link came up or went down */
@@ -237,7 +236,6 @@ void be_link_status_update(void *ctxt, bool link_up)
 /* Update the EQ delay n BE based on the RX frags consumed / sec */
 static void be_rx_eqd_update(struct be_adapter *adapter)
 {
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_drvr_stats *stats = &adapter->stats.drvr_stats;
 	ulong now = jiffies;
@@ -270,7 +268,7 @@ static void be_rx_eqd_update(struct be_adapter *adapter)
 	if (eqd < 10)
 		eqd = 0;
 	if (eqd != rx_eq->cur_eqd)
-		be_cmd_modify_eqd(ctrl, rx_eq->q.id, eqd);
+		be_cmd_modify_eqd(adapter, rx_eq->q.id, eqd);
 
 	rx_eq->cur_eqd = eqd;
 }
@@ -412,8 +410,8 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 		struct skb_frag_struct *frag =
 			&skb_shinfo(skb)->frags[i];
 		busaddr = pci_map_page(pdev, frag->page,
-				       frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+					frag->page_offset,
+					frag->size, PCI_DMA_TODEVICE);
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, frag->size);
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
@@ -461,7 +459,7 @@ static int be_xmit(struct sk_buff *skb, struct net_device *netdev)
 		stopped = true;
 	}
 
-	be_txq_notify(&adapter->ctrl, txq->id, wrb_cnt);
+	be_txq_notify(adapter, txq->id, wrb_cnt);
 
 	be_tx_stats_update(adapter, wrb_cnt, copied, stopped);
 	return NETDEV_TX_OK;
@@ -502,10 +500,10 @@ static void be_vid_config(struct net_device *netdev)
 				ntags++;
 			}
 		}
-		be_cmd_vlan_config(&adapter->ctrl, adapter->if_handle,
+		be_cmd_vlan_config(adapter, adapter->if_handle,
 			vtag, ntags, 1, 0);
 	} else {
-		be_cmd_vlan_config(&adapter->ctrl, adapter->if_handle,
+		be_cmd_vlan_config(adapter, adapter->if_handle,
 			NULL, 0, 1, 1);
 	}
 }
@@ -515,13 +513,12 @@ static void be_vlan_register(struct net_device *netdev, struct vlan_group *grp)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 
-	be_eq_notify(ctrl, rx_eq->q.id, false, false, 0);
-	be_eq_notify(ctrl, tx_eq->q.id, false, false, 0);
+	be_eq_notify(adapter, rx_eq->q.id, false, false, 0);
+	be_eq_notify(adapter, tx_eq->q.id, false, false, 0);
 	adapter->vlan_grp = grp;
-	be_eq_notify(ctrl, rx_eq->q.id, true, false, 0);
-	be_eq_notify(ctrl, tx_eq->q.id, true, false, 0);
+	be_eq_notify(adapter, rx_eq->q.id, true, false, 0);
+	be_eq_notify(adapter, tx_eq->q.id, true, false, 0);
 }
 
 static void be_vlan_add_vid(struct net_device *netdev, u16 vid)
@@ -548,10 +545,9 @@ static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 static void be_set_multicast_list(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 
 	if (netdev->flags & IFF_PROMISC) {
-		be_cmd_promiscuous_config(ctrl, adapter->port_num, 1);
+		be_cmd_promiscuous_config(adapter, adapter->port_num, 1);
 		adapter->promiscuous = true;
 		goto done;
 	}
@@ -559,15 +555,15 @@ static void be_set_multicast_list(struct net_device *netdev)
 	/* BE was previously in promiscous mode; disable it */
 	if (adapter->promiscuous) {
 		adapter->promiscuous = false;
-		be_cmd_promiscuous_config(ctrl, adapter->port_num, 0);
+		be_cmd_promiscuous_config(adapter, adapter->port_num, 0);
 	}
 
 	if (netdev->flags & IFF_ALLMULTI) {
-		be_cmd_multicast_set(ctrl, adapter->if_handle, NULL, 0);
+		be_cmd_multicast_set(adapter, adapter->if_handle, NULL, 0);
 		goto done;
 	}
 
-	be_cmd_multicast_set(ctrl, adapter->if_handle, netdev->mc_list,
+	be_cmd_multicast_set(adapter, adapter->if_handle, netdev->mc_list,
 		netdev->mc_count);
 done:
 	return;
@@ -942,7 +938,7 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 
 	if (posted) {
 		atomic_add(posted, &rxq->used);
-		be_rxq_notify(&adapter->ctrl, rxq->id, posted);
+		be_rxq_notify(adapter, rxq->id, posted);
 	} else if (atomic_read(&rxq->used) == 0) {
 		/* Let be_worker replenish when memory is available */
 		adapter->rx_post_starved = true;
@@ -1010,7 +1006,7 @@ static void be_rx_q_clean(struct be_adapter *adapter)
 	while ((rxcp = be_rx_compl_get(adapter)) != NULL) {
 		be_rx_compl_discard(adapter, rxcp);
 		be_rx_compl_reset(rxcp);
-		be_cq_notify(&adapter->ctrl, rx_cq->id, true, 1);
+		be_cq_notify(adapter, rx_cq->id, true, 1);
 	}
 
 	/* Then free posted rx buffer that were not used */
@@ -1043,16 +1039,15 @@ static void be_tx_q_clean(struct be_adapter *adapter)
 static void be_mcc_queues_destroy(struct be_adapter *adapter)
 {
 	struct be_queue_info *q;
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 
-	q = &ctrl->mcc_obj.q;
+	q = &adapter->mcc_obj.q;
 	if (q->created)
-		be_cmd_q_destroy(ctrl, q, QTYPE_MCCQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_MCCQ);
 	be_queue_free(adapter, q);
 
-	q = &ctrl->mcc_obj.cq;
+	q = &adapter->mcc_obj.cq;
 	if (q->created)
-		be_cmd_q_destroy(ctrl, q, QTYPE_CQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_CQ);
 	be_queue_free(adapter, q);
 }
 
@@ -1060,25 +1055,24 @@ static void be_mcc_queues_destroy(struct be_adapter *adapter)
 static int be_mcc_queues_create(struct be_adapter *adapter)
 {
 	struct be_queue_info *q, *cq;
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 
 	/* Alloc MCC compl queue */
-	cq = &ctrl->mcc_obj.cq;
+	cq = &adapter->mcc_obj.cq;
 	if (be_queue_alloc(adapter, cq, MCC_CQ_LEN,
 			sizeof(struct be_mcc_cq_entry)))
 		goto err;
 
 	/* Ask BE to create MCC compl queue; share TX's eq */
-	if (be_cmd_cq_create(ctrl, cq, &adapter->tx_eq.q, false, true, 0))
+	if (be_cmd_cq_create(adapter, cq, &adapter->tx_eq.q, false, true, 0))
 		goto mcc_cq_free;
 
 	/* Alloc MCC queue */
-	q = &ctrl->mcc_obj.q;
+	q = &adapter->mcc_obj.q;
 	if (be_queue_alloc(adapter, q, MCC_Q_LEN, sizeof(struct be_mcc_wrb)))
 		goto mcc_cq_destroy;
 
 	/* Ask BE to create MCC queue */
-	if (be_cmd_mccq_create(ctrl, q, cq))
+	if (be_cmd_mccq_create(adapter, q, cq))
 		goto mcc_q_free;
 
 	return 0;
@@ -1086,7 +1080,7 @@ static int be_mcc_queues_create(struct be_adapter *adapter)
 mcc_q_free:
 	be_queue_free(adapter, q);
 mcc_cq_destroy:
-	be_cmd_q_destroy(ctrl, cq, QTYPE_CQ);
+	be_cmd_q_destroy(adapter, cq, QTYPE_CQ);
 mcc_cq_free:
 	be_queue_free(adapter, cq);
 err:
@@ -1099,7 +1093,7 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 
 	q = &adapter->tx_obj.q;
 	if (q->created) {
-		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_TXQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_TXQ);
 
 		/* No more tx completions can be rcvd now; clean up if there
 		 * are any pending completions or pending tx requests */
@@ -1109,12 +1103,12 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 
 	q = &adapter->tx_obj.cq;
 	if (q->created)
-		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_CQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_CQ);
 	be_queue_free(adapter, q);
 
 	q = &adapter->tx_eq.q;
 	if (q->created)
-		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_EQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_EQ);
 	be_queue_free(adapter, q);
 }
 
@@ -1132,7 +1126,7 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 		return -1;
 
 	/* Ask BE to create Tx Event queue */
-	if (be_cmd_eq_create(&adapter->ctrl, eq, adapter->tx_eq.cur_eqd))
+	if (be_cmd_eq_create(adapter, eq, adapter->tx_eq.cur_eqd))
 		goto tx_eq_free;
 	/* Alloc TX eth compl queue */
 	cq = &adapter->tx_obj.cq;
@@ -1141,7 +1135,7 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 		goto tx_eq_destroy;
 
 	/* Ask BE to create Tx eth compl queue */
-	if (be_cmd_cq_create(&adapter->ctrl, cq, eq, false, false, 3))
+	if (be_cmd_cq_create(adapter, cq, eq, false, false, 3))
 		goto tx_cq_free;
 
 	/* Alloc TX eth queue */
@@ -1150,18 +1144,18 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 		goto tx_cq_destroy;
 
 	/* Ask BE to create Tx eth queue */
-	if (be_cmd_txq_create(&adapter->ctrl, q, cq))
+	if (be_cmd_txq_create(adapter, q, cq))
 		goto tx_q_free;
 	return 0;
 
 tx_q_free:
 	be_queue_free(adapter, q);
 tx_cq_destroy:
-	be_cmd_q_destroy(&adapter->ctrl, cq, QTYPE_CQ);
+	be_cmd_q_destroy(adapter, cq, QTYPE_CQ);
 tx_cq_free:
 	be_queue_free(adapter, cq);
 tx_eq_destroy:
-	be_cmd_q_destroy(&adapter->ctrl, eq, QTYPE_EQ);
+	be_cmd_q_destroy(adapter, eq, QTYPE_EQ);
 tx_eq_free:
 	be_queue_free(adapter, eq);
 	return -1;
@@ -1173,19 +1167,19 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 
 	q = &adapter->rx_obj.q;
 	if (q->created) {
-		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_RXQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_RXQ);
 		be_rx_q_clean(adapter);
 	}
 	be_queue_free(adapter, q);
 
 	q = &adapter->rx_obj.cq;
 	if (q->created)
-		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_CQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_CQ);
 	be_queue_free(adapter, q);
 
 	q = &adapter->rx_eq.q;
 	if (q->created)
-		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_EQ);
+		be_cmd_q_destroy(adapter, q, QTYPE_EQ);
 	be_queue_free(adapter, q);
 }
 
@@ -1208,7 +1202,7 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 		return rc;
 
 	/* Ask BE to create Rx Event queue */
-	rc = be_cmd_eq_create(&adapter->ctrl, eq, adapter->rx_eq.cur_eqd);
+	rc = be_cmd_eq_create(adapter, eq, adapter->rx_eq.cur_eqd);
 	if (rc)
 		goto rx_eq_free;
 
@@ -1220,7 +1214,7 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 		goto rx_eq_destroy;
 
 	/* Ask BE to create Rx eth compl queue */
-	rc = be_cmd_cq_create(&adapter->ctrl, cq, eq, false, false, 3);
+	rc = be_cmd_cq_create(adapter, cq, eq, false, false, 3);
 	if (rc)
 		goto rx_cq_free;
 
@@ -1231,7 +1225,7 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 		goto rx_cq_destroy;
 
 	/* Ask BE to create Rx eth queue */
-	rc = be_cmd_rxq_create(&adapter->ctrl, q, cq->id, rx_frag_size,
+	rc = be_cmd_rxq_create(adapter, q, cq->id, rx_frag_size,
 		BE_MAX_JUMBO_FRAME_SIZE, adapter->if_handle, false);
 	if (rc)
 		goto rx_q_free;
@@ -1240,11 +1234,11 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 rx_q_free:
 	be_queue_free(adapter, q);
 rx_cq_destroy:
-	be_cmd_q_destroy(&adapter->ctrl, cq, QTYPE_CQ);
+	be_cmd_q_destroy(adapter, cq, QTYPE_CQ);
 rx_cq_free:
 	be_queue_free(adapter, cq);
 rx_eq_destroy:
-	be_cmd_q_destroy(&adapter->ctrl, eq, QTYPE_EQ);
+	be_cmd_q_destroy(adapter, eq, QTYPE_EQ);
 rx_eq_free:
 	be_queue_free(adapter, eq);
 	return rc;
@@ -1264,8 +1258,7 @@ static bool event_get(struct be_eq_obj *eq_obj, u16 *rid)
 	return true;
 }
 
-static int event_handle(struct be_ctrl_info *ctrl,
-			struct be_eq_obj *eq_obj)
+static int event_handle(struct be_adapter *adapter, struct be_eq_obj *eq_obj)
 {
 	u16 rid = 0, num = 0;
 
@@ -1273,7 +1266,7 @@ static int event_handle(struct be_ctrl_info *ctrl,
 		num++;
 
 	/* We can see an interrupt and no event */
-	be_eq_notify(ctrl, eq_obj->q.id, true, true, num);
+	be_eq_notify(adapter, eq_obj->q.id, true, true, num);
 	if (num)
 		napi_schedule(&eq_obj->napi);
 
@@ -1283,25 +1276,24 @@ static int event_handle(struct be_ctrl_info *ctrl,
 static irqreturn_t be_intx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
-        int isr;
+	int isr;
 
-	isr = ioread32(ctrl->csr + CEV_ISR0_OFFSET +
-                      ctrl->pci_func * CEV_ISR_SIZE);
+	isr = ioread32(adapter->csr + CEV_ISR0_OFFSET +
+			adapter->pci_func * CEV_ISR_SIZE);
 	if (!isr)
-                return IRQ_NONE;
+		return IRQ_NONE;
 
-        event_handle(ctrl, &adapter->tx_eq);
-        event_handle(ctrl, &adapter->rx_eq);
+	event_handle(adapter, &adapter->tx_eq);
+	event_handle(adapter, &adapter->rx_eq);
 
-        return IRQ_HANDLED;
+	return IRQ_HANDLED;
 }
 
 static irqreturn_t be_msix_rx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
 
-	event_handle(&adapter->ctrl, &adapter->rx_eq);
+	event_handle(adapter, &adapter->rx_eq);
 
 	return IRQ_HANDLED;
 }
@@ -1310,7 +1302,7 @@ static irqreturn_t be_msix_tx_mcc(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
 
-	event_handle(&adapter->ctrl, &adapter->tx_eq);
+	event_handle(adapter, &adapter->tx_eq);
 
 	return IRQ_HANDLED;
 }
@@ -1356,10 +1348,10 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 	/* All consumed */
 	if (work_done < budget) {
 		napi_complete(napi);
-		be_cq_notify(&adapter->ctrl, rx_cq->id, true, work_done);
+		be_cq_notify(adapter, rx_cq->id, true, work_done);
 	} else {
 		/* More to be consumed; continue with interrupts disabled */
-		be_cq_notify(&adapter->ctrl, rx_cq->id, false, work_done);
+		be_cq_notify(adapter, rx_cq->id, false, work_done);
 	}
 	return work_done;
 }
@@ -1380,7 +1372,7 @@ void be_process_tx(struct be_adapter *adapter)
 	}
 
 	if (num_cmpl) {
-		be_cq_notify(&adapter->ctrl, tx_cq->id, true, num_cmpl);
+		be_cq_notify(adapter, tx_cq->id, true, num_cmpl);
 
 		/* As Tx wrbs have been freed up, wake up netdev queue if
 		 * it was stopped due to lack of tx wrbs.
@@ -1408,7 +1400,7 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 
 	be_process_tx(adapter);
 
-	be_process_mcc(&adapter->ctrl);
+	be_process_mcc(adapter);
 
 	return 1;
 }
@@ -1420,7 +1412,7 @@ static void be_worker(struct work_struct *work)
 	int status;
 
 	/* Get Stats */
-	status = be_cmd_get_stats(&adapter->ctrl, &adapter->stats.cmd);
+	status = be_cmd_get_stats(adapter, &adapter->stats.cmd);
 	if (!status)
 		netdev_stats_update(adapter);
 
@@ -1454,8 +1446,7 @@ static void be_msix_enable(struct be_adapter *adapter)
 
 static inline int be_msix_vec_get(struct be_adapter *adapter, u32 eq_id)
 {
-	return adapter->msix_entries[eq_id -
-			8 * adapter->ctrl.pci_func].vector;
+	return adapter->msix_entries[eq_id - 8 * adapter->pci_func].vector;
 }
 
 static int be_msix_register(struct be_adapter *adapter)
@@ -1540,7 +1531,6 @@ done:
 static int be_open(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	bool link_up;
@@ -1554,16 +1544,16 @@ static int be_open(struct net_device *netdev)
 
 	be_irq_register(adapter);
 
-	be_intr_set(ctrl, true);
+	be_intr_set(adapter, true);
 
 	/* The evt queues are created in unarmed state; arm them */
-	be_eq_notify(ctrl, rx_eq->q.id, true, false, 0);
-	be_eq_notify(ctrl, tx_eq->q.id, true, false, 0);
+	be_eq_notify(adapter, rx_eq->q.id, true, false, 0);
+	be_eq_notify(adapter, tx_eq->q.id, true, false, 0);
 
 	/* Rx compl queue may be in unarmed state; rearm it */
-	be_cq_notify(ctrl, adapter->rx_obj.cq.id, true, 0);
+	be_cq_notify(adapter, adapter->rx_obj.cq.id, true, 0);
 
-	status = be_cmd_link_status_query(ctrl, &link_up);
+	status = be_cmd_link_status_query(adapter, &link_up);
 	if (status)
 		return status;
 	be_link_status_update(adapter, link_up);
@@ -1574,7 +1564,6 @@ static int be_open(struct net_device *netdev)
 
 static int be_setup(struct be_adapter *adapter)
 {
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct net_device *netdev = adapter->netdev;
 	u32 if_flags;
 	int status;
@@ -1582,7 +1571,7 @@ static int be_setup(struct be_adapter *adapter)
 	if_flags = BE_IF_FLAGS_BROADCAST | BE_IF_FLAGS_PROMISCUOUS |
 		BE_IF_FLAGS_MCAST_PROMISCUOUS | BE_IF_FLAGS_UNTAGGED |
 		BE_IF_FLAGS_PASS_L3L4_ERRORS;
-	status = be_cmd_if_create(ctrl, if_flags, netdev->dev_addr,
+	status = be_cmd_if_create(adapter, if_flags, netdev->dev_addr,
 			false/* pmac_invalid */, &adapter->if_handle,
 			&adapter->pmac_id);
 	if (status != 0)
@@ -1590,7 +1579,7 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_vid_config(netdev);
 
-	status = be_cmd_set_flow_control(ctrl, true, true);
+	status = be_cmd_set_flow_control(adapter, true, true);
 	if (status != 0)
 		goto if_destroy;
 
@@ -1613,19 +1602,17 @@ rx_qs_destroy:
 tx_qs_destroy:
 	be_tx_queues_destroy(adapter);
 if_destroy:
-	be_cmd_if_destroy(ctrl, adapter->if_handle);
+	be_cmd_if_destroy(adapter, adapter->if_handle);
 do_none:
 	return status;
 }
 
 static int be_clear(struct be_adapter *adapter)
 {
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
-
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
 
-	be_cmd_if_destroy(ctrl, adapter->if_handle);
+	be_cmd_if_destroy(adapter, adapter->if_handle);
 
 	be_mcc_queues_destroy(adapter);
 	return 0;
@@ -1634,7 +1621,6 @@ static int be_clear(struct be_adapter *adapter)
 static int be_close(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	int vec;
@@ -1645,7 +1631,7 @@ static int be_close(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	adapter->link_up = false;
 
-	be_intr_set(ctrl, false);
+	be_intr_set(adapter, false);
 
 	if (adapter->msix_enabled) {
 		vec = be_msix_vec_get(adapter, tx_eq->q.id);
@@ -1704,13 +1690,12 @@ static void be_netdev_init(struct net_device *netdev)
 
 static void be_unmap_pci_bars(struct be_adapter *adapter)
 {
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
-	if (ctrl->csr)
-		iounmap(ctrl->csr);
-	if (ctrl->db)
-		iounmap(ctrl->db);
-	if (ctrl->pcicfg)
-		iounmap(ctrl->pcicfg);
+	if (adapter->csr)
+		iounmap(adapter->csr);
+	if (adapter->db)
+		iounmap(adapter->db);
+	if (adapter->pcicfg)
+		iounmap(adapter->pcicfg);
 }
 
 static int be_map_pci_bars(struct be_adapter *adapter)
@@ -1721,19 +1706,19 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 			pci_resource_len(adapter->pdev, 2));
 	if (addr == NULL)
 		return -ENOMEM;
-	adapter->ctrl.csr = addr;
+	adapter->csr = addr;
 
 	addr = ioremap_nocache(pci_resource_start(adapter->pdev, 4),
 			128 * 1024);
 	if (addr == NULL)
 		goto pci_map_err;
-	adapter->ctrl.db = addr;
+	adapter->db = addr;
 
 	addr = ioremap_nocache(pci_resource_start(adapter->pdev, 1),
 			pci_resource_len(adapter->pdev, 1));
 	if (addr == NULL)
 		goto pci_map_err;
-	adapter->ctrl.pcicfg = addr;
+	adapter->pcicfg = addr;
 
 	return 0;
 pci_map_err:
@@ -1744,7 +1729,7 @@ pci_map_err:
 
 static void be_ctrl_cleanup(struct be_adapter *adapter)
 {
-	struct be_dma_mem *mem = &adapter->ctrl.mbox_mem_alloced;
+	struct be_dma_mem *mem = &adapter->mbox_mem_alloced;
 
 	be_unmap_pci_bars(adapter);
 
@@ -1753,12 +1738,10 @@ static void be_ctrl_cleanup(struct be_adapter *adapter)
 			mem->va, mem->dma);
 }
 
-/* Initialize the mbox required to send cmds to BE */
 static int be_ctrl_init(struct be_adapter *adapter)
 {
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
-	struct be_dma_mem *mbox_mem_alloc = &ctrl->mbox_mem_alloced;
-	struct be_dma_mem *mbox_mem_align = &ctrl->mbox_mem;
+	struct be_dma_mem *mbox_mem_alloc = &adapter->mbox_mem_alloced;
+	struct be_dma_mem *mbox_mem_align = &adapter->mbox_mem;
 	int status;
 	u32 val;
 
@@ -1777,15 +1760,12 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	mbox_mem_align->va = PTR_ALIGN(mbox_mem_alloc->va, 16);
 	mbox_mem_align->dma = PTR_ALIGN(mbox_mem_alloc->dma, 16);
 	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
-	spin_lock_init(&ctrl->mbox_lock);
-	spin_lock_init(&ctrl->mcc_lock);
-	spin_lock_init(&ctrl->mcc_cq_lock);
-
-	ctrl->async_cb = be_link_status_update;
-	ctrl->adapter_ctxt = adapter;
+	spin_lock_init(&adapter->mbox_lock);
+	spin_lock_init(&adapter->mcc_lock);
+	spin_lock_init(&adapter->mcc_cq_lock);
 
-	val = ioread32(ctrl->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET);
-	ctrl->pci_func = (val >> MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT) &
+	val = ioread32(adapter->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET);
+	adapter->pci_func = (val >> MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT) &
 					MEMBAR_CTRL_INT_CTRL_PFUNC_MASK;
 	return 0;
 }
@@ -1840,18 +1820,17 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 static int be_hw_up(struct be_adapter *adapter)
 {
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	int status;
 
-	status = be_cmd_POST(ctrl);
+	status = be_cmd_POST(adapter);
 	if (status)
 		return status;
 
-	status = be_cmd_get_fw_ver(ctrl, adapter->fw_ver);
+	status = be_cmd_get_fw_ver(adapter, adapter->fw_ver);
 	if (status)
 		return status;
 
-	status = be_cmd_query_fw_cfg(ctrl, &adapter->port_num);
+	status = be_cmd_query_fw_cfg(adapter, &adapter->port_num);
 	return status;
 }
 
@@ -1861,7 +1840,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	int status = 0;
 	struct be_adapter *adapter;
 	struct net_device *netdev;
-	struct be_ctrl_info *ctrl;
 	u8 mac[ETH_ALEN];
 
 	status = pci_enable_device(pdev);
@@ -1896,7 +1874,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		}
 	}
 
-	ctrl = &adapter->ctrl;
 	status = be_ctrl_init(adapter);
 	if (status)
 		goto free_netdev;
@@ -1909,7 +1886,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto stats_clean;
 
-	status = be_cmd_mac_addr_query(ctrl, mac, MAC_ADDRESS_TYPE_NETWORK,
+	status = be_cmd_mac_addr_query(adapter, mac, MAC_ADDRESS_TYPE_NETWORK,
 			true /* permanent */, 0);
 	if (status)
 		goto stats_clean;
-- 
1.6.0.4

