From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 4/7] net: phy: spi_ks8995: add support for resetting switch using GPIO
Date: Sun,  7 Feb 2016 23:39:10 +0100
Message-ID: <1454884753-4560-5-git-send-email-helmut.buchsbaum@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35034 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754919AbcBGWj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:39:59 -0500
Received: by mail-wm0-f68.google.com with SMTP id g62so12876790wme.2
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:39:59 -0800 (PST)
In-Reply-To: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using device tree it is no more possible to reset the PHY at board
level. Furthermore, doing in the driver allows to power down the switch
when the it is not used any more.

The patch introduces a new optional property "reset-gpios" denoting an
appropriate GPIO handle, e.g.:

reset-gpios = <&gpio0 46 1>

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index d50f091..60479c4 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -19,6 +19,8 @@
 #include <linux/delay.h>
 #include <linux/device.h>
 #include <linux/of.h>
+#include <linux/gpio.h>
+#include <linux/of_gpio.h>
 
 #include <linux/spi/spi.h>
 
@@ -127,6 +129,7 @@ struct ks8995_pdata {
 		int mask;
 	} *settings;
 	int nsettings;
+	int reset_gpio;
 };
 
 struct ks8995_switch {
@@ -406,6 +409,8 @@ static int ks8995_parse_dt(struct ks8995_switch *ks)
 	if (!np)
 		return 0;
 
+	pdata->reset_gpio = of_get_named_gpio(np, "reset-gpios", 0);
+
 	/* we have something like:
 	 * settings = <0x22 0x80 0xF0>;
 	 *               ^   ^    ^
@@ -484,6 +489,8 @@ static int ks8995_probe(struct spi_device *spi)
 		if (!ks->pdata)
 			return -ENOMEM;
 
+		ks->pdata->reset_gpio = -1;
+
 		err = ks8995_parse_dt(ks);
 		if (err) {
 			dev_err(&ks->spi->dev, "bad data DT data\n");
@@ -494,6 +501,18 @@ static int ks8995_probe(struct spi_device *spi)
 	if (!ks->pdata)
 		ks->pdata = spi->dev.platform_data;
 
+	if (ks->pdata && gpio_is_valid(ks->pdata->reset_gpio)) {
+		err = devm_gpio_request_one(&spi->dev,
+					    ks->pdata->reset_gpio,
+					    GPIOF_OUT_INIT_HIGH,
+					    "switch-reset");
+		if (err) {
+			dev_err(&spi->dev,
+				"failed to get reset-gpios: %d\n", err);
+			return -EIO;
+		}
+	}
+
 	spi_set_drvdata(spi, ks);
 
 	spi->mode = SPI_MODE_0;
@@ -534,11 +553,13 @@ static int ks8995_remove(struct spi_device *spi)
 
 	sysfs_remove_bin_file(&spi->dev.kobj, &ks->regs_attr);
 
+	if (ks->pdata && gpio_is_valid(ks->pdata->reset_gpio))
+		gpio_set_value(ks->pdata->reset_gpio, 0);
+
 	return 0;
 }
 
 /* ------------------------------------------------------------------------ */
-
 static struct spi_driver ks8995_driver = {
 	.driver = {
 		.name	    = "spi-ks8995",
-- 
2.1.4
