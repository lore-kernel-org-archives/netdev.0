From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 2/3] net: mdio-gpio: Add support for active low gpio pins
Date: Tue, 15 Apr 2014 19:16:41 -0700
Message-ID: <1397614602-29694-3-git-send-email-linux@roeck-us.net>
References: <1397614602-29694-1-git-send-email-linux@roeck-us.net>
Cc: Chris Healy <chealy@imsco-us.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397614602-29694-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some systems using mdio-gpio may use active-low gpio pins
(eg with inverters or FETs connected to all or some of the
gpio pins).

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/phy/mdio-gpio.c |   19 +++++++++++++------
 include/linux/mdio-gpio.h   |    3 +++
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index e853066..fac211a 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -33,28 +33,32 @@
 struct mdio_gpio_info {
 	struct mdiobb_ctrl ctrl;
 	int mdc, mdio;
+	int mdc_active_low, mdio_active_low;
 };
 
 static void *mdio_gpio_of_get_data(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct mdio_gpio_platform_data *pdata;
+	enum of_gpio_flags flags;
 	int ret;
 
 	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
 	if (!pdata)
 		return NULL;
 
-	ret = of_get_gpio(np, 0);
+	ret = of_get_gpio_flags(np, 0, &flags);
 	if (ret < 0)
 		return NULL;
 
 	pdata->mdc = ret;
+	pdata->mdc_active_low = flags & OF_GPIO_ACTIVE_LOW;
 
-	ret = of_get_gpio(np, 1);
+	ret = of_get_gpio_flags(np, 1, &flags);
 	if (ret < 0)
 		return NULL;
 	pdata->mdio = ret;
+	pdata->mdio_active_low = flags & OF_GPIO_ACTIVE_LOW;
 
 	return pdata;
 }
@@ -65,7 +69,8 @@ static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
 	if (dir)
-		gpio_direction_output(bitbang->mdio, 1);
+		gpio_direction_output(bitbang->mdio,
+				      1 ^ bitbang->mdio_active_low);
 	else
 		gpio_direction_input(bitbang->mdio);
 }
@@ -75,7 +80,7 @@ static int mdio_get(struct mdiobb_ctrl *ctrl)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	return gpio_get_value(bitbang->mdio);
+	return gpio_get_value(bitbang->mdio) ^ bitbang->mdio_active_low;
 }
 
 static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
@@ -83,7 +88,7 @@ static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	gpio_set_value(bitbang->mdio, what);
+	gpio_set_value(bitbang->mdio, what ^ bitbang->mdio_active_low);
 }
 
 static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
@@ -91,7 +96,7 @@ static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	gpio_set_value(bitbang->mdc, what);
+	gpio_set_value(bitbang->mdc, what ^ bitbang->mdc_active_low);
 }
 
 static struct mdiobb_ops mdio_gpio_ops = {
@@ -117,7 +122,9 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 	bitbang->ctrl.ops = &mdio_gpio_ops;
 	bitbang->ctrl.reset = pdata->reset;
 	bitbang->mdc = pdata->mdc;
+	bitbang->mdc_active_low = pdata->mdc_active_low;
 	bitbang->mdio = pdata->mdio;
+	bitbang->mdio_active_low = pdata->mdio_active_low;
 
 	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
 	if (!new_bus)
diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
index 7c9fe3c..57e57fe 100644
--- a/include/linux/mdio-gpio.h
+++ b/include/linux/mdio-gpio.h
@@ -18,6 +18,9 @@ struct mdio_gpio_platform_data {
 	unsigned int mdc;
 	unsigned int mdio;
 
+	bool mdc_active_low;
+	bool mdio_active_low;
+
 	unsigned int phy_mask;
 	int irqs[PHY_MAX_ADDR];
 	/* reset callback */
-- 
1.7.9.7
