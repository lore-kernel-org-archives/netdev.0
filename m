From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH v2 net-next 2/4] be2net: Refactor be_xmit_enqueue() routine
Date: Mon, 16 Feb 2015 08:03:46 +0530
Message-ID: <1424054028-23659-3-git-send-email-sriharsha.basavapatna@emulex.com>
References: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:57681 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbbBPCly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 21:41:54 -0500
In-Reply-To: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Reduce code duplication by moving WRB-frags setup into a function.
- Do not setup WRB-header before frags are setup, which is unncessary if
  there's errors while setting up frags. We should only grab an entry for
  the header, setup the frags and if everything is fine setup the header.
- The error cleanup can be moved into a small function.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 126 +++++++++++++++++++---------
 1 file changed, 86 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 40f54c0..2f17937 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -812,7 +812,80 @@ static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
 	}
 }
 
-/* Returns the number of WRBs used up by the skb */
+/* Grab a WRB header for xmit */
+static u16 be_tx_get_wrb_hdr(struct be_tx_obj *txo)
+{
+	u16 head = txo->q.head;
+
+	queue_head_inc(&txo->q);
+	return head;
+}
+
+/* Set up the WRB header for xmit */
+static void be_tx_setup_wrb_hdr(struct be_adapter *adapter,
+				struct be_tx_obj *txo,
+				struct be_wrb_params *wrb_params,
+				struct sk_buff *skb, u16 head)
+{
+	u32 num_frags = skb_wrb_cnt(skb);
+	struct be_queue_info *txq = &txo->q;
+	struct be_eth_hdr_wrb *hdr = queue_index_node(txq, head);
+
+	wrb_fill_hdr(adapter, hdr, wrb_params, skb);
+	be_dws_cpu_to_le(hdr, sizeof(*hdr));
+
+	BUG_ON(txo->sent_skb_list[head]);
+	txo->sent_skb_list[head] = skb;
+	txo->last_req_hdr = head;
+	atomic_add(num_frags, &txq->used);
+	txo->last_req_wrb_cnt = num_frags;
+	txo->pend_wrb_cnt += num_frags;
+}
+
+/* Setup a WRB fragment (buffer descriptor) for xmit */
+static void be_tx_setup_wrb_frag(struct be_tx_obj *txo, dma_addr_t busaddr,
+				 int len)
+{
+	struct be_eth_wrb *wrb;
+	struct be_queue_info *txq = &txo->q;
+
+	wrb = queue_head_node(txq);
+	wrb_fill(wrb, busaddr, len);
+	queue_head_inc(txq);
+}
+
+/* Bring the queue back to the state it was in before be_xmit_enqueue() routine
+ * was invoked. The producer index is restored to the previous packet and the
+ * WRBs of the current packet are unmapped. Invoked to handle tx setup errors.
+ */
+static void be_xmit_restore(struct be_adapter *adapter,
+			    struct be_tx_obj *txo, u16 head, bool map_single,
+			    u32 copied)
+{
+	struct device *dev;
+	struct be_eth_wrb *wrb;
+	struct be_queue_info *txq = &txo->q;
+
+	dev = &adapter->pdev->dev;
+	txq->head = head;
+
+	/* skip the first wrb (hdr); it's not mapped */
+	queue_head_inc(txq);
+	while (copied) {
+		wrb = queue_head_node(txq);
+		unmap_tx_frag(dev, wrb, map_single);
+		map_single = false;
+		copied -= le32_to_cpu(wrb->frag_len);
+		queue_head_inc(txq);
+	}
+
+	txq->head = head;
+}
+
+/* Enqueue the given packet for transmit. This routine allocates WRBs for the
+ * packet, dma maps the packet buffers and sets up the WRBs. Returns the number
+ * of WRBs used up by the packet.
+ */
 static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
 			   struct sk_buff *skb,
 			   struct be_wrb_params *wrb_params)
@@ -820,70 +893,43 @@ static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
 	u32 i, copied = 0, wrb_cnt = skb_wrb_cnt(skb);
 	struct device *dev = &adapter->pdev->dev;
 	struct be_queue_info *txq = &txo->q;
-	struct be_eth_hdr_wrb *hdr;
 	bool map_single = false;
-	struct be_eth_wrb *wrb;
-	dma_addr_t busaddr;
 	u16 head = txq->head;
+	dma_addr_t busaddr;
+	int len;
 
-	hdr = queue_head_node(txq);
-	wrb_fill_hdr(adapter, hdr, wrb_params, skb);
-	be_dws_cpu_to_le(hdr, sizeof(*hdr));
-
-	queue_head_inc(txq);
+	head = be_tx_get_wrb_hdr(txo);
 
 	if (skb->len > skb->data_len) {
-		int len = skb_headlen(skb);
+		len = skb_headlen(skb);
 
 		busaddr = dma_map_single(dev, skb->data, len, DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, busaddr))
 			goto dma_err;
 		map_single = true;
-		wrb = queue_head_node(txq);
-		wrb_fill(wrb, busaddr, len);
-		queue_head_inc(txq);
+		be_tx_setup_wrb_frag(txo, busaddr, len);
 		copied += len;
 	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+		len = skb_frag_size(frag);
 
-		busaddr = skb_frag_dma_map(dev, frag, 0,
-					   skb_frag_size(frag), DMA_TO_DEVICE);
+		busaddr = skb_frag_dma_map(dev, frag, 0, len, DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, busaddr))
 			goto dma_err;
-		wrb = queue_head_node(txq);
-		wrb_fill(wrb, busaddr, skb_frag_size(frag));
-		queue_head_inc(txq);
-		copied += skb_frag_size(frag);
+		be_tx_setup_wrb_frag(txo, busaddr, len);
+		copied += len;
 	}
 
-	BUG_ON(txo->sent_skb_list[head]);
-	txo->sent_skb_list[head] = skb;
-	txo->last_req_hdr = head;
-	atomic_add(wrb_cnt, &txq->used);
-	txo->last_req_wrb_cnt = wrb_cnt;
-	txo->pend_wrb_cnt += wrb_cnt;
+	be_tx_setup_wrb_hdr(adapter, txo, wrb_params, skb, head);
 
 	be_tx_stats_update(txo, skb);
 	return wrb_cnt;
 
 dma_err:
-	/* Bring the queue back to the state it was in before this
-	 * routine was invoked.
-	 */
-	txq->head = head;
-	/* skip the first wrb (hdr); it's not mapped */
-	queue_head_inc(txq);
-	while (copied) {
-		wrb = queue_head_node(txq);
-		unmap_tx_frag(dev, wrb, map_single);
-		map_single = false;
-		copied -= le32_to_cpu(wrb->frag_len);
-		adapter->drv_stats.dma_map_errors++;
-		queue_head_inc(txq);
-	}
-	txq->head = head;
+	adapter->drv_stats.dma_map_errors++;
+	be_xmit_restore(adapter, txo, head, map_single, copied);
 	return 0;
 }
 
-- 
2.2.0.65.g9abc44b
