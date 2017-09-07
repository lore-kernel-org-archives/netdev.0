From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 5/5] Add KSZ8795 SPI driver
Date: Thu, 7 Sep 2017 21:17:33 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121A95@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:15489 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756104AbdIGVRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:17:50 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tristram Ha <Tristram.Ha@microchip.com>

Add KSZ8795 switch support with SPI access.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
diff --git a/drivers/net/dsa/microchip/ksz8795_spi.c b/drivers/net/dsa/microchip/ksz8795_spi.c
new file mode 100644
index 0000000..0f9c731
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz8795_spi.c
@@ -0,0 +1,229 @@
+/*
+ * Microchip KSZ8795 series register access through SPI
+ *
+ * Copyright (C) 2017 Microchip Technology Inc.
+ *	Tristram Ha <Tristram.Ha@microchip.com>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for 
+any
+ * purpose with or without fee is hereby granted, provided that the 
+above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL 
+WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE 
+FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY 
+DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN 
+AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT 
+OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <asm/unaligned.h>
+
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/spi/spi.h>
+
+#include "ksz_priv.h"
+
+int ksz8795_switch_register(struct ksz_device *dev);
+
+/* SPI frame opcodes */
+#define KS_SPIOP_RD			3
+#define KS_SPIOP_WR			2
+
+#define SPI_ADDR_S			12
+#define SPI_ADDR_M			(BIT(SPI_ADDR_S) - 1)
+#define SPI_TURNAROUND_S		1
+
+/* Enough to read all switch registers. */
+#define SPI_TX_BUF_LEN			0x100
+
+static int ksz_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
+			    unsigned int len)
+{
+	u16 txbuf;
+	int ret;
+
+	txbuf = reg & SPI_ADDR_M;
+	txbuf |= KS_SPIOP_RD << SPI_ADDR_S;
+	txbuf <<= SPI_TURNAROUND_S;
+	txbuf = cpu_to_be16(txbuf);
+
+	ret = spi_write_then_read(spi, &txbuf, 2, val, len);
+	return ret;
+}
+
+static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
+			unsigned int len)
+{
+	struct spi_device *spi = dev->priv;
+
+	return ksz_spi_read_reg(spi, reg, data, len); }
+
+static int ksz_spi_read8(struct ksz_device *dev, u32 reg, u8 *val) {
+	return ksz_spi_read(dev, reg, val, 1); }
+
+static int ksz_spi_read16(struct ksz_device *dev, u32 reg, u16 *val) {
+	int ret = ksz_spi_read(dev, reg, (u8 *)val, 2);
+
+	if (!ret)
+		*val = be16_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_read32(struct ksz_device *dev, u32 reg, u32 *val) {
+	int ret = ksz_spi_read(dev, reg, (u8 *)val, 4);
+
+	if (!ret)
+		*val = be32_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_write_reg(struct spi_device *spi, u32 reg, u8 *val,
+			     unsigned int len)
+{
+	u16 *txbuf = (u16 *)val;
+
+	*txbuf = reg & SPI_ADDR_M;
+	*txbuf |= (KS_SPIOP_WR << SPI_ADDR_S);
+	*txbuf <<= SPI_TURNAROUND_S;
+	*txbuf = cpu_to_be16(*txbuf);
+
+	return spi_write(spi, txbuf, 2 + len); }
+
+static int ksz_spi_write(struct ksz_device *dev, u32 reg, void *data,
+			 unsigned int len)
+{
+	struct spi_device *spi = dev->priv;
+
+	if (len > SPI_TX_BUF_LEN)
+		len = SPI_TX_BUF_LEN;
+	memcpy(&dev->txbuf[2], data, len);
+	return ksz_spi_write_reg(spi, reg, dev->txbuf, len); }
+
+static unsigned int ksz_spi_get(struct ksz_device *dev, u32 reg, void *data,
+				unsigned int len)
+{
+	int err;
+
+	err = ksz_spi_read(dev, reg, data, len);
+	if (err)
+		return 0;
+	return len;
+}
+
+static unsigned int ksz_spi_set(struct ksz_device *dev, u32 reg, void *data,
+				unsigned int len)
+{
+	int err;
+
+	err = ksz_spi_write(dev, reg, data, len);
+	if (err)
+		return 0;
+	return len;
+}
+
+static int ksz_spi_write8(struct ksz_device *dev, u32 reg, u8 value) {
+	return ksz_spi_write(dev, reg, &value, 1); }
+
+static int ksz_spi_write16(struct ksz_device *dev, u32 reg, u16 value) 
+{
+	value = cpu_to_be16(value);
+	return ksz_spi_write(dev, reg, &value, 2); }
+
+static int ksz_spi_write32(struct ksz_device *dev, u32 reg, u32 value) 
+{
+	value = cpu_to_be32(value);
+	return ksz_spi_write(dev, reg, &value, 4); }
+
+static const struct ksz_io_ops ksz_spi_ops = {
+	.read8 = ksz_spi_read8,
+	.read16 = ksz_spi_read16,
+	.read32 = ksz_spi_read32,
+	.write8 = ksz_spi_write8,
+	.write16 = ksz_spi_write16,
+	.write32 = ksz_spi_write32,
+	.get = ksz_spi_get,
+	.set = ksz_spi_set,
+};
+
+static int ksz_spi_probe(struct spi_device *spi) {
+	struct ksz_device *dev;
+	int ret;
+
+	dev = ksz_switch_alloc(&spi->dev, &ksz_spi_ops, spi);
+	if (!dev)
+		return -ENOMEM;
+
+	if (spi->dev.platform_data)
+		dev->pdata = spi->dev.platform_data;
+
+	dev->txbuf = devm_kzalloc(dev->dev, 2 + SPI_TX_BUF_LEN, GFP_KERNEL);
+
+	ret = ksz8795_switch_register(dev);
+
+	/* Main DSA driver may not be started yet. */
+	if (ret)
+		return ret;
+
+	spi_set_drvdata(spi, dev);
+
+	return 0;
+}
+
+static int ksz_spi_remove(struct spi_device *spi) {
+	struct ksz_device *dev = spi_get_drvdata(spi);
+
+	if (dev)
+		ksz_switch_remove(dev);
+
+	return 0;
+}
+
+static void ksz_spi_shutdown(struct spi_device *spi) {
+	struct ksz_device *dev = spi_get_drvdata(spi);
+
+	if (dev)
+		dev->dev_ops->reset(dev);
+}
+
+static const struct of_device_id ksz_dt_ids[] = {
+	{ .compatible = "microchip,ksz8795" },
+	{ .compatible = "microchip,ksz8765" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, ksz_dt_ids);
+
+static struct spi_driver ksz_spi_driver = {
+	.driver = {
+		.name	= "ksz8795-switch",
+		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(ksz_dt_ids),
+	},
+	.probe	= ksz_spi_probe,
+	.remove	= ksz_spi_remove,
+	.shutdown = ksz_spi_shutdown,
+};
+
+module_spi_driver(ksz_spi_driver);
+
+MODULE_AUTHOR("Tristram Ha <Tristram.Ha@microchip.com>"); 
+MODULE_DESCRIPTION("Microchip KSZ8795 Series Switch SPI Driver"); 
+MODULE_LICENSE("GPL");
