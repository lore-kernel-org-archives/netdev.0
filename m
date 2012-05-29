From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v5 4/6] net: sh_eth: fix up the buffer pointers
Date: Tue, 29 May 2012 17:14:57 +0900
Message-ID: <4FC48581.5060004@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After freeing the buffer, the driver should change the value of
the pointer to NULL.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 about v5:
  - this patch is the same as v3

 drivers/net/ethernet/renesas/sh_eth.c |   31 ++++++++++++++++++++++++-------
 1 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 906e410..ff5a4a9 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -745,6 +745,7 @@ static void sh_eth_ring_free(struct net_device *ndev)
 		}
 	}
 	kfree(mdp->rx_skbuff);
+	mdp->rx_skbuff = NULL;

 	/* Free Tx skb ringbuffer */
 	if (mdp->tx_skbuff) {
@@ -754,6 +755,7 @@ static void sh_eth_ring_free(struct net_device *ndev)
 		}
 	}
 	kfree(mdp->tx_skbuff);
+	mdp->tx_skbuff = NULL;
 }

 /* format skb and descriptor buffer */
@@ -890,10 +892,31 @@ desc_ring_free:
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
@@ -1629,7 +1652,6 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 static int sh_eth_close(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	int ringsize;

 	netif_stop_queue(ndev);

@@ -1652,12 +1674,7 @@ static int sh_eth_close(struct net_device *ndev)
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

