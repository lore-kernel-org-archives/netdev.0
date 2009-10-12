From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 5/8] gianfar: Move tbase/rbase initialization to
	gfar_init_mac()
Date: Mon, 12 Oct 2009 20:00:36 +0400
Message-ID: <20091012160036.GE2463@oksana.dev.rtsoft.ru>
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

For hibernation we want to call gfar_init_mac() without need to
free/allocate_skb_resources sequence, so save the DMA address into a
private struct, and move tbase/rbase initialization to gfar_init_mac().

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |   17 ++++++++---------
 drivers/net/gianfar.h |    1 +
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4dcaaa7..46b0b37 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -151,17 +151,15 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 {
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
-	dma_addr_t addr = 0;
 	void *vaddr;
 	int i;
 	struct gfar_private *priv = netdev_priv(ndev);
 	struct device *dev = &priv->ofdev->dev;
-	struct gfar __iomem *regs = priv->regs;
 
 	/* Allocate memory for the buffer descriptors */
 	vaddr = dma_alloc_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
 					sizeof(*rxbdp) * priv->rx_ring_size,
-				   &addr, GFP_KERNEL);
+				   &priv->tx_bd_dma_base, GFP_KERNEL);
 	if (!vaddr) {
 		if (netif_msg_ifup(priv))
 			pr_err("%s: Could not allocate buffer descriptors!\n",
@@ -171,14 +169,9 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 
 	priv->tx_bd_base = vaddr;
 
-	/* enet DMA only understands physical addresses */
-	gfar_write(&regs->tbase0, addr);
-
 	/* Start the rx descriptor ring where the tx ring leaves off */
-	addr = addr + sizeof(*txbdp) * priv->tx_ring_size;
 	vaddr = vaddr + sizeof(*txbdp) * priv->tx_ring_size;
 	priv->rx_bd_base = vaddr;
-	gfar_write(&regs->rbase0, addr);
 
 	/* Setup the skbuff rings */
 	priv->tx_skbuff = kmalloc(sizeof(*priv->tx_skbuff) *
@@ -256,6 +249,12 @@ static void gfar_init_mac(struct net_device *ndev)
 	u32 tctrl = 0;
 	u32 attrs = 0;
 
+	/* enet DMA only understands physical addresses */
+	gfar_write(&regs->tbase0, priv->tx_bd_dma_base);
+	gfar_write(&regs->rbase0, priv->tx_bd_dma_base +
+				  sizeof(*priv->tx_bd_base) *
+				  priv->tx_ring_size);
+
 	/* Configure the coalescing support */
 	gfar_write(&regs->txic, 0);
 	if (priv->txcoalescing)
@@ -1060,7 +1059,7 @@ skip_rx_skbuff:
 
 	dma_free_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
 			       sizeof(*rxbdp) * priv->rx_ring_size,
-			  priv->tx_bd_base, gfar_read(&priv->regs->tbase0));
+			  priv->tx_bd_base, priv->tx_bd_dma_base);
 }
 
 void gfar_start(struct net_device *dev)
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 2cd9433..05732fa 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -726,6 +726,7 @@ struct gfar_private {
 	unsigned long txic;
 
 	/* Buffer descriptor pointers */
+	dma_addr_t tx_bd_dma_base;
 	struct txbd8 *tx_bd_base;	/* First tx buffer descriptor */
 	struct txbd8 *cur_tx;	        /* Next free ring entry */
 	struct txbd8 *dirty_tx;		/* First buffer in line
-- 
1.6.3.3
