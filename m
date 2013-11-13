From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH 3/3] can: mcp251x: Add device tree support
Date: Wed, 13 Nov 2013 12:45:41 +0400
Message-ID: <1384332341-15363-1-git-send-email-shc_work@mail.ru>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Alexander Shiyan <shc_work@mail.ru>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp26.mail.ru ([94.100.176.179]:40319 "EHLO smtp26.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758517Ab3KMIpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 03:45:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds Device Tree support to the Microchip MCP251X driver.

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 .../bindings/net/can/microchip,mcp251x.txt         | 25 ++++++++++
 drivers/net/can/mcp251x.c                          | 57 ++++++++++++++++------
 2 files changed, 66 insertions(+), 16 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/microchip,mcp251x.txt

diff --git a/Documentation/devicetree/bindings/net/can/microchip,mcp251x.txt b/Documentation/devicetree/bindings/net/can/microchip,mcp251x.txt
new file mode 100644
index 0000000..06d95ee
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/microchip,mcp251x.txt
@@ -0,0 +1,25 @@
+* Microchip MCP251X device tree bindings
+
+Registers a Microchip MCP251X stand-alone CAN controller connected to SPI bus.
+
+Required properties:
+ - compatible: Should be one of the following:
+   - "microchip,mcp2510" for MCP2510.
+   - "microchip,mcp2515" for MCP2515.
+ - reg: SPI chip select.
+ - clocks: The clock feeding the CAN controller.
+ - interrupt-parent: The parent interrupt controller.
+ - interrupts: Should contain IRQ line for the CAN controller.
+
+Optional properties:
+ - vdd-supply: Regulator that powers the CAN controller.
+ - xceiver-supply: Regulator that powers the CAN transceiver.
+
+Example:
+	can0: can@1 {
+		compatible = "microchip,mcp2515";
+		reg = <1>;
+		clocks = <&clk24m>;
+		interrupt-parent = <&gpio4>;
+		interrupts = <13 0x2>;
+	};
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 8e133aa..9aa2822 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -60,6 +60,8 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
 #include <linux/platform_device.h>
 #include <linux/slab.h>
 #include <linux/spi/spi.h>
@@ -987,10 +989,38 @@ static const struct net_device_ops mcp251x_netdev_ops = {
 	.ndo_start_xmit = mcp251x_hard_start_xmit,
 };
 
+static struct of_device_id mcp251x_of_match[] = {
+	{
+		.compatible	= "microchip,mcp2510",
+		.data		= (void *)CAN_MCP251X_MCP2510,
+	},
+	{
+		.compatible	= "microchip,mcp2515",
+		.data		= (void *)CAN_MCP251X_MCP2515,
+	},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, mcp251x_of_match);
+
+static const struct spi_device_id mcp251x_id_table[] = {
+	{
+		.name		= "mcp2510",
+		.driver_data	= (kernel_ulong_t)CAN_MCP251X_MCP2510,
+	},
+	{
+		.name		= "mcp2515",
+		.driver_data	= (kernel_ulong_t)CAN_MCP251X_MCP2515,
+	},
+	{ }
+};
+MODULE_DEVICE_TABLE(spi, mcp251x_id_table);
+
 static int mcp251x_can_probe(struct spi_device *spi)
 {
 	struct net_device *net;
 	struct mcp251x_priv *priv;
+	const struct of_device_id *of_id = of_match_device(mcp251x_of_match,
+							   &spi->dev);
 	int ret;
 
 	/* Allocate can/net device */
@@ -1017,7 +1047,10 @@ static int mcp251x_can_probe(struct spi_device *spi)
 	priv->can.clock.freq = clk_get_rate(priv->clk) / 2;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
 		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
-	priv->model = spi_get_device_id(spi)->driver_data;
+	if (of_id)
+		priv->model = (enum mcp251x_model)of_id->data;
+	else
+		priv->model = spi_get_device_id(spi)->driver_data;
 	priv->net = net;
 
 	priv->power = devm_regulator_get(&spi->dev, "vdd");
@@ -1198,24 +1231,16 @@ static int mcp251x_can_resume(struct device *dev)
 static SIMPLE_DEV_PM_OPS(mcp251x_can_pm_ops, mcp251x_can_suspend,
 	mcp251x_can_resume);
 
-static const struct spi_device_id mcp251x_id_table[] = {
-	{ "mcp2510",	CAN_MCP251X_MCP2510 },
-	{ "mcp2515",	CAN_MCP251X_MCP2515 },
-	{ },
-};
-
-MODULE_DEVICE_TABLE(spi, mcp251x_id_table);
-
 static struct spi_driver mcp251x_can_driver = {
 	.driver = {
-		.name = DEVICE_NAME,
-		.owner = THIS_MODULE,
-		.pm = &mcp251x_can_pm_ops,
+		.name		= DEVICE_NAME,
+		.owner		= THIS_MODULE,
+		.of_match_table	= of_match_ptr(mcp251x_of_match),
+		.pm		= &mcp251x_can_pm_ops,
 	},
-
-	.id_table = mcp251x_id_table,
-	.probe = mcp251x_can_probe,
-	.remove = mcp251x_can_remove,
+	.id_table	= mcp251x_id_table,
+	.probe		= mcp251x_can_probe,
+	.remove		= mcp251x_can_remove,
 };
 module_spi_driver(mcp251x_can_driver);
 
-- 
1.8.1.5
