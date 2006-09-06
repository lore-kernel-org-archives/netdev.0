From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/6] sky2: use dev_alloc_skb for receive buffers
Date: Wed, 06 Sep 2006 10:17:55 -0700
Message-ID: <20060906171921.238190000@localhost.localdomain>
References: <20060906171752.781595000@localhost.localdomain>
Cc: stable@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40103 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751470AbWIFSLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 14:11:25 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-dev-alloc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several code paths assume an additional 16 bytes of header padding
on the receive path. Use dev_alloc_skb to get that padding.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.17.11.orig/drivers/net/sky2.c
+++ linux-2.6.17.11/drivers/net/sky2.c
@@ -949,14 +949,14 @@ static void sky2_vlan_rx_kill_vid(struct
 /*
  * It appears the hardware has a bug in the FIFO logic that
  * cause it to hang if the FIFO gets overrun and the receive buffer
- * is not aligned. ALso alloc_skb() won't align properly if slab
+ * is not aligned. Also dev_alloc_skb() won't align properly if slab
  * debugging is enabled.
  */
 static inline struct sk_buff *sky2_alloc_skb(unsigned int size, gfp_t gfp_mask)
 {
 	struct sk_buff *skb;
 
-	skb = alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
+	skb = __dev_alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
 	if (likely(skb)) {
 		unsigned long p	= (unsigned long) skb->data;
 		skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
@@ -1855,7 +1855,7 @@ static struct sk_buff *sky2_receive(stru
 		goto oversize;
 
 	if (length < copybreak) {
-		skb = alloc_skb(length + 2, GFP_ATOMIC);
+		skb = dev_alloc_skb(length + 2);
 		if (!skb)
 			goto resubmit;
 

--
Stephen Hemminger <shemminger@osdl.org>

