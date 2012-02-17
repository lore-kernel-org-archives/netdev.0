From: John Crispin <blogic@openwrt.org>
Subject: [PATCH 8/9] NET: MIPS: lantiq: convert etop driver to clkdev api
Date: Fri, 17 Feb 2012 11:33:19 +0100
Message-ID: <1329474800-20979-9-git-send-email-blogic@openwrt.org>
References: <1329474800-20979-1-git-send-email-blogic@openwrt.org>
Cc: linux-mips@linux-mips.org, John Crispin <blogic@openwrt.org>,
	netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:38943 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab2BQKdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 05:33:42 -0500
In-Reply-To: <1329474800-20979-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update from old pmu_{dis,en}able() to ckldev api.

Signed-off-by: John Crispin <blogic@openwrt.org>
Cc: netdev@vger.kernel.org
---
This patch should go via MIPS with the rest of the series.

 drivers/net/ethernet/lantiq_etop.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 80ce6d9..fa2580b 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -36,6 +36,7 @@
 #include <linux/io.h>
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
+#include <linux/clk.h>
 
 #include <asm/checksum.h>
 
@@ -278,10 +279,18 @@ ltq_etop_free_channel(struct net_device *dev, struct ltq_etop_chan *ch)
 static void
 ltq_etop_hw_exit(struct net_device *dev)
 {
+	struct clk *clk;
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 	int i;
 
-	ltq_pmu_disable(PMU_PPE);
+	clk = clk_get_sys("ppe", NULL);
+	clk_disable(clk);
+
+	if (ltq_has_gbit()) {
+		clk = clk_get_sys("fpi", "switch");
+		clk_disable(clk);
+	}
+
 	for (i = 0; i < MAX_DMA_CHAN; i++)
 		if (IS_TX(i) || IS_RX(i))
 			ltq_etop_free_channel(dev, &priv->ch[i]);
@@ -290,7 +299,10 @@ ltq_etop_hw_exit(struct net_device *dev)
 static void
 ltq_etop_gbit_init(void)
 {
-	ltq_pmu_enable(PMU_SWITCH);
+	struct clk *clk;
+
+	clk = clk_get_sys("fpi", "switch");
+	clk_enable(clk);
 
 	ltq_gbit_w32_mask(0, GCTL0_SE, LTQ_GBIT_GCTL0);
 	/** Disable MDIO auto polling mode */
@@ -312,8 +324,10 @@ ltq_etop_hw_init(struct net_device *dev)
 	unsigned int mii_mode = priv->pldata->mii_mode;
 	int err = 0;
 	int i;
+	struct clk *clk;
 
-	ltq_pmu_enable(PMU_PPE);
+	clk = clk_get_sys("fpi", "ppe");
+	clk_enable(clk);
 
 	if (ltq_has_gbit()) {
 		ltq_etop_gbit_init();
@@ -334,11 +348,14 @@ ltq_etop_hw_init(struct net_device *dev)
 
 	default:
 		if (ltq_is_ase()) {
-			ltq_pmu_enable(PMU_EPHY);
+			clk = clk_get_sys("fpi", "ephy");
+			clk_enable(clk);
+
 			/* disable external MII */
 			ltq_etop_w32_mask(0, ETOP_CFG_MII0, LTQ_ETOP_CFG);
 			/* enable clock for internal PHY */
-			ltq_cgu_enable(CGU_EPHY);
+			clk = clk_get_sys("fpi", "ephycgu");
+			clk_enable(clk);
 			/* we need to write this magic to the internal phy to
 			   make it work */
 			ltq_etop_mdio_wr(NULL, 0x8, 0x12, 0xC020);
-- 
1.7.7.1
