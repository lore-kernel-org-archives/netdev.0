From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 2/8] r8169: init rx ring cleanup
Date: Thu, 21 Oct 2010 10:25:37 +0200
Message-ID: <1287649543-6569-3-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152Ab0JUIXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:23 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   52 +++++++++++++++++++++-----------------------------
 1 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 01d96a7..5a87036 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3974,12 +3974,12 @@ static inline void *rtl8169_align(void *data)
 	return (void *)ALIGN((long)data, 16);
 }
 
-static struct sk_buff *rtl8169_alloc_rx_data(struct pci_dev *pdev,
-					    struct net_device *dev,
-					    struct RxDesc *desc)
+static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
+					     struct RxDesc *desc)
 {
 	void *data;
 	dma_addr_t mapping;
+	struct net_device *dev = tp->dev;
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 
 	data = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
@@ -3993,9 +3993,9 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct pci_dev *pdev,
 			return NULL;
 	}
 
-	mapping = dma_map_single(&pdev->dev, rtl8169_align(data), rx_buf_sz,
+	mapping = dma_map_single(&tp->pci_dev->dev, rtl8169_align(data), rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
-	if (unlikely(dma_mapping_error(&pdev->dev, mapping)))
+	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
 		goto err_out;
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
@@ -4018,34 +4018,35 @@ static void rtl8169_rx_clear(struct rtl8169_private *tp)
 	}
 }
 
-static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
-			   u32 start, u32 end, gfp_t gfp)
+static inline void rtl8169_mark_as_last_descriptor(struct RxDesc *desc)
 {
-	u32 cur;
+	desc->opts1 |= cpu_to_le32(RingEnd);
+}
 
-	for (cur = start; end - cur != 0; cur++) {
-		void *data;
-		unsigned int i = cur % NUM_RX_DESC;
+static int rtl8169_rx_fill(struct rtl8169_private *tp)
+{
+	unsigned int i;
 
-		WARN_ON((s32)(end - cur) < 0);
+	for (i = 0; i < NUM_RX_DESC; i++) {
+		void *data;
 
 		if (tp->Rx_databuff[i])
 			continue;
 
-		data = rtl8169_alloc_rx_data(tp->pci_dev, dev,
-					     tp->RxDescArray + i);
+		data = rtl8169_alloc_rx_data(tp, tp->RxDescArray + i);
 		if (!data) {
 			rtl8169_make_unusable_by_asic(tp->RxDescArray + i);
-			break;
+			goto err_out;
 		}
 		tp->Rx_databuff[i] = data;
 	}
-	return cur - start;
-}
 
-static inline void rtl8169_mark_as_last_descriptor(struct RxDesc *desc)
-{
-	desc->opts1 |= cpu_to_le32(RingEnd);
+	rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
+	return 0;
+
+err_out:
+	rtl8169_rx_clear(tp);
+	return -ENOMEM;
 }
 
 static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
@@ -4062,16 +4063,7 @@ static int rtl8169_init_ring(struct net_device *dev)
 	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
 	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
 
-	if (rtl8169_rx_fill(tp, dev, 0, NUM_RX_DESC, GFP_KERNEL) != NUM_RX_DESC)
-		goto err_out;
-
-	rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
-
-	return 0;
-
-err_out:
-	rtl8169_rx_clear(tp);
-	return -ENOMEM;
+	return rtl8169_rx_fill(tp);
 }
 
 static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
-- 
1.6.5.2

