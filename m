From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6 1/2] be2net: handle dma mapping errors in Tx
 path
Date: Tue, 23 Mar 2010 12:11:12 +0530
Message-ID: <20100323064112.GA3706@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:24743 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752826Ab0CWGlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 02:41:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   41 ++++++++++++++++++++++++++++++++++++++---
 1 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 43e8032..0800c63 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -386,26 +386,48 @@ static void wrb_fill_hdr(struct be_eth_hdr_wrb *hdr, struct sk_buff *skb,
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, len, hdr, len);
 }
 
+static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
+		bool unmap_single)
+{
+	dma_addr_t dma;
+
+	be_dws_le_to_cpu(wrb, sizeof(*wrb));
+
+	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
+	if (dma != 0) {
+		if (unmap_single)
+			pci_unmap_single(pdev, dma, wrb->frag_len,
+				PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(pdev, dma, wrb->frag_len,
+				PCI_DMA_TODEVICE);
+	}
+}
 
 static int make_tx_wrbs(struct be_adapter *adapter,
 		struct sk_buff *skb, u32 wrb_cnt, bool dummy_wrb)
 {
-	u64 busaddr;
-	u32 i, copied = 0;
+	dma_addr_t busaddr;
+	int i, copied = 0;
 	struct pci_dev *pdev = adapter->pdev;
 	struct sk_buff *first_skb = skb;
 	struct be_queue_info *txq = &adapter->tx_obj.q;
 	struct be_eth_wrb *wrb;
 	struct be_eth_hdr_wrb *hdr;
+	bool map_single = false;
+	u16 map_head;
 
 	hdr = queue_head_node(txq);
-	atomic_add(wrb_cnt, &txq->used);
 	queue_head_inc(txq);
+	map_head = txq->head;
 
 	if (skb->len > skb->data_len) {
 		int len = skb->len - skb->data_len;
 		busaddr = pci_map_single(pdev, skb->data, len,
 					 PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, busaddr))
+			goto dma_err;
+		map_single = true;
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, len);
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
@@ -419,6 +441,8 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 		busaddr = pci_map_page(pdev, frag->page,
 				       frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, busaddr))
+			goto dma_err;
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, frag->size);
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
@@ -438,6 +462,16 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	be_dws_cpu_to_le(hdr, sizeof(*hdr));
 
 	return copied;
+dma_err:
+	txq->head = map_head;
+	while (copied) {
+		wrb = queue_head_node(txq);
+		unmap_tx_frag(pdev, wrb, map_single);
+		map_single = false;
+		copied -= wrb->frag_len;
+		queue_head_inc(txq);
+	}
+	return 0;
 }
 
 static netdev_tx_t be_xmit(struct sk_buff *skb,
@@ -462,6 +496,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 		 * *BEFORE* ringing the tx doorbell, so that we serialze the
 		 * tx compls of the current transmit which'll wake up the queue
 		 */
+		atomic_add(wrb_cnt, &txq->used);
 		if ((BE_MAX_TX_FRAG_COUNT + atomic_read(&txq->used)) >=
 								txq->len) {
 			netif_stop_queue(netdev);
-- 
1.6.3.3

