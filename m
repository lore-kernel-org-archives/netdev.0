From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH] 8139too: use iomap for pio/mmio
Date: Sun, 31 Oct 2004 15:07:55 +0200
Message-ID: <1099228076.9571.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch converts the 8139too driver to use the iomap infrastructure for
PIO and MMIO instead of playing macro tricks.  The patch also adds __iomem
annotations for the driver.   Compiles and passes sparse checks but not tested
with actual hardware.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---

 8139too.c |  124 ++++++++++++++++++++++++++------------------------------------
 1 files changed, 52 insertions(+), 72 deletions(-)

Index: 2.6.10-rc1-mm1/drivers/net/8139too.c
===================================================================
--- 2.6.10-rc1-mm1.orig/drivers/net/8139too.c	2004-10-30 13:29:58.000000000 +0300
+++ 2.6.10-rc1-mm1/drivers/net/8139too.c	2004-10-31 14:42:19.874089928 +0200
@@ -570,7 +570,7 @@
 };
 
 struct rtl8139_private {
-	void *mmio_addr;
+	void __iomem *mmio_addr;
 	int drv_flags;
 	struct pci_dev *pci_dev;
 	u32 msg_enable;
@@ -614,7 +614,7 @@
 MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
 
-static int read_eeprom (void *ioaddr, int location, int addr_len);
+static int read_eeprom (void __iomem *ioaddr, int location, int addr_len);
 static int rtl8139_open (struct net_device *dev);
 static int mdio_read (struct net_device *dev, int phy_id, int location);
 static void mdio_write (struct net_device *dev, int phy_id, int location,
@@ -638,46 +638,20 @@
 static void rtl8139_hw_start (struct net_device *dev);
 static struct ethtool_ops rtl8139_ethtool_ops;
 
-#ifdef USE_IO_OPS
-
-#define RTL_R8(reg)		inb (((unsigned long)ioaddr) + (reg))
-#define RTL_R16(reg)		inw (((unsigned long)ioaddr) + (reg))
-#define RTL_R32(reg)		((unsigned long) inl (((unsigned long)ioaddr) + (reg)))
-#define RTL_W8(reg, val8)	outb ((val8), ((unsigned long)ioaddr) + (reg))
-#define RTL_W16(reg, val16)	outw ((val16), ((unsigned long)ioaddr) + (reg))
-#define RTL_W32(reg, val32)	outl ((val32), ((unsigned long)ioaddr) + (reg))
-#define RTL_W8_F		RTL_W8
-#define RTL_W16_F		RTL_W16
-#define RTL_W32_F		RTL_W32
-#undef readb
-#undef readw
-#undef readl
-#undef writeb
-#undef writew
-#undef writel
-#define readb(addr) inb((unsigned long)(addr))
-#define readw(addr) inw((unsigned long)(addr))
-#define readl(addr) inl((unsigned long)(addr))
-#define writeb(val,addr) outb((val),(unsigned long)(addr))
-#define writew(val,addr) outw((val),(unsigned long)(addr))
-#define writel(val,addr) outl((val),(unsigned long)(addr))
-
-#else
-
 /* write MMIO register, with flush */
 /* Flush avoids rtl8139 bug w/ posted MMIO writes */
-#define RTL_W8_F(reg, val8)	do { writeb ((val8), ioaddr + (reg)); readb (ioaddr + (reg)); } while (0)
-#define RTL_W16_F(reg, val16)	do { writew ((val16), ioaddr + (reg)); readw (ioaddr + (reg)); } while (0)
-#define RTL_W32_F(reg, val32)	do { writel ((val32), ioaddr + (reg)); readl (ioaddr + (reg)); } while (0)
+#define RTL_W8_F(reg, val8)	do { iowrite8 ((val8), ioaddr + (reg)); ioread8 (ioaddr + (reg)); } while (0)
+#define RTL_W16_F(reg, val16)	do { iowrite16 ((val16), ioaddr + (reg)); ioread16 (ioaddr + (reg)); } while (0)
+#define RTL_W32_F(reg, val32)	do { iowrite32 ((val32), ioaddr + (reg)); ioread32 (ioaddr + (reg)); } while (0)
 
 
 #define MMIO_FLUSH_AUDIT_COMPLETE 1
 #if MMIO_FLUSH_AUDIT_COMPLETE
 
 /* write MMIO register */
-#define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
-#define RTL_W16(reg, val16)	writew ((val16), ioaddr + (reg))
-#define RTL_W32(reg, val32)	writel ((val32), ioaddr + (reg))
+#define RTL_W8(reg, val8)	iowrite8 ((val8), ioaddr + (reg))
+#define RTL_W16(reg, val16)	iowrite16 ((val16), ioaddr + (reg))
+#define RTL_W32(reg, val32)	iowrite32 ((val32), ioaddr + (reg))
 
 #else
 
@@ -689,11 +663,9 @@
 #endif /* MMIO_FLUSH_AUDIT_COMPLETE */
 
 /* read MMIO register */
-#define RTL_R8(reg)		readb (ioaddr + (reg))
-#define RTL_R16(reg)		readw (ioaddr + (reg))
-#define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
-
-#endif /* USE_IO_OPS */
+#define RTL_R8(reg)		ioread8 (ioaddr + (reg))
+#define RTL_R16(reg)		ioread16 (ioaddr + (reg))
+#define RTL_R32(reg)		((unsigned long) ioread32 (ioaddr + (reg)))
 
 
 static const u16 rtl8139_intr_mask =
@@ -740,10 +712,13 @@
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
-#ifndef USE_IO_OPS
+#ifdef USE_IO_OPS
+	if (tp->mmio_addr)
+		ioport_unmap (tp->mmio_addr);
+#else
 	if (tp->mmio_addr)
-		iounmap (tp->mmio_addr);
-#endif /* !USE_IO_OPS */
+		pci_iounmap (pdev, tp->mmio_addr);
+#endif /* USE_IO_OPS */
 
 	/* it's ok to call this even if we have no regions to free */
 	pci_release_regions (pdev);
@@ -754,7 +729,7 @@
 }
 
 
-static void rtl8139_chip_reset (void *ioaddr)
+static void rtl8139_chip_reset (void __iomem *ioaddr)
 {
 	int i;
 
@@ -774,7 +749,7 @@
 static int __devinit rtl8139_init_board (struct pci_dev *pdev,
 					 struct net_device **dev_out)
 {
-	void *ioaddr;
+	void __iomem *ioaddr;
 	struct net_device *dev;
 	struct rtl8139_private *tp;
 	u8 tmp8;
@@ -855,13 +830,18 @@
 	pci_set_master (pdev);
 
 #ifdef USE_IO_OPS
-	ioaddr = (void *) pio_start;
+	ioaddr = ioport_map(pio_start, pio_len);
+	if (!ioaddr) {
+		printk (KERN_ERR PFX "%s: cannot map PIO, aborting\n", pci_name(pdev));
+		rc = -EIO;
+		goto err_out;
+	}
 	dev->base_addr = pio_start;
 	tp->mmio_addr = ioaddr;
 	tp->regs_len = pio_len;
 #else
 	/* ioremap MMIO region */
-	ioaddr = ioremap (mmio_start, mmio_len);
+	ioaddr = pci_iomap(dev, mmio_start, mmio_len);
 	if (ioaddr == NULL) {
 		printk (KERN_ERR PFX "%s: cannot remap MMIO, aborting\n", pci_name(pdev));
 		rc = -EIO;
@@ -945,7 +925,7 @@
 	struct net_device *dev = NULL;
 	struct rtl8139_private *tp;
 	int i, addr_len, option;
-	void *ioaddr;
+	void __iomem *ioaddr;
 	static int board_idx = -1;
 	u8 pci_rev;
 
@@ -1150,11 +1130,11 @@
 #define EE_READ_CMD		(6)
 #define EE_ERASE_CMD	(7)
 
-static int __devinit read_eeprom (void *ioaddr, int location, int addr_len)
+static int __devinit read_eeprom (void __iomem *ioaddr, int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
-	void *ee_addr = ioaddr + Cfg9346;
+	void __iomem *ee_addr = ioaddr + Cfg9346;
 	int read_cmd = location | (EE_READ_CMD << addr_len);
 
 	writeb (EE_ENB & ~EE_CS, ee_addr);
@@ -1219,7 +1199,7 @@
 
 #ifdef CONFIG_8139TOO_8129
 /* Syncronize the MII management interface by shifting 32 one bits out. */
-static void mdio_sync (void *mdio_addr)
+static void mdio_sync (void __iomem *mdio_addr)
 {
 	int i;
 
@@ -1237,7 +1217,7 @@
 	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval = 0;
 #ifdef CONFIG_8139TOO_8129
-	void *mdio_addr = tp->mmio_addr + Config4;
+	void __iomem *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0xf6 << 10) | (phy_id << 5) | location;
 	int i;
 #endif
@@ -1278,13 +1258,13 @@
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 #ifdef CONFIG_8139TOO_8129
-	void *mdio_addr = tp->mmio_addr + Config4;
+	void __iomem *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
 	int i;
 #endif
 
 	if (phy_id > 31) {	/* Really a 8139.  Use internal registers. */
-		void *ioaddr = tp->mmio_addr;
+		void __iomem *ioaddr = tp->mmio_addr;
 		if (location == 0) {
 			RTL_W8 (Cfg9346, Cfg9346_Unlock);
 			RTL_W16 (BasicModeCtrl, value);
@@ -1321,7 +1301,7 @@
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval;
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 
 	retval = request_irq (dev->irq, rtl8139_interrupt, SA_SHIRQ, dev->name, dev);
 	if (retval)
@@ -1378,7 +1358,7 @@
 static void rtl8139_hw_start (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 i;
 	u8 tmp;
 
@@ -1480,7 +1460,7 @@
 				  struct rtl8139_private *tp)
 {
 	int linkcase;
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 
 	/* This is a complicated state machine to configure the "twister" for
 	   impedance/echos based on the cable length.
@@ -1564,7 +1544,7 @@
 
 static inline void rtl8139_thread_iter (struct net_device *dev,
 				 struct rtl8139_private *tp,
-				 void *ioaddr)
+				 void __iomem *ioaddr)
 {
 	int mii_lpa;
 
@@ -1672,7 +1652,7 @@
 static void rtl8139_tx_timeout (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 	u8 tmp8;
 	unsigned long flags;
@@ -1717,7 +1697,7 @@
 static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int entry;
 	unsigned int len = skb->len;
 
@@ -1759,7 +1739,7 @@
 
 static void rtl8139_tx_interrupt (struct net_device *dev,
 				  struct rtl8139_private *tp,
-				  void *ioaddr)
+				  void __iomem *ioaddr)
 {
 	unsigned long dirty_tx, tx_left;
 
@@ -1829,7 +1809,7 @@
 
 /* TODO: clean this up!  Rx reset need not be this intensive */
 static void rtl8139_rx_err (u32 rx_status, struct net_device *dev,
-			    struct rtl8139_private *tp, void *ioaddr)
+			    struct rtl8139_private *tp, void __iomem *ioaddr)
 {
 	u8 tmp8;
 #ifdef CONFIG_8139_OLD_RX_RESET
@@ -1926,7 +1906,7 @@
 
 static void rtl8139_isr_ack(struct rtl8139_private *tp)
 {
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	u16 status;
 
 	status = RTL_R16 (IntrStatus) & RxAckBits;
@@ -1945,7 +1925,7 @@
 static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		      int budget)
 {
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	int received = 0;
 	unsigned char *rx_ring = tp->rx_ring;
 	unsigned int cur_rx = tp->cur_rx;
@@ -2083,7 +2063,7 @@
 
 static void rtl8139_weird_interrupt (struct net_device *dev,
 				     struct rtl8139_private *tp,
-				     void *ioaddr,
+				     void __iomem *ioaddr,
 				     int status, int link_changed)
 {
 	DPRINTK ("%s: Abnormal interrupt, status %8.8x.\n",
@@ -2123,7 +2103,7 @@
 static int rtl8139_poll(struct net_device *dev, int *budget)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	int orig_budget = min(*budget, dev->quota);
 	int done = 1;
 
@@ -2161,7 +2141,7 @@
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	u16 status, ackstat;
 	int link_changed = 0; /* avoid bogus "uninit" warning */
 	int handled = 0;
@@ -2237,7 +2217,7 @@
 static int rtl8139_close (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	int ret = 0;
 	unsigned long flags;
 
@@ -2300,7 +2280,7 @@
 static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8139_private *np = netdev_priv(dev);
-	void *ioaddr = np->mmio_addr;
+	void __iomem *ioaddr = np->mmio_addr;
 
 	spin_lock_irq(&np->lock);
 	if (rtl_chip_info[np->chipset].flags & HasLWake) {
@@ -2334,7 +2314,7 @@
 static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8139_private *np = netdev_priv(dev);
-	void *ioaddr = np->mmio_addr;
+	void __iomem *ioaddr = np->mmio_addr;
 	u32 support;
 	u8 cfg3, cfg5;
 
@@ -2502,7 +2482,7 @@
 static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
 	if (netif_running(dev)) {
@@ -2521,7 +2501,7 @@
 static void __set_rx_mode (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int i, rx_mode;
 	u32 tmp;
@@ -2582,7 +2562,7 @@
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct rtl8139_private *tp = netdev_priv(dev);
-	void *ioaddr = tp->mmio_addr;
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
 	pci_save_state (pdev);
