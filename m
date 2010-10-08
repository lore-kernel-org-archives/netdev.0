From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC PATCH 2/2] r8169: reduce number of functions arguments
Date: Fri,  8 Oct 2010 16:30:03 +0200
Message-ID: <1286548203-10831-2-git-send-email-sgruszka@redhat.com>
References: <1286548203-10831-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757342Ab0JHO2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 10:28:09 -0400
In-Reply-To: <1286548203-10831-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need to pass arguments on stack since we have them in per
device private structure. Patch was not tested.
---
 drivers/net/r8169.c |   30 ++++++++++++------------------
 1 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b3b28b1..65d4219 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4005,29 +4005,26 @@ static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 	rtl8169_mark_to_asic(desc, rx_buf_sz);
 }
 
-static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
-					    struct net_device *dev,
-					    struct RxDesc *desc, int rx_buf_sz,
-					    unsigned int align, gfp_t gfp)
+static struct sk_buff *rtl8169_alloc_rx_skb(struct rtl8169_private *tp,
+					    struct RxDesc *desc, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
-	unsigned int pad;
+	unsigned int align = tp->align;
+	unsigned int pad = align ? align : NET_IP_ALIGN;
 
-	pad = align ? align : NET_IP_ALIGN;
-
-	skb = __netdev_alloc_skb(dev, rx_buf_sz + pad, gfp);
+	skb = __netdev_alloc_skb(tp->dev, tp->rx_buf_sz + pad, gfp);
 	if (!skb)
 		goto err0;
 
 	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
-	mapping = dma_map_single(&pdev->dev, skb->data, rx_buf_sz,
+	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, tp->rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
-	if (dma_mapping_error(&pdev->dev, mapping))
+	if (dma_mapping_error(&tp->pci_dev->dev, mapping))
 		goto err1;
 
-	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
+	rtl8169_map_to_asic(desc, mapping, tp->rx_buf_sz);
 
 	return skb;
 
@@ -4050,8 +4047,7 @@ static void rtl8169_rx_clear(struct rtl8169_private *tp)
 	}
 }
 
-static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
-			   u32 start, u32 end, gfp_t gfp)
+static u32 rtl8169_rx_fill(struct rtl8169_private *tp, u32 start, u32 end, gfp_t gfp)
 {
 	u32 cur;
 
@@ -4064,9 +4060,7 @@ static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
 		if (tp->Rx_skbuff[i])
 			continue;
 
-		skb = rtl8169_alloc_rx_skb(tp->pci_dev, dev,
-					   tp->RxDescArray + i,
-					   tp->rx_buf_sz, tp->align, gfp);
+		skb = rtl8169_alloc_rx_skb(tp, tp->RxDescArray + i, gfp);
 		if (!skb)
 			break;
 
@@ -4094,7 +4088,7 @@ static int rtl8169_init_ring(struct net_device *dev)
 	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
 	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));
 
-	if (rtl8169_rx_fill(tp, dev, 0, NUM_RX_DESC, GFP_KERNEL) != NUM_RX_DESC)
+	if (rtl8169_rx_fill(tp, 0, NUM_RX_DESC, GFP_KERNEL) != NUM_RX_DESC)
 		goto err_out;
 
 	rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
@@ -4612,7 +4606,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 	count = cur_rx - tp->cur_rx;
 	tp->cur_rx = cur_rx;
 
-	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx, GFP_ATOMIC);
+	delta = rtl8169_rx_fill(tp, tp->dirty_rx, tp->cur_rx, GFP_ATOMIC);
 	if (!delta && count)
 		netif_info(tp, intr, dev, "no Rx buffer allocated\n");
 	tp->dirty_rx += delta;
-- 
1.7.1

