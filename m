From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] move skb->dev assignment into netdev_alloc_skb
Date: Sat, 5 Aug 2006 15:01:09 +0200
Message-ID: <20060805130109.GB24121@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:43397 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1161430AbWHENBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 09:01:14 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All caller of netdev_alloc_skb need to assign skb->dev shortly
afterwards.  Move it into common code.

I also had to fixup a little bit of the surrounding control flow in
e1000 - it was just too convoluted.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c	2006-08-04 19:06:09.000000000 +0200
+++ linux-2.6/drivers/net/e1000/e1000_main.c	2006-08-05 14:18:32.000000000 +0200
@@ -3711,7 +3711,6 @@
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				new_skb->dev = netdev;
 				memcpy(new_skb->data - NET_IP_ALIGN,
 				       skb->data - NET_IP_ALIGN,
 				       length + NET_IP_ALIGN);
@@ -3978,13 +3977,13 @@
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (cleaned_count--) {
-		if (!(skb = buffer_info->skb))
-			skb = netdev_alloc_skb(netdev, bufsz);
-		else {
+		skb = buffer_info->skb;
+		if (skb) {
 			skb_trim(skb, 0);
 			goto map_skb;
 		}
 
+		skb = netdev_alloc_skb(netdev, bufsz);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			adapter->alloc_rx_buff_failed++;
@@ -4009,10 +4008,10 @@
 				dev_kfree_skb(skb);
 				dev_kfree_skb(oldskb);
 				break; /* while !buffer_info->skb */
-			} else {
-				/* Use new allocation */
-				dev_kfree_skb(oldskb);
 			}
+
+			/* Use new allocation */
+			dev_kfree_skb(oldskb);
 		}
 		/* Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
@@ -4020,8 +4019,6 @@
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 map_skb:
@@ -4135,8 +4132,6 @@
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_ps_bsize0;
 		buffer_info->dma = pci_map_single(pdev, skb->data,
Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c	2006-08-04 19:06:11.000000000 +0200
+++ linux-2.6/drivers/net/tg3.c	2006-08-05 14:18:18.000000000 +0200
@@ -3101,7 +3101,6 @@
 	if (skb == NULL)
 		return -ENOMEM;
 
-	skb->dev = tp->dev;
 	skb_reserve(skb, tp->rx_offset);
 
 	mapping = pci_map_single(tp->pdev, skb->data,
@@ -3274,7 +3273,6 @@
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-			copy_skb->dev = tp->dev;
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2006-08-04 19:06:37.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2006-08-05 14:48:01.000000000 +0200
@@ -268,8 +268,10 @@
 	struct sk_buff *skb;
 
 	skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
-	if (likely(skb))
+	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
+		skb->dev = dev;
+	}
 	return skb;
 }
 
