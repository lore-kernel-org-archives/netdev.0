From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] tulip/winbond-840: convert to module_param and get
 rid of warnings
Date: Mon, 18 Oct 2004 15:34:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018153411.15f7568e@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert to module_param and get rid of __iomem warnings.
To handle the __iomem, adds a inline dev_ioaddr(dev)

Signed-off-by: Stephen Hemmminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
--- a/drivers/net/tulip/winbond-840.c	2004-10-18 15:28:04 -07:00
+++ b/drivers/net/tulip/winbond-840.c	2004-10-18 15:28:04 -07:00
@@ -113,6 +113,7 @@
 
 /* Include files, designed to support most kernel versions 2.0.0 and later. */
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -145,12 +146,15 @@
 MODULE_DESCRIPTION("Winbond W89c840 Ethernet driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(debug, "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(multicast_filter_limit, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
+module_param(max_interrupt_work, int, 0);
+module_param(debug, int, 0);
+module_param(rx_copybreak, int, 0);
+module_param(multicast_filter_limit, int, 0);
+
+static int num_params;
+module_param_array(options, int, num_params, 0);
+module_param_array(full_duplex, int, num_params, 0);
+
 MODULE_PARM_DESC(max_interrupt_work, "winbond-840 maximum events handled per interrupt");
 MODULE_PARM_DESC(debug, "winbond-840 debug level (0-6)");
 MODULE_PARM_DESC(rx_copybreak, "winbond-840 copy breakpoint for copy-only-tiny-frames");
@@ -363,7 +367,7 @@
 	struct mii_if_info mii_if;
 };
 
-static int  eeprom_read(long ioaddr, int location);
+static int  eeprom_read(void __iomem *ioaddr, int location);
 static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  netdev_open(struct net_device *dev);
@@ -397,7 +401,7 @@
 	int chip_idx = ent->driver_data;
 	int irq;
 	int i, option = find_cnt < MAX_UNITS ? options[find_cnt] : 0;
-	long ioaddr;
+	void __iomem *ioaddr;
 
 	i = pci_enable_device(pdev);
 	if (i) return i;
@@ -421,10 +425,10 @@
 		goto err_out_netdev;
 
 #ifdef USE_IO_OPS
-	ioaddr = pci_resource_start(pdev, 0);
+	ioaddr = (void __iomem *) pci_resource_start(pdev, 0);
 #else
-	ioaddr = pci_resource_start(pdev, 1);
-	ioaddr = (long) ioremap (ioaddr, pci_id_tbl[chip_idx].io_size);
+	ioaddr = ioremap (pci_resource_start(pdev, 1), 
+			  pci_id_tbl[chip_idx].io_size);
 	if (!ioaddr)
 		goto err_out_free_res;
 #endif
@@ -436,10 +440,10 @@
 	   No hold time required! */
 	writel(0x00000001, ioaddr + PCIBusCfg);
 
-	dev->base_addr = ioaddr;
+	dev->base_addr = (unsigned long) ioaddr;
 	dev->irq = irq;
 
-	np = dev->priv;
+	np = netdev_priv(dev);
 	np->pci_dev = pdev;
 	np->chip_id = chip_idx;
 	np->drv_flags = pci_id_tbl[chip_idx].drv_flags;
@@ -482,7 +486,7 @@
 	if (i)
 		goto err_out_cleardev;
 
-	printk(KERN_INFO "%s: %s at 0x%lx, ",
+	printk(KERN_INFO "%s: %s at 0x%p, ",
 		   dev->name, pci_id_tbl[chip_idx].name, ioaddr);
 	for (i = 0; i < 5; i++)
 			printk("%2.2x:", dev->dev_addr[i]);
@@ -549,11 +553,11 @@
 	EE_WriteCmd=(5 << 6), EE_ReadCmd=(6 << 6), EE_EraseCmd=(7 << 6),
 };
 
-static int eeprom_read(long addr, int location)
+static int eeprom_read(void __iomem *addr, int location)
 {
 	int i;
 	int retval = 0;
-	long ee_addr = addr + EECtrl;
+	void __iomem *ee_addr = addr + EECtrl;
 	int read_cmd = location | EE_ReadCmd;
 	writel(EE_ChipSelect, ee_addr);
 
@@ -600,7 +604,7 @@
 
 /* Generate the preamble required for initial synchronization and
    a few older transceivers. */
-static void mdio_sync(long mdio_addr)
+static void mdio_sync(void __iomem *mdio_addr)
 {
 	int bits = 32;
 
@@ -613,9 +617,14 @@
 	}
 }
 
+static inline void __iomem *dev_ioaddr(struct net_device *dev)
+{
+	return (void __iomem *) dev->base_addr;
+}
+
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	long mdio_addr = dev->base_addr + MIICtrl;
+	void __iomem * mdio_addr = dev_ioaddr(dev) + MIICtrl;
 	int mii_cmd = (0xf6 << 10) | (phy_id << 5) | location;
 	int i, retval = 0;
 
@@ -644,8 +653,8 @@
 
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value)
 {
-	struct netdev_private *np = dev->priv;
-	long mdio_addr = dev->base_addr + MIICtrl;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *mdio_addr = dev_ioaddr(dev) + MIICtrl;
 	int mii_cmd = (0x5002 << 16) | (phy_id << 23) | (location<<18) | value;
 	int i;
 
@@ -677,8 +686,8 @@
 
 static int netdev_open(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	int i;
 
 	writel(0x00000001, ioaddr + PCIBusCfg);		/* Reset */
@@ -720,7 +729,7 @@
 
 static int update_link(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int duplex, fasteth, result, mii_reg;
 
 	/* BSMR */
@@ -783,8 +792,8 @@
 #define RXTX_TIMEOUT	2000
 static inline void update_csr6(struct net_device *dev, int new)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	int limit = RXTX_TIMEOUT;
 
 	if (!netif_device_present(dev))
@@ -824,8 +833,8 @@
 static void netdev_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = dev_ioaddr(dev);
 
 	if (debug > 2)
 		printk(KERN_DEBUG "%s: Media selection timer tick, status %8.8x "
@@ -841,7 +850,7 @@
 
 static void init_rxtx_rings(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	np->rx_head_desc = &np->rx_ring[0];
@@ -881,10 +890,9 @@
 	np->tx_full = 0;
 	np->tx_q_bytes = np->dirty_tx = np->cur_tx = 0;
 
-	writel(np->ring_dma_addr, dev->base_addr + RxRingPtr);
+	writel(np->ring_dma_addr, dev_ioaddr(dev) + RxRingPtr);
 	writel(np->ring_dma_addr+sizeof(struct w840_rx_desc)*RX_RING_SIZE,
-		dev->base_addr + TxRingPtr);
-
+	       dev_ioaddr(dev) + TxRingPtr);
 }
 
 static void free_rxtx_rings(struct netdev_private* np)
@@ -916,8 +924,8 @@
 
 static void init_registers(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	int i;
 
 	for (i = 0; i < 6; i++)
@@ -974,8 +982,8 @@
 
 static void tx_timeout(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = dev_ioaddr(dev);
 
 	printk(KERN_WARNING "%s: Transmit timed out, status %8.8x,"
 		   " resetting...\n", dev->name, (int)readl(ioaddr + IntrStatus));
@@ -1002,7 +1010,7 @@
 	 * everything.
 	 */
 
-	writel(1, dev->base_addr+PCIBusCfg);
+	writel(1, dev_ioaddr(dev) + PCIBusCfg);
 	udelay(1);
 
 	free_rxtx_rings(np);
@@ -1020,7 +1028,7 @@
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static int alloc_ringdesc(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
 
@@ -1045,7 +1053,7 @@
 
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	unsigned entry;
 
 	/* Caution: the write order is important here, set the field
@@ -1086,7 +1094,7 @@
 	wmb(); /* flush length, buffer1, buffer2 */
 	np->tx_ring[entry].status = DescOwn;
 	wmb(); /* flush status and kick the hardware */
-	writel(0, dev->base_addr + TxStartDemand);
+	writel(0, dev_ioaddr(dev) + TxStartDemand);
 	np->tx_q_bytes += skb->len;
 	/* Work around horrible bug in the chip by marking the queue as full
 	   when we do not have FIFO room for a maximum sized packet. */
@@ -1109,7 +1117,7 @@
 
 static void netdev_tx_done(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 		int entry = np->dirty_tx % TX_RING_SIZE;
 		int tx_status = np->tx_ring[entry].status;
@@ -1162,8 +1170,8 @@
 static irqreturn_t intr_handler(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = (struct net_device *)dev_instance;
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	int work_limit = max_interrupt_work;
 	int handled = 0;
 
@@ -1226,7 +1234,7 @@
    for clarity and better register allocation. */
 static int netdev_rx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int entry = np->cur_rx % RX_RING_SIZE;
 	int work_limit = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 
@@ -1342,8 +1350,8 @@
 
 static void netdev_error(struct net_device *dev, int intr_status)
 {
-	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	void __iomem *ioaddr = dev_ioaddr(dev);
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (debug > 2)
 		printk(KERN_DEBUG "%s: Abnormal event, %8.8x.\n",
@@ -1386,8 +1394,8 @@
 
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	void __iomem *ioaddr = dev_ioaddr(dev);
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The chip only need report frame silently dropped. */
 	spin_lock_irq(&np->lock);
@@ -1401,7 +1409,7 @@
 
 static u32 __set_rx_mode(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = dev_ioaddr(dev);
 	u32 mc_filter[2];			/* Multicast hash filter */
 	u32 rx_mode;
 
@@ -1435,7 +1443,7 @@
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 rx_mode = __set_rx_mode(dev);
 	spin_lock_irq(&np->lock);
 	update_csr6(dev, (np->csr6 & ~0x00F8) | rx_mode);
@@ -1444,7 +1452,7 @@
 
 static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	strcpy (info->driver, DRV_NAME);
 	strcpy (info->version, DRV_VERSION);
@@ -1453,7 +1461,7 @@
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1465,7 +1473,7 @@
 
 static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1477,13 +1485,13 @@
 
 static int netdev_nway_reset(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	return mii_nway_restart(&np->mii_if);
 }
 
 static u32 netdev_get_link(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	return mii_link_ok(&np->mii_if);
 }
 
@@ -1516,7 +1524,7 @@
 
 	switch(cmd) {
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
-		data->phy_id = ((struct netdev_private *)dev->priv)->phys[0] & 0x1f;
+		data->phy_id = ((struct netdev_private *)netdev_priv(dev))->phys[0] & 0x1f;
 		/* Fall Through */
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
@@ -1539,8 +1547,8 @@
 
 static int netdev_close(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	void __iomem *ioaddr = dev_ioaddr(dev);
+	struct netdev_private *np = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1602,7 +1610,7 @@
 		unregister_netdev(dev);
 		pci_release_regions(pdev);
 #ifndef USE_IO_OPS
-		iounmap((char *)(dev->base_addr));
+		iounmap(dev_ioaddr(dev));
 #endif
 		free_netdev(dev);
 	}
@@ -1638,8 +1646,8 @@
 static int w840_suspend (struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdev_private *np = dev->priv;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = dev_ioaddr(dev);
 
 	rtnl_lock();
 	if (netif_running (dev)) {
@@ -1675,7 +1683,7 @@
 static int w840_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	rtnl_lock();
 	if (netif_device_present(dev))
@@ -1685,8 +1693,8 @@
 	/*	pci_power_on(pdev); */
 
 		spin_lock_irq(&np->lock);
-		writel(1, dev->base_addr+PCIBusCfg);
-		readl(dev->base_addr+PCIBusCfg);
+		writel(1, dev_ioaddr(dev) + PCIBusCfg);
+		readl(dev_ioaddr(dev) + PCIBusCfg);
 		udelay(1);
 		netif_device_attach(dev);
 		init_rxtx_rings(dev);
