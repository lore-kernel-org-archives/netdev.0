From: Ajit Khaparde <ajit.khaparde@broadcom.com>
Subject: [PATCH net-next 1/2] be2net: Declare some u16 fields as u32 to improve performance
Date: Tue, 23 Feb 2016 00:33:48 +0530
Message-ID: <1456167828-31441-1-git-send-email-ajit.khaparde@broadcom.com>
To: ajit.khaparde@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:53663 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751977AbcBVTFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 14:05:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When 16-bit integers are loaded on CPUs with high order native
register sizes, the CPU could use some extra ops before using them.
And currently some of the frequently used fields in the driver like
the producer and consumer indices of the queues are declared as u16.

This patch declares such fields as u32.  With this change we see the
64-byte packets per second numbers improve by about 4%.

Signed-off-by: Ajit Khaparde <ajit.khaparde@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 18 +++++++++---------
 drivers/net/ethernet/emulex/benet/be_cmds.c |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 16 +++++++++-------
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index ab24f84..756f25b 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -124,27 +124,27 @@ struct be_dma_mem {
 };
 
 struct be_queue_info {
+	u32 len;
+	u32 entry_size;	/* Size of an element in the queue */
+	u32 tail, head;
+	atomic_t used;	/* Number of valid elements in the queue */
+	u32 id;
 	struct be_dma_mem dma_mem;
-	u16 len;
-	u16 entry_size;	/* Size of an element in the queue */
-	u16 id;
-	u16 tail, head;
 	bool created;
-	atomic_t used;	/* Number of valid elements in the queue */
 };
 
-static inline u32 MODULO(u16 val, u16 limit)
+static inline u32 MODULO(u32 val, u32 limit)
 {
 	BUG_ON(limit & (limit - 1));
 	return val & (limit - 1);
 }
 
-static inline void index_adv(u16 *index, u16 val, u16 limit)
+static inline void index_adv(u32 *index, u32 val, u32 limit)
 {
 	*index = MODULO((*index + val), limit);
 }
 
-static inline void index_inc(u16 *index, u16 limit)
+static inline void index_inc(u32 *index, u32 limit)
 {
 	*index = MODULO((*index + 1), limit);
 }
@@ -169,7 +169,7 @@ static inline void queue_head_inc(struct be_queue_info *q)
 	index_inc(&q->head, q->len);
 }
 
-static inline void index_dec(u16 *index, u16 limit)
+static inline void index_dec(u32 *index, u32 limit)
 {
 	*index = MODULO((*index - 1), limit);
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 66fa214..22402db 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -596,7 +596,7 @@ static int be_mcc_notify_wait(struct be_adapter *adapter)
 	int status;
 	struct be_mcc_wrb *wrb;
 	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
-	u16 index = mcc_obj->q.head;
+	u32 index = mcc_obj->q.head;
 	struct be_cmd_resp_hdr *resp;
 
 	index_dec(&index, mcc_obj->q.len);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4624846..0bd64f1 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -849,9 +849,9 @@ static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
 }
 
 /* Grab a WRB header for xmit */
-static u16 be_tx_get_wrb_hdr(struct be_tx_obj *txo)
+static u32 be_tx_get_wrb_hdr(struct be_tx_obj *txo)
 {
-	u16 head = txo->q.head;
+	u32 head = txo->q.head;
 
 	queue_head_inc(&txo->q);
 	return head;
@@ -895,7 +895,7 @@ static void be_tx_setup_wrb_frag(struct be_tx_obj *txo, dma_addr_t busaddr,
  * WRBs of the current packet are unmapped. Invoked to handle tx setup errors.
  */
 static void be_xmit_restore(struct be_adapter *adapter,
-			    struct be_tx_obj *txo, u16 head, bool map_single,
+			    struct be_tx_obj *txo, u32 head, bool map_single,
 			    u32 copied)
 {
 	struct device *dev;
@@ -930,7 +930,7 @@ static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
 	struct device *dev = &adapter->pdev->dev;
 	struct be_queue_info *txq = &txo->q;
 	bool map_single = false;
-	u16 head = txq->head;
+	u32 head = txq->head;
 	dma_addr_t busaddr;
 	int len;
 
@@ -1990,7 +1990,7 @@ static struct be_rx_page_info *get_rx_page_info(struct be_rx_obj *rxo)
 	struct be_adapter *adapter = rxo->adapter;
 	struct be_rx_page_info *rx_page_info;
 	struct be_queue_info *rxq = &rxo->q;
-	u16 frag_idx = rxq->tail;
+	u32 frag_idx = rxq->tail;
 
 	rx_page_info = &rxo->page_info_tbl[frag_idx];
 	BUG_ON(!rx_page_info->page);
@@ -2401,10 +2401,11 @@ static u16 be_tx_compl_process(struct be_adapter *adapter,
 {
 	struct sk_buff **sent_skbs = txo->sent_skb_list;
 	struct be_queue_info *txq = &txo->q;
-	u16 frag_index, num_wrbs = 0;
 	struct sk_buff *skb = NULL;
 	bool unmap_skb_hdr = false;
 	struct be_eth_wrb *wrb;
+	u16 num_wrbs = 0;
+	u32 frag_index;
 
 	do {
 		if (sent_skbs[txq->tail]) {
@@ -2516,10 +2517,11 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 
 static void be_tx_compl_clean(struct be_adapter *adapter)
 {
-	u16 end_idx, notified_idx, cmpl = 0, timeo = 0, num_wrbs = 0;
 	struct device *dev = &adapter->pdev->dev;
+	u16 cmpl = 0, timeo = 0, num_wrbs = 0;
 	struct be_tx_compl_info *txcp;
 	struct be_queue_info *txq;
+	u32 end_idx, notified_idx;
 	struct be_tx_obj *txo;
 	int i, pending_txqs;
 
-- 
2.4.3
