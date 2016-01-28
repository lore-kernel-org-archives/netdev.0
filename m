From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 22/40] net: fec: call dma_unmap_single on mapped tx buffers at restart
Date: Thu, 28 Jan 2016 14:25:46 -0700
Message-ID: <1454016364-30985-23-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32861 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879AbcA1V2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:45 -0500
Received: by mail-pf0-f179.google.com with SMTP id x125so29976434pfb.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:45 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bc084ad9..da2e3c530 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -403,6 +403,7 @@ dma_mapping_error:
 		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 				bdp->cbd_datlen, DMA_TO_DEVICE);
+		bdp->cbd_bufaddr = 0;
 	}
 	return ERR_PTR(-ENOMEM);
 }
@@ -788,11 +789,18 @@ static void fec_enet_bd_init(struct net_device *dev)
 
 		for (i = 0; i < txq->bd.ring_size; i++) {
 			/* Initialize the BD for every fragment in the page. */
+			if (bdp->cbd_bufaddr) {
+				if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
+					dma_unmap_single(&fep->pdev->dev,
+							 bdp->cbd_bufaddr,
+							 bdp->cbd_datlen,
+							 DMA_TO_DEVICE);
+				bdp->cbd_bufaddr = 0;
+			}
 			if (txq->tx_skbuff[i]) {
 				dev_kfree_skb_any(txq->tx_skbuff[i]);
 				txq->tx_skbuff[i] = NULL;
 			}
-			bdp->cbd_bufaddr = 0;
 			bdp->cbd_sc = (bdp == txq->bd.last) ? BD_SC_WRAP : 0;
 			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		}
@@ -2635,6 +2643,7 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 						 bdp->cbd_bufaddr,
 						 FEC_ENET_RX_FRSIZE - fep->rx_align,
 						 DMA_FROM_DEVICE);
+				bdp->cbd_bufaddr = 0;
 				dev_kfree_skb(skb);
 			}
 			bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
@@ -2645,11 +2654,20 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 		txq = fep->tx_queue[q];
 		bdp = txq->bd.base;
 		for (i = 0; i < txq->bd.ring_size; i++) {
+			if (bdp->cbd_bufaddr) {
+				if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
+					dma_unmap_single(&fep->pdev->dev,
+							 bdp->cbd_bufaddr,
+							 bdp->cbd_datlen,
+							 DMA_TO_DEVICE);
+				bdp->cbd_bufaddr = 0;
+			}
 			kfree(txq->tx_bounce[i]);
 			txq->tx_bounce[i] = NULL;
 			skb = txq->tx_skbuff[i];
 			txq->tx_skbuff[i] = NULL;
 			dev_kfree_skb(skb);
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		}
 	}
 }
-- 
2.5.0
