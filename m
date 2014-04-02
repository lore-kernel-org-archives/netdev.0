From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH] net: Micrel KSZ8864RMN 4-port managed switch support
Date: Wed,  2 Apr 2014 17:50:16 +0200
Message-ID: <1396453816-32348-1-git-send-email-p.zabel@pengutronix.de>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Frederic LAMBERT <frdrc66@gmail.com>, kernel@pengutronix.de,
	Philipp Zabel <p.zabel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the Micrel KSZ8864RMN switch to the spi_ks8995
driver. The KSZ8864RMN switch has a wider 256-byte register space.

Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
 drivers/net/phy/spi_ks8995.c | 49 +++++++++++++++++++++++++++++++++++---------
 1 file changed, 39 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 4cf5fb9..ad4e028 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -1,5 +1,5 @@
 /*
- * SPI driver for Micrel/Kendin KS8995M ethernet switch
+ * SPI driver for Micrel/Kendin KS8995M and KSZ8864RMN ethernet switches
  *
  * Copyright (C) 2008 Gabor Juhos <juhosg at openwrt.org>
  *
@@ -70,7 +70,10 @@
 #define KS8995_REG_IAD1		0x76    /* Indirect Access Data 1 */
 #define KS8995_REG_IAD0		0x77    /* Indirect Access Data 0 */
 
+#define KSZ8864_REG_ID1		0xfe	/* Chip ID in bit 7 */
+
 #define KS8995_REGS_SIZE	0x80
+#define KSZ8864_REGS_SIZE	0x100
 
 #define ID1_CHIPID_M		0xf
 #define ID1_CHIPID_S		4
@@ -94,6 +97,7 @@ struct ks8995_switch {
 	struct spi_device	*spi;
 	struct mutex		lock;
 	struct ks8995_pdata	*pdata;
+	unsigned int		regs_size;
 };
 
 static inline u8 get_chip_id(u8 val)
@@ -216,11 +220,11 @@ static ssize_t ks8995_registers_read(struct file *filp, struct kobject *kobj,
 	dev = container_of(kobj, struct device, kobj);
 	ks8995 = dev_get_drvdata(dev);
 
-	if (unlikely(off > KS8995_REGS_SIZE))
+	if (unlikely(off > ks8995->regs_size))
 		return 0;
 
-	if ((off + count) > KS8995_REGS_SIZE)
-		count = KS8995_REGS_SIZE - off;
+	if ((off + count) > ks8995->regs_size)
+		count = ks8995->regs_size - off;
 
 	if (unlikely(!count))
 		return count;
@@ -238,11 +242,11 @@ static ssize_t ks8995_registers_write(struct file *filp, struct kobject *kobj,
 	dev = container_of(kobj, struct device, kobj);
 	ks8995 = dev_get_drvdata(dev);
 
-	if (unlikely(off >= KS8995_REGS_SIZE))
+	if (unlikely(off >= ks8995->regs_size))
 		return -EFBIG;
 
-	if ((off + count) > KS8995_REGS_SIZE)
-		count = KS8995_REGS_SIZE - off;
+	if ((off + count) > ks8995->regs_size)
+		count = ks8995->regs_size - off;
 
 	if (unlikely(!count))
 		return count;
@@ -306,6 +310,26 @@ static int ks8995_probe(struct spi_device *spi)
 		goto err_drvdata;
 	}
 
+	ks->regs_size = KS8995_REGS_SIZE;
+	if (get_chip_id(ids[1]) != CHIPID_M) {
+		u8 val;
+
+		/* Check if this is a KSZ8864RMN */
+		err = ks8995_read(ks, &val, KSZ8864_REG_ID1, sizeof(val));
+		if (err < 0) {
+			dev_err(&spi->dev,
+				"unable to read chip id register, err=%d\n",
+				err);
+			goto err_drvdata;
+		}
+		if ((val & 0x80) == 0) {
+			dev_err(&spi->dev, "unknown chip:%02x,0\n", ids[1]);
+			goto err_drvdata;
+		}
+		ks->regs_size = KSZ8864_REGS_SIZE;
+		ks8995_registers_attr.size = KSZ8864_REGS_SIZE;
+	}
+
 	err = ks8995_reset(ks);
 	if (err)
 		goto err_drvdata;
@@ -317,9 +341,14 @@ static int ks8995_probe(struct spi_device *spi)
 		goto err_drvdata;
 	}
 
-	dev_info(&spi->dev, "KS89%02X device found, Chip ID:%01x, "
-			"Revision:%01x\n", ids[0],
-			get_chip_id(ids[1]), get_chip_rev(ids[1]));
+	if (get_chip_id(ids[1]) == CHIPID_M) {
+		dev_info(&spi->dev,
+			 "KS8995 device found, Chip ID:%01x, Revision:%01x\n",
+			 get_chip_id(ids[1]), get_chip_rev(ids[1]));
+	} else {
+		dev_info(&spi->dev, "KSZ8864 device found, Revision:%01x\n",
+			 get_chip_rev(ids[1]));
+	}
 
 	return 0;
 
-- 
1.9.1
