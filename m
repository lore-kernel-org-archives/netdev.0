From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH net-next 3/4 v2] net: sh_eth: fix up the buffer pointers
Date: Wed, 27 Jun 2012 15:00:01 +0900
Message-ID: <4FEAA161.4030001@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:56023 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab2F0GAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 02:00:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After freeing the buffer, the driver should change the value of
the pointer to NULL.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 about v2:
  - rebase the latest net-next.git

 drivers/net/ethernet/renesas/sh_eth.c |   31 ++++++++++++++++++++++++-------
 1 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 43e76d2..2dd2ff5 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -788,6 +788,7 @@ static void sh_eth_ring_free(struct net_device *ndev)
 		}
 	}
 	kfree(mdp->rx_skbuff);
+	mdp->rx_skbuff = NULL;

 	/* Free Tx skb ringbuffer */
 	if (mdp->tx_skbuff) {
@@ -797,6 +798,7 @@ static void sh_eth_ring_free(struct net_device *ndev)
 		}
 	}
 	kfree(mdp->tx_skbuff);
+	mdp->tx_skbuff = NULL;
 }

 /* format skb and descriptor buffer */
@@ -933,10 +935,31 @@ desc_ring_free:
 skb_ring_free:
 	/* Free Rx and Tx skb ring buffer */
 	sh_eth_ring_free(ndev);
+	mdp->tx_ring = NULL;
+	mdp->rx_ring = NULL;

 	return ret;
 }

+static void sh_eth_free_dma_buffer(struct sh_eth_private *mdp)
+{
+	int ringsize;
+
+	if (mdp->rx_ring) {
+		ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+		dma_free_coherent(NULL, ringsize, mdp->rx_ring,
+				  mdp->rx_desc_dma);
+		mdp->rx_ring = NULL;
+	}
+
+	if (mdp->tx_ring) {
+		ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+		dma_free_coherent(NULL, ringsize, mdp->tx_ring,
+				  mdp->tx_desc_dma);
+		mdp->tx_ring = NULL;
+	}
+}
+
 static int sh_eth_dev_init(struct net_device *ndev)
 {
 	int ret = 0;
@@ -1677,7 +1700,6 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 static int sh_eth_close(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	int ringsize;

 	netif_stop_queue(ndev);

@@ -1700,12 +1722,7 @@ static int sh_eth_close(struct net_device *ndev)
 	sh_eth_ring_free(ndev);

 	/* free DMA buffer */
-	ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
-	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);
-
-	/* free DMA buffer */
-	ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
-	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
+	sh_eth_free_dma_buffer(mdp);

 	pm_runtime_put_sync(&mdp->pdev->dev);

-- 
1.7.1
