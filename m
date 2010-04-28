From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] sky2: use the DMA state API instead of the pci equivalents
Date: Wed, 28 Apr 2010 09:57:05 +0900
Message-ID: <20100428095826S.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:57308 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562Ab0D1A5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 20:57:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replace the PCI DMA state API (include/linux/pci-dma.h) with the
DMA equivalents since the PCI DMA state API will be obsolete.

No functional change.

For further information about the background:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/sky2.c |   22 +++++++++++-----------
 drivers/net/sky2.h |    6 +++---
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a1b17fa..bf9c05b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1129,7 +1129,7 @@ static int sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
 	if (pci_dma_mapping_error(pdev, re->data_addr))
 		goto mapping_error;
 
-	pci_unmap_len_set(re, data_size, size);
+	dma_unmap_len_set(re, data_size, size);
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -1151,7 +1151,7 @@ map_page_error:
 			       PCI_DMA_FROMDEVICE);
 	}
 
-	pci_unmap_single(pdev, re->data_addr, pci_unmap_len(re, data_size),
+	pci_unmap_single(pdev, re->data_addr, dma_unmap_len(re, data_size),
 			 PCI_DMA_FROMDEVICE);
 
 mapping_error:
@@ -1166,7 +1166,7 @@ static void sky2_rx_unmap_skb(struct pci_dev *pdev, struct rx_ring_info *re)
 	struct sk_buff *skb = re->skb;
 	int i;
 
-	pci_unmap_single(pdev, re->data_addr, pci_unmap_len(re, data_size),
+	pci_unmap_single(pdev, re->data_addr, dma_unmap_len(re, data_size),
 			 PCI_DMA_FROMDEVICE);
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
@@ -1695,12 +1695,12 @@ static unsigned tx_le_req(const struct sk_buff *skb)
 static void sky2_tx_unmap(struct pci_dev *pdev, struct tx_ring_info *re)
 {
 	if (re->flags & TX_MAP_SINGLE)
-		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
-				 pci_unmap_len(re, maplen),
+		pci_unmap_single(pdev, dma_unmap_addr(re, mapaddr),
+				 dma_unmap_len(re, maplen),
 				 PCI_DMA_TODEVICE);
 	else if (re->flags & TX_MAP_PAGE)
-		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
-			       pci_unmap_len(re, maplen),
+		pci_unmap_page(pdev, dma_unmap_addr(re, mapaddr),
+			       dma_unmap_len(re, maplen),
 			       PCI_DMA_TODEVICE);
 	re->flags = 0;
 }
@@ -1811,8 +1811,8 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 
 	re = sky2->tx_ring + slot;
 	re->flags = TX_MAP_SINGLE;
-	pci_unmap_addr_set(re, mapaddr, mapping);
-	pci_unmap_len_set(re, maplen, len);
+	dma_unmap_addr_set(re, mapaddr, mapping);
+	dma_unmap_len_set(re, maplen, len);
 
 	le = get_tx_le(sky2, &slot);
 	le->addr = cpu_to_le32(lower_32_bits(mapping));
@@ -1840,8 +1840,8 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 
 		re = sky2->tx_ring + slot;
 		re->flags = TX_MAP_PAGE;
-		pci_unmap_addr_set(re, mapaddr, mapping);
-		pci_unmap_len_set(re, maplen, frag->size);
+		dma_unmap_addr_set(re, mapaddr, mapping);
+		dma_unmap_len_set(re, maplen, frag->size);
 
 		le = get_tx_le(sky2, &slot);
 		le->addr = cpu_to_le32(lower_32_bits(mapping));
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 545a3f4..084eff2 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2182,14 +2182,14 @@ struct tx_ring_info {
 	unsigned long flags;
 #define TX_MAP_SINGLE   0x0001
 #define TX_MAP_PAGE     0x0002
-	DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	DECLARE_PCI_UNMAP_LEN(maplen);
+	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+	DEFINE_DMA_UNMAP_LEN(maplen);
 };
 
 struct rx_ring_info {
 	struct sk_buff	*skb;
 	dma_addr_t	data_addr;
-	DECLARE_PCI_UNMAP_LEN(data_size);
+	DEFINE_DMA_UNMAP_LEN(data_size);
 	dma_addr_t	frag_addr[ETH_JUMBO_MTU >> PAGE_SHIFT];
 };
 
-- 
1.6.5

