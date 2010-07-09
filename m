From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH v3] ll_temac: fix DMA and memory leaks
Date: Fri,  9 Jul 2010 21:55:13 +0400
Message-ID: <1278698113-5713-1-git-send-email-segooon@gmail.com>
Cc: Denis Kirjanov <dkirjanov@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	John Linn <john.linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:65242 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab0GIRzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 13:55:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

temac_dma_bd_init() doesn't free DMA and memory on error. Also
temac_stop() must free them.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ll_temac_main.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 5bca20b..9090e79 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -193,6 +193,41 @@ static int temac_dcr_setup(struct temac_local *lp, struct of_device *op,
 #endif
 
 /**
+ *  * temac_dma_bd_release - Release buffer descriptor rings
+ */
+static void temac_dma_bd_release(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	int i;
+
+	if (lp->rx_skb) {
+		for (i = 0; i < RX_BD_NUM; i++) {
+			if (!lp->rx_skb[i])
+				break;
+			dma_unmap_single(ndev->dev.parent, lp->rx_bd_v[i].phys,
+				    XTE_MAX_JUMBO_FRAME_SIZE, DMA_FROM_DEVICE);
+			dev_kfree_skb(lp->rx_skb[i]);
+		}
+		kfree(lp->rx_skb);
+		lp->rx_skb = NULL;
+	}
+
+	if (lp->rx_bd_v) {
+		dma_free_coherent(ndev->dev.parent,
+				sizeof(*lp->rx_bd_v) * RX_BD_NUM,
+				lp->rx_bd_v, lp->rx_bd_p);
+		lp->rx_bd_v = NULL;
+	}
+
+	if (lp->tx_bd_v) {
+		dma_free_coherent(ndev->dev.parent,
+				sizeof(*lp->tx_bd_v) * TX_BD_NUM,
+				lp->tx_bd_v, lp->tx_bd_p);
+		lp->tx_bd_v = NULL;
+	}
+}
+
+/**
  * temac_dma_bd_init - Setup buffer descriptor rings
  */
 static int temac_dma_bd_init(struct net_device *ndev)
@@ -275,6 +310,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	return 0;
 
 out:
+	temac_dma_bd_release(ndev);
 	return -ENOMEM;
 }
 
@@ -858,6 +894,8 @@ static int temac_stop(struct net_device *ndev)
 		phy_disconnect(lp->phy_dev);
 	lp->phy_dev = NULL;
 
+	temac_dma_bd_release(ndev);
+
 	return 0;
 }
 
-- 
1.7.0.4

