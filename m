From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 3/4] ll_temac: free everything on error path
Date: Thu,  8 Jul 2010 16:10:10 +0400
Message-ID: <1278591012-3213-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	John Linn <john.linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Pirko <jpirko@redhat.com>,
	Brian Hill <brian.hill@xilinx.com>, netdev@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54488 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756450Ab0GHMKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 08:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

temac_dma_bd_init() must free all allocated resources: memory, dma, skbs.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ll_temac_main.c |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index a2da3d7..38d658a 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -200,6 +200,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	struct temac_local *lp = netdev_priv(ndev);
 	struct sk_buff *skb;
 	int i;
+	int tx_bd_v_size, rx_bd_v_size;
 
 	lp->rx_skb = kzalloc(sizeof(*lp->rx_skb) * RX_BD_NUM, GFP_KERNEL);
 	if (!lp->rx_skb) {
@@ -209,21 +210,23 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	}
 	/* allocate the tx and rx ring buffer descriptors. */
 	/* returns a virtual addres and a physical address. */
+	tx_bd_v_size = sizeof(*lp->tx_bd_v) * TX_BD_NUM;
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
-					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
+					tx_bd_v_size,
 					 &lp->tx_bd_p, GFP_KERNEL);
 	if (!lp->tx_bd_v) {
 		dev_err(&ndev->dev,
 				"unable to allocate DMA TX buffer descriptors");
-		goto out;
+		goto err_rx_skb;
 	}
+	rx_bd_v_size = sizeof(*lp->rx_bd_v) * RX_BD_NUM;
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
-					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
+					 rx_bd_v_size,
 					 &lp->rx_bd_p, GFP_KERNEL);
 	if (!lp->rx_bd_v) {
 		dev_err(&ndev->dev,
 				"unable to allocate DMA RX buffer descriptors");
-		goto out;
+		goto err_tx_bd;
 	}
 
 	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
@@ -242,7 +245,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
 
 		if (skb == 0) {
 			dev_err(&ndev->dev, "alloc_skb error %d\n", i);
-			goto out;
+			goto err_dma_single;
 		}
 		lp->rx_skb[i] = skb;
 		/* returns physical address of skb->data */
@@ -274,6 +277,23 @@ static int temac_dma_bd_init(struct net_device *ndev)
 
 	return 0;
 
+err_dma_single:
+	for (i = 0; i < RX_BD_NUM; i++) {
+		if (lp->rx_skb[i] == NULL)
+			break;
+
+		kfree_skb(lp->rx_skb[i]);
+		dma_unmap_single(ndev->dev.parent, lp->rx_bd_v[i].phys,
+				XTE_MAX_JUMBO_FRAME_SIZE, DMA_FROM_DEVICE);
+	}
+
+	dma_free_coherent(ndev->dev.parent, rx_bd_v_size,
+				lp->rx_bd_v, lp->rx_bd_p);
+err_tx_bd:
+	dma_free_coherent(ndev->dev.parent, tx_bd_v_size,
+				lp->tx_bd_v, lp->tx_bd_p);
+err_rx_skb:
+	kfree(lp->rx_skb);
 out:
 	return -ENOMEM;
 }
-- 
1.7.0.4

