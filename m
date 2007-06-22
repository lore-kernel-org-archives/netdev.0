From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 8/9] pasemi_mac: Reduce locking when cleaning TX ring
Date: Fri, 22 Jun 2007 15:05:48 -0500
Message-ID: <20070622200548.GI11723@lixom.net>
References: <20070622194720.614405000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59223 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbXFVUHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 16:07:18 -0400
Content-Disposition: inline; filename=pasemi_mac-tx-lock-reduction
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Postpone pci unmap and skb free of the transmitted buffers to outside
of the tx ring lock, batching them up 32 at a time.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -562,37 +562,56 @@ static int pasemi_mac_clean_tx(struct pa
 	int i;
 	struct pasemi_mac_buffer *info;
 	struct pas_dma_xct_descr *dp;
-	int start, count;
+	unsigned int start, count, limit;
+	unsigned int total_count;
 	int flags;
+	struct sk_buff *skbs[32];
+	dma_addr_t dmas[32];
 
+	total_count = 0;
+restart:
 	spin_lock_irqsave(&mac->tx->lock, flags);
 
 	start = mac->tx->next_to_clean;
+	limit = min(mac->tx->next_to_use, start+32);
+
 	count = 0;
 
-	for (i = start; i < mac->tx->next_to_use; i++) {
+	for (i = start; i < limit; i++) {
 		dp = &TX_DESC(mac, i);
+
 		if (unlikely(dp->mactx & XCT_MACTX_O))
+			/* Not yet transmitted */
 			break;
 
-		count++;
-
 		info = &TX_DESC_INFO(mac, i);
-
-		pci_unmap_single(mac->dma_pdev, info->dma,
-				 info->skb->len, PCI_DMA_TODEVICE);
-		dev_kfree_skb_irq(info->skb);
+		skbs[count] = info->skb;
+		dmas[count] = info->dma;
 
 		info->skb = NULL;
 		info->dma = 0;
 		dp->mactx = 0;
 		dp->ptr = 0;
+
+		count++;
 	}
 	mac->tx->next_to_clean += count;
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 	netif_wake_queue(mac->netdev);
 
-	return count;
+	for (i = 0; i < count; i++) {
+		pci_unmap_single(mac->dma_pdev, dmas[i],
+				 skbs[i]->len, PCI_DMA_TODEVICE);
+		dev_kfree_skb_irq(skbs[i]);
+	}
+
+	total_count += count;
+
+	/* If the batch was full, try to clean more */
+	if (count == 32)
+		goto restart;
+
+	return total_count;
 }
 
 

--
