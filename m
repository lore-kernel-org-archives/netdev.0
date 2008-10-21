From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: skb recycling
Date: Mon, 20 Oct 2008 19:09:22 -0700
Message-ID: <20081020190922.7dd6510a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56671 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998AbYJUCJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2008 22:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for recycling tx buffers into receive buffers.
This is experimental at this point.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Since the merge window appears to have past, this can wait until 2.6.29

--- a/drivers/net/sky2.c	2008-10-20 16:16:32.000000000 -0700
+++ b/drivers/net/sky2.c	2008-10-20 17:03:29.000000000 -0700
@@ -1165,6 +1165,8 @@ static void sky2_rx_clean(struct sky2_po
 			re->skb = NULL;
 		}
 	}
+
+	skb_queue_purge(&sky2->rx_recycle);
 }
 
 /* Basic MII support */
@@ -1250,26 +1252,24 @@ static struct sk_buff *sky2_rx_alloc(str
 	struct sk_buff *skb;
 	int i;
 
+	skb = __skb_dequeue(&sky2->rx_recycle);
+	if (!skb) {
+		skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size);
+		if (!skb)
+			goto nomem;
+	}
+
 	if (sky2->hw->flags & SKY2_HW_RAM_BUFFER) {
-		unsigned char *start;
 		/*
 		 * Workaround for a bug in FIFO that cause hang
 		 * if the FIFO if the receive buffer is not 64 byte aligned.
 		 * The buffer returned from netdev_alloc_skb is
 		 * aligned except if slab debugging is enabled.
 		 */
-		skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size + 8);
-		if (!skb)
-			goto nomem;
-		start = PTR_ALIGN(skb->data, 8);
+		unsigned char *start = PTR_ALIGN(skb->data, 8);
 		skb_reserve(skb, start - skb->data);
-	} else {
-		skb = netdev_alloc_skb(sky2->netdev,
-				       sky2->rx_data_size + NET_IP_ALIGN);
-		if (!skb)
-			goto nomem;
+	} else
 		skb_reserve(skb, NET_IP_ALIGN);
-	}
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
 		struct page *page = alloc_page(GFP_ATOMIC);
@@ -1344,7 +1344,9 @@ static int sky2_rx_start(struct sky2_por
 	if (size < ETH_HLEN)
 		size = ETH_HLEN;
 
-	sky2->rx_data_size = size;
+	/* Add padding for either IP or DMA alignment */
+	sky2->rx_data_size = size + 8;
+	skb_queue_head_init(&sky2->rx_recycle);
 
 	/* Fill Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
@@ -1684,7 +1686,7 @@ static int sky2_xmit_frame(struct sk_buf
  * NB: the hardware will tell us about partial completion of multi-part
  *     buffers so make sure not to free skb to early.
  */
-static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
+static void sky2_tx_complete(struct sky2_port *sky2, u16 done, int recycle)
 {
 	struct net_device *dev = sky2->netdev;
 	struct pci_dev *pdev = sky2->hw->pdev;
@@ -1713,14 +1715,21 @@ static void sky2_tx_complete(struct sky2
 		}
 
 		if (le->ctrl & EOP) {
+			struct sk_buff *skb = re->skb;
+
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
 
 			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += re->skb->len;
+			dev->stats.tx_bytes += skb->len;
 
-			dev_kfree_skb_any(re->skb);
+			if (recycle
+			    && skb_queue_len(&sky2->rx_recycle) < sky2->rx_pending
+			    && skb_recycle_check(skb, sky2->rx_data_size))
+				__skb_queue_head(&sky2->rx_recycle, skb);
+			else
+				dev_kfree_skb_any(skb);
 			sky2->tx_next = RING_NEXT(idx, TX_RING_SIZE);
 		}
 	}
@@ -1738,7 +1747,7 @@ static void sky2_tx_clean(struct net_dev
 	struct sky2_port *sky2 = netdev_priv(dev);
 
 	netif_tx_lock_bh(dev);
-	sky2_tx_complete(sky2, sky2->tx_prod);
+	sky2_tx_complete(sky2, sky2->tx_prod, 0);
 	netif_tx_unlock_bh(dev);
 }
 
@@ -2291,7 +2300,7 @@ static inline void sky2_tx_done(struct n
 
 	if (netif_running(dev)) {
 		netif_tx_lock(dev);
-		sky2_tx_complete(sky2, last);
+		sky2_tx_complete(sky2, last, 1);
 		netif_tx_unlock(dev);
 	}
 }
--- a/drivers/net/sky2.h	2008-10-20 16:16:32.000000000 -0700
+++ b/drivers/net/sky2.h	2008-10-20 16:29:42.000000000 -0700
@@ -2020,7 +2020,8 @@ struct sky2_port {
 	u16		     tx_last_mss;
 	u32		     tx_tcpsum;
 
-	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;
+	struct sk_buff_head  rx_recycle;
+	struct rx_ring_info  *rx_ring;
 	struct sky2_rx_le    *rx_le;
 
 	u16		     rx_next;		/* next re to check */
