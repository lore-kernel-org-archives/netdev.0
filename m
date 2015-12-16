From: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v3] net/macb: add support for resetting PHY using GPIO
Date: Wed, 16 Dec 2015 19:31:30 +0100
Message-ID: <1450290690-32369-1-git-send-email-gregory.clement@free-electrons.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

With device tree it is no more possible to reset the PHY at board
level. Furthermore, doing in the driver allow to power down the PHY when
the network interface is no more used.

This reset can't be done at the PHY driver level. The PHY must be able to
answer to the mii bus scan to let the kernel creating a PHY device.

The patch introduces a new optional property "reset-gpios" at PHY level.

Signed-off-by: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
Hi,

I agree with Sasha to start with a good binding and indeed the reset
is more related to the PHY than to the MAC even if currently we have
to manipulate it at MAC level.

I also followed Russell advice to not use fwnode functions. However
the following code seems to work:

        struct fwnode_handle *phy_node =
		device_get_next_child_node(&pdev->dev, NULL);
        bp->reset_gpio = fwnode_get_named_gpiod(phy_node, "reset-gpios");
        if (IS_ERR)
		bp->reset_gpio = NULL;
        gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);

Given that it doesn't make the code better I kept the of_get_named_gpio method.

Gregory

Documentation/devicetree/bindings/net/macb.txt |  7 +++++++
 drivers/net/ethernet/cadence/macb.c            | 16 ++++++++++++++++
 drivers/net/ethernet/cadence/macb.h            |  1 +
 3 files changed, 24 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5d7976..38c8e84 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -19,6 +19,9 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties for PHY child node:
+- reset-gpios : Should specify the gpio for phy reset
+
 Examples:
 
 	macb0: ethernet@fffc4000 {
@@ -29,4 +32,8 @@ Examples:
 		local-mac-address = [3a 0e 03 04 05 06];
 		clock-names = "pclk", "hclk", "tx_clk";
 		clocks = <&clkc 30>, <&clkc 30>, <&clkc 13>;
+		ethernet-phy@1 {
+			reg = <0x1>;
+			reset-gpios = <&pioE 6 1>;
+		};
 	};
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 88c1e1a..35661aa 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -28,6 +28,7 @@
 #include <linux/phy.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
 
@@ -2813,6 +2814,7 @@ static int macb_probe(struct platform_device *pdev)
 					      = macb_clk_init;
 	int (*init)(struct platform_device *) = macb_init;
 	struct device_node *np = pdev->dev.of_node;
+	struct device_node *phy_node;
 	const struct macb_config *macb_config = NULL;
 	struct clk *pclk, *hclk, *tx_clk;
 	unsigned int queue_mask, num_queues;
@@ -2900,6 +2902,16 @@ static int macb_probe(struct platform_device *pdev)
 	else
 		macb_get_hwaddr(bp);
 
+	/* Power up the PHY if there is a GPIO reset */
+	phy_node =  of_get_next_available_child(np, NULL);
+	if (phy_node) {
+		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
+		if (gpio_is_valid(gpio))
+			bp->reset_gpio = gpio_to_desc(gpio);
+		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);
+	}
+	of_node_put(phy_node);
+
 	err = of_get_phy_mode(np);
 	if (err < 0) {
 		pdata = dev_get_platdata(&pdev->dev);
@@ -2966,6 +2978,10 @@ static int macb_remove(struct platform_device *pdev)
 		mdiobus_unregister(bp->mii_bus);
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
+
+		/* Shutdown the PHY if there is a GPIO reset */
+		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_LOW);
+
 		unregister_netdev(dev);
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 6e1faea..b6ec421 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -824,6 +824,7 @@ struct macb {
 	unsigned int		dma_burst_length;
 
 	phy_interface_t		phy_interface;
+	struct gpio_desc	*reset_gpio;
 
 	/* AT91RM9200 transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
