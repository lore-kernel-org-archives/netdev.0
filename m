From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 7/8] gianfar: Factor out gfar_init_bds() from
	gfar_alloc_skb_resources()
Date: Mon, 12 Oct 2009 20:00:39 +0400
Message-ID: <20091012160039.GG2463@oksana.dev.rtsoft.ru>
References: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

After hibernation we want to just reinitialize BDs, no need to allocate
anything. So, factor out BDs initialization code from
gfar_alloc_skb_resourses().

Also, teach gfar_init_bds() to reuse already allocated RX SKBs, i.e.
just call gfar_init_rxbdp() if a SKB was already allocated and mapped.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |   96 ++++++++++++++++++++++++++++--------------------
 1 files changed, 56 insertions(+), 40 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1b32274..634a15b 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -164,19 +164,68 @@ static void gfar_init_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
 	bdp->lstatus = lstatus;
 }
 
-static int gfar_alloc_skb_resources(struct net_device *ndev)
+static int gfar_init_bds(struct net_device *ndev)
 {
+	struct gfar_private *priv = netdev_priv(ndev);
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
+	int i;
+
+	/* Initialize some variables in our dev structure */
+	priv->num_txbdfree = priv->tx_ring_size;
+	priv->dirty_tx = priv->cur_tx = priv->tx_bd_base;
+	priv->cur_rx = priv->rx_bd_base;
+	priv->skb_curtx = priv->skb_dirtytx = 0;
+	priv->skb_currx = 0;
+
+	/* Initialize Transmit Descriptor Ring */
+	txbdp = priv->tx_bd_base;
+	for (i = 0; i < priv->tx_ring_size; i++) {
+		txbdp->lstatus = 0;
+		txbdp->bufPtr = 0;
+		txbdp++;
+	}
+
+	/* Set the last descriptor in the ring to indicate wrap */
+	txbdp--;
+	txbdp->status |= TXBD_WRAP;
+
+	rxbdp = priv->rx_bd_base;
+	for (i = 0; i < priv->rx_ring_size; i++) {
+		struct sk_buff *skb = priv->rx_skbuff[i];
+
+		if (skb) {
+			gfar_init_rxbdp(ndev, rxbdp, rxbdp->bufPtr);
+		} else {
+			skb = gfar_new_skb(ndev);
+			if (!skb) {
+				pr_err("%s: Can't allocate RX buffers\n",
+				       ndev->name);
+				return -ENOMEM;
+			}
+			priv->rx_skbuff[i] = skb;
+
+			gfar_new_rxbdp(ndev, rxbdp, skb);
+		}
+
+		rxbdp++;
+	}
+
+	return 0;
+}
+
+static int gfar_alloc_skb_resources(struct net_device *ndev)
+{
 	void *vaddr;
 	int i;
 	struct gfar_private *priv = netdev_priv(ndev);
 	struct device *dev = &priv->ofdev->dev;
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = dma_alloc_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
-					sizeof(*rxbdp) * priv->rx_ring_size,
-				   &priv->tx_bd_dma_base, GFP_KERNEL);
+	vaddr = dma_alloc_coherent(dev,
+			sizeof(*priv->tx_bd_base) * priv->tx_ring_size +
+			sizeof(*priv->rx_bd_base) * priv->rx_ring_size,
+			&priv->tx_bd_dma_base, GFP_KERNEL);
 	if (!vaddr) {
 		if (netif_msg_ifup(priv))
 			pr_err("%s: Could not allocate buffer descriptors!\n",
@@ -187,7 +236,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 	priv->tx_bd_base = vaddr;
 
 	/* Start the rx descriptor ring where the tx ring leaves off */
-	vaddr = vaddr + sizeof(*txbdp) * priv->tx_ring_size;
+	vaddr = vaddr + sizeof(*priv->tx_bd_base) * priv->tx_ring_size;
 	priv->rx_bd_base = vaddr;
 
 	/* Setup the skbuff rings */
@@ -215,41 +264,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 	for (i = 0; i < priv->rx_ring_size; i++)
 		priv->rx_skbuff[i] = NULL;
 
-	/* Initialize some variables in our dev structure */
-	priv->num_txbdfree = priv->tx_ring_size;
-	priv->dirty_tx = priv->cur_tx = priv->tx_bd_base;
-	priv->cur_rx = priv->rx_bd_base;
-	priv->skb_curtx = priv->skb_dirtytx = 0;
-	priv->skb_currx = 0;
-
-	/* Initialize Transmit Descriptor Ring */
-	txbdp = priv->tx_bd_base;
-	for (i = 0; i < priv->tx_ring_size; i++) {
-		txbdp->lstatus = 0;
-		txbdp->bufPtr = 0;
-		txbdp++;
-	}
-
-	/* Set the last descriptor in the ring to indicate wrap */
-	txbdp--;
-	txbdp->status |= TXBD_WRAP;
-
-	rxbdp = priv->rx_bd_base;
-	for (i = 0; i < priv->rx_ring_size; i++) {
-		struct sk_buff *skb;
-
-		skb = gfar_new_skb(ndev);
-		if (!skb) {
-			pr_err("%s: Can't allocate RX buffers\n", ndev->name);
-			goto cleanup;
-		}
-
-		priv->rx_skbuff[i] = skb;
-
-		gfar_new_rxbdp(ndev, rxbdp, skb);
-
-		rxbdp++;
-	}
+	if (gfar_init_bds(ndev))
+		goto cleanup;
 
 	return 0;
 
-- 
1.6.3.3
