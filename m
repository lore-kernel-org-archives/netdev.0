From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: [PATCH 2/2] arc_emac: add clock handling
Date: Wed, 23 Apr 2014 14:24:55 +0200
Message-ID: <21852569.EUtq6ntoe2@phil>
References: <2479609.DglKFY1Bsn@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org, Max Schwarz <max.schwarz@online.de>,
	devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:33729 "EHLO gloria.sntech.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411AbaDWMXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 08:23:05 -0400
In-Reply-To: <2479609.DglKFY1Bsn@phil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ability for the arc_emac to really handle its supplying clock.
To get the needed clock-frequency either a real clock or the previous
clock-frequency property must be provided.

Signed-off-by: Heiko Stuebner <heiko@sntech.de>
---
 Documentation/devicetree/bindings/net/arc_emac.txt | 12 +++++-
 drivers/net/ethernet/arc/emac.h                    |  2 +
 drivers/net/ethernet/arc/emac_main.c               | 46 ++++++++++++++++------
 3 files changed, 47 insertions(+), 13 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/arc_emac.txt b/Documentation/devicetree/bindings/net/arc_emac.txt
index 7fbb027..a1d71eb 100644
--- a/Documentation/devicetree/bindings/net/arc_emac.txt
+++ b/Documentation/devicetree/bindings/net/arc_emac.txt
@@ -4,11 +4,15 @@ Required properties:
 - compatible: Should be "snps,arc-emac"
 - reg: Address and length of the register set for the device
 - interrupts: Should contain the EMAC interrupts
-- clock-frequency: CPU frequency. It is needed to calculate and set polling
-period of EMAC.
 - max-speed: see ethernet.txt file in the same directory.
 - phy: see ethernet.txt file in the same directory.
 
+Clock handling:
+The clock frequency is needed to calculate and set polling period of EMAC.
+It must be provided by one of:
+- clock-frequency: CPU frequency.
+- clocks: reference to the clock supplying the EMAC.
+
 Child nodes of the driver are the individual PHY devices connected to the
 MDIO bus. They must have a "reg" property given the PHY address on the MDIO bus.
 
@@ -19,7 +23,11 @@ Examples:
 		reg = <0xc0fc2000 0x3c>;
 		interrupts = <6>;
 		mac-address = [ 00 11 22 33 44 55 ];
+
 		clock-frequency = <80000000>;
+		/* or */
+		clocks = <&emac_clock>;
+
 		max-speed = <100>;
 		phy = <&phy0>;
 
diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index 928fac6..53f85bf 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -11,6 +11,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
+#include <linux/clk.h>
 
 /* STATUS and ENABLE Register bit masks */
 #define TXINT_MASK	(1<<0)	/* Transmit interrupt */
@@ -131,6 +132,7 @@ struct arc_emac_priv {
 	struct mii_bus *bus;
 
 	void __iomem *regs;
+	struct clk *clk;
 
 	struct napi_struct napi;
 	struct net_device_stats stats;
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 0cba97a..68f8ad5 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -649,13 +649,6 @@ static int arc_emac_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	/* Get CPU clock frequency from device tree */
-	if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
-				 &clock_frequency)) {
-		dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from device tree\n");
-		return -EINVAL;
-	}
-
 	/* Get IRQ from device tree */
 	irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
 	if (!irq) {
@@ -687,13 +680,32 @@ static int arc_emac_probe(struct platform_device *pdev)
 	}
 	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs);
 
+	priv->clk = of_clk_get(pdev->dev.of_node, 0);
+	if (IS_ERR(priv->clk)) {
+		/* Get CPU clock frequency from device tree */
+		if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
+					&clock_frequency)) {
+			dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from device tree\n");
+			err = -EINVAL;
+			goto out_netdev;
+		}
+	} else {
+		err = clk_prepare_enable(priv->clk);
+		if (err) {
+			dev_err(&pdev->dev, "failed to enable clock\n");
+			goto out_clkget;
+		}
+
+		clock_frequency = clk_get_rate(priv->clk);
+	}
+
 	id = arc_reg_get(priv, R_ID);
 
 	/* Check for EMAC revision 5 or 7, magic number */
 	if (!(id == 0x0005fd02 || id == 0x0007fd02)) {
 		dev_err(&pdev->dev, "ARC EMAC not detected, id=0x%x\n", id);
 		err = -ENODEV;
-		goto out_netdev;
+		goto out_clken;
 	}
 	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
 
@@ -708,7 +720,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 			       ndev->name, ndev);
 	if (err) {
 		dev_err(&pdev->dev, "could not allocate IRQ\n");
-		goto out_netdev;
+		goto out_clken;
 	}
 
 	/* Get MAC address from device tree */
@@ -729,7 +741,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (!priv->rxbd) {
 		dev_err(&pdev->dev, "failed to allocate data buffers\n");
 		err = -ENOMEM;
-		goto out_netdev;
+		goto out_clken;
 	}
 
 	priv->txbd = priv->rxbd + RX_BD_NUM;
@@ -741,7 +753,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	err = arc_mdio_probe(pdev, priv);
 	if (err) {
 		dev_err(&pdev->dev, "failed to probe MII bus\n");
-		goto out_netdev;
+		goto out_clken;
 	}
 
 	priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
@@ -772,6 +784,12 @@ out_netif_api:
 	priv->phy_dev = NULL;
 out_mdio:
 	arc_mdio_remove(priv);
+out_clken:
+	if (IS_ERR(priv->clk))
+		clk_disable_unprepare(priv->clk);
+out_clkget:
+	if (IS_ERR(priv->clk))
+		clk_put(priv->clk);
 out_netdev:
 	free_netdev(ndev);
 	return err;
@@ -787,6 +805,12 @@ static int arc_emac_remove(struct platform_device *pdev)
 	arc_mdio_remove(priv);
 	unregister_netdev(ndev);
 	netif_napi_del(&priv->napi);
+
+	if (!IS_ERR(priv->clk)) {
+		clk_disable_unprepare(priv->clk);
+		clk_put(priv->clk);
+	}
+
 	free_netdev(ndev);
 
 	return 0;
-- 
1.9.0
