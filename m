From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6 2/2] be2net: fix unmap_single/page() called
 incorrectly in Tx compl processing
Date: Tue, 23 Mar 2010 12:11:34 +0530
Message-ID: <20100323064134.GA3733@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:25152 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754431Ab0CWGll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 02:41:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first wrb seen by tx compl processing does not have a dma handle in it.
Currently, pci_unmap_single() is attempted on this wrb and pci_unmap_page() on the
rest. So, pci_unmap_page() gets incorrectly called on the dma hdl of skb->data (that
was mapped using map_single()). This patch fixes this issue.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   33 ++++++++++++---------------------
 1 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 0800c63..174e5f8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1047,35 +1047,26 @@ static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 	struct be_eth_wrb *wrb;
 	struct sk_buff **sent_skbs = adapter->tx_obj.sent_skb_list;
 	struct sk_buff *sent_skb;
-	u64 busaddr;
-	u16 cur_index, num_wrbs = 0;
+	u16 cur_index, num_wrbs = 1; /* account for hdr wrb */
+	bool unmap_skb_hdr = true;
 
-	cur_index = txq->tail;
-	sent_skb = sent_skbs[cur_index];
+	sent_skb = sent_skbs[txq->tail];
 	BUG_ON(!sent_skb);
-	sent_skbs[cur_index] = NULL;
-	wrb = queue_tail_node(txq);
-	be_dws_le_to_cpu(wrb, sizeof(*wrb));
-	busaddr = ((u64)wrb->frag_pa_hi << 32) | (u64)wrb->frag_pa_lo;
-	if (busaddr != 0) {
-		pci_unmap_single(adapter->pdev, busaddr,
-				 wrb->frag_len, PCI_DMA_TODEVICE);
-	}
-	num_wrbs++;
+	sent_skbs[txq->tail] = NULL;
+
+	/* skip header wrb */
 	queue_tail_inc(txq);
 
-	while (cur_index != last_index) {
+	do {
 		cur_index = txq->tail;
 		wrb = queue_tail_node(txq);
-		be_dws_le_to_cpu(wrb, sizeof(*wrb));
-		busaddr = ((u64)wrb->frag_pa_hi << 32) | (u64)wrb->frag_pa_lo;
-		if (busaddr != 0) {
-			pci_unmap_page(adapter->pdev, busaddr,
-				       wrb->frag_len, PCI_DMA_TODEVICE);
-		}
+		unmap_tx_frag(adapter->pdev, wrb, (unmap_skb_hdr &&
+					sent_skb->len > sent_skb->data_len));
+		unmap_skb_hdr = false;
+
 		num_wrbs++;
 		queue_tail_inc(txq);
-	}
+	} while (cur_index != last_index);
 
 	atomic_sub(num_wrbs, &txq->used);
 
-- 
1.6.3.3

