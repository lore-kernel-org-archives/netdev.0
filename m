From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: mdio-gpio: Use gpio subsystem to handle low-active pins
Date: Wed, 11 Jan 2017 12:59:51 -0800
Message-ID: <20170111205951.32363-4-f.fainelli@gmail.com>
References: <20170111205951.32363-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        linux@roeck-us.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36710 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756918AbdAKVAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:00:48 -0500
Received: by mail-pf0-f193.google.com with SMTP id b22so17212612pfd.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 13:00:42 -0800 (PST)
In-Reply-To: <20170111205951.32363-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

gpiod functions support handling low-active pins, so we can move
thos code out of this driver into the gpio subsystem and simplify
the code a bit.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-gpio.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index e62fcea2d945..7faa79b254ef 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -33,7 +33,6 @@
 struct mdio_gpio_info {
 	struct mdiobb_ctrl ctrl;
 	struct gpio_desc *mdc, *mdio, *mdo;
-	int mdc_active_low, mdio_active_low, mdo_active_low;
 };
 
 static void *mdio_gpio_of_get_data(struct platform_device *pdev)
@@ -80,13 +79,12 @@ static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 		 * assume the pin serves as pull-up. If direction is
 		 * output, the default value is high.
 		 */
-		gpiod_set_value(bitbang->mdo, 1 ^ bitbang->mdo_active_low);
+		gpiod_set_value(bitbang->mdo, 1);
 		return;
 	}
 
 	if (dir)
-		gpiod_direction_output(bitbang->mdio,
-				       1 ^ bitbang->mdio_active_low);
+		gpiod_direction_output(bitbang->mdio, 1);
 	else
 		gpiod_direction_input(bitbang->mdio);
 }
@@ -96,7 +94,7 @@ static int mdio_get(struct mdiobb_ctrl *ctrl)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	return gpiod_get_value(bitbang->mdio) ^ bitbang->mdio_active_low;
+	return gpiod_get_value(bitbang->mdio);
 }
 
 static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
@@ -105,9 +103,9 @@ static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
 	if (bitbang->mdo)
-		gpiod_set_value(bitbang->mdo, what ^ bitbang->mdo_active_low);
+		gpiod_set_value(bitbang->mdo, what);
 	else
-		gpiod_set_value(bitbang->mdio, what ^ bitbang->mdio_active_low);
+		gpiod_set_value(bitbang->mdio, what);
 }
 
 static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
@@ -115,7 +113,7 @@ static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	gpiod_set_value(bitbang->mdc, what ^ bitbang->mdc_active_low);
+	gpiod_set_value(bitbang->mdc, what);
 }
 
 static struct mdiobb_ops mdio_gpio_ops = {
@@ -146,14 +144,18 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 	bitbang->ctrl.reset = pdata->reset;
 	mdc = pdata->mdc;
 	bitbang->mdc = gpio_to_desc(mdc);
-	bitbang->mdc_active_low = pdata->mdc_active_low;
+	if (pdata->mdc_active_low)
+		mdc_flags = GPIOF_OUT_INIT_HIGH | GPIOF_ACTIVE_LOW;
 	mdio = pdata->mdio;
 	bitbang->mdio = gpio_to_desc(mdio);
-	bitbang->mdio_active_low = pdata->mdio_active_low;
+	if (pdata->mdio_active_low)
+		mdio_flags |= GPIOF_ACTIVE_LOW;
 	mdo = pdata->mdo;
-	if (mdo)
+	if (mdo) {
 		bitbang->mdo = gpio_to_desc(mdo);
-	bitbang->mdo_active_low = pdata->mdo_active_low;
+		if (pdata->mdo_active_low)
+			mdo_flags = GPIOF_OUT_INIT_LOW | GPIOF_ACTIVE_LOW;
+	}
 
 	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
 	if (!new_bus)
-- 
2.9.3
