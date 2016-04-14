From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 5/5] net: w5100: support W5200
Date: Fri, 15 Apr 2016 00:11:33 +0900
Message-ID: <1460646693-25179-6-git-send-email-akinobu.mita@gmail.com>
References: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34220 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbcDNPMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 11:12:03 -0400
Received: by mail-pf0-f180.google.com with SMTP id c20so46899340pfc.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 08:12:02 -0700 (PDT)
In-Reply-To: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for W5200 chip.

W5100 and W5200 have similar memory map although some of their offsets
are different.  The register access sequences between them are different
but w5100 driver has abstraction layer for difference bus interface
modes so it is easy to add W5200 support to w5100 and w5100-spi drivers.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
* v3
- Allocate w5200 ops specific data structure to put DMA-safe buffer
- Add missing chip_id assignment for w5100_*_ops

 drivers/net/ethernet/wiznet/Kconfig     |   2 +-
 drivers/net/ethernet/wiznet/w5100-spi.c | 174 +++++++++++++++++++++++++++++++-
 drivers/net/ethernet/wiznet/w5100.c     | 155 ++++++++++++++++++++--------
 drivers/net/ethernet/wiznet/w5100.h     |   6 ++
 4 files changed, 289 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
index d1ab353..1f15376 100644
--- a/drivers/net/ethernet/wiznet/Kconfig
+++ b/drivers/net/ethernet/wiznet/Kconfig
@@ -70,7 +70,7 @@ config WIZNET_BUS_ANY
 endchoice
 
 config WIZNET_W5100_SPI
-	tristate "WIZnet W5100 Ethernet support for SPI mode"
+	tristate "WIZnet W5100/W5200 Ethernet support for SPI mode"
 	depends on WIZNET_BUS_ANY
 	depends on SPI
 	---help---
diff --git a/drivers/net/ethernet/wiznet/w5100-spi.c b/drivers/net/ethernet/wiznet/w5100-spi.c
index 32f406c..598a7b0 100644
--- a/drivers/net/ethernet/wiznet/w5100-spi.c
+++ b/drivers/net/ethernet/wiznet/w5100-spi.c
@@ -1,9 +1,13 @@
 /*
- * Ethernet driver for the WIZnet W5100 chip.
+ * Ethernet driver for the WIZnet W5100/W5200 chip.
  *
  * Copyright (C) 2016 Akinobu Mita <akinobu.mita@gmail.com>
  *
  * Licensed under the GPL-2 or later.
+ *
+ * Datasheet:
+ * http://www.wiznet.co.kr/wp-content/uploads/wiznethome/Chip/W5100/Document/W5100_Datasheet_v1.2.6.pdf
+ * http://wiznethome.cafe24.com/wp-content/uploads/wiznethome/Chip/W5200/Documents/W5200_DS_V140E.pdf
  */
 
 #include <linux/kernel.h>
@@ -95,6 +99,7 @@ static int w5100_spi_writebulk(struct net_device *ndev, u16 addr, const u8 *buf,
 
 static const struct w5100_ops w5100_spi_ops = {
 	.may_sleep = true,
+	.chip_id = W5100,
 	.read = w5100_spi_read,
 	.write = w5100_spi_write,
 	.read16 = w5100_spi_read16,
@@ -103,10 +108,168 @@ static const struct w5100_ops w5100_spi_ops = {
 	.writebulk = w5100_spi_writebulk,
 };
 
+#define W5200_SPI_WRITE_OPCODE 0x80
+
+struct w5200_spi_priv {
+	/* Serialize access to cmd_buf */
+	struct mutex cmd_lock;
+
+	/* DMA (thus cache coherency maintenance) requires the
+	 * transfer buffers to live in their own cache lines.
+	 */
+	u8 cmd_buf[4] ____cacheline_aligned;
+};
+
+static struct w5200_spi_priv *w5200_spi_priv(struct net_device *ndev)
+{
+	return w5100_ops_priv(ndev);
+}
+
+static int w5200_spi_init(struct net_device *ndev)
+{
+	struct w5200_spi_priv *spi_priv = w5200_spi_priv(ndev);
+
+	mutex_init(&spi_priv->cmd_lock);
+
+	return 0;
+}
+
+static int w5200_spi_read(struct net_device *ndev, u16 addr)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[4] = { addr >> 8, addr & 0xff, 0, 1 };
+	u8 data;
+	int ret;
+
+	ret = spi_write_then_read(spi, cmd, sizeof(cmd), &data, 1);
+
+	return ret ? ret : data;
+}
+
+static int w5200_spi_write(struct net_device *ndev, u16 addr, u8 data)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[5] = { addr >> 8, addr & 0xff, W5200_SPI_WRITE_OPCODE, 1, data };
+
+	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
+}
+
+static int w5200_spi_read16(struct net_device *ndev, u16 addr)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[4] = { addr >> 8, addr & 0xff, 0, 2 };
+	__be16 data;
+	int ret;
+
+	ret = spi_write_then_read(spi, cmd, sizeof(cmd), &data, sizeof(data));
+
+	return ret ? ret : be16_to_cpu(data);
+}
+
+static int w5200_spi_write16(struct net_device *ndev, u16 addr, u16 data)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[6] = {
+		addr >> 8, addr & 0xff,
+		W5200_SPI_WRITE_OPCODE, 2,
+		data >> 8, data & 0xff
+	};
+
+	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
+}
+
+static int w5200_spi_readbulk(struct net_device *ndev, u16 addr, u8 *buf,
+			      int len)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	struct w5200_spi_priv *spi_priv = w5200_spi_priv(ndev);
+	struct spi_transfer xfer[] = {
+		{
+			.tx_buf = spi_priv->cmd_buf,
+			.len = sizeof(spi_priv->cmd_buf),
+		},
+		{
+			.rx_buf = buf,
+			.len = len,
+		},
+	};
+	int ret;
+
+	mutex_lock(&spi_priv->cmd_lock);
+
+	spi_priv->cmd_buf[0] = addr >> 8;
+	spi_priv->cmd_buf[1] = addr;
+	spi_priv->cmd_buf[2] = len >> 8;
+	spi_priv->cmd_buf[3] = len;
+	ret = spi_sync_transfer(spi, xfer, ARRAY_SIZE(xfer));
+
+	mutex_unlock(&spi_priv->cmd_lock);
+
+	return ret;
+}
+
+static int w5200_spi_writebulk(struct net_device *ndev, u16 addr, const u8 *buf,
+			       int len)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	struct w5200_spi_priv *spi_priv = w5200_spi_priv(ndev);
+	struct spi_transfer xfer[] = {
+		{
+			.tx_buf = spi_priv->cmd_buf,
+			.len = sizeof(spi_priv->cmd_buf),
+		},
+		{
+			.tx_buf = buf,
+			.len = len,
+		},
+	};
+	int ret;
+
+	mutex_lock(&spi_priv->cmd_lock);
+
+	spi_priv->cmd_buf[0] = addr >> 8;
+	spi_priv->cmd_buf[1] = addr;
+	spi_priv->cmd_buf[2] = W5200_SPI_WRITE_OPCODE | (len >> 8);
+	spi_priv->cmd_buf[3] = len;
+	ret = spi_sync_transfer(spi, xfer, ARRAY_SIZE(xfer));
+
+	mutex_unlock(&spi_priv->cmd_lock);
+
+	return ret;
+}
+
+static const struct w5100_ops w5200_ops = {
+	.may_sleep = true,
+	.chip_id = W5200,
+	.read = w5200_spi_read,
+	.write = w5200_spi_write,
+	.read16 = w5200_spi_read16,
+	.write16 = w5200_spi_write16,
+	.readbulk = w5200_spi_readbulk,
+	.writebulk = w5200_spi_writebulk,
+	.init = w5200_spi_init,
+};
+
 static int w5100_spi_probe(struct spi_device *spi)
 {
-	return w5100_probe(&spi->dev, &w5100_spi_ops, 0, NULL, spi->irq,
-			   -EINVAL);
+	const struct spi_device_id *id = spi_get_device_id(spi);
+	const struct w5100_ops *ops;
+	int priv_size;
+
+	switch (id->driver_data) {
+	case W5100:
+		ops = &w5100_spi_ops;
+		priv_size = 0;
+		break;
+	case W5200:
+		ops = &w5200_ops;
+		priv_size = sizeof(struct w5200_spi_priv);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return w5100_probe(&spi->dev, ops, priv_size, NULL, spi->irq, -EINVAL);
 }
 
 static int w5100_spi_remove(struct spi_device *spi)
@@ -115,7 +278,8 @@ static int w5100_spi_remove(struct spi_device *spi)
 }
 
 static const struct spi_device_id w5100_spi_ids[] = {
-	{ "w5100", 0 },
+	{ "w5100", W5100 },
+	{ "w5200", W5200 },
 	{}
 };
 MODULE_DEVICE_TABLE(spi, w5100_spi_ids);
@@ -131,6 +295,6 @@ static struct spi_driver w5100_spi_driver = {
 };
 module_spi_driver(w5100_spi_driver);
 
-MODULE_DESCRIPTION("WIZnet W5100 Ethernet driver for SPI mode");
+MODULE_DESCRIPTION("WIZnet W5100/W5200 Ethernet driver for SPI mode");
 MODULE_AUTHOR("Akinobu Mita <akinobu.mita@gmail.com>");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 42a9de4..09149c9 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -38,7 +38,7 @@ MODULE_ALIAS("platform:"DRV_NAME);
 MODULE_LICENSE("GPL");
 
 /*
- * Registers
+ * W5100 and W5100 common registers
  */
 #define W5100_COMMON_REGS	0x0000
 #define W5100_MR		0x0000 /* Mode Register */
@@ -52,37 +52,69 @@ MODULE_LICENSE("GPL");
 #define   IR_S0			  0x01 /* S0 interrupt */
 #define W5100_RTR		0x0017 /* Retry Time-value Register */
 #define   RTR_DEFAULT		  2000 /* =0x07d0 (2000) */
-#define W5100_RMSR		0x001a /* Receive Memory Size */
-#define W5100_TMSR		0x001b /* Transmit Memory Size */
 #define W5100_COMMON_REGS_LEN	0x0040
 
-#define W5100_S0_REGS		0x0400
-#define W5100_S0_MR		0x0400 /* S0 Mode Register */
+#define W5100_Sn_MR		0x0000 /* Sn Mode Register */
+#define W5100_Sn_CR		0x0001 /* Sn Command Register */
+#define W5100_Sn_IR		0x0002 /* Sn Interrupt Register */
+#define W5100_Sn_SR		0x0003 /* Sn Status Register */
+#define W5100_Sn_TX_FSR		0x0020 /* Sn Transmit free memory size */
+#define W5100_Sn_TX_RD		0x0022 /* Sn Transmit memory read pointer */
+#define W5100_Sn_TX_WR		0x0024 /* Sn Transmit memory write pointer */
+#define W5100_Sn_RX_RSR		0x0026 /* Sn Receive free memory size */
+#define W5100_Sn_RX_RD		0x0028 /* Sn Receive memory read pointer */
+
+#define S0_REGS(priv)		(is_w5200(priv) ? W5200_S0_REGS : W5100_S0_REGS)
+
+#define W5100_S0_MR(priv)	(S0_REGS(priv) + W5100_Sn_MR)
 #define   S0_MR_MACRAW		  0x04 /* MAC RAW mode (promiscuous) */
 #define   S0_MR_MACRAW_MF	  0x44 /* MAC RAW mode (filtered) */
-#define W5100_S0_CR		0x0401 /* S0 Command Register */
+#define W5100_S0_CR(priv)	(S0_REGS(priv) + W5100_Sn_CR)
 #define   S0_CR_OPEN		  0x01 /* OPEN command */
 #define   S0_CR_CLOSE		  0x10 /* CLOSE command */
 #define   S0_CR_SEND		  0x20 /* SEND command */
 #define   S0_CR_RECV		  0x40 /* RECV command */
-#define W5100_S0_IR		0x0402 /* S0 Interrupt Register */
+#define W5100_S0_IR(priv)	(S0_REGS(priv) + W5100_Sn_IR)
 #define   S0_IR_SENDOK		  0x10 /* complete sending */
 #define   S0_IR_RECV		  0x04 /* receiving data */
-#define W5100_S0_SR		0x0403 /* S0 Status Register */
+#define W5100_S0_SR(priv)	(S0_REGS(priv) + W5100_Sn_SR)
 #define   S0_SR_MACRAW		  0x42 /* mac raw mode */
-#define W5100_S0_TX_FSR		0x0420 /* S0 Transmit free memory size */
-#define W5100_S0_TX_RD		0x0422 /* S0 Transmit memory read pointer */
-#define W5100_S0_TX_WR		0x0424 /* S0 Transmit memory write pointer */
-#define W5100_S0_RX_RSR		0x0426 /* S0 Receive free memory size */
-#define W5100_S0_RX_RD		0x0428 /* S0 Receive memory read pointer */
+#define W5100_S0_TX_FSR(priv)	(S0_REGS(priv) + W5100_Sn_TX_FSR)
+#define W5100_S0_TX_RD(priv)	(S0_REGS(priv) + W5100_Sn_TX_RD)
+#define W5100_S0_TX_WR(priv)	(S0_REGS(priv) + W5100_Sn_TX_WR)
+#define W5100_S0_RX_RSR(priv)	(S0_REGS(priv) + W5100_Sn_RX_RSR)
+#define W5100_S0_RX_RD(priv)	(S0_REGS(priv) + W5100_Sn_RX_RD)
+
 #define W5100_S0_REGS_LEN	0x0040
 
+/*
+ * W5100 specific registers
+ */
+#define W5100_RMSR		0x001a /* Receive Memory Size */
+#define W5100_TMSR		0x001b /* Transmit Memory Size */
+
+#define W5100_S0_REGS		0x0400
+
 #define W5100_TX_MEM_START	0x4000
 #define W5100_TX_MEM_SIZE	0x2000
 #define W5100_RX_MEM_START	0x6000
 #define W5100_RX_MEM_SIZE	0x2000
 
 /*
+ * W5200 specific registers
+ */
+#define W5200_S0_REGS		0x4000
+
+#define W5200_Sn_RXMEM_SIZE(n)	(0x401e + (n) * 0x0100) /* Sn RX Memory Size */
+#define W5200_Sn_TXMEM_SIZE(n)	(0x401f + (n) * 0x0100) /* Sn TX Memory Size */
+#define W5200_S0_IMR		0x402c /* S0 Interrupt Mask Register */
+
+#define W5200_TX_MEM_START	0x8000
+#define W5200_TX_MEM_SIZE	0x4000
+#define W5200_RX_MEM_START	0xc000
+#define W5200_RX_MEM_SIZE	0x4000
+
+/*
  * Device driver private data structure
  */
 
@@ -105,6 +137,11 @@ struct w5100_priv {
 	struct work_struct restart_work;
 };
 
+static inline bool is_w5200(struct w5100_priv *priv)
+{
+	return priv->ops->chip_id == W5200;
+}
+
 /************************************************************************
  *
  *  Lowlevel I/O functions
@@ -217,6 +254,7 @@ static int w5100_mmio_init(struct net_device *ndev)
 }
 
 static const struct w5100_ops w5100_mmio_direct_ops = {
+	.chip_id = W5100,
 	.read = w5100_read_direct,
 	.write = w5100_write_direct,
 	.read16 = w5100_read16_direct,
@@ -341,6 +379,7 @@ static int w5100_reset_indirect(struct net_device *ndev)
 }
 
 static const struct w5100_ops w5100_mmio_indirect_ops = {
+	.chip_id = W5100,
 	.read = w5100_read_indirect,
 	.write = w5100_write_indirect,
 	.read16 = w5100_read16_indirect,
@@ -457,20 +496,24 @@ static int w5100_readbuf(struct w5100_priv *priv, u16 offset, u8 *buf, int len)
 	u16 addr;
 	int remain = 0;
 	int ret;
+	const u16 mem_start =
+		is_w5200(priv) ? W5200_RX_MEM_START : W5100_RX_MEM_START;
+	const u16 mem_size =
+		is_w5200(priv) ? W5200_RX_MEM_SIZE : W5100_RX_MEM_SIZE;
 
-	offset %= W5100_RX_MEM_SIZE;
-	addr = W5100_RX_MEM_START + offset;
+	offset %= mem_size;
+	addr = mem_start + offset;
 
-	if (offset + len > W5100_RX_MEM_SIZE) {
-		remain = (offset + len) % W5100_RX_MEM_SIZE;
-		len = W5100_RX_MEM_SIZE - offset;
+	if (offset + len > mem_size) {
+		remain = (offset + len) % mem_size;
+		len = mem_size - offset;
 	}
 
 	ret = w5100_readbulk(priv, addr, buf, len);
 	if (ret || !remain)
 		return ret;
 
-	return w5100_readbulk(priv, W5100_RX_MEM_START, buf + len, remain);
+	return w5100_readbulk(priv, mem_start, buf + len, remain);
 }
 
 static int w5100_writebuf(struct w5100_priv *priv, u16 offset, const u8 *buf,
@@ -479,20 +522,24 @@ static int w5100_writebuf(struct w5100_priv *priv, u16 offset, const u8 *buf,
 	u16 addr;
 	int ret;
 	int remain = 0;
+	const u16 mem_start =
+		is_w5200(priv) ? W5200_TX_MEM_START : W5100_TX_MEM_START;
+	const u16 mem_size =
+		is_w5200(priv) ? W5200_TX_MEM_SIZE : W5100_TX_MEM_SIZE;
 
-	offset %= W5100_TX_MEM_SIZE;
-	addr = W5100_TX_MEM_START + offset;
+	offset %= mem_size;
+	addr = mem_start + offset;
 
-	if (offset + len > W5100_TX_MEM_SIZE) {
-		remain = (offset + len) % W5100_TX_MEM_SIZE;
-		len = W5100_TX_MEM_SIZE - offset;
+	if (offset + len > mem_size) {
+		remain = (offset + len) % mem_size;
+		len = mem_size - offset;
 	}
 
 	ret = w5100_writebulk(priv, addr, buf, len);
 	if (ret || !remain)
 		return ret;
 
-	return w5100_writebulk(priv, W5100_TX_MEM_START, buf + len, remain);
+	return w5100_writebulk(priv, mem_start, buf + len, remain);
 }
 
 static int w5100_reset(struct w5100_priv *priv)
@@ -511,11 +558,11 @@ static int w5100_command(struct w5100_priv *priv, u16 cmd)
 {
 	unsigned long timeout;
 
-	w5100_write(priv, W5100_S0_CR, cmd);
+	w5100_write(priv, W5100_S0_CR(priv), cmd);
 
 	timeout = jiffies + msecs_to_jiffies(100);
 
-	while (w5100_read(priv, W5100_S0_CR) != 0) {
+	while (w5100_read(priv, W5100_S0_CR(priv)) != 0) {
 		if (time_after(jiffies, timeout))
 			return -EIO;
 		cpu_relax();
@@ -531,6 +578,31 @@ static void w5100_write_macaddr(struct w5100_priv *priv)
 	w5100_writebulk(priv, W5100_SHAR, ndev->dev_addr, ETH_ALEN);
 }
 
+static void w5100_memory_configure(struct w5100_priv *priv)
+{
+	/* Configure 16K of internal memory
+	 * as 8K RX buffer and 8K TX buffer
+	 */
+	w5100_write(priv, W5100_RMSR, 0x03);
+	w5100_write(priv, W5100_TMSR, 0x03);
+}
+
+static void w5200_memory_configure(struct w5100_priv *priv)
+{
+	int i;
+
+	/* Configure internal RX memory as 16K RX buffer and
+	 * internal TX memory as 16K TX buffer
+	 */
+	w5100_write(priv, W5200_Sn_RXMEM_SIZE(0), 0x10);
+	w5100_write(priv, W5200_Sn_TXMEM_SIZE(0), 0x10);
+
+	for (i = 1; i < 8; i++) {
+		w5100_write(priv, W5200_Sn_RXMEM_SIZE(i), 0);
+		w5100_write(priv, W5200_Sn_TXMEM_SIZE(i), 0);
+	}
+}
+
 static void w5100_hw_reset(struct w5100_priv *priv)
 {
 	w5100_reset(priv);
@@ -538,16 +610,15 @@ static void w5100_hw_reset(struct w5100_priv *priv)
 	w5100_write(priv, W5100_IMR, 0);
 	w5100_write_macaddr(priv);
 
-	/* Configure 16K of internal memory
-	 * as 8K RX buffer and 8K TX buffer
-	 */
-	w5100_write(priv, W5100_RMSR, 0x03);
-	w5100_write(priv, W5100_TMSR, 0x03);
+	if (is_w5200(priv))
+		w5200_memory_configure(priv);
+	else
+		w5100_memory_configure(priv);
 }
 
 static void w5100_hw_start(struct w5100_priv *priv)
 {
-	w5100_write(priv, W5100_S0_MR, priv->promisc ?
+	w5100_write(priv, W5100_S0_MR(priv), priv->promisc ?
 			  S0_MR_MACRAW : S0_MR_MACRAW_MF);
 	w5100_command(priv, S0_CR_OPEN);
 	w5100_write(priv, W5100_IMR, IR_S0);
@@ -611,7 +682,7 @@ static void w5100_get_regs(struct net_device *ndev,
 	regs->version = 1;
 	w5100_readbulk(priv, W5100_COMMON_REGS, buf, W5100_COMMON_REGS_LEN);
 	buf += W5100_COMMON_REGS_LEN;
-	w5100_readbulk(priv, W5100_S0_REGS, buf, W5100_S0_REGS_LEN);
+	w5100_readbulk(priv, S0_REGS(priv), buf, W5100_S0_REGS_LEN);
 }
 
 static void w5100_restart(struct net_device *ndev)
@@ -649,9 +720,9 @@ static void w5100_tx_skb(struct net_device *ndev, struct sk_buff *skb)
 	struct w5100_priv *priv = netdev_priv(ndev);
 	u16 offset;
 
-	offset = w5100_read16(priv, W5100_S0_TX_WR);
+	offset = w5100_read16(priv, W5100_S0_TX_WR(priv));
 	w5100_writebuf(priv, offset, skb->data, skb->len);
-	w5100_write16(priv, W5100_S0_TX_WR, offset + skb->len);
+	w5100_write16(priv, W5100_S0_TX_WR(priv), offset + skb->len);
 	ndev->stats.tx_bytes += skb->len;
 	ndev->stats.tx_packets++;
 	dev_kfree_skb(skb);
@@ -696,18 +767,18 @@ static struct sk_buff *w5100_rx_skb(struct net_device *ndev)
 	u16 rx_len;
 	u16 offset;
 	u8 header[2];
-	u16 rx_buf_len = w5100_read16(priv, W5100_S0_RX_RSR);
+	u16 rx_buf_len = w5100_read16(priv, W5100_S0_RX_RSR(priv));
 
 	if (rx_buf_len == 0)
 		return NULL;
 
-	offset = w5100_read16(priv, W5100_S0_RX_RD);
+	offset = w5100_read16(priv, W5100_S0_RX_RD(priv));
 	w5100_readbuf(priv, offset, header, 2);
 	rx_len = get_unaligned_be16(header) - 2;
 
 	skb = netdev_alloc_skb_ip_align(ndev, rx_len);
 	if (unlikely(!skb)) {
-		w5100_write16(priv, W5100_S0_RX_RD, offset + rx_buf_len);
+		w5100_write16(priv, W5100_S0_RX_RD(priv), offset + rx_buf_len);
 		w5100_command(priv, S0_CR_RECV);
 		ndev->stats.rx_dropped++;
 		return NULL;
@@ -715,7 +786,7 @@ static struct sk_buff *w5100_rx_skb(struct net_device *ndev)
 
 	skb_put(skb, rx_len);
 	w5100_readbuf(priv, offset + 2, skb->data, rx_len);
-	w5100_write16(priv, W5100_S0_RX_RD, offset + 2 + rx_len);
+	w5100_write16(priv, W5100_S0_RX_RD(priv), offset + 2 + rx_len);
 	w5100_command(priv, S0_CR_RECV);
 	skb->protocol = eth_type_trans(skb, ndev);
 
@@ -764,10 +835,10 @@ static irqreturn_t w5100_interrupt(int irq, void *ndev_instance)
 	struct net_device *ndev = ndev_instance;
 	struct w5100_priv *priv = netdev_priv(ndev);
 
-	int ir = w5100_read(priv, W5100_S0_IR);
+	int ir = w5100_read(priv, W5100_S0_IR(priv));
 	if (!ir)
 		return IRQ_NONE;
-	w5100_write(priv, W5100_S0_IR, ir);
+	w5100_write(priv, W5100_S0_IR(priv), ir);
 
 	if (ir & S0_IR_SENDOK) {
 		netif_dbg(priv, tx_done, ndev, "tx done\n");
diff --git a/drivers/net/ethernet/wiznet/w5100.h b/drivers/net/ethernet/wiznet/w5100.h
index 69045f0..9b1fa23 100644
--- a/drivers/net/ethernet/wiznet/w5100.h
+++ b/drivers/net/ethernet/wiznet/w5100.h
@@ -7,8 +7,14 @@
  * Licensed under the GPL-2 or later.
  */
 
+enum {
+	W5100,
+	W5200,
+};
+
 struct w5100_ops {
 	bool may_sleep;
+	int chip_id;
 	int (*read)(struct net_device *ndev, u16 addr);
 	int (*write)(struct net_device *ndev, u16 addr, u8 data);
 	int (*read16)(struct net_device *ndev, u16 addr);
-- 
2.5.0
