From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 7/9] pasemi_mac: Minor performance tweaks
Date: Fri, 22 Jun 2007 15:05:42 -0500
Message-ID: <20070622200542.GH11723@lixom.net>
References: <20070622194720.614405000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59222 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359AbXFVUHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 16:07:18 -0400
Content-Disposition: inline; filename=pasemi_mac-rxperf
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Various minor performance tweaks, do some explicit prefetching of packet
data, etc.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -481,6 +481,7 @@ static int pasemi_mac_clean_rx(struct pa
 		rmb();
 
 		dp = &RX_DESC(mac, n);
+		prefetchw(dp);
 		macrx = dp->macrx;
 
 		if (!(macrx & XCT_MACRX_O))
@@ -502,8 +503,10 @@ static int pasemi_mac_clean_rx(struct pa
 			if (info->dma == dma)
 				break;
 		}
+		prefetchw(info);
 
 		skb = info->skb;
+		prefetchw(skb);
 		info->dma = 0;
 
 		pci_unmap_single(mac->dma_pdev, dma, skb->len,
@@ -526,9 +529,7 @@ static int pasemi_mac_clean_rx(struct pa
 
 		skb_put(skb, len);
 
-		skb->protocol = eth_type_trans(skb, mac->netdev);
-
-		if ((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
+		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
 			skb->ip_summed = CHECKSUM_COMPLETE;
 			skb->csum = (macrx & XCT_MACRX_CSUM_M) >>
 					   XCT_MACRX_CSUM_S;
@@ -538,6 +539,7 @@ static int pasemi_mac_clean_rx(struct pa
 		mac->stats.rx_bytes += len;
 		mac->stats.rx_packets++;
 
+		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
 
 		dp->ptr = 0;
@@ -569,7 +571,7 @@ static int pasemi_mac_clean_tx(struct pa
 
 	for (i = start; i < mac->tx->next_to_use; i++) {
 		dp = &TX_DESC(mac, i);
-		if (!dp || (dp->mactx & XCT_MACTX_O))
+		if (unlikely(dp->mactx & XCT_MACTX_O))
 			break;
 
 		count++;
@@ -957,7 +959,7 @@ static int pasemi_mac_start_tx(struct sk
 	struct pasemi_mac_txring *txring;
 	struct pasemi_mac_buffer *info;
 	struct pas_dma_xct_descr *dp;
-	u64 dflags;
+	u64 dflags, mactx, ptr;
 	dma_addr_t map;
 	int flags;
 
@@ -985,6 +987,9 @@ static int pasemi_mac_start_tx(struct sk
 	if (dma_mapping_error(map))
 		return NETDEV_TX_BUSY;
 
+	mactx = dflags | XCT_MACTX_LLEN(skb->len);
+	ptr   = XCT_PTR_LEN(skb->len) | XCT_PTR_ADDR(map);
+
 	txring = mac->tx;
 
 	spin_lock_irqsave(&txring->lock, flags);
@@ -1005,12 +1010,11 @@ static int pasemi_mac_start_tx(struct sk
 		}
 	}
 
-
 	dp = &TX_DESC(mac, txring->next_to_use);
 	info = &TX_DESC_INFO(mac, txring->next_to_use);
 
-	dp->mactx = dflags | XCT_MACTX_LLEN(skb->len);
-	dp->ptr   = XCT_PTR_LEN(skb->len) | XCT_PTR_ADDR(map);
+	dp->mactx = mactx;
+	dp->ptr = ptr;
 	info->dma = map;
 	info->skb = skb;
 

--
