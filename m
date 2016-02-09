From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v3 3/6] net: phy: spi_ks8995: add support for resetting switch using GPIO
Date: Tue,  9 Feb 2016 20:47:15 +0100
Message-ID: <1455047238-111358-4-git-send-email-helmut.buchsbaum@gmail.com>
References: <1455047238-111358-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33989 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353AbcBITri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 14:47:38 -0500
Received: by mail-wm0-f68.google.com with SMTP id p63so5382590wmp.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 11:47:37 -0800 (PST)
In-Reply-To: <1455047238-111358-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using device tree it is no more possible to reset the PHY at board
level. Furthermore, doing in the driver allows to power down the switch
when it is not used any more.

The patch introduces a new optional property "reset-gpios" denoting an
appropriate GPIO handle, e.g.:

reset-gpios = <&gpio0 46 GPIO_ACTIVE_LOW>

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 71 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 62 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 2803c8e..04d468f 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -18,6 +18,9 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/device.h>
+#include <linux/of.h>
+#include <linux/gpio.h>
+#include <linux/of_gpio.h>
 
 #include <linux/spi/spi.h>
 
@@ -120,7 +123,8 @@ static const struct ks8995_chip_params ks8995_chip[] = {
 };
 
 struct ks8995_pdata {
-	/* not yet implemented */
+	int reset_gpio;
+	enum of_gpio_flags reset_gpio_flags;
 };
 
 struct ks8995_switch {
@@ -339,6 +343,24 @@ err_out:
 	return err;
 }
 
+/* ks8995_parse_dt - setup platform data from devicetree
+ * @ks: pointer to switch instance
+ *
+ * Parses supported DT properties and sets up platform data
+ * accordingly.
+ */
+static void ks8995_parse_dt(struct ks8995_switch *ks)
+{
+	struct device_node *np = ks->spi->dev.of_node;
+	struct ks8995_pdata *pdata = ks->pdata;
+
+	if (!np)
+		return;
+
+	pdata->reset_gpio = of_get_named_gpio_flags(np, "reset-gpios", 0,
+		&pdata->reset_gpio_flags);
+}
+
 static const struct bin_attribute ks8995_registers_attr = {
 	.attr = {
 		.name   = "registers",
@@ -352,14 +374,10 @@ static const struct bin_attribute ks8995_registers_attr = {
 /* ------------------------------------------------------------------------ */
 static int ks8995_probe(struct spi_device *spi)
 {
-	struct ks8995_switch    *ks;
-	struct ks8995_pdata     *pdata;
-	int     err;
+	struct ks8995_switch *ks;
+	int err;
 	int variant = spi_get_device_id(spi)->driver_data;
 
-	/* Chip description */
-	pdata = spi->dev.platform_data;
-
 	if (variant >= max_variant) {
 		dev_err(&spi->dev, "bad chip variant %d\n", variant);
 		return -ENODEV;
@@ -370,10 +388,42 @@ static int ks8995_probe(struct spi_device *spi)
 		return -ENOMEM;
 
 	mutex_init(&ks->lock);
-	ks->pdata = pdata;
 	ks->spi = spi_dev_get(spi);
 	ks->chip = &ks8995_chip[variant];
 
+	if (ks->spi->dev.of_node) {
+		ks->pdata = devm_kzalloc(&spi->dev, sizeof(*ks->pdata),
+					 GFP_KERNEL);
+		if (!ks->pdata)
+			return -ENOMEM;
+
+		ks->pdata->reset_gpio = -1;
+
+		ks8995_parse_dt(ks);
+	}
+
+	if (!ks->pdata)
+		ks->pdata = spi->dev.platform_data;
+
+	/* de-assert switch reset */
+	if (ks->pdata && gpio_is_valid(ks->pdata->reset_gpio)) {
+		unsigned long flags;
+
+		flags = (ks->pdata->reset_gpio_flags == OF_GPIO_ACTIVE_LOW ?
+			 GPIOF_ACTIVE_LOW : 0);
+
+		err = devm_gpio_request_one(&spi->dev,
+					    ks->pdata->reset_gpio,
+					    flags, "switch-reset");
+		if (err) {
+			dev_err(&spi->dev,
+				"failed to get reset-gpios: %d\n", err);
+			return -EIO;
+		}
+
+		gpiod_set_value(gpio_to_desc(ks->pdata->reset_gpio), 0);
+	}
+
 	spi_set_drvdata(spi, ks);
 
 	spi->mode = SPI_MODE_0;
@@ -414,11 +464,14 @@ static int ks8995_remove(struct spi_device *spi)
 
 	sysfs_remove_bin_file(&spi->dev.kobj, &ks->regs_attr);
 
+	/* assert reset */
+	if (ks->pdata && gpio_is_valid(ks->pdata->reset_gpio))
+		gpiod_set_value(gpio_to_desc(ks->pdata->reset_gpio), 1);
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
