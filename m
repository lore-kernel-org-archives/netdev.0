From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next] net: w5100: support W5500
Date: Wed, 27 Apr 2016 05:43:48 +0900
Message-ID: <1461703428-8078-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34964 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbcDZUoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:44:03 -0400
Received: by mail-pa0-f41.google.com with SMTP id iv1so10858944pac.2
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 13:44:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for W5500 chip.

W5500 has similar register and memory organization with W5100 and W5200.
There are a few important differences listed below but it is still
possible to share common code with W5100 and W5200.

* W5500 register and memory are organized by multiple blocks.  Each one
is selected by 16bits offset address and 5bits block select bits.

But the existing register access operations take u16 address.  This change
extends the addess by u32 address and put offset address to lower 16bits
and block select bits to upper 16bits.

This change also adds the offset addresses for socket register and TX/RX
memory blocks to the driver private data structure in order to reduce
conditional switches for each chip.

* W5500 has the different register offset for socket interrupt mask
register.  Newly added internal functions w5100_enable_intr() and
w5100_disable_intr() take care of the diffrence.

* W5500 has the different register offset for retry time-value register.
But this register is only used to verify that the reset value is correctly
read at initialization.  So move the verification to w5100_hw_reset()
which already does different things for different chips.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/wiznet/Kconfig     |   2 +-
 drivers/net/ethernet/wiznet/w5100-spi.c | 192 +++++++++++++++++++++++--
 drivers/net/ethernet/wiznet/w5100.c     | 243 +++++++++++++++++++++++---------
 drivers/net/ethernet/wiznet/w5100.h     |  13 +-
 4 files changed, 365 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
index f3385a1..1981e88c 100644
--- a/drivers/net/ethernet/wiznet/Kconfig
+++ b/drivers/net/ethernet/wiznet/Kconfig
@@ -70,7 +70,7 @@ config WIZNET_BUS_ANY
 endchoice
 
 config WIZNET_W5100_SPI
-	tristate "WIZnet W5100/W5200 Ethernet support for SPI mode"
+	tristate "WIZnet W5100/W5200/W5500 Ethernet support for SPI mode"
 	depends on WIZNET_BUS_ANY && WIZNET_W5100
 	depends on SPI
 	---help---
diff --git a/drivers/net/ethernet/wiznet/w5100-spi.c b/drivers/net/ethernet/wiznet/w5100-spi.c
index 598a7b0..b868e45 100644
--- a/drivers/net/ethernet/wiznet/w5100-spi.c
+++ b/drivers/net/ethernet/wiznet/w5100-spi.c
@@ -1,5 +1,5 @@
 /*
- * Ethernet driver for the WIZnet W5100/W5200 chip.
+ * Ethernet driver for the WIZnet W5100/W5200/W5500 chip.
  *
  * Copyright (C) 2016 Akinobu Mita <akinobu.mita@gmail.com>
  *
@@ -8,6 +8,7 @@
  * Datasheet:
  * http://www.wiznet.co.kr/wp-content/uploads/wiznethome/Chip/W5100/Document/W5100_Datasheet_v1.2.6.pdf
  * http://wiznethome.cafe24.com/wp-content/uploads/wiznethome/Chip/W5200/Documents/W5200_DS_V140E.pdf
+ * http://wizwiki.net/wiki/lib/exe/fetch.php?media=products:w5500:w5500_ds_v106e_141230.pdf
  */
 
 #include <linux/kernel.h>
@@ -21,7 +22,7 @@
 #define W5100_SPI_WRITE_OPCODE 0xf0
 #define W5100_SPI_READ_OPCODE 0x0f
 
-static int w5100_spi_read(struct net_device *ndev, u16 addr)
+static int w5100_spi_read(struct net_device *ndev, u32 addr)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
 	u8 cmd[3] = { W5100_SPI_READ_OPCODE, addr >> 8, addr & 0xff };
@@ -33,7 +34,7 @@ static int w5100_spi_read(struct net_device *ndev, u16 addr)
 	return ret ? ret : data;
 }
 
-static int w5100_spi_write(struct net_device *ndev, u16 addr, u8 data)
+static int w5100_spi_write(struct net_device *ndev, u32 addr, u8 data)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
 	u8 cmd[4] = { W5100_SPI_WRITE_OPCODE, addr >> 8, addr & 0xff, data};
@@ -41,7 +42,7 @@ static int w5100_spi_write(struct net_device *ndev, u16 addr, u8 data)
 	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
 }
 
-static int w5100_spi_read16(struct net_device *ndev, u16 addr)
+static int w5100_spi_read16(struct net_device *ndev, u32 addr)
 {
 	u16 data;
 	int ret;
@@ -55,7 +56,7 @@ static int w5100_spi_read16(struct net_device *ndev, u16 addr)
 	return ret < 0 ? ret : data | ret;
 }
 
-static int w5100_spi_write16(struct net_device *ndev, u16 addr, u16 data)
+static int w5100_spi_write16(struct net_device *ndev, u32 addr, u16 data)
 {
 	int ret;
 
@@ -66,7 +67,7 @@ static int w5100_spi_write16(struct net_device *ndev, u16 addr, u16 data)
 	return w5100_spi_write(ndev, addr + 1, data & 0xff);
 }
 
-static int w5100_spi_readbulk(struct net_device *ndev, u16 addr, u8 *buf,
+static int w5100_spi_readbulk(struct net_device *ndev, u32 addr, u8 *buf,
 			      int len)
 {
 	int i;
@@ -82,7 +83,7 @@ static int w5100_spi_readbulk(struct net_device *ndev, u16 addr, u8 *buf,
 	return 0;
 }
 
-static int w5100_spi_writebulk(struct net_device *ndev, u16 addr, const u8 *buf,
+static int w5100_spi_writebulk(struct net_device *ndev, u32 addr, const u8 *buf,
 			       int len)
 {
 	int i;
@@ -134,7 +135,7 @@ static int w5200_spi_init(struct net_device *ndev)
 	return 0;
 }
 
-static int w5200_spi_read(struct net_device *ndev, u16 addr)
+static int w5200_spi_read(struct net_device *ndev, u32 addr)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
 	u8 cmd[4] = { addr >> 8, addr & 0xff, 0, 1 };
@@ -146,7 +147,7 @@ static int w5200_spi_read(struct net_device *ndev, u16 addr)
 	return ret ? ret : data;
 }
 
-static int w5200_spi_write(struct net_device *ndev, u16 addr, u8 data)
+static int w5200_spi_write(struct net_device *ndev, u32 addr, u8 data)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
 	u8 cmd[5] = { addr >> 8, addr & 0xff, W5200_SPI_WRITE_OPCODE, 1, data };
@@ -154,7 +155,7 @@ static int w5200_spi_write(struct net_device *ndev, u16 addr, u8 data)
 	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
 }
 
-static int w5200_spi_read16(struct net_device *ndev, u16 addr)
+static int w5200_spi_read16(struct net_device *ndev, u32 addr)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
 	u8 cmd[4] = { addr >> 8, addr & 0xff, 0, 2 };
@@ -166,7 +167,7 @@ static int w5200_spi_read16(struct net_device *ndev, u16 addr)
 	return ret ? ret : be16_to_cpu(data);
 }
 
-static int w5200_spi_write16(struct net_device *ndev, u16 addr, u16 data)
+static int w5200_spi_write16(struct net_device *ndev, u32 addr, u16 data)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
 	u8 cmd[6] = {
@@ -178,7 +179,7 @@ static int w5200_spi_write16(struct net_device *ndev, u16 addr, u16 data)
 	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
 }
 
-static int w5200_spi_readbulk(struct net_device *ndev, u16 addr, u8 *buf,
+static int w5200_spi_readbulk(struct net_device *ndev, u32 addr, u8 *buf,
 			      int len)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
@@ -208,7 +209,7 @@ static int w5200_spi_readbulk(struct net_device *ndev, u16 addr, u8 *buf,
 	return ret;
 }
 
-static int w5200_spi_writebulk(struct net_device *ndev, u16 addr, const u8 *buf,
+static int w5200_spi_writebulk(struct net_device *ndev, u32 addr, const u8 *buf,
 			       int len)
 {
 	struct spi_device *spi = to_spi_device(ndev->dev.parent);
@@ -250,6 +251,164 @@ static const struct w5100_ops w5200_ops = {
 	.init = w5200_spi_init,
 };
 
+#define W5500_SPI_BLOCK_SELECT(addr) (((addr) >> 16) & 0x1f)
+#define W5500_SPI_READ_CONTROL(addr) (W5500_SPI_BLOCK_SELECT(addr) << 3)
+#define W5500_SPI_WRITE_CONTROL(addr)	\
+	((W5500_SPI_BLOCK_SELECT(addr) << 3) | BIT(2))
+
+struct w5500_spi_priv {
+	/* Serialize access to cmd_buf */
+	struct mutex cmd_lock;
+
+	/* DMA (thus cache coherency maintenance) requires the
+	 * transfer buffers to live in their own cache lines.
+	 */
+	u8 cmd_buf[3] ____cacheline_aligned;
+};
+
+static struct w5500_spi_priv *w5500_spi_priv(struct net_device *ndev)
+{
+	return w5100_ops_priv(ndev);
+}
+
+static int w5500_spi_init(struct net_device *ndev)
+{
+	struct w5500_spi_priv *spi_priv = w5500_spi_priv(ndev);
+
+	mutex_init(&spi_priv->cmd_lock);
+
+	return 0;
+}
+
+static int w5500_spi_read(struct net_device *ndev, u32 addr)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[3] = {
+		addr >> 8,
+		addr,
+		W5500_SPI_READ_CONTROL(addr)
+	};
+	u8 data;
+	int ret;
+
+	ret = spi_write_then_read(spi, cmd, sizeof(cmd), &data, 1);
+
+	return ret ? ret : data;
+}
+
+static int w5500_spi_write(struct net_device *ndev, u32 addr, u8 data)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[4] = {
+		addr >> 8,
+		addr,
+		W5500_SPI_WRITE_CONTROL(addr),
+		data
+	};
+
+	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
+}
+
+static int w5500_spi_read16(struct net_device *ndev, u32 addr)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[3] = {
+		addr >> 8,
+		addr,
+		W5500_SPI_READ_CONTROL(addr)
+	};
+	__be16 data;
+	int ret;
+
+	ret = spi_write_then_read(spi, cmd, sizeof(cmd), &data, sizeof(data));
+
+	return ret ? ret : be16_to_cpu(data);
+}
+
+static int w5500_spi_write16(struct net_device *ndev, u32 addr, u16 data)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	u8 cmd[5] = {
+		addr >> 8,
+		addr,
+		W5500_SPI_WRITE_CONTROL(addr),
+		data >> 8,
+		data
+	};
+
+	return spi_write_then_read(spi, cmd, sizeof(cmd), NULL, 0);
+}
+
+static int w5500_spi_readbulk(struct net_device *ndev, u32 addr, u8 *buf,
+			      int len)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	struct w5500_spi_priv *spi_priv = w5500_spi_priv(ndev);
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
+	spi_priv->cmd_buf[2] = W5500_SPI_READ_CONTROL(addr);
+	ret = spi_sync_transfer(spi, xfer, ARRAY_SIZE(xfer));
+
+	mutex_unlock(&spi_priv->cmd_lock);
+
+	return ret;
+}
+
+static int w5500_spi_writebulk(struct net_device *ndev, u32 addr, const u8 *buf,
+			       int len)
+{
+	struct spi_device *spi = to_spi_device(ndev->dev.parent);
+	struct w5500_spi_priv *spi_priv = w5500_spi_priv(ndev);
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
+	spi_priv->cmd_buf[2] = W5500_SPI_WRITE_CONTROL(addr);
+	ret = spi_sync_transfer(spi, xfer, ARRAY_SIZE(xfer));
+
+	mutex_unlock(&spi_priv->cmd_lock);
+
+	return ret;
+}
+
+static const struct w5100_ops w5500_ops = {
+	.may_sleep = true,
+	.chip_id = W5500,
+	.read = w5500_spi_read,
+	.write = w5500_spi_write,
+	.read16 = w5500_spi_read16,
+	.write16 = w5500_spi_write16,
+	.readbulk = w5500_spi_readbulk,
+	.writebulk = w5500_spi_writebulk,
+	.init = w5500_spi_init,
+};
+
 static int w5100_spi_probe(struct spi_device *spi)
 {
 	const struct spi_device_id *id = spi_get_device_id(spi);
@@ -265,6 +424,10 @@ static int w5100_spi_probe(struct spi_device *spi)
 		ops = &w5200_ops;
 		priv_size = sizeof(struct w5200_spi_priv);
 		break;
+	case W5500:
+		ops = &w5500_ops;
+		priv_size = sizeof(struct w5500_spi_priv);
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -280,6 +443,7 @@ static int w5100_spi_remove(struct spi_device *spi)
 static const struct spi_device_id w5100_spi_ids[] = {
 	{ "w5100", W5100 },
 	{ "w5200", W5200 },
+	{ "w5500", W5500 },
 	{}
 };
 MODULE_DEVICE_TABLE(spi, w5100_spi_ids);
@@ -295,6 +459,6 @@ static struct spi_driver w5100_spi_driver = {
 };
 module_spi_driver(w5100_spi_driver);
 
-MODULE_DESCRIPTION("WIZnet W5100/W5200 Ethernet driver for SPI mode");
+MODULE_DESCRIPTION("WIZnet W5100/W5200/W5500 Ethernet driver for SPI mode");
 MODULE_AUTHOR("Akinobu Mita <akinobu.mita@gmail.com>");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 09149c9..8ed0c77 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -38,7 +38,7 @@ MODULE_ALIAS("platform:"DRV_NAME);
 MODULE_LICENSE("GPL");
 
 /*
- * W5100 and W5100 common registers
+ * W5100/W5200/W5500 common registers
  */
 #define W5100_COMMON_REGS	0x0000
 #define W5100_MR		0x0000 /* Mode Register */
@@ -48,10 +48,6 @@ MODULE_LICENSE("GPL");
 #define   MR_IND		  0x01 /* Indirect mode */
 #define W5100_SHAR		0x0009 /* Source MAC address */
 #define W5100_IR		0x0015 /* Interrupt Register */
-#define W5100_IMR		0x0016 /* Interrupt Mask Register */
-#define   IR_S0			  0x01 /* S0 interrupt */
-#define W5100_RTR		0x0017 /* Retry Time-value Register */
-#define   RTR_DEFAULT		  2000 /* =0x07d0 (2000) */
 #define W5100_COMMON_REGS_LEN	0x0040
 
 #define W5100_Sn_MR		0x0000 /* Sn Mode Register */
@@ -64,7 +60,7 @@ MODULE_LICENSE("GPL");
 #define W5100_Sn_RX_RSR		0x0026 /* Sn Receive free memory size */
 #define W5100_Sn_RX_RD		0x0028 /* Sn Receive memory read pointer */
 
-#define S0_REGS(priv)		(is_w5200(priv) ? W5200_S0_REGS : W5100_S0_REGS)
+#define S0_REGS(priv)		((priv)->s0_regs)
 
 #define W5100_S0_MR(priv)	(S0_REGS(priv) + W5100_Sn_MR)
 #define   S0_MR_MACRAW		  0x04 /* MAC RAW mode (promiscuous) */
@@ -88,7 +84,15 @@ MODULE_LICENSE("GPL");
 #define W5100_S0_REGS_LEN	0x0040
 
 /*
- * W5100 specific registers
+ * W5100 and W5200 common registers
+ */
+#define W5100_IMR		0x0016 /* Interrupt Mask Register */
+#define   IR_S0			  0x01 /* S0 interrupt */
+#define W5100_RTR		0x0017 /* Retry Time-value Register */
+#define   RTR_DEFAULT		  2000 /* =0x07d0 (2000) */
+
+/*
+ * W5100 specific register and memory
  */
 #define W5100_RMSR		0x001a /* Receive Memory Size */
 #define W5100_TMSR		0x001b /* Transmit Memory Size */
@@ -101,13 +105,12 @@ MODULE_LICENSE("GPL");
 #define W5100_RX_MEM_SIZE	0x2000
 
 /*
- * W5200 specific registers
+ * W5200 specific register and memory
  */
 #define W5200_S0_REGS		0x4000
 
 #define W5200_Sn_RXMEM_SIZE(n)	(0x401e + (n) * 0x0100) /* Sn RX Memory Size */
 #define W5200_Sn_TXMEM_SIZE(n)	(0x401f + (n) * 0x0100) /* Sn TX Memory Size */
-#define W5200_S0_IMR		0x402c /* S0 Interrupt Mask Register */
 
 #define W5200_TX_MEM_START	0x8000
 #define W5200_TX_MEM_SIZE	0x4000
@@ -115,11 +118,44 @@ MODULE_LICENSE("GPL");
 #define W5200_RX_MEM_SIZE	0x4000
 
 /*
+ * W5500 specific register and memory
+ *
+ * W5500 register and memory are organized by multiple blocks.  Each one is
+ * selected by 16bits offset address and 5bits block select bits.  So we
+ * encode it into 32bits address. (lower 16bits is offset address and
+ * upper 16bits is block select bits)
+ */
+#define W5500_SIMR		0x0018 /* Socket Interrupt Mask Register */
+#define W5500_RTR		0x0019 /* Retry Time-value Register */
+
+#define W5500_S0_REGS		0x10000
+
+#define W5500_Sn_RXMEM_SIZE(n)	\
+		(0x1001e + (n) * 0x40000) /* Sn RX Memory Size */
+#define W5500_Sn_TXMEM_SIZE(n)	\
+		(0x1001f + (n) * 0x40000) /* Sn TX Memory Size */
+
+#define W5500_TX_MEM_START	0x20000
+#define W5500_TX_MEM_SIZE	0x04000
+#define W5500_RX_MEM_START	0x30000
+#define W5500_RX_MEM_SIZE	0x04000
+
+/*
  * Device driver private data structure
  */
 
 struct w5100_priv {
 	const struct w5100_ops *ops;
+
+	/* Socket 0 register offset address */
+	u32 s0_regs;
+	/* Socket 0 TX buffer offset address and size */
+	u32 s0_tx_buf;
+	u16 s0_tx_buf_size;
+	/* Socket 0 RX buffer offset address and size */
+	u32 s0_rx_buf;
+	u16 s0_rx_buf_size;
+
 	int irq;
 	int link_irq;
 	int link_gpio;
@@ -172,12 +208,12 @@ static inline void __iomem *w5100_mmio(struct net_device *ndev)
  *
  * 0x8000 bytes are required for memory space.
  */
-static inline int w5100_read_direct(struct net_device *ndev, u16 addr)
+static inline int w5100_read_direct(struct net_device *ndev, u32 addr)
 {
 	return ioread8(w5100_mmio(ndev) + (addr << CONFIG_WIZNET_BUS_SHIFT));
 }
 
-static inline int __w5100_write_direct(struct net_device *ndev, u16 addr,
+static inline int __w5100_write_direct(struct net_device *ndev, u32 addr,
 				       u8 data)
 {
 	iowrite8(data, w5100_mmio(ndev) + (addr << CONFIG_WIZNET_BUS_SHIFT));
@@ -185,7 +221,7 @@ static inline int __w5100_write_direct(struct net_device *ndev, u16 addr,
 	return 0;
 }
 
-static inline int w5100_write_direct(struct net_device *ndev, u16 addr, u8 data)
+static inline int w5100_write_direct(struct net_device *ndev, u32 addr, u8 data)
 {
 	__w5100_write_direct(ndev, addr, data);
 	mmiowb();
@@ -193,7 +229,7 @@ static inline int w5100_write_direct(struct net_device *ndev, u16 addr, u8 data)
 	return 0;
 }
 
-static int w5100_read16_direct(struct net_device *ndev, u16 addr)
+static int w5100_read16_direct(struct net_device *ndev, u32 addr)
 {
 	u16 data;
 	data  = w5100_read_direct(ndev, addr) << 8;
@@ -201,7 +237,7 @@ static int w5100_read16_direct(struct net_device *ndev, u16 addr)
 	return data;
 }
 
-static int w5100_write16_direct(struct net_device *ndev, u16 addr, u16 data)
+static int w5100_write16_direct(struct net_device *ndev, u32 addr, u16 data)
 {
 	__w5100_write_direct(ndev, addr, data >> 8);
 	__w5100_write_direct(ndev, addr + 1, data);
@@ -210,7 +246,7 @@ static int w5100_write16_direct(struct net_device *ndev, u16 addr, u16 data)
 	return 0;
 }
 
-static int w5100_readbulk_direct(struct net_device *ndev, u16 addr, u8 *buf,
+static int w5100_readbulk_direct(struct net_device *ndev, u32 addr, u8 *buf,
 				 int len)
 {
 	int i;
@@ -221,7 +257,7 @@ static int w5100_readbulk_direct(struct net_device *ndev, u16 addr, u8 *buf,
 	return 0;
 }
 
-static int w5100_writebulk_direct(struct net_device *ndev, u16 addr,
+static int w5100_writebulk_direct(struct net_device *ndev, u32 addr,
 				  const u8 *buf, int len)
 {
 	int i;
@@ -275,7 +311,7 @@ static const struct w5100_ops w5100_mmio_direct_ops = {
 #define W5100_IDM_AR		0x01   /* Indirect Mode Address Register */
 #define W5100_IDM_DR		0x03   /* Indirect Mode Data Register */
 
-static int w5100_read_indirect(struct net_device *ndev, u16 addr)
+static int w5100_read_indirect(struct net_device *ndev, u32 addr)
 {
 	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
@@ -289,7 +325,7 @@ static int w5100_read_indirect(struct net_device *ndev, u16 addr)
 	return data;
 }
 
-static int w5100_write_indirect(struct net_device *ndev, u16 addr, u8 data)
+static int w5100_write_indirect(struct net_device *ndev, u32 addr, u8 data)
 {
 	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
@@ -302,7 +338,7 @@ static int w5100_write_indirect(struct net_device *ndev, u16 addr, u8 data)
 	return 0;
 }
 
-static int w5100_read16_indirect(struct net_device *ndev, u16 addr)
+static int w5100_read16_indirect(struct net_device *ndev, u32 addr)
 {
 	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
@@ -317,7 +353,7 @@ static int w5100_read16_indirect(struct net_device *ndev, u16 addr)
 	return data;
 }
 
-static int w5100_write16_indirect(struct net_device *ndev, u16 addr, u16 data)
+static int w5100_write16_indirect(struct net_device *ndev, u32 addr, u16 data)
 {
 	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
@@ -331,7 +367,7 @@ static int w5100_write16_indirect(struct net_device *ndev, u16 addr, u16 data)
 	return 0;
 }
 
-static int w5100_readbulk_indirect(struct net_device *ndev, u16 addr, u8 *buf,
+static int w5100_readbulk_indirect(struct net_device *ndev, u32 addr, u8 *buf,
 				   int len)
 {
 	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
@@ -350,7 +386,7 @@ static int w5100_readbulk_indirect(struct net_device *ndev, u16 addr, u8 *buf,
 	return 0;
 }
 
-static int w5100_writebulk_indirect(struct net_device *ndev, u16 addr,
+static int w5100_writebulk_indirect(struct net_device *ndev, u32 addr,
 				    const u8 *buf, int len)
 {
 	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
@@ -392,32 +428,32 @@ static const struct w5100_ops w5100_mmio_indirect_ops = {
 
 #if defined(CONFIG_WIZNET_BUS_DIRECT)
 
-static int w5100_read(struct w5100_priv *priv, u16 addr)
+static int w5100_read(struct w5100_priv *priv, u32 addr)
 {
 	return w5100_read_direct(priv->ndev, addr);
 }
 
-static int w5100_write(struct w5100_priv *priv, u16 addr, u8 data)
+static int w5100_write(struct w5100_priv *priv, u32 addr, u8 data)
 {
 	return w5100_write_direct(priv->ndev, addr, data);
 }
 
-static int w5100_read16(struct w5100_priv *priv, u16 addr)
+static int w5100_read16(struct w5100_priv *priv, u32 addr)
 {
 	return w5100_read16_direct(priv->ndev, addr);
 }
 
-static int w5100_write16(struct w5100_priv *priv, u16 addr, u16 data)
+static int w5100_write16(struct w5100_priv *priv, u32 addr, u16 data)
 {
 	return w5100_write16_direct(priv->ndev, addr, data);
 }
 
-static int w5100_readbulk(struct w5100_priv *priv, u16 addr, u8 *buf, int len)
+static int w5100_readbulk(struct w5100_priv *priv, u32 addr, u8 *buf, int len)
 {
 	return w5100_readbulk_direct(priv->ndev, addr, buf, len);
 }
 
-static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
+static int w5100_writebulk(struct w5100_priv *priv, u32 addr, const u8 *buf,
 			   int len)
 {
 	return w5100_writebulk_direct(priv->ndev, addr, buf, len);
@@ -425,32 +461,32 @@ static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
 
 #elif defined(CONFIG_WIZNET_BUS_INDIRECT)
 
-static int w5100_read(struct w5100_priv *priv, u16 addr)
+static int w5100_read(struct w5100_priv *priv, u32 addr)
 {
 	return w5100_read_indirect(priv->ndev, addr);
 }
 
-static int w5100_write(struct w5100_priv *priv, u16 addr, u8 data)
+static int w5100_write(struct w5100_priv *priv, u32 addr, u8 data)
 {
 	return w5100_write_indirect(priv->ndev, addr, data);
 }
 
-static int w5100_read16(struct w5100_priv *priv, u16 addr)
+static int w5100_read16(struct w5100_priv *priv, u32 addr)
 {
 	return w5100_read16_indirect(priv->ndev, addr);
 }
 
-static int w5100_write16(struct w5100_priv *priv, u16 addr, u16 data)
+static int w5100_write16(struct w5100_priv *priv, u32 addr, u16 data)
 {
 	return w5100_write16_indirect(priv->ndev, addr, data);
 }
 
-static int w5100_readbulk(struct w5100_priv *priv, u16 addr, u8 *buf, int len)
+static int w5100_readbulk(struct w5100_priv *priv, u32 addr, u8 *buf, int len)
 {
 	return w5100_readbulk_indirect(priv->ndev, addr, buf, len);
 }
 
-static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
+static int w5100_writebulk(struct w5100_priv *priv, u32 addr, const u8 *buf,
 			   int len)
 {
 	return w5100_writebulk_indirect(priv->ndev, addr, buf, len);
@@ -458,32 +494,32 @@ static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
 
 #else /* CONFIG_WIZNET_BUS_ANY */
 
-static int w5100_read(struct w5100_priv *priv, u16 addr)
+static int w5100_read(struct w5100_priv *priv, u32 addr)
 {
 	return priv->ops->read(priv->ndev, addr);
 }
 
-static int w5100_write(struct w5100_priv *priv, u16 addr, u8 data)
+static int w5100_write(struct w5100_priv *priv, u32 addr, u8 data)
 {
 	return priv->ops->write(priv->ndev, addr, data);
 }
 
-static int w5100_read16(struct w5100_priv *priv, u16 addr)
+static int w5100_read16(struct w5100_priv *priv, u32 addr)
 {
 	return priv->ops->read16(priv->ndev, addr);
 }
 
-static int w5100_write16(struct w5100_priv *priv, u16 addr, u16 data)
+static int w5100_write16(struct w5100_priv *priv, u32 addr, u16 data)
 {
 	return priv->ops->write16(priv->ndev, addr, data);
 }
 
-static int w5100_readbulk(struct w5100_priv *priv, u16 addr, u8 *buf, int len)
+static int w5100_readbulk(struct w5100_priv *priv, u32 addr, u8 *buf, int len)
 {
 	return priv->ops->readbulk(priv->ndev, addr, buf, len);
 }
 
-static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
+static int w5100_writebulk(struct w5100_priv *priv, u32 addr, const u8 *buf,
 			   int len)
 {
 	return priv->ops->writebulk(priv->ndev, addr, buf, len);
@@ -493,13 +529,11 @@ static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
 
 static int w5100_readbuf(struct w5100_priv *priv, u16 offset, u8 *buf, int len)
 {
-	u16 addr;
+	u32 addr;
 	int remain = 0;
 	int ret;
-	const u16 mem_start =
-		is_w5200(priv) ? W5200_RX_MEM_START : W5100_RX_MEM_START;
-	const u16 mem_size =
-		is_w5200(priv) ? W5200_RX_MEM_SIZE : W5100_RX_MEM_SIZE;
+	const u32 mem_start = priv->s0_rx_buf;
+	const u16 mem_size = priv->s0_rx_buf_size;
 
 	offset %= mem_size;
 	addr = mem_start + offset;
@@ -519,13 +553,11 @@ static int w5100_readbuf(struct w5100_priv *priv, u16 offset, u8 *buf, int len)
 static int w5100_writebuf(struct w5100_priv *priv, u16 offset, const u8 *buf,
 			  int len)
 {
-	u16 addr;
+	u32 addr;
 	int ret;
 	int remain = 0;
-	const u16 mem_start =
-		is_w5200(priv) ? W5200_TX_MEM_START : W5100_TX_MEM_START;
-	const u16 mem_size =
-		is_w5200(priv) ? W5200_TX_MEM_SIZE : W5100_TX_MEM_SIZE;
+	const u32 mem_start = priv->s0_tx_buf;
+	const u16 mem_size = priv->s0_tx_buf_size;
 
 	offset %= mem_size;
 	addr = mem_start + offset;
@@ -578,6 +610,28 @@ static void w5100_write_macaddr(struct w5100_priv *priv)
 	w5100_writebulk(priv, W5100_SHAR, ndev->dev_addr, ETH_ALEN);
 }
 
+static void w5100_socket_intr_mask(struct w5100_priv *priv, u8 mask)
+{
+	u32 imr;
+
+	if (priv->ops->chip_id == W5500)
+		imr = W5500_SIMR;
+	else
+		imr = W5100_IMR;
+
+	w5100_write(priv, imr, mask);
+}
+
+static void w5100_enable_intr(struct w5100_priv *priv)
+{
+	w5100_socket_intr_mask(priv, IR_S0);
+}
+
+static void w5100_disable_intr(struct w5100_priv *priv)
+{
+	w5100_socket_intr_mask(priv, 0);
+}
+
 static void w5100_memory_configure(struct w5100_priv *priv)
 {
 	/* Configure 16K of internal memory
@@ -603,17 +657,52 @@ static void w5200_memory_configure(struct w5100_priv *priv)
 	}
 }
 
-static void w5100_hw_reset(struct w5100_priv *priv)
+static void w5500_memory_configure(struct w5100_priv *priv)
 {
+	int i;
+
+	/* Configure internal RX memory as 16K RX buffer and
+	 * internal TX memory as 16K TX buffer
+	 */
+	w5100_write(priv, W5500_Sn_RXMEM_SIZE(0), 0x10);
+	w5100_write(priv, W5500_Sn_TXMEM_SIZE(0), 0x10);
+
+	for (i = 1; i < 8; i++) {
+		w5100_write(priv, W5500_Sn_RXMEM_SIZE(i), 0);
+		w5100_write(priv, W5500_Sn_TXMEM_SIZE(i), 0);
+	}
+}
+
+static int w5100_hw_reset(struct w5100_priv *priv)
+{
+	u32 rtr;
+
 	w5100_reset(priv);
 
-	w5100_write(priv, W5100_IMR, 0);
+	w5100_disable_intr(priv);
 	w5100_write_macaddr(priv);
 
-	if (is_w5200(priv))
-		w5200_memory_configure(priv);
-	else
+	switch (priv->ops->chip_id) {
+	case W5100:
 		w5100_memory_configure(priv);
+		rtr = W5100_RTR;
+		break;
+	case W5200:
+		w5200_memory_configure(priv);
+		rtr = W5100_RTR;
+		break;
+	case W5500:
+		w5500_memory_configure(priv);
+		rtr = W5500_RTR;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (w5100_read16(priv, rtr) != RTR_DEFAULT)
+		return -ENODEV;
+
+	return 0;
 }
 
 static void w5100_hw_start(struct w5100_priv *priv)
@@ -621,12 +710,12 @@ static void w5100_hw_start(struct w5100_priv *priv)
 	w5100_write(priv, W5100_S0_MR(priv), priv->promisc ?
 			  S0_MR_MACRAW : S0_MR_MACRAW_MF);
 	w5100_command(priv, S0_CR_OPEN);
-	w5100_write(priv, W5100_IMR, IR_S0);
+	w5100_enable_intr(priv);
 }
 
 static void w5100_hw_close(struct w5100_priv *priv)
 {
-	w5100_write(priv, W5100_IMR, 0);
+	w5100_disable_intr(priv);
 	w5100_command(priv, S0_CR_CLOSE);
 }
 
@@ -805,7 +894,7 @@ static void w5100_rx_work(struct work_struct *work)
 	while ((skb = w5100_rx_skb(priv->ndev)))
 		netif_rx_ni(skb);
 
-	w5100_write(priv, W5100_IMR, IR_S0);
+	w5100_enable_intr(priv);
 }
 
 static int w5100_napi_poll(struct napi_struct *napi, int budget)
@@ -824,7 +913,7 @@ static int w5100_napi_poll(struct napi_struct *napi, int budget)
 
 	if (rx_count < budget) {
 		napi_complete(napi);
-		w5100_write(priv, W5100_IMR, IR_S0);
+		w5100_enable_intr(priv);
 	}
 
 	return rx_count;
@@ -846,7 +935,7 @@ static irqreturn_t w5100_interrupt(int irq, void *ndev_instance)
 	}
 
 	if (ir & S0_IR_RECV) {
-		w5100_write(priv, W5100_IMR, 0);
+		w5100_disable_intr(priv);
 
 		if (priv->ops->may_sleep)
 			queue_work(priv->xfer_wq, &priv->rx_work);
@@ -1014,6 +1103,34 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 	SET_NETDEV_DEV(ndev, dev);
 	dev_set_drvdata(dev, ndev);
 	priv = netdev_priv(ndev);
+
+	switch (ops->chip_id) {
+	case W5100:
+		priv->s0_regs = W5100_S0_REGS;
+		priv->s0_tx_buf = W5100_TX_MEM_START;
+		priv->s0_tx_buf_size = W5100_TX_MEM_SIZE;
+		priv->s0_rx_buf = W5100_RX_MEM_START;
+		priv->s0_rx_buf_size = W5100_RX_MEM_SIZE;
+		break;
+	case W5200:
+		priv->s0_regs = W5200_S0_REGS;
+		priv->s0_tx_buf = W5200_TX_MEM_START;
+		priv->s0_tx_buf_size = W5200_TX_MEM_SIZE;
+		priv->s0_rx_buf = W5200_RX_MEM_START;
+		priv->s0_rx_buf_size = W5200_RX_MEM_SIZE;
+		break;
+	case W5500:
+		priv->s0_regs = W5500_S0_REGS;
+		priv->s0_tx_buf = W5500_TX_MEM_START;
+		priv->s0_tx_buf_size = W5500_TX_MEM_SIZE;
+		priv->s0_rx_buf = W5500_RX_MEM_START;
+		priv->s0_rx_buf_size = W5500_RX_MEM_SIZE;
+		break;
+	default:
+		err = -EINVAL;
+		goto err_register;
+	}
+
 	priv->ndev = ndev;
 	priv->ops = ops;
 	priv->irq = irq;
@@ -1055,11 +1172,9 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 			goto err_hw;
 	}
 
-	w5100_hw_reset(priv);
-	if (w5100_read16(priv, W5100_RTR) != RTR_DEFAULT) {
-		err = -ENODEV;
+	err = w5100_hw_reset(priv);
+	if (err)
 		goto err_hw;
-	}
 
 	if (ops->may_sleep) {
 		err = request_threaded_irq(priv->irq, NULL, w5100_interrupt,
diff --git a/drivers/net/ethernet/wiznet/w5100.h b/drivers/net/ethernet/wiznet/w5100.h
index 9b1fa23..f8a16fa 100644
--- a/drivers/net/ethernet/wiznet/w5100.h
+++ b/drivers/net/ethernet/wiznet/w5100.h
@@ -10,17 +10,18 @@
 enum {
 	W5100,
 	W5200,
+	W5500,
 };
 
 struct w5100_ops {
 	bool may_sleep;
 	int chip_id;
-	int (*read)(struct net_device *ndev, u16 addr);
-	int (*write)(struct net_device *ndev, u16 addr, u8 data);
-	int (*read16)(struct net_device *ndev, u16 addr);
-	int (*write16)(struct net_device *ndev, u16 addr, u16 data);
-	int (*readbulk)(struct net_device *ndev, u16 addr, u8 *buf, int len);
-	int (*writebulk)(struct net_device *ndev, u16 addr, const u8 *buf,
+	int (*read)(struct net_device *ndev, u32 addr);
+	int (*write)(struct net_device *ndev, u32 addr, u8 data);
+	int (*read16)(struct net_device *ndev, u32 addr);
+	int (*write16)(struct net_device *ndev, u32 addr, u16 data);
+	int (*readbulk)(struct net_device *ndev, u32 addr, u8 *buf, int len);
+	int (*writebulk)(struct net_device *ndev, u32 addr, const u8 *buf,
 			 int len);
 	int (*reset)(struct net_device *ndev);
 	int (*init)(struct net_device *ndev);
-- 
2.5.0
