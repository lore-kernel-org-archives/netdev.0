From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [net-next-2.6 PATCH 2/2] be2net: Code changes in Tx path to use
	skb_dma_map/skb_dma_unmap
Date: Fri, 4 Sep 2009 18:42:29 +0530
Message-ID: <20090904131220.GA10754@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:60424 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756548AbZIDNM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 09:12:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code changes to
 - In the tx completion processing, there were instances of unmapping a
memory as a page which was originally mapped as single. This patch takes care
of this by using skb_dma_map()/skb_dma_unmap() to map/unmap Tx buffers.
 - set gso_max_size to 65535. This was not done till now.


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |   62 ++++++++++++++++++++++--------------------
 1 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index d09106f..ce11bba 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -385,15 +385,19 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	struct be_eth_wrb *wrb;
 	struct be_eth_hdr_wrb *hdr;
 
-	atomic_add(wrb_cnt, &txq->used);
 	hdr = queue_head_node(txq);
+	atomic_add(wrb_cnt, &txq->used);
 	queue_head_inc(txq);
 
+	if (skb_dma_map(&pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_err(&pdev->dev, "TX DMA mapping failed\n");
+		return 0;
+	}
+
 	if (skb->len > skb->data_len) {
 		int len = skb->len - skb->data_len;
-		busaddr = pci_map_single(pdev, skb->data, len,
-					 PCI_DMA_TODEVICE);
 		wrb = queue_head_node(txq);
+		busaddr = skb_shinfo(skb)->dma_head;
 		wrb_fill(wrb, busaddr, len);
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
 		queue_head_inc(txq);
@@ -403,9 +407,8 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag =
 			&skb_shinfo(skb)->frags[i];
-		busaddr = pci_map_page(pdev, frag->page,
-					frag->page_offset,
-					frag->size, PCI_DMA_TODEVICE);
+
+		busaddr = skb_shinfo(skb)->dma_maps[i];
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, frag->size);
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
@@ -429,6 +432,7 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 
 static netdev_tx_t be_xmit(struct sk_buff *skb,
 				 struct net_device *netdev)
+
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_tx_obj *tx_obj = &adapter->tx_obj;
@@ -440,23 +444,28 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	wrb_cnt = wrb_cnt_for_skb(skb, &dummy_wrb);
 
 	copied = make_tx_wrbs(adapter, skb, wrb_cnt, dummy_wrb);
+	if (copied) {
+		/* record the sent skb in the sent_skb table */
+		BUG_ON(tx_obj->sent_skb_list[start]);
+		tx_obj->sent_skb_list[start] = skb;
+
+		/* Ensure txq has space for the next skb; Else stop the queue
+		 * *BEFORE* ringing the tx doorbell, so that we serialze the
+		 * tx compls of the current transmit which'll wake up the queue
+		 */
+		if ((BE_MAX_TX_FRAG_COUNT + atomic_read(&txq->used)) >=
+								txq->len) {
+			netif_stop_queue(netdev);
+			stopped = true;
+		}
 
-	/* record the sent skb in the sent_skb table */
-	BUG_ON(tx_obj->sent_skb_list[start]);
-	tx_obj->sent_skb_list[start] = skb;
+		be_txq_notify(adapter, txq->id, wrb_cnt);
 
-	/* Ensure that txq has space for the next skb; Else stop the queue
-	 * *BEFORE* ringing the tx doorbell, so that we serialze the
-	 * tx compls of the current transmit which'll wake up the queue
-	 */
-	if ((BE_MAX_TX_FRAG_COUNT + atomic_read(&txq->used)) >= txq->len) {
-		netif_stop_queue(netdev);
-		stopped = true;
+		be_tx_stats_update(adapter, wrb_cnt, copied, stopped);
+	} else {
+		txq->head = start;
+		dev_kfree_skb_any(skb);
 	}
-
-	be_txq_notify(adapter, txq->id, wrb_cnt);
-
-	be_tx_stats_update(adapter, wrb_cnt, copied, stopped);
 	return NETDEV_TX_OK;
 }
 
@@ -958,10 +967,8 @@ static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
 static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 {
 	struct be_queue_info *txq = &adapter->tx_obj.q;
-	struct be_eth_wrb *wrb;
 	struct sk_buff **sent_skbs = adapter->tx_obj.sent_skb_list;
 	struct sk_buff *sent_skb;
-	u64 busaddr;
 	u16 cur_index, num_wrbs = 0;
 
 	cur_index = txq->tail;
@@ -971,19 +978,12 @@ static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 
 	do {
 		cur_index = txq->tail;
-		wrb = queue_tail_node(txq);
-		be_dws_le_to_cpu(wrb, sizeof(*wrb));
-		busaddr = ((u64)wrb->frag_pa_hi << 32) | (u64)wrb->frag_pa_lo;
-		if (busaddr != 0) {
-			pci_unmap_single(adapter->pdev, busaddr,
-				wrb->frag_len, PCI_DMA_TODEVICE);
-		}
 		num_wrbs++;
 		queue_tail_inc(txq);
 	} while (cur_index != last_index);
 
 	atomic_sub(num_wrbs, &txq->used);
-
+	skb_dma_unmap(&adapter->pdev->dev, sent_skb, DMA_TO_DEVICE);
 	kfree_skb(sent_skb);
 }
 
@@ -1892,6 +1892,8 @@ static void be_netdev_init(struct net_device *netdev)
 
 	adapter->rx_csum = true;
 
+	netif_set_gso_max_size(netdev, 65535);
+
 	BE_SET_NETDEV_OPS(netdev, &be_netdev_ops);
 
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
-- 
1.6.0.4

