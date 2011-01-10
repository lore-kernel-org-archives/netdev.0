From: Angelo Dureghello <angelo70@gmail.com>
Subject: Fwd: [RFC v3 PATCH] m68knommu: added dm9000 support
Date: Mon, 10 Jan 2011 13:09:42 +0100
Message-ID: <4D2AF706.1050600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux-m68k@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

is there any feedback on the patch ?

thanks,
angelo

-------- Original Message --------
Subject: [RFC v3 PATCH] m68knommu: added dm9000 support
Date: Sat, 08 Jan 2011 10:08:13 +0100
From: Angelo Dureghello <angelo70@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,  linux-m68k@vger.kernel.org

This patch allows to use the dm9000 network chip with a m68knommu
big-endian cpu. From the data bus circuit-wiring point of view,
the cpu data bus connected to the dm9000 chip should be hardware-byte-swapped,
crossing the bytes wires (D0:7 to D24:31, etc.). 
In anyway, has been also added an option to swap the bytes in the driver, 
if some cpu has been wired straight D0:D31 to dm9000.

Signed-off-by: Angelo Dureghello <angelo70@gmail.com>

---
--- linux/drivers/net/Kconfig.orig	2011-01-05 17:11:37.992376124 +0100
+++ linux/drivers/net/Kconfig	2011-01-08 09:53:48.231300064 +0100
@@ -960,7 +960,7 @@ config TI_DAVINCI_EMAC
 
 config DM9000
 	tristate "DM9000 support"
-	depends on ARM || BLACKFIN || MIPS
+	depends on COLDFIRE || ARM || BLACKFIN || MIPS
 	select CRC32
 	select MII
 	---help---
@@ -986,6 +986,14 @@ config DM9000_FORCE_SIMPLE_PHY_POLL
 	  costly MII PHY reads. Note, this will not work if the chip is
 	  operating with an external PHY.
 
+config DM9000_32BIT_SW_SWAP
+	bool "Software byte swap for 32 bit data bus"
+	depends on DM9000 && COLDFIRE
+	---help---
+	  This configuration allows to swap data bytes from the dm9000
+	  driver itself, when the big endian cpu is wired straight to
+	  the dm9000 32 bit data bus.
+
 config ENC28J60
 	tristate "ENC28J60 support"
 	depends on EXPERIMENTAL && SPI && NET_ETHERNET

--- linux/drivers/net/dm9000.c.orig	2010-12-30 23:19:39.747836070 +0100
+++ linux/drivers/net/dm9000.c	2011-01-08 09:54:28.543551323 +0100
@@ -158,9 +158,17 @@ dm9000_reset(board_info_t * db)
 	dev_dbg(db->dev, "resetting device\n");
 
 	/* RESET device */
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(DM9000_NCR, db->io_addr);
+#else
 	writeb(DM9000_NCR, db->io_addr);
+#endif
 	udelay(200);
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(NCR_RST, db->io_data);
+#else
 	writeb(NCR_RST, db->io_data);
+#endif
 	udelay(200);
 }
 
@@ -170,8 +178,13 @@ dm9000_reset(board_info_t * db)
 static u8
 ior(board_info_t * db, int reg)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(reg, db->io_addr);
+	return (u8)readl(db->io_data);
+#else
 	writeb(reg, db->io_addr);
 	return readb(db->io_data);
+#endif
 }
 
 /*
@@ -181,43 +194,72 @@ ior(board_info_t * db, int reg)
 static void
 iow(board_info_t * db, int reg, int value)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(reg, db->io_addr);
+	writel(value, db->io_data);
+#else
 	writeb(reg, db->io_addr);
 	writeb(value, db->io_data);
+#endif
 }
 
 /* routines for sending block to chip */
 
 static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writesbsw(reg, data, count);
+#else
 	writesb(reg, data, count);
+#endif
 }
 
 static void dm9000_outblk_16bit(void __iomem *reg, void *data, int count)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writeswsw(reg, data, (count+1) >> 1);
+#else
 	writesw(reg, data, (count+1) >> 1);
+#endif
 }
 
 static void dm9000_outblk_32bit(void __iomem *reg, void *data, int count)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writeslsw(reg, data, (count+3) >> 2);
+#else
 	writesl(reg, data, (count+3) >> 2);
+#endif
 }
 
 /* input block from chip to memory */
 
 static void dm9000_inblk_8bit(void __iomem *reg, void *data, int count)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	readsbsw(reg, data, count);
+#else
 	readsb(reg, data, count);
+#endif
 }
 
 
 static void dm9000_inblk_16bit(void __iomem *reg, void *data, int count)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	readswsw(reg, data, (count+1) >> 1);
+#else
 	readsw(reg, data, (count+1) >> 1);
+#endif
 }
 
 static void dm9000_inblk_32bit(void __iomem *reg, void *data, int count)
 {
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	readslsw(reg, data, (count+3) >> 2);
+#else
 	readsl(reg, data, (count+3) >> 2);
+#endif
 }
 
 /* dump block from chip to null */
@@ -863,8 +905,12 @@ static void dm9000_timeout(struct net_de
 	netif_wake_queue(dev);
 
 	/* Restore previous register address */
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(reg_save, db->io_addr);
+#else
 	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock, flags);
+#endif
+	spin_unlock_irqrestore(&db->lock,flags);
 }
 
 static void dm9000_send_packet(struct net_device *dev,
@@ -908,7 +954,11 @@ dm9000_start_xmit(struct sk_buff *skb, s
 	spin_lock_irqsave(&db->lock, flags);
 
 	/* Move data to DM9000 TX RAM */
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+   writel(DM9000_MWCMD, db->io_addr);
+#else
 	writeb(DM9000_MWCMD, db->io_addr);
+#endif	
 
 	(db->outblk)(db->io_data, skb->data, skb->len);
 	dev->stats.tx_bytes += skb->len;
@@ -981,7 +1031,11 @@ dm9000_rx(struct net_device *dev)
 		ior(db, DM9000_MRCMDX);	/* Dummy read */
 
 		/* Get most updated data */
-		rxbyte = readb(db->io_data);
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+      rxbyte = (u8)readl(db->io_data);
+#else
+      rxbyte = readb(db->io_data);
+#endif
 
 		/* Status check: this byte must be 0 or 1 */
 		if (rxbyte & DM9000_PKT_ERR) {
@@ -996,7 +1050,12 @@ dm9000_rx(struct net_device *dev)
 
 		/* A packet ready now  & Get status/length */
 		GoodPacket = true;
+
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+		writel(DM9000_MRCMD, db->io_addr);
+#else
 		writeb(DM9000_MRCMD, db->io_addr);
+#endif
 
 		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
 
@@ -1085,7 +1144,11 @@ static irqreturn_t dm9000_interrupt(int
 	spin_lock_irqsave(&db->lock, flags);
 
 	/* Save previous register address */
-	reg_save = readb(db->io_addr);
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+   reg_save = (u8)readl(db->io_addr);
+#else
+   reg_save = readb(db->io_addr);
+#endif
 
 	/* Disable all interrupts */
 	iow(db, DM9000_IMR, IMR_PAR);
@@ -1116,7 +1179,11 @@ static irqreturn_t dm9000_interrupt(int
 	iow(db, DM9000_IMR, db->imr_all);
 
 	/* Restore previous register address */
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(reg_save, db->io_addr);
+#else
 	writeb(reg_save, db->io_addr);
+#endif
 
 	spin_unlock_irqrestore(&db->lock, flags);
 
@@ -1237,7 +1304,11 @@ dm9000_phy_read(struct net_device *dev,
 	spin_lock_irqsave(&db->lock,flags);
 
 	/* Save previous register address */
-	reg_save = readb(db->io_addr);
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+   reg_save = (u8)readl(db->io_addr);
+#else
+   reg_save = readb(db->io_addr);
+#endif
 
 	/* Fill the phyxcer register into REG_0C */
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
@@ -1250,7 +1321,11 @@ dm9000_phy_read(struct net_device *dev,
 	dm9000_msleep(db, 1);		/* Wait read complete */
 
 	spin_lock_irqsave(&db->lock,flags);
-	reg_save = readb(db->io_addr);
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+   reg_save = (u8)readl(db->io_addr);
+#else
+   reg_save = readb(db->io_addr);
+#endif
 
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer read command */
 
@@ -1258,7 +1333,11 @@ dm9000_phy_read(struct net_device *dev,
 	ret = (ior(db, DM9000_EPDRH) << 8) | ior(db, DM9000_EPDRL);
 
 	/* restore the previous address */
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(reg_save, db->io_addr);
+#else
 	writeb(reg_save, db->io_addr);
+#endif
 	spin_unlock_irqrestore(&db->lock,flags);
 
 	mutex_unlock(&db->addr_lock);
@@ -1284,7 +1363,11 @@ dm9000_phy_write(struct net_device *dev,
 	spin_lock_irqsave(&db->lock,flags);
 
 	/* Save previous register address */
-	reg_save = readb(db->io_addr);
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+   reg_save = (u8)readl(db->io_addr);
+#else
+   reg_save = readb(db->io_addr);
+#endif
 
 	/* Fill the phyxcer register into REG_0C */
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
@@ -1295,18 +1378,30 @@ dm9000_phy_write(struct net_device *dev,
 
 	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);	/* Issue phyxcer write command */
 
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(reg_save, db->io_addr);
+#else
 	writeb(reg_save, db->io_addr);
+#endif
 	spin_unlock_irqrestore(&db->lock, flags);
 
 	dm9000_msleep(db, 1);		/* Wait write complete */
 
 	spin_lock_irqsave(&db->lock,flags);
-	reg_save = readb(db->io_addr);
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+   reg_save = (u8)readl(db->io_addr);
+#else
+   reg_save = readb(db->io_addr);
+#endif
 
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
 
 	/* restore the previous address */
+#ifdef CONFIG_DM9000_32BIT_SW_SWAP
+	writel(reg_save, db->io_addr);
+#else
 	writeb(reg_save, db->io_addr);
+#endif
 
 	spin_unlock_irqrestore(&db->lock, flags);
 	mutex_unlock(&db->addr_lock);

--- linux/arch/m68k/include/asm/io_no.h.orig	2011-01-08 09:53:16.835301417 +0100
+++ linux/arch/m68k/include/asm/io_no.h	2011-01-08 09:53:18.523299757 +0100
@@ -47,6 +47,90 @@ static inline unsigned int _swapl(volati
 #define writew(b,addr) (void)((*(volatile unsigned short *) (addr)) = (b))
 #define writel(b,addr) (void)((*(volatile unsigned int *) (addr)) = (b))
 
+static inline void writesb (void __iomem *reg, void *data, int count)
+{
+	unsigned char *p = (unsigned char*) data;
+
+	while (count--) writeb(*p++, reg);
+}
+
+static inline void writesbsw (void __iomem *reg, void *data, int count)
+{
+	unsigned char *p = (unsigned char *) data;
+
+	while (count--) writel((int)(*p++), reg);
+}
+
+static inline void writesw (void __iomem *reg, void *data, int count)
+{
+   unsigned short *p = (unsigned short*) data;
+
+   while (count--) writew(*p++, reg);
+}
+
+static inline void writeswsw (void __iomem *reg, void *data, int count)
+{
+   unsigned short *p = (unsigned short *) data;
+
+   while (count--) writel((int)(_swapw(*p++)), reg);
+}
+
+static inline void writesl (void __iomem *reg, void *data, int count)
+{
+   unsigned long *p = (unsigned long*) data;
+
+   while (count--) writel(*p++, reg);
+}
+
+static inline void writeslsw (void __iomem *reg, void *data, int count)
+{
+   unsigned long *p = (unsigned long *) data;
+
+   while (count--) writel((int)(_swapl(*p++)), reg);
+}
+
+static inline void readsb (void __iomem *reg, void *data, int count)
+{
+   unsigned char *p = (unsigned char *) data;
+
+   while (count--) *p++ = readb(reg);
+}
+
+static inline void readsbsw (void __iomem *reg, void *data, int count)
+{
+   unsigned char *p = (unsigned char *) data;
+
+   while (count--) *p++ = (unsigned char)readl(reg);
+}
+
+static inline void readsw (void __iomem *reg, void *data, int count)
+{
+   unsigned short *p = (unsigned short *) data;
+
+   while (count--) *p++ = readb(reg);
+}
+
+static inline void readswsw (void __iomem *reg, void *data, int count)
+{
+   unsigned short *p = (unsigned short *) data;
+
+   while (count--) *p++ = _swapw((unsigned short)readw(reg));
+}
+
+static inline void readsl (void __iomem *reg, void *data, int count)
+{
+   unsigned long *p = (unsigned long *) data;
+
+   while (count--) *p++ = readb(reg);
+}
+
+static inline void readslsw (void __iomem *reg, void *data, int count)
+{
+   unsigned long *p = (unsigned long *) data;
+
+   while (count--) *p++ = _swapl(readl(reg));
+}
+
 #define __raw_readb readb
 #define __raw_readw readw
 #define __raw_readl readl
