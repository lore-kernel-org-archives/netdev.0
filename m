From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 4/5] net: w5100: support SPI interface mode
Date: Fri, 15 Apr 2016 00:11:32 +0900
Message-ID: <1460646693-25179-5-git-send-email-akinobu.mita@gmail.com>
References: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34484 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215AbcDNPMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 11:12:02 -0400
Received: by mail-pa0-f49.google.com with SMTP id ot11so45736661pab.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 08:12:00 -0700 (PDT)
In-Reply-To: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds new w5100-spi driver which shares the bus interface
independent code with existing w5100 driver.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
* No changes from v2

 drivers/net/ethernet/wiznet/Kconfig     |  14 ++++
 drivers/net/ethernet/wiznet/Makefile    |   1 +
 drivers/net/ethernet/wiznet/w5100-spi.c | 136 ++++++++++++++++++++++++++++++++
 3 files changed, 151 insertions(+)
 create mode 100644 drivers/net/ethernet/wiznet/w5100-spi.c

diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
index f98b91d..d1ab353 100644
--- a/drivers/net/ethernet/wiznet/Kconfig
+++ b/drivers/net/ethernet/wiznet/Kconfig
@@ -69,4 +69,18 @@ config WIZNET_BUS_ANY
 	  Performance may decrease compared to explicitly selected bus mode.
 endchoice
 
+config WIZNET_W5100_SPI
+	tristate "WIZnet W5100 Ethernet support for SPI mode"
+	depends on WIZNET_BUS_ANY
+	depends on SPI
+	---help---
+	  In SPI mode host system accesses registers using SPI protocol
+	  (mode 0) on the SPI bus.
+
+	  Performance decreases compared to other bus interface mode.
+	  In W5100 SPI mode, burst READ/WRITE processing are not provided.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called w5100-spi.
+
 endif # NET_VENDOR_WIZNET
diff --git a/drivers/net/ethernet/wiznet/Makefile b/drivers/net/ethernet/wiznet/Makefile
index c614535..1e05e1a 100644
--- a/drivers/net/ethernet/wiznet/Makefile
+++ b/drivers/net/ethernet/wiznet/Makefile
@@ -1,2 +1,3 @@
 obj-$(CONFIG_WIZNET_W5100) += w5100.o
+obj-$(CONFIG_WIZNET_W5100_SPI) += w5100-spi.o
 obj-$(CONFIG_WIZNET_W5300) += w5300.o
diff --git a/drivers/net/ethernet/wiznet/w5100-spi.c b/drivers/net/ethernet/wiznet/w5100-spi.c
new file mode 100644
index 0000000..32f406c
--- /dev/null
+++ b/drivers/net/ethernet/wiznet/w5100-spi.c
@@ -0,0 +1,136 @@
+/*
+ * Ethernet driver for the WIZnet W5100 chip.
+ *
+ * Copyright (C) 2016 Akinobu Mita <akinobu.mita@gmail.com>
+ *
+ * Licensed under the GPL-2 or later.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/spi/spi.h>
+
+#include "w5100.h"
+
+#define W5100_SPI_WRITE_OPCODE 0xf0
+#define W5100_SPI_READ_OPCODE 0x0f
+
+static int w5100_spi_read(struct net_device *ndev, u16 addr)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[3] = { W5100_SPI_READ_OPCODE, addr >> 8, addr & 0xff };
+	u8 data;
+	int ret;
+
+	ret = spi_write_then_read(spi, cmd, sizeof(cmd), &data, 1);
+
+	return ret ? ret : data;
+}
+
+static int w5100_spi_write(struct net_device *ndev, u16 addr, u8 data)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[4] = { W5100_SPI_WRITE_OPCODE, addr >> 8, addr & 0xff, data};
+
+	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
+}
+
+static int w5100_spi_read16(struct net_device *ndev, u16 addr)
+{
+	u16 data;
+	int ret;
+
+	ret = w5100_spi_read(ndev, addr);
+	if (ret < 0)
+		return ret;
+	data = ret << 8;
+	ret = w5100_spi_read(ndev, addr + 1);
+
+	return ret < 0 ? ret : data | ret;
+}
+
+static int w5100_spi_write16(struct net_device *ndev, u16 addr, u16 data)
+{
+	int ret;
+
+	ret = w5100_spi_write(ndev, addr, data >> 8);
+	if (ret)
+		return ret;
+
+	return w5100_spi_write(ndev, addr + 1, data & 0xff);
+}
+
+static int w5100_spi_readbulk(struct net_device *ndev, u16 addr, u8 *buf,
+			      int len)
+{
+	int i;
+
+	for (i = 0; i < len; i++) {
+		int ret = w5100_spi_read(ndev, addr + i);
+
+		if (ret < 0)
+			return ret;
+		buf[i] = ret;
+	}
+
+	return 0;
+}
+
+static int w5100_spi_writebulk(struct net_device *ndev, u16 addr, const u8 *buf,
+			       int len)
+{
+	int i;
+
+	for (i = 0; i < len; i++) {
+		int ret = w5100_spi_write(ndev, addr + i, buf[i]);
+
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static const struct w5100_ops w5100_spi_ops = {
+	.may_sleep = true,
+	.read = w5100_spi_read,
+	.write = w5100_spi_write,
+	.read16 = w5100_spi_read16,
+	.write16 = w5100_spi_write16,
+	.readbulk = w5100_spi_readbulk,
+	.writebulk = w5100_spi_writebulk,
+};
+
+static int w5100_spi_probe(struct spi_device *spi)
+{
+	return w5100_probe(&spi->dev, &w5100_spi_ops, 0, NULL, spi->irq,
+			   -EINVAL);
+}
+
+static int w5100_spi_remove(struct spi_device *spi)
+{
+	return w5100_remove(&spi->dev);
+}
+
+static const struct spi_device_id w5100_spi_ids[] = {
+	{ "w5100", 0 },
+	{}
+};
+MODULE_DEVICE_TABLE(spi, w5100_spi_ids);
+
+static struct spi_driver w5100_spi_driver = {
+	.driver		= {
+		.name	= "w5100",
+		.pm	= &w5100_pm_ops,
+	},
+	.probe		= w5100_spi_probe,
+	.remove		= w5100_spi_remove,
+	.id_table	= w5100_spi_ids,
+};
+module_spi_driver(w5100_spi_driver);
+
+MODULE_DESCRIPTION("WIZnet W5100 Ethernet driver for SPI mode");
+MODULE_AUTHOR("Akinobu Mita <akinobu.mita@gmail.com>");
+MODULE_LICENSE("GPL");
-- 
2.5.0
