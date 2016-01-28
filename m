From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 34/40] net: fec: update dirty_tx even if no skb
Date: Thu, 28 Jan 2016 14:25:58 -0700
Message-ID: <1454016364-30985-35-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32779 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965963AbcA1V3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:29:06 -0500
Received: by mail-pa0-f54.google.com with SMTP id cy9so29208739pac.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:29:05 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dirty_tx isn't updated, then dma_unmap_single
will be called twice.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 512b1ad..8dea600 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1236,10 +1236,8 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 					bdp->cbd_datlen, DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = 0;
-		if (!skb) {
-			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-			continue;
-		}
+		if (!skb)
+			goto skb_done;
 
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
@@ -1278,7 +1276,7 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 
 		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
-
+skb_done:
 		/* Make sure the update to bdp and tx_skbuff are performed
 		 * before dirty_tx
 		 */
-- 
2.5.0
