From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 11/14] NET: MIPS: lantiq: convert etop driver to clkdev api
Date: Thu, 23 Feb 2012 17:03:10 +0100
Message-ID: <1330012993-13510-11-git-send-email-blogic@openwrt.org>
References: <1330012993-13510-1-git-send-email-blogic@openwrt.org>
Cc: linux-mips@linux-mips.org, John Crispin <blogic@openwrt.org>,
	netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:56670 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654Ab2BWQUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Feb 2012 11:20:03 -0500
In-Reply-To: <1330012993-13510-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update from old pmu_{dis,en}able() to ckldev api.

Signed-off-by: John Crispin <blogic@openwrt.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/lantiq_etop.c |   47 ++++++++++++++++++++++++++++++-----
 1 files changed, 40 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index e5ec8b1..6b2e4b4 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -36,6 +36,7 @@
 #include <linux/io.h>
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
+#include <linux/clk.h>
 
 #include <asm/checksum.h>
 
@@ -148,6 +149,11 @@ struct ltq_etop_priv {
 	int tx_free[MAX_DMA_CHAN >> 1];
 
 	spinlock_t lock;
+
+	struct clk *clk_ppe;
+	struct clk *clk_switch;
+	struct clk *clk_ephy;
+	struct clk *clk_ephycgu;
 };
 
 static int ltq_etop_mdio_wr(struct mii_bus *bus, int phy_addr,
@@ -281,16 +287,27 @@ ltq_etop_hw_exit(struct net_device *dev)
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 	int i;
 
-	ltq_pmu_disable(PMU_PPE);
+	clk_disable(priv->clk_ppe);
+
+	if (ltq_has_gbit())
+		clk_disable(priv->clk_switch);
+
+	if (ltq_is_ase()) {
+		clk_disable(priv->clk_ephy);
+		clk_disable(priv->clk_ephycgu);
+	}
+
 	for (i = 0; i < MAX_DMA_CHAN; i++)
 		if (IS_TX(i) || IS_RX(i))
 			ltq_etop_free_channel(dev, &priv->ch[i]);
 }
 
 static void
-ltq_etop_gbit_init(void)
+ltq_etop_gbit_init(struct net_device *dev)
 {
-	ltq_pmu_enable(PMU_SWITCH);
+	struct ltq_etop_priv *priv = netdev_priv(dev);
+
+	clk_enable(priv->clk_switch);
 
 	ltq_gbit_w32_mask(0, GCTL0_SE, LTQ_GBIT_GCTL0);
 	/** Disable MDIO auto polling mode */
@@ -313,10 +330,10 @@ ltq_etop_hw_init(struct net_device *dev)
 	int err = 0;
 	int i;
 
-	ltq_pmu_enable(PMU_PPE);
+	clk_enable(priv->clk_ppe);
 
 	if (ltq_has_gbit()) {
-		ltq_etop_gbit_init();
+		ltq_etop_gbit_init(dev);
 		/* force the etops link to the gbit to MII */
 		mii_mode = PHY_INTERFACE_MODE_MII;
 	}
@@ -334,11 +351,11 @@ ltq_etop_hw_init(struct net_device *dev)
 
 	default:
 		if (ltq_is_ase()) {
-			ltq_pmu_enable(PMU_EPHY);
+			clk_enable(priv->clk_ephy);
 			/* disable external MII */
 			ltq_etop_w32_mask(0, ETOP_CFG_MII0, LTQ_ETOP_CFG);
 			/* enable clock for internal PHY */
-			ltq_cgu_enable(CGU_EPHY);
+			clk_enable(priv->clk_ephycgu);
 			/* we need to write this magic to the internal phy to
 			   make it work */
 			ltq_etop_mdio_wr(NULL, 0x8, 0x12, 0xC020);
@@ -886,6 +903,22 @@ ltq_etop_probe(struct platform_device *pdev)
 	priv->pdev = pdev;
 	priv->pldata = dev_get_platdata(&pdev->dev);
 	priv->netdev = dev;
+
+	priv->clk_ppe = clk_get(&pdev->dev, NULL);
+	if (!priv->clk_ppe)
+		return -ENOENT;
+	if (ltq_has_gbit()) {
+		priv->clk_switch = clk_get(&pdev->dev, "switch");
+		if (!priv->clk_switch)
+			return -ENOENT;
+	}
+	if (ltq_is_ase()) {
+		priv->clk_ephy = clk_get(&pdev->dev, "ephy");
+		priv->clk_ephycgu = clk_get(&pdev->dev, "ephycgu");
+		if (!priv->clk_ephy || !priv->clk_ephycgu)
+			return -ENOENT;
+	}
+
 	spin_lock_init(&priv->lock);
 
 	for (i = 0; i < MAX_DMA_CHAN; i++) {
-- 
1.7.7.1
