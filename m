From: Yegor Yefremov <yegor_sub1-ZJVcf1zZPRSebONBosFW4Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 2/2] can: sja1000: add read/write routines
	for 8, 16 and 32-bit register access
Date: Fri, 19 Mar 2010 11:50:44 +0100
Message-ID: <4BA35704.2060909@visionsystems.de>
References: <4BA3565F.6040907@visionsystems.de>
	<4BA356A4.5040205@visionsystems.de>
Reply-To: yegor_sub1-ZJVcf1zZPRSebONBosFW4Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4BA356A4.5040205-ZJVcf1zZPRSebONBosFW4Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

SJA1000: add read/write routines for 8, 16 and 32-bit register access

add routines for 8, 16 and 32-bit access like in 
drivers/i2c/busses/i2c-pca-platform.c

Signed-off-by: Yegor Yefremov <yegorslists-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>

Index: net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000_platform.c
+++ net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c
@@ -37,16 +37,36 @@ MODULE_AUTHOR("Sascha Hauer <s.hauer@pen
 MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
 MODULE_LICENSE("GPL v2");
 
-static u8 sp_read_reg(const struct sja1000_priv *priv, int reg)
+static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
 {
 	return ioread8(priv->reg_base + reg);
 }
 
-static void sp_write_reg(const struct sja1000_priv *priv, int reg, u8 val)
+static void sp_write_reg8(const struct sja1000_priv *priv, int reg, u8 val)
 {
 	iowrite8(val, priv->reg_base + reg);
 }
 
+static u8 sp_read_reg16(const struct sja1000_priv *priv, int reg)
+{
+	return ioread8(priv->reg_base + reg * 2);
+}
+
+static void sp_write_reg16(const struct sja1000_priv *priv, int reg, u8 val)
+{
+	iowrite8(val, priv->reg_base + reg * 2);
+}
+
+static u8 sp_read_reg32(const struct sja1000_priv *priv, int reg)
+{
+	return ioread8(priv->reg_base + reg * 4);
+}
+
+static void sp_write_reg32(const struct sja1000_priv *priv, int reg, u8 val)
+{
+	iowrite8(val, priv->reg_base + reg * 4);
+}
+
 static int sp_probe(struct platform_device *pdev)
 {
 	int err;
@@ -92,12 +112,26 @@ static int sp_probe(struct platform_devi
 	dev->irq = res_irq->start;
 	priv->irq_flags = res_irq->flags & (IRQF_TRIGGER_MASK | IRQF_SHARED);
 	priv->reg_base = addr;
-	priv->read_reg = sp_read_reg;
-	priv->write_reg = sp_write_reg;
 	priv->can.clock.freq = pdata->clock;
 	priv->ocr = pdata->ocr;
 	priv->cdr = pdata->cdr;
 
+	switch (res_mem->flags & IORESOURCE_MEM_TYPE_MASK) {
+	case IORESOURCE_MEM_32BIT:
+		priv->read_reg = sp_read_reg32;
+		priv->write_reg = sp_write_reg32;
+		break;
+	case IORESOURCE_MEM_16BIT:
+		priv->read_reg = sp_read_reg16;
+		priv->write_reg = sp_write_reg16;
+		break;
+	case IORESOURCE_MEM_8BIT:
+	default:
+		priv->read_reg = sp_read_reg8;
+		priv->write_reg = sp_write_reg8;
+		break;
+	}
+
 	dev_set_drvdata(&pdev->dev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
