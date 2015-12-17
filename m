From: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] net/macb: Update device tree binding for resetting PHY using GPIO
Date: Thu, 17 Dec 2015 10:51:04 +0100
Message-ID: <1450345864-10907-1-git-send-email-gregory.clement@free-electrons.com>
References: <874mfhtqnv.fsf@free-electrons.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <874mfhtqnv.fsf-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of being at the MAC level the reset gpio preperty is moved at the
PHY child node level. It is still managed by the MAC, but from the point
of view of the binding it make more sense to be part of the PHY node.

This commit also fixes a build errors if GPIOLIB is not selected.

Signed-off-by: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
 Documentation/devicetree/bindings/net/macb.txt |  8 ++++++--
 drivers/net/ethernet/cadence/macb.c            | 15 ++++++++++++---
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index 4a7fb6c..38c8e84 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -19,8 +19,8 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
-Optional properties:
-- phy-reset-gpios : Should specify the gpio for phy reset
+Optional properties for PHY child node:
+- reset-gpios : Should specify the gpio for phy reset
 
 Examples:
 
@@ -32,4 +32,8 @@ Examples:
 		local-mac-address = [3a 0e 03 04 05 06];
 		clock-names = "pclk", "hclk", "tx_clk";
 		clocks = <&clkc 30>, <&clkc 30>, <&clkc 13>;
+		ethernet-phy@1 {
+			reg = <0x1>;
+			reset-gpios = <&pioE 6 1>;
+		};
 	};
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 71fbda3..12370dd 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 #include <linux/io.h>
 #include <linux/gpio.h>
+#include <linux/gpio/consumer.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -28,6 +29,7 @@
 #include <linux/phy.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
 
@@ -2813,6 +2815,7 @@ static int macb_probe(struct platform_device *pdev)
 					      = macb_clk_init;
 	int (*init)(struct platform_device *) = macb_init;
 	struct device_node *np = pdev->dev.of_node;
+	struct device_node *phy_node;
 	const struct macb_config *macb_config = NULL;
 	struct clk *pclk, *hclk, *tx_clk;
 	unsigned int queue_mask, num_queues;
@@ -2901,8 +2904,14 @@ static int macb_probe(struct platform_device *pdev)
 		macb_get_hwaddr(bp);
 
 	/* Power up the PHY if there is a GPIO reset */
-	bp->reset_gpio = devm_gpiod_get_optional(&bp->pdev->dev, "phy-reset",
-						 GPIOD_OUT_HIGH);
+	phy_node =  of_get_next_available_child(np, NULL);
+	if (phy_node) {
+		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
+		if (gpio_is_valid(gpio))
+			bp->reset_gpio = gpio_to_desc(gpio);
+		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);
+	}
+	of_node_put(phy_node);
 
 	err = of_get_phy_mode(np);
 	if (err < 0) {
@@ -2972,7 +2981,7 @@ static int macb_remove(struct platform_device *pdev)
 		mdiobus_free(bp->mii_bus);
 
 		/* Shutdown the PHY if there is a GPIO reset */
-		gpiod_set_value(bp->reset_gpio, 0);
+		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_LOW);
 
 		unregister_netdev(dev);
 		clk_disable_unprepare(bp->tx_clk);
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
