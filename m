From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [6/11] pasemi_mac: add local skb alignment
Date: Tue, 2 Oct 2007 16:26:53 -0500
Message-ID: <20071002212653.GG2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46695 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755833AbXJBVWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:22:50 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: add local skb alignment

Add local SKB alignment to pasemi_mac, since ppc64 in general has it at 0
because of design flaws in some of the IBM server bridge chips. However,
for PWRficient doing the unaligned copies is more expensive than doing
unaligned DMA so make sure the data is aligned instead.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -37,6 +37,12 @@
 
 #include "pasemi_mac.h"
 
+/* We have our own align, since ppc64 in general has it at 0 because
+ * of design flaws in some of the server bridge chips. However, for
+ * PWRficient doing the unaligned copies is more expensive than doing
+ * unaligned DMA, so make sure the data is aligned instead.
+ */
+#define LOCAL_SKB_ALIGN	2
 
 /* TODO list
  *
@@ -409,13 +415,16 @@ static void pasemi_mac_replenish_rx_ring
 		/* skb might still be in there for recycle on short receives */
 		if (info->skb)
 			skb = info->skb;
-		else
+		else {
 			skb = dev_alloc_skb(BUF_SIZE);
+			skb_reserve(skb, LOCAL_SKB_ALIGN);
+		}
 
 		if (unlikely(!skb))
 			break;
 
-		dma = pci_map_single(mac->dma_pdev, skb->data, BUF_SIZE,
+		dma = pci_map_single(mac->dma_pdev, skb->data,
+				     BUF_SIZE - LOCAL_SKB_ALIGN,
 				     PCI_DMA_FROMDEVICE);
 
 		if (unlikely(dma_mapping_error(dma))) {
@@ -553,10 +562,12 @@ static int pasemi_mac_clean_rx(struct pa
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
 		if (len < 256) {
-			struct sk_buff *new_skb =
-			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
+			struct sk_buff *new_skb;
+
+			new_skb = netdev_alloc_skb(mac->netdev,
+						   len + LOCAL_SKB_ALIGN);
 			if (new_skb) {
-				skb_reserve(new_skb, NET_IP_ALIGN);
+				skb_reserve(new_skb, LOCAL_SKB_ALIGN);
 				memcpy(new_skb->data, skb->data, len);
 				/* save the skb in buffer_info as good */
 				skb = new_skb;
