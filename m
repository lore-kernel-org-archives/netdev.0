From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 49/75] sky2: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:21 +0100
Message-ID: <1313760467-8598-49-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/sky2.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 57339da..2951762 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1226,10 +1226,9 @@ static int sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		re->frag_addr[i] = pci_map_page(pdev, frag->page,
-						frag->page_offset,
-						frag->size,
-						PCI_DMA_FROMDEVICE);
+		re->frag_addr[i] = skb_frag_dma_map(&pdev->dev, frag, 0,
+						    frag->size,
+						    PCI_DMA_FROMDEVICE);
 
 		if (pci_dma_mapping_error(pdev, re->frag_addr[i]))
 			goto map_page_error;
@@ -1910,8 +1909,8 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+		mapping = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
+					   frag->size, PCI_DMA_TODEVICE);
 
 		if (pci_dma_mapping_error(hw->pdev, mapping))
 			goto mapping_unwind;
@@ -2449,7 +2448,7 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 
 		if (length == 0) {
 			/* don't need this page */
-			__free_page(frag->page);
+			__skb_frag_unref(frag);
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
-- 
1.7.2.5
