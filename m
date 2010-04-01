From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH 1/2] acenic: fix the misusage of zero dma address
Date: Thu,  1 Apr 2010 17:13:05 +0900
Message-ID: <1270109586-9193-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: netdev@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp
To: linux-acenic@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:48853 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754144Ab0DAIRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 04:17:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

acenic wrongly assumes that zero is an invalid dma address (calls
dma_unmap_page for only non zero dma addresses). Zero is a valid dma
address on some architectures. The dma length can be used here.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/acenic.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 97a3dfd..02a4746 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2078,18 +2078,16 @@ static inline void ace_tx_int(struct net_device *dev,
 
 	do {
 		struct sk_buff *skb;
-		dma_addr_t mapping;
 		struct tx_ring_info *info;
 
 		info = ap->skb->tx_skbuff + idx;
 		skb = info->skb;
-		mapping = pci_unmap_addr(info, mapping);
 
-		if (mapping) {
-			pci_unmap_page(ap->pdev, mapping,
+		if (dma_unmap_len(info, maplen)) {
+			pci_unmap_page(ap->pdev, dma_unmap_addr(info, mapping),
 				       pci_unmap_len(info, maplen),
 				       PCI_DMA_TODEVICE);
-			pci_unmap_addr_set(info, mapping, 0);
+			dma_unmap_len_set(info, maplen, 0);
 		}
 
 		if (skb) {
@@ -2377,14 +2375,12 @@ static int ace_close(struct net_device *dev)
 
 	for (i = 0; i < ACE_TX_RING_ENTRIES(ap); i++) {
 		struct sk_buff *skb;
-		dma_addr_t mapping;
 		struct tx_ring_info *info;
 
 		info = ap->skb->tx_skbuff + i;
 		skb = info->skb;
-		mapping = pci_unmap_addr(info, mapping);
 
-		if (mapping) {
+		if (dma_unmap_len(info, maplen)) {
 			if (ACE_IS_TIGON_I(ap)) {
 				/* NB: TIGON_1 is special, tx_ring is in io space */
 				struct tx_desc __iomem *tx;
@@ -2395,10 +2391,10 @@ static int ace_close(struct net_device *dev)
 			} else
 				memset(ap->tx_ring + i, 0,
 				       sizeof(struct tx_desc));
-			pci_unmap_page(ap->pdev, mapping,
+			pci_unmap_page(ap->pdev, dma_unmap_addr(info, mapping),
 				       pci_unmap_len(info, maplen),
 				       PCI_DMA_TODEVICE);
-			pci_unmap_addr_set(info, mapping, 0);
+			dma_unmap_len_set(info, maplen, 0);
 		}
 		if (skb) {
 			dev_kfree_skb(skb);
-- 
1.7.0

