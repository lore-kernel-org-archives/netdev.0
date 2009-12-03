From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 08/10] be2net: remove use of skb_dma_map/unmap
Date: Wed, 02 Dec 2009 18:48:18 -0800
Message-ID: <20091203024817.2232.192.stgit@localhost.localdomain>
References: <20091203024519.2232.6084.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:37983 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755740AbZLCCsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 21:48:30 -0500
In-Reply-To: <20091203024519.2232.6084.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Due to the fact that skb_dma_map/unmap do not work correctly when a HW
IOMMU is enabled it has been recommended to go about removing the calls
from the network device drivers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Eilon Greenstein <eilong@broadcom.com>
---

 drivers/net/benet/be_main.c |   37 ++++++++++++++++++++++++++-----------
 1 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7959364..f6d8a88 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -390,15 +390,11 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	atomic_add(wrb_cnt, &txq->used);
 	queue_head_inc(txq);
 
-	if (skb_dma_map(&pdev->dev, skb, DMA_TO_DEVICE)) {
-		dev_err(&pdev->dev, "TX DMA mapping failed\n");
-		return 0;
-	}
-
 	if (skb->len > skb->data_len) {
 		int len = skb->len - skb->data_len;
+		busaddr = pci_map_single(pdev, skb->data, len,
+					 PCI_DMA_TODEVICE);
 		wrb = queue_head_node(txq);
-		busaddr = skb_shinfo(skb)->dma_head;
 		wrb_fill(wrb, busaddr, len);
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
 		queue_head_inc(txq);
@@ -408,8 +404,9 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag =
 			&skb_shinfo(skb)->frags[i];
-
-		busaddr = skb_shinfo(skb)->dma_maps[i];
+		busaddr = pci_map_page(pdev, frag->page,
+				       frag->page_offset,
+				       frag->size, PCI_DMA_TODEVICE);
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, frag->size);
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
@@ -982,23 +979,41 @@ static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
 static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 {
 	struct be_queue_info *txq = &adapter->tx_obj.q;
+	struct be_eth_wrb *wrb;
 	struct sk_buff **sent_skbs = adapter->tx_obj.sent_skb_list;
 	struct sk_buff *sent_skb;
+	u64 busaddr;
 	u16 cur_index, num_wrbs = 0;
 
 	cur_index = txq->tail;
 	sent_skb = sent_skbs[cur_index];
 	BUG_ON(!sent_skb);
 	sent_skbs[cur_index] = NULL;
+	wrb = queue_tail_node(txq);
+	be_dws_le_to_cpu(wrb, sizeof(*wrb));
+	busaddr = ((u64)wrb->frag_pa_hi << 32) | (u64)wrb->frag_pa_lo;
+	if (busaddr != 0) {
+		pci_unmap_single(adapter->pdev, busaddr,
+				 wrb->frag_len, PCI_DMA_TODEVICE);
+	}
+	num_wrbs++;
+	queue_tail_inc(txq);
 
-	do {
+	while (cur_index != last_index) {
 		cur_index = txq->tail;
+		wrb = queue_tail_node(txq);
+		be_dws_le_to_cpu(wrb, sizeof(*wrb));
+		busaddr = ((u64)wrb->frag_pa_hi << 32) | (u64)wrb->frag_pa_lo;
+		if (busaddr != 0) {
+			pci_unmap_page(adapter->pdev, busaddr,
+				       wrb->frag_len, PCI_DMA_TODEVICE);
+		}
 		num_wrbs++;
 		queue_tail_inc(txq);
-	} while (cur_index != last_index);
+	}
 
 	atomic_sub(num_wrbs, &txq->used);
-	skb_dma_unmap(&adapter->pdev->dev, sent_skb, DMA_TO_DEVICE);
+
 	kfree_skb(sent_skb);
 }
 

