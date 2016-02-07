From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 3/7] net: phy: spi_ks8995: add register initialization
Date: Sun,  7 Feb 2016 23:39:09 +0100
Message-ID: <1454884753-4560-4-git-send-email-helmut.buchsbaum@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32856 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbcBGWj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:39:58 -0500
Received: by mail-wm0-f67.google.com with SMTP id r129so12869119wmr.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:39:57 -0800 (PST)
In-Reply-To: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since several use cases need to setup at least some basic control
registers add the ability to configure an array containing such
register initialization values within the platform data of the switch.
Furthermore expose this capabilty to the devicetree.

Platform data now contains a pointer to an array and the array length
where each member contains the register to be initialized, the
initialization value and a register mask, since in many use cases there
is only the need to init some bits of a register, e.g. disabling unused
ports.

The devicetree notation add the property 'settings' to the SPI node of the
ks8985 driver, which is a list of triple values (register, value, mask),
e.g.:

settings = <0x4D 0x08 0x08
            0x5D 0x08 0x08>;

to power down port 3 and 4 of a KSZ8864RMN.

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 136 ++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 128 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 2803c8e..d50f091 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/device.h>
+#include <linux/of.h>
 
 #include <linux/spi/spi.h>
 
@@ -120,7 +121,12 @@ static const struct ks8995_chip_params ks8995_chip[] = {
 };
 
 struct ks8995_pdata {
-	/* not yet implemented */
+	struct reg_init {
+		int reg;
+		int val;
+		int mask;
+	} *settings;
+	int nsettings;
 };
 
 struct ks8995_switch {
@@ -235,6 +241,47 @@ static int ks8995_start(struct ks8995_switch *ks)
 	return ks8995_write_reg(ks, KS8995_REG_ID1, 1);
 }
 
+/* ks8995_register_init - initialize registers
+ * @ks: pointer to switch instance
+ *
+ * Initialize registers from platform data if available.
+ */
+static int ks8995_register_init(struct ks8995_switch *ks)
+{
+	int i;
+	int err = 0;
+	struct ks8995_pdata *pdata = ks->pdata;
+
+	if (!pdata || !pdata->settings)
+		return 0;
+
+	for (i = 0; i < pdata->nsettings; ++i) {
+		u8 oldval, newval;
+		struct reg_init *s = &pdata->settings[i];
+
+		err = ks8995_read_reg(ks, s->reg, &oldval);
+		if (err) {
+			dev_err(&ks->spi->dev,
+				"Reading register 0x%02x failed\n",
+				s->reg);
+			err = -EIO;
+			break;
+		}
+
+		oldval &= ~s->mask;
+		newval = oldval | (s->val & s->mask);
+
+		err = ks8995_write_reg(ks, s->reg, newval);
+		if (err) {
+			dev_err(&ks->spi->dev,
+				"Writing register 0x%02x failed\n",
+				s->reg);
+			err = -EIO;
+			break;
+		}
+	}
+	return err;
+}
 static int ks8995_reset(struct ks8995_switch *ks)
 {
 	int err;
@@ -245,6 +292,10 @@ static int ks8995_reset(struct ks8995_switch *ks)
 
 	udelay(KS8995_RESET_DELAY);
 
+	err = ks8995_register_init(ks);
+	if (err)
+		return err;
+
 	return ks8995_start(ks);
 }
 
@@ -339,6 +390,64 @@ err_out:
 	return err;
 }
 
+/* ks8995_parse_dt - setup platform data from devicetree
+ * @ks: pointer to switch instance
+ *
+ * Parses supported DT properties and sets up platform data
+ * accordingly.
+ */
+static int ks8995_parse_dt(struct ks8995_switch *ks)
+{
+	const __be32 *settings;
+	int size, nsettings, i;
+	struct device_node *np = ks->spi->dev.of_node;
+	struct ks8995_pdata *pdata = ks->pdata;
+
+	if (!np)
+		return 0;
+
+	/* we have something like:
+	 * settings = <0x22 0x80 0xF0>;
+	 *               ^   ^    ^
+	 *               |   |    |
+	 *               |   |    + register bit mask
+	 *               |   + register value
+	 *               + register number
+	 *
+	 * for multiple registers it is
+	 *
+	 * settings = <0x22 0x80 0xF0 0x23 0x01 0xFF>;
+	 */
+	settings = of_get_property(np, "settings", &size);
+	if (!settings)
+		return 0;
+
+	if (size < sizeof(*settings) * 2) {
+		dev_err(&ks->spi->dev, "bad data for settings\n");
+		return -EINVAL;
+	}
+
+	size /= sizeof(*settings);	/* Number of elements in DT array */
+	nsettings = size / 3;		/* Number of register settings */
+
+	pdata->settings = devm_kzalloc(&ks->spi->dev,
+		sizeof(*pdata->settings) * nsettings, GFP_KERNEL);
+
+	if (!pdata->settings)
+		return -ENOMEM;
+
+	for (i = 0; i < nsettings; ++i) {
+		struct reg_init *s = &pdata->settings[i];
+
+		s->reg = be32_to_cpup(settings + 3 * i);
+		s->val = be32_to_cpup(settings + 3 * i + 1);
+		s->mask = be32_to_cpup(settings + 3 * i + 2);
+	}
+	pdata->nsettings = nsettings;
+
+	return 0;
+}
+
 static const struct bin_attribute ks8995_registers_attr = {
 	.attr = {
 		.name   = "registers",
@@ -352,14 +461,10 @@ static const struct bin_attribute ks8995_registers_attr = {
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
@@ -370,10 +475,25 @@ static int ks8995_probe(struct spi_device *spi)
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
+		err = ks8995_parse_dt(ks);
+		if (err) {
+			dev_err(&ks->spi->dev, "bad data DT data\n");
+			return err;
+		}
+	}
+
+	if (!ks->pdata)
+		ks->pdata = spi->dev.platform_data;
+
 	spi_set_drvdata(spi, ks);
 
 	spi->mode = SPI_MODE_0;
-- 
2.1.4
