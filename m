From: Roger Luethi <rl@hellgate.ch>
Subject: [7/9][PATCH 2.6] Rewrite special-casing
Date: Wed, 2 Jun 2004 13:59:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115900.GA17578@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use PCI revision to determine special cases. One bit field replaces a
bunch of data structures holding special case information.

Replace chip_id, drv_flags in rhine_private with quirks

Remove enum rhine_chips, struct rhine_chip_info (and array),
enum chip_capability_flags

Add enum rhine_revs, enum rhine_quirks (some values in preparation for
subsequent changes)

wait_for_reset() and enable_mmio() now use quirks instead of chip_id

Remove model names from ident strings for now.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -354,48 +354,46 @@
    second only the 1234 card.
 */
 
-enum rhine_chips {
-	VT86C100A = 0,
-	VT6102,
-	VT6105,
-	VT6105M
+enum rhine_revs {
+	VT86C100A	= 0x00,
+	VT6102		= 0x40,
+	VT8231		= 0x50,	/* Integrated MAC */
+	VT8233		= 0x60,	/* Integrated MAC */
+	VT8235		= 0x74,	/* Integrated MAC */
+	VT8237		= 0x78,	/* Integrated MAC */
+	VTunknown0	= 0x7C,
+	VT6105		= 0x80,
+	VT6105_B0	= 0x83,
+	VT6105L		= 0x8A,
+	VT6107		= 0x8C,
+	VTunknown1	= 0x8E,
+	VT6105M		= 0x90,
 };
 
-struct rhine_chip_info {
-	const char *name;
-	int io_size;
-	int drv_flags;
-};
-
-
-enum chip_capability_flags {
-	HasDavicomPhy=4,
-	ReqTxAlign=0x10, HasWOL=0x20,
+enum rhine_quirks {
+	rqWOL		= 0x0001,	/* Wake-On-LAN support */
+	rqForceReset	= 0x0002,
+	rqDavicomPhy	= 0x0020,
+	rq6patterns	= 0x0040,	/* 6 instead of 4 patterns for WOL */
+	rqStatusWBRace	= 0x0080,	/* Tx Status Writeback Error possible */
+	rqRhineI	= 0x0100,	/* See comment below */
 };
+/*
+ * rqRhineI: VT86C100A (aka Rhine-I) uses different bits to enable
+ * MMIO as well as for the collision counter and the Tx FIFO underflow
+ * indicator. In addition, Tx and Rx buffers need to 4 byte aligned.
+ */
 
 /* Beware of PCI posted writes */
 #define IOSYNC	do { readb(dev->base_addr + StationAddr); } while (0)
 
-/* directly indexed by enum rhine_chips, above */
-static struct rhine_chip_info rhine_chip_info[] __devinitdata =
-{
-	{ "VIA VT86C100A Rhine", 128,
-	  ReqTxAlign | HasDavicomPhy },
-	{ "VIA VT6102 Rhine-II", 256,
-	  HasWOL },
-	{ "VIA VT6105 Rhine-III", 256,
-	  HasWOL },
-	{ "VIA VT6105M Rhine-III", 256,
-	  HasWOL },
-};
-
 static struct pci_device_id rhine_pci_tbl[] =
 {
-	{0x1106, 0x3043, PCI_ANY_ID, PCI_ANY_ID, 0, 0, VT86C100A},
-	{0x1106, 0x3065, PCI_ANY_ID, PCI_ANY_ID, 0, 0, VT6102},
-	{0x1106, 0x3106, PCI_ANY_ID, PCI_ANY_ID, 0, 0, VT6105}, /* 6105{,L,LOM} */
-	{0x1106, 0x3053, PCI_ANY_ID, PCI_ANY_ID, 0, 0, VT6105M},
-	{0,}	/* terminate list */
+	{0x1106, 0x3043, PCI_ANY_ID, PCI_ANY_ID, 0, 0, }, /* VT86C100A */
+	{0x1106, 0x3065, PCI_ANY_ID, PCI_ANY_ID, 0, 0, }, /* VT6102 */
+	{0x1106, 0x3106, PCI_ANY_ID, PCI_ANY_ID, 0, 0, }, /* 6105{,L,LOM} */
+	{0x1106, 0x3053, PCI_ANY_ID, PCI_ANY_ID, 0, 0, }, /* VT6105M */
+	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
 
@@ -503,7 +501,7 @@
 	spinlock_t lock;
 
 	/* Frequently used values: keep some adjacent for cache effect. */
-	int chip_id, drv_flags;
+	u32 quirks;
 	struct rx_desc *rx_head_desc;
 	unsigned int cur_rx, dirty_rx;	/* Producer/consumer ring indices */
 	unsigned int cur_tx, dirty_tx;
@@ -545,12 +543,12 @@
 
 	intr_status = readw(ioaddr + IntrStatus);
 	/* On Rhine-II, Bit 3 indicates Tx descriptor write-back race. */
-	if (rp->chip_id == VT6102)
+	if (rp->quirks & rqStatusWBRace)
 		intr_status |= readb(ioaddr + IntrStatus2) << 16;
 	return intr_status;
 }
 
-static void wait_for_reset(struct net_device *dev, int chip_id, char *name)
+static void wait_for_reset(struct net_device *dev, u32 quirks, char *name)
 {
 	long ioaddr = dev->base_addr;
 	int boguscnt = 20;
@@ -562,7 +560,7 @@
 			"Trying harder.\n", name);
 
 		/* Rhine-II needs to be forced sometimes */
-		if (chip_id == VT6102)
+		if (quirks & rqForceReset)
 			writeb(0x40, ioaddr + MiscCmd);
 
 		/* VT86C100A may need long delay after reset (dlink) */
@@ -578,10 +576,10 @@
 }
 
 #ifdef USE_MMIO
-static void __devinit enable_mmio(long ioaddr, int chip_id)
+static void __devinit enable_mmio(long ioaddr, u32 quirks)
 {
 	int n;
-	if (chip_id == VT86C100A) {
+	if (quirks & rqRhineI) {
 		/* More recent docs say that this bit is reserved ... */
 		n = inb(ioaddr + ConfigA) | 0x20;
 		outb(n, ioaddr + ConfigA);
@@ -617,7 +615,8 @@
 	struct net_device *dev;
 	struct rhine_private *rp;
 	int i, option, rc;
-	int chip_id = (int) ent->driver_data;
+	u8 pci_rev;
+	u32 quirks;
 	static int card_idx = -1;
 	long ioaddr;
 	long memaddr;
@@ -626,6 +625,7 @@
 #ifdef USE_MMIO
 	long ioaddr0;
 #endif
+	const char *name;
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -636,7 +636,26 @@
 
 	card_idx++;
 	option = card_idx < MAX_UNITS ? options[card_idx] : 0;
-	io_size = rhine_chip_info[chip_id].io_size;
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &pci_rev);
+
+	io_size = 256;
+	if (pci_rev < VT6102) {
+		quirks = rqRhineI | rqDavicomPhy;
+		io_size = 128;
+		name = "VT86C100A Rhine";
+	}
+	else {
+		quirks = rqWOL | rqForceReset;
+		if (pci_rev < VT6105) {
+			name = "Rhine II";
+			quirks |= rqStatusWBRace;	/* Rhine-II exclusive */
+		}
+		else {
+			name = "Rhine III";
+			if (pci_rev >= VT6105_B0)
+				quirks |= rq6patterns;
+		}
+	}
 
 	rc = pci_enable_device(pdev);
 	if (rc)
@@ -679,7 +698,7 @@
 
 #ifdef USE_MMIO
 	ioaddr0 = ioaddr;
-	enable_mmio(ioaddr0, chip_id);
+	enable_mmio(ioaddr0, quirks);
 
 	ioaddr = (long) ioremap(memaddr, io_size);
 	if (!ioaddr) {
@@ -705,7 +724,7 @@
 #endif /* USE_MMIO */
 
 	/* D-Link provided reset code (with comment additions) */
-	if (rhine_chip_info[chip_id].drv_flags & HasWOL) {
+	if (quirks & rqWOL) {
 		unsigned char byOrgValue;
 
 		/* clear sticky bit before reset & read ethernet address */
@@ -726,7 +745,7 @@
 	writew(CmdReset, ioaddr + ChipCmd);
 
 	dev->base_addr = ioaddr;
-	wait_for_reset(dev, chip_id, shortname);
+	wait_for_reset(dev, quirks, shortname);
 
 	/* Reload the station address from the EEPROM. */
 #ifdef USE_MMIO
@@ -734,7 +753,7 @@
 	/* Reloading from eeprom overwrites cfgA-D, so we must re-enable MMIO.
 	   If reload_eeprom() was done first this could be avoided, but it is
 	   not known if that still works with the "win98-reboot" problem. */
-	enable_mmio(ioaddr0, chip_id);
+	enable_mmio(ioaddr0, quirks);
 #else
 	reload_eeprom(ioaddr);
 #endif
@@ -748,7 +767,7 @@
 		goto err_out_unmap;
 	}
 
-	if (chip_id == VT6102) {
+	if (quirks & rqWOL) {
 		/*
 		 * for 3065D, EEPROM reloaded will cause bit 0 in MAC_REG_CFGA
 		 * turned on. it makes MAC receive magic packet
@@ -766,9 +785,8 @@
 
 	rp = netdev_priv(dev);
 	spin_lock_init(&rp->lock);
-	rp->chip_id = chip_id;
-	rp->drv_flags = rhine_chip_info[chip_id].drv_flags;
 	rp->pdev = pdev;
+	rp->quirks = quirks;
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
 	rp->mii_if.mdio_write = mdio_write;
@@ -791,7 +809,7 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = rhine_poll;
 #endif
-	if (rp->drv_flags & ReqTxAlign)
+	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
 	/* dev->name not defined before register_netdev()! */
@@ -813,8 +831,8 @@
 		rp->mii_if.force_media = 1;
 	}
 
-	printk(KERN_INFO "%s: %s at 0x%lx, ",
-	       dev->name, rhine_chip_info[chip_id].name,
+	printk(KERN_INFO "%s: VIA %s at 0x%lx, ",
+	       dev->name, name,
 #ifdef USE_MMIO
 		memaddr
 #else
@@ -896,7 +914,7 @@
 		printk(KERN_ERR "Could not allocate DMA memory.\n");
 		return -ENOMEM;
 	}
-	if (rp->drv_flags & ReqTxAlign) {
+	if (rp->quirks & rqRhineI) {
 		rp->tx_bufs = pci_alloc_consistent(rp->pdev,
 						   PKT_BUF_SZ * TX_RING_SIZE,
 						   &rp->tx_bufs_dma);
@@ -1154,7 +1172,7 @@
 		return i;
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
-	wait_for_reset(dev, rp->chip_id, dev->name);
+	wait_for_reset(dev, rp->quirks, dev->name);
 	init_registers(dev);
 	if (debug > 2)
 		printk(KERN_DEBUG "%s: Done rhine_open(), status %4.4x "
@@ -1260,7 +1278,7 @@
 	alloc_rbufs(dev);
 
 	/* Reinitialize the hardware. */
-	wait_for_reset(dev, rp->chip_id, dev->name);
+	wait_for_reset(dev, rp->quirks, dev->name);
 	init_registers(dev);
 
 	spin_unlock(&rp->lock);
@@ -1291,7 +1309,7 @@
 
 	rp->tx_skbuff[entry] = skb;
 
-	if ((rp->drv_flags & ReqTxAlign) &&
+	if ((rp->quirks & rqRhineI) &&
 	    (((long)skb->data & 3) || skb_shinfo(skb)->nr_frags != 0 || skb->ip_summed == CHECKSUM_HW)) {
 		/* Must use alignment buffer. */
 		if (skb->len > PKT_BUF_SZ) {
@@ -1440,7 +1458,7 @@
 			if (txstatus & 0x0200) rp->stats.tx_window_errors++;
 			if (txstatus & 0x0100) rp->stats.tx_aborted_errors++;
 			if (txstatus & 0x0080) rp->stats.tx_heartbeat_errors++;
-			if (((rp->chip_id == VT86C100A) && txstatus & 0x0002) ||
+			if (((rp->quirks & rqRhineI) && txstatus & 0x0002) ||
 			    (txstatus & 0x0800) || (txstatus & 0x1000)) {
 				rp->stats.tx_fifo_errors++;
 				rp->tx_ring[entry].tx_status = cpu_to_le32(DescOwn);
@@ -1448,7 +1466,7 @@
 			}
 			/* Transmitter restarted in 'abnormal' handler. */
 		} else {
-			if (rp->chip_id == VT86C100A)
+			if (rp->quirks & rqRhineI)
 				rp->stats.collisions += (txstatus >> 3) & 0x0F;
 			else
 				rp->stats.collisions += txstatus & 0x0F;
@@ -1660,7 +1678,7 @@
 	if (intr_status & (IntrLinkChange)) {
 		if (readb(ioaddr + MIIStatus) & 0x02) {
 			/* Link failed, restart autonegotiation. */
-			if (rp->drv_flags & HasDavicomPhy)
+			if (rp->quirks & rqRhineI)
 				mdio_write(dev, rp->phys[0], MII_BMCR, 0x3300);
 		} else
 			rhine_check_duplex(dev);
