From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/6] sis190: use the allocated buffer as a status code in
	sis190_alloc_rx_skb
Date: Sun, 27 Apr 2008 19:01:24 +0200
Message-ID: <20080427170124.GB26953@electric-eye.fr.zoreil.com>
References: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52345 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755725AbYD0RUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 13:20:40 -0400
Content-Disposition: inline
In-Reply-To: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The local status code does not carry mory information.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |   37 +++++++++++++++----------------------
 1 files changed, 15 insertions(+), 22 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 20745fd..0d6aa1f 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -480,30 +480,22 @@ static inline void sis190_make_unusable_by_asic(struct RxDesc *desc)
 	desc->status = 0x0;
 }
 
-static int sis190_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
-			       struct RxDesc *desc, u32 rx_buf_sz)
+static struct sk_buff *sis190_alloc_rx_skb(struct pci_dev *pdev,
+					   struct RxDesc *desc, u32 rx_buf_sz)
 {
 	struct sk_buff *skb;
-	dma_addr_t mapping;
-	int ret = 0;
 
 	skb = dev_alloc_skb(rx_buf_sz);
-	if (!skb)
-		goto err_out;
-
-	*sk_buff = skb;
-
-	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
-				 PCI_DMA_FROMDEVICE);
+	if (likely(skb)) {
+		dma_addr_t mapping;
 
-	sis190_map_to_asic(desc, mapping, rx_buf_sz);
-out:
-	return ret;
+		mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
+					 PCI_DMA_FROMDEVICE);
+		sis190_map_to_asic(desc, mapping, rx_buf_sz);
+	} else
+		sis190_make_unusable_by_asic(desc);
 
-err_out:
-	ret = -ENOMEM;
-	sis190_make_unusable_by_asic(desc);
-	goto out;
+	return skb;
 }
 
 static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
@@ -512,14 +504,15 @@ static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
 	u32 cur;
 
 	for (cur = start; cur < end; cur++) {
-		int ret, i = cur % NUM_RX_DESC;
+		unsigned int i = cur % NUM_RX_DESC;
 
 		if (tp->Rx_skbuff[i])
 			continue;
 
-		ret = sis190_alloc_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
-					  tp->RxDescRing + i, tp->rx_buf_sz);
-		if (ret < 0)
+		tp->Rx_skbuff[i] = sis190_alloc_rx_skb(tp->pci_dev,
+						       tp->RxDescRing + i,
+						       tp->rx_buf_sz);
+		if (!tp->Rx_skbuff[i])
 			break;
 	}
 	return cur - start;
-- 
1.5.3.3

