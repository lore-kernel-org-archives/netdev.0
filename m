From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 02/10] ftgmac100: Use device "compatible" property, not machine.
Date: Wed, 12 Apr 2017 13:27:02 +1000
Message-ID: <20170412032710.17546-3-benh@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41863 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752731AbdDLD1p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:27:45 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We test for aspeed chips to handle a couple of special cases,
but we do that by checking the machine type which isn't right.

Instead check the actual device compatible property. This also
updates the dtsi files for the aspeed SoC to match.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/arm/boot/dts/aspeed-g4.dtsi         |  4 ++--
 arch/arm/boot/dts/aspeed-g5.dtsi         |  4 ++--
 drivers/net/ethernet/faraday/ftgmac100.c | 16 +++++++++-------
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/arch/arm/boot/dts/aspeed-g4.dtsi b/arch/arm/boot/dts/aspeed-g4.dtsi
index 0b4932c..6068e79 100644
--- a/arch/arm/boot/dts/aspeed-g4.dtsi
+++ b/arch/arm/boot/dts/aspeed-g4.dtsi
@@ -42,7 +42,7 @@
 		};
 
 		mac0: ethernet@1e660000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2400-mac", "faraday,ftgmac100";
 			reg = <0x1e660000 0x180>;
 			interrupts = <2>;
 			no-hw-checksum;
@@ -50,7 +50,7 @@
 		};
 
 		mac1: ethernet@1e680000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2400-mac", "faraday,ftgmac100";
 			reg = <0x1e680000 0x180>;
 			interrupts = <3>;
 			no-hw-checksum;
diff --git a/arch/arm/boot/dts/aspeed-g5.dtsi b/arch/arm/boot/dts/aspeed-g5.dtsi
index b664fe3..4dbe91a 100644
--- a/arch/arm/boot/dts/aspeed-g5.dtsi
+++ b/arch/arm/boot/dts/aspeed-g5.dtsi
@@ -33,7 +33,7 @@
 		};
 
 		mac0: ethernet@1e660000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
 			reg = <0x1e660000 0x180>;
 			interrupts = <2>;
 			no-hw-checksum;
@@ -41,7 +41,7 @@
 		};
 
 		mac1: ethernet@1e680000 {
-			compatible = "faraday,ftgmac100";
+			compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
 			reg = <0x1e680000 0x180>;
 			interrupts = <3>;
 			no-hw-checksum;
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index bfa7d0a..6a4fed6 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -90,6 +90,7 @@ struct ftgmac100 {
 
 	/* Misc */
 	bool need_mac_restart;
+	bool is_aspeed;
 };
 
 static void ftgmac100_set_rx_ring_base(struct ftgmac100 *priv, dma_addr_t addr)
@@ -1320,8 +1321,7 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 	if (!priv->mii_bus)
 		return -EIO;
 
-	if (of_machine_is_compatible("aspeed,ast2400") ||
-	    of_machine_is_compatible("aspeed,ast2500")) {
+	if (priv->is_aspeed) {
 		/* This driver supports the old MDIO interface */
 		reg = ioread32(priv->base + FTGMAC100_OFFSET_REVR);
 		reg &= ~FTGMAC100_REVR_NEW_MDIO_INTERFACE;
@@ -1386,6 +1386,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	int irq;
 	struct net_device *netdev;
 	struct ftgmac100 *priv;
+	struct device_node *np;
 	int err = 0;
 
 	if (!pdev)
@@ -1441,17 +1442,18 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	/* MAC address from chip or random one */
 	ftgmac100_setup_mac(priv);
 
-	if (of_machine_is_compatible("aspeed,ast2400") ||
-	    of_machine_is_compatible("aspeed,ast2500")) {
+	np = pdev->dev.of_node;
+	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac") ||
+		   of_device_is_compatible(np, "aspeed,ast2500-mac"))) {
 		priv->rxdes0_edorr_mask = BIT(30);
 		priv->txdes0_edotr_mask = BIT(30);
+		priv->is_aspeed = true;
 	} else {
 		priv->rxdes0_edorr_mask = BIT(15);
 		priv->txdes0_edotr_mask = BIT(15);
 	}
 
-	if (pdev->dev.of_node &&
-	    of_get_property(pdev->dev.of_node, "use-ncsi", NULL)) {
+	if (np && of_get_property(np, "use-ncsi", NULL)) {
 		if (!IS_ENABLED(CONFIG_NET_NCSI)) {
 			dev_err(&pdev->dev, "NCSI stack not enabled\n");
 			goto err_ncsi_dev;
@@ -1476,7 +1478,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	netdev->features = NETIF_F_RXCSUM | NETIF_F_HW_CSUM |
 		NETIF_F_GRO | NETIF_F_SG;
 	if (priv->use_ncsi &&
-	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
+	    of_get_property(np, "no-hw-checksum", NULL))
 		netdev->features &= ~NETIF_F_HW_CSUM;
 
 	/* register network device */
-- 
2.9.3
