From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [RFT] yellowfin: get rid of __iomem warnings
Date: Mon, 18 Oct 2004 12:19:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018121953.77d87e8f@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch converts driver to use module_param and gets rid of warnings 
because now we type check for io memory.
Patch against the 2.6.9 version in jeff's netdev tree.
Compiled, but not tested.  Could someone with this board make sure it doesn't
break everything?

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
--- a/drivers/net/yellowfin.c	2004-10-18 12:18:27 -07:00
+++ b/drivers/net/yellowfin.c	2004-10-18 12:18:27 -07:00
@@ -53,13 +53,6 @@
 
 #define PFX DRV_NAME ": "
 
-/* The user-configurable values.
-   These may be modified when a driver module is loaded.*/
-
-static int debug = 1;			/* 1 normal messages, 0 quiet .. 7 verbose. */
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static int max_interrupt_work = 20;
-static int mtu;
 #ifdef YF_PROTOTYPE			/* Support for prototype hardware errata. */
 /* System-wide count of bogus-rx frames. */
 static int bogus_rx;
@@ -73,9 +66,6 @@
 static int fifo_cfg = 0x0020;				/* Bypass external Tx FIFO. */
 #endif
 
-/* Set the copy breakpoint for the copy-only-tiny-frames scheme.
-   Setting to > 1514 effectively disables this feature. */
-static int rx_copybreak;
 
 /* Used to pass the media type, etc.
    No media types are currently defined.  These exist for driver
@@ -109,6 +99,7 @@
 #define yellowfin_debug debug
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -154,13 +145,26 @@
 MODULE_DESCRIPTION("Packet Engines Yellowfin G-NIC Gigabit Ethernet driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(mtu, "i");
-MODULE_PARM(debug, "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(gx_fix, "i");
+/* The user-configurable values.
+   These may be modified when a driver module is loaded.*/
+static int debug = 1;			/* 1 normal messages, 0 quiet .. 7 verbose. */
+/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
+static int max_interrupt_work = 20;
+static int mtu;
+/* Set the copy breakpoint for the copy-only-tiny-frames scheme.
+   Setting to > 1514 effectively disables this feature. */
+static int rx_copybreak;
+
+module_param(max_interrupt_work, int, 0);
+module_param(mtu, int, 0);
+module_param(debug, int, 0);
+module_param(rx_copybreak, int, 0);
+module_param(gx_fix, int, 0);
+
+static int num_units;
+module_param_array(options, int, num_units, 0);
+module_param_array(full_duplex, int, num_units, 0);
+
 MODULE_PARM_DESC(max_interrupt_work, "G-NIC maximum events handled per interrupt");
 MODULE_PARM_DESC(mtu, "G-NIC MTU (all boards)");
 MODULE_PARM_DESC(debug, "G-NIC debug level (0-7)");
@@ -391,9 +395,9 @@
 	spinlock_t lock;
 };
 
-static int read_eeprom(long ioaddr, int location);
-static int mdio_read(long ioaddr, int phy_id, int location);
-static void mdio_write(long ioaddr, int phy_id, int location, int value);
+static int read_eeprom(void __iomem *ioaddr, int location);
+static int mdio_read(void __iomem *ioaddr, int phy_id, int location);
+static void mdio_write(void __iomem *ioaddr, int phy_id, int location, int value);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int yellowfin_open(struct net_device *dev);
 static void yellowfin_timer(unsigned long data);
@@ -417,7 +421,7 @@
 	int irq;
 	int chip_idx = ent->driver_data;
 	static int find_cnt;
-	long ioaddr, real_ioaddr;
+	void __iomem *ioaddr;
 	int i, option = find_cnt < MAX_UNITS ? options[find_cnt] : 0;
 	int drv_flags = pci_id_tbl[chip_idx].drv_flags;
         void *ring_space;
@@ -449,10 +453,9 @@
 	pci_set_master (pdev);
 
 #ifdef USE_IO_OPS
-	real_ioaddr = ioaddr = pci_resource_start (pdev, 0);
+	ioaddr = (void __iomem *) pci_resource_start (pdev, 0);
 #else
-	real_ioaddr = ioaddr = pci_resource_start (pdev, 1);
-	ioaddr = (long) ioremap(ioaddr, YELLOWFIN_SIZE);
+	ioaddr = ioremap(pci_resource_start (pdev, 1), YELLOWFIN_SIZE);
 	if (!ioaddr)
 		goto err_out_free_res;
 #endif
@@ -470,7 +473,7 @@
 	/* Reset the chip. */
 	outl(0x80000000, ioaddr + DMACtrl);
 
-	dev->base_addr = ioaddr;
+	dev->base_addr = (unsigned long) ioaddr;
 	dev->irq = irq;
 
 	pci_set_drvdata(pdev, dev);
@@ -533,7 +536,7 @@
 	if (i)
 		goto err_out_unmap_status;
 
-	printk(KERN_INFO "%s: %s type %8x at 0x%lx, ",
+	printk(KERN_INFO "%s: %s type %8x at 0x%p, ",
 		   dev->name, pci_id_tbl[chip_idx].name, inl(ioaddr + ChipRev), ioaddr);
 	for (i = 0; i < 5; i++)
 			printk("%2.2x:", dev->dev_addr[i]);
@@ -577,7 +580,7 @@
 	return -ENODEV;
 }
 
-static int __devinit read_eeprom(long ioaddr, int location)
+static int read_eeprom(void __iomem *ioaddr, int location)
 {
 	int bogus_cnt = 10000;		/* Typical 33Mhz: 1050 ticks */
 
@@ -592,7 +595,7 @@
    These routines assume the MDIO controller is idle, and do not exit until
    the command is finished. */
 
-static int mdio_read(long ioaddr, int phy_id, int location)
+static int mdio_read(void __iomem *ioaddr, int phy_id, int location)
 {
 	int i;
 
@@ -604,7 +607,7 @@
 	return inw(ioaddr + MII_Rd_Data);
 }
 
-static void mdio_write(long ioaddr, int phy_id, int location, int value)
+static void mdio_write(void __iomem *ioaddr, int phy_id, int location, int value)
 {
 	int i;
 
@@ -619,10 +622,15 @@
 }
 
 
+static inline void __iomem *dev_ioaddr(struct net_device *dev)
+{
+	return (void __iomem *) dev->base_addr;
+}
+
 static int yellowfin_open(struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	int i;
 
 	/* Reset the chip. */
@@ -704,7 +712,7 @@
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct yellowfin_private *yp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	int next_tick = 60*HZ;
 
 	if (yellowfin_debug > 3) {
@@ -738,7 +746,7 @@
 static void yellowfin_tx_timeout(struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = dev_ioaddr(dev);
 
 	printk(KERN_WARNING "%s: Yellowfin transmit timed out at %d/%d Tx "
 		   "status %4.4x, Rx status %4.4x, resetting...\n",
@@ -763,7 +771,7 @@
 	dev->if_port = 0;
 
 	/* Wake the potentially-idle transmit channel. */
-	outl(0x10001000, dev->base_addr + TxCtrl);
+	outl(0x10001000, dev_ioaddr(dev) + TxCtrl);
 	if (yp->cur_tx - yp->dirty_tx < TX_QUEUE_SIZE)
 		netif_wake_queue (dev);		/* Typical path */
 
@@ -922,7 +930,7 @@
 	/* Non-x86 Todo: explicitly flush cache lines here. */
 
 	/* Wake the potentially-idle transmit channel. */
-	outl(0x10001000, dev->base_addr + TxCtrl);
+	outl(0x10001000, dev_ioaddr(dev) + TxCtrl);
 
 	if (yp->cur_tx - yp->dirty_tx < TX_QUEUE_SIZE)
 		netif_start_queue (dev);		/* Typical path */
@@ -943,7 +951,7 @@
 {
 	struct net_device *dev = dev_instance;
 	struct yellowfin_private *yp;
-	long ioaddr;
+	void __iomem *ioaddr;
 	int boguscnt = max_interrupt_work;
 	unsigned int handled = 0;
 
@@ -954,8 +962,8 @@
 	}
 #endif
 
-	ioaddr = dev->base_addr;
 	yp = netdev_priv(dev);
+	ioaddr = dev_ioaddr(dev);
 	
 	spin_lock (&yp->lock);
 
@@ -1254,7 +1262,7 @@
 
 static int yellowfin_close(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	struct yellowfin_private *yp = netdev_priv(dev);
 	int i;
 
@@ -1351,7 +1359,7 @@
 static void set_rx_mode(struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	u16 cfg_value = inw(ioaddr + Cnfg);
 
 	/* Stop the Rx process to change any value. */
@@ -1411,7 +1419,7 @@
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct yellowfin_private *np = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 
 	switch(cmd) {
@@ -1465,7 +1473,7 @@
 	pci_release_regions (pdev);
 
 #ifndef USE_IO_OPS
-	iounmap ((void *) dev->base_addr);
+	iounmap (dev_ioaddr(dev));
 #endif
 
 	free_netdev (dev);
