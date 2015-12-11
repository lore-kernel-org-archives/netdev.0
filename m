From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2] net/macb: add support for resetting PHY using GPIO
Date: Fri, 11 Dec 2015 11:34:53 +0100
Message-ID: <1449830093-29433-1-git-send-email-gregory.clement@free-electrons.com>
Cc: devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With device tree it is no more possible to reset the PHY at board
level. Furthermore, doing in the driver allow to power down the PHY when
the network interface is no more used.

This reset can't be done at the PHY driver level. The PHY must be able to
answer the to the mii bus scan to let the kernel creating a PHY device.

The patch introduces a new optional property "phy-reset-gpios" inspired
from the one use for the FEC.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---

Since the v1, I used the gpiod functions. It allows to simplify the
code and to not introduce any #ifdef.

I also rename the property in phy-reset-gpios, even if actually the
gpiod will match both phy-reset-gpios and phy-reset-gpio.


 Documentation/devicetree/bindings/net/macb.txt | 3 +++
 drivers/net/ethernet/cadence/macb.c            | 8 ++++++++
 drivers/net/ethernet/cadence/macb.h            | 1 +
 3 files changed, 12 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5d7976..4a7fb6c 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -19,6 +19,9 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties:
+- phy-reset-gpios : Should specify the gpio for phy reset
+
 Examples:
 
 	macb0: ethernet@fffc4000 {
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 88c1e1a..71fbda3 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2900,6 +2900,10 @@ static int macb_probe(struct platform_device *pdev)
 	else
 		macb_get_hwaddr(bp);
 
+	/* Power up the PHY if there is a GPIO reset */
+	bp->reset_gpio = devm_gpiod_get_optional(&bp->pdev->dev, "phy-reset",
+						 GPIOD_OUT_HIGH);
+
 	err = of_get_phy_mode(np);
 	if (err < 0) {
 		pdata = dev_get_platdata(&pdev->dev);
@@ -2966,6 +2970,10 @@ static int macb_remove(struct platform_device *pdev)
 		mdiobus_unregister(bp->mii_bus);
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
+
+		/* Shutdown the PHY if there is a GPIO reset */
+		gpiod_set_value(bp->reset_gpio, 0);
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
