From: Roger Luethi <rl@hellgate.ch>
Subject: [9/9][PATCH 2.6] Restructure reset code
Date: Wed, 2 Jun 2004 13:59:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115920.GA17634@k3.hellgate.ch>
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

Restructure code to make it easier to maintain.

rhine_hw_init: resets chip, reloads eeprom
rhine_chip_reset: chip reset + what used to be wait_for_reset
rhine_reload_eeprom: reload eeprom, re-enable MMIO, disable EEPROM-controlled
	WOL

Note: Chip reset clears a bunch of registers that should be reloaded
from EEPROM (which turns off MMIO). Deal with that later.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -579,56 +579,76 @@
 	}
 }
 
-static void wait_for_reset(struct net_device *dev, u32 quirks, char *name)
+static void rhine_chip_reset(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
+	struct rhine_private *rp = netdev_priv(dev);
 	int boguscnt = 20;
 
+	writew(CmdReset, ioaddr + ChipCmd);
 	IOSYNC;
 
 	if (readw(ioaddr + ChipCmd) & CmdReset) {
 		printk(KERN_INFO "%s: Reset not complete yet. "
-			"Trying harder.\n", name);
+			"Trying harder.\n", DRV_NAME);
 
-		/* Rhine-II needs to be forced sometimes */
-		if (quirks & rqForceReset)
+		/* Force reset */
+		if (rp->quirks & rqForceReset)
 			writeb(0x40, ioaddr + MiscCmd);
 
-		/* VT86C100A may need long delay after reset (dlink) */
-		/* Seen on Rhine-II as well (rl) */
+		/* Reset can take somewhat longer (rare) */
 		while ((readw(ioaddr + ChipCmd) & CmdReset) && --boguscnt)
 			udelay(5);
-
 	}
 
 	if (debug > 1)
-		printk(KERN_INFO "%s: Reset %s.\n", name,
+		printk(KERN_INFO "%s: Reset %s.\n", pci_name(rp->pdev),
 			boguscnt ? "succeeded" : "failed");
 }
 
 #ifdef USE_MMIO
-static void __devinit enable_mmio(long ioaddr, u32 quirks)
+static void __devinit enable_mmio(long pioaddr, u32 quirks)
 {
 	int n;
 	if (quirks & rqRhineI) {
 		/* More recent docs say that this bit is reserved ... */
-		n = inb(ioaddr + ConfigA) | 0x20;
-		outb(n, ioaddr + ConfigA);
+		n = inb(pioaddr + ConfigA) | 0x20;
+		outb(n, pioaddr + ConfigA);
 	} else {
-		n = inb(ioaddr + ConfigD) | 0x80;
-		outb(n, ioaddr + ConfigD);
+		n = inb(pioaddr + ConfigD) | 0x80;
+		outb(n, pioaddr + ConfigD);
 	}
 }
 #endif
 
-static void __devinit reload_eeprom(long ioaddr)
+/*
+ * Loads bytes 0x00-0x05, 0x6E-0x6F, 0x78-0x7B from EEPROM
+ */
+static void __devinit rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 {
+	long ioaddr = dev->base_addr;
+	struct rhine_private *rp = netdev_priv(dev);
 	int i;
-	outb(0x20, ioaddr + MACRegEEcsr);
+
+	outb(0x20, pioaddr + MACRegEEcsr);
 	/* Typically 2 cycles to reload. */
 	for (i = 0; i < 150; i++)
-		if (! (inb(ioaddr + MACRegEEcsr) & 0x20))
+		if (! (inb(pioaddr + MACRegEEcsr) & 0x20))
 			break;
+
+#ifdef USE_MMIO
+	/*
+	 * Reloading from EEPROM overwrites ConfigA-D, so we must re-enable
+	 * MMIO. If reloading EEPROM was done first this could be avoided, but
+	 * it is not known if that still works with the "win98-reboot" problem.
+	 */
+	enable_mmio(pioaddr, rp->quirks);
+#endif
+
+	/* Turn off EEPROM-controlled wake-up (magic packet) */
+	if (rp->quirks & rqWOL)
+		writeb(readb(ioaddr + ConfigA) & 0xFE, ioaddr + ConfigA);
+
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -640,6 +660,15 @@
 }
 #endif
 
+static void rhine_hw_init(struct net_device *dev, long pioaddr)
+{
+	/* Reset the chip to erase previous misconfiguration. */
+	rhine_chip_reset(dev);
+
+	/* Reload EEPROM controlled bytes cleared by soft reset */
+	rhine_reload_eeprom(pioaddr, dev);
+}
+
 static int __devinit rhine_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -649,13 +678,11 @@
 	u8 pci_rev;
 	u32 quirks;
 	static int card_idx = -1;
-	long ioaddr;
+	long pioaddr;
 	long memaddr;
+	long ioaddr;
 	int io_size;
 	int phy, phy_idx = 0;
-#ifdef USE_MMIO
-	long ioaddr0;
-#endif
 	const char *name;
 
 /* when built into the kernel, we only print version if device is found */
@@ -708,7 +735,7 @@
 		goto err_out;
 	}
 
-	ioaddr = pci_resource_start(pdev, 0);
+	pioaddr = pci_resource_start(pdev, 0);
 	memaddr = pci_resource_start(pdev, 1);
 
 	pci_set_master(pdev);
@@ -728,8 +755,7 @@
 		goto err_out_free_netdev;
 
 #ifdef USE_MMIO
-	ioaddr0 = ioaddr;
-	enable_mmio(ioaddr0, quirks);
+	enable_mmio(pioaddr, quirks);
 
 	ioaddr = (long) ioremap(memaddr, io_size);
 	if (!ioaddr) {
@@ -743,7 +769,7 @@
 	i = 0;
 	while (mmio_verify_registers[i]) {
 		int reg = mmio_verify_registers[i++];
-		unsigned char a = inb(ioaddr0+reg);
+		unsigned char a = inb(pioaddr+reg);
 		unsigned char b = readb(ioaddr+reg);
 		if (a != b) {
 			rc = -EIO;
@@ -752,26 +778,18 @@
 			goto err_out_unmap;
 		}
 	}
+#else
+	ioaddr = pioaddr;
 #endif /* USE_MMIO */
+
 	dev->base_addr = ioaddr;
+	rp = netdev_priv(dev);
+	rp->quirks = quirks;
 
 	rhine_power_init(dev);
 
 	/* Reset the chip to erase previous misconfiguration. */
-	writew(CmdReset, ioaddr + ChipCmd);
-
-	wait_for_reset(dev, quirks, shortname);
-
-	/* Reload the station address from the EEPROM. */
-#ifdef USE_MMIO
-	reload_eeprom(ioaddr0);
-	/* Reloading from eeprom overwrites cfgA-D, so we must re-enable MMIO.
-	   If reload_eeprom() was done first this could be avoided, but it is
-	   not known if that still works with the "win98-reboot" problem. */
-	enable_mmio(ioaddr0, quirks);
-#else
-	reload_eeprom(ioaddr);
-#endif
+	rhine_hw_init(dev, pioaddr);
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = readb(ioaddr + StationAddr + i);
@@ -782,15 +800,6 @@
 		goto err_out_unmap;
 	}
 
-	if (quirks & rqWOL) {
-		/*
-		 * for 3065D, EEPROM reloaded will cause bit 0 in MAC_REG_CFGA
-		 * turned on. it makes MAC receive magic packet
-		 * automatically. So, we turn it off. (D-Link)
-		 */
-		writeb(readb(ioaddr + ConfigA) & 0xFE, ioaddr + ConfigA);
-	}
-
 	/* Select backoff algorithm */
 	if (backoff)
 		writeb(readb(ioaddr + ConfigD) & (0xF0 | backoff),
@@ -798,10 +807,8 @@
 
 	dev->irq = pdev->irq;
 
-	rp = netdev_priv(dev);
 	spin_lock_init(&rp->lock);
 	rp->pdev = pdev;
-	rp->quirks = quirks;
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
 	rp->mii_if.mdio_write = mdio_write;
@@ -1170,9 +1177,6 @@
 	long ioaddr = dev->base_addr;
 	int i;
 
-	/* Reset the chip. */
-	writew(CmdReset, ioaddr + ChipCmd);
-
 	i = request_irq(rp->pdev->irq, &rhine_interrupt, SA_SHIRQ, dev->name,
 			dev);
 	if (i)
@@ -1187,7 +1191,7 @@
 		return i;
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
-	wait_for_reset(dev, rp->quirks, dev->name);
+	rhine_chip_reset(dev);
 	init_registers(dev);
 	if (debug > 2)
 		printk(KERN_DEBUG "%s: Done rhine_open(), status %4.4x "
@@ -1283,9 +1287,6 @@
 
 	spin_lock(&rp->lock);
 
-	/* Reset the chip. */
-	writew(CmdReset, ioaddr + ChipCmd);
-
 	/* clear all descriptors */
 	free_tbufs(dev);
 	free_rbufs(dev);
@@ -1293,7 +1294,7 @@
 	alloc_rbufs(dev);
 
 	/* Reinitialize the hardware. */
-	wait_for_reset(dev, rp->quirks, dev->name);
+	rhine_chip_reset(dev);
 	init_registers(dev);
 
 	spin_unlock(&rp->lock);
