From: Jason Lunz <lunz@gtf.org>
Subject: Re: [PATCH] 2.4.20-pre sundance.c cleanups
Date: Wed, 28 Aug 2002 19:13:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020828231333.GA15183@reflexsecurity.com>
References: <20020828185612.GA14342@reflexsecurity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: becker@scyld.com, jgarzik@mandrakesoft.com,
   "Patrick R. McManus" <mcmanus@ducksong.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20020828185612.GA14342@reflexsecurity.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



I forgot to mention that the last patch, like every other sundance
driver I've ever tried, has transmit timeouts under heavy tx load. So I
merged in only the tx changes from Edward Peng's sundance.c v1.03 (i
ignored the rest of it because it moved rx handling to a tasklet in what
looks like an emulation of a NAPI dev->poll function).

This is the first sundance driver I've used that handles both heavy RX
and TX load (where heavy is ~90kpps) without the card resetting on
transmit timeout. It's also the first in-kernel sundance.c that
recognizes a D-Link 580-TX 4-port ethercard.

It remains to be seen whether this driver still works with older
sundance cards; i'd appreciate it if anyone can test that.

Jason


--- sundance-kernel.c	Tue Aug 27 15:30:08 2002
+++ sundance-kernel-cleanup-b.c	Wed Aug 28 19:03:39 2002
@@ -1,6 +1,6 @@
 /* sundance.c: A Linux device driver for the Sundance ST201 "Alta". */
 /*
-	Written 1999-2000 by Donald Becker.
+	Written 1999-2002 by Donald Becker.
 
 	This software may be used and distributed according to the terms of
 	the GNU General Public License (GPL), incorporated herein by reference.
@@ -23,13 +23,27 @@
 
 	Version 1.01b (D-Link):
 	- Add new board to PCI ID list
-	
+
+	Version 1.01c (Jason Lunz):
+	- merged changes from Donald Becker's sundance.c v1.09:
+	  . use IO ops by default (needed for D-Link 580TX)
+	  . autodetect need for mii_preamble_required
+	  . add per-adapter mtu change support
+	  . update driver status in SIOCSMIIREG ioctl
+	  . ignore IntrRxDone (buggy on some chipsets)
+	- minor cleanups
+
+	Version 1.01d (Jason Lunz):
+	- merged changes from Edward Peng's (of D-Link) sundance.c v1.03:
+	  . increase tx ring size
+	  . tx interrupt coalescing
+	  . support for flow control
 
 */
 
 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.01b"
-#define DRV_RELDATE	"17-Jan-2002"
+#define DRV_VERSION	"1.01d"
+#define DRV_RELDATE	"28-Aug-2002"
 
 
 /* The user-configurable values.
@@ -37,7 +51,6 @@
 static int debug = 1;			/* 1 normal messages, 0 quiet .. 7 verbose. */
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work = 30;
-static int mtu;
 /* Maximum number of multicast addresses to filter (vs. rx-all-multicast).
    Typical is a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
@@ -47,7 +60,10 @@
    This chip can receive into offset buffers, so the Alpha does not
    need a copy-align. */
 static int rx_copybreak;
+static int tx_coalesce=1;
+static int flowctrl=1;
 
+#define MAX_UNITS 8		/* More are supported, limit only on options */
 /* media[] specifies the media type the NIC operates at.
 		 autosense	Autosensing active media.
 		 10mbps_hd 	10Mbps half duplex.
@@ -60,18 +76,34 @@
 		 3	 	100Mbps half duplex.
 		 4	 	100Mbps full duplex.
 */
-#define MAX_UNITS 8	
 static char *media[MAX_UNITS];
+/* Used to pass the media type, etc.
+   Both 'options[]' and 'full_duplex[]' should exist for driver
+   interoperability.
+   The media type is usually passed in 'options[]'.
+    The default is autonegotation for speed and duplex.
+	This should rarely be overridden.
+    Use option values 0x10/0x20 for 10Mbps, 0x100,0x200 for 100Mbps.
+    Use option values 0x10 and 0x100 for forcing half duplex fixed speed.
+    Use option values 0x20 and 0x200 for forcing full duplex operation.
+*/
+static int options[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+
+/* Set iff a MII transceiver on any interface requires mdio preamble.
+   This only set with older tranceivers, so the extra
+   code size of a per-interface flag is not worthwhile. */
+static int mii_preamble_required = 0;
+
 /* Operational parameters that are set at compile time. */
 
 /* Keep the ring sizes a power of two for compile efficiency.
    The compiler will convert <unsigned>'%'<2^N> into a bit mask.
    Making the Tx ring too large decreases the effectiveness of channel
-   bonding and packet priority, and more than 128 requires modifying the
-   Tx error recovery.
+   bonding and packet priority, and more than 31 requires modifying the
+   Tx status handling error recovery.
    Large receive rings merely waste memory. */
-#define TX_RING_SIZE	16
-#define TX_QUEUE_LEN	10		/* Limit ring entries actually used.  */
+#define TX_RING_SIZE	64
+#define TX_QUEUE_LEN	(TX_RING_SIZE - 1) /* Limit ring entries actually used.  */
 #define RX_RING_SIZE	32
 #define TX_TOTAL_SIZE	TX_RING_SIZE*sizeof(struct netdev_desc)
 #define RX_TOTAL_SIZE	RX_RING_SIZE*sizeof(struct netdev_desc)
@@ -125,23 +157,33 @@
 MODULE_LICENSE("GPL");
 
 MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(mtu, "i");
 MODULE_PARM(debug, "i");
 MODULE_PARM(rx_copybreak, "i");
 MODULE_PARM(media, "1-" __MODULE_STRING(MAX_UNITS) "s");
-MODULE_PARM_DESC(max_interrupt_work, "Sundance Alta maximum events handled per interrupt");
-MODULE_PARM_DESC(mtu, "Sundance Alta MTU (all boards)");
+MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM(multicast_filter_limit, "i");
+MODULE_PARM(mii_preamble_required, "i");
+MODULE_PARM(flowctrl, "i");
 MODULE_PARM_DESC(debug, "Sundance Alta debug level (0-5)");
+MODULE_PARM_DESC(media, "Sundance Alta force fixed speed+duplex");
+MODULE_PARM_DESC(options, "Sundance Alta force transceiver type or fixed speed+duplex");
+MODULE_PARM_DESC(max_interrupt_work, "Sundance Alta maximum events handled per interrupt");
 MODULE_PARM_DESC(rx_copybreak, "Sundance Alta copy breakpoint for copy-only-tiny-frames");
+MODULE_PARM_DESC(multicast_filter_limit, "Sundance Alta multicast addresses before switching to Rx-all-multicast");
+MODULE_PARM_DESC(mii_preamble_required, "Sundance Alta force sending a preamble before MII management transactions");
+MODULE_PARM_DESC(flowctrl, "Sundance Alta flow control (0|1, default 1)");
 /*
 				Theory of Operation
 
 I. Board Compatibility
 
 This driver is designed for the Sundance Technologies "Alta" ST201 chip.
+The Kendin KS8723 is the same design with an integrated transceiver.
 
 II. Board-specific settings
 
+This is an all-in-one chip, so there are no board-specific settings.
+
 III. Driver operation
 
 IIIa. Ring buffers
@@ -200,8 +242,9 @@
 IVb. References
 
 The Sundance ST201 datasheet, preliminary version.
-http://cesdis.gsfc.nasa.gov/linux/misc/100mbps.html
-http://cesdis.gsfc.nasa.gov/linux/misc/NWay.html
+The Kendin KS8723 datasheet, preliminary version.
+http://www.scyld.com/expert/100mbps.html
+http://www.scyld.com/expert/NWay.html
 
 IVc. Errata
 
@@ -209,6 +252,11 @@
 
 
 
+/* Work-around for Kendin chip bugs. */
+#ifndef USE_MEM_OPS
+#define USE_IO_OPS 1
+#endif
+
 enum pci_id_flags_bits {
         /* Set PCI command register bits before calling probe1(). */
         PCI_USES_IO=1, PCI_USES_MEM=2, PCI_USES_MASTER=4,
@@ -311,7 +359,7 @@
 	MACCtrl0 = 0x50,
 	MACCtrl1 = 0x52,
 	StationAddr = 0x54,
-	MaxTxSize = 0x5A,
+	MaxFrameSize = 0x5A,
 	RxMode = 0x5c,
 	MIICtrl = 0x5e,
 	MulticastFilter0 = 0x60,
@@ -402,21 +450,20 @@
 	int chip_id, drv_flags;
 	unsigned int cur_rx, dirty_rx;		/* Producer/consumer ring indices */
 	unsigned int rx_buf_sz;				/* Based on MTU+slack. */
-	spinlock_t txlock;					/* Group with Tx control cache line. */
 	struct netdev_desc *last_tx;		/* Last Tx descriptor used. */
 	unsigned int cur_tx, dirty_tx;
 	unsigned int tx_full:1;				/* The Tx queue is full. */
+	unsigned int flowctrl:1;
 	/* These values are keep track of the transceiver/media in use. */
 	unsigned int full_duplex:1;			/* Full-duplex operation requested. */
 	unsigned int medialock:1;			/* Do not sense media. */
 	unsigned int default_port:4;		/* Last dev->if_port value. */
-	unsigned int an_enable:1;
-	unsigned int speed;
 	/* Multicast and receive mode. */
 	spinlock_t mcastlock;				/* SMP lock multicast updates. */
 	u16 mcast_filter[4];
 	/* MII transceiver section. */
 	int mii_cnt;						/* MII device addresses. */
+	int link_status;
 	u16 advertising;					/* NWay media advertisement */
 	unsigned char phys[MII_CNT];		/* MII device addresses, only first one used. */
 	struct pci_dev *pci_dev;
@@ -425,6 +472,7 @@
 /* The station address location in the EEPROM. */
 #define EEPROM_SA_OFFSET	0x10
 
+static int  change_mtu(struct net_device *dev, int new_mtu);
 static int  eeprom_read(long ioaddr, int location);
 static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
@@ -437,11 +485,10 @@
 static void intr_handler(int irq, void *dev_instance, struct pt_regs *regs);
 static void netdev_error(struct net_device *dev, int intr_status);
 static int  netdev_rx(struct net_device *dev);
-static void netdev_error(struct net_device *dev, int intr_status);
 static void set_rx_mode(struct net_device *dev);
-static struct net_device_stats *get_stats(struct net_device *dev);
-static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static int  netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int  netdev_close(struct net_device *dev);
+static struct net_device_stats *get_stats(struct net_device *dev);
 
 
 
@@ -455,9 +502,9 @@
 	int irq;
 	int i;
 	long ioaddr;
-	u16 mii_ctl;
 	void *ring_space;
 	dma_addr_t ring_dma;
+	int option = card_idx < MAX_UNITS ? options[card_idx] : 0;
 
 
 /* when built into the kernel, we only print version if device is found */
@@ -524,11 +571,9 @@
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+	dev->change_mtu = &change_mtu;
 	pci_set_drvdata(pdev, dev);
 
-	if (mtu)
-		dev->mtu = mtu;
-
 	i = register_netdev(dev);
 	if (i)
 		goto err_out_unmap_rx;
@@ -542,77 +587,79 @@
 	if (1) {
 		int phy, phy_idx = 0;
 		np->phys[0] = 1;		/* Default setting */
+		mii_preamble_required++;
 		for (phy = 0; phy < 32 && phy_idx < MII_CNT; phy++) {
 			int mii_status = mdio_read(dev, phy, 1);
 			if (mii_status != 0xffff  &&  mii_status != 0x0000) {
 				np->phys[phy_idx++] = phy;
 				np->advertising = mdio_read(dev, phy, 4);
+				if ((mii_status & 0x0040) == 0)
+					mii_preamble_required++;
 				printk(KERN_INFO "%s: MII PHY found at address %d, status "
 					   "0x%4.4x advertising %4.4x.\n",
 					   dev->name, phy, mii_status, np->advertising);
 			}
 		}
+		mii_preamble_required--;
 		np->mii_cnt = phy_idx;
 		if (phy_idx == 0)
 			printk(KERN_INFO "%s: No MII transceiver found!, ASIC status %x\n",
 				   dev->name, readl(ioaddr + ASICCtrl));
 	}
+
+	if(tx_coalesce < 1) {
+		tx_coalesce = 1;
+	} else if(tx_coalesce > TX_QUEUE_LEN - 1) {
+		tx_coalesce = TX_QUEUE_LEN - 1;
+	}
+	if(flowctrl == 0) {
+		np->flowctrl = 0;
+	}
+
 	/* Parse override configuration */
-	np->an_enable = 1;
 	if (card_idx < MAX_UNITS) {
 		if (media[card_idx] != NULL) {
-			np->an_enable = 0;
 			if (strcmp (media[card_idx], "100mbps_fd") == 0 ||
 			    strcmp (media[card_idx], "4") == 0) {
-				np->speed = 100;
-				np->full_duplex = 1;
+				option |= 0x200;
 			} else if (strcmp (media[card_idx], "100mbps_hd") == 0
 				   || strcmp (media[card_idx], "3") == 0) {
-				np->speed = 100;
-				np->full_duplex = 0;
+				option |= 0x100;
 			} else if (strcmp (media[card_idx], "10mbps_fd") == 0 ||
 				   strcmp (media[card_idx], "2") == 0) {
-				np->speed = 10;
-				np->full_duplex = 1;
+				option |= 0x20;
 			} else if (strcmp (media[card_idx], "10mbps_hd") == 0 ||
 				   strcmp (media[card_idx], "1") == 0) {
-				np->speed = 10;
-				np->full_duplex = 0;
-			} else {
-				np->an_enable = 1;
+				option |= 0x10;
 			}
 		}
 	}
 
-	/* Fibre PHY? */
-	if (readl (ioaddr + ASICCtrl) & 0x80) {
-		/* Default 100Mbps Full */
-		if (np->an_enable) {
-			np->speed = 100;
-			np->full_duplex = 1;
-			np->an_enable = 0;
-		}
+	/* Fibre PHY? Default 100Mbps Full */
+	if((readl(ioaddr + ASICCtrl) & 0x80) && (0 == (option & 0x3ff))) {
+		option |= 0x200;
 	}
-	/* Reset PHY */
-	mdio_write (dev, np->phys[0], MII_BMCR, BMCR_RESET);
-	mdelay (300);
-	mdio_write (dev, np->phys[0], MII_BMCR, BMCR_ANENABLE|BMCR_ANRESTART);
-	/* Force media type */
-	if (!np->an_enable) {
-		mii_ctl = 0;
-		mii_ctl |= (np->speed == 100) ? BMCR_SPEED100 : 0;
-		mii_ctl |= (np->full_duplex) ? BMCR_FULLDPLX : 0;
-		mdio_write (dev, np->phys[0], MII_BMCR, mii_ctl);
-		printk (KERN_INFO "Override speed=%d, %s duplex\n",
-			np->speed, np->full_duplex ? "Full" : "Half");
 
+	/* Allow forcing the media type. */
+	if (option > 0) {
+		if (option & 0x220)
+			np->full_duplex = 1;
+		np->default_port = option & 0x3ff;
+		if (np->default_port & 0x330) {
+			np->medialock = 1;
+			printk(KERN_INFO "  Forcing %dMbps %s-duplex operation.\n",
+				   (option & 0x300 ? 100 : 10),
+				   np->full_duplex ? "full" : "half");
+			mdio_write(dev, np->phys[0], MII_BMCR,
+					(option & 0x330) ? BMCR_SPEED100 : 0 |
+					(np->full_duplex ? BMCR_FULLDPLX : 0));
+		}
 	}
 
-	/* Perhaps move the reset here? */
 	/* Reset the chip to erase previous misconfiguration. */
 	if (debug > 1)
 		printk("ASIC Control is %x.\n", readl(ioaddr + ASICCtrl));
-	writew(0x007f, ioaddr + ASICCtrl + 2);
+	writel(0x007f0000 | readl(ioaddr + ASICCtrl), ioaddr + ASICCtrl);
 	if (debug > 1)
 		printk("ASIC Control is now %x.\n", readl(ioaddr + ASICCtrl));
 
@@ -636,10 +683,21 @@
 }
 
 
+
+static int change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > 8191)) /* Set by RxDMAFrameLen */
+		return -EINVAL;
+	if (netif_running(dev))
+		return -EBUSY;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 /* Read the EEPROM and MII Management Data I/O (MDIO) interfaces. */
 static int __devinit eeprom_read(long ioaddr, int location)
 {
-	int boguscnt = 1000;		/* Typical 190 ticks. */
+	int boguscnt = 2000;		/* Typical 190 ticks. */
 	writew(0x0200 | (location & 0xff), ioaddr + EECtrl);
 	do {
 		if (! (readw(ioaddr + EECtrl) & 0x8000)) {
@@ -658,11 +716,6 @@
 	met by back-to-back 33Mhz PCI cycles. */
 #define mdio_delay() readb(mdio_addr)
 
-/* Set iff a MII transceiver on any interface requires mdio preamble.
-   This only set with older tranceivers, so the extra
-   code size of a per-interface flag is not worthwhile. */
-static const char mii_preamble_required = 1;
-
 enum mii_reg_bits {
 	MDIO_ShiftClk=0x0001, MDIO_Data=0x0002, MDIO_EnbOutput=0x0004,
 };
@@ -761,6 +814,11 @@
 
 	init_ring(dev);
 
+	if (dev->if_port == 0)
+		dev->if_port = np->default_port;
+
+	np->mcastlock = (spinlock_t) SPIN_LOCK_UNLOCKED;
+
 	writel(np->rx_ring_dma, ioaddr + RxListPtr);
 	/* The Tx list pointer is written as packets are queued. */
 
@@ -768,26 +826,27 @@
 		writeb(dev->dev_addr[i], ioaddr + StationAddr + i);
 
 	/* Initialize other registers. */
-	/* Configure the PCI bus bursts and FIFO thresholds. */
-
-	if (dev->if_port == 0)
-		dev->if_port = np->default_port;
-
-	np->mcastlock = (spinlock_t) SPIN_LOCK_UNLOCKED;
+	np->link_status = readb(ioaddr + MIICtrl) & 0xE0;
+	writew((np->full_duplex || (np->link_status & 0x20)) ? 0x120 : 0,
+		   ioaddr + MACCtrl0);
+	writew(dev->mtu + 14, ioaddr + MaxFrameSize);
+	if (dev->mtu > 2047)
+		writel(readl(ioaddr + ASICCtrl) | 0x0C, ioaddr + ASICCtrl);
 
+	/* Configure the PCI bus bursts and FIFO thresholds. */
 	set_rx_mode(dev);
 	writew(0, ioaddr + IntrEnable);
 	writew(0, ioaddr + DownCounter);
 	/* Set the chip to poll every N*320nsec. */
 	writeb(100, ioaddr + RxDescPoll);
 	writeb(127, ioaddr + TxDescPoll);
-	netif_start_queue(dev);
 
 	/* Enable interrupts by setting the interrupt mask. */
-	writew(IntrRxDone | IntrRxDMADone | IntrPCIErr | IntrDrvRqst | IntrTxDone
+	writew(IntrRxDMADone | IntrPCIErr | IntrDrvRqst | IntrTxDone
 		   | StatsMax | LinkChange, ioaddr + IntrEnable);
 
 	writew(StatsEnable | RxEnable | TxEnable, ioaddr + MACCtrl1);
+	netif_start_queue(dev);
 
 	if (debug > 2)
 		printk(KERN_DEBUG "%s: Done netdev_open(), status: Rx %x Tx %x "
@@ -815,21 +874,23 @@
 	int duplex;
 	
 	/* Force media */
-	if (!np->an_enable || mii_lpa == 0xffff) {
+	if (np->medialock || mii_lpa == 0xffff) {
 		if (np->full_duplex)
 			writew (readw (ioaddr + MACCtrl0) | EnbFullDuplex,
 				ioaddr + MACCtrl0);
 		return;
 	}
 	/* Autonegotiation */
-	duplex = (negotiated & 0x0100) || (negotiated & 0x01C0) == 0x0040;
+	duplex = (negotiated & LPA_100FULL) ||
+		(negotiated & (LPA_100FULL | LPA_100HALF | LPA_10FULL)) == LPA_10FULL;
 	if (np->full_duplex != duplex) {
 		np->full_duplex = duplex;
 		if (debug)
 			printk(KERN_INFO "%s: Setting %s-duplex based on MII #%d "
 				   "negotiated capability %4.4x.\n", dev->name,
 				   duplex ? "full" : "half", np->phys[0], negotiated);
-		writew(duplex ? 0x20 : 0, ioaddr + MACCtrl0);
+		writew(duplex ? (readw(ioaddr + MACCtrl0) | EnbFullDuplex) : 0,
+				ioaddr + MACCtrl0);
 	}
 }
 
@@ -875,13 +936,13 @@
 	/* Stop and restart the chip's Tx processes . */
 
 	/* Trigger an immediate transmit demand. */
-	writew(IntrRxDone | IntrRxDMADone | IntrPCIErr | IntrDrvRqst | IntrTxDone
+	writew(IntrRxDMADone | IntrPCIErr | IntrDrvRqst | IntrTxDone
 		   | StatsMax | LinkChange, ioaddr + IntrEnable);
 
 	dev->trans_start = jiffies;
 	np->stats.tx_errors++;
 
-	if (!np->tx_full)
+	if(!netif_queue_stopped(dev))
 		netif_wake_queue(dev);
 }
 
@@ -892,11 +953,10 @@
 	struct netdev_private *np = dev->priv;
 	int i;
 
-	np->tx_full = 0;
 	np->cur_rx = np->cur_tx = 0;
 	np->dirty_rx = np->dirty_tx = 0;
 
-	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
+	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 36);
 
 	/* Initialize all Rx descriptors. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -904,7 +964,7 @@
 			((i+1)%RX_RING_SIZE)*sizeof(*np->rx_ring));
 		np->rx_ring[i].status = 0;
 		np->rx_ring[i].frag[0].length = 0;
-		np->rx_skbuff[i] = 0;
+		np->rx_skbuff[i] = NULL;
 	}
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
@@ -923,7 +983,7 @@
 	np->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
-		np->tx_skbuff[i] = 0;
+		np->tx_skbuff[i] = NULL;
 		np->tx_ring[i].status = 0;
 	}
 	return;
@@ -945,8 +1005,12 @@
 
 	txdesc->next_desc = 0;
 	/* Note: disable the interrupt generation here before releasing. */
-	txdesc->status =
-		cpu_to_le32((entry<<2) | DescIntrOnDMADone | DescIntrOnTx | DisableAlign);
+	if(entry % tx_coalesce == 0) {
+		txdesc->status = cpu_to_le32((entry<<2) | DescIntrOnTx | DisableAlign);
+	
+	} else {
+		txdesc->status = cpu_to_le32((entry<<2) | DisableAlign);
+	}
 	txdesc->frag[0].addr = cpu_to_le32(pci_map_single(np->pci_dev, 
 		skb->data, skb->len, PCI_DMA_TODEVICE));
 	txdesc->frag[0].length = cpu_to_le32(skb->len | LastFrag);
@@ -958,10 +1022,10 @@
 
 	/* On some architectures: explicitly flush cache lines here. */
 
-	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1) {
+	if((np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1) &&
+			!netif_queue_stopped(dev)) {
 		/* do nothing */
 	} else {
-		np->tx_full = 1;
 		netif_stop_queue(dev);
 	}
 	/* Side effect: The read wakes the potentially-idle transmit channel. */
@@ -972,9 +1036,13 @@
 	dev->trans_start = jiffies;
 
 	if (debug > 4) {
-		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
-			   dev->name, np->cur_tx, entry);
+		printk(KERN_DEBUG "%s: Transmit frame #%d len %d queued in slot %d.\n",
+			   dev->name, np->cur_tx, skb->len, entry);
 	}
+
+	if(tx_coalesce > 1)
+		writel(1000, dev->base_addr + DownCounter);
+
 	return 0;
 }
 
@@ -993,21 +1061,21 @@
 
 	do {
 		int intr_status = readw(ioaddr + IntrStatus);
-		writew(intr_status & (IntrRxDone | IntrRxDMADone | IntrPCIErr |
-			IntrDrvRqst | IntrTxDone | IntrTxDMADone | StatsMax | 
-			LinkChange), ioaddr + IntrStatus);
+		if ((intr_status & ~IntrRxDone) == 0 || intr_status == 0xffff)
+			break;
+
+		writew(intr_status & (IntrRxDMADone | IntrPCIErr |
+					IntrDrvRqst | IntrTxDone | IntrTxDMADone |
+					StatsMax | LinkChange), ioaddr + IntrStatus);
 
 		if (debug > 4)
 			printk(KERN_DEBUG "%s: Interrupt, status %4.4x.\n",
 				   dev->name, intr_status);
 
-		if (intr_status == 0)
-			break;
-
-		if (intr_status & (IntrRxDone|IntrRxDMADone))
+		if (intr_status & IntrRxDMADone)
 			netdev_rx(dev);
 
-		if (intr_status & IntrTxDone) {
+		if (intr_status & (IntrTxDone | IntrDrvRqst)) {
 			int boguscnt = 32;
 			int tx_status = readw(ioaddr + TxStatus);
 			while (tx_status & 0x80) {
@@ -1026,7 +1094,8 @@
 					if (tx_status & 0x02)  np->stats.tx_window_errors++;
 					/* This reset has not been verified!. */
 					if (tx_status & 0x10) {			/* Reset the Tx. */
-						writew(0x001c, ioaddr + ASICCtrl + 2);
+						writel(0x001c0000 | readl(ioaddr + ASICCtrl),
+							   ioaddr + ASICCtrl);
 #if 0					/* Do we need to reset the Tx pointer here? */
 						writel(np->tx_ring_dma
 							+ np->dirty_tx*sizeof(*np->tx_ring),
@@ -1038,7 +1107,7 @@
 				}
 				/* Yup, this is a documentation bug.  It cost me *hours*. */
 				writew(0, ioaddr + TxStatus);
-				tx_status = readb(ioaddr + TxStatus);
+				tx_status = readw(ioaddr + TxStatus);
 				if (--boguscnt < 0)
 					break;
 			}
@@ -1057,26 +1126,22 @@
 			dev_kfree_skb_irq(skb);
 			np->tx_skbuff[entry] = 0;
 		}
-		if (np->tx_full
-			&& np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
+		if (netif_queue_stopped(dev) && 
+			np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 			/* The ring is no longer full, clear tbusy. */
-			np->tx_full = 0;
 			netif_wake_queue(dev);
 		}
 
 		/* Abnormal error summary/uncommon events handlers. */
-		if (intr_status & (IntrDrvRqst | IntrPCIErr | LinkChange | StatsMax))
+		if (intr_status & (IntrPCIErr | LinkChange | StatsMax))
 			netdev_error(dev, intr_status);
+		
 		if (--boguscnt < 0) {
 			get_stats(dev);
 			if (debug > 1) 
 				printk(KERN_WARNING "%s: Too much work at interrupt, "
 				   "status=0x%4.4x / 0x%4.4x.\n",
 				   dev->name, intr_status, readw(ioaddr + IntrClear));
-			/* Re-enable us in 3.2msec. */
-			writew(0, ioaddr + IntrEnable);
-			writew(1000, ioaddr + DownCounter);
-			writew(IntrDrvRqst, ioaddr + IntrEnable);
 			break;
 		}
 	} while (1);
@@ -1085,6 +1150,9 @@
 		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x.\n",
 			   dev->name, readw(ioaddr + IntrStatus));
 
+	if(np->cur_tx - np->dirty_tx > 0 && tx_coalesce > 1)
+		writel(100, ioaddr + DownCounter);
+
 	spin_unlock(&np->lock);
 }
 
@@ -1196,46 +1264,31 @@
 {
 	long ioaddr = dev->base_addr;
 	struct netdev_private *np = dev->priv;
-	u16 mii_ctl, mii_advertise, mii_lpa;
-	int speed;
 
-	if (intr_status & IntrDrvRqst) {
-		/* Stop the down counter and turn interrupts back on. */
-		if (debug > 1)
-			printk("%s: Turning interrupts back on.\n", dev->name);
-		writew(0, ioaddr + IntrEnable);
-		writew(0, ioaddr + DownCounter);
-		writew(IntrRxDone | IntrRxDMADone | IntrPCIErr | IntrDrvRqst |
-			   IntrTxDone | StatsMax | LinkChange, ioaddr + IntrEnable);
-		/* Ack buggy InRequest */
-		writew (IntrDrvRqst, ioaddr + IntrStatus);
-	}
 	if (intr_status & LinkChange) {
-		if (np->an_enable) {
-			mii_advertise = mdio_read (dev, np->phys[0], MII_ADVERTISE);
-			mii_lpa= mdio_read (dev, np->phys[0], MII_LPA);
-			mii_advertise &= mii_lpa;
-			printk (KERN_INFO "%s: Link changed: ", dev->name);
-			if (mii_advertise & ADVERTISE_100FULL)
-				printk ("100Mbps, full duplex\n");
-			else if (mii_advertise & ADVERTISE_100HALF)
-				printk ("100Mbps, half duplex\n");
-			else if (mii_advertise & ADVERTISE_10FULL)
-				printk ("10Mbps, full duplex\n");
-			else if (mii_advertise & ADVERTISE_10HALF)
-				printk ("10Mbps, half duplex\n");
+		int new_status = readb(ioaddr + MIICtrl) & 0xE0;
+		u16 mii_advertise = mdio_read (dev, np->phys[0], MII_ADVERTISE);
+		u16 mii_lpa = mdio_read (dev, np->phys[0], MII_LPA);
+
+		printk(KERN_ERR "%s: Link changed: Autonegotiation advertising "
+				"%dMbps %s duplex, partner %dMbps %s duplex.\n",
+				dev->name,
+				(mii_advertise & BMCR_SPEED100) ? 100 : 10,
+				(mii_advertise & BMCR_FULLDPLX) ? "full" : "half",
+				(mii_lpa & BMCR_SPEED100) ? 100 : 10,
+				(mii_lpa & BMCR_FULLDPLX) ? "full" : "half");
+		if ((np->link_status ^ new_status) & 0x80) {
+			/* need to check if this is even remotely correct */
+			if (new_status & 0x80)
+				netif_carrier_on(dev);
 			else
-				printk ("\n");
-
-		} else {
-			mii_ctl = mdio_read (dev, np->phys[0], MII_BMCR);
-			speed = (mii_ctl & BMCR_SPEED100) ? 100 : 10;
-			printk (KERN_INFO "%s: Link changed: %dMbps ,",
-				dev->name, speed);
-			printk ("%s duplex.\n", (mii_ctl & BMCR_FULLDPLX) ?
-				"full" : "half");
+				netif_carrier_off(dev);
 		}
-		check_duplex (dev);
+		np->link_status = new_status;
+		check_duplex(dev);
+		if(np->flowctrl == 0)
+			writew(readw(ioaddr + MACCtrl0) & ~EnbFlowCtrl,
+					ioaddr + MACCtrl0);
 	}
 	if (intr_status & StatsMax) {
 		get_stats(dev);
@@ -1253,6 +1306,9 @@
 	struct netdev_private *np = dev->priv;
 	int i;
 
+	if (readw(ioaddr + TxOctetsHigh) == 0xffff)
+		return &np->stats;
+
 	/* We should lock this segment of code for SMP eventually, although
 	   the vulnerability window is very small and statistics are
 	   non-critical. */
@@ -1329,6 +1385,38 @@
 		return 0;
 	}
 
+	case ETHTOOL_GSET: {
+		struct ethtool_cmd ecmd = { ETHTOOL_GSET };
+
+		ecmd.supported = SUPPORTED_Autoneg;
+
+		spin_lock_irq(&np->lock);
+		if((readl(dev->base_addr + ASICCtrl) & 0x80)) {
+			ecmd.supported |= SUPPORTED_FIBRE;
+		} else {
+			ecmd.supported |= (SUPPORTED_100baseT_Half |
+					  SUPPORTED_100baseT_Full |
+					  SUPPORTED_10baseT_Half |
+					  SUPPORTED_10baseT_Full |
+					  SUPPORTED_MII);
+		}
+
+		ecmd.advertising = np->advertising;
+		ecmd.speed = 0;
+		ecmd.duplex = np->full_duplex;
+		ecmd.port = 0;
+		ecmd.phy_address = np->phys[0];
+		ecmd.transceiver = 0;
+		ecmd.autoneg = !np->medialock;
+		ecmd.maxtxpkt = 0;
+		ecmd.maxrxpkt = 0;
+
+		spin_unlock_irq(&np->lock);
+		if(copy_to_user(useraddr, &ecmd, sizeof(ecmd)))
+			return -EFAULT;
+		return 0;
+	}
+
         }
 	
 	return -EOPNOTSUPP;
@@ -1336,6 +1424,7 @@
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
+	struct netdev_private *np = dev->priv;
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&rq->ifr_data;
 
 	switch(cmd) {
@@ -1343,7 +1432,7 @@
 		return netdev_ethtool_ioctl(dev, (void *) rq->ifr_data);
 	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
 	case SIOCDEVPRIVATE:		/* for binary compat, remove in 2.5 */
-		data->phy_id = ((struct netdev_private *)dev->priv)->phys[0] & 0x1f;
+		data->phy_id = np->phys[0] & 0x1f;
 		/* Fall Through */
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
@@ -1355,6 +1444,17 @@
 	case SIOCDEVPRIVATE+2:		/* for binary compat, remove in 2.5 */
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
+		if(data->phy_id == np->phys[0]) {
+			switch(data->reg_num) {
+			case 0:
+				np->medialock = (data->val_in & (BMCR_RESET|BMCR_ANENABLE)) ? 0 : 1;
+				if(np->medialock)
+					np->full_duplex = (data->val_in & BMCR_FULLDPLX) ? 1 : 0;
+				break;
+			case 4: np->advertising = data->val_in; break;
+			}
+			/* Perhaps check_duplex(dev), depending on chip semantics. */
+		}
 		mdio_write(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
 		return 0;
 	default:
@@ -1418,7 +1518,7 @@
 				np->rx_ring[i].frag[0].addr, np->rx_buf_sz, 
 				PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
-			np->rx_skbuff[i] = 0;
+			np->rx_skbuff[i] = NULL;
 		}
 	}
 	for (i = 0; i < TX_RING_SIZE; i++) {
@@ -1428,7 +1528,7 @@
 				np->tx_ring[i].frag[0].addr, skb->len,
 				PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
-			np->tx_skbuff[i] = 0;
+			np->tx_skbuff[i] = NULL;
 		}
 	}
 
