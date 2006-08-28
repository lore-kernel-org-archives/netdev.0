From: shemminger@osdl.org
Subject: [PATCH 2/9] sky2: use netdev_alloc_skb
Date: Mon, 28 Aug 2006 10:00:46 -0700
Message-ID: <20060828170215.605591121@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17026 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750906AbWH1SQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:16:07 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use netdev_alloc_skb for buffer allocation to allow for headroom.
This prevents bugs in code paths that assume extra space at the
front and makes sky2 behave like other drivers.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-08-25 16:01:33.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-25 16:02:27.000000000 -0700
@@ -954,14 +954,16 @@
 /*
  * It appears the hardware has a bug in the FIFO logic that
  * cause it to hang if the FIFO gets overrun and the receive buffer
- * is not aligned. ALso alloc_skb() won't align properly if slab
- * debugging is enabled.
+ * is not 64 byte aligned. The buffer returned from netdev_alloc_skb is
+ * aligned except if slab debugging is enabled.
  */
-static inline struct sk_buff *sky2_alloc_skb(unsigned int size, gfp_t gfp_mask)
+static inline struct sk_buff *sky2_alloc_skb(struct net_device *dev,
+					     unsigned int length,
+					     gfp_t gfp_mask)
 {
 	struct sk_buff *skb;
 
-	skb = alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
+	skb = __netdev_alloc_skb(dev, length + RX_SKB_ALIGN, gfp_mask);
 	if (likely(skb)) {
 		unsigned long p	= (unsigned long) skb->data;
 		skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
@@ -997,7 +999,8 @@
 	for (i = 0; i < sky2->rx_pending; i++) {
 		struct ring_info *re = sky2->rx_ring + i;
 
-		re->skb = sky2_alloc_skb(sky2->rx_bufsize, GFP_KERNEL);
+		re->skb = sky2_alloc_skb(sky2->netdev, sky2->rx_bufsize,
+					 GFP_KERNEL);
 		if (!re->skb)
 			goto nomem;
 
@@ -1829,15 +1832,16 @@
  * For small packets or errors, just reuse existing skb.
  * For larger packets, get new buffer.
  */
-static struct sk_buff *sky2_receive(struct sky2_port *sky2,
+static struct sk_buff *sky2_receive(struct net_device *dev,
 				    u16 length, u32 status)
 {
+ 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct ring_info *re = sky2->rx_ring + sky2->rx_next;
 	struct sk_buff *skb = NULL;
 
 	if (unlikely(netif_msg_rx_status(sky2)))
 		printk(KERN_DEBUG PFX "%s: rx slot %u status 0x%x len %d\n",
-		       sky2->netdev->name, sky2->rx_next, status, length);
+		       dev->name, sky2->rx_next, status, length);
 
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
@@ -1848,11 +1852,11 @@
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
-	if (length > sky2->netdev->mtu + ETH_HLEN)
+	if (length > dev->mtu + ETH_HLEN)
 		goto oversize;
 
 	if (length < copybreak) {
-		skb = alloc_skb(length + 2, GFP_ATOMIC);
+		skb = netdev_alloc_skb(dev, length + 2);
 		if (!skb)
 			goto resubmit;
 
@@ -1867,7 +1871,7 @@
 	} else {
 		struct sk_buff *nskb;
 
-		nskb = sky2_alloc_skb(sky2->rx_bufsize, GFP_ATOMIC);
+		nskb = sky2_alloc_skb(dev, sky2->rx_bufsize, GFP_ATOMIC);
 		if (!nskb)
 			goto resubmit;
 
@@ -1897,7 +1901,7 @@
 
 	if (netif_msg_rx_err(sky2) && net_ratelimit())
 		printk(KERN_INFO PFX "%s: rx error, status 0x%x length %d\n",
-		       sky2->netdev->name, status, length);
+		       dev->name, status, length);
 
 	if (status & (GMR_FS_LONG_ERR | GMR_FS_UN_SIZE))
 		sky2->net_stats.rx_length_errors++;
@@ -1951,11 +1955,10 @@
 
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
-			skb = sky2_receive(sky2, length, status);
+			skb = sky2_receive(dev, length, status);
 			if (!skb)
 				break;
 
-			skb->dev = dev;
 			skb->protocol = eth_type_trans(skb, dev);
 			dev->last_rx = jiffies;
 

--
Stephen Hemminger <shemminger@osdl.org>


