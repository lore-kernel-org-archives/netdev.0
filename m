From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 2/5] net: w5100: add ability to support other bus interface
Date: Fri, 15 Apr 2016 00:11:30 +0900
Message-ID: <1460646693-25179-3-git-send-email-akinobu.mita@gmail.com>
References: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33394 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbcDNPLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 11:11:55 -0400
Received: by mail-pf0-f175.google.com with SMTP id 184so47042000pff.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 08:11:55 -0700 (PDT)
In-Reply-To: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The w5100 driver currently only supports direct and indirect bus
interface mode which use MMIO space for accessing w5100 registers.

In order to support SPI interface mode which is supported by W5100 chip,
this makes the bus interface abstraction layer more generic so that
separated w5100-spi driver can use w5100 driver as core module.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
* v3
- Add comment for reg_lock
- Add ability to allocate ops specific data structure

 drivers/net/ethernet/wiznet/w5100.c | 604 ++++++++++++++++++++++++------------
 drivers/net/ethernet/wiznet/w5100.h |  28 ++
 2 files changed, 431 insertions(+), 201 deletions(-)
 create mode 100644 drivers/net/ethernet/wiznet/w5100.h

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index f4b7200..89cba67 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -27,6 +27,8 @@
 #include <linux/irq.h>
 #include <linux/gpio.h>
 
+#include "w5100.h"
+
 #define DRV_NAME	"w5100"
 #define DRV_VERSION	"2012-04-04"
 
@@ -76,25 +78,16 @@ MODULE_LICENSE("GPL");
 #define W5100_S0_REGS_LEN	0x0040
 
 #define W5100_TX_MEM_START	0x4000
-#define W5100_TX_MEM_END	0x5fff
-#define W5100_TX_MEM_MASK	0x1fff
+#define W5100_TX_MEM_SIZE	0x2000
 #define W5100_RX_MEM_START	0x6000
-#define W5100_RX_MEM_END	0x7fff
-#define W5100_RX_MEM_MASK	0x1fff
+#define W5100_RX_MEM_SIZE	0x2000
 
 /*
  * Device driver private data structure
  */
+
 struct w5100_priv {
-	void __iomem *base;
-	spinlock_t reg_lock;
-	bool indirect;
-	u8   (*read)(struct w5100_priv *priv, u16 addr);
-	void (*write)(struct w5100_priv *priv, u16 addr, u8 data);
-	u16  (*read16)(struct w5100_priv *priv, u16 addr);
-	void (*write16)(struct w5100_priv *priv, u16 addr, u16 data);
-	void (*readbuf)(struct w5100_priv *priv, u16 addr, u8 *buf, int len);
-	void (*writebuf)(struct w5100_priv *priv, u16 addr, u8 *buf, int len);
+	const struct w5100_ops *ops;
 	int irq;
 	int link_irq;
 	int link_gpio;
@@ -111,72 +104,121 @@ struct w5100_priv {
  *
  ***********************************************************************/
 
+struct w5100_mmio_priv {
+	void __iomem *base;
+	/* Serialize access in indirect address mode */
+	spinlock_t reg_lock;
+};
+
+static inline struct w5100_mmio_priv *w5100_mmio_priv(struct net_device *dev)
+{
+	return w5100_ops_priv(dev);
+}
+
+static inline void __iomem *w5100_mmio(struct net_device *ndev)
+{
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
+
+	return mmio_priv->base;
+}
+
 /*
  * In direct address mode host system can directly access W5100 registers
  * after mapping to Memory-Mapped I/O space.
  *
  * 0x8000 bytes are required for memory space.
  */
-static inline u8 w5100_read_direct(struct w5100_priv *priv, u16 addr)
+static inline int w5100_read_direct(struct net_device *ndev, u16 addr)
 {
-	return ioread8(priv->base + (addr << CONFIG_WIZNET_BUS_SHIFT));
+	return ioread8(w5100_mmio(ndev) + (addr << CONFIG_WIZNET_BUS_SHIFT));
 }
 
-static inline void __w5100_write_direct(struct w5100_priv *priv, u16 addr,
-					u8 data)
+static inline int __w5100_write_direct(struct net_device *ndev, u16 addr,
+				       u8 data)
 {
-	iowrite8(data, priv->base + (addr << CONFIG_WIZNET_BUS_SHIFT));
+	iowrite8(data, w5100_mmio(ndev) + (addr << CONFIG_WIZNET_BUS_SHIFT));
+
+	return 0;
 }
 
-static inline void w5100_write_direct(struct w5100_priv *priv,
-				      u16 addr, u8 data)
+static inline int w5100_write_direct(struct net_device *ndev, u16 addr, u8 data)
 {
-	__w5100_write_direct(priv, addr, data);
+	__w5100_write_direct(ndev, addr, data);
 	mmiowb();
+
+	return 0;
 }
 
-static u16 w5100_read16_direct(struct w5100_priv *priv, u16 addr)
+static int w5100_read16_direct(struct net_device *ndev, u16 addr)
 {
 	u16 data;
-	data  = w5100_read_direct(priv, addr) << 8;
-	data |= w5100_read_direct(priv, addr + 1);
+	data  = w5100_read_direct(ndev, addr) << 8;
+	data |= w5100_read_direct(ndev, addr + 1);
 	return data;
 }
 
-static void w5100_write16_direct(struct w5100_priv *priv, u16 addr, u16 data)
+static int w5100_write16_direct(struct net_device *ndev, u16 addr, u16 data)
 {
-	__w5100_write_direct(priv, addr, data >> 8);
-	__w5100_write_direct(priv, addr + 1, data);
+	__w5100_write_direct(ndev, addr, data >> 8);
+	__w5100_write_direct(ndev, addr + 1, data);
 	mmiowb();
+
+	return 0;
 }
 
-static void w5100_readbuf_direct(struct w5100_priv *priv,
-				 u16 offset, u8 *buf, int len)
+static int w5100_readbulk_direct(struct net_device *ndev, u16 addr, u8 *buf,
+				 int len)
 {
-	u16 addr = W5100_RX_MEM_START + (offset & W5100_RX_MEM_MASK);
 	int i;
 
-	for (i = 0; i < len; i++, addr++) {
-		if (unlikely(addr > W5100_RX_MEM_END))
-			addr = W5100_RX_MEM_START;
-		*buf++ = w5100_read_direct(priv, addr);
-	}
+	for (i = 0; i < len; i++, addr++)
+		*buf++ = w5100_read_direct(ndev, addr);
+
+	return 0;
 }
 
-static void w5100_writebuf_direct(struct w5100_priv *priv,
-				  u16 offset, u8 *buf, int len)
+static int w5100_writebulk_direct(struct net_device *ndev, u16 addr,
+				  const u8 *buf, int len)
 {
-	u16 addr = W5100_TX_MEM_START + (offset & W5100_TX_MEM_MASK);
 	int i;
 
-	for (i = 0; i < len; i++, addr++) {
-		if (unlikely(addr > W5100_TX_MEM_END))
-			addr = W5100_TX_MEM_START;
-		__w5100_write_direct(priv, addr, *buf++);
-	}
+	for (i = 0; i < len; i++, addr++)
+		__w5100_write_direct(ndev, addr, *buf++);
+
 	mmiowb();
+
+	return 0;
+}
+
+static int w5100_mmio_init(struct net_device *ndev)
+{
+	struct platform_device *pdev = to_platform_device(ndev->dev.parent);
+	struct w5100_priv *priv = netdev_priv(ndev);
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
+	struct resource *mem;
+
+	spin_lock_init(&mmio_priv->reg_lock);
+
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	mmio_priv->base = devm_ioremap_resource(&pdev->dev, mem);
+	if (IS_ERR(mmio_priv->base))
+		return PTR_ERR(mmio_priv->base);
+
+	netdev_info(ndev, "at 0x%llx irq %d\n", (u64)mem->start, priv->irq);
+
+	return 0;
 }
 
+static const struct w5100_ops w5100_mmio_direct_ops = {
+	.read = w5100_read_direct,
+	.write = w5100_write_direct,
+	.read16 = w5100_read16_direct,
+	.write16 = w5100_write16_direct,
+	.readbulk = w5100_readbulk_direct,
+	.writebulk = w5100_writebulk_direct,
+	.init = w5100_mmio_init,
+};
+
 /*
  * In indirect address mode host system indirectly accesses registers by
  * using Indirect Mode Address Register (IDM_AR) and Indirect Mode Data
@@ -188,121 +230,276 @@ static void w5100_writebuf_direct(struct w5100_priv *priv,
 #define W5100_IDM_AR		0x01   /* Indirect Mode Address Register */
 #define W5100_IDM_DR		0x03   /* Indirect Mode Data Register */
 
-static u8 w5100_read_indirect(struct w5100_priv *priv, u16 addr)
+static int w5100_read_indirect(struct net_device *ndev, u16 addr)
 {
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
 	u8 data;
 
-	spin_lock_irqsave(&priv->reg_lock, flags);
-	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	data = w5100_read_direct(priv, W5100_IDM_DR);
-	spin_unlock_irqrestore(&priv->reg_lock, flags);
+	spin_lock_irqsave(&mmio_priv->reg_lock, flags);
+	w5100_write16_direct(ndev, W5100_IDM_AR, addr);
+	data = w5100_read_direct(ndev, W5100_IDM_DR);
+	spin_unlock_irqrestore(&mmio_priv->reg_lock, flags);
 
 	return data;
 }
 
-static void w5100_write_indirect(struct w5100_priv *priv, u16 addr, u8 data)
+static int w5100_write_indirect(struct net_device *ndev, u16 addr, u8 data)
 {
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
 
-	spin_lock_irqsave(&priv->reg_lock, flags);
-	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	w5100_write_direct(priv, W5100_IDM_DR, data);
-	spin_unlock_irqrestore(&priv->reg_lock, flags);
+	spin_lock_irqsave(&mmio_priv->reg_lock, flags);
+	w5100_write16_direct(ndev, W5100_IDM_AR, addr);
+	w5100_write_direct(ndev, W5100_IDM_DR, data);
+	spin_unlock_irqrestore(&mmio_priv->reg_lock, flags);
+
+	return 0;
 }
 
-static u16 w5100_read16_indirect(struct w5100_priv *priv, u16 addr)
+static int w5100_read16_indirect(struct net_device *ndev, u16 addr)
 {
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
 	u16 data;
 
-	spin_lock_irqsave(&priv->reg_lock, flags);
-	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	data  = w5100_read_direct(priv, W5100_IDM_DR) << 8;
-	data |= w5100_read_direct(priv, W5100_IDM_DR);
-	spin_unlock_irqrestore(&priv->reg_lock, flags);
+	spin_lock_irqsave(&mmio_priv->reg_lock, flags);
+	w5100_write16_direct(ndev, W5100_IDM_AR, addr);
+	data  = w5100_read_direct(ndev, W5100_IDM_DR) << 8;
+	data |= w5100_read_direct(ndev, W5100_IDM_DR);
+	spin_unlock_irqrestore(&mmio_priv->reg_lock, flags);
 
 	return data;
 }
 
-static void w5100_write16_indirect(struct w5100_priv *priv, u16 addr, u16 data)
+static int w5100_write16_indirect(struct net_device *ndev, u16 addr, u16 data)
 {
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
 
-	spin_lock_irqsave(&priv->reg_lock, flags);
-	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	__w5100_write_direct(priv, W5100_IDM_DR, data >> 8);
-	w5100_write_direct(priv, W5100_IDM_DR, data);
-	spin_unlock_irqrestore(&priv->reg_lock, flags);
+	spin_lock_irqsave(&mmio_priv->reg_lock, flags);
+	w5100_write16_direct(ndev, W5100_IDM_AR, addr);
+	__w5100_write_direct(ndev, W5100_IDM_DR, data >> 8);
+	w5100_write_direct(ndev, W5100_IDM_DR, data);
+	spin_unlock_irqrestore(&mmio_priv->reg_lock, flags);
+
+	return 0;
 }
 
-static void w5100_readbuf_indirect(struct w5100_priv *priv,
-				   u16 offset, u8 *buf, int len)
+static int w5100_readbulk_indirect(struct net_device *ndev, u16 addr, u8 *buf,
+				   int len)
 {
-	u16 addr = W5100_RX_MEM_START + (offset & W5100_RX_MEM_MASK);
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
 	int i;
 
-	spin_lock_irqsave(&priv->reg_lock, flags);
-	w5100_write16_direct(priv, W5100_IDM_AR, addr);
+	spin_lock_irqsave(&mmio_priv->reg_lock, flags);
+	w5100_write16_direct(ndev, W5100_IDM_AR, addr);
+
+	for (i = 0; i < len; i++)
+		*buf++ = w5100_read_direct(ndev, W5100_IDM_DR);
 
-	for (i = 0; i < len; i++, addr++) {
-		if (unlikely(addr > W5100_RX_MEM_END)) {
-			addr = W5100_RX_MEM_START;
-			w5100_write16_direct(priv, W5100_IDM_AR, addr);
-		}
-		*buf++ = w5100_read_direct(priv, W5100_IDM_DR);
-	}
 	mmiowb();
-	spin_unlock_irqrestore(&priv->reg_lock, flags);
+	spin_unlock_irqrestore(&mmio_priv->reg_lock, flags);
+
+	return 0;
 }
 
-static void w5100_writebuf_indirect(struct w5100_priv *priv,
-				    u16 offset, u8 *buf, int len)
+static int w5100_writebulk_indirect(struct net_device *ndev, u16 addr,
+				    const u8 *buf, int len)
 {
-	u16 addr = W5100_TX_MEM_START + (offset & W5100_TX_MEM_MASK);
+	struct w5100_mmio_priv *mmio_priv = w5100_mmio_priv(ndev);
 	unsigned long flags;
 	int i;
 
-	spin_lock_irqsave(&priv->reg_lock, flags);
-	w5100_write16_direct(priv, W5100_IDM_AR, addr);
+	spin_lock_irqsave(&mmio_priv->reg_lock, flags);
+	w5100_write16_direct(ndev, W5100_IDM_AR, addr);
+
+	for (i = 0; i < len; i++)
+		__w5100_write_direct(ndev, W5100_IDM_DR, *buf++);
 
-	for (i = 0; i < len; i++, addr++) {
-		if (unlikely(addr > W5100_TX_MEM_END)) {
-			addr = W5100_TX_MEM_START;
-			w5100_write16_direct(priv, W5100_IDM_AR, addr);
-		}
-		__w5100_write_direct(priv, W5100_IDM_DR, *buf++);
-	}
 	mmiowb();
-	spin_unlock_irqrestore(&priv->reg_lock, flags);
+	spin_unlock_irqrestore(&mmio_priv->reg_lock, flags);
+
+	return 0;
+}
+
+static int w5100_reset_indirect(struct net_device *ndev)
+{
+	w5100_write_direct(ndev, W5100_MR, MR_RST);
+	mdelay(5);
+	w5100_write_direct(ndev, W5100_MR, MR_PB | MR_AI | MR_IND);
+
+	return 0;
 }
 
+static const struct w5100_ops w5100_mmio_indirect_ops = {
+	.read = w5100_read_indirect,
+	.write = w5100_write_indirect,
+	.read16 = w5100_read16_indirect,
+	.write16 = w5100_write16_indirect,
+	.readbulk = w5100_readbulk_indirect,
+	.writebulk = w5100_writebulk_indirect,
+	.init = w5100_mmio_init,
+	.reset = w5100_reset_indirect,
+};
+
 #if defined(CONFIG_WIZNET_BUS_DIRECT)
-#define w5100_read	w5100_read_direct
-#define w5100_write	w5100_write_direct
-#define w5100_read16	w5100_read16_direct
-#define w5100_write16	w5100_write16_direct
-#define w5100_readbuf	w5100_readbuf_direct
-#define w5100_writebuf	w5100_writebuf_direct
+
+static int w5100_read(struct w5100_priv *priv, u16 addr)
+{
+	return w5100_read_direct(priv->ndev, addr);
+}
+
+static int w5100_write(struct w5100_priv *priv, u16 addr, u8 data)
+{
+	return w5100_write_direct(priv->ndev, addr, data);
+}
+
+static int w5100_read16(struct w5100_priv *priv, u16 addr)
+{
+	return w5100_read16_direct(priv->ndev, addr);
+}
+
+static int w5100_write16(struct w5100_priv *priv, u16 addr, u16 data)
+{
+	return w5100_write16_direct(priv->ndev, addr, data);
+}
+
+static int w5100_readbulk(struct w5100_priv *priv, u16 addr, u8 *buf, int len)
+{
+	return w5100_readbulk_direct(priv->ndev, addr, buf, len);
+}
+
+static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
+			   int len)
+{
+	return w5100_writebulk_direct(priv->ndev, addr, buf, len);
+}
 
 #elif defined(CONFIG_WIZNET_BUS_INDIRECT)
-#define w5100_read	w5100_read_indirect
-#define w5100_write	w5100_write_indirect
-#define w5100_read16	w5100_read16_indirect
-#define w5100_write16	w5100_write16_indirect
-#define w5100_readbuf	w5100_readbuf_indirect
-#define w5100_writebuf	w5100_writebuf_indirect
+
+static int w5100_read(struct w5100_priv *priv, u16 addr)
+{
+	return w5100_read_indirect(priv->ndev, addr);
+}
+
+static int w5100_write(struct w5100_priv *priv, u16 addr, u8 data)
+{
+	return w5100_write_indirect(priv->ndev, addr, data);
+}
+
+static int w5100_read16(struct w5100_priv *priv, u16 addr)
+{
+	return w5100_read16_indirect(priv->ndev, addr);
+}
+
+static int w5100_write16(struct w5100_priv *priv, u16 addr, u16 data)
+{
+	return w5100_write16_indirect(priv->ndev, addr, data);
+}
+
+static int w5100_readbulk(struct w5100_priv *priv, u16 addr, u8 *buf, int len)
+{
+	return w5100_readbulk_indirect(priv->ndev, addr, buf, len);
+}
+
+static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
+			   int len)
+{
+	return w5100_writebulk_indirect(priv->ndev, addr, buf, len);
+}
 
 #else /* CONFIG_WIZNET_BUS_ANY */
-#define w5100_read	priv->read
-#define w5100_write	priv->write
-#define w5100_read16	priv->read16
-#define w5100_write16	priv->write16
-#define w5100_readbuf	priv->readbuf
-#define w5100_writebuf	priv->writebuf
+
+static int w5100_read(struct w5100_priv *priv, u16 addr)
+{
+	return priv->ops->read(priv->ndev, addr);
+}
+
+static int w5100_write(struct w5100_priv *priv, u16 addr, u8 data)
+{
+	return priv->ops->write(priv->ndev, addr, data);
+}
+
+static int w5100_read16(struct w5100_priv *priv, u16 addr)
+{
+	return priv->ops->read16(priv->ndev, addr);
+}
+
+static int w5100_write16(struct w5100_priv *priv, u16 addr, u16 data)
+{
+	return priv->ops->write16(priv->ndev, addr, data);
+}
+
+static int w5100_readbulk(struct w5100_priv *priv, u16 addr, u8 *buf, int len)
+{
+	return priv->ops->readbulk(priv->ndev, addr, buf, len);
+}
+
+static int w5100_writebulk(struct w5100_priv *priv, u16 addr, const u8 *buf,
+			   int len)
+{
+	return priv->ops->writebulk(priv->ndev, addr, buf, len);
+}
+
 #endif
 
+static int w5100_readbuf(struct w5100_priv *priv, u16 offset, u8 *buf, int len)
+{
+	u16 addr;
+	int remain = 0;
+	int ret;
+
+	offset %= W5100_RX_MEM_SIZE;
+	addr = W5100_RX_MEM_START + offset;
+
+	if (offset + len > W5100_RX_MEM_SIZE) {
+		remain = (offset + len) % W5100_RX_MEM_SIZE;
+		len = W5100_RX_MEM_SIZE - offset;
+	}
+
+	ret = w5100_readbulk(priv, addr, buf, len);
+	if (ret || !remain)
+		return ret;
+
+	return w5100_readbulk(priv, W5100_RX_MEM_START, buf + len, remain);
+}
+
+static int w5100_writebuf(struct w5100_priv *priv, u16 offset, const u8 *buf,
+			  int len)
+{
+	u16 addr;
+	int ret;
+	int remain = 0;
+
+	offset %= W5100_TX_MEM_SIZE;
+	addr = W5100_TX_MEM_START + offset;
+
+	if (offset + len > W5100_TX_MEM_SIZE) {
+		remain = (offset + len) % W5100_TX_MEM_SIZE;
+		len = W5100_TX_MEM_SIZE - offset;
+	}
+
+	ret = w5100_writebulk(priv, addr, buf, len);
+	if (ret || !remain)
+		return ret;
+
+	return w5100_writebulk(priv, W5100_TX_MEM_START, buf + len, remain);
+}
+
+static int w5100_reset(struct w5100_priv *priv)
+{
+	if (priv->ops->reset)
+		return priv->ops->reset(priv->ndev);
+
+	w5100_write(priv, W5100_MR, MR_RST);
+	mdelay(5);
+	w5100_write(priv, W5100_MR, MR_PB);
+
+	return 0;
+}
+
 static int w5100_command(struct w5100_priv *priv, u16 cmd)
 {
 	unsigned long timeout = jiffies + msecs_to_jiffies(100);
@@ -321,19 +518,14 @@ static int w5100_command(struct w5100_priv *priv, u16 cmd)
 static void w5100_write_macaddr(struct w5100_priv *priv)
 {
 	struct net_device *ndev = priv->ndev;
-	int i;
 
-	for (i = 0; i < ETH_ALEN; i++)
-		w5100_write(priv, W5100_SHAR + i, ndev->dev_addr[i]);
+	w5100_writebulk(priv, W5100_SHAR, ndev->dev_addr, ETH_ALEN);
 }
 
 static void w5100_hw_reset(struct w5100_priv *priv)
 {
-	w5100_write_direct(priv, W5100_MR, MR_RST);
-	mdelay(5);
-	w5100_write_direct(priv, W5100_MR, priv->indirect ?
-				  MR_PB | MR_AI | MR_IND :
-				  MR_PB);
+	w5100_reset(priv);
+
 	w5100_write(priv, W5100_IMR, 0);
 	w5100_write_macaddr(priv);
 
@@ -403,17 +595,14 @@ static int w5100_get_regs_len(struct net_device *ndev)
 }
 
 static void w5100_get_regs(struct net_device *ndev,
-			   struct ethtool_regs *regs, void *_buf)
+			   struct ethtool_regs *regs, void *buf)
 {
 	struct w5100_priv *priv = netdev_priv(ndev);
-	u8 *buf = _buf;
-	u16 i;
 
 	regs->version = 1;
-	for (i = 0; i < W5100_COMMON_REGS_LEN; i++)
-		*buf++ = w5100_read(priv, W5100_COMMON_REGS + i);
-	for (i = 0; i < W5100_S0_REGS_LEN; i++)
-		*buf++ = w5100_read(priv, W5100_S0_REGS + i);
+	w5100_readbulk(priv, W5100_COMMON_REGS, buf, W5100_COMMON_REGS_LEN);
+	buf += W5100_COMMON_REGS_LEN;
+	w5100_readbulk(priv, W5100_S0_REGS, buf, W5100_S0_REGS_LEN);
 }
 
 static void w5100_tx_timeout(struct net_device *ndev)
@@ -606,91 +795,68 @@ static const struct net_device_ops w5100_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int w5100_hw_probe(struct platform_device *pdev)
+static int w5100_mmio_probe(struct platform_device *pdev)
 {
 	struct wiznet_platform_data *data = dev_get_platdata(&pdev->dev);
-	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct w5100_priv *priv = netdev_priv(ndev);
-	const char *name = netdev_name(ndev);
+	u8 *mac_addr = NULL;
 	struct resource *mem;
-	int mem_size;
+	const struct w5100_ops *ops;
 	int irq;
-	int ret;
 
-	if (data && is_valid_ether_addr(data->mac_addr)) {
-		memcpy(ndev->dev_addr, data->mac_addr, ETH_ALEN);
-	} else {
-		eth_hw_addr_random(ndev);
-	}
+	if (data && is_valid_ether_addr(data->mac_addr))
+		mac_addr = data->mac_addr;
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	priv->base = devm_ioremap_resource(&pdev->dev, mem);
-	if (IS_ERR(priv->base))
-		return PTR_ERR(priv->base);
-
-	mem_size = resource_size(mem);
-
-	spin_lock_init(&priv->reg_lock);
-	priv->indirect = mem_size < W5100_BUS_DIRECT_SIZE;
-	if (priv->indirect) {
-		priv->read     = w5100_read_indirect;
-		priv->write    = w5100_write_indirect;
-		priv->read16   = w5100_read16_indirect;
-		priv->write16  = w5100_write16_indirect;
-		priv->readbuf  = w5100_readbuf_indirect;
-		priv->writebuf = w5100_writebuf_indirect;
-	} else {
-		priv->read     = w5100_read_direct;
-		priv->write    = w5100_write_direct;
-		priv->read16   = w5100_read16_direct;
-		priv->write16  = w5100_write16_direct;
-		priv->readbuf  = w5100_readbuf_direct;
-		priv->writebuf = w5100_writebuf_direct;
-	}
-
-	w5100_hw_reset(priv);
-	if (w5100_read16(priv, W5100_RTR) != RTR_DEFAULT)
-		return -ENODEV;
+	if (resource_size(mem) < W5100_BUS_DIRECT_SIZE)
+		ops = &w5100_mmio_indirect_ops;
+	else
+		ops = &w5100_mmio_direct_ops;
 
 	irq = platform_get_irq(pdev, 0);
 	if (irq < 0)
 		return irq;
-	ret = request_irq(irq, w5100_interrupt,
-			  IRQ_TYPE_LEVEL_LOW, name, ndev);
-	if (ret < 0)
-		return ret;
-	priv->irq = irq;
 
-	priv->link_gpio = data ? data->link_gpio : -EINVAL;
-	if (gpio_is_valid(priv->link_gpio)) {
-		char *link_name = devm_kzalloc(&pdev->dev, 16, GFP_KERNEL);
-		if (!link_name)
-			return -ENOMEM;
-		snprintf(link_name, 16, "%s-link", name);
-		priv->link_irq = gpio_to_irq(priv->link_gpio);
-		if (request_any_context_irq(priv->link_irq, w5100_detect_link,
-				IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING,
-				link_name, priv->ndev) < 0)
-			priv->link_gpio = -EINVAL;
-	}
+	return w5100_probe(&pdev->dev, ops, sizeof(struct w5100_mmio_priv),
+			   mac_addr, irq, data ? data->link_gpio : -EINVAL);
+}
 
-	netdev_info(ndev, "at 0x%llx irq %d\n", (u64)mem->start, irq);
-	return 0;
+static int w5100_mmio_remove(struct platform_device *pdev)
+{
+	return w5100_remove(&pdev->dev);
 }
 
-static int w5100_probe(struct platform_device *pdev)
+void *w5100_ops_priv(const struct net_device *ndev)
+{
+	return netdev_priv(ndev) +
+	       ALIGN(sizeof(struct w5100_priv), NETDEV_ALIGN);
+}
+EXPORT_SYMBOL_GPL(w5100_ops_priv);
+
+int w5100_probe(struct device *dev, const struct w5100_ops *ops,
+		int sizeof_ops_priv, u8 *mac_addr, int irq, int link_gpio)
 {
 	struct w5100_priv *priv;
 	struct net_device *ndev;
 	int err;
+	size_t alloc_size;
+
+	alloc_size = sizeof(*priv);
+	if (sizeof_ops_priv) {
+		alloc_size = ALIGN(alloc_size, NETDEV_ALIGN);
+		alloc_size += sizeof_ops_priv;
+	}
+	alloc_size += NETDEV_ALIGN - 1;
 
-	ndev = alloc_etherdev(sizeof(*priv));
+	ndev = alloc_etherdev(alloc_size);
 	if (!ndev)
 		return -ENOMEM;
-	SET_NETDEV_DEV(ndev, &pdev->dev);
-	platform_set_drvdata(pdev, ndev);
+	SET_NETDEV_DEV(ndev, dev);
+	dev_set_drvdata(dev, ndev);
 	priv = netdev_priv(ndev);
 	priv->ndev = ndev;
+	priv->ops = ops;
+	priv->irq = irq;
+	priv->link_gpio = link_gpio;
 
 	ndev->netdev_ops = &w5100_netdev_ops;
 	ndev->ethtool_ops = &w5100_ethtool_ops;
@@ -706,22 +872,59 @@ static int w5100_probe(struct platform_device *pdev)
 	if (err < 0)
 		goto err_register;
 
-	err = w5100_hw_probe(pdev);
-	if (err < 0)
-		goto err_hw_probe;
+	if (mac_addr)
+		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
+	else
+		eth_hw_addr_random(ndev);
+
+	if (priv->ops->init) {
+		err = priv->ops->init(priv->ndev);
+		if (err)
+			goto err_hw;
+	}
+
+	w5100_hw_reset(priv);
+	if (w5100_read16(priv, W5100_RTR) != RTR_DEFAULT) {
+		err = -ENODEV;
+		goto err_hw;
+	}
+
+	err = request_irq(priv->irq, w5100_interrupt, IRQF_TRIGGER_LOW,
+			  netdev_name(ndev), ndev);
+	if (err)
+		goto err_hw;
+
+	if (gpio_is_valid(priv->link_gpio)) {
+		char *link_name = devm_kzalloc(dev, 16, GFP_KERNEL);
+
+		if (!link_name) {
+			err = -ENOMEM;
+			goto err_gpio;
+		}
+		snprintf(link_name, 16, "%s-link", netdev_name(ndev));
+		priv->link_irq = gpio_to_irq(priv->link_gpio);
+		if (request_any_context_irq(priv->link_irq, w5100_detect_link,
+					    IRQF_TRIGGER_RISING |
+					    IRQF_TRIGGER_FALLING,
+					    link_name, priv->ndev) < 0)
+			priv->link_gpio = -EINVAL;
+	}
 
 	return 0;
 
-err_hw_probe:
+err_gpio:
+	free_irq(priv->irq, ndev);
+err_hw:
 	unregister_netdev(ndev);
 err_register:
 	free_netdev(ndev);
 	return err;
 }
+EXPORT_SYMBOL_GPL(w5100_probe);
 
-static int w5100_remove(struct platform_device *pdev)
+int w5100_remove(struct device *dev)
 {
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct w5100_priv *priv = netdev_priv(ndev);
 
 	w5100_hw_reset(priv);
@@ -733,12 +936,12 @@ static int w5100_remove(struct platform_device *pdev)
 	free_netdev(ndev);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(w5100_remove);
 
 #ifdef CONFIG_PM_SLEEP
 static int w5100_suspend(struct device *dev)
 {
-	struct platform_device *pdev = to_platform_device(dev);
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct w5100_priv *priv = netdev_priv(ndev);
 
 	if (netif_running(ndev)) {
@@ -752,8 +955,7 @@ static int w5100_suspend(struct device *dev)
 
 static int w5100_resume(struct device *dev)
 {
-	struct platform_device *pdev = to_platform_device(dev);
-	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct w5100_priv *priv = netdev_priv(ndev);
 
 	if (netif_running(ndev)) {
@@ -769,15 +971,15 @@ static int w5100_resume(struct device *dev)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-static SIMPLE_DEV_PM_OPS(w5100_pm_ops, w5100_suspend, w5100_resume);
+SIMPLE_DEV_PM_OPS(w5100_pm_ops, w5100_suspend, w5100_resume);
+EXPORT_SYMBOL_GPL(w5100_pm_ops);
 
-static struct platform_driver w5100_driver = {
+static struct platform_driver w5100_mmio_driver = {
 	.driver		= {
 		.name	= DRV_NAME,
 		.pm	= &w5100_pm_ops,
 	},
-	.probe		= w5100_probe,
-	.remove		= w5100_remove,
+	.probe		= w5100_mmio_probe,
+	.remove		= w5100_mmio_remove,
 };
-
-module_platform_driver(w5100_driver);
+module_platform_driver(w5100_mmio_driver);
diff --git a/drivers/net/ethernet/wiznet/w5100.h b/drivers/net/ethernet/wiznet/w5100.h
new file mode 100644
index 0000000..39d452d8
--- /dev/null
+++ b/drivers/net/ethernet/wiznet/w5100.h
@@ -0,0 +1,28 @@
+/*
+ * Ethernet driver for the WIZnet W5100 chip.
+ *
+ * Copyright (C) 2006-2008 WIZnet Co.,Ltd.
+ * Copyright (C) 2012 Mike Sinkovsky <msink@permonline.ru>
+ *
+ * Licensed under the GPL-2 or later.
+ */
+
+struct w5100_ops {
+	int (*read)(struct net_device *ndev, u16 addr);
+	int (*write)(struct net_device *ndev, u16 addr, u8 data);
+	int (*read16)(struct net_device *ndev, u16 addr);
+	int (*write16)(struct net_device *ndev, u16 addr, u16 data);
+	int (*readbulk)(struct net_device *ndev, u16 addr, u8 *buf, int len);
+	int (*writebulk)(struct net_device *ndev, u16 addr, const u8 *buf,
+			 int len);
+	int (*reset)(struct net_device *ndev);
+	int (*init)(struct net_device *ndev);
+};
+
+void *w5100_ops_priv(const struct net_device *ndev);
+
+int w5100_probe(struct device *dev, const struct w5100_ops *ops,
+		int sizeof_ops_priv, u8 *mac_addr, int irq, int link_gpio);
+int w5100_remove(struct device *dev);
+
+extern const struct dev_pm_ops w5100_pm_ops;
-- 
2.5.0
