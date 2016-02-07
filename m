From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 1/7] net: phy: spi_ks8995: introduce spi_device_id table
Date: Sun,  7 Feb 2016 23:39:07 +0100
Message-ID: <1454884753-4560-2-git-send-email-helmut.buchsbaum@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34337 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457AbcBGWj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:39:56 -0500
Received: by mail-wm0-f66.google.com with SMTP id p63so12861551wmp.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:39:55 -0800 (PST)
In-Reply-To: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor to use spi_device_id table to facilitate easy
extendability.

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index f091d69..e848ad9 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -89,6 +89,28 @@
 
 #define KS8995_RESET_DELAY	10 /* usec */
 
+enum ks8995_chip_variant {
+	ks8995,
+	ksz8864,
+	max_variant
+};
+
+struct ks8995_chip_params {
+	char *name;
+	int regs_size;
+};
+
+static const struct ks8995_chip_params ks8995_chip[] = {
+	[ks8995] = {
+		.name = "KS8995MA",
+		.regs_size = KS8995_REGS_SIZE,
+	},
+	[ksz8864] = {
+		.name = "KSZ8864RMN",
+		.regs_size = KSZ8864_REGS_SIZE,
+	},
+};
+
 struct ks8995_pdata {
 	/* not yet implemented */
 };
@@ -98,8 +120,16 @@ struct ks8995_switch {
 	struct mutex		lock;
 	struct ks8995_pdata	*pdata;
 	struct bin_attribute	regs_attr;
+	const struct ks8995_chip_params	*chip;
 };
 
+static const struct spi_device_id ks8995_id[] = {
+	{"ks8995", ks8995},
+	{"ksz8864", ksz8864},
+	{ }
+};
+MODULE_DEVICE_TABLE(spi, ks8995_id);
+
 static inline u8 get_chip_id(u8 val)
 {
 	return (val >> ID1_CHIPID_S) & ID1_CHIPID_M;
@@ -244,17 +274,22 @@ static const struct bin_attribute ks8995_registers_attr = {
 };
 
 /* ------------------------------------------------------------------------ */
-
 static int ks8995_probe(struct spi_device *spi)
 {
 	struct ks8995_switch    *ks;
 	struct ks8995_pdata     *pdata;
 	u8      ids[2];
 	int     err;
+	int variant = spi_get_device_id(spi)->driver_data;
 
 	/* Chip description */
 	pdata = spi->dev.platform_data;
 
+	if (variant >= max_variant) {
+		dev_err(&spi->dev, "bad chip variant %d\n", variant);
+		return -ENODEV;
+	}
+
 	ks = devm_kzalloc(&spi->dev, sizeof(*ks), GFP_KERNEL);
 	if (!ks)
 		return -ENOMEM;
@@ -262,6 +297,8 @@ static int ks8995_probe(struct spi_device *spi)
 	mutex_init(&ks->lock);
 	ks->pdata = pdata;
 	ks->spi = spi_dev_get(spi);
+	ks->chip = &ks8995_chip[variant];
+
 	spi_set_drvdata(spi, ks);
 
 	spi->mode = SPI_MODE_0;
@@ -287,6 +324,7 @@ static int ks8995_probe(struct spi_device *spi)
 		return -ENODEV;
 	}
 
+	ks->regs_attr.size = ks->chip->regs_size;
 	memcpy(&ks->regs_attr, &ks8995_registers_attr, sizeof(ks->regs_attr));
 	if (get_chip_id(ids[1]) != CHIPID_M) {
 		u8 val;
@@ -303,7 +341,6 @@ static int ks8995_probe(struct spi_device *spi)
 			dev_err(&spi->dev, "unknown chip:%02x,0\n", ids[1]);
 			return err;
 		}
-		ks->regs_attr.size = KSZ8864_REGS_SIZE;
 	}
 
 	err = ks8995_reset(ks);
@@ -347,6 +384,7 @@ static struct spi_driver ks8995_driver = {
 	},
 	.probe	  = ks8995_probe,
 	.remove	  = ks8995_remove,
+	.id_table = ks8995_id,
 };
 
 module_spi_driver(ks8995_driver);
-- 
2.1.4
