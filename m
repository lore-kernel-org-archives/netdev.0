From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 26/75] enic: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:58 +0100
Message-ID: <1313760467-8598-26-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Wang <dwang2@cisco.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Vasanthy Kolluri <vkolluri@cisco.com>
Cc: Roopa Prabhu <roprabhu@cisco.com>
Cc: David Wang <dwang2@cisco.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/enic/enic_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 67a27cd..fc470fa 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -590,9 +590,9 @@ static inline void enic_queue_wq_skb_cont(struct enic *enic,
 	for (frag = skb_shinfo(skb)->frags; len_left; frag++) {
 		len_left -= frag->size;
 		enic_queue_wq_desc_cont(wq, skb,
-			pci_map_page(enic->pdev, frag->page,
-				frag->page_offset, frag->size,
-				PCI_DMA_TODEVICE),
+			skb_frag_dma_map(&enic->pdev->dev,
+					 frag, 0, frag->size,
+					 PCI_DMA_TODEVICE),
 			frag->size,
 			(len_left == 0),	/* EOP? */
 			loopback);
@@ -704,14 +704,14 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 	for (frag = skb_shinfo(skb)->frags; len_left; frag++) {
 		len_left -= frag->size;
 		frag_len_left = frag->size;
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (frag_len_left) {
 			len = min(frag_len_left,
 				(unsigned int)WQ_ENET_MAX_DESC_LEN);
-			dma_addr = pci_map_page(enic->pdev, frag->page,
-				offset, len,
-				PCI_DMA_TODEVICE);
+			dma_addr = skb_frag_dma_map(&enic->pdev->dev, frag,
+						    offset, len,
+						    PCI_DMA_TODEVICE);
 			enic_queue_wq_desc_cont(wq, skb,
 				dma_addr,
 				len,
-- 
1.7.2.5
