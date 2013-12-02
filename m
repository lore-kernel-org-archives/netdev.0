From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH v2] net: fec_main: dma_map() only the length of the skb
Date: Mon, 2 Dec 2013 10:52:55 +0100
Message-ID: <20131202095255.GA13247@linutronix.de>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
 <9848F2DB572E5649BA045B288BE08FBE018B5B1A@039-SN2MPN1-022.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Jim Baxter <jim_baxter@mentor.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>
To: Fugang Duan <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:42227 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232Ab3LBJxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 04:53:04 -0500
Content-Disposition: inline
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE018B5B1A@039-SN2MPN1-022.039d.mgd.msft.net>
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

Tested-by: Fugang Duan <B38611@freescale.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1..v2: removed a blank line.

 drivers/net/ethernet/freescale/fec_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4cbebf3..73b000d 100644
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
@@ -779,11 +779,10 @@ fec_enet_tx(struct net_device *ndev)
 		else
 			index = bdp - fep->tx_bd_base;
 
-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
-				FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
-		bdp->cbd_bufaddr = 0;
-
 		skb = fep->tx_skbuff[index];
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr, skb->len,
+				DMA_TO_DEVICE);
+		bdp->cbd_bufaddr = 0;
 
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
-- 
1.8.4.4
