From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 2/2] net: flexcan: add transceiver switch gpio support
Date: Tue, 26 Jun 2012 16:49:23 +0800
Message-ID: <1340700563-8386-3-git-send-email-shawn.guo@linaro.org>
References: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:42535
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752066Ab2FZItZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:49:25 -0400
In-Reply-To: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flexcan driver has function pointer transceiver_switch defined in
flexcan_platform_data for platform codes to hook up their transceiver
switch implementation.  However this does not cope with device tree
probe.

It's been observed that platforms mostly use gpio to control the
switch of flexcan transceiver.  The patch adds transceiver switch gpio
support into flexcan driver, so that platforms that have transceiver
switch controlled by gpio can just define property transceiver-switch-gpios
in their device tree, and then device tree boot just works with it.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 .../devicetree/bindings/net/can/fsl-flexcan.txt    |    3 ++
 drivers/net/can/flexcan.c                          |   30 ++++++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
index 8ff324e..5ca91d1 100644
--- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
+++ b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
@@ -15,6 +15,9 @@ Required properties:
 Optional properties:
 
 - clock-frequency : The oscillator frequency driving the flexcan device
+- transceiver-switch-gpios : Should specify the gpio for transceiver switch
+- enable-active-low : Polarity of transceiver switch gpio is active low.
+  If this property is missing, the default assumed is active high.
 
 Example:
 
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 38c0690..bc47595 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -26,6 +26,7 @@
 #include <linux/can/platform/flexcan.h>
 #include <linux/clk.h>
 #include <linux/delay.h>
+#include <linux/gpio.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/interrupt.h>
@@ -34,6 +35,7 @@
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/of.h>
+#include <linux/of_gpio.h>
 #include <linux/platform_device.h>
 #include <linux/pinctrl/consumer.h>
 
@@ -180,6 +182,9 @@ struct flexcan_priv {
 
 	struct clk *clk;
 	struct flexcan_platform_data *pdata;
+
+	int switch_gpio;
+	bool enable_high;
 };
 
 static struct can_bittiming_const flexcan_bittiming_const = {
@@ -224,6 +229,9 @@ static inline void flexcan_write(u32 val, void __iomem *addr)
  */
 static void flexcan_transceiver_switch(const struct flexcan_priv *priv, int on)
 {
+	if (gpio_is_valid(priv->switch_gpio))
+		gpio_set_value(priv->switch_gpio, priv->enable_high ? on : !on);
+
 	if (priv->pdata && priv->pdata->transceiver_switch)
 		priv->pdata->transceiver_switch(on);
 }
@@ -933,6 +941,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	resource_size_t mem_size;
 	int err, irq;
 	u32 clock_freq = 0;
+	int switch_gpio = -EINVAL;
+	bool enable_high = true;
 
 	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
 	if (IS_ERR(pinctrl))
@@ -945,6 +955,23 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 						"clock-frequency", NULL);
 		if (clock_freq_p)
 			clock_freq = *clock_freq_p;
+
+		switch_gpio = of_get_named_gpio(pdev->dev.of_node,
+						"transceiver-switch-gpios", 0);
+		if (gpio_is_valid(switch_gpio)) {
+			err = gpio_request_one(switch_gpio, GPIOF_DIR_OUT,
+					       "transceiver-switch");
+			if (err) {
+				dev_err(&pdev->dev,
+					"failed to request gpio %d: %d\n",
+					switch_gpio, err);
+				goto failed_gpio;
+			}
+
+			if (of_get_property(pdev->dev.of_node,
+					    "enable-active-low", NULL))
+				enable_high = false;
+		}
 	}
 
 	if (!clock_freq) {
@@ -997,6 +1024,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	priv->base = base;
 	priv->dev = dev;
 	priv->clk = clk;
+	priv->switch_gpio = switch_gpio;
+	priv->enable_high = enable_high;
 	priv->pdata = pdev->dev.platform_data;
 
 	netif_napi_add(dev, &priv->napi, flexcan_poll, FLEXCAN_NAPI_WEIGHT);
@@ -1025,6 +1054,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	if (clk)
 		clk_put(clk);
  failed_clock:
+ failed_gpio:
 	return err;
 }
 
-- 
1.7.5.4
