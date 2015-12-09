From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Wed,  9 Dec 2015 18:49:43 +0100
Message-ID: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
Cc: devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
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

The patch introduces a new optional property "phy-reset-gpio" inspired
from the one use for the FEC.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 Documentation/devicetree/bindings/net/macb.txt |  3 +++
 drivers/net/ethernet/cadence/macb.c            | 26 ++++++++++++++++++++++++++
 drivers/net/ethernet/cadence/macb.h            |  1 +
 3 files changed, 30 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5d7976..546d34d 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -19,6 +19,9 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties:
+- phy-reset-gpio : Should specify the gpio for phy reset
+
 Examples:
 
 	macb0: ethernet@fffc4000 {
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 88c1e1a..e630c56 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -30,6 +30,7 @@
 #include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
+#include <linux/of_gpio.h>
 
 #include "macb.h"
 
@@ -2733,6 +2734,28 @@ static int at91ether_init(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static void macb_reset_phy(struct macb *bp, struct device_node *np, int state)
+{
+	if (!np)
+		return;
+
+	bp->reset_gpio = of_get_named_gpio(np, "phy-reset-gpio", 0);
+
+	if (gpio_is_valid(bp->reset_gpio))
+		gpio_direction_output(bp->reset_gpio, state);
+}
+#else /* CONFIG_OF */
+static void macb_reset_phy(struct macb *bp, struct device_node *np, int state)
+{
+	/*
+	 * In case of platform probe, the reset has been done
+	 * by machine code.
+	 */
+}
+#endif /* CONFIG_OF */
+
+
 static const struct macb_config at91sam9260_config = {
 	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
 	.clk_init = macb_clk_init,
@@ -2900,6 +2923,8 @@ static int macb_probe(struct platform_device *pdev)
 	else
 		macb_get_hwaddr(bp);
 
+	macb_reset_phy(bp, np, 1);
+
 	err = of_get_phy_mode(np);
 	if (err < 0) {
 		pdata = dev_get_platdata(&pdev->dev);
@@ -2966,6 +2991,7 @@ static int macb_remove(struct platform_device *pdev)
 		mdiobus_unregister(bp->mii_bus);
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
+		macb_reset_phy(bp, pdev->dev.of_node, 0);
 		unregister_netdev(dev);
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 6e1faea..637d22c 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -824,6 +824,7 @@ struct macb {
 	unsigned int		dma_burst_length;
 
 	phy_interface_t		phy_interface;
+	int			reset_gpio;
 
 	/* AT91RM9200 transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
-- 
2.5.0
