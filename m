From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: mdio-gpio: Convert to use gpiod functions where possible
Date: Wed, 11 Jan 2017 12:59:50 -0800
Message-ID: <20170111205951.32363-3-f.fainelli@gmail.com>
References: <20170111205951.32363-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        linux@roeck-us.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35698 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757731AbdAKVAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:00:41 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so14668809pfa.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 13:00:40 -0800 (PST)
In-Reply-To: <20170111205951.32363-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Using gpiod functions lets us use functionality which is not available
with gpio functions.

There is no gpiod function to match devm_gpio_request_one, so leave it
in place and use gpio_to_desc() to convert absolute pin numbers to gpio
descriptors.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-gpio.c | 43 +++++++++++++++++++++----------------------
 1 file changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index f6e773256c82..e62fcea2d945 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -32,7 +32,7 @@
 
 struct mdio_gpio_info {
 	struct mdiobb_ctrl ctrl;
-	int mdc, mdio, mdo;
+	struct gpio_desc *mdc, *mdio, *mdo;
 	int mdc_active_low, mdio_active_low, mdo_active_low;
 };
 
@@ -80,16 +80,15 @@ static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 		 * assume the pin serves as pull-up. If direction is
 		 * output, the default value is high.
 		 */
-		gpio_set_value_cansleep(bitbang->mdo,
-					1 ^ bitbang->mdo_active_low);
+		gpiod_set_value(bitbang->mdo, 1 ^ bitbang->mdo_active_low);
 		return;
 	}
 
 	if (dir)
-		gpio_direction_output(bitbang->mdio,
-				      1 ^ bitbang->mdio_active_low);
+		gpiod_direction_output(bitbang->mdio,
+				       1 ^ bitbang->mdio_active_low);
 	else
-		gpio_direction_input(bitbang->mdio);
+		gpiod_direction_input(bitbang->mdio);
 }
 
 static int mdio_get(struct mdiobb_ctrl *ctrl)
@@ -97,8 +96,7 @@ static int mdio_get(struct mdiobb_ctrl *ctrl)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	return gpio_get_value_cansleep(bitbang->mdio) ^
-		bitbang->mdio_active_low;
+	return gpiod_get_value(bitbang->mdio) ^ bitbang->mdio_active_low;
 }
 
 static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
@@ -107,11 +105,9 @@ static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
 	if (bitbang->mdo)
-		gpio_set_value_cansleep(bitbang->mdo,
-					what ^ bitbang->mdo_active_low);
+		gpiod_set_value(bitbang->mdo, what ^ bitbang->mdo_active_low);
 	else
-		gpio_set_value_cansleep(bitbang->mdio,
-					what ^ bitbang->mdio_active_low);
+		gpiod_set_value(bitbang->mdio, what ^ bitbang->mdio_active_low);
 }
 
 static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
@@ -119,7 +115,7 @@ static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	gpio_set_value_cansleep(bitbang->mdc, what ^ bitbang->mdc_active_low);
+	gpiod_set_value(bitbang->mdc, what ^ bitbang->mdc_active_low);
 }
 
 static struct mdiobb_ops mdio_gpio_ops = {
@@ -137,6 +133,7 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 	struct mii_bus *new_bus;
 	struct mdio_gpio_info *bitbang;
 	int i;
+	int mdc, mdio, mdo;
 	unsigned long mdc_flags = GPIOF_OUT_INIT_LOW;
 	unsigned long mdio_flags = GPIOF_DIR_IN;
 	unsigned long mdo_flags = GPIOF_OUT_INIT_HIGH;
@@ -147,11 +144,15 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 
 	bitbang->ctrl.ops = &mdio_gpio_ops;
 	bitbang->ctrl.reset = pdata->reset;
-	bitbang->mdc = pdata->mdc;
+	mdc = pdata->mdc;
+	bitbang->mdc = gpio_to_desc(mdc);
 	bitbang->mdc_active_low = pdata->mdc_active_low;
-	bitbang->mdio = pdata->mdio;
+	mdio = pdata->mdio;
+	bitbang->mdio = gpio_to_desc(mdio);
 	bitbang->mdio_active_low = pdata->mdio_active_low;
-	bitbang->mdo = pdata->mdo;
+	mdo = pdata->mdo;
+	if (mdo)
+		bitbang->mdo = gpio_to_desc(mdo);
 	bitbang->mdo_active_low = pdata->mdo_active_low;
 
 	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
@@ -177,16 +178,14 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 	else
 		strncpy(new_bus->id, "gpio", MII_BUS_ID_SIZE);
 
-	if (devm_gpio_request_one(dev, bitbang->mdc, mdc_flags, "mdc"))
+	if (devm_gpio_request_one(dev, mdc, mdc_flags, "mdc"))
 		goto out_free_bus;
 
-	if (devm_gpio_request_one(dev, bitbang->mdio, mdio_flags, "mdio"))
+	if (devm_gpio_request_one(dev, mdio, mdio_flags, "mdio"))
 		goto out_free_bus;
 
-	if (bitbang->mdo) {
-		if (devm_gpio_request_one(dev, bitbang->mdo, mdo_flags, "mdo"))
-			goto out_free_bus;
-	}
+	if (mdo && devm_gpio_request_one(dev, mdo, mdo_flags, "mdo"))
+		goto out_free_bus;
 
 	dev_set_drvdata(dev, new_bus);
 
-- 
2.9.3
