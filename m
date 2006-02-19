From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: Merging Skylark's IOC3 patch
Date: Sun, 19 Feb 2006 21:56:56 +0000
Message-ID: <20060219215656.GP10266@deprecation.cyrius.com>
References: <20060219211527.GA12848@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org,
	Stanislaw Skowronek <skylark@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
To: Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060219211527.GA12848@deprecation.cyrius.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

* Martin Michlmayr <tbm@cyrius.com> [2006-02-19 21:15]:
> Can you please review and/or merge Skylark's IOC3 patch from
> ftp://ftp.linux-mips.org/pub/linux/mips/people/skylark/linux-mips-2.6.14-ioc3-r26.patch.bz2
> 
> From my basic understanding I believe that this patch needs to be split up
> and submitted to different sub-system maintainers.

(netdev@vger.kernel.org, this is only a RFC for now since the main
support patch for IOC3 has not been merged yet.)


From: Stanislaw Skowronek <skylark@linux-mips.org>

[PATCH 3/5] net: Convert the SGI IOC3 Ethernet driver to use IOC3 meta driver

Convert the SGI IOC3 Ethernet driver to use the IOC3 meta driver.

Signed-off-by: Stanislaw Skowronek <skylark@linux-mips.org>
Signed-off-by: Martin Michlmayr <tbm@cyrius.com>

---

 Kconfig    |    2 
 ioc3-eth.c |  458 +++++++------------------------------------------------------
 2 files changed, 55 insertions(+), 405 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 94ad74c..66c340d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -462,7 +462,7 @@ config MIPS_AU1X00_ENET
 
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
-	depends on NET_ETHERNET && PCI && SGI_IP27
+	depends on NET_ETHERNET && SGI_IOC3
 	select CRC32
 	select MII
 	help
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 9b8295e..8fadae6 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -5,6 +5,7 @@
  *
  * Driver for SGI's IOC3 based Ethernet cards as found in the PCI card.
  *
+ * Copyright (C) 2005 Stanislaw Skowronek (port to meta-driver)
  * Copyright (C) 1999, 2000, 2001, 2003 Ralf Baechle
  * Copyright (C) 1995, 1999, 2000, 2001 by Silicon Graphics, Inc.
  *
@@ -20,15 +21,13 @@
  *  o Use prefetching for large packets.  What is a good lower limit for
  *    prefetching?
  *  o We're probably allocating a bit too much memory.
- *  o Use hardware checksums.
- *  o Convert to using a IOC3 meta driver.
  *  o Which PHYs might possibly be attached to the IOC3 in real live,
  *    which workarounds are required for them?  Do we ever have Lucent's?
  *  o For the 2.5 branch kill the mii-tool ioctls.
  */
 
 #define IOC3_NAME	"ioc3-eth"
-#define IOC3_VERSION	"2.6.3-3"
+#define IOC3_VERSION	"2.6.4-s2"
 
 #include <linux/config.h>
 #include <linux/init.h>
@@ -45,11 +44,6 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 
-#ifdef CONFIG_SERIAL_8250
-#include <linux/serial_core.h>
-#include <linux/serial_8250.h>
-#endif
-
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -61,14 +55,19 @@
 #include <asm/io.h>
 #include <asm/pgtable.h>
 #include <asm/uaccess.h>
+
+#ifdef CONFIG_SGI_IP30
+#include <asm/mach-ip30/addrs.h>
+#else
 #include <asm/sn/types.h>
 #include <asm/sn/sn0/addrs.h>
 #include <asm/sn/sn0/hubni.h>
 #include <asm/sn/sn0/hubio.h>
 #include <asm/sn/klconfig.h>
-#include <asm/sn/ioc3.h>
 #include <asm/sn/sn0/ip27.h>
+#endif
 #include <asm/pci/bridge.h>
+#include <linux/ioc3.h>
 
 /*
  * 64 RX buffers.  This is tunable in the range of 16 <= x < 512.  The
@@ -81,6 +80,7 @@
 
 /* Private per NIC data of the driver.  */
 struct ioc3_private {
+	struct ioc3_driver_data *idd;
 	struct ioc3 *regs;
 	unsigned long *rxr;		/* pointer to receiver ring */
 	struct ioc3_etxd *txr;
@@ -149,8 +149,15 @@ static inline unsigned long ioc3_map(voi
 	return vdev | (0xaUL << PCI64_ATTR_TARG_SHFT) | PCI64_ATTR_PREF |
 	       ((unsigned long)ptr & TO_PHYS_MASK);
 #else
+#ifdef CONFIG_SGI_IP30
+	vdev <<= 58;   /* Shift to PCI64_ATTR_VIRTUAL */
+
+	return vdev | (0x8UL << PCI64_ATTR_TARG_SHFT) | PCI64_ATTR_PREF |
+	       ((unsigned long)ptr & TO_PHYS_MASK);
+#else
 	return virt_to_bus(ptr);
 #endif
+#endif
 }
 
 /* BEWARE: The IOC3 documentation documents the size of rx buffers as
@@ -226,219 +233,6 @@ static inline unsigned long ioc3_map(voi
 #define ioc3_r_midr_w()		be32_to_cpu(ioc3->midr_w)
 #define ioc3_w_midr_w(v)	do { ioc3->midr_w = cpu_to_be32(v); } while (0)
 
-static inline u32 mcr_pack(u32 pulse, u32 sample)
-{
-	return (pulse << 10) | (sample << 2);
-}
-
-static int nic_wait(struct ioc3 *ioc3)
-{
-	u32 mcr;
-
-        do {
-                mcr = ioc3_r_mcr();
-        } while (!(mcr & 2));
-
-        return mcr & 1;
-}
-
-static int nic_reset(struct ioc3 *ioc3)
-{
-        int presence;
-
-	ioc3_w_mcr(mcr_pack(500, 65));
-	presence = nic_wait(ioc3);
-
-	ioc3_w_mcr(mcr_pack(0, 500));
-	nic_wait(ioc3);
-
-        return presence;
-}
-
-static inline int nic_read_bit(struct ioc3 *ioc3)
-{
-	int result;
-
-	ioc3_w_mcr(mcr_pack(6, 13));
-	result = nic_wait(ioc3);
-	ioc3_w_mcr(mcr_pack(0, 100));
-	nic_wait(ioc3);
-
-	return result;
-}
-
-static inline void nic_write_bit(struct ioc3 *ioc3, int bit)
-{
-	if (bit)
-		ioc3_w_mcr(mcr_pack(6, 110));
-	else
-		ioc3_w_mcr(mcr_pack(80, 30));
-
-	nic_wait(ioc3);
-}
-
-/*
- * Read a byte from an iButton device
- */
-static u32 nic_read_byte(struct ioc3 *ioc3)
-{
-	u32 result = 0;
-	int i;
-
-	for (i = 0; i < 8; i++)
-		result = (result >> 1) | (nic_read_bit(ioc3) << 7);
-
-	return result;
-}
-
-/*
- * Write a byte to an iButton device
- */
-static void nic_write_byte(struct ioc3 *ioc3, int byte)
-{
-	int i, bit;
-
-	for (i = 8; i; i--) {
-		bit = byte & 1;
-		byte >>= 1;
-
-		nic_write_bit(ioc3, bit);
-	}
-}
-
-static u64 nic_find(struct ioc3 *ioc3, int *last)
-{
-	int a, b, index, disc;
-	u64 address = 0;
-
-	nic_reset(ioc3);
-	/* Search ROM.  */
-	nic_write_byte(ioc3, 0xf0);
-
-	/* Algorithm from ``Book of iButton Standards''.  */
-	for (index = 0, disc = 0; index < 64; index++) {
-		a = nic_read_bit(ioc3);
-		b = nic_read_bit(ioc3);
-
-		if (a && b) {
-			printk("NIC search failed (not fatal).\n");
-			*last = 0;
-			return 0;
-		}
-
-		if (!a && !b) {
-			if (index == *last) {
-				address |= 1UL << index;
-			} else if (index > *last) {
-				address &= ~(1UL << index);
-				disc = index;
-			} else if ((address & (1UL << index)) == 0)
-				disc = index;
-			nic_write_bit(ioc3, address & (1UL << index));
-			continue;
-		} else {
-			if (a)
-				address |= 1UL << index;
-			else
-				address &= ~(1UL << index);
-			nic_write_bit(ioc3, a);
-			continue;
-		}
-	}
-
-	*last = disc;
-
-	return address;
-}
-
-static int nic_init(struct ioc3 *ioc3)
-{
-	const char *type;
-	u8 crc;
-	u8 serial[6];
-	int save = 0, i;
-
-	type = "unknown";
-
-	while (1) {
-		u64 reg;
-		reg = nic_find(ioc3, &save);
-
-		switch (reg & 0xff) {
-		case 0x91:
-			type = "DS1981U";
-			break;
-		default:
-			if (save == 0) {
-				/* Let the caller try again.  */
-				return -1;
-			}
-			continue;
-		}
-
-		nic_reset(ioc3);
-
-		/* Match ROM.  */
-		nic_write_byte(ioc3, 0x55);
-		for (i = 0; i < 8; i++)
-			nic_write_byte(ioc3, (reg >> (i << 3)) & 0xff);
-
-		reg >>= 8; /* Shift out type.  */
-		for (i = 0; i < 6; i++) {
-			serial[i] = reg & 0xff;
-			reg >>= 8;
-		}
-		crc = reg & 0xff;
-		break;
-	}
-
-	printk("Found %s NIC", type);
-	if (type != "unknown") {
-		printk (" registration number %02x:%02x:%02x:%02x:%02x:%02x,"
-			" CRC %02x", serial[0], serial[1], serial[2],
-			serial[3], serial[4], serial[5], crc);
-	}
-	printk(".\n");
-
-	return 0;
-}
-
-/*
- * Read the NIC (Number-In-a-Can) device used to store the MAC address on
- * SN0 / SN00 nodeboards and PCI cards.
- */
-static void ioc3_get_eaddr_nic(struct ioc3_private *ip)
-{
-	struct ioc3 *ioc3 = ip->regs;
-	u8 nic[14];
-	int tries = 2; /* There may be some problem with the battery?  */
-	int i;
-
-	ioc3_w_gpcr_s(1 << 21);
-
-	while (tries--) {
-		if (!nic_init(ioc3))
-			break;
-		udelay(500);
-	}
-
-	if (tries < 0) {
-		printk("Failed to read MAC address\n");
-		return;
-	}
-
-	/* Read Memory.  */
-	nic_write_byte(ioc3, 0xf0);
-	nic_write_byte(ioc3, 0x00);
-	nic_write_byte(ioc3, 0x00);
-
-	for (i = 13; i >= 0; i--)
-		nic[i] = nic_read_byte(ioc3);
-
-	for (i = 2; i < 8; i++)
-		priv_netdev(ip)->dev_addr[i - 2] = nic[i];
-}
-
 /*
  * Ok, this is hosed by design.  It's necessary to know what machine the
  * NIC is in in order to know how to read the NIC address.  We also have
@@ -446,12 +240,16 @@ static void ioc3_get_eaddr_nic(struct io
  */
 static void ioc3_get_eaddr(struct ioc3_private *ip)
 {
-	int i;
+	int i,nz=0;
 
-
-	ioc3_get_eaddr_nic(ip);
+	for(i=0;i<6;i++)
+		nz |= (priv_netdev(ip)->dev_addr[i] = ip->idd->nic_mac[i]);
 
 	printk("Ethernet address is ");
+	if(!nz) {
+		printk("unreadable.\n");
+		return;
+	}
 	for (i = 0; i < 6; i++) {
 		printk("%02x", priv_netdev(ip)->dev_addr[i]);
 		if (i < 5)
@@ -750,9 +548,9 @@ static void ioc3_error(struct ioc3_priva
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread.  */
-static irqreturn_t ioc3_interrupt(int irq, void *_dev, struct pt_regs *regs)
+static int ioc3eth_intr(struct ioc3_submodule *is, struct ioc3_driver_data *idd, unsigned int irq, struct pt_regs *regs)
 {
-	struct net_device *dev = (struct net_device *)_dev;
+	struct net_device *dev = (struct net_device *)(idd->data[is->id]);
 	struct ioc3_private *ip = netdev_priv(dev);
 	struct ioc3 *ioc3 = ip->regs;
 	const u32 enabled = EISR_RXTIMERINT | EISR_RXOFLO | EISR_RXBUFOFLO |
@@ -773,7 +571,7 @@ static irqreturn_t ioc3_interrupt(int ir
 	if (eisr & EISR_TXEXPLICIT)
 		ioc3_tx(ip);
 
-	return IRQ_HANDLED;
+	return 0;
 }
 
 static inline void ioc3_setup_duplex(struct ioc3_private *ip)
@@ -840,6 +638,7 @@ static int ioc3_mii_init(struct ioc3_pri
 	ip->ioc3_timer.expires = jiffies + (12 * HZ)/10;  /* 1.2 sec. */
 	ip->ioc3_timer.data = (unsigned long) ip;
 	ip->ioc3_timer.function = &ioc3_timer;
+
 	add_timer(&ip->ioc3_timer);
 
 out:
@@ -1026,7 +825,7 @@ static void ioc3_init(struct net_device 
 	(void) ioc3_r_emcr();
 
 	/* Misc registers  */
-#ifdef CONFIG_SGI_IP27
+#if (defined CONFIG_SGI_IP27) || (defined CONFIG_SGI_IP30)
 	ioc3_w_erbar(PCI64_ATTR_BAR >> 32);	/* Barrier on last store */
 #else
 	ioc3_w_erbar(0);			/* Let PCI API get it right */
@@ -1063,12 +862,6 @@ static int ioc3_open(struct net_device *
 {
 	struct ioc3_private *ip = netdev_priv(dev);
 
-	if (request_irq(dev->irq, ioc3_interrupt, SA_SHIRQ, ioc3_str, dev)) {
-		printk(KERN_ERR "%s: Can't get irq %d\n", dev->name, dev->irq);
-
-		return -EAGAIN;
-	}
-
 	ip->ehar_h = 0;
 	ip->ehar_l = 0;
 	ioc3_init(dev);
@@ -1086,105 +879,12 @@ static int ioc3_close(struct net_device 
 	netif_stop_queue(dev);
 
 	ioc3_stop(ip);
-	free_irq(dev->irq, dev);
 
 	ioc3_free_rings(ip);
 	return 0;
 }
 
-/*
- * MENET cards have four IOC3 chips, which are attached to two sets of
- * PCI slot resources each: the primary connections are on slots
- * 0..3 and the secondaries are on 4..7
- *
- * All four ethernets are brought out to connectors; six serial ports
- * (a pair from each of the first three IOC3s) are brought out to
- * MiniDINs; all other subdevices are left swinging in the wind, leave
- * them disabled.
- */
-static inline int ioc3_is_menet(struct pci_dev *pdev)
-{
-	struct pci_dev *dev;
-
-	return pdev->bus->parent == NULL
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(0, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(1, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(2, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3;
-}
-
-#ifdef CONFIG_SERIAL_8250
-/*
- * Note about serial ports and consoles:
- * For console output, everyone uses the IOC3 UARTA (offset 0x178)
- * connected to the master node (look in ip27_setup_console() and
- * ip27prom_console_write()).
- *
- * For serial (/dev/ttyS0 etc), we can not have hardcoded serial port
- * addresses on a partitioned machine. Since we currently use the ioc3
- * serial ports, we use dynamic serial port discovery that the serial.c
- * driver uses for pci/pnp ports (there is an entry for the SGI ioc3
- * boards in pci_boards[]). Unfortunately, UARTA's pio address is greater
- * than UARTB's, although UARTA on o200s has traditionally been known as
- * port 0. So, we just use one serial port from each ioc3 (since the
- * serial driver adds addresses to get to higher ports).
- *
- * The first one to do a register_console becomes the preferred console
- * (if there is no kernel command line console= directive). /dev/console
- * (ie 5, 1) is then "aliased" into the device number returned by the
- * "device" routine referred to in this console structure
- * (ip27prom_console_dev).
- *
- * Also look in ip27-pci.c:pci_fixup_ioc3() for some comments on working
- * around ioc3 oddities in this respect.
- *
- * The IOC3 serials use a 22MHz clock rate with an additional divider by 3.
- */
-
-static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
-{
-	struct uart_port port;
-
-	/*
-	 * We need to recognice and treat the fourth MENET serial as it
-	 * does not have an SuperIO chip attached to it, therefore attempting
-	 * to access it will result in bus errors.  We call something an
-	 * MENET if PCI slot 0, 1, 2 and 3 of a master PCI bus all have an IOC3
-	 * in it.  This is paranoid but we want to avoid blowing up on a
-	 * showhorn PCI box that happens to have 4 IOC3 cards in it so it's
-	 * not paranoid enough ...
-	 */
-	if (ioc3_is_menet(pdev) && PCI_SLOT(pdev->devfn) == 3)
-		return;
-
-	/*
-	 * Register to interrupt zero because we share the interrupt with
-	 * the serial driver which we don't properly support yet.
-	 *
-	 * Can't use UPF_IOREMAP as the whole of IOC3 resources have already
-	 * been registered.
-	 */
-	memset(&port, 0, sizeof(port));
-	port.irq      = 0;
-	port.flags    = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF;
-	port.iotype   = UPIO_MEM;
-	port.regshift = 0;
-	port.uartclk  = 22000000 / 3;
-
-	port.membase  = (unsigned char *) &ioc3->sregs.uarta;
-	serial8250_register_port(&port);
-
-	port.membase  = (unsigned char *) &ioc3->sregs.uartb;
-	serial8250_register_port(&port);
-}
-#endif
-
-static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int ioc3eth_probe(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 {
 	unsigned int sw_physid1, sw_physid2;
 	struct net_device *dev = NULL;
@@ -1194,63 +894,29 @@ static int ioc3_probe(struct pci_dev *pd
 	u32 vendor, model, rev;
 	int err, pci_using_dac;
 
-	/* Configure DMA attributes. */
-	err = pci_set_dma_mask(pdev, 0xffffffffffffffffULL);
-	if (!err) {
-		pci_using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL);
-		if (err < 0) {
-			printk(KERN_ERR "%s: Unable to obtain 64 bit DMA "
-			       "for consistent allocations\n", pci_name(pdev));
-			goto out;
-		}
-	} else {
-		err = pci_set_dma_mask(pdev, 0xffffffffULL);
-		if (err) {
-			printk(KERN_ERR "%s: No usable DMA configuration, "
-			       "aborting.\n", pci_name(pdev));
-			goto out;
-		}
-		pci_using_dac = 0;
-	}
-
-	if (pci_enable_device(pdev))
-		return -ENODEV;
+	/* check for board type */
+	if(idd->class == IOC3_CLASS_SERIAL)
+		return 1;
 
 	dev = alloc_etherdev(sizeof(struct ioc3_private));
 	if (!dev) {
 		err = -ENOMEM;
 		goto out_disable;
 	}
+	idd->data[is->id] = dev;
 
-	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
-
-	err = pci_request_regions(pdev, "ioc3");
-	if (err)
-		goto out_free;
+	/* assume we always have DAC */
+	dev->features |= NETIF_F_HIGHDMA;
 
 	SET_MODULE_OWNER(dev);
-	SET_NETDEV_DEV(dev, &pdev->dev);
+	SET_NETDEV_DEV(dev, &(idd->pdev->dev));
 
 	ip = netdev_priv(dev);
 
-	dev->irq = pdev->irq;
+	dev->irq = idd->pdev->irq;
 
-	ioc3_base = pci_resource_start(pdev, 0);
-	ioc3_size = pci_resource_len(pdev, 0);
-	ioc3 = (struct ioc3 *) ioremap(ioc3_base, ioc3_size);
-	if (!ioc3) {
-		printk(KERN_CRIT "ioc3eth(%s): ioremap failed, goodbye.\n",
-		       pci_name(pdev));
-		err = -ENOMEM;
-		goto out_res;
-	}
-	ip->regs = ioc3;
-
-#ifdef CONFIG_SERIAL_8250
-	ioc3_serial_probe(pdev, ioc3);
-#endif
+	ip->idd = idd;
+	ip->regs = ioc3 = idd->vma;
 
 	spin_lock_init(&ip->ioc3_lock);
 	init_timer(&ip->ioc3_timer);
@@ -1258,7 +924,7 @@ static int ioc3_probe(struct pci_dev *pd
 	ioc3_stop(ip);
 	ioc3_init(dev);
 
-	ip->pdev = pdev;
+	ip->pdev = idd->pdev;
 
 	ip->mii.phy_id_mask = 0x1f;
 	ip->mii.reg_num_mask = 0x1f;
@@ -1270,7 +936,7 @@ static int ioc3_probe(struct pci_dev *pd
 
 	if (ip->mii.phy_id == -1) {
 		printk(KERN_CRIT "ioc3-eth(%s): Didn't find a PHY, goodbye.\n",
-		       pci_name(pdev));
+		       pci_name(idd->pdev));
 		err = -ENODEV;
 		goto out_stop;
 	}
@@ -1316,56 +982,40 @@ static int ioc3_probe(struct pci_dev *pd
 out_stop:
 	ioc3_stop(ip);
 	ioc3_free_rings(ip);
-out_res:
-	pci_release_regions(pdev);
-out_free:
 	free_netdev(dev);
 out_disable:
-	/*
-	 * We should call pci_disable_device(pdev); here if the IOC3 wasn't
-	 * such a weird device ...
-	 */
 out:
 	return err;
 }
 
-static void __devexit ioc3_remove_one (struct pci_dev *pdev)
+static int ioc3eth_remove(struct ioc3_submodule *is, struct ioc3_driver_data *idd)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = idd->data[is->id];
 	struct ioc3_private *ip = netdev_priv(dev);
-	struct ioc3 *ioc3 = ip->regs;
 
 	unregister_netdev(dev);
-	iounmap(ioc3);
-	pci_release_regions(pdev);
 	free_netdev(dev);
-	/*
-	 * We should call pci_disable_device(pdev); here if the IOC3 wasn't
-	 * such a weird device ...
-	 */
+	return 0;
 }
 
-static struct pci_device_id ioc3_pci_tbl[] = {
-	{ PCI_VENDOR_ID_SGI, PCI_DEVICE_ID_SGI_IOC3, PCI_ANY_ID, PCI_ANY_ID },
-	{ 0 }
-};
-MODULE_DEVICE_TABLE(pci, ioc3_pci_tbl);
-
-static struct pci_driver ioc3_driver = {
-	.name		= "ioc3-eth",
-	.id_table	= ioc3_pci_tbl,
-	.probe		= ioc3_probe,
-	.remove		= __devexit_p(ioc3_remove_one),
+static struct ioc3_submodule ioc3eth_submodule = {
+	.name = "ethernet",
+	.probe = ioc3eth_probe,
+	.remove = ioc3eth_remove,
+	.ethernet = 1,
+	.intr = ioc3eth_intr,
+	.owner = THIS_MODULE,
 };
 
 static int __init ioc3_init_module(void)
 {
-	return pci_register_driver(&ioc3_driver);
+	ioc3_register_submodule(&ioc3eth_submodule);
+	return 0;
 }
 
 static void __exit ioc3_cleanup_module(void)
 {
-	pci_unregister_driver(&ioc3_driver);
+	ioc3_unregister_submodule(&ioc3eth_submodule);
 }
 
 static int ioc3_start_xmit(struct sk_buff *skb, struct net_device *dev)

-- 
Martin Michlmayr
http://www.cyrius.com/
