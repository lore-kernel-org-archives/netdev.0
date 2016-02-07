From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 2/7] net: phy: spi_ks8995: verify chip and determine revision
Date: Sun,  7 Feb 2016 23:39:08 +0100
Message-ID: <1454884753-4560-3-git-send-email-helmut.buchsbaum@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32847 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754863AbcBGWj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:39:57 -0500
Received: by mail-wm0-f65.google.com with SMTP id r129so12869066wmr.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:39:56 -0800 (PST)
In-Reply-To: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the chip variant is now determined by spi_device_id, verify
family and chip id and determine the revision id.

Conflicts:
	drivers/net/phy/spi_ks8995.c

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 118 +++++++++++++++++++++++++++++--------------
 1 file changed, 80 insertions(+), 38 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index e848ad9..2803c8e 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -83,6 +83,8 @@
 
 #define FAMILY_KS8995		0x95
 #define CHIPID_M		0
+#define KS8995_CHIP_ID		0x00
+#define KSZ8864_CHIP_ID		0x01
 
 #define KS8995_CMD_WRITE	0x02U
 #define KS8995_CMD_READ		0x03U
@@ -97,16 +99,22 @@ enum ks8995_chip_variant {
 
 struct ks8995_chip_params {
 	char *name;
+	int family_id;
+	int chip_id;
 	int regs_size;
 };
 
 static const struct ks8995_chip_params ks8995_chip[] = {
 	[ks8995] = {
 		.name = "KS8995MA",
+		.family_id = FAMILY_KS8995,
+		.chip_id = KS8995_CHIP_ID,
 		.regs_size = KS8995_REGS_SIZE,
 	},
 	[ksz8864] = {
 		.name = "KSZ8864RMN",
+		.family_id = FAMILY_KS8995,
+		.chip_id = KSZ8864_CHIP_ID,
 		.regs_size = KSZ8864_REGS_SIZE,
 	},
 };
@@ -121,6 +129,7 @@ struct ks8995_switch {
 	struct ks8995_pdata	*pdata;
 	struct bin_attribute	regs_attr;
 	const struct ks8995_chip_params	*chip;
+	int			revision_id;
 };
 
 static const struct spi_device_id ks8995_id[] = {
@@ -263,6 +272,73 @@ static ssize_t ks8995_registers_write(struct file *filp, struct kobject *kobj,
 	return ks8995_write(ks8995, buf, off, count);
 }
 
+/* ks8995_get_revision - get chip revision
+ * @ks: pointer to switch instance
+ *
+ * Verify chip family and id and get chip revision.
+ */
+static int ks8995_get_revision(struct ks8995_switch *ks)
+{
+	int err;
+	u8 id0, id1, ksz8864_id;
+
+	/* read family id */
+	err = ks8995_read_reg(ks, KS8995_REG_ID0, &id0);
+	if (err) {
+		err = -EIO;
+		goto err_out;
+	}
+
+	/* verify family id */
+	if (id0 != ks->chip->family_id) {
+		dev_err(&ks->spi->dev, "chip family id mismatch: expected 0x%02x but 0x%02x read\n",
+			ks->chip->family_id, id0);
+		err = -ENODEV;
+		goto err_out;
+	}
+
+	switch (ks->chip->family_id) {
+	case FAMILY_KS8995:
+		/* try reading chip id at CHIP ID1 */
+		err = ks8995_read_reg(ks, KS8995_REG_ID1, &id1);
+		if (err) {
+			err = -EIO;
+			goto err_out;
+		}
+
+		/* verify chip id */
+		if ((get_chip_id(id1) == CHIPID_M) &&
+		    (get_chip_id(id1) == ks->chip->chip_id)) {
+			/* KS8995MA */
+			ks->revision_id = get_chip_rev(id1);
+		} else if (get_chip_id(id1) != CHIPID_M) {
+			/* KSZ8864RMN */
+			err = ks8995_read_reg(ks, KS8995_REG_ID1, &ksz8864_id);
+			if (err) {
+				err = -EIO;
+				goto err_out;
+			}
+
+			if ((ksz8864_id & 0x80) &&
+			    (ks->chip->chip_id == KSZ8864_CHIP_ID)) {
+				ks->revision_id = get_chip_rev(id1);
+			}
+
+		} else {
+			dev_err(&ks->spi->dev, "unsupported chip id for KS8995 family: 0x%02x\n",
+				id1);
+			err = -ENODEV;
+		}
+		break;
+	default:
+		dev_err(&ks->spi->dev, "unsupported family id: 0x%02x\n", id0);
+		err = -ENODEV;
+		break;
+	}
+err_out:
+	return err;
+}
+
 static const struct bin_attribute ks8995_registers_attr = {
 	.attr = {
 		.name   = "registers",
@@ -278,7 +354,6 @@ static int ks8995_probe(struct spi_device *spi)
 {
 	struct ks8995_switch    *ks;
 	struct ks8995_pdata     *pdata;
-	u8      ids[2];
 	int     err;
 	int variant = spi_get_device_id(spi)->driver_data;
 
@@ -309,39 +384,12 @@ static int ks8995_probe(struct spi_device *spi)
 		return err;
 	}
 
-	err = ks8995_read(ks, ids, KS8995_REG_ID0, sizeof(ids));
-	if (err < 0) {
-		dev_err(&spi->dev, "unable to read id registers, err=%d\n",
-				err);
+	err = ks8995_get_revision(ks);
+	if (err)
 		return err;
-	}
-
-	switch (ids[0]) {
-	case FAMILY_KS8995:
-		break;
-	default:
-		dev_err(&spi->dev, "unknown family id:%02x\n", ids[0]);
-		return -ENODEV;
-	}
 
 	ks->regs_attr.size = ks->chip->regs_size;
 	memcpy(&ks->regs_attr, &ks8995_registers_attr, sizeof(ks->regs_attr));
-	if (get_chip_id(ids[1]) != CHIPID_M) {
-		u8 val;
-
-		/* Check if this is a KSZ8864RMN */
-		err = ks8995_read(ks, &val, KSZ8864_REG_ID1, sizeof(val));
-		if (err < 0) {
-			dev_err(&spi->dev,
-				"unable to read chip id register, err=%d\n",
-				err);
-			return err;
-		}
-		if ((val & 0x80) == 0) {
-			dev_err(&spi->dev, "unknown chip:%02x,0\n", ids[1]);
-			return err;
-		}
-	}
 
 	err = ks8995_reset(ks);
 	if (err)
@@ -354,14 +402,8 @@ static int ks8995_probe(struct spi_device *spi)
 		return err;
 	}
 
-	if (get_chip_id(ids[1]) == CHIPID_M) {
-		dev_info(&spi->dev,
-			 "KS8995 device found, Chip ID:%x, Revision:%x\n",
-			 get_chip_id(ids[1]), get_chip_rev(ids[1]));
-	} else {
-		dev_info(&spi->dev, "KSZ8864 device found, Revision:%x\n",
-			 get_chip_rev(ids[1]));
-	}
+	dev_info(&spi->dev, "%s device found, Chip ID:%x, Revision:%x\n",
+		 ks->chip->name, ks->chip->chip_id, ks->revision_id);
 
 	return 0;
 }
-- 
2.1.4
