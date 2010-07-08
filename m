From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH -net-2.6] ll_temac: fix DMA resources leak
Date: Thu, 8 Jul 2010 13:54:45 +0000
Message-ID: <20100708135445.GA30923@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.linn@xilinx.com, brian.hill@xilinx.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:35367 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757859Ab0GHNyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jul 2010 09:54:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix DMA resources leak.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index fa303c8..afec660 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -193,6 +193,28 @@ static int temac_dcr_setup(struct temac_local *lp, struct of_device *op,
 #endif
 
 /**
+ *  * temac_dma_bd_release - Release buffer descriptor rings
+ */
+static void temac_dma_bd_release(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	int i;
+
+	for (i = 0; i < RX_BD_NUM; i++) {
+		if (lp->rx_skb[i]) {
+			dma_unmap_single(ndev->dev.parent, lp->rx_bd_v[i].phys,
+					XTE_MAX_JUMBO_FRAME_SIZE, DMA_FROM_DEVICE);
+			dev_kfree_skb(lp->rx_skb[i]);
+		}
+	}
+	dma_free_coherent(ndev->dev.parent, sizeof(*lp->rx_bd_v) * RX_BD_NUM,
+			lp->rx_bd_v, lp->rx_bd_p);
+	dma_free_coherent(ndev->dev.parent, sizeof(*lp->tx_bd_v) * TX_BD_NUM,
+			lp->tx_bd_v, lp->tx_bd_p);
+	kfree(lp->rx_skb);
+}
+
+/**
  * temac_dma_bd_init - Setup buffer descriptor rings
  */
 static int temac_dma_bd_init(struct net_device *ndev)
@@ -275,6 +297,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	return 0;
 
 out:
+	temac_dma_bd_release(ndev);
 	return -ENOMEM;
 }
 
@@ -858,6 +881,8 @@ static int temac_stop(struct net_device *ndev)
 		phy_disconnect(lp->phy_dev);
 	lp->phy_dev = NULL;
 
+	temac_dma_bd_release(ndev);
+
 	return 0;
 }
 
