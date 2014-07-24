From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH v2 3/6] net/macb: add TX checksum offload feature
Date: Thu, 24 Jul 2014 13:51:00 +0200
Message-ID: <76147417f6902f4d5c08581b43857f582ed5d5b1.1406192657.git.cyrille.pitchen@atmel.com>
References: <cover.1406192657.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1406192657.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2e4bfe3..cc36269 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1525,6 +1525,10 @@ static void macb_configure_dma(struct macb *bp)
 			dmacfg = GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
 		dmacfg &= ~GEM_BIT(ENDIA);
+		if (bp->dev->features & NETIF_F_HW_CSUM)
+			dmacfg |= GEM_BIT(TXCOEN);
+		else
+			dmacfg &= ~GEM_BIT(TXCOEN);
 		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
 			   dmacfg);
 		gem_writel(bp, DMACFG, dmacfg);
@@ -1925,6 +1929,27 @@ int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
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
@@ -1938,6 +1963,7 @@ static const struct net_device_ops macb_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= macb_poll_controller,
 #endif
+	.ndo_set_features	= macb_set_features,
 };
 
 #if defined(CONFIG_OF)
@@ -2122,6 +2148,9 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	/* Set features */
 	dev->hw_features = NETIF_F_SG;
+	/* Checksum offload is only available on gem with packet buffer */
+	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE))
+		dev->hw_features |= NETIF_F_HW_CSUM;
 	if (bp->caps & MACB_CAPS_SG_DISABLED)
 		dev->hw_features &= ~NETIF_F_SG;
 	dev->features = dev->hw_features;
-- 
1.8.2.2
