From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 10/30] net: fec: make rx skb handling more robust
Date: Fri, 27 Jun 2014 16:19:44 +0100
Message-ID: <E1X0XwG-0001NR-EP@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45204 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754030AbaF0PTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:19:46 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate, and then map the receive skb before writing any data to the
ring descriptor or storing the skb.  When freeing the receive ring
entries, unmap and free the skb, and then clear the stored skb pointer.

This means we have ring data and skb pointer in one of two states:
either both fully setup, or nothing setup.

This simplifies the cleanup, as we can use just the skb pointer to
indicate whether the descriptor is setup, and thus avoids potentially
calling dma_unmap_single() on a DMA error value.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 309aa2ff8cc9..70853a59627a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2066,12 +2066,12 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < fep->rx_ring_size; i++) {
 		skb = fep->rx_skbuff[i];
-
-		if (bdp->cbd_bufaddr)
+		fep->rx_skbuff[i] = NULL;
+		if (skb) {
 			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
-		if (skb)
 			dev_kfree_skb(skb);
+		}
 		bdp = fec_enet_get_nextdesc(bdp, fep);
 	}
 
@@ -2089,21 +2089,26 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < fep->rx_ring_size; i++) {
+		dma_addr_t addr;
+
 		skb = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
 		if (!skb) {
 			fec_enet_free_buffers(ndev);
 			return -ENOMEM;
 		}
-		fep->rx_skbuff[i] = skb;
 
-		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, skb->data,
+		addr = dma_map_single(&fep->pdev->dev, skb->data,
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
-		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+		if (dma_mapping_error(&fep->pdev->dev, addr)) {
+			dev_kfree_skb(skb);
 			fec_enet_free_buffers(ndev);
 			if (net_ratelimit())
 				netdev_err(ndev, "Rx DMA memory map failed\n");
 			return -ENOMEM;
 		}
+
+		fep->rx_skbuff[i] = skb;
+		bdp->cbd_bufaddr = addr;
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
 
 		if (fep->bufdesc_ex) {
-- 
1.8.3.1
