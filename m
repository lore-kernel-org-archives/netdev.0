From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH] ll_temac: add error checking to DMA init path
Date: Thu, 1 Jul 2010 09:39:05 +0000
Message-ID: <20100701093905.GA29132@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.linn@xilinx.com, brian.hill@xilinx.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:34023 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754717Ab0GAJjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 05:39:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add error checking to DMA descriptor rings initialization code.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/ll_temac_main.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 52dcc84..7b12d0e 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -202,14 +202,29 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	int i;
 
 	lp->rx_skb = kzalloc(sizeof(*lp->rx_skb) * RX_BD_NUM, GFP_KERNEL);
+	if (!lp->rx_skb) {
+		dev_err(&ndev->dev,
+				"can't allocate memory for DMA RX buffer\n");
+		goto out;
+	}
 	/* allocate the tx and rx ring buffer descriptors. */
 	/* returns a virtual addres and a physical address. */
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
 					 &lp->tx_bd_p, GFP_KERNEL);
+	if (!lp->tx_bd_v) {
+		dev_err(&ndev->dev,
+				"unable to allocate DMA TX buffer descriptors");
+		goto out;
+	}
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
 					 &lp->rx_bd_p, GFP_KERNEL);
+	if (!lp->rx_bd_v) {
+		dev_err(&ndev->dev,
+				"unable to allocate DMA RX buffer descriptors");
+		goto out;
+	}
 
 	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
 	for (i = 0; i < TX_BD_NUM; i++) {
@@ -227,7 +242,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
 
 		if (skb == 0) {
 			dev_err(&ndev->dev, "alloc_skb error %d\n", i);
-			return -1;
+			goto out;
 		}
 		lp->rx_skb[i] = skb;
 		/* returns physical address of skb->data */
@@ -258,6 +273,9 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	lp->dma_out(lp, TX_CURDESC_PTR, lp->tx_bd_p);
 
 	return 0;
+
+out:
+	return -ENOMEM;
 }
 
 /* ---------------------------------------------------------------------
@@ -505,7 +523,10 @@ static void temac_device_reset(struct net_device *ndev)
 	}
 	lp->dma_out(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
 
-	temac_dma_bd_init(ndev);
+	if (temac_dma_bd_init(ndev)) {
+		dev_err(&ndev->dev,
+				"temac_device_reset descriptor allocation failed\n");
+	}
 
 	temac_indirect_out32(lp, XTE_RXC0_OFFSET, 0);
 	temac_indirect_out32(lp, XTE_RXC1_OFFSET, 0);
