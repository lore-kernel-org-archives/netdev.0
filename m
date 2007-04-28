From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [5/10] pasemi_mac: Add SKB reuse / copy-break
Date: Sat, 28 Apr 2007 15:37:28 -0500
Message-ID: <20070428203728.GF4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:50926 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960AbXD1Ugv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:36:51 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a copy-break and recycle the SKB in the driver for small packets.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -279,8 +279,8 @@ static void pasemi_mac_free_rx_resources
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		info = &RX_DESC_INFO(mac, i);
 		dp = &RX_DESC(mac, i);
-		if (info->dma) {
-			if (info->skb) {
+		if (info->skb) {
+			if (info->dma) {
 				pci_unmap_single(mac->dma_pdev,
 						 info->dma,
 						 info->skb->len,
@@ -329,12 +329,14 @@ static void pasemi_mac_replenish_rx_ring
 		struct sk_buff *skb;
 		dma_addr_t dma;
 
-		skb = dev_alloc_skb(BUF_SIZE);
+		/* skb might still be in there for recycle on short receives */
+		if (info->skb)
+			skb = info->skb;
+		else
+			skb = dev_alloc_skb(BUF_SIZE);
 
-		if (!skb) {
-			count = i - start;
+		if (unlikely(!skb))
 			break;
-		}
 
 		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
 				     PCI_DMA_FROMDEVICE);
@@ -442,13 +444,28 @@ static int pasemi_mac_clean_rx(struct pa
 
 		BUG_ON(!info);
 		BUG_ON(info->dma != dma);
+		skb = info->skb;
 
 		pci_unmap_single(mac->dma_pdev, info->dma, info->skb->len,
 				 PCI_DMA_FROMDEVICE);
+		info->dma = 0;
 
-		skb = info->skb;
 
 		len = (dp->macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
+		if (len < 256) {
+			struct sk_buff *new_skb =
+			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
+			if (new_skb) {
+				skb_reserve(new_skb, NET_IP_ALIGN);
+				memcpy(new_skb->data - NET_IP_ALIGN,
+					skb->data - NET_IP_ALIGN,
+					len + NET_IP_ALIGN);
+				/* save the skb in buffer_info as good */
+				skb = new_skb;
+			}
+			/* else just continue with the old one */
+		} else
+			info->skb = NULL;
 
 		skb_put(skb, len);
 
