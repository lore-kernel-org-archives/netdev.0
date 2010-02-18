From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 08/15] drivers/net/pci-skeleton.c: Use (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:55 -0800
Message-ID: <4c08791a2507a5d0624e8881eebfd7efff2d0eff.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1059 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051Ab0BRBCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:11 -0500
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Use netif_<level>
Checkpatch cleaning
Convert formats like 0x%08x to %#08x
Remove periods from formats
Coalesce long formats
Use print_hex_dump

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pci-skeleton.c | 1019 ++++++++++++++++++++++----------------------
 1 files changed, 503 insertions(+), 516 deletions(-)

diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index bbdf039..11d4398 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -11,7 +11,7 @@
 
 	-----<snip>-----
 
-        	Written 1997-2000 by Donald Becker.
+		Written 1997-2000 by Donald Becker.
 		This software may be used and distributed according to the
 		terms of the GNU General Public License (GPL), incorporated
 		herein by reference.  Drivers based on or derived from this
@@ -85,6 +85,8 @@ IVc. Errata
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
@@ -96,16 +98,15 @@ IVc. Errata
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/crc32.h>
-#include <asm/io.h>
+#include <linux/io.h>
 
 #define NETDRV_VERSION		"1.0.1"
 #define MODNAME			"netdrv"
 #define NETDRV_DRIVER_LOAD_MSG	"MyVendor Fast Ethernet driver " NETDRV_VERSION " loaded"
-#define PFX			MODNAME ": "
 
 static char version[] __devinitdata =
-KERN_INFO NETDRV_DRIVER_LOAD_MSG "\n"
-"  Support available from http://foo.com/bar/baz.html\n";
+	KERN_INFO NETDRV_DRIVER_LOAD_MSG "\n"
+	"  Support available from http://foo.com/bar/baz.html\n";
 
 /* define to 1 to enable PIO instead of MMIO */
 #undef USE_IO_OPS
@@ -119,19 +120,24 @@ KERN_INFO NETDRV_DRIVER_LOAD_MSG "\n"
 
 #ifdef NETDRV_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
+#define DPRINTK(fmt, args...)					\
+	printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
 #else
-#  define DPRINTK(fmt, args...)
+#define DPRINTK(fmt, args...)				\
+do {							\
+	if (0)						\
+		printk(KERN_DEBUG fmt, ##args);		\
+} while (0)
 #endif
 
 #ifdef NETDRV_NDEBUG
-#  define assert(expr) do {} while (0)
+#define assert(expr) do {} while (0)
 #else
-#  define assert(expr) \
-        if(!(expr)) {					\
-        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-        #expr,__FILE__,__func__,__LINE__);		\
-        }
+#define assert(expr)						\
+	if (!(expr)) {						\
+		printk("Assertion failed! %s,%s,%s,line=%d\n",	\
+		       #expr, __FILE__, __func__, __LINE__);	\
+	}
 #endif
 
 
@@ -148,10 +154,10 @@ static int multicast_filter_limit = 32;
 
 /* Size of the in-memory receive ring. */
 #define RX_BUF_LEN_IDX	2	/* 0==8K, 1==16K, 2==32K, 3==64K */
-#define RX_BUF_LEN (8192 << RX_BUF_LEN_IDX)
-#define RX_BUF_PAD 16
+#define RX_BUF_LEN	(8192 << RX_BUF_LEN_IDX)
+#define RX_BUF_PAD	16
 #define RX_BUF_WRAP_PAD 2048 /* spare padding to handle lack of packet wrap */
-#define RX_BUF_TOT_LEN (RX_BUF_LEN + RX_BUF_PAD + RX_BUF_WRAP_PAD)
+#define RX_BUF_TOT_LEN	(RX_BUF_LEN + RX_BUF_PAD + RX_BUF_WRAP_PAD)
 
 /* Number of Tx descriptor registers. */
 #define NUM_TX_DESC	4
@@ -165,9 +171,11 @@ static int multicast_filter_limit = 32;
 
 /* PCI Tuning Parameters
    Threshold is bytes transferred to chip before transmission starts. */
-#define TX_FIFO_THRESH 256	/* In bytes, rounded down to 32 byte units. */
+#define TX_FIFO_THRESH	256	/* In bytes, rounded down to 32 byte units. */
 
-/* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6==1024, 7==end of packet. */
+/* The following settings are log_2(bytes)-4:
+   0==16 bytes 1==32 2==64 3==128 4==256 5==512 6==1024 7==end of packet.
+*/
 #define RX_FIFO_THRESH	6	/* Rx buffer level before first PCI xfer.  */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
@@ -175,8 +183,7 @@ static int multicast_filter_limit = 32;
 
 /* Operational parameters that usually are not changed. */
 /* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT  (6*HZ)
-
+#define TX_TIMEOUT	(6 * HZ)
 
 enum {
 	HAS_CHIP_XCVR = 0x020000,
@@ -186,7 +193,7 @@ enum {
 #define NETDRV_MIN_IO_SIZE 0x80
 #define RTL8139B_IO_SIZE 256
 
-#define NETDRV_CAPS	HAS_CHIP_XCVR|HAS_LNK_CHNG
+#define NETDRV_CAPS	(HAS_CHIP_XCVR | HAS_LNK_CHNG)
 
 typedef enum {
 	RTL8139 = 0,
@@ -220,7 +227,7 @@ static DEFINE_PCI_DEVICE_TABLE(netdrv_pci_tbl) = {
 	{0x4033, 0x1360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ADDTRON8139 },
 	{0,}
 };
-MODULE_DEVICE_TABLE (pci, netdrv_pci_tbl);
+MODULE_DEVICE_TABLE(pci, netdrv_pci_tbl);
 
 
 /* The rest of these values should never change. */
@@ -270,7 +277,7 @@ enum NETDRV_registers {
 enum ClearBitMasks {
 	MultiIntrClear = 0xF000,
 	ChipCmdClear = 0xE2,
-	Config1Clear = (1<<7)|(1<<6)|(1<<3)|(1<<2)|(1<<1),
+	Config1Clear = (1 << 7) | (1 << 6) | (1 << 3) | (1 << 2) | (1 << 1),
 };
 
 enum ChipCmdBits {
@@ -329,7 +336,7 @@ enum tx_config_bits {
 	TxLoopBack = (1 << 18) | (1 << 17), /* enable loopback test mode */
 	TxCRC = (1 << 16),	/* DISABLE appending CRC to end of Tx packets */
 	TxClearAbt = (1 << 0),	/* Clear abort (WO) */
-	TxDMAShift = 8,		/* DMA burst value (0-7) is shift this many bits */
+	TxDMAShift = 8,		/* DMA burst value(0-7) is shift this many bits */
 
 	TxVersionMask = 0x7C800000, /* mask out version bits 30-26, 23 */
 };
@@ -481,41 +488,44 @@ struct netdrv_private {
 	chip_t chipset;
 };
 
-MODULE_AUTHOR ("Jeff Garzik <jgarzik@pobox.com>");
-MODULE_DESCRIPTION ("Skeleton for a PCI Fast Ethernet driver");
+MODULE_AUTHOR("Jeff Garzik <jgarzik@pobox.com>");
+MODULE_DESCRIPTION("Skeleton for a PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 module_param(multicast_filter_limit, int, 0);
 module_param(max_interrupt_work, int, 0);
 module_param_array(media, int, NULL, 0);
-MODULE_PARM_DESC (multicast_filter_limit, "pci-skeleton maximum number of filtered multicast addresses");
-MODULE_PARM_DESC (max_interrupt_work, "pci-skeleton maximum events handled per interrupt");
-MODULE_PARM_DESC (media, "pci-skeleton: Bits 0-3: media type, bit 17: full duplex");
-
-static int read_eeprom (void *ioaddr, int location, int addr_len);
-static int netdrv_open (struct net_device *dev);
-static int mdio_read (struct net_device *dev, int phy_id, int location);
-static void mdio_write (struct net_device *dev, int phy_id, int location,
-			int val);
-static void netdrv_timer (unsigned long data);
-static void netdrv_tx_timeout (struct net_device *dev);
-static void netdrv_init_ring (struct net_device *dev);
-static int netdrv_start_xmit (struct sk_buff *skb,
-			       struct net_device *dev);
-static irqreturn_t netdrv_interrupt (int irq, void *dev_instance);
-static int netdrv_close (struct net_device *dev);
-static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
-static void netdrv_set_rx_mode (struct net_device *dev);
-static void netdrv_hw_start (struct net_device *dev);
+MODULE_PARM_DESC(multicast_filter_limit,
+		 MODNAME " maximum number of filtered multicast addresses");
+MODULE_PARM_DESC(max_interrupt_work,
+		 MODNAME " maximum events handled per interrupt");
+MODULE_PARM_DESC(media,
+		 MODNAME " Bits 0-3: media type, bit 17: full duplex");
+
+static int read_eeprom(void *ioaddr, int location, int addr_len);
+static int netdrv_open(struct net_device *dev);
+static int mdio_read(struct net_device *dev, int phy_id, int location);
+static void mdio_write(struct net_device *dev, int phy_id, int location,
+		       int val);
+static void netdrv_timer(unsigned long data);
+static void netdrv_tx_timeout(struct net_device *dev);
+static void netdrv_init_ring(struct net_device *dev);
+static int netdrv_start_xmit(struct sk_buff *skb,
+			     struct net_device *dev);
+static irqreturn_t netdrv_interrupt(int irq, void *dev_instance);
+static int netdrv_close(struct net_device *dev);
+static int netdrv_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static void netdrv_set_rx_mode(struct net_device *dev);
+static void netdrv_hw_start(struct net_device *dev);
 
 
 #ifdef USE_IO_OPS
 
-#define NETDRV_R8(reg)		inb (((unsigned long)ioaddr) + (reg))
-#define NETDRV_R16(reg)		inw (((unsigned long)ioaddr) + (reg))
-#define NETDRV_R32(reg)		((unsigned long) inl (((unsigned long)ioaddr) + (reg)))
-#define NETDRV_W8(reg, val8)	outb ((val8), ((unsigned long)ioaddr) + (reg))
-#define NETDRV_W16(reg, val16)	outw ((val16), ((unsigned long)ioaddr) + (reg))
-#define NETDRV_W32(reg, val32)	outl ((val32), ((unsigned long)ioaddr) + (reg))
+#define NETDRV_R8(reg)		inb(((unsigned long)ioaddr) + (reg))
+#define NETDRV_R16(reg)		inw(((unsigned long)ioaddr) + (reg))
+#define NETDRV_R32(reg)		((unsigned long)inl(((unsigned long)ioaddr) + (reg)))
+#define NETDRV_W8(reg, val8)	outb((val8), ((unsigned long)ioaddr) + (reg))
+#define NETDRV_W16(reg, val16)	outw((val16), ((unsigned long)ioaddr) + (reg))
+#define NETDRV_W32(reg, val32)	outl((val32), ((unsigned long)ioaddr) + (reg))
 #define NETDRV_W8_F		NETDRV_W8
 #define NETDRV_W16_F		NETDRV_W16
 #define NETDRV_W32_F		NETDRV_W32
@@ -528,25 +538,37 @@ static void netdrv_hw_start (struct net_device *dev);
 #define readb(addr) inb((unsigned long)(addr))
 #define readw(addr) inw((unsigned long)(addr))
 #define readl(addr) inl((unsigned long)(addr))
-#define writeb(val,addr) outb((val),(unsigned long)(addr))
-#define writew(val,addr) outw((val),(unsigned long)(addr))
-#define writel(val,addr) outl((val),(unsigned long)(addr))
+#define writeb(val, addr) outb((val), (unsigned long)(addr))
+#define writew(val, addr) outw((val), (unsigned long)(addr))
+#define writel(val, addr) outl((val), (unsigned long)(addr))
 
 #else
 
 /* write MMIO register, with flush */
 /* Flush avoids rtl8139 bug w/ posted MMIO writes */
-#define NETDRV_W8_F(reg, val8)	do { writeb ((val8), ioaddr + (reg)); readb (ioaddr + (reg)); } while (0)
-#define NETDRV_W16_F(reg, val16)	do { writew ((val16), ioaddr + (reg)); readw (ioaddr + (reg)); } while (0)
-#define NETDRV_W32_F(reg, val32)	do { writel ((val32), ioaddr + (reg)); readl (ioaddr + (reg)); } while (0)
+#define NETDRV_W8_F(reg, val8)			\
+do {						\
+	writeb((val8), ioaddr + (reg));		\
+	readb(ioaddr + (reg));			\
+} while (0)
+#define NETDRV_W16_F(reg, val16)		\
+do {						\
+	writew((val16), ioaddr + (reg));	\
+	readw(ioaddr + (reg));			\
+} while (0)
+#define NETDRV_W32_F(reg, val32)		\
+do {						\
+	writel((val32), ioaddr + (reg));	\
+	readl(ioaddr + (reg));			\
+} while (0)
 
 
 #ifdef MMIO_FLUSH_AUDIT_COMPLETE
 
 /* write MMIO register */
-#define NETDRV_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
-#define NETDRV_W16(reg, val16)	writew ((val16), ioaddr + (reg))
-#define NETDRV_W32(reg, val32)	writel ((val32), ioaddr + (reg))
+#define NETDRV_W8(reg, val8)	writeb((val8), ioaddr + (reg))
+#define NETDRV_W16(reg, val16)	writew((val16), ioaddr + (reg))
+#define NETDRV_W32(reg, val32)	writel((val32), ioaddr + (reg))
 
 #else
 
@@ -558,9 +580,9 @@ static void netdrv_hw_start (struct net_device *dev);
 #endif /* MMIO_FLUSH_AUDIT_COMPLETE */
 
 /* read MMIO register */
-#define NETDRV_R8(reg)		readb (ioaddr + (reg))
-#define NETDRV_R16(reg)		readw (ioaddr + (reg))
-#define NETDRV_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
+#define NETDRV_R8(reg)		readb(ioaddr + (reg))
+#define NETDRV_R16(reg)		readw(ioaddr + (reg))
+#define NETDRV_R32(reg)		((unsigned long) readl(ioaddr + (reg)))
 
 #endif /* USE_IO_OPS */
 
@@ -570,14 +592,14 @@ static const u16 netdrv_intr_mask =
 	TxErr | TxOK | RxErr | RxOK;
 
 static const unsigned int netdrv_rx_config =
-	  RxCfgEarlyRxNone | RxCfgRcv32K | RxNoWrap |
-	  (RX_FIFO_THRESH << RxCfgFIFOShift) |
-	  (RX_DMA_BURST << RxCfgDMAShift);
+	RxCfgEarlyRxNone | RxCfgRcv32K | RxNoWrap |
+	(RX_FIFO_THRESH << RxCfgFIFOShift) |
+	(RX_DMA_BURST << RxCfgDMAShift);
 
 
-static int __devinit netdrv_init_board (struct pci_dev *pdev,
-					 struct net_device **dev_out,
-					 void **ioaddr_out)
+static int __devinit netdrv_init_board(struct pci_dev *pdev,
+				       struct net_device **dev_out,
+				       void **ioaddr_out)
 {
 	void *ioaddr = NULL;
 	struct net_device *dev;
@@ -587,43 +609,43 @@ static int __devinit netdrv_init_board (struct pci_dev *pdev,
 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
 	u32 tmp;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
-	assert (pdev != NULL);
-	assert (ioaddr_out != NULL);
+	assert(pdev != NULL);
+	assert(ioaddr_out != NULL);
 
 	*ioaddr_out = NULL;
 	*dev_out = NULL;
 
 	/* dev zeroed in alloc_etherdev */
-	dev = alloc_etherdev (sizeof (*tp));
+	dev = alloc_etherdev(sizeof(*tp));
 	if (dev == NULL) {
 		dev_err(&pdev->dev, "unable to alloc new ethernet\n");
-		DPRINTK ("EXIT, returning -ENOMEM\n");
+		DPRINTK("EXIT, returning -ENOMEM\n");
 		return -ENOMEM;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = netdev_priv(dev);
 
-	/* enable device (incl. PCI PM wakeup), and bus-mastering */
-	rc = pci_enable_device (pdev);
+	/* enable device(incl. PCI PM wakeup), and bus-mastering */
+	rc = pci_enable_device(pdev);
 	if (rc)
 		goto err_out;
 
-	pio_start = pci_resource_start (pdev, 0);
-	pio_end = pci_resource_end (pdev, 0);
-	pio_flags = pci_resource_flags (pdev, 0);
-	pio_len = pci_resource_len (pdev, 0);
+	pio_start = pci_resource_start(pdev, 0);
+	pio_end = pci_resource_end(pdev, 0);
+	pio_flags = pci_resource_flags(pdev, 0);
+	pio_len = pci_resource_len(pdev, 0);
 
-	mmio_start = pci_resource_start (pdev, 1);
-	mmio_end = pci_resource_end (pdev, 1);
-	mmio_flags = pci_resource_flags (pdev, 1);
-	mmio_len = pci_resource_len (pdev, 1);
+	mmio_start = pci_resource_start(pdev, 1);
+	mmio_end = pci_resource_end(pdev, 1);
+	mmio_flags = pci_resource_flags(pdev, 1);
+	mmio_len = pci_resource_len(pdev, 1);
 
 	/* set this immediately, we need to know before
 	 * we talk to the chip directly */
-	DPRINTK("PIO region size == 0x%02X\n", pio_len);
-	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
+	DPRINTK("PIO region size == %#02X\n", pio_len);
+	DPRINTK("MMIO region size == %#02lX\n", mmio_len);
 
 	/* make sure PCI base addr 0 is PIO */
 	if (!(pio_flags & IORESOURCE_IO)) {
@@ -647,17 +669,17 @@ static int __devinit netdrv_init_board (struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	rc = pci_request_regions (pdev, MODNAME);
+	rc = pci_request_regions(pdev, MODNAME);
 	if (rc)
 		goto err_out;
 
-	pci_set_master (pdev);
+	pci_set_master(pdev);
 
 #ifdef USE_IO_OPS
-	ioaddr = (void *) pio_start;
+	ioaddr = (void *)pio_start;
 #else
 	/* ioremap MMIO region */
-	ioaddr = ioremap (mmio_start, mmio_len);
+	ioaddr = ioremap(mmio_start, mmio_len);
 	if (ioaddr == NULL) {
 		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
 		rc = -EIO;
@@ -666,52 +688,50 @@ static int __devinit netdrv_init_board (struct pci_dev *pdev,
 #endif /* USE_IO_OPS */
 
 	/* Soft reset the chip. */
-	NETDRV_W8 (ChipCmd, (NETDRV_R8 (ChipCmd) & ChipCmdClear) | CmdReset);
+	NETDRV_W8(ChipCmd, (NETDRV_R8(ChipCmd) & ChipCmdClear) | CmdReset);
 
 	/* Check that the chip has finished the reset. */
 	for (i = 1000; i > 0; i--)
-		if ((NETDRV_R8 (ChipCmd) & CmdReset) == 0)
+		if ((NETDRV_R8(ChipCmd) & CmdReset) == 0)
 			break;
 		else
-			udelay (10);
+			udelay(10);
 
 	/* Bring the chip out of low-power mode. */
 	/* <insert device-specific code here> */
 
 #ifndef USE_IO_OPS
 	/* sanity checks -- ensure PIO and MMIO registers agree */
-	assert (inb (pio_start+Config0) == readb (ioaddr+Config0));
-	assert (inb (pio_start+Config1) == readb (ioaddr+Config1));
-	assert (inb (pio_start+TxConfig) == readb (ioaddr+TxConfig));
-	assert (inb (pio_start+RxConfig) == readb (ioaddr+RxConfig));
+	assert(inb(pio_start+Config0) == readb(ioaddr+Config0));
+	assert(inb(pio_start+Config1) == readb(ioaddr+Config1));
+	assert(inb(pio_start+TxConfig) == readb(ioaddr+TxConfig));
+	assert(inb(pio_start+RxConfig) == readb(ioaddr+RxConfig));
 #endif /* !USE_IO_OPS */
 
 	/* identify chip attached to board */
-	tmp = NETDRV_R8 (ChipVersion);
-	for (i = ARRAY_SIZE (rtl_chip_info) - 1; i >= 0; i--)
+	tmp = NETDRV_R8(ChipVersion);
+	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--)
 		if (tmp == rtl_chip_info[i].version) {
 			tp->chipset = i;
 			goto match;
 		}
 
 	/* if unknown chip, assume array element #0, original RTL-8139 in this case */
-	dev_printk (KERN_DEBUG, &pdev->dev,
-		"unknown chip version, assuming RTL-8139\n");
-	dev_printk (KERN_DEBUG, &pdev->dev, "TxConfig = 0x%lx\n",
-		NETDRV_R32 (TxConfig));
+	dev_printk(KERN_DEBUG, &pdev->dev,
+		   "unknown chip version, assuming RTL-8139\n");
+	dev_printk(KERN_DEBUG, &pdev->dev, "TxConfig = %#lx\n",
+		   NETDRV_R32(TxConfig));
 	tp->chipset = 0;
 
 match:
-	DPRINTK ("chipset id (%d) == index %d, '%s'\n",
-		tmp,
-		tp->chipset,
-		rtl_chip_info[tp->chipset].name);
+	DPRINTK("chipset id(%d) == index %d, '%s'\n",
+		tmp, tp->chipset, rtl_chip_info[tp->chipset].name);
 
-	rc = register_netdev (dev);
+	rc = register_netdev(dev);
 	if (rc)
 		goto err_out_unmap;
 
-	DPRINTK ("EXIT, returning 0\n");
+	DPRINTK("EXIT, returning 0\n");
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
 	return 0;
@@ -721,10 +741,10 @@ err_out_unmap:
 	iounmap(ioaddr);
 err_out_free_res:
 #endif
-	pci_release_regions (pdev);
+	pci_release_regions(pdev);
 err_out:
-	free_netdev (dev);
-	DPRINTK ("EXIT, returning %d\n", rc);
+	free_netdev(dev);
+	DPRINTK("EXIT, returning %d\n", rc);
 	return rc;
 }
 
@@ -740,8 +760,8 @@ static const struct net_device_ops netdrv_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit netdrv_init_one (struct pci_dev *pdev,
-				       const struct pci_device_id *ent)
+static int __devinit netdrv_init_one(struct pci_dev *pdev,
+				     const struct pci_device_id *ent)
 {
 	struct net_device *dev = NULL;
 	struct netdrv_private *tp;
@@ -756,29 +776,29 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 		printk(version);
 #endif
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
-	assert (pdev != NULL);
-	assert (ent != NULL);
+	assert(pdev != NULL);
+	assert(ent != NULL);
 
 	board_idx++;
 
-	i = netdrv_init_board (pdev, &dev, &ioaddr);
+	i = netdrv_init_board(pdev, &dev, &ioaddr);
 	if (i < 0) {
-		DPRINTK ("EXIT, returning %d\n", i);
+		DPRINTK("EXIT, returning %d\n", i);
 		return i;
 	}
 
 	tp = netdev_priv(dev);
 
-	assert (ioaddr != NULL);
-	assert (dev != NULL);
-	assert (tp != NULL);
+	assert(ioaddr != NULL);
+	assert(dev != NULL);
+	assert(tp != NULL);
 
-	addr_len = read_eeprom (ioaddr, 0, 8) == 0x8129 ? 8 : 6;
+	addr_len = read_eeprom(ioaddr, 0, 8) == 0x8129 ? 8 : 6;
 	for (i = 0; i < 3; i++)
-		((u16 *) (dev->dev_addr))[i] =
-		    le16_to_cpu (read_eeprom (ioaddr, i + 7, addr_len));
+		((u16 *)(dev->dev_addr))[i] =
+			le16_to_cpu(read_eeprom(ioaddr, i + 7, addr_len));
 
 	dev->netdev_ops = &netdrv_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
@@ -791,7 +811,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 
 	/* note: tp->chipset set in netdrv_init_board */
 	tp->drv_flags = PCI_COMMAND_IO | PCI_COMMAND_MEMORY |
-			PCI_COMMAND_MASTER | NETDRV_CAPS;
+		PCI_COMMAND_MASTER | NETDRV_CAPS;
 	tp->pci_dev = pdev;
 	tp->board = ent->driver_data;
 	tp->mmio_addr = ioaddr;
@@ -801,18 +821,15 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 
 	tp->phys[0] = 32;
 
-	printk (KERN_INFO "%s: %s at 0x%lx, %pM IRQ %d\n",
-		dev->name,
-		board_info[ent->driver_data].name,
-		dev->base_addr,
-		dev->dev_addr,
-		dev->irq);
+	netdev_info(dev, "%s at %#lx, %pM IRQ %d\n",
+		    board_info[ent->driver_data].name,
+		    dev->base_addr, dev->dev_addr, dev->irq);
 
-	printk (KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
-		dev->name, rtl_chip_info[tp->chipset].name);
+	netdev_printk(KERN_DEBUG, dev, "Identified 8139 chip type '%s'\n",
+		      rtl_chip_info[tp->chipset].name);
 
 	/* Put the chip into low-power mode. */
-	NETDRV_W8_F (Cfg9346, Cfg9346_Unlock);
+	NETDRV_W8_F(Cfg9346, Cfg9346_Unlock);
 
 	/* The lower four bits are the media type. */
 	option = (board_idx > 7) ? 0 : media[board_idx];
@@ -824,45 +841,43 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 	}
 
 	if (tp->full_duplex) {
-		printk (KERN_INFO
-			"%s: Media type forced to Full Duplex.\n",
-			dev->name);
-		mdio_write (dev, tp->phys[0], MII_ADVERTISE, ADVERTISE_FULL);
+		netdev_info(dev, "Media type forced to Full Duplex\n");
+		mdio_write(dev, tp->phys[0], MII_ADVERTISE, ADVERTISE_FULL);
 		tp->duplex_lock = 1;
 	}
 
-	DPRINTK ("EXIT - returning 0\n");
+	DPRINTK("EXIT - returning 0\n");
 	return 0;
 }
 
 
-static void __devexit netdrv_remove_one (struct pci_dev *pdev)
+static void __devexit netdrv_remove_one(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 	struct netdrv_private *np;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
-	assert (dev != NULL);
+	assert(dev != NULL);
 
 	np = netdev_priv(dev);
-	assert (np != NULL);
+	assert(np != NULL);
 
-	unregister_netdev (dev);
+	unregister_netdev(dev);
 
 #ifndef USE_IO_OPS
-	iounmap (np->mmio_addr);
+	iounmap(np->mmio_addr);
 #endif /* !USE_IO_OPS */
 
-	pci_release_regions (pdev);
+	pci_release_regions(pdev);
 
-	free_netdev (dev);
+	free_netdev(dev);
 
-	pci_set_drvdata (pdev, NULL);
+	pci_set_drvdata(pdev, NULL);
 
-	pci_disable_device (pdev);
+	pci_disable_device(pdev);
 
-	DPRINTK ("EXIT\n");
+	DPRINTK("EXIT\n");
 }
 
 
@@ -870,63 +885,63 @@ static void __devexit netdrv_remove_one (struct pci_dev *pdev)
 
 /*  EEPROM_Ctrl bits. */
 #define EE_SHIFT_CLK	0x04	/* EEPROM shift clock. */
-#define EE_CS			0x08	/* EEPROM chip select. */
+#define EE_CS		0x08	/* EEPROM chip select. */
 #define EE_DATA_WRITE	0x02	/* EEPROM chip data in. */
-#define EE_WRITE_0		0x00
-#define EE_WRITE_1		0x02
+#define EE_WRITE_0	0x00
+#define EE_WRITE_1	0x02
 #define EE_DATA_READ	0x01	/* EEPROM chip data out. */
-#define EE_ENB			(0x80 | EE_CS)
+#define EE_ENB		(0x80 | EE_CS)
 
 /* Delay between EEPROM clock transitions.
    No extra delay is needed with 33Mhz PCI, but 66Mhz may change this.
- */
+*/
 
 #define eeprom_delay()	readl(ee_addr)
 
 /* The EEPROM commands include the alway-set leading bit. */
 #define EE_WRITE_CMD	(5)
-#define EE_READ_CMD		(6)
+#define EE_READ_CMD	(6)
 #define EE_ERASE_CMD	(7)
 
-static int __devinit read_eeprom (void *ioaddr, int location, int addr_len)
+static int __devinit read_eeprom(void *ioaddr, int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
 	void *ee_addr = ioaddr + Cfg9346;
 	int read_cmd = location | (EE_READ_CMD << addr_len);
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
-	writeb (EE_ENB & ~EE_CS, ee_addr);
-	writeb (EE_ENB, ee_addr);
-	eeprom_delay ();
+	writeb(EE_ENB & ~EE_CS, ee_addr);
+	writeb(EE_ENB, ee_addr);
+	eeprom_delay();
 
 	/* Shift the read command bits out. */
 	for (i = 4 + addr_len; i >= 0; i--) {
 		int dataval = (read_cmd & (1 << i)) ? EE_DATA_WRITE : 0;
-		writeb (EE_ENB | dataval, ee_addr);
-		eeprom_delay ();
-		writeb (EE_ENB | dataval | EE_SHIFT_CLK, ee_addr);
-		eeprom_delay ();
+		writeb(EE_ENB | dataval, ee_addr);
+		eeprom_delay();
+		writeb(EE_ENB | dataval | EE_SHIFT_CLK, ee_addr);
+		eeprom_delay();
 	}
-	writeb (EE_ENB, ee_addr);
-	eeprom_delay ();
+	writeb(EE_ENB, ee_addr);
+	eeprom_delay();
 
 	for (i = 16; i > 0; i--) {
-		writeb (EE_ENB | EE_SHIFT_CLK, ee_addr);
-		eeprom_delay ();
+		writeb(EE_ENB | EE_SHIFT_CLK, ee_addr);
+		eeprom_delay();
 		retval =
-		    (retval << 1) | ((readb (ee_addr) & EE_DATA_READ) ? 1 :
-				     0);
-		writeb (EE_ENB, ee_addr);
-		eeprom_delay ();
+			(retval << 1) | ((readb(ee_addr) & EE_DATA_READ) ? 1 :
+					0);
+		writeb(EE_ENB, ee_addr);
+		eeprom_delay();
 	}
 
 	/* Terminate the EEPROM access. */
-	writeb (~EE_CS, ee_addr);
-	eeprom_delay ();
+	writeb(~EE_CS, ee_addr);
+	eeprom_delay();
 
-	DPRINTK ("EXIT - returning %d\n", retval);
+	DPRINTK("EXIT - returning %d\n", retval);
 	return retval;
 }
 
@@ -936,12 +951,12 @@ static int __devinit read_eeprom (void *ioaddr, int location, int addr_len)
    The maximum data clock rate is 2.5 Mhz.  The minimum timing is usually
    met by back-to-back PCI I/O cycles, but we insert a delay to avoid
    "overclocking" issues. */
-#define MDIO_DIR		0x80
+#define MDIO_DIR	0x80
 #define MDIO_DATA_OUT	0x04
 #define MDIO_DATA_IN	0x02
-#define MDIO_CLK		0x01
-#define MDIO_WRITE0 (MDIO_DIR)
-#define MDIO_WRITE1 (MDIO_DIR | MDIO_DATA_OUT)
+#define MDIO_CLK	0x01
+#define MDIO_WRITE0	(MDIO_DIR)
+#define MDIO_WRITE1	(MDIO_DIR | MDIO_DATA_OUT)
 
 #define mdio_delay()	readb(mdio_addr)
 
@@ -959,24 +974,24 @@ static char mii_2_8139_map[8] = {
 
 
 /* Syncronize the MII management interface by shifting 32 one bits out. */
-static void mdio_sync (void *mdio_addr)
+static void mdio_sync(void *mdio_addr)
 {
 	int i;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
 	for (i = 32; i >= 0; i--) {
-		writeb (MDIO_WRITE1, mdio_addr);
-		mdio_delay ();
-		writeb (MDIO_WRITE1 | MDIO_CLK, mdio_addr);
-		mdio_delay ();
+		writeb(MDIO_WRITE1, mdio_addr);
+		mdio_delay();
+		writeb(MDIO_WRITE1 | MDIO_CLK, mdio_addr);
+		mdio_delay();
 	}
 
-	DPRINTK ("EXIT\n");
+	DPRINTK("EXIT\n");
 }
 
 
-static int mdio_read (struct net_device *dev, int phy_id, int location)
+static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
@@ -984,97 +999,94 @@ static int mdio_read (struct net_device *dev, int phy_id, int location)
 	int retval = 0;
 	int i;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
 	if (phy_id > 31) {	/* Really a 8139.  Use internal registers. */
-		DPRINTK ("EXIT after directly using 8139 internal regs\n");
+		DPRINTK("EXIT after directly using 8139 internal regs\n");
 		return location < 8 && mii_2_8139_map[location] ?
-		    readw (tp->mmio_addr + mii_2_8139_map[location]) : 0;
+			readw(tp->mmio_addr + mii_2_8139_map[location]) : 0;
 	}
-	mdio_sync (mdio_addr);
+	mdio_sync(mdio_addr);
 	/* Shift the read command bits out. */
 	for (i = 15; i >= 0; i--) {
 		int dataval = (mii_cmd & (1 << i)) ? MDIO_DATA_OUT : 0;
 
-		writeb (MDIO_DIR | dataval, mdio_addr);
-		mdio_delay ();
-		writeb (MDIO_DIR | dataval | MDIO_CLK, mdio_addr);
-		mdio_delay ();
+		writeb(MDIO_DIR | dataval, mdio_addr);
+		mdio_delay();
+		writeb(MDIO_DIR | dataval | MDIO_CLK, mdio_addr);
+		mdio_delay();
 	}
 
 	/* Read the two transition, 16 data, and wire-idle bits. */
 	for (i = 19; i > 0; i--) {
-		writeb (0, mdio_addr);
-		mdio_delay ();
-		retval =
-		    (retval << 1) | ((readb (mdio_addr) & MDIO_DATA_IN) ? 1
-				     : 0);
-		writeb (MDIO_CLK, mdio_addr);
-		mdio_delay ();
+		writeb(0, mdio_addr);
+		mdio_delay();
+		retval = ((retval << 1) | ((readb(mdio_addr) & MDIO_DATA_IN))
+			  ? 1 : 0);
+		writeb(MDIO_CLK, mdio_addr);
+		mdio_delay();
 	}
 
-	DPRINTK ("EXIT, returning %d\n", (retval >> 1) & 0xffff);
+	DPRINTK("EXIT, returning %d\n", (retval >> 1) & 0xffff);
 	return (retval >> 1) & 0xffff;
 }
 
 
-static void mdio_write (struct net_device *dev, int phy_id, int location,
-			int value)
+static void mdio_write(struct net_device *dev, int phy_id, int location,
+		       int value)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd =
-	    (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
+		(0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
 	int i;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
 	if (phy_id > 31) {	/* Really a 8139.  Use internal registers. */
 		if (location < 8 && mii_2_8139_map[location]) {
-			writew (value,
-				tp->mmio_addr + mii_2_8139_map[location]);
-			readw (tp->mmio_addr + mii_2_8139_map[location]);
+			writew(value,
+			       tp->mmio_addr + mii_2_8139_map[location]);
+			readw(tp->mmio_addr + mii_2_8139_map[location]);
 		}
-		DPRINTK ("EXIT after directly using 8139 internal regs\n");
+		DPRINTK("EXIT after directly using 8139 internal regs\n");
 		return;
 	}
-	mdio_sync (mdio_addr);
+	mdio_sync(mdio_addr);
 
 	/* Shift the command bits out. */
 	for (i = 31; i >= 0; i--) {
 		int dataval =
-		    (mii_cmd & (1 << i)) ? MDIO_WRITE1 : MDIO_WRITE0;
-		writeb (dataval, mdio_addr);
-		mdio_delay ();
-		writeb (dataval | MDIO_CLK, mdio_addr);
-		mdio_delay ();
+			(mii_cmd & (1 << i)) ? MDIO_WRITE1 : MDIO_WRITE0;
+		writeb(dataval, mdio_addr);
+		mdio_delay();
+		writeb(dataval | MDIO_CLK, mdio_addr);
+		mdio_delay();
 	}
 
 	/* Clear out extra bits. */
 	for (i = 2; i > 0; i--) {
-		writeb (0, mdio_addr);
-		mdio_delay ();
-		writeb (MDIO_CLK, mdio_addr);
-		mdio_delay ();
+		writeb(0, mdio_addr);
+		mdio_delay();
+		writeb(MDIO_CLK, mdio_addr);
+		mdio_delay();
 	}
 
-	DPRINTK ("EXIT\n");
+	DPRINTK("EXIT\n");
 }
 
 
-static int netdrv_open (struct net_device *dev)
+static int netdrv_open(struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	int retval;
-#ifdef NETDRV_DEBUG
 	void *ioaddr = tp->mmio_addr;
-#endif
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
-	retval = request_irq (dev->irq, netdrv_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(dev->irq, netdrv_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval) {
-		DPRINTK ("EXIT, returning %d\n", retval);
+		DPRINTK("EXIT, returning %d\n", retval);
 		return retval;
 	}
 
@@ -1092,7 +1104,7 @@ static int netdrv_open (struct net_device *dev)
 			pci_free_consistent(tp->pci_dev, RX_BUF_TOT_LEN,
 					    tp->rx_ring, tp->rx_ring_dma);
 
-		DPRINTK ("EXIT, returning -ENOMEM\n");
+		DPRINTK("EXIT, returning -ENOMEM\n");
 		return -ENOMEM;
 
 	}
@@ -1100,109 +1112,108 @@ static int netdrv_open (struct net_device *dev)
 	tp->full_duplex = tp->duplex_lock;
 	tp->tx_flag = (TX_FIFO_THRESH << 11) & 0x003f0000;
 
-	netdrv_init_ring (dev);
-	netdrv_hw_start (dev);
+	netdrv_init_ring(dev);
+	netdrv_hw_start(dev);
 
-	DPRINTK ("%s: netdrv_open() ioaddr %#lx IRQ %d"
-			" GP Pins %2.2x %s-duplex.\n",
-			dev->name, pci_resource_start (tp->pci_dev, 1),
-			dev->irq, NETDRV_R8 (MediaStatus),
-			tp->full_duplex ? "full" : "half");
+	netdev_dbg(dev, "ioaddr %#llx IRQ %d GP Pins %02x %s-duplex\n",
+		   (unsigned long long)pci_resource_start(tp->pci_dev, 1),
+		   dev->irq, NETDRV_R8(MediaStatus),
+		   tp->full_duplex ? "full" : "half");
 
 	/* Set the timer to switch to check for link beat and perhaps switch
 	   to an alternate media type. */
-	init_timer (&tp->timer);
+	init_timer(&tp->timer);
 	tp->timer.expires = jiffies + 3 * HZ;
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = &netdrv_timer;
-	add_timer (&tp->timer);
+	add_timer(&tp->timer);
 
-	DPRINTK ("EXIT, returning 0\n");
+	DPRINTK("EXIT, returning 0\n");
 	return 0;
 }
 
 
 /* Start the hardware at open or resume. */
-static void netdrv_hw_start (struct net_device *dev)
+static void netdrv_hw_start(struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
 	/* Soft reset the chip. */
-	NETDRV_W8 (ChipCmd, (NETDRV_R8 (ChipCmd) & ChipCmdClear) | CmdReset);
-	udelay (100);
+	NETDRV_W8(ChipCmd, (NETDRV_R8(ChipCmd) & ChipCmdClear) | CmdReset);
+	udelay(100);
 
 	/* Check that the chip has finished the reset. */
 	for (i = 1000; i > 0; i--)
-		if ((NETDRV_R8 (ChipCmd) & CmdReset) == 0)
+		if ((NETDRV_R8(ChipCmd) & CmdReset) == 0)
 			break;
 
 	/* Restore our idea of the MAC address. */
-	NETDRV_W32_F (MAC0 + 0, cpu_to_le32 (*(u32 *) (dev->dev_addr + 0)));
-	NETDRV_W32_F (MAC0 + 4, cpu_to_le32 (*(u32 *) (dev->dev_addr + 4)));
+	NETDRV_W32_F(MAC0 + 0, cpu_to_le32(*(u32 *)(dev->dev_addr + 0)));
+	NETDRV_W32_F(MAC0 + 4, cpu_to_le32(*(u32 *)(dev->dev_addr + 4)));
 
 	/* Must enable Tx/Rx before setting transfer thresholds! */
-	NETDRV_W8_F (ChipCmd, (NETDRV_R8 (ChipCmd) & ChipCmdClear) |
-			   CmdRxEnb | CmdTxEnb);
+	NETDRV_W8_F(ChipCmd, (NETDRV_R8(ChipCmd) & ChipCmdClear) |
+		    CmdRxEnb | CmdTxEnb);
 
 	i = netdrv_rx_config |
-	    (NETDRV_R32 (RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
-	NETDRV_W32_F (RxConfig, i);
+		(NETDRV_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
+	NETDRV_W32_F(RxConfig, i);
 
 	/* Check this value: the documentation for IFG contradicts ifself. */
-	NETDRV_W32 (TxConfig, (TX_DMA_BURST << TxDMAShift));
+	NETDRV_W32(TxConfig, (TX_DMA_BURST << TxDMAShift));
 
 	/* unlock Config[01234] and BMCR register writes */
-	NETDRV_W8_F (Cfg9346, Cfg9346_Unlock);
-	udelay (10);
+	NETDRV_W8_F(Cfg9346, Cfg9346_Unlock);
+	udelay(10);
 
 	tp->cur_rx = 0;
 
 	/* Lock Config[01234] and BMCR register writes */
-	NETDRV_W8_F (Cfg9346, Cfg9346_Lock);
-	udelay (10);
+	NETDRV_W8_F(Cfg9346, Cfg9346_Lock);
+	udelay(10);
 
 	/* init Rx ring buffer DMA address */
-	NETDRV_W32_F (RxBuf, tp->rx_ring_dma);
+	NETDRV_W32_F(RxBuf, tp->rx_ring_dma);
 
 	/* init Tx buffer DMA addresses */
 	for (i = 0; i < NUM_TX_DESC; i++)
-		NETDRV_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs));
+		NETDRV_W32_F(TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs));
 
-	NETDRV_W32_F (RxMissed, 0);
+	NETDRV_W32_F(RxMissed, 0);
 
-	netdrv_set_rx_mode (dev);
+	netdrv_set_rx_mode(dev);
 
 	/* no early-rx interrupts */
-	NETDRV_W16 (MultiIntr, NETDRV_R16 (MultiIntr) & MultiIntrClear);
+	NETDRV_W16(MultiIntr, NETDRV_R16(MultiIntr) & MultiIntrClear);
 
 	/* make sure RxTx has started */
-	NETDRV_W8_F (ChipCmd, (NETDRV_R8 (ChipCmd) & ChipCmdClear) |
-			   CmdRxEnb | CmdTxEnb);
+	NETDRV_W8_F(ChipCmd, (NETDRV_R8(ChipCmd) & ChipCmdClear) |
+		    CmdRxEnb | CmdTxEnb);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	NETDRV_W16_F (IntrMask, netdrv_intr_mask);
+	NETDRV_W16_F(IntrMask, netdrv_intr_mask);
 
-	netif_start_queue (dev);
+	netif_start_queue(dev);
 
-	DPRINTK ("EXIT\n");
+	DPRINTK("EXIT\n");
 }
 
 
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
-static void netdrv_init_ring (struct net_device *dev)
+static void netdrv_init_ring(struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	int i;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
 	tp->cur_rx = 0;
-	atomic_set (&tp->cur_tx, 0);
-	atomic_set (&tp->dirty_tx, 0);
+	atomic_set(&tp->cur_tx, 0);
+	atomic_set(&tp->dirty_tx, 0);
 
 	for (i = 0; i < NUM_TX_DESC; i++) {
 		tp->tx_info[i].skb = NULL;
@@ -1210,11 +1221,11 @@ static void netdrv_init_ring (struct net_device *dev)
 		tp->tx_buf[i] = &tp->tx_bufs[i * TX_BUF_SIZE];
 	}
 
-	DPRINTK ("EXIT\n");
+	DPRINTK("EXIT\n");
 }
 
 
-static void netdrv_timer (unsigned long data)
+static void netdrv_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct netdrv_private *tp = netdev_priv(dev);
@@ -1222,58 +1233,54 @@ static void netdrv_timer (unsigned long data)
 	int next_tick = 60 * HZ;
 	int mii_lpa;
 
-	mii_lpa = mdio_read (dev, tp->phys[0], MII_LPA);
+	mii_lpa = mdio_read(dev, tp->phys[0], MII_LPA);
 
 	if (!tp->duplex_lock && mii_lpa != 0xffff) {
 		int duplex = ((mii_lpa & LPA_100FULL) ||
-			      (mii_lpa & 0x01C0) == 0x0040);
+			     (mii_lpa & 0x01C0) == 0x0040);
 		if (tp->full_duplex != duplex) {
 			tp->full_duplex = duplex;
-			printk (KERN_INFO
-				"%s: Setting %s-duplex based on MII #%d link"
-				" partner ability of %4.4x.\n", dev->name,
-				tp->full_duplex ? "full" : "half",
-				tp->phys[0], mii_lpa);
-			NETDRV_W8 (Cfg9346, Cfg9346_Unlock);
-			NETDRV_W8 (Config1, tp->full_duplex ? 0x60 : 0x20);
-			NETDRV_W8 (Cfg9346, Cfg9346_Lock);
+			netdev_info(dev, "Setting %s-duplex based on MII #%d link partner ability of %04x\n",
+				    tp->full_duplex ? "full" : "half",
+				    tp->phys[0], mii_lpa);
+			NETDRV_W8(Cfg9346, Cfg9346_Unlock);
+			NETDRV_W8(Config1, tp->full_duplex ? 0x60 : 0x20);
+			NETDRV_W8(Cfg9346, Cfg9346_Lock);
 		}
 	}
 
-	DPRINTK ("%s: Media selection tick, Link partner %4.4x.\n",
-		 dev->name, NETDRV_R16 (NWayLPAR));
-	DPRINTK ("%s:  Other registers are IntMask %4.4x IntStatus %4.4x"
-		 " RxStatus %4.4x.\n", dev->name,
-		 NETDRV_R16 (IntrMask),
-		 NETDRV_R16 (IntrStatus),
-		 NETDRV_R32 (RxEarlyStatus));
-	DPRINTK ("%s:  Chip config %2.2x %2.2x.\n",
-		 dev->name, NETDRV_R8 (Config0),
-		 NETDRV_R8 (Config1));
+	netdev_dbg(dev, "Media selection tick, Link partner %04x\n",
+		   NETDRV_R16(NWayLPAR));
+	netdev_dbg(dev, "Other registers are IntMask %04x IntStatus %04x RxStatus %04lx\n",
+		   NETDRV_R16(IntrMask),
+		   NETDRV_R16(IntrStatus),
+		   NETDRV_R32(RxEarlyStatus));
+	netdev_dbg(dev, "Chip config %02x %02x\n",
+		   NETDRV_R8(Config0), NETDRV_R8(Config1));
 
 	tp->timer.expires = jiffies + next_tick;
-	add_timer (&tp->timer);
+	add_timer(&tp->timer);
 }
 
 
-static void netdrv_tx_clear (struct net_device *dev)
+static void netdrv_tx_clear(struct net_device *dev)
 {
 	int i;
 	struct netdrv_private *tp = netdev_priv(dev);
 
-	atomic_set (&tp->cur_tx, 0);
-	atomic_set (&tp->dirty_tx, 0);
+	atomic_set(&tp->cur_tx, 0);
+	atomic_set(&tp->dirty_tx, 0);
 
 	/* Dump the unsent Tx packets. */
 	for (i = 0; i < NUM_TX_DESC; i++) {
 		struct ring_info *rp = &tp->tx_info[i];
 		if (rp->mapping != 0) {
-			pci_unmap_single (tp->pci_dev, rp->mapping,
-					  rp->skb->len, PCI_DMA_TODEVICE);
+			pci_unmap_single(tp->pci_dev, rp->mapping,
+					 rp->skb->len, PCI_DMA_TODEVICE);
 			rp->mapping = 0;
 		}
 		if (rp->skb) {
-			dev_kfree_skb (rp->skb);
+			dev_kfree_skb(rp->skb);
 			rp->skb = NULL;
 			dev->stats.tx_dropped++;
 		}
@@ -1281,7 +1288,7 @@ static void netdrv_tx_clear (struct net_device *dev)
 }
 
 
-static void netdrv_tx_timeout (struct net_device *dev)
+static void netdrv_tx_timeout(struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
@@ -1289,96 +1296,95 @@ static void netdrv_tx_timeout (struct net_device *dev)
 	u8 tmp8;
 	unsigned long flags;
 
-	DPRINTK ("%s: Transmit timeout, status %2.2x %4.4x "
-		 "media %2.2x.\n", dev->name,
-		 NETDRV_R8 (ChipCmd),
-		 NETDRV_R16 (IntrStatus),
-		 NETDRV_R8 (MediaStatus));
+	netdev_dbg(dev, "Transmit timeout, status %02x %04x media %02x\n",
+		   NETDRV_R8(ChipCmd),
+		   NETDRV_R16(IntrStatus),
+		   NETDRV_R8(MediaStatus));
 
 	/* disable Tx ASAP, if not already */
-	tmp8 = NETDRV_R8 (ChipCmd);
+	tmp8 = NETDRV_R8(ChipCmd);
 	if (tmp8 & CmdTxEnb)
-		NETDRV_W8 (ChipCmd, tmp8 & ~CmdTxEnb);
+		NETDRV_W8(ChipCmd, tmp8 & ~CmdTxEnb);
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	NETDRV_W16 (IntrMask, 0x0000);
+	NETDRV_W16(IntrMask, 0x0000);
 
 	/* Emit info to figure out what went wrong. */
-	printk (KERN_DEBUG "%s: Tx queue start entry %d  dirty entry %d.\n",
-		dev->name, atomic_read (&tp->cur_tx),
-		atomic_read (&tp->dirty_tx));
+	netdev_dbg(dev, "Tx queue start entry %d dirty entry %d\n",
+		   atomic_read(&tp->cur_tx),
+		   atomic_read(&tp->dirty_tx));
 	for (i = 0; i < NUM_TX_DESC; i++)
-		printk (KERN_DEBUG "%s:  Tx descriptor %d is %8.8lx.%s\n",
-			dev->name, i, NETDRV_R32 (TxStatus0 + (i * 4)),
-			i == atomic_read (&tp->dirty_tx) % NUM_TX_DESC ?
-				" (queue head)" : "");
+		netdev_dbg(dev, "Tx descriptor %d is %08lx%s\n",
+			   i, NETDRV_R32(TxStatus0 + (i * 4)),
+			   i == atomic_read(&tp->dirty_tx) % NUM_TX_DESC ?
+			   "(queue head)" : "");
 
 	/* Stop a shared interrupt from scavenging while we are. */
-	spin_lock_irqsave (&tp->lock, flags);
+	spin_lock_irqsave(&tp->lock, flags);
 
-	netdrv_tx_clear (dev);
+	netdrv_tx_clear(dev);
 
-	spin_unlock_irqrestore (&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	/* ...and finally, reset everything */
-	netdrv_hw_start (dev);
+	netdrv_hw_start(dev);
 
-	netif_wake_queue (dev);
+	netif_wake_queue(dev);
 }
 
 
 
-static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static int netdrv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int entry;
 
 	/* Calculate the next Tx descriptor entry. */
-	entry = atomic_read (&tp->cur_tx) % NUM_TX_DESC;
+	entry = atomic_read(&tp->cur_tx) % NUM_TX_DESC;
 
-	assert (tp->tx_info[entry].skb == NULL);
-	assert (tp->tx_info[entry].mapping == 0);
+	assert(tp->tx_info[entry].skb == NULL);
+	assert(tp->tx_info[entry].mapping == 0);
 
 	tp->tx_info[entry].skb = skb;
 	/* tp->tx_info[entry].mapping = 0; */
 	skb_copy_from_linear_data(skb, tp->tx_buf[entry], skb->len);
 
 	/* Note: the chip doesn't have auto-pad! */
-	NETDRV_W32 (TxStatus0 + (entry * sizeof(u32)),
-		 tp->tx_flag | (skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN));
+	NETDRV_W32(TxStatus0 + (entry * sizeof(u32)),
+		   tp->tx_flag | (skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN));
 
 	dev->trans_start = jiffies;
-	atomic_inc (&tp->cur_tx);
-	if ((atomic_read (&tp->cur_tx) - atomic_read (&tp->dirty_tx)) >= NUM_TX_DESC)
-		netif_stop_queue (dev);
+	atomic_inc(&tp->cur_tx);
+	if ((atomic_read(&tp->cur_tx) - atomic_read(&tp->dirty_tx)) >= NUM_TX_DESC)
+		netif_stop_queue(dev);
 
-	DPRINTK ("%s: Queued Tx packet at %p size %u to slot %d.\n",
-		 dev->name, skb->data, skb->len, entry);
+	netdev_dbg(dev, "Queued Tx packet at %p size %u to slot %d\n",
+		   skb->data, skb->len, entry);
 
 	return NETDEV_TX_OK;
 }
 
 
-static void netdrv_tx_interrupt (struct net_device *dev,
-				  struct netdrv_private *tp,
-				  void *ioaddr)
+static void netdrv_tx_interrupt(struct net_device *dev,
+				struct netdrv_private *tp,
+				void *ioaddr)
 {
 	int cur_tx, dirty_tx, tx_left;
 
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
+	assert(dev != NULL);
+	assert(tp != NULL);
+	assert(ioaddr != NULL);
 
-	dirty_tx = atomic_read (&tp->dirty_tx);
+	dirty_tx = atomic_read(&tp->dirty_tx);
 
-	cur_tx = atomic_read (&tp->cur_tx);
+	cur_tx = atomic_read(&tp->cur_tx);
 	tx_left = cur_tx - dirty_tx;
 	while (tx_left > 0) {
 		int entry = dirty_tx % NUM_TX_DESC;
 		int txstatus;
 
-		txstatus = NETDRV_R32 (TxStatus0 + (entry * sizeof (u32)));
+		txstatus = NETDRV_R32(TxStatus0 + (entry * sizeof(u32)));
 
 		if (!(txstatus & (TxStatOK | TxUnderrun | TxAborted)))
 			break;	/* It still hasn't been Txed */
@@ -1386,12 +1392,12 @@ static void netdrv_tx_interrupt (struct net_device *dev,
 		/* Note: TxCarrierLost is always asserted at 100mbps. */
 		if (txstatus & (TxOutOfWindow | TxAborted)) {
 			/* There was an major error, log it. */
-			DPRINTK ("%s: Transmit error, Tx status %8.8x.\n",
-				 dev->name, txstatus);
+			netdev_dbg(dev, "Transmit error, Tx status %#08x\n",
+				   txstatus);
 			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
 				dev->stats.tx_aborted_errors++;
-				NETDRV_W32 (TxConfig, TxClearAbt | (TX_DMA_BURST << TxDMAShift));
+				NETDRV_W32(TxConfig, TxClearAbt | (TX_DMA_BURST << TxDMAShift));
 			}
 			if (txstatus & TxCarrierLost)
 				dev->stats.tx_carrier_errors++;
@@ -1417,48 +1423,45 @@ static void netdrv_tx_interrupt (struct net_device *dev,
 					 PCI_DMA_TODEVICE);
 			tp->tx_info[entry].mapping = 0;
 		}
-		dev_kfree_skb_irq (tp->tx_info[entry].skb);
+		dev_kfree_skb_irq(tp->tx_info[entry].skb);
 		tp->tx_info[entry].skb = NULL;
 		dirty_tx++;
 		if (dirty_tx < 0) { /* handle signed int overflow */
-			atomic_sub (cur_tx, &tp->cur_tx); /* XXX racy? */
+			atomic_sub(cur_tx, &tp->cur_tx); /* XXX racy? */
 			dirty_tx = cur_tx - tx_left + 1;
 		}
-		if (netif_queue_stopped (dev))
-			netif_wake_queue (dev);
+		if (netif_queue_stopped(dev))
+			netif_wake_queue(dev);
 
-		cur_tx = atomic_read (&tp->cur_tx);
+		cur_tx = atomic_read(&tp->cur_tx);
 		tx_left = cur_tx - dirty_tx;
 
 	}
 
 #ifndef NETDRV_NDEBUG
-	if (atomic_read (&tp->cur_tx) - dirty_tx > NUM_TX_DESC) {
-		printk (KERN_ERR
-		  "%s: Out-of-sync dirty pointer, %d vs. %d.\n",
-		     dev->name, dirty_tx, atomic_read (&tp->cur_tx));
+	if (atomic_read(&tp->cur_tx) - dirty_tx > NUM_TX_DESC) {
+		netdev_err(dev, "Out-of-sync dirty pointer, %d vs. %d\n",
+			   dirty_tx, atomic_read(&tp->cur_tx));
 		dirty_tx += NUM_TX_DESC;
 	}
 #endif /* NETDRV_NDEBUG */
 
-	atomic_set (&tp->dirty_tx, dirty_tx);
+	atomic_set(&tp->dirty_tx, dirty_tx);
 }
 
 
 /* TODO: clean this up!  Rx reset need not be this intensive */
-static void netdrv_rx_err (u32 rx_status, struct net_device *dev,
-			    struct netdrv_private *tp, void *ioaddr)
+static void netdrv_rx_err(u32 rx_status, struct net_device *dev,
+			  struct netdrv_private *tp, void *ioaddr)
 {
 	u8 tmp8;
 	int tmp_work = 1000;
 
-	DPRINTK ("%s: Ethernet frame had errors, status %8.8x.\n",
-	         dev->name, rx_status);
-	if (rx_status & RxTooLong) {
-		DPRINTK ("%s: Oversized Ethernet frame, status %4.4x!\n",
-			 dev->name, rx_status);
+	netdev_dbg(dev, "Ethernet frame had errors, status %08x\n", rx_status);
+	if (rx_status & RxTooLong)
+		netdev_dbg(dev, "Oversized Ethernet frame, status %04x!\n",
+			   rx_status);
 		/* A.C.: The chip hangs here. */
-	}
 	dev->stats.rx_errors++;
 	if (rx_status & (RxBadSymbol | RxBadAlign))
 		dev->stats.rx_frame_errors++;
@@ -1466,56 +1469,55 @@ static void netdrv_rx_err (u32 rx_status, struct net_device *dev,
 		dev->stats.rx_length_errors++;
 	if (rx_status & RxCRCErr)
 		dev->stats.rx_crc_errors++;
-	/* Reset the receiver, based on RealTek recommendation. (Bug?) */
+	/* Reset the receiver, based on RealTek recommendation.(Bug?) */
 	tp->cur_rx = 0;
 
 	/* disable receive */
-	tmp8 = NETDRV_R8 (ChipCmd) & ChipCmdClear;
-	NETDRV_W8_F (ChipCmd, tmp8 | CmdTxEnb);
+	tmp8 = NETDRV_R8(ChipCmd) & ChipCmdClear;
+	NETDRV_W8_F(ChipCmd, tmp8 | CmdTxEnb);
 
 	/* A.C.: Reset the multicast list. */
-	netdrv_set_rx_mode (dev);
+	netdrv_set_rx_mode(dev);
 
 	/* XXX potentially temporary hack to
 	 * restart hung receiver */
 	while (--tmp_work > 0) {
-		tmp8 = NETDRV_R8 (ChipCmd);
+		tmp8 = NETDRV_R8(ChipCmd);
 		if ((tmp8 & CmdRxEnb) && (tmp8 & CmdTxEnb))
 			break;
-		NETDRV_W8_F (ChipCmd,
-			  (tmp8 & ChipCmdClear) | CmdRxEnb | CmdTxEnb);
+		NETDRV_W8_F(ChipCmd,
+			    (tmp8 & ChipCmdClear) | CmdRxEnb | CmdTxEnb);
 	}
 
 	/* G.S.: Re-enable receiver */
 	/* XXX temporary hack to work around receiver hang */
-	netdrv_set_rx_mode (dev);
+	netdrv_set_rx_mode(dev);
 
 	if (tmp_work <= 0)
-		printk (KERN_WARNING PFX "tx/rx enable wait too long\n");
+		netdev_warn(dev, "tx/rx enable wait too long\n");
 }
 
 
 /* The data sheet doesn't describe the Rx ring at all, so I'm guessing at the
    field alignments and semantics. */
-static void netdrv_rx_interrupt (struct net_device *dev,
-				  struct netdrv_private *tp, void *ioaddr)
+static void netdrv_rx_interrupt(struct net_device *dev,
+				struct netdrv_private *tp, void *ioaddr)
 {
 	unsigned char *rx_ring;
 	u16 cur_rx;
 
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
+	assert(dev != NULL);
+	assert(tp != NULL);
+	assert(ioaddr != NULL);
 
 	rx_ring = tp->rx_ring;
 	cur_rx = tp->cur_rx;
 
-	DPRINTK ("%s: In netdrv_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
-		 NETDRV_R16 (RxBufAddr),
-		 NETDRV_R16 (RxBufPtr), NETDRV_R8 (ChipCmd));
+	netdev_dbg(dev, "In netdrv_rx(), current %04x BufAddr %04x, free to %04x, Cmd %02x\n",
+		   cur_rx, NETDRV_R16(RxBufAddr),
+		   NETDRV_R16(RxBufPtr), NETDRV_R8(ChipCmd));
 
-	while ((NETDRV_R8 (ChipCmd) & RxBufEmpty) == 0) {
+	while ((NETDRV_R8(ChipCmd) & RxBufEmpty) == 0) {
 		int ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
 		unsigned int rx_size;
@@ -1523,32 +1525,25 @@ static void netdrv_rx_interrupt (struct net_device *dev,
 		struct sk_buff *skb;
 
 		/* read size+status of next frame from DMA ring buffer */
-		rx_status = le32_to_cpu (*(u32 *) (rx_ring + ring_offset));
+		rx_status = le32_to_cpu(*(u32 *)(rx_ring + ring_offset));
 		rx_size = rx_status >> 16;
 		pkt_size = rx_size - 4;
 
-		DPRINTK ("%s:  netdrv_rx() status %4.4x, size %4.4x,"
-			 " cur %4.4x.\n", dev->name, rx_status,
-			 rx_size, cur_rx);
+		netdev_dbg(dev, "netdrv_rx() status %04x, size %04x, cur %04x\n",
+			   rx_status, rx_size, cur_rx);
 #if defined(NETDRV_DEBUG) && (NETDRV_DEBUG > 2)
-		{
-			int i;
-			DPRINTK ("%s: Frame contents ", dev->name);
-			for (i = 0; i < 70; i++)
-				printk (" %2.2x",
-					rx_ring[ring_offset + i]);
-			printk (".\n");
-		}
+		print_hex_dump_bytes("Frame contents: ", HEX_DUMP_OFFSET,
+				     &rx_ring[ring_offset], 70);
 #endif
 
 		/* If Rx err or invalid rx_size/rx_status received
-		 * (which happens if we get lost in the ring),
+		 *(which happens if we get lost in the ring),
 		 * Rx process gets reset, so we abort any further
 		 * Rx processing.
 		 */
 		if ((rx_size > (MAX_ETH_FRAME_SIZE+4)) ||
 		    (!(rx_status & RxStatusOK))) {
-			netdrv_rx_err (rx_status, dev, tp, ioaddr);
+			netdrv_rx_err(rx_status, dev, tp, ioaddr);
 			return;
 		}
 
@@ -1561,71 +1556,67 @@ static void netdrv_rx_interrupt (struct net_device *dev,
 		 * drop packets here under memory pressure.
 		 */
 
-		skb = dev_alloc_skb (pkt_size + 2);
+		skb = dev_alloc_skb(pkt_size + 2);
 		if (skb) {
-			skb_reserve (skb, 2);	/* 16 byte align the IP fields. */
+			skb_reserve(skb, 2);	/* 16 byte align the IP fields. */
 
-			skb_copy_to_linear_data (skb, &rx_ring[ring_offset + 4], pkt_size);
-			skb_put (skb, pkt_size);
+			skb_copy_to_linear_data(skb, &rx_ring[ring_offset + 4], pkt_size);
+			skb_put(skb, pkt_size);
 
-			skb->protocol = eth_type_trans (skb, dev);
-			netif_rx (skb);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
 		} else {
-			printk (KERN_WARNING
-				"%s: Memory squeeze, dropping packet.\n",
-				dev->name);
+			netdev_warn(dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 		}
 
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
-		NETDRV_W16_F (RxBufPtr, cur_rx - 16);
+		NETDRV_W16_F(RxBufPtr, cur_rx - 16);
 	}
 
-	DPRINTK ("%s: Done netdrv_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
-		 NETDRV_R16 (RxBufAddr),
-		 NETDRV_R16 (RxBufPtr), NETDRV_R8 (ChipCmd));
+	netdev_dbg(dev, "Done netdrv_rx(), current %04x BufAddr %04x, free to %04x, Cmd %02x\n",
+		   cur_rx, NETDRV_R16(RxBufAddr),
+		   NETDRV_R16(RxBufPtr), NETDRV_R8(ChipCmd));
 
 	tp->cur_rx = cur_rx;
 }
 
 
-static void netdrv_weird_interrupt (struct net_device *dev,
-				     struct netdrv_private *tp,
-				     void *ioaddr,
-				     int status, int link_changed)
+static void netdrv_weird_interrupt(struct net_device *dev,
+				   struct netdrv_private *tp,
+				   void *ioaddr,
+				   int status, int link_changed)
 {
-	printk (KERN_DEBUG "%s: Abnormal interrupt, status %8.8x.\n",
-		dev->name, status);
+	netdev_printk(KERN_DEBUG, dev, "Abnormal interrupt, status %08x\n",
+		      status);
 
-	assert (dev != NULL);
-	assert (tp != NULL);
-	assert (ioaddr != NULL);
+	assert(dev != NULL);
+	assert(tp != NULL);
+	assert(ioaddr != NULL);
 
 	/* Update the error count. */
-	dev->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
-	NETDRV_W32 (RxMissed, 0);
+	dev->stats.rx_missed_errors += NETDRV_R32(RxMissed);
+	NETDRV_W32(RxMissed, 0);
 
 	if ((status & RxUnderrun) && link_changed &&
 	    (tp->drv_flags & HAS_LNK_CHNG)) {
 		/* Really link-change on new chips. */
-		int lpar = NETDRV_R16 (NWayLPAR);
+		int lpar = NETDRV_R16(NWayLPAR);
 		int duplex = ((lpar & 0x0100) || (lpar & 0x01C0) == 0x0040 ||
-			      tp->duplex_lock);
+			     tp->duplex_lock);
 		if (tp->full_duplex != duplex) {
 			tp->full_duplex = duplex;
-			NETDRV_W8 (Cfg9346, Cfg9346_Unlock);
-			NETDRV_W8 (Config1, tp->full_duplex ? 0x60 : 0x20);
-			NETDRV_W8 (Cfg9346, Cfg9346_Lock);
+			NETDRV_W8(Cfg9346, Cfg9346_Unlock);
+			NETDRV_W8(Config1, tp->full_duplex ? 0x60 : 0x20);
+			NETDRV_W8(Cfg9346, Cfg9346_Lock);
 		}
 		status &= ~RxUnderrun;
 	}
 
 	/* XXX along with netdrv_rx_err, are we double-counting errors? */
-	if (status &
-	    (RxUnderrun | RxOverflow | RxErr | RxFIFOOver))
+	if (status & (RxUnderrun | RxOverflow | RxErr | RxFIFOOver))
 		dev->stats.rx_errors++;
 
 	if (status & (PCSTimeout))
@@ -1634,22 +1625,21 @@ static void netdrv_weird_interrupt (struct net_device *dev,
 		dev->stats.rx_fifo_errors++;
 	if (status & RxOverflow) {
 		dev->stats.rx_over_errors++;
-		tp->cur_rx = NETDRV_R16 (RxBufAddr) % RX_BUF_LEN;
-		NETDRV_W16_F (RxBufPtr, tp->cur_rx - 16);
+		tp->cur_rx = NETDRV_R16(RxBufAddr) % RX_BUF_LEN;
+		NETDRV_W16_F(RxBufPtr, tp->cur_rx - 16);
 	}
 	if (status & PCIErr) {
 		u16 pci_cmd_status;
-		pci_read_config_word (tp->pci_dev, PCI_STATUS, &pci_cmd_status);
+		pci_read_config_word(tp->pci_dev, PCI_STATUS, &pci_cmd_status);
 
-		printk (KERN_ERR "%s: PCI Bus error %4.4x.\n",
-			dev->name, pci_cmd_status);
+		netdev_err(dev, "PCI Bus error %04x\n", pci_cmd_status);
 	}
 }
 
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
-static irqreturn_t netdrv_interrupt (int irq, void *dev_instance)
+static irqreturn_t netdrv_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct netdrv_private *tp = netdev_priv(dev);
@@ -1658,22 +1648,21 @@ static irqreturn_t netdrv_interrupt (int irq, void *dev_instance)
 	int status = 0, link_changed = 0; /* avoid bogus "uninit" warning */
 	int handled = 0;
 
-	spin_lock (&tp->lock);
+	spin_lock(&tp->lock);
 
 	do {
-		status = NETDRV_R16 (IntrStatus);
+		status = NETDRV_R16(IntrStatus);
 
-		/* h/w no longer present (hotplug?) or major error, bail */
+		/* h/w no longer present(hotplug?) or major error, bail */
 		if (status == 0xFFFF)
 			break;
 
 		handled = 1;
 		/* Acknowledge all of the current interrupt sources ASAP */
-		NETDRV_W16_F (IntrStatus, status);
+		NETDRV_W16_F(IntrStatus, status);
 
-		DPRINTK ("%s: interrupt  status=%#4.4x new intstat=%#4.4x.\n",
-				dev->name, status,
-				NETDRV_R16 (IntrStatus));
+		netdev_dbg(dev, "interrupt  status=%#04x new intstat=%#04x\n",
+			   status, NETDRV_R16(IntrStatus));
 
 		if ((status &
 		     (PCIErr | PCSTimeout | RxUnderrun | RxOverflow |
@@ -1682,69 +1671,67 @@ static irqreturn_t netdrv_interrupt (int irq, void *dev_instance)
 
 		/* Check uncommon events with one test. */
 		if (status & (PCIErr | PCSTimeout | RxUnderrun | RxOverflow |
-		  	      RxFIFOOver | TxErr | RxErr))
-			netdrv_weird_interrupt (dev, tp, ioaddr,
-						 status, link_changed);
+			     RxFIFOOver | TxErr | RxErr))
+			netdrv_weird_interrupt(dev, tp, ioaddr,
+					       status, link_changed);
 
 		if (status & (RxOK | RxUnderrun | RxOverflow | RxFIFOOver))	/* Rx interrupt */
-			netdrv_rx_interrupt (dev, tp, ioaddr);
+			netdrv_rx_interrupt(dev, tp, ioaddr);
 
 		if (status & (TxOK | TxErr))
-			netdrv_tx_interrupt (dev, tp, ioaddr);
+			netdrv_tx_interrupt(dev, tp, ioaddr);
 
 		boguscnt--;
 	} while (boguscnt > 0);
 
 	if (boguscnt <= 0) {
-		printk (KERN_WARNING
-			"%s: Too much work at interrupt, "
-			"IntrStatus=0x%4.4x.\n", dev->name,
-			status);
+		netdev_warn(dev, "Too much work at interrupt, IntrStatus=%#04x\n",
+			    status);
 
 		/* Clear all interrupt sources. */
-		NETDRV_W16 (IntrStatus, 0xffff);
+		NETDRV_W16(IntrStatus, 0xffff);
 	}
 
-	spin_unlock (&tp->lock);
+	spin_unlock(&tp->lock);
 
-	DPRINTK ("%s: exiting interrupt, intr_status=%#4.4x.\n",
-		 dev->name, NETDRV_R16 (IntrStatus));
+	netdev_dbg(dev, "exiting interrupt, intr_status=%#04x\n",
+		   NETDRV_R16(IntrStatus));
 	return IRQ_RETVAL(handled);
 }
 
 
-static int netdrv_close (struct net_device *dev)
+static int netdrv_close(struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
-	netif_stop_queue (dev);
+	netif_stop_queue(dev);
 
-	DPRINTK ("%s: Shutting down ethercard, status was 0x%4.4x.\n",
-			dev->name, NETDRV_R16 (IntrStatus));
+	netdev_dbg(dev, "Shutting down ethercard, status was %#04x\n",
+		   NETDRV_R16(IntrStatus));
 
-	del_timer_sync (&tp->timer);
+	del_timer_sync(&tp->timer);
 
-	spin_lock_irqsave (&tp->lock, flags);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	/* Stop the chip's Tx and Rx DMA processes. */
-	NETDRV_W8 (ChipCmd, (NETDRV_R8 (ChipCmd) & ChipCmdClear));
+	NETDRV_W8(ChipCmd, (NETDRV_R8(ChipCmd) & ChipCmdClear));
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	NETDRV_W16 (IntrMask, 0x0000);
+	NETDRV_W16(IntrMask, 0x0000);
 
 	/* Update the error counts. */
-	dev->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
-	NETDRV_W32 (RxMissed, 0);
+	dev->stats.rx_missed_errors += NETDRV_R32(RxMissed);
+	NETDRV_W32(RxMissed, 0);
 
-	spin_unlock_irqrestore (&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
-	free_irq (dev->irq, dev);
+	free_irq(dev->irq, dev);
 
-	netdrv_tx_clear (dev);
+	netdrv_tx_clear(dev);
 
 	pci_free_consistent(tp->pci_dev, RX_BUF_TOT_LEN,
 			    tp->rx_ring, tp->rx_ring_dma);
@@ -1754,23 +1741,23 @@ static int netdrv_close (struct net_device *dev)
 	tp->tx_bufs = NULL;
 
 	/* Green! Put the chip in low-power mode. */
-	NETDRV_W8 (Cfg9346, Cfg9346_Unlock);
-	NETDRV_W8 (Config1, 0x03);
-	NETDRV_W8 (Cfg9346, Cfg9346_Lock);
+	NETDRV_W8(Cfg9346, Cfg9346_Unlock);
+	NETDRV_W8(Config1, 0x03);
+	NETDRV_W8(Cfg9346, Cfg9346_Lock);
 
-	DPRINTK ("EXIT\n");
+	DPRINTK("EXIT\n");
 	return 0;
 }
 
 
-static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
+static int netdrv_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 	unsigned long flags;
 	int rc = 0;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
 	switch (cmd) {
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
@@ -1778,15 +1765,15 @@ static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 		/* Fall Through */
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
-		spin_lock_irqsave (&tp->lock, flags);
-		data->val_out = mdio_read (dev, data->phy_id & 0x1f, data->reg_num & 0x1f);
-		spin_unlock_irqrestore (&tp->lock, flags);
+		spin_lock_irqsave(&tp->lock, flags);
+		data->val_out = mdio_read(dev, data->phy_id & 0x1f, data->reg_num & 0x1f);
+		spin_unlock_irqrestore(&tp->lock, flags);
 		break;
 
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		spin_lock_irqsave (&tp->lock, flags);
-		mdio_write (dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
-		spin_unlock_irqrestore (&tp->lock, flags);
+		spin_lock_irqsave(&tp->lock, flags);
+		mdio_write(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
+		spin_unlock_irqrestore(&tp->lock, flags);
 		break;
 
 	default:
@@ -1794,14 +1781,14 @@ static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 		break;
 	}
 
-	DPRINTK ("EXIT, returning %d\n", rc);
+	DPRINTK("EXIT, returning %d\n", rc);
 	return rc;
 }
 
 /* Set or clear the multicast filter for this adaptor.
    This routine is not state sensitive and need not be SMP locked. */
 
-static void netdrv_set_rx_mode (struct net_device *dev)
+static void netdrv_set_rx_mode(struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
@@ -1809,16 +1796,16 @@ static void netdrv_set_rx_mode (struct net_device *dev)
 	int i, rx_mode;
 	u32 tmp;
 
-	DPRINTK ("ENTER\n");
+	DPRINTK("ENTER\n");
 
-	DPRINTK ("%s:   netdrv_set_rx_mode(%4.4x) done -- Rx config %8.8x.\n",
-			dev->name, dev->flags, NETDRV_R32 (RxConfig));
+	netdev_dbg(dev, "%s(%04x) done -- Rx config %08lx\n",
+		   __func__, dev->flags, NETDRV_R32(RxConfig));
 
 	/* Note: do not reorder, GCC is clever about common statements. */
 	if (dev->flags & IFF_PROMISC) {
 		rx_mode =
-		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
-		    AcceptAllPhys;
+			AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
+			AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
@@ -1838,66 +1825,66 @@ static void netdrv_set_rx_mode (struct net_device *dev)
 	}
 
 	/* if called from irq handler, lock already acquired */
-	if (!in_irq ())
-		spin_lock_irq (&tp->lock);
+	if (!in_irq())
+		spin_lock_irq(&tp->lock);
 
 	/* We can safely update without stopping the chip. */
 	tmp = netdrv_rx_config | rx_mode |
-		(NETDRV_R32 (RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
-	NETDRV_W32_F (RxConfig, tmp);
-	NETDRV_W32_F (MAR0 + 0, mc_filter[0]);
-	NETDRV_W32_F (MAR0 + 4, mc_filter[1]);
+		(NETDRV_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
+	NETDRV_W32_F(RxConfig, tmp);
+	NETDRV_W32_F(MAR0 + 0, mc_filter[0]);
+	NETDRV_W32_F(MAR0 + 4, mc_filter[1]);
 
-	if (!in_irq ())
-		spin_unlock_irq (&tp->lock);
+	if (!in_irq())
+		spin_unlock_irq(&tp->lock);
 
-	DPRINTK ("EXIT\n");
+	DPRINTK("EXIT\n");
 }
 
 
 #ifdef CONFIG_PM
 
-static int netdrv_suspend (struct pci_dev *pdev, pm_message_t state)
+static int netdrv_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
 	if (!netif_running(dev))
 		return 0;
-	netif_device_detach (dev);
+	netif_device_detach(dev);
 
-	spin_lock_irqsave (&tp->lock, flags);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	/* Disable interrupts, stop Tx and Rx. */
-	NETDRV_W16 (IntrMask, 0x0000);
-	NETDRV_W8 (ChipCmd, (NETDRV_R8 (ChipCmd) & ChipCmdClear));
+	NETDRV_W16(IntrMask, 0x0000);
+	NETDRV_W8(ChipCmd, (NETDRV_R8(ChipCmd) & ChipCmdClear));
 
 	/* Update the error counts. */
-	dev->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
-	NETDRV_W32 (RxMissed, 0);
+	dev->stats.rx_missed_errors += NETDRV_R32(RxMissed);
+	NETDRV_W32(RxMissed, 0);
 
-	spin_unlock_irqrestore (&tp->lock, flags);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
-	pci_save_state (pdev);
-	pci_set_power_state (pdev, PCI_D3hot);
+	pci_save_state(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
 }
 
 
-static int netdrv_resume (struct pci_dev *pdev)
+static int netdrv_resume(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 	/*struct netdrv_private *tp = netdev_priv(dev);*/
 
 	if (!netif_running(dev))
 		return 0;
-	pci_set_power_state (pdev, PCI_D0);
-	pci_restore_state (pdev);
-	netif_device_attach (dev);
-	netdrv_hw_start (dev);
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	netif_device_attach(dev);
+	netdrv_hw_start(dev);
 
 	return 0;
 }
@@ -1917,7 +1904,7 @@ static struct pci_driver netdrv_pci_driver = {
 };
 
 
-static int __init netdrv_init_module (void)
+static int __init netdrv_init_module(void)
 {
 /* when a module, this is printed whether or not devices are found in probe */
 #ifdef MODULE
@@ -1927,9 +1914,9 @@ static int __init netdrv_init_module (void)
 }
 
 
-static void __exit netdrv_cleanup_module (void)
+static void __exit netdrv_cleanup_module(void)
 {
-	pci_unregister_driver (&netdrv_pci_driver);
+	pci_unregister_driver(&netdrv_pci_driver);
 }
 
 
-- 
1.7.0.14.g7e948

