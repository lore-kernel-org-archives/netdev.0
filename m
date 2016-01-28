From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 32/40] net: fec: fix err_release in fec_enet_txq_submit_tso
Date: Thu, 28 Jan 2016 14:25:56 -0700
Message-ID: <1454016364-30985-33-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34285 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914AbcA1V3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:29:02 -0500
Received: by mail-pf0-f179.google.com with SMTP id o185so25031836pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:29:02 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unmap descriptors upon error.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ee6cd69..9da2c6d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -319,6 +319,18 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
+static void unmap_descriptors(struct fec_enet_private *fep,
+			      struct fec_enet_priv_tx_q *txq,
+			      struct bufdesc *bdp, struct bufdesc *end)
+{
+	while (bdp != end) {
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
+				 bdp->cbd_datlen, DMA_TO_DEVICE);
+		bdp->cbd_bufaddr = 0;
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+	}
+}
+
 static struct bufdesc *
 fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 			     struct sk_buff *skb,
@@ -335,7 +347,6 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 	unsigned int index;
 	void *bufaddr;
 	dma_addr_t addr;
-	int i;
 
 	for (frag = 0; frag < nr_frags; frag++) {
 		this_frag = &skb_shinfo(skb)->frags[frag];
@@ -397,13 +408,8 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 
 	return bdp;
 dma_mapping_error:
-	bdp = txq->bd.cur;
-	for (i = 0; i < frag; i++) {
-		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
-				bdp->cbd_datlen, DMA_TO_DEVICE);
-		bdp->cbd_bufaddr = 0;
-	}
+	unmap_descriptors(fep, txq,
+			  fec_enet_get_nextdesc(txq->bd.cur, &txq->bd), bdp);
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -733,8 +739,9 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 	return 0;
 
 err_release:
-	/* TODO: Release all used data descriptors for TSO */
-	return ret;
+	unmap_descriptors(fep, txq, first_bdp, bdp);
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
 }
 
 static netdev_tx_t
-- 
2.5.0
