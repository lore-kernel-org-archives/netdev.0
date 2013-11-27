From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Wed, 27 Nov 2013 13:44:13 +0100
Message-ID: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Fugang Duan <B38611@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:44652 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346Ab3K0MoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 07:44:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On tx submit the driver always dma_map_single() FEC_ENET_TX_FRSIZE (=2048)
bytes. This works because we don't overwrite any memory after the data buffer,
we remove it from cache if it was there. So we hurt performace in case the
mapping of a smaller area makes a difference.
There is also a bug: If the data area starts shortly before the end of
RAM say 0xc7fffa10 and the RAM ends at 0xc8000000 then we have enough
space to fit the data area (according to skb->len) but we would map beyond
end of ram if we are using 2048. In v2.6.31 (against which kernel this patch
made) there is the following check in dma_cache_maint():

|BUG_ON(!virt_addr_valid(start) || !virt_addr_valid(start + size - 1));

Since the area starting at 0xc8000000 is no longer virt_addr_valid() we
BUG() during dma_map_single(). The BUG() statement was removed in v3.5-rc1 as
per 2dc6a016 ("ARM: dma-mapping: use asm-generic/dma-mapping-common.h").

This patch was tested on v2.6.31 and then forward-ported and compile
tested only against the net tree. I think it is still worth fixing
mainline even after the BUG() statement is gone.

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
It would be nice if someone could test this on current kernel.
Is this worth pushing stable?

Marek: Was there a special reason why the check was removed? Would it make
sense to bring it back say under CONFIG_DMA_DEBUG?

 drivers/net/ethernet/freescale/fec_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4cbebf3..29d8dc4 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -385,7 +385,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	 * data.
 	 */
 	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
-			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
+			skb->len, DMA_TO_DEVICE);
 	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
 		bdp->cbd_bufaddr = 0;
 		fep->tx_skbuff[index] = NULL;
@@ -779,11 +779,11 @@ fec_enet_tx(struct net_device *ndev)
 		else
 			index = bdp - fep->tx_bd_base;
 
-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
-				FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
+		skb = fep->tx_skbuff[index];
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr, skb->len,
+				DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = 0;
 
-		skb = fep->tx_skbuff[index];
 
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
-- 
1.8.4.4
