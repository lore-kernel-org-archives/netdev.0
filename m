From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Tue, 18 Jan 2005 03:15:33 -0500
Message-ID: <41ECC5A5.90708@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060509060202040405080405"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060509060202040405080405
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

iomem annotations from viro, tun/tap fixes, multicast fixes.

--------------060509060202040405080405
Content-Type: text/plain;
 name="net-drivers-2.6.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net-drivers-2.6.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/Kconfig             |    1 
 drivers/net/atp.c               |    2 
 drivers/net/bmac.c              |   68 +++++++++---------
 drivers/net/hamachi.c           |   81 +++++++++++-----------
 drivers/net/myri_sbus.c         |   10 +-
 drivers/net/s2io.c              |  104 ++++++++++++++--------------
 drivers/net/s2io.h              |   15 +---
 drivers/net/tulip/tulip_core.c  |    2 
 drivers/net/tulip/winbond-840.c |    2 
 drivers/net/tun.c               |  145 ++++++++++++++++++++++++++++++++++------
 include/linux/if_tun.h          |    2 
 11 files changed, 271 insertions(+), 161 deletions(-)

through these ChangeSets:

Alexander Viro:
  o s2io iomem annotations and cleanups
  o bmac iomem annotations
  o hamachi iomem annotations
  o miri_sbus iomem annotations

Maksim Krasnyanskiy:
  o [TUN] Add a missing dependency on enabling the crc32 libraries
  o Use random_ether_addr() to generate TAP MAC address
  o TUN/TAP driver packet queuing fixes and improvements

Roger Luethi:
  o mc_filter on big-endian arch

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/Kconfig	2005-01-18 03:13:47 -05:00
@@ -84,6 +84,7 @@
 config TUN
 	tristate "Universal TUN/TAP device driver support"
 	depends on NETDEVICES
+	select CRC32
 	---help---
 	  TUN/TAP provides packet reception and transmission for user space
 	  programs.  It can be viewed as a simple Point-to-Point or Ethernet
diff -Nru a/drivers/net/atp.c b/drivers/net/atp.c
--- a/drivers/net/atp.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/atp.c	2005-01-18 03:13:47 -05:00
@@ -909,7 +909,7 @@
 			 i++, mclist = mclist->next)
 		{
 			int filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
-			mc_filter[filterbit >> 5] |= cpu_to_le32(1 << (filterbit & 31));
+			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 		}
 		new_mode = CMR2h_Normal;
 	}
diff -Nru a/drivers/net/bmac.c b/drivers/net/bmac.c
--- a/drivers/net/bmac.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/bmac.c	2005-01-18 03:13:47 -05:00
@@ -59,9 +59,9 @@
 struct bmac_data {
 	/* volatile struct bmac *bmac; */
 	struct sk_buff_head *queue;
-	volatile struct dbdma_regs *tx_dma;
+	volatile struct dbdma_regs __iomem *tx_dma;
 	int tx_dma_intr;
-	volatile struct dbdma_regs *rx_dma;
+	volatile struct dbdma_regs __iomem *rx_dma;
 	int rx_dma_intr;
 	volatile struct dbdma_cmd *tx_cmds;	/* xmit dma command list */
 	volatile struct dbdma_cmd *rx_cmds;	/* recv dma command list */
@@ -165,35 +165,35 @@
 #define	DBDMA_CLEAR(x)	( (x) << 16)
 
 static inline void
-dbdma_st32(volatile unsigned long *a, unsigned long x)
+dbdma_st32(volatile __u32 __iomem *a, unsigned long x)
 {
 	__asm__ volatile( "stwbrx %0,0,%1" : : "r" (x), "r" (a) : "memory");
 	return;
 }
 
 static inline unsigned long
-dbdma_ld32(volatile unsigned long *a)
+dbdma_ld32(volatile __u32 __iomem *a)
 {
-	unsigned long swap;
+	__u32 swap;
 	__asm__ volatile ("lwbrx %0,0,%1" :  "=r" (swap) : "r" (a));
 	return swap;
 }
 
 static void
-dbdma_continue(volatile struct dbdma_regs *dmap)
+dbdma_continue(volatile struct dbdma_regs __iomem *dmap)
 {
-	dbdma_st32((volatile unsigned long *)&dmap->control,
+	dbdma_st32(&dmap->control,
 		   DBDMA_SET(RUN|WAKE) | DBDMA_CLEAR(PAUSE|DEAD));
 	eieio();
 }
 
 static void
-dbdma_reset(volatile struct dbdma_regs *dmap)
+dbdma_reset(volatile struct dbdma_regs __iomem *dmap)
 {
-	dbdma_st32((volatile unsigned long *)&dmap->control,
+	dbdma_st32(&dmap->control,
 		   DBDMA_CLEAR(ACTIVE|DEAD|WAKE|FLUSH|PAUSE|RUN));
 	eieio();
-	while (dbdma_ld32((volatile unsigned long *)&dmap->status) & RUN)
+	while (dbdma_ld32(&dmap->status) & RUN)
 		eieio();
 }
 
@@ -213,22 +213,22 @@
 static inline
 void bmwrite(struct net_device *dev, unsigned long reg_offset, unsigned data )
 {
-	out_le16((void *)dev->base_addr + reg_offset, data);
+	out_le16((void __iomem *)dev->base_addr + reg_offset, data);
 }
 
 
 static inline
 volatile unsigned short bmread(struct net_device *dev, unsigned long reg_offset )
 {
-	return in_le16((void *)dev->base_addr + reg_offset);
+	return in_le16((void __iomem *)dev->base_addr + reg_offset);
 }
 
 static void
 bmac_enable_and_reset_chip(struct net_device *dev)
 {
 	struct bmac_data *bp = netdev_priv(dev);
-	volatile struct dbdma_regs *rd = bp->rx_dma;
-	volatile struct dbdma_regs *td = bp->tx_dma;
+	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
+	volatile struct dbdma_regs __iomem *td = bp->tx_dma;
 
 	if (rd)
 		dbdma_reset(rd);
@@ -406,7 +406,7 @@
 bmac_start_chip(struct net_device *dev)
 {
 	struct bmac_data *bp = netdev_priv(dev);
-	volatile struct dbdma_regs *rd = bp->rx_dma;
+	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
 	unsigned short	oldConfig;
 
 	/* enable rx dma channel */
@@ -476,8 +476,8 @@
 	bp->sleeping = 1;
 	spin_unlock_irqrestore(&bp->lock, flags);
 	if (bp->opened) {
-		volatile struct dbdma_regs *rd = bp->rx_dma;
-		volatile struct dbdma_regs *td = bp->tx_dma;
+		volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
+		volatile struct dbdma_regs __iomem *td = bp->tx_dma;
 			
 		config = bmread(dev, RXCFG);
 		bmwrite(dev, RXCFG, (config & ~RxMACEnable));
@@ -602,7 +602,7 @@
 static void
 bmac_init_tx_ring(struct bmac_data *bp)
 {
-	volatile struct dbdma_regs *td = bp->tx_dma;
+	volatile struct dbdma_regs __iomem *td = bp->tx_dma;
 
 	memset((char *)bp->tx_cmds, 0, (N_TX_RING+1) * sizeof(struct dbdma_cmd));
 
@@ -623,7 +623,7 @@
 static int
 bmac_init_rx_ring(struct bmac_data *bp)
 {
-	volatile struct dbdma_regs *rd = bp->rx_dma;
+	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
 	int i;
 	struct sk_buff *skb;
 
@@ -657,7 +657,7 @@
 static int bmac_transmit_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bmac_data *bp = netdev_priv(dev);
-	volatile struct dbdma_regs *td = bp->tx_dma;
+	volatile struct dbdma_regs __iomem *td = bp->tx_dma;
 	int i;
 
 	/* see if there's a free slot in the tx ring */
@@ -693,7 +693,7 @@
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct bmac_data *bp = netdev_priv(dev);
-	volatile struct dbdma_regs *rd = bp->rx_dma;
+	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
 	volatile struct dbdma_cmd *cp;
 	int i, nb, stat;
 	struct sk_buff *skb;
@@ -1331,13 +1331,11 @@
 		goto err_out_iounmap;
 
 	bp->is_bmac_plus = is_bmac_plus;
-	bp->tx_dma = (volatile struct dbdma_regs *)
-		ioremap(macio_resource_start(mdev, 1), macio_resource_len(mdev, 1));
+	bp->tx_dma = ioremap(macio_resource_start(mdev, 1), macio_resource_len(mdev, 1));
 	if (!bp->tx_dma)
 		goto err_out_iounmap;
 	bp->tx_dma_intr = macio_irq(mdev, 1);
-	bp->rx_dma = (volatile struct dbdma_regs *)
-		ioremap(macio_resource_start(mdev, 2), macio_resource_len(mdev, 2));
+	bp->rx_dma = ioremap(macio_resource_start(mdev, 2), macio_resource_len(mdev, 2));
 	if (!bp->rx_dma)
 		goto err_out_iounmap_tx;
 	bp->rx_dma_intr = macio_irq(mdev, 2);
@@ -1392,11 +1390,11 @@
 err_out_irq0:
 	free_irq(dev->irq, dev);
 err_out_iounmap_rx:
-	iounmap((void *)bp->rx_dma);
+	iounmap(bp->rx_dma);
 err_out_iounmap_tx:
-	iounmap((void *)bp->tx_dma);
+	iounmap(bp->tx_dma);
 err_out_iounmap:
-	iounmap((void *)dev->base_addr);
+	iounmap((void __iomem *)dev->base_addr);
 out_release:
 	macio_release_resources(mdev);
 out_free:
@@ -1421,8 +1419,8 @@
 static int bmac_close(struct net_device *dev)
 {
 	struct bmac_data *bp = netdev_priv(dev);
-	volatile struct dbdma_regs *rd = bp->rx_dma;
-	volatile struct dbdma_regs *td = bp->tx_dma;
+	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
+	volatile struct dbdma_regs __iomem *td = bp->tx_dma;
 	unsigned short config;
 	int i;
 
@@ -1505,8 +1503,8 @@
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct bmac_data *bp = netdev_priv(dev);
-	volatile struct dbdma_regs *td = bp->tx_dma;
-	volatile struct dbdma_regs *rd = bp->rx_dma;
+	volatile struct dbdma_regs __iomem *td = bp->tx_dma;
+	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
 	volatile struct dbdma_cmd *cp;
 	unsigned long flags;
 	unsigned short config, oldConfig;
@@ -1638,9 +1636,9 @@
 	free_irq(bp->tx_dma_intr, dev);	
 	free_irq(bp->rx_dma_intr, dev);
 
-	iounmap((void *)dev->base_addr);
-	iounmap((void *)bp->tx_dma);
-	iounmap((void *)bp->rx_dma);
+	iounmap((void __iomem *)dev->base_addr);
+	iounmap(bp->tx_dma);
+	iounmap(bp->rx_dma);
 
 	macio_release_resources(mdev);
 
diff -Nru a/drivers/net/hamachi.c b/drivers/net/hamachi.c
--- a/drivers/net/hamachi.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/hamachi.c	2005-01-18 03:13:47 -05:00
@@ -512,6 +512,7 @@
 	u32 rx_int_var, tx_int_var;	/* interrupt control variables */
 	u32 option;							/* Hold on to a copy of the options */
 	struct pci_dev *pci_dev;
+	void __iomem *base;
 };
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>, Eric Kasten <kasten@nscl.msu.edu>, Keith Underwood <keithu@parl.clemson.edu>");
@@ -549,7 +550,7 @@
 MODULE_PARM_DESC(full_duplex, "GNIC-II full duplex setting(s) (1)");
 MODULE_PARM_DESC(force32, "GNIC-II: Bit 0: 32 bit PCI, bit 1: disable parity, bit 2: 64 bit PCI (all boards)");
                                                                         
-static int read_eeprom(long ioaddr, int location);
+static int read_eeprom(void __iomem *ioaddr, int location);
 static int mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int hamachi_open(struct net_device *dev);
@@ -575,7 +576,8 @@
 	int option, i, rx_int_var, tx_int_var, boguscnt;
 	int chip_id = ent->driver_data;
 	int irq;
-	long ioaddr;
+	void __iomem *ioaddr;
+	unsigned long base;
 	static int card_idx;
 	struct net_device *dev;
 	void *ring_space;
@@ -594,9 +596,9 @@
 		goto err_out;
 	}
 
-	ioaddr = pci_resource_start(pdev, 0);
+	base = pci_resource_start(pdev, 0);
 #ifdef __alpha__				/* Really "64 bit addrs" */
-	ioaddr |= (pci_resource_start(pdev, 1) << 32);
+	base |= (pci_resource_start(pdev, 1) << 32);
 #endif
 
 	pci_set_master(pdev);
@@ -605,7 +607,7 @@
 	if (i) return i;
 
 	irq = pdev->irq;
-	ioaddr = (long) ioremap(ioaddr, 0x400);
+	ioaddr = ioremap(base, 0x400);
 	if (!ioaddr)
 		goto err_out_release;
 
@@ -678,7 +680,8 @@
 		i = readb(ioaddr + PCIClkMeas);	
 	}
 
-	dev->base_addr = ioaddr;
+	hmp->base = ioaddr;
+	dev->base_addr = (unsigned long)ioaddr;
 	dev->irq = irq;
 	pci_set_drvdata(pdev, dev);
 
@@ -741,7 +744,7 @@
 		goto err_out_unmap_rx;
 	}
 
-	printk(KERN_INFO "%s: %s type %x at 0x%lx, ",
+	printk(KERN_INFO "%s: %s type %x at %p, ",
 		   dev->name, chip_tbl[chip_id].name, readl(ioaddr + ChipRev),
 		   ioaddr);
 	for (i = 0; i < 5; i++)
@@ -790,14 +793,14 @@
 err_out_cleardev:
 	free_netdev (dev);
 err_out_iounmap:
-	iounmap((char *)ioaddr);
+	iounmap(ioaddr);
 err_out_release:
 	pci_release_regions(pdev);
 err_out:
 	return ret;
 }
 
-static int __devinit read_eeprom(long ioaddr, int location)
+static int __devinit read_eeprom(void __iomem *ioaddr, int location)
 {
 	int bogus_cnt = 1000;
 
@@ -819,7 +822,8 @@
 
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	long ioaddr = dev->base_addr;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->base;
 	int i;
 
 	/* We should check busy first - per docs -KDU */
@@ -836,7 +840,8 @@
 
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value)
 {
-	long ioaddr = dev->base_addr;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->base;
 	int i;
 
 	/* We should check busy first - per docs -KDU */
@@ -857,7 +862,7 @@
 static int hamachi_open(struct net_device *dev)
 {
 	struct hamachi_private *hmp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = hmp->base;
 	int i;
 	u32 rx_int_var, tx_int_var;
 	u16 fifo_info;
@@ -987,7 +992,7 @@
 	writew(0x001D, ioaddr + RxDMACtrl);
 	writew(0x001D, ioaddr + TxDMACtrl);
 #endif
-	writew(0x0001, dev->base_addr + RxCmd);
+	writew(0x0001, ioaddr + RxCmd);
 
 	if (hamachi_debug > 2) {
 		printk(KERN_DEBUG "%s: Done hamachi_open(), status: Rx %x Tx %x.\n",
@@ -1038,7 +1043,7 @@
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct hamachi_private *hmp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = hmp->base;
 	int next_tick = 10*HZ;
 
 	if (hamachi_debug > 2) {
@@ -1063,7 +1068,7 @@
 {
 	int i;
 	struct hamachi_private *hmp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = hmp->base;
 
 	printk(KERN_WARNING "%s: Hamachi transmit timed out, status %8.8x,"
 		   " resetting...\n", dev->name, (int)readw(ioaddr + TxStatus));
@@ -1115,7 +1120,7 @@
 	}
 
 	udelay(60); /* Sleep 60 us just for safety sake */
-	writew(0x0002, dev->base_addr + RxCmd); /* STOP Rx */
+	writew(0x0002, ioaddr + RxCmd); /* STOP Rx */
 		
 	writeb(0x01, ioaddr + ChipReset);  /* Reinit the hardware */ 
 
@@ -1157,9 +1162,9 @@
 	hmp->stats.tx_errors++;
 
 	/* Restart the chip's Tx/Rx processes . */
-	writew(0x0002, dev->base_addr + TxCmd); /* STOP Tx */
-	writew(0x0001, dev->base_addr + TxCmd); /* START Tx */
-	writew(0x0001, dev->base_addr + RxCmd); /* START Rx */
+	writew(0x0002, ioaddr + TxCmd); /* STOP Tx */
+	writew(0x0001, ioaddr + TxCmd); /* START Tx */
+	writew(0x0001, ioaddr + RxCmd); /* START Rx */
 
 	netif_wake_queue(dev);
 }
@@ -1275,9 +1280,9 @@
 
 		/* Wake the potentially-idle transmit channel. */
 		/* If we don't need to read status, DON'T -KDU */
-		status=readw(dev->base_addr + TxStatus);
+		status=readw(hmp->base + TxStatus);
 		if( !(status & 0x0001) || (status & 0x0002))
-			writew(0x0001, dev->base_addr + TxCmd);
+			writew(0x0001, hmp->base + TxCmd);
 		return 1;
 	} 
 
@@ -1343,9 +1348,9 @@
 
 	/* Wake the potentially-idle transmit channel. */
 	/* If we don't need to read status, DON'T -KDU */
-	status=readw(dev->base_addr + TxStatus);
+	status=readw(hmp->base + TxStatus);
 	if( !(status & 0x0001) || (status & 0x0002))
-		writew(0x0001, dev->base_addr + TxCmd);
+		writew(0x0001, hmp->base + TxCmd);
 
 	/* Immediately before returning, let's clear as many entries as we can. */
 	hamachi_tx(dev);
@@ -1376,8 +1381,9 @@
 static irqreturn_t hamachi_interrupt(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = dev_instance;
-	struct hamachi_private *hmp;
-	long ioaddr, boguscnt = max_interrupt_work;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->base;
+	long boguscnt = max_interrupt_work;
 	int handled = 0;
 
 #ifndef final_version			/* Can never occur. */
@@ -1387,8 +1393,6 @@
 	}
 #endif
 
-	ioaddr = dev->base_addr;
-	hmp = netdev_priv(dev);
 	spin_lock(&hmp->lock);
 
 	do {
@@ -1687,8 +1691,8 @@
 
 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	if (readw(dev->base_addr + RxStatus) & 0x0002)
-		writew(0x0001, dev->base_addr + RxCmd);
+	if (readw(hmp->base + RxStatus) & 0x0002)
+		writew(0x0001, hmp->base + RxCmd);
 
 	return 0;
 }
@@ -1697,8 +1701,8 @@
    than just errors. */
 static void hamachi_error(struct net_device *dev, int intr_status)
 {
-	long ioaddr = dev->base_addr;
 	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->base;
 
 	if (intr_status & (LinkChange|NegotiationChange)) {
 		if (hamachi_debug > 1)
@@ -1731,8 +1735,8 @@
 
 static int hamachi_close(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->base;
 	struct sk_buff *skb;
 	int i;
 
@@ -1817,8 +1821,8 @@
 
 static struct net_device_stats *hamachi_get_stats(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->base;
 
 	/* We should lock this segment of code for SMP eventually, although
 	   the vulnerability window is very small and statistics are
@@ -1845,7 +1849,8 @@
 
 static void set_rx_mode(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->base;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		/* Unconditionally log net taps. */
@@ -1950,11 +1955,11 @@
 		 */
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		writel(d[0], dev->base_addr + TxIntrCtrl);
-		writel(d[1], dev->base_addr + RxIntrCtrl);
+		writel(d[0], np->base + TxIntrCtrl);
+		writel(d[1], np->base + RxIntrCtrl);
 		printk(KERN_NOTICE "%s: tx %08x, rx %08x intr\n", dev->name,
-		  (u32) readl(dev->base_addr + TxIntrCtrl),
-		  (u32) readl(dev->base_addr + RxIntrCtrl));
+		  (u32) readl(np->base + TxIntrCtrl),
+		  (u32) readl(np->base + RxIntrCtrl));
 		rc = 0;
 	}
 
@@ -1980,7 +1985,7 @@
 		pci_free_consistent(pdev, TX_TOTAL_SIZE, hmp->tx_ring, 
 			hmp->tx_ring_dma);
 		unregister_netdev(dev);
-		iounmap((char *)dev->base_addr);
+		iounmap(hmp->base);
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
--- a/drivers/net/myri_sbus.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/myri_sbus.c	2005-01-18 03:13:47 -05:00
@@ -118,7 +118,7 @@
 
 static inline void bang_the_chip(struct myri_eth *mp)
 {
-	struct myri_shmem *shmem	= mp->shmem;
+	struct myri_shmem __iomem *shmem = mp->shmem;
 	void __iomem *cregs		= mp->cregs;
 
 	sbus_writel(1, &shmem->send);
@@ -127,9 +127,9 @@
 
 static int myri_do_handshake(struct myri_eth *mp)
 {
-	struct myri_shmem *shmem	= mp->shmem;
+	struct myri_shmem __iomem *shmem = mp->shmem;
 	void __iomem *cregs = mp->cregs;
-	struct myri_channel *chan	= &shmem->channel;
+	struct myri_channel __iomem *chan = &shmem->channel;
 	int tick 			= 0;
 
 	DET(("myri_do_handshake: "));
@@ -427,7 +427,7 @@
 		u32 csum		= sbus_readl(&rxdack->csum);
 		int len			= sbus_readl(&rxdack->myri_scatters[0].len);
 		int index		= sbus_readl(&rxdack->ctx);
-		struct myri_rxd __iomem *rxd	= &rq->myri_rxd[rq->tail];
+		struct myri_rxd __iomem *rxd = &rq->myri_rxd[sbus_readl(&rq->tail)];
 		struct sk_buff *skb	= mp->rx_skbs[index];
 
 		/* Ack it. */
@@ -546,7 +546,7 @@
 	struct net_device *dev		= (struct net_device *) dev_id;
 	struct myri_eth *mp		= (struct myri_eth *) dev->priv;
 	void __iomem *lregs		= mp->lregs;
-	struct myri_channel *chan	= &mp->shmem->channel;
+	struct myri_channel __iomem *chan = &mp->shmem->channel;
 	unsigned long flags;
 	u32 status;
 	int handled = 0;
diff -Nru a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/s2io.c	2005-01-18 03:13:47 -05:00
@@ -277,7 +277,7 @@
 	int lst_size, lst_per_page;
 	struct net_device *dev = nic->dev;
 #ifdef CONFIG_2BUFF_MODE
-	u64 tmp;
+	unsigned long tmp;
 	buffAdd_t *ba;
 #endif
 
@@ -448,22 +448,22 @@
 			while (k != MAX_RXDS_PER_BLOCK) {
 				ba = &nic->ba[i][j][k];
 
-				ba->ba_0_org = (void *) kmalloc
+				ba->ba_0_org = kmalloc
 				    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
 				if (!ba->ba_0_org)
 					return -ENOMEM;
-				tmp = (u64) ba->ba_0_org;
+				tmp = (unsigned long) ba->ba_0_org;
 				tmp += ALIGN_SIZE;
-				tmp &= ~((u64) ALIGN_SIZE);
+				tmp &= ~((unsigned long) ALIGN_SIZE);
 				ba->ba_0 = (void *) tmp;
 
-				ba->ba_1_org = (void *) kmalloc
+				ba->ba_1_org = kmalloc
 				    (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
 				if (!ba->ba_1_org)
 					return -ENOMEM;
-				tmp = (u64) ba->ba_1_org;
+				tmp = (unsigned long) ba->ba_1_org;
 				tmp += ALIGN_SIZE;
-				tmp &= ~((u64) ALIGN_SIZE);
+				tmp &= ~((unsigned long) ALIGN_SIZE);
 				ba->ba_1 = (void *) tmp;
 				k++;
 			}
@@ -610,10 +610,10 @@
 
 static int init_nic(struct s2io_nic *nic)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	struct net_device *dev = nic->dev;
 	register u64 val64 = 0;
-	void *add;
+	void __iomem *add;
 	u32 time;
 	int i, j;
 	mac_info_t *mac_control;
@@ -702,7 +702,7 @@
 	schedule_timeout(HZ / 2);
 
 	/*  Enable Receiving broadcasts */
-	add = (void *) &bar0->mac_cfg;
+	add = &bar0->mac_cfg;
 	val64 = readq(&bar0->mac_cfg);
 	val64 |= MAC_RMAC_BCAST_ENABLE;
 	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
@@ -1003,7 +1003,7 @@
 	writeq(0xffbbffbbffbbffbbULL, &bar0->mc_pause_thresh_q4q7);
 
 	/* Disable RMAC PAD STRIPPING */
-	add = (void *) &bar0->mac_cfg;
+	add = &bar0->mac_cfg;
 	val64 = readq(&bar0->mac_cfg);
 	val64 &= ~(MAC_CFG_RMAC_STRIP_PAD);
 	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
@@ -1069,7 +1069,7 @@
 
 static void en_dis_able_nic_intrs(struct s2io_nic *nic, u16 mask, int flag)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0, temp64 = 0;
 
 	/*  Top level interrupt classification */
@@ -1354,7 +1354,7 @@
 
 void fix_mac_address(nic_t * sp)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
 	int i = 0;
 
@@ -1379,7 +1379,7 @@
 
 static int start_nic(struct s2io_nic *nic)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	struct net_device *dev = nic->dev;
 	register u64 val64 = 0;
 	u16 interruptible, i;
@@ -1474,7 +1474,7 @@
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
 		val64 = 0x0411040400000000ULL;
-		writeq(val64, (void *) ((u8 *) bar0 + 0x2700));
+		writeq(val64, (void __iomem *) bar0 + 0x2700);
 	}
 
 	/* 
@@ -1557,7 +1557,7 @@
 
 static void stop_nic(struct s2io_nic *nic)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0;
 	u16 interruptible, i;
 	mac_info_t *mac_control;
@@ -1615,7 +1615,7 @@
 #ifdef CONFIG_2BUFF_MODE
 	RxD_t *rxdpnext;
 	int nextblk;
-	u64 tmp;
+	unsigned long tmp;
 	buffAdd_t *ba;
 	dma_addr_t rxdpphys;
 #endif
@@ -1757,7 +1757,7 @@
 #else
 		ba = &nic->ba[ring_no][block_no][off];
 		skb_reserve(skb, BUF0_LEN);
-		tmp = (u64) skb->data;
+		tmp = (unsigned long) skb->data;
 		tmp += ALIGN_SIZE;
 		tmp &= ~ALIGN_SIZE;
 		skb->data = (void *) tmp;
@@ -1900,7 +1900,7 @@
 static int s2io_poll(struct net_device *dev, int *budget)
 {
 	nic_t *nic = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	int pkts_to_process = *budget, pkt_cnt = 0;
 	register u64 val64 = 0;
 	rx_curr_get_info_t get_info, put_info;
@@ -2269,7 +2269,7 @@
 
 static void tx_intr_handler(struct s2io_nic *nic)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	struct net_device *dev = (struct net_device *) nic->dev;
 	tx_curr_get_info_t get_info, put_info;
 	struct sk_buff *skb;
@@ -2376,7 +2376,7 @@
 static void alarm_intr_handler(struct s2io_nic *nic)
 {
 	struct net_device *dev = (struct net_device *) nic->dev;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0, err_reg = 0;
 
 	/* Handling link status change error Intr */
@@ -2427,7 +2427,7 @@
 
 int wait_for_cmd_complete(nic_t * sp)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	int ret = FAILURE, cnt = 0;
 	u64 val64;
 
@@ -2458,7 +2458,7 @@
 
 void s2io_reset(nic_t * sp)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
 	u16 subid;
 
@@ -2494,7 +2494,7 @@
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
 		val64 = 0x0411040400000000ULL;
-		writeq(val64, (void *) ((u8 *) bar0 + 0x2700));
+		writeq(val64, (void __iomem *) bar0 + 0x2700);
 	}
 
 	sp->device_enabled_once = FALSE;
@@ -2513,7 +2513,7 @@
 int s2io_set_swapper(nic_t * sp)
 {
 	struct net_device *dev = sp->dev;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
 
 	/* 
@@ -2689,14 +2689,14 @@
 	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
 	register u64 val64;
 	TxD_t *txdp;
-	TxFIFO_element_t *tx_fifo;
+	TxFIFO_element_t __iomem *tx_fifo;
 	unsigned long flags;
 #ifdef NETIF_F_TSO
 	int mss;
 #endif
 	mac_info_t *mac_control;
 	struct config_param *config;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -2813,7 +2813,7 @@
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 #ifndef CONFIG_S2IO_NAPI
 	int i, ret;
 #endif
@@ -2939,11 +2939,11 @@
 	int i, j, prev_cnt;
 	struct dev_mc_list *mclist;
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64 = 0, multi_mac = 0x010203040506ULL, mask =
 	    0xfeffffffffffULL;
 	u64 dis_addr = 0xffffffffffffULL, mac_addr = 0;
-	void *add;
+	void __iomem *add;
 
 	if ((dev->flags & IFF_ALLMULTI) && (!sp->m_cast_flg)) {
 		/*  Enable all Multicast addresses */
@@ -2977,7 +2977,7 @@
 
 	if ((dev->flags & IFF_PROMISC) && (!sp->promisc_flg)) {
 		/*  Put the NIC into promiscuous mode */
-		add = (void *) &bar0->mac_cfg;
+		add = &bar0->mac_cfg;
 		val64 = readq(&bar0->mac_cfg);
 		val64 |= MAC_CFG_RMAC_PROM_ENABLE;
 
@@ -2992,7 +2992,7 @@
 			  dev->name);
 	} else if (!(dev->flags & IFF_PROMISC) && (sp->promisc_flg)) {
 		/*  Remove the NIC from promiscuous mode */
-		add = (void *) &bar0->mac_cfg;
+		add = &bar0->mac_cfg;
 		val64 = readq(&bar0->mac_cfg);
 		val64 &= ~MAC_CFG_RMAC_PROM_ENABLE;
 
@@ -3082,7 +3082,7 @@
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr)
 {
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	register u64 val64, mac_addr = 0;
 	int i;
 
@@ -3225,7 +3225,7 @@
 	regs->version = sp->pdev->subsystem_device;
 
 	for (i = 0; i < regs->len; i += 8) {
-		reg = readq((void *) (sp->bar0 + i));
+		reg = readq(sp->bar0 + i);
 		memcpy((reg_space + i), &reg, 8);
 	}
 }
@@ -3242,7 +3242,7 @@
 static void s2io_phy_id(unsigned long data)
 {
 	nic_t *sp = (nic_t *) data;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64 = 0;
 	u16 subid;
 
@@ -3279,7 +3279,7 @@
 {
 	u64 val64 = 0, last_gpio_ctrl_val;
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u16 subid;
 
 	subid = sp->pdev->subsystem_device;
@@ -3327,7 +3327,7 @@
 {
 	u64 val64;
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 
 	val64 = readq(&bar0->rmac_pause_cfg);
 	if (val64 & RMAC_PAUSE_GEN_ENABLE)
@@ -3354,7 +3354,7 @@
 {
 	u64 val64;
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 
 	val64 = readq(&bar0->rmac_pause_cfg);
 	if (ep->tx_pause)
@@ -3391,7 +3391,7 @@
 	int ret = -1;
 	u32 exit_cnt = 0;
 	u64 val64;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 
 	val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |
 	    I2C_CONTROL_BYTE_CNT(0x3) | I2C_CONTROL_READ |
@@ -3432,7 +3432,7 @@
 {
 	int exit_cnt = 0, ret = -1;
 	u64 val64;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 
 	val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |
 	    I2C_CONTROL_BYTE_CNT(cnt) | I2C_CONTROL_SET_DATA(data) |
@@ -3555,7 +3555,7 @@
 
 static int s2io_register_test(nic_t * sp, uint64_t * data)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64 = 0;
 	int fail = 0;
 
@@ -3726,7 +3726,7 @@
 
 static int s2io_link_test(nic_t * sp, uint64_t * data)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
 
 	val64 = readq(&bar0->adapter_status);
@@ -3751,7 +3751,7 @@
 
 static int s2io_rldram_test(nic_t * sp, uint64_t * data)
 {
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
 	int cnt, iteration = 0, test_pass = 0;
 
@@ -4092,7 +4092,7 @@
 int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	register u64 val64;
 
 	if (netif_running(dev)) {
@@ -4169,7 +4169,7 @@
 {
 	nic_t *nic = (nic_t *) data;
 	struct net_device *dev = nic->dev;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	register u64 val64;
 	u16 subid;
 
@@ -4233,7 +4233,7 @@
 static void s2io_card_down(nic_t * sp)
 {
 	int cnt = 0;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	unsigned long flags;
 	register u64 val64 = 0;
 
@@ -4611,7 +4611,7 @@
 	int dma_flag = FALSE;
 	u32 mac_up, mac_down;
 	u64 val64 = 0, tmp64 = 0;
-	XENA_dev_config_t *bar0 = NULL;
+	XENA_dev_config_t __iomem *bar0 = NULL;
 	u16 subid;
 	mac_info_t *mac_control;
 	struct config_param *config;
@@ -4741,7 +4741,7 @@
 		goto mem_alloc_failed;
 	}
 
-	sp->bar0 = (caddr_t) ioremap(pci_resource_start(pdev, 0),
+	sp->bar0 = ioremap(pci_resource_start(pdev, 0),
 				     pci_resource_len(pdev, 0));
 	if (!sp->bar0) {
 		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem1\n",
@@ -4750,7 +4750,7 @@
 		goto bar0_remap_failed;
 	}
 
-	sp->bar1 = (caddr_t) ioremap(pci_resource_start(pdev, 2),
+	sp->bar1 = ioremap(pci_resource_start(pdev, 2),
 				     pci_resource_len(pdev, 2));
 	if (!sp->bar1) {
 		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem2\n",
@@ -4764,7 +4764,7 @@
 
 	/* Initializing the BAR1 address as the start of the FIFO pointer. */
 	for (j = 0; j < MAX_TX_FIFOS; j++) {
-		mac_control->tx_FIFO_start[j] = (TxFIFO_element_t *)
+		mac_control->tx_FIFO_start[j] = (TxFIFO_element_t __iomem *)
 		    (sp->bar1 + (j * 0x00020000));
 	}
 
@@ -4829,7 +4829,7 @@
 	 * MAC address initialization.
 	 * For now only one mac address will be read and used.
 	 */
-	bar0 = (XENA_dev_config_t *) sp->bar0;
+	bar0 = sp->bar0;
 	val64 = RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
@@ -4886,7 +4886,7 @@
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
 		val64 = 0x0411040400000000ULL;
-		writeq(val64, (u64 *) ((u8 *) bar0 + 0x2700));
+		writeq(val64, (void __iomem *) bar0 + 0x2700);
 		val64 = readq(&bar0->gpio_control);
 	}
 
diff -Nru a/drivers/net/s2io.h b/drivers/net/s2io.h
--- a/drivers/net/s2io.h	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/s2io.h	2005-01-18 03:13:47 -05:00
@@ -583,7 +583,7 @@
 
 /* tx side stuff */
 	/* logical pointer of start of each Tx FIFO */
-	TxFIFO_element_t *tx_FIFO_start[MAX_TX_FIFOS];
+	TxFIFO_element_t __iomem *tx_FIFO_start[MAX_TX_FIFOS];
 
 /* Current offset within tx_FIFO_start, where driver would write new Tx frame*/
 	tx_curr_put_info_t tx_curr_put_info[MAX_TX_FIFOS];
@@ -623,8 +623,8 @@
 	macaddr_t pre_mac_addr[MAX_MAC_SUPPORTED];
 
 	struct net_device_stats stats;
-	caddr_t bar0;
-	caddr_t bar1;
+	void __iomem *bar0;
+	void __iomem *bar1;
 	struct config_param config;
 	mac_info_t mac_control;
 	int high_dma_flag;
@@ -736,10 +736,9 @@
 
 /*  OS related system calls */
 #ifndef readq
-static inline u64 readq(void *addr)
+static inline u64 readq(void __iomem *addr)
 {
-	u64 ret = 0;
-	ret = readl(addr + 4);
+	u64 ret = readl(addr + 4);
 	ret <<= 32;
 	ret |= readl(addr);
 
@@ -748,7 +747,7 @@
 #endif
 
 #ifndef writeq
-static inline void writeq(u64 val, void *addr)
+static inline void writeq(u64 val, void __iomem *addr)
 {
 	writel((u32) (val), addr);
 	writel((u32) (val >> 32), (addr + 4));
@@ -762,7 +761,7 @@
  */
 #define UF	1
 #define LF	2
-static inline void SPECIAL_REG_WRITE(u64 val, void *addr, int order)
+static inline void SPECIAL_REG_WRITE(u64 val, void __iomem *addr, int order)
 {
 	if (order == LF) {
 		writel((u32) (val), addr);
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/tulip/tulip_core.c	2005-01-18 03:13:47 -05:00
@@ -1051,7 +1051,7 @@
 				else
 					filterbit = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 				filterbit &= 0x3f;
-				mc_filter[filterbit >> 5] |= cpu_to_le32(1 << (filterbit & 31));
+				mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 				if (tulip_debug > 2) {
 					printk(KERN_INFO "%s: Added filter for %2.2x:%2.2x:%2.2x:"
 						   "%2.2x:%2.2x:%2.2x  %8.8x bit %d.\n", dev->name,
diff -Nru a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
--- a/drivers/net/tulip/winbond-840.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/tulip/winbond-840.c	2005-01-18 03:13:47 -05:00
@@ -1410,7 +1410,7 @@
 			 i++, mclist = mclist->next) {
 			int filterbit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
 			filterbit &= 0x3f;
-			mc_filter[filterbit >> 5] |= cpu_to_le32(1 << (filterbit & 31));
+			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 		}
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	}
diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	2005-01-18 03:13:47 -05:00
+++ b/drivers/net/tun.c	2005-01-18 03:13:47 -05:00
@@ -16,11 +16,25 @@
  */
 
 /*
+ *  Changes:
+ *
+ *  Mark Smith <markzzzsmith@yahoo.com.au>
+ *   Use random_ether_addr() for tap MAC address.
+ *
+ *  Harald Roelle <harald.roelle@ifi.lmu.de>  2004/04/20
+ *    Fixes in packet dropping, queue length setting and queue wakeup.
+ *    Increased default tx queue length.
+ *    Added ethtool API.
+ *    Minor cleanups
+ *
  *  Daniel Podlejski <underley@underley.eu.org>
  *    Modifications for 2.3.99-pre5 kernel.
  */
 
-#define TUN_VER "1.5"
+#define DRV_NAME	"tun"
+#define DRV_VERSION	"1.6"
+#define DRV_DESCRIPTION	"Universal TUN/TAP device driver"
+#define DRV_COPYRIGHT	"(C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>"
 
 #include <linux/config.h>
 #include <linux/module.h>
@@ -31,11 +45,11 @@
 #include <linux/poll.h>
 #include <linux/fcntl.h>
 #include <linux/init.h>
-#include <linux/random.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/miscdevice.h>
+#include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include <linux/if.h>
 #include <linux/if_arp.h>
@@ -53,6 +67,7 @@
 /* Network device part of the driver */
 
 static LIST_HEAD(tun_dev_list);
+static struct ethtool_ops tun_ethtool_ops;
 
 /* Net device open. */
 static int tun_net_open(struct net_device *dev)
@@ -79,18 +94,24 @@
 	if (!tun->attached)
 		goto drop;
 
-	/* Queue packet */
-	if (!(tun->flags & TUN_ONE_QUEUE)) {
-		/* Normal queueing mode.
-		 * Packet scheduler handles dropping. */
-		if (skb_queue_len(&tun->readq) >= TUN_READQ_SIZE)
+	/* Packet dropping */
+	if (skb_queue_len(&tun->readq) >= dev->tx_queue_len) {
+		if (!(tun->flags & TUN_ONE_QUEUE)) {
+			/* Normal queueing mode. */
+			/* Packet scheduler handles dropping of further packets. */
 			netif_stop_queue(dev);
-	} else {
-		/* Single queue mode.
-		 * Driver handles dropping itself. */
-		if (skb_queue_len(&tun->readq) >= dev->tx_queue_len)
+
+			/* We won't see all dropped packets individually, so overrun
+			 * error is more appropriate. */
+			tun->stats.tx_fifo_errors++;
+		} else {
+			/* Single queue mode.
+			 * Driver handles dropping of all packets itself. */
 			goto drop;
+		}
 	}
+
+	/* Queue packet */
 	skb_queue_tail(&tun->readq, skb);
 
 	/* Notify and wake up reader process */
@@ -164,18 +185,16 @@
 		/* Zero header length */
 		dev->type = ARPHRD_NONE; 
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
-		dev->tx_queue_len = 10;
+		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 
 	case TUN_TAP_DEV:
 		/* Ethernet TAP Device */
 		dev->set_multicast_list = tun_net_mclist;
 
-		/* Generate random Ethernet address.  */
-		*(u16 *)dev->dev_addr = htons(0x00FF);
-		get_random_bytes(dev->dev_addr + sizeof(u16), 4);
-
 		ether_setup(dev);
+		random_ether_addr(dev->dev_addr);
+		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
 }
@@ -354,7 +373,7 @@
 			schedule();
 			continue;
 		}
-		netif_start_queue(tun->dev);
+		netif_wake_queue(tun->dev);
 
 		/** Decide whether to accept this packet. This code is designed to
 		 * behave identically to an Ethernet interface. Accept the packet if
@@ -418,6 +437,7 @@
 	dev->hard_start_xmit = tun_net_xmit;
 	dev->stop = tun_net_close;
 	dev->get_stats = tun_net_stats;
+	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = free_netdev;
 }
 
@@ -736,12 +756,97 @@
 	.devfs_name = "net/tun",
 };
 
+/* ethtool interface */
+
+static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->supported		= 0;
+	cmd->advertising	= 0;
+	cmd->speed		= SPEED_10;
+	cmd->duplex		= DUPLEX_FULL;
+	cmd->port		= PORT_TP;
+	cmd->phy_address	= 0;
+	cmd->transceiver	= XCVR_INTERNAL;
+	cmd->autoneg		= AUTONEG_DISABLE;
+	cmd->maxtxpkt		= 0;
+	cmd->maxrxpkt		= 0;
+	return 0;
+}
+
+static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->fw_version, "N/A");
+
+	switch (tun->flags & TUN_TYPE_MASK) {
+	case TUN_TUN_DEV:
+		strcpy(info->bus_info, "tun");
+		break;
+	case TUN_TAP_DEV:
+		strcpy(info->bus_info, "tap");
+		break;
+	}
+}
+
+static u32 tun_get_msglevel(struct net_device *dev)
+{
+#ifdef TUN_DEBUG
+	struct tun_struct *tun = netdev_priv(dev);
+	return tun->debug;
+#else
+	return -EOPNOTSUPP;
+#endif
+}
+
+static void tun_set_msglevel(struct net_device *dev, u32 value)
+{
+#ifdef TUN_DEBUG
+	struct tun_struct *tun = netdev_priv(dev);
+	tun->debug = value;
+#endif
+}
+
+static u32 tun_get_link(struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	return tun->attached;
+}
+
+static u32 tun_get_rx_csum(struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	return (tun->flags & TUN_NOCHECKSUM) == 0;
+}
+
+static int tun_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	if (data)
+		tun->flags &= ~TUN_NOCHECKSUM;
+	else
+		tun->flags |= TUN_NOCHECKSUM;
+	return 0;
+}
+
+static struct ethtool_ops tun_ethtool_ops = {
+	.get_settings	= tun_get_settings,
+	.get_drvinfo	= tun_get_drvinfo,
+	.get_msglevel	= tun_get_msglevel,
+	.set_msglevel	= tun_set_msglevel,
+	.get_link	= tun_get_link,
+	.get_rx_csum	= tun_get_rx_csum,
+	.set_rx_csum	= tun_set_rx_csum
+};
+
 int __init tun_init(void)
 {
 	int ret = 0;
 
-	printk(KERN_INFO "Universal TUN/TAP device driver %s " 
-	       "(C)1999-2002 Maxim Krasnyansky\n", TUN_VER);
+	printk(KERN_INFO "tun: %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
+	printk(KERN_INFO "tun: %s\n", DRV_COPYRIGHT);
 
 	ret = misc_register(&tun_miscdev);
 	if (ret)
@@ -766,5 +871,7 @@
 
 module_init(tun_init);
 module_exit(tun_cleanup);
+MODULE_DESCRIPTION(DRV_DESCRIPTION);
+MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_MISCDEV(TUN_MINOR);
diff -Nru a/include/linux/if_tun.h b/include/linux/if_tun.h
--- a/include/linux/if_tun.h	2005-01-18 03:13:47 -05:00
+++ b/include/linux/if_tun.h	2005-01-18 03:13:47 -05:00
@@ -58,7 +58,7 @@
 #endif /* __KERNEL__ */
 
 /* Read queue size */
-#define TUN_READQ_SIZE	10
+#define TUN_READQ_SIZE	500
 
 /* TUN device flags */
 #define TUN_TUN_DEV 	0x0001	

--------------060509060202040405080405--
