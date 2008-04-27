From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/6] sis190: use netdev_alloc_skb
Date: Sun, 27 Apr 2008 19:03:25 +0200
Message-ID: <20080427170325.GD26953@electric-eye.fr.zoreil.com>
References: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60980 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756088AbYD0RWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 13:22:38 -0400
Content-Disposition: inline
In-Reply-To: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sets skb->dev and allows arch specific allocation.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 248c385..97aa18d 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -480,16 +480,17 @@ static inline void sis190_make_unusable_by_asic(struct RxDesc *desc)
 	desc->status = 0x0;
 }
 
-static struct sk_buff *sis190_alloc_rx_skb(struct pci_dev *pdev,
-					   struct RxDesc *desc, u32 rx_buf_sz)
+static struct sk_buff *sis190_alloc_rx_skb(struct sis190_private *tp,
+					   struct RxDesc *desc)
 {
+	u32 rx_buf_sz = tp->rx_buf_sz;
 	struct sk_buff *skb;
 
-	skb = dev_alloc_skb(rx_buf_sz);
+	skb = netdev_alloc_skb(tp->dev, rx_buf_sz);
 	if (likely(skb)) {
 		dma_addr_t mapping;
 
-		mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
+		mapping = pci_map_single(tp->pci_dev, skb->data, tp->rx_buf_sz,
 					 PCI_DMA_FROMDEVICE);
 		sis190_map_to_asic(desc, mapping, rx_buf_sz);
 	} else
@@ -509,29 +510,29 @@ static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
 		if (tp->Rx_skbuff[i])
 			continue;
 
-		tp->Rx_skbuff[i] = sis190_alloc_rx_skb(tp->pci_dev,
-						       tp->RxDescRing + i,
-						       tp->rx_buf_sz);
+		tp->Rx_skbuff[i] = sis190_alloc_rx_skb(tp, tp->RxDescRing + i);
+
 		if (!tp->Rx_skbuff[i])
 			break;
 	}
 	return cur - start;
 }
 
-static inline int sis190_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-				     struct RxDesc *desc, int rx_buf_sz)
+static int sis190_try_rx_copy(struct sis190_private *tp,
+			      struct sk_buff **sk_buff, int pkt_size,
+			      struct RxDesc *desc)
 {
 	int ret = -1;
 
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_size + 2);
+		skb = netdev_alloc_skb(tp->dev, pkt_size + 2);
 		if (skb) {
 			skb_reserve(skb, 2);
 			skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
 			*sk_buff = skb;
-			sis190_give_to_asic(desc, rx_buf_sz);
+			sis190_give_to_asic(desc, tp->rx_buf_sz);
 			ret = 0;
 		}
 	}
@@ -603,8 +604,7 @@ static int sis190_rx_interrupt(struct net_device *dev,
 				le32_to_cpu(desc->addr), tp->rx_buf_sz,
 				PCI_DMA_FROMDEVICE);
 
-			if (sis190_try_rx_copy(&skb, pkt_size, desc,
-					       tp->rx_buf_sz)) {
+			if (sis190_try_rx_copy(tp, &skb, pkt_size, desc)) {
 				pci_action = pci_unmap_single;
 				tp->Rx_skbuff[entry] = NULL;
 				sis190_make_unusable_by_asic(desc);
-- 
1.5.3.3

