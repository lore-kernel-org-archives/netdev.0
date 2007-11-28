From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] sky2: align IP header on Rx if possible
Date: Wed, 28 Nov 2007 14:27:03 -0800
Message-ID: <20071128142703.7f0b5e5d@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37720 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755143AbXK1Xaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 18:30:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sky2 driver was not aligning the IP header on receive buffers.
This workaround is only needed on hardware with broken FIFO, newer chips
without FIFO can just DMA to unaligned address.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please apply for 2.6.25 this is not urgent.

--- a/drivers/net/sky2.c	2007-11-26 16:30:57.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-26 17:18:27.000000000 -0800
@@ -64,7 +64,6 @@
 #define RX_LE_BYTES		(RX_LE_SIZE*sizeof(struct sky2_rx_le))
 #define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
-#define RX_SKB_ALIGN		8
 
 #define TX_RING_SIZE		512
 #define TX_DEF_PENDING		(TX_RING_SIZE - 1)
@@ -1171,24 +1170,32 @@ static void sky2_vlan_rx_register(struct
 /*
  * Allocate an skb for receiving. If the MTU is large enough
  * make the skb non-linear with a fragment list of pages.
- *
- * It appears the hardware has a bug in the FIFO logic that
- * cause it to hang if the FIFO gets overrun and the receive buffer
- * is not 64 byte aligned. The buffer returned from netdev_alloc_skb is
- * aligned except if slab debugging is enabled.
  */
 static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
 {
 	struct sk_buff *skb;
-	unsigned long p;
 	int i;
 
-	skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size + RX_SKB_ALIGN);
-	if (!skb)
-		goto nomem;
-
-	p = (unsigned long) skb->data;
-	skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
+	if (sky2->hw->flags & SKY2_HW_FIFO_HANG_CHECK) {
+		unsigned char *start;
+		/*
+		 * Workaround for a bug in FIFO that cause hang
+		 * if the FIFO if the receive buffer is not 64 byte aligned.
+		 * The buffer returned from netdev_alloc_skb is
+		 * aligned except if slab debugging is enabled.
+		 */
+		skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size + 8);
+		if (!skb)
+			goto nomem;
+		start = PTR_ALIGN(skb->data, 8);
+		skb_reserve(skb, start - skb->data);
+	} else {
+		skb = netdev_alloc_skb(sky2->netdev,
+				       sky2->rx_data_size + NET_IP_ALIGN);
+		if (!skb)
+			goto nomem;
+		skb_reserve(skb, NET_IP_ALIGN);
+	}
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
 		struct page *page = alloc_page(GFP_ATOMIC);
