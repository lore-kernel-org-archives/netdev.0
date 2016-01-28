From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 28/40] net: fec: unmap initial buffer on error
Date: Thu, 28 Jan 2016 14:25:52 -0700
Message-ID: <1454016364-30985-29-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32934 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898AbcA1V24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:56 -0500
Received: by mail-pf0-f173.google.com with SMTP id x125so29978421pfb.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:56 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 7258051..e141f6f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -404,7 +404,6 @@ dma_mapping_error:
 				bdp->cbd_datlen, DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = 0;
 	}
-	dev_kfree_skb_any(skb);
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -466,8 +465,12 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 			((bdp == txq->bd.last) ? BD_SC_WRAP : 0);
 	if (nr_frags) {
 		last_bdp = fec_enet_txq_submit_frag_skb(txq, skb, ndev);
-		if (IS_ERR(last_bdp))
+		if (IS_ERR(last_bdp)) {
+			dma_unmap_single(&fep->pdev->dev, addr,
+					 buflen, DMA_TO_DEVICE);
+			dev_kfree_skb_any(skb);
 			return NETDEV_TX_OK;
+		}
 	} else {
 		status |= (BD_ENET_TX_INTR | BD_ENET_TX_LAST);
 		if (fep->bufdesc_ex) {
-- 
2.5.0
