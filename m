From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/13] myri: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:36 -0700
Message-ID: <20080416233757.623681762@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43782 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552AbYDPXt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:27 -0400
Content-Disposition: inline; filename=myri
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb. This sets skb->dev and allows arch specific
allocation.

Copmpile tested only

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/myri_sbus.c	2008-04-07 10:36:16.000000000 -0700
+++ b/drivers/net/myri_sbus.c	2008-04-07 12:44:15.000000000 -0700
@@ -266,6 +266,22 @@ static void myri_clean_rings(struct myri
 	}
 }
 
+
+/* We use this to acquire receive skb's that we can DMA directly into. */
+#define RX_SKB_PAD(addr) (PTR_ALIGN(addr, 64) - (unsigned long)(addr))
+
+static struct sk_buff *myri_alloc_skb(struct net_device *dev,
+				      unsigned int length, gfp_t gfp_flags)
+{
+	struct sk_buff *skb;
+
+	skb = __netdev_alloc_skb(dev, length + 64, gfp_flags);
+	if (likely(skb)) {
+		skb_reserve(skb, RX_SKB_PAD(skb->data));
+	}
+	return skb;
+}
+
 static void myri_init_rings(struct myri_eth *mp, int from_irq)
 {
 	struct recvq __iomem *rq = mp->rq;
@@ -285,7 +301,6 @@ static void myri_init_rings(struct myri_
 		if (!skb)
 			continue;
 		mp->rx_skbs[i] = skb;
-		skb->dev = dev;
 		skb_put(skb, RX_ALLOC_SIZE);
 
 		dma_addr = sbus_map_single(mp->myri_sdev, skb->data, RX_ALLOC_SIZE, SBUS_DMA_FROMDEVICE);
@@ -469,7 +484,6 @@ static void myri_rx(struct myri_eth *mp,
 					  RX_ALLOC_SIZE,
 					  SBUS_DMA_FROMDEVICE);
 			mp->rx_skbs[index] = new_skb;
-			new_skb->dev = dev;
 			skb_put(new_skb, RX_ALLOC_SIZE);
 			dma_addr = sbus_map_single(mp->myri_sdev,
 						   new_skb->data,
@@ -485,7 +499,7 @@ static void myri_rx(struct myri_eth *mp,
 			DRX(("trim(%d) ", len));
 			skb_trim(skb, len);
 		} else {
-			struct sk_buff *copy_skb = dev_alloc_skb(len);
+			struct sk_buff *copy_skb = netdev_alloc_skb(dev, len + 2);
 
 			DRX(("SMALLBUFF "));
 			if (copy_skb == NULL) {
@@ -493,7 +507,7 @@ static void myri_rx(struct myri_eth *mp,
 				goto drop_it;
 			}
 			/* DMA sync already done above. */
-			copy_skb->dev = dev;
+			skb_reserve(copy_skb, 2);
 			DRX(("resv_and_put "));
 			skb_put(copy_skb, len);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
--- a/drivers/net/myri_sbus.h	2008-04-07 10:36:16.000000000 -0700
+++ b/drivers/net/myri_sbus.h	2008-04-07 12:43:47.000000000 -0700
@@ -291,21 +291,4 @@ struct myri_eth {
 	struct sbus_dev			*myri_sdev;	/* Our SBUS device struct.    */
 };
 
-/* We use this to acquire receive skb's that we can DMA directly into. */
-#define ALIGNED_RX_SKB_ADDR(addr) \
-        ((((unsigned long)(addr) + (64 - 1)) & ~(64 - 1)) - (unsigned long)(addr))
-static inline struct sk_buff *myri_alloc_skb(unsigned int length, gfp_t gfp_flags)
-{
-	struct sk_buff *skb;
-
-	skb = alloc_skb(length + 64, gfp_flags);
-	if(skb) {
-		int offset = ALIGNED_RX_SKB_ADDR(skb->data);
-
-		if(offset)
-			skb_reserve(skb, offset);
-	}
-	return skb;
-}
-
 #endif /* !(_MYRI_SBUS_H) */

-- 

