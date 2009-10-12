From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 6/8] gianfar: Factor out RX BDs initialization from
	gfar_new_rxbdp()
Date: Mon, 12 Oct 2009 20:00:37 +0400
Message-ID: <20091012160037.GF2463@oksana.dev.rtsoft.ru>
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

We want to just reinitialize RX BDs after hibernation, no need to
map the skb->data again. So let's factor gfar_init_rxbdp() out of
gfar_new_rxbdp().

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |   33 +++++++++++++++++++++------------
 1 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 46b0b37..1b32274 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -147,6 +147,23 @@ MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
 MODULE_LICENSE("GPL");
 
+static void gfar_init_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
+			    dma_addr_t buf)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	u32 lstatus;
+
+	bdp->bufPtr = buf;
+
+	lstatus = BD_LFLAG(RXBD_EMPTY | RXBD_INTERRUPT);
+	if (bdp == priv->rx_bd_base + priv->rx_ring_size - 1)
+		lstatus |= BD_LFLAG(RXBD_WRAP);
+
+	eieio();
+
+	bdp->lstatus = lstatus;
+}
+
 static int gfar_alloc_skb_resources(struct net_device *ndev)
 {
 	struct txbd8 *txbdp;
@@ -1676,19 +1693,11 @@ static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
 		struct sk_buff *skb)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	u32 lstatus;
-
-	bdp->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
-			priv->rx_buffer_size, DMA_FROM_DEVICE);
-
-	lstatus = BD_LFLAG(RXBD_EMPTY | RXBD_INTERRUPT);
+	dma_addr_t buf;
 
-	if (bdp == priv->rx_bd_base + priv->rx_ring_size - 1)
-		lstatus |= BD_LFLAG(RXBD_WRAP);
-
-	eieio();
-
-	bdp->lstatus = lstatus;
+	buf = dma_map_single(&priv->ofdev->dev, skb->data,
+			     priv->rx_buffer_size, DMA_FROM_DEVICE);
+	gfar_init_rxbdp(dev, bdp, buf);
 }
 
 
-- 
1.6.3.3
