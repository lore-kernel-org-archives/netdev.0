From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 1/2] net: davinci_mdio: add GPIO reset logic
Date: Mon, 13 Mar 2017 15:42:33 +0200
Message-ID: <1489412554-2054-2-git-send-email-rogerq@ti.com>
References: <1489412554-2054-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <grygorii.strashko@ti.com>, <nsekhar@ti.com>, <jsarha@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Roger Quadros <rogerq@ti.com>
To: <davem@davemloft.net>, <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:10513 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752951AbdCMNmq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 09:42:46 -0400
In-Reply-To: <1489412554-2054-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards [1] leave the PHYs at an invalid state
during system power-up or reset thus causing unreliability
issues with the PHY like not being detected by the mdio bus
or link not functional. To work around these boards have
a GPIO connected to the PHY's reset pin.

Implement GPIO reset handling for such cases.

[1] - am572x-idk, am571x-idk, a437x-idk.

Signed-off-by: Roger Quadros <rogerq@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 .../devicetree/bindings/net/davinci-mdio.txt       |  2 +
 drivers/net/ethernet/ti/davinci_mdio.c             | 68 +++++++++++++++++++---
 2 files changed, 62 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/davinci-mdio.txt b/Documentation/devicetree/bindings/net/davinci-mdio.txt
index 621156c..fd6ebe7 100644
--- a/Documentation/devicetree/bindings/net/davinci-mdio.txt
+++ b/Documentation/devicetree/bindings/net/davinci-mdio.txt
@@ -12,6 +12,8 @@ Required properties:
 
 Optional properties:
 - ti,hwmods		: Must be "davinci_mdio"
+- reset-gpios		: array of GPIO specifier for PHY hardware reset control
+- reset-delay-us	: reset assertion time [in microseconds]
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 33df340..c6f9e55 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -40,6 +40,9 @@
 #include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/pinctrl/consumer.h>
+#include <linux/gpio.h>
+#include <linux/gpio/consumer.h>
+#include <linux/of_gpio.h>
 
 /*
  * This timeout definition is a worst-case ultra defensive measure against
@@ -53,6 +56,8 @@
 
 #define DEF_OUT_FREQ		2200000		/* 2.2 MHz */
 
+#define DEFAULT_GPIO_RESET_DELAY	10	/* in microseconds */
+
 struct davinci_mdio_of_param {
 	int autosuspend_delay_ms;
 };
@@ -104,6 +109,9 @@ struct davinci_mdio_data {
 	 */
 	bool		skip_scan;
 	u32		clk_div;
+	struct gpio_desc **gpio_reset;
+	int		num_gpios;
+	int		reset_delay_us;
 };
 
 static void davinci_mdio_init_clk(struct davinci_mdio_data *data)
@@ -142,6 +150,20 @@ static void davinci_mdio_enable(struct davinci_mdio_data *data)
 	__raw_writel(data->clk_div | CONTROL_ENABLE, &data->regs->control);
 }
 
+static void __davinci_gpio_reset(struct davinci_mdio_data *data)
+{
+	int i;
+
+	for (i = 0; i < data->num_gpios; i++) {
+		if (!data->gpio_reset[i])
+			continue;
+
+		gpiod_set_value_cansleep(data->gpio_reset[i], 1);
+		udelay(data->reset_delay_us);
+		gpiod_set_value_cansleep(data->gpio_reset[i], 0);
+	}
+}
+
 static int davinci_mdio_reset(struct mii_bus *bus)
 {
 	struct davinci_mdio_data *data = bus->priv;
@@ -317,20 +339,50 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 }
 
 #if IS_ENABLED(CONFIG_OF)
-static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
-			 struct platform_device *pdev)
+static int davinci_mdio_probe_dt(struct davinci_mdio_data *data,
+				 struct platform_device *pdev)
 {
 	struct device_node *node = pdev->dev.of_node;
 	u32 prop;
-
-	if (!node)
-		return -EINVAL;
+	int error;
+	int i;
+	struct gpio_desc *gpiod;
 
 	if (of_property_read_u32(node, "bus_freq", &prop)) {
 		dev_err(&pdev->dev, "Missing bus_freq property in the DT.\n");
-		return -EINVAL;
+		data->pdata = default_pdata;
+	} else {
+		data->pdata.bus_freq = prop;
+	}
+
+	i = of_gpio_named_count(node, "reset-gpios");
+	if (i > 0) {
+		data->num_gpios = i;
+		data->gpio_reset = devm_kcalloc(&pdev->dev, i,
+						sizeof(struct gpio_desc *),
+						GFP_KERNEL);
+		if (!data->gpio_reset)
+			return -ENOMEM;
+
+		for (i = 0; i < data->num_gpios; i++) {
+			gpiod = devm_gpiod_get_index(&pdev->dev, "reset", i,
+						     GPIOD_OUT_LOW);
+			if (IS_ERR(gpiod)) {
+				error = PTR_ERR(gpiod);
+				if (error == -ENOENT)
+					continue;
+				else
+					return error;
+			}
+			data->gpio_reset[i] = gpiod;
+		}
+
+		if (of_property_read_u32(node, "reset-delay-us",
+					 &data->reset_delay_us))
+			data->reset_delay_us = DEFAULT_GPIO_RESET_DELAY;
+
+		__davinci_gpio_reset(data);
 	}
-	data->bus_freq = prop;
 
 	return 0;
 }
@@ -372,7 +424,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	if (dev->of_node) {
 		const struct of_device_id	*of_id;
 
-		ret = davinci_mdio_probe_dt(&data->pdata, pdev);
+		ret = davinci_mdio_probe_dt(data, pdev);
 		if (ret)
 			return ret;
 		snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
-- 
2.7.4
