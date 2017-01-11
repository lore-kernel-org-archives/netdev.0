From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: mdio-gpio: Use devm_gpio_request_one instead of devm_gpio_request
Date: Wed, 11 Jan 2017 12:59:49 -0800
Message-ID: <20170111205951.32363-2-f.fainelli@gmail.com>
References: <20170111205951.32363-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        linux@roeck-us.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35687 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759721AbdAKVAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:00:39 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so14668731pfa.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 13:00:39 -0800 (PST)
In-Reply-To: <20170111205951.32363-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Using devm_gpio_request_one lets us request gpio pins with initial state
in one go.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-gpio.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 27ab63064f95..f6e773256c82 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -137,6 +137,9 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 	struct mii_bus *new_bus;
 	struct mdio_gpio_info *bitbang;
 	int i;
+	unsigned long mdc_flags = GPIOF_OUT_INIT_LOW;
+	unsigned long mdio_flags = GPIOF_DIR_IN;
+	unsigned long mdo_flags = GPIOF_OUT_INIT_HIGH;
 
 	bitbang = devm_kzalloc(dev, sizeof(*bitbang), GFP_KERNEL);
 	if (!bitbang)
@@ -174,21 +177,17 @@ static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
 	else
 		strncpy(new_bus->id, "gpio", MII_BUS_ID_SIZE);
 
-	if (devm_gpio_request(dev, bitbang->mdc, "mdc"))
+	if (devm_gpio_request_one(dev, bitbang->mdc, mdc_flags, "mdc"))
 		goto out_free_bus;
 
-	if (devm_gpio_request(dev, bitbang->mdio, "mdio"))
+	if (devm_gpio_request_one(dev, bitbang->mdio, mdio_flags, "mdio"))
 		goto out_free_bus;
 
 	if (bitbang->mdo) {
-		if (devm_gpio_request(dev, bitbang->mdo, "mdo"))
+		if (devm_gpio_request_one(dev, bitbang->mdo, mdo_flags, "mdo"))
 			goto out_free_bus;
-		gpio_direction_output(bitbang->mdo, 1);
-		gpio_direction_input(bitbang->mdio);
 	}
 
-	gpio_direction_output(bitbang->mdc, 0);
-
 	dev_set_drvdata(dev, new_bus);
 
 	return new_bus;
-- 
2.9.3
