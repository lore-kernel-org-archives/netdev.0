From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 3/6] net/macb: add TX checksum offload feature
Date: Fri, 18 Jul 2014 16:21:15 +0200
Message-ID: <81148356bc5a52d07c49b18f68833fa7b2f97f2d.1405689937.git.cyrille.pitchen@atmel.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>, linux-kernel@vger.kernel.org
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
 <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
 <soren.brinkmann@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1405689937.git.cyrille.pitchen@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 06e9934..9bdcd1b 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1524,6 +1524,10 @@ static void macb_configure_dma(struct macb *bp)
 			dmacfg = GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
 		dmacfg &= ~GEM_BIT(ENDIA);
+		if (bp->dev->features & NETIF_F_HW_CSUM)
+			dmacfg |= GEM_BIT(TXCOEN);
+		else
+			dmacfg &= ~GEM_BIT(TXCOEN);
 		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n", dmacfg);
 		gem_writel(bp, DMACFG, dmacfg);
 	}
@@ -1923,6 +1927,27 @@ int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 EXPORT_SYMBOL_GPL(macb_ioctl);
 
+static int macb_set_features(struct net_device *netdev,
+			     netdev_features_t features)
+{
+	struct macb *bp = netdev_priv(netdev);
+	netdev_features_t changed = features ^ netdev->features;
+
+	/* TX checksum offload */
+	if ((changed & NETIF_F_HW_CSUM) && macb_is_gem(bp)) {
+		u32 dmacfg;
+
+		dmacfg = gem_readl(bp, DMACFG);
+		if (features & NETIF_F_HW_CSUM)
+			dmacfg |= GEM_BIT(TXCOEN);
+		else
+			dmacfg &= ~GEM_BIT(TXCOEN);
+		gem_writel(bp, DMACFG, dmacfg);
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops macb_netdev_ops = {
 	.ndo_open		= macb_open,
 	.ndo_stop		= macb_close,
@@ -1936,6 +1961,7 @@ static const struct net_device_ops macb_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= macb_poll_controller,
 #endif
+	.ndo_set_features	= macb_set_features,
 };
 
 #if defined(CONFIG_OF)
@@ -2118,6 +2144,10 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	/* Set features */
 	dev->hw_features = NETIF_F_SG;
+	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE)) {
+		/* Checksum offload is only available on packet buffer design */
+		dev->hw_features |= NETIF_F_HW_CSUM;
+	}
 	if (bp->caps & MACB_CAPS_SG_DISABLED)
 		dev->hw_features &= ~NETIF_F_SG;
 	dev->features = dev->hw_features;
-- 
1.8.2.2
