From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [6/6] pasemi_mac: pass in count of buffers to replenish rx
	ring with
Date: Wed, 26 Sep 2007 16:25:06 -0500
Message-ID: <20070926212506.GG24168@lixom.net>
References: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49491 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbXIZVV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 17:21:57 -0400
Content-Disposition: inline
In-Reply-To: <20070926212200.GA24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: pass in count of buffers to replenish rx ring with

Refactor replenish_rx_ring to take an argument for how many entries to
fill. Since it's normally available from where it's called anyway, this
is just simpler. It also removes the awkward logic to try to figure out
if we're filling for the first time or not.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -375,23 +375,18 @@ static void pasemi_mac_free_rx_resources
 	mac->rx = NULL;
 }
 
-static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
+static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	int start = mac->rx->next_to_fill;
-	unsigned int limit, count;
-
-	limit = RING_AVAIL(mac->rx);
-	/* Check to see if we're doing first-time setup */
-	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0))
-		limit = RX_RING_SIZE;
+	int count;
 
 	if (limit <= 0)
 		return;
 
 	i = start;
-	for (count = limit; count; count--) {
+	for (count = 0; count < limit; count++) {
 		struct pasemi_mac_buffer *info = &RX_DESC_INFO(mac, i);
 		u64 *buff = &RX_BUFF(mac, i);
 		struct sk_buff *skb;
@@ -422,10 +417,10 @@ static void pasemi_mac_replenish_rx_ring
 
 	wmb();
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), limit - count);
-	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), limit - count);
+	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), count);
+	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), count);
 
-	mac->rx->next_to_fill += limit - count;
+	mac->rx->next_to_fill += count;
 }
 
 static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
@@ -543,7 +538,7 @@ static int pasemi_mac_clean_rx(struct pa
 	}
 
 	mac->rx->next_to_clean += limit - count;
-	pasemi_mac_replenish_rx_ring(mac->netdev);
+	pasemi_mac_replenish_rx_ring(mac->netdev, limit-count);
 
 	spin_unlock(&mac->rx->lock);
 
@@ -830,7 +825,7 @@ static int pasemi_mac_open(struct net_de
 	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
 			   PAS_DMA_TXCHAN_TCMDSTA_EN);
 
-	pasemi_mac_replenish_rx_ring(dev);
+	pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE);
 
 	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
 		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
