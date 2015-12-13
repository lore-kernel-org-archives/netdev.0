From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix descriptor access endianness
Date: Sun, 13 Dec 2015 23:05:07 +0300
Message-ID: <11070795.yxBPvlHg4n@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34030 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbLMUFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 15:05:20 -0500
Received: by lbbcs9 with SMTP id cs9so95325772lbb.1
        for <netdev@vger.kernel.org>; Sun, 13 Dec 2015 12:05:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver never  calls cpu_to_edmac() when writing the descriptor address
and edmac_to_cpu() when reading it, although it should -- fix this.

Note that the frame/buffer length descriptor field accesses also need fixing
but since they are both 16-bit we can't  use {cpu|edmac}_to_{edmac|cpu}()...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo plus the patch I've posted today.

 drivers/net/ethernet/renesas/sh_eth.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1172,7 +1172,7 @@ static void sh_eth_ring_format(struct ne
 			break;
 		}
 		mdp->rx_skbuff[i] = skb;
-		rxdesc->addr = dma_addr;
+		rxdesc->addr = cpu_to_edmac(mdp, dma_addr);
 		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);
 
 		/* Rx descriptor address set */
@@ -1403,7 +1403,8 @@ static int sh_eth_txfree(struct net_devi
 			   entry, edmac_to_cpu(mdp, txdesc->status));
 		/* Free the original skb. */
 		if (mdp->tx_skbuff[entry]) {
-			dma_unmap_single(&ndev->dev, txdesc->addr,
+			dma_unmap_single(&ndev->dev,
+					 edmac_to_cpu(mdp, txdesc->addr),
 					 txdesc->buffer_length, DMA_TO_DEVICE);
 			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
 			mdp->tx_skbuff[entry] = NULL;
@@ -1479,14 +1480,15 @@ static int sh_eth_rx(struct net_device *
 			if (desc_status & RD_RFS10)
 				ndev->stats.rx_over_errors++;
 		} else	if (skb) {
+			dma_addr = edmac_to_cpu(mdp, rxdesc->addr);
 			if (!mdp->cd->hw_swap)
 				sh_eth_soft_swap(
-					phys_to_virt(ALIGN(rxdesc->addr, 4)),
+					phys_to_virt(ALIGN(dma_addr, 4)),
 					pkt_len + 2);
 			mdp->rx_skbuff[entry] = NULL;
 			if (mdp->cd->rpadir)
 				skb_reserve(skb, NET_IP_ALIGN);
-			dma_unmap_single(&ndev->dev, rxdesc->addr,
+			dma_unmap_single(&ndev->dev, dma_addr,
 					 ALIGN(mdp->rx_buf_sz, 32),
 					 DMA_FROM_DEVICE);
 			skb_put(skb, pkt_len);
@@ -1523,7 +1525,7 @@ static int sh_eth_rx(struct net_device *
 			mdp->rx_skbuff[entry] = skb;
 
 			skb_checksum_none_assert(skb);
-			rxdesc->addr = dma_addr;
+			rxdesc->addr = cpu_to_edmac(mdp, dma_addr);
 		}
 		dma_wmb(); /* RACT bit must be set after all the above writes */
 		if (entry >= mdp->num_rx_ring - 1)
@@ -2331,8 +2333,8 @@ static void sh_eth_tx_timeout(struct net
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < mdp->num_rx_ring; i++) {
 		rxdesc = &mdp->rx_ring[i];
-		rxdesc->status = 0;
-		rxdesc->addr = 0xBADF00D0;
+		rxdesc->status = cpu_to_edmac(mdp, 0);
+		rxdesc->addr = cpu_to_edmac(mdp, 0xBADF00D0);
 		dev_kfree_skb(mdp->rx_skbuff[i]);
 		mdp->rx_skbuff[i] = NULL;
 	}
@@ -2350,6 +2352,7 @@ static int sh_eth_start_xmit(struct sk_b
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_txdesc *txdesc;
+	dma_addr_t dma_addr;
 	u32 entry;
 	unsigned long flags;
 
@@ -2373,12 +2376,13 @@ static int sh_eth_start_xmit(struct sk_b
 	/* soft swap. */
 	if (!mdp->cd->hw_swap)
 		sh_eth_soft_swap(PTR_ALIGN(skb->data, 4), skb->len + 2);
-	txdesc->addr = dma_map_single(&ndev->dev, skb->data, skb->len,
-				      DMA_TO_DEVICE);
-	if (dma_mapping_error(&ndev->dev, txdesc->addr)) {
+	dma_addr = dma_map_single(&ndev->dev, skb->data, skb->len,
+				  DMA_TO_DEVICE);
+	if (dma_mapping_error(&ndev->dev, dma_addr)) {
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
+	txdesc->addr = cpu_to_edmac(mdp, dma_addr);
 	txdesc->buffer_length = skb->len;
 
 	dma_wmb(); /* TACT bit must be set after all the above writes */
