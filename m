From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 net-next 03/13] at86rf230: rework
	detect device handling
Date: Thu,  3 Jul 2014 00:20:45 +0200
Message-ID: <1404339655-8456-4-git-send-email-alex.aring@gmail.com>
References: <1404339655-8456-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1404339655-8456-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch drops the current lowlevel spi calls for the detect device
function instead we handle this via regmap. Also put the detection of
in a seperate function and set all device specific attributes while detection.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 183 +++++++++++++++----------------------
 1 file changed, 76 insertions(+), 107 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index e369703..7d96cd4 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -410,57 +410,6 @@ static struct regmap_config at86rf230_regmap_spi_config = {
 };
 
 static int
-__at86rf230_detect_device(struct spi_device *spi, u16 *man_id, u8 *part,
-		u8 *version)
-{
-	u8 data[4];
-	u8 *buf = kmalloc(2, GFP_KERNEL);
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer = {
-		.len	= 2,
-		.tx_buf	= buf,
-		.rx_buf	= buf,
-	};
-	u8 reg;
-
-	if (!buf)
-		return -ENOMEM;
-
-	for (reg = RG_PART_NUM; reg <= RG_MAN_ID_1; reg++) {
-		buf[0] = (reg & CMD_REG_MASK) | CMD_REG;
-		buf[1] = 0xff;
-		dev_vdbg(&spi->dev, "buf[0] = %02x\n", buf[0]);
-		spi_message_init(&msg);
-		spi_message_add_tail(&xfer, &msg);
-
-		status = spi_sync(spi, &msg);
-		dev_vdbg(&spi->dev, "status = %d\n", status);
-		if (msg.status)
-			status = msg.status;
-
-		dev_vdbg(&spi->dev, "status = %d\n", status);
-		dev_vdbg(&spi->dev, "buf[0] = %02x\n", buf[0]);
-		dev_vdbg(&spi->dev, "buf[1] = %02x\n", buf[1]);
-
-		if (status == 0)
-			data[reg - RG_PART_NUM] = buf[1];
-		else
-			break;
-	}
-
-	if (status == 0) {
-		*part = data[0];
-		*version = data[1];
-		*man_id = (data[3] << 8) | data[2];
-	}
-
-	kfree(buf);
-
-	return status;
-}
-
-static int
 at86rf230_write_fbuf(struct at86rf230_local *lp, u8 *data, u8 len)
 {
 	u8 *buf = lp->buf;
@@ -1080,18 +1029,87 @@ done:
 	return pdata;
 }
 
+static int
+at86rf230_detect_device(struct at86rf230_local *lp)
+{
+	unsigned int part, version, val;
+	u16 man_id = 0;
+	const char *chip;
+	int rc;
+
+	rc = __at86rf230_read(lp, RG_MAN_ID_0, &val);
+	if (rc)
+		return rc;
+	man_id |= val;
+
+	rc = __at86rf230_read(lp, RG_MAN_ID_1, &val);
+	if (rc)
+		return rc;
+	man_id |= (val << 8);
+
+	rc = __at86rf230_read(lp, RG_PART_NUM, &part);
+	if (rc)
+		return rc;
+
+	rc = __at86rf230_read(lp, RG_PART_NUM, &version);
+	if (rc)
+		return rc;
+
+	if (man_id != 0x001f) {
+		dev_err(&lp->spi->dev, "Non-Atmel dev found (MAN_ID %02x %02x)\n",
+			man_id >> 8, man_id & 0xFF);
+		return -EINVAL;
+	}
+
+	lp->part = part;
+	lp->vers = version;
+	lp->dev->extra_tx_headroom = 0;
+	lp->dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK |
+			 IEEE802154_HW_TXPOWER | IEEE802154_HW_CSMA;
+
+	switch (part) {
+	case 2:
+		chip = "at86rf230";
+		rc = -ENOTSUPP;
+		break;
+	case 3:
+		chip = "at86rf231";
+		lp->dev->phy->channels_supported[0] = 0x7FFF800;
+		break;
+	case 7:
+		chip = "at86rf212";
+		if (version == 1) {
+			lp->dev->flags |= IEEE802154_HW_LBT;
+			lp->dev->phy->channels_supported[0] = 0x00007FF;
+			lp->dev->phy->channels_supported[2] = 0x00007FF;
+		} else {
+			rc = -ENOTSUPP;
+		}
+		break;
+	case 11:
+		chip = "at86rf233";
+		lp->dev->phy->channels_supported[0] = 0x7FFF800;
+		break;
+	default:
+		chip = "unkown";
+		rc = -ENOTSUPP;
+		break;
+	}
+
+	dev_info(&lp->spi->dev, "Detected %s chip version %d\n", chip, version);
+
+	return rc;
+}
+
 static int at86rf230_probe(struct spi_device *spi)
 {
 	struct at86rf230_platform_data *pdata;
 	struct ieee802154_dev *dev;
 	struct at86rf230_local *lp;
-	u16 man_id = 0;
-	u8 part = 0, version = 0;
 	unsigned int status;
 	irq_handler_t irq_handler;
 	work_func_t irq_worker;
 	int rc, irq_type;
-	const char *chip;
 
 	if (!spi->irq) {
 		dev_err(&spi->dev, "no IRQ specified\n");
@@ -1133,54 +1151,8 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	lp = dev->priv;
 	lp->dev = dev;
-	lp->part = part;
-	lp->vers = version;
-
 	lp->spi = spi;
-
 	dev->parent = &spi->dev;
-	dev->extra_tx_headroom = 0;
-	dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK |
-		     IEEE802154_HW_TXPOWER | IEEE802154_HW_CSMA;
-
-	rc = __at86rf230_detect_device(spi, &man_id, &part, &version);
-	if (rc < 0)
-		goto free_dev;
-
-	if (man_id != 0x001f) {
-		dev_err(&spi->dev, "Non-Atmel dev found (MAN_ID %02x %02x)\n",
-			man_id >> 8, man_id & 0xFF);
-		return -EINVAL;
-	}
-
-	switch (part) {
-	case 2:
-		chip = "at86rf230";
-		rc = -ENOTSUPP;
-		/* FIXME: should be easy to support; */
-		break;
-	case 3:
-		chip = "at86rf231";
-		break;
-	case 7:
-		chip = "at86rf212";
-		if (version == 1)
-			dev->flags |= IEEE802154_HW_LBT;
-		else
-			rc = -ENOTSUPP;
-		break;
-	case 11:
-		chip = "at86rf233";
-		break;
-	default:
-		chip = "UNKNOWN";
-		rc = -ENOTSUPP;
-		break;
-	}
-
-	dev_info(&spi->dev, "Detected %s chip version %d\n", chip, version);
-	if (rc < 0)
-		goto free_dev;
 
 	lp->regmap = devm_regmap_init_spi(spi, &at86rf230_regmap_spi_config);
 	if (IS_ERR(lp->regmap)) {
@@ -1190,6 +1162,10 @@ static int at86rf230_probe(struct spi_device *spi)
 		goto free_dev;
 	}
 
+	rc = at86rf230_detect_device(lp);
+	if (rc < 0)
+		goto free_dev;
+
 	irq_type = irq_get_trigger_type(spi->irq);
 	if (!irq_type)
 		irq_type = IRQF_TRIGGER_RISING;
@@ -1208,13 +1184,6 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	spi_set_drvdata(spi, lp);
 
-	if (is_rf212(lp)) {
-		dev->phy->channels_supported[0] = 0x00007FF;
-		dev->phy->channels_supported[2] = 0x00007FF;
-	} else {
-		dev->phy->channels_supported[0] = 0x7FFF800;
-	}
-
 	rc = at86rf230_hw_init(lp);
 	if (rc)
 		goto err_hw_init;
-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
