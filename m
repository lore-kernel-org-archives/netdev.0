From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH] bcm63xx_enet: fix poll callback.
Date: Mon,  2 Mar 2015 18:28:10 +0100
Message-ID: <1425317290-1443-1-git-send-email-nschichan@freebox.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case there was some tx buffer reclaimed and not enough rx packets
to consume the whole budget, napi_complete would not be called and
interrupts would be kept disabled, effectively resulting in the
network core never to call the poll callback again and no rx/tx
interrupts to be fired either.

Fix that by taking the tx buffer reclaim work into account in the poll
callback, and keeping interrupts off only when the budget allowance
has been exhausted.
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 21206d3..e0d599a 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -427,7 +427,7 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
 /*
  * try to or force reclaim of transmitted buffers
  */
-static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
+static int bcm_enet_tx_reclaim(struct net_device *dev, int force, int budget)
 {
 	struct bcm_enet_priv *priv;
 	int released;
@@ -471,6 +471,8 @@ static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
 
 		dev_kfree_skb(skb);
 		released++;
+		if (!force && released == budget)
+			break;
 	}
 
 	if (netif_queue_stopped(dev) && released)
@@ -486,7 +488,7 @@ static int bcm_enet_poll(struct napi_struct *napi, int budget)
 {
 	struct bcm_enet_priv *priv;
 	struct net_device *dev;
-	int tx_work_done, rx_work_done;
+	int work_done;
 
 	priv = container_of(napi, struct bcm_enet_priv, napi);
 	dev = priv->net_dev;
@@ -498,15 +500,15 @@ static int bcm_enet_poll(struct napi_struct *napi, int budget)
 			 ENETDMAC_IR, priv->tx_chan);
 
 	/* reclaim sent skb */
-	tx_work_done = bcm_enet_tx_reclaim(dev, 0);
+	work_done = bcm_enet_tx_reclaim(dev, 0, budget);
 
 	spin_lock(&priv->rx_lock);
-	rx_work_done = bcm_enet_receive_queue(dev, budget);
+	work_done += bcm_enet_receive_queue(dev, budget - work_done);
 	spin_unlock(&priv->rx_lock);
 
-	if (rx_work_done >= budget || tx_work_done > 0) {
+	if (work_done >= budget) {
 		/* rx/tx queue is not yet empty/clean */
-		return rx_work_done;
+		return work_done;
 	}
 
 	/* no more packet in rx/tx queue, remove device from poll
@@ -519,7 +521,7 @@ static int bcm_enet_poll(struct napi_struct *napi, int budget)
 	enet_dmac_writel(priv, priv->dma_chan_int_mask,
 			 ENETDMAC_IRMASK, priv->tx_chan);
 
-	return rx_work_done;
+	return work_done;
 }
 
 /*
@@ -1208,7 +1210,7 @@ static int bcm_enet_stop(struct net_device *dev)
 	bcm_enet_disable_mac(priv);
 
 	/* force reclaim of all tx buffers */
-	bcm_enet_tx_reclaim(dev, 1);
+	bcm_enet_tx_reclaim(dev, 1, 0);
 
 	/* free the rx skb ring */
 	for (i = 0; i < priv->rx_ring_size; i++) {
@@ -2415,7 +2417,7 @@ static int bcm_enetsw_stop(struct net_device *dev)
 	bcm_enet_disable_dma(priv, priv->rx_chan);
 
 	/* force reclaim of all tx buffers */
-	bcm_enet_tx_reclaim(dev, 1);
+	bcm_enet_tx_reclaim(dev, 1, 0);
 
 	/* free the rx skb ring */
 	for (i = 0; i < priv->rx_ring_size; i++) {
-- 
1.9.1
