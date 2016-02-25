From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 14/16] net: fec: create subroutine reset_tx_queue
Date: Wed, 24 Feb 2016 17:36:57 -0700
Message-ID: <1456360619-24390-15-git-send-email-troy.kisky@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35977 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759044AbcBYAkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:40:42 -0500
Received: by mail-pa0-f43.google.com with SMTP id yy13so21742713pab.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:40:37 -0800 (PST)
In-Reply-To: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This creates one place to release any queued
tx skbs.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 50 +++++++++++++++----------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9a3136b..8711196 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -752,12 +752,33 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return NETDEV_TX_OK;
 }
 
+static void reset_tx_queue(struct fec_enet_private *fep,
+			   struct fec_enet_priv_tx_q *txq)
+{
+	struct bufdesc *bdp = txq->bd.base;
+	unsigned int i;
+
+	txq->bd.cur = bdp;
+	for (i = 0; i < txq->bd.ring_size; i++) {
+		/* Initialize the BD for every fragment in the page. */
+		if (txq->tx_skbuff[i]) {
+			dev_kfree_skb_any(txq->tx_skbuff[i]);
+			txq->tx_skbuff[i] = NULL;
+		}
+		bdp->cbd_bufaddr = cpu_to_fec32(0);
+		bdp->cbd_sc = cpu_to_fec16((bdp == txq->bd.last) ?
+					   BD_SC_WRAP : 0);
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+	}
+	bdp = fec_enet_get_prevdesc(bdp, &txq->bd);
+	txq->dirty_tx = bdp;
+}
+
 /* Init RX & TX buffer descriptors
  */
 static void fec_enet_bd_init(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	struct fec_enet_priv_tx_q *txq;
 	struct fec_enet_priv_rx_q *rxq;
 	struct bufdesc *bdp;
 	unsigned int i;
@@ -780,26 +801,8 @@ static void fec_enet_bd_init(struct net_device *dev)
 		rxq->bd.cur = rxq->bd.base;
 	}
 
-	for (q = 0; q < fep->num_tx_queues; q++) {
-		/* ...and the same for transmit */
-		txq = fep->tx_queue[q];
-		bdp = txq->bd.base;
-		txq->bd.cur = bdp;
-
-		for (i = 0; i < txq->bd.ring_size; i++) {
-			/* Initialize the BD for every fragment in the page. */
-			if (txq->tx_skbuff[i]) {
-				dev_kfree_skb_any(txq->tx_skbuff[i]);
-				txq->tx_skbuff[i] = NULL;
-			}
-			bdp->cbd_bufaddr = cpu_to_fec32(0);
-			bdp->cbd_sc = cpu_to_fec16((bdp == txq->bd.last) ?
-					BD_SC_WRAP : 0);
-			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-		}
-		bdp = fec_enet_get_prevdesc(bdp, &txq->bd);
-		txq->dirty_tx = bdp;
-	}
+	for (q = 0; q < fep->num_tx_queues; q++)
+		reset_tx_queue(fep, fep->tx_queue[q]);
 }
 
 static void fec_enet_active_rxring(struct net_device *ndev)
@@ -2652,13 +2655,10 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 
 	for (q = 0; q < fep->num_tx_queues; q++) {
 		txq = fep->tx_queue[q];
-		bdp = txq->bd.base;
+		reset_tx_queue(fep, txq);
 		for (i = 0; i < txq->bd.ring_size; i++) {
 			kfree(txq->tx_bounce[i]);
 			txq->tx_bounce[i] = NULL;
-			skb = txq->tx_skbuff[i];
-			txq->tx_skbuff[i] = NULL;
-			dev_kfree_skb(skb);
 		}
 	}
 }
-- 
2.5.0
