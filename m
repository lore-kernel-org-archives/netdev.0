From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/42) eepro
Date: Wed, 12 Nov 2003 16:40:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130040.hAD0ecG29903@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch from viro: NE26-eepro
	* switched eepro to dynamic allocation
	* eepro: embedded ->priv
	* eepro: fixed clobbering on autoprobe
	* eepro: fixed IO before request_region()
	* eepro: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:24 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:24 2003
@@ -50,7 +50,7 @@
 extern int hp_probe(struct net_device *dev);
 extern int hp_plus_probe(struct net_device *dev);
 extern int express_probe(struct net_device *);
-extern int eepro_probe(struct net_device *);
+extern struct net_device *eepro_probe(int unit);
 extern int at1500_probe(struct net_device *);
 extern int at1700_probe(struct net_device *);
 extern int fmv18x_probe(struct net_device *);
@@ -253,13 +253,13 @@
 #ifdef CONFIG_EEXPRESS		/* Intel EtherExpress */
 	{express_probe, 0},
 #endif
-#ifdef CONFIG_EEXPRESS_PRO	/* Intel EtherExpress Pro/10 */
-	{eepro_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_EEXPRESS_PRO	/* Intel EtherExpress Pro/10 */
+	{eepro_probe, 0},
+#endif
 #ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
     	{ewrk3_probe, 0},
 #endif
diff -Nru a/drivers/net/eepro.c b/drivers/net/eepro.c
--- a/drivers/net/eepro.c	Tue Nov 11 09:35:24 2003
+++ b/drivers/net/eepro.c	Tue Nov 11 09:35:24 2003
@@ -302,9 +302,7 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int eepro_probe(struct net_device *dev);
-
-static int	eepro_probe1(struct net_device *dev, short ioaddr);
+static int	eepro_probe1(struct net_device *dev, int autoprobe);
 static int	eepro_open(struct net_device *dev);
 static int	eepro_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t eepro_interrupt(int irq, void *dev_id, struct pt_regs *regs);
@@ -527,10 +525,11 @@
    If dev->base_addr == 2, allocate space for the device and return success
    (detachable devices only).
    */
-int __init eepro_probe(struct net_device *dev)
+static int __init do_eepro_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;
+	int irq = dev->irq;
 
 	SET_MODULE_OWNER(dev);
 
@@ -563,24 +562,48 @@
 #endif
 
 	if (base_addr > 0x1ff)		/* Check a single specified location. */
-		return eepro_probe1(dev, base_addr);
+		return eepro_probe1(dev, 0);
 
 	else if (base_addr != 0)	/* Don't probe at all. */
 		return -ENXIO;
 
-
 	for (i = 0; eepro_portlist[i]; i++) {
-		int ioaddr = eepro_portlist[i];
-
-		if (check_region(ioaddr, EEPRO_IO_EXTENT))
-			continue;
-		if (eepro_probe1(dev, ioaddr) == 0)
+		dev->base_addr = eepro_portlist[i];
+		dev->irq = irq;
+		if (eepro_probe1(dev, 1) == 0)
 			return 0;
 	}
 
 	return -ENODEV;
 }
 
+struct net_device * __init eepro_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct eepro_local));
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
+	SET_MODULE_OWNER(dev);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	err = do_eepro_probe(dev);
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	release_region(dev->base_addr, EEPRO_IO_EXTENT);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+
 static void __init printEEPROMInfo(short ioaddr, struct net_device *dev)
 {
 	unsigned short Word;
@@ -713,83 +736,75 @@
    probes on the ISA bus.  A good device probe avoids doing writes, and
    verifies that the correct device exists and functions.  */
 
-static int __init eepro_probe1(struct net_device *dev, short ioaddr)
+static int __init eepro_probe1(struct net_device *dev, int autoprobe)
 {
 	unsigned short station_addr[6], id, counter;
-	int i, j, irqMask, retval = 0;
+	int i;
 	struct eepro_local *lp;
 	enum iftype { AUI=0, BNC=1, TPE=2 };
+	int ioaddr = dev->base_addr;
+
+	/* Grab the region so we can find another board if autoIRQ fails. */
+	if (!request_region(ioaddr, EEPRO_IO_EXTENT, dev->name)) { 
+		if (!autoprobe)
+			printk(KERN_WARNING "EEPRO: io-port 0x%04x in use \n",
+				ioaddr);
+		return -EBUSY;
+	}
 
 	/* Now, we are going to check for the signature of the
 	   ID_REG (register 2 of bank 0) */
 
-	id=inb(ioaddr + ID_REG);
+	id = inb(ioaddr + ID_REG);
 
-	if (((id) & ID_REG_MASK) != ID_REG_SIG) {
-		retval = -ENODEV;
+	if ((id & ID_REG_MASK) != ID_REG_SIG)
 		goto exit;
-	}
 
-		/* We seem to have the 82595 signature, let's
-		   play with its counter (last 2 bits of
-		   register 2 of bank 0) to be sure. */
+	/* We seem to have the 82595 signature, let's
+	   play with its counter (last 2 bits of
+	   register 2 of bank 0) to be sure. */
 
-		counter = (id & R_ROBIN_BITS);
-
-	if (((id=inb(ioaddr+ID_REG)) & R_ROBIN_BITS)!=(counter + 0x40)) {
-		retval = -ENODEV;
-		goto exit;
-	}
+	counter = id & R_ROBIN_BITS;
 
-			/* Initialize the device structure */
-			dev->priv = kmalloc(sizeof(struct eepro_local), GFP_KERNEL);
-	if (!dev->priv) {
-		retval = -ENOMEM;
+	if ((inb(ioaddr + ID_REG) & R_ROBIN_BITS) != (counter + 0x40))
 		goto exit;
-	}
-
-			memset(dev->priv, 0, sizeof(struct eepro_local));
-
-			lp = (struct eepro_local *)dev->priv;
 
-	/* default values */
-	lp->eepro = 0;
+	lp = (struct eepro_local *)dev->priv;
+	memset(lp, 0, sizeof(struct eepro_local));
 	lp->xmt_bar = XMT_BAR_PRO;
 	lp->xmt_lower_limit_reg = XMT_LOWER_LIMIT_REG_PRO;
 	lp->xmt_upper_limit_reg = XMT_UPPER_LIMIT_REG_PRO;
 	lp->eeprom_reg = EEPROM_REG_PRO;
+	spin_lock_init(&lp->lock);
 
-			/* Now, get the ethernet hardware address from
-			   the EEPROM */
-			station_addr[0] = read_eeprom(ioaddr, 2, dev);
-
-			/* FIXME - find another way to know that we've found
-			 * an Etherexpress 10
-			 */
-			if (station_addr[0] == 0x0000 ||
-			    station_addr[0] == 0xffff) {
-				lp->eepro = LAN595FX_10ISA;
+	/* Now, get the ethernet hardware address from
+	   the EEPROM */
+	station_addr[0] = read_eeprom(ioaddr, 2, dev);
+
+	/* FIXME - find another way to know that we've found
+	 * an Etherexpress 10
+	 */
+	if (station_addr[0] == 0x0000 || station_addr[0] == 0xffff) {
+		lp->eepro = LAN595FX_10ISA;
 		lp->eeprom_reg = EEPROM_REG_10;
 		lp->xmt_lower_limit_reg = XMT_LOWER_LIMIT_REG_10;
 		lp->xmt_upper_limit_reg = XMT_UPPER_LIMIT_REG_10;
 		lp->xmt_bar = XMT_BAR_10;
-				station_addr[0] = read_eeprom(ioaddr, 2, dev);
-			}
-			station_addr[1] = read_eeprom(ioaddr, 3, dev);
-			station_addr[2] = read_eeprom(ioaddr, 4, dev);
+		station_addr[0] = read_eeprom(ioaddr, 2, dev);
+	}
+	station_addr[1] = read_eeprom(ioaddr, 3, dev);
+	station_addr[2] = read_eeprom(ioaddr, 4, dev);
 
 	if (!lp->eepro) {
 		if (read_eeprom(ioaddr,7,dev)== ee_FX_INT2IRQ)
 			lp->eepro = 2;
 		else if (station_addr[2] == SA_ADDR1)
 			lp->eepro = 1;
-			}
-
-			/* Fill in the 'dev' fields. */
-			dev->base_addr = ioaddr;
+	}
 
+	/* Fill in the 'dev' fields. */
 	for (i=0; i < 6; i++)
-				dev->dev_addr[i] = ((unsigned char *) station_addr)[5-i];
+		dev->dev_addr[i] = ((unsigned char *) station_addr)[5-i];
 
 	/* RX buffer must be more than 3K and less than 29K */
 	if (dev->mem_end < 3072 || dev->mem_end > 29696)
@@ -798,65 +813,49 @@
 	/* calculate {xmt,rcv}_{lower,upper}_limit */
 	eepro_recalc(dev);
 
-
-			if (GetBit( read_eeprom(ioaddr, 5, dev),ee_BNC_TPE))
-				dev->if_port = BNC;
+	if (GetBit( read_eeprom(ioaddr, 5, dev),ee_BNC_TPE))
+		dev->if_port = BNC;
 	else
 		dev->if_port = TPE;
 
-	if ((dev->irq < 2) && (lp->eepro!=0)) {
-				i = read_eeprom(ioaddr, 1, dev);
-				irqMask = read_eeprom(ioaddr, 7, dev);
-				i &= 0x07; /* Mask off INT number */
-
-				for (j=0; ((j<16) && (i>=0)); j++) {
-					if ((irqMask & (1<<j))!=0) {
-						if (i==0) {
-							dev->irq = j;
-							break; /* found bit corresponding to irq */
-						}
-						i--; /* count bits set in irqMask */
-					}
-				}
-				if (dev->irq < 2) {
-			printk(KERN_ERR " Duh! invalid interrupt vector stored in EEPROM.\n");
-			retval = -ENODEV;
-			goto freeall;
-				} else
-			if (dev->irq==2) dev->irq = 9;
-			}
-
-			/* Grab the region so we can find another board if autoIRQ fails. */
-			if (!request_region(ioaddr, EEPRO_IO_EXTENT, dev->name)) { 
-				printk(KERN_WARNING "EEPRO: io-port 0x%04x in use \n", ioaddr);
-				goto freeall;
-			}
-			((struct eepro_local *)dev->priv)->lock = SPIN_LOCK_UNLOCKED;
-
-			dev->open               = eepro_open;
-			dev->stop               = eepro_close;
-			dev->hard_start_xmit    = eepro_send_packet;
-			dev->get_stats          = eepro_get_stats;
-			dev->set_multicast_list = &set_multicast_list;
-			dev->tx_timeout		= eepro_tx_timeout;
-			dev->watchdog_timeo	= TX_TIMEOUT;
-
-			/* Fill in the fields of the device structure with
-			   ethernet generic values */
-			ether_setup(dev);
-
+ 	if (dev->irq < 2 && lp->eepro != 0) {
+ 		/* Mask off INT number */
+ 		int count = read_eeprom(ioaddr, 1, dev) & 7;
+ 		unsigned irqMask = read_eeprom(ioaddr, 7, dev);
+ 
+ 		while (count--)
+ 			irqMask &= irqMask - 1;
+ 
+ 		count = ffs(irqMask);
+ 
+ 		if (count)
+ 			dev->irq = count - 1;
+ 
+ 		if (dev->irq < 2) {
+ 			printk(KERN_ERR " Duh! illegal interrupt vector stored in EEPROM.\n");
+ 			goto exit;
+ 		} else if (dev->irq == 2) {
+ 			dev->irq = 9;
+ 		}
+ 	}
+ 
+ 	dev->open               = eepro_open;
+ 	dev->stop               = eepro_close;
+ 	dev->hard_start_xmit    = eepro_send_packet;
+ 	dev->get_stats          = eepro_get_stats;
+ 	dev->set_multicast_list = &set_multicast_list;
+ 	dev->tx_timeout		= eepro_tx_timeout;
+ 	dev->watchdog_timeo	= TX_TIMEOUT;
+ 
 	/* print boot time info */
 	eepro_print_info(dev);
 
 	/* reset 82595 */
-			eepro_reset(ioaddr);
-
+	eepro_reset(ioaddr);
+	return 0;
 exit:
-	return retval;
-freeall:
-	kfree(dev->priv);
-	goto exit;
-
+ 	release_region(dev->base_addr, EEPRO_IO_EXTENT);
+ 	return -ENODEV;
 }
 
 /* Open/initialize the board.  This is called (in the current kernel)
@@ -1701,7 +1700,7 @@
 #ifdef MODULE
 
 #define MAX_EEPRO 8
-static struct net_device dev_eepro[MAX_EEPRO];
+static struct net_device *dev_eepro[MAX_EEPRO];
 
 static int io[MAX_EEPRO];
 static int irq[MAX_EEPRO];
@@ -1729,6 +1728,7 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int i;
 	if (io[0] == 0 && autodetect == 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA boards!\n");
@@ -1743,17 +1743,24 @@
 	}
 
 	for (i = 0; i < MAX_EEPRO; i++) {
-		struct net_device *d = &dev_eepro[n_eepro];
-		d->mem_end	= mem[i];
-		d->base_addr	= io[i];
-		d->irq		= irq[i];
-		d->init		= eepro_probe;
-
-			if (register_netdev(d) == 0)
-				n_eepro++;
-			else
-				break;
+		dev = alloc_etherdev(sizeof(struct eepro_local));
+		if (!dev)
+			break;
+
+		dev->mem_end = mem[i];
+		dev->base_addr = io[i];
+		dev->irq = irq[i];
+
+		if (do_eepro_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_eepro[n_eepro++] = dev;
+				continue;
+			}
+			release_region(dev->base_addr, EEPRO_IO_EXTENT);
 		}
+		free_netdev(dev);
+		break;
+	}
 
 	if (n_eepro)
 		printk(KERN_INFO "%s", version);
@@ -1767,15 +1774,10 @@
 	int i;
 
 	for (i=0; i<n_eepro; i++) {
-		struct net_device *d = &dev_eepro[i];
-		unregister_netdev(d);
-
-		kfree(d->priv);
-		d->priv=NULL;
-
-		/* If we don't do this, we can't re-insmod it later. */
-		release_region(d->base_addr, EEPRO_IO_EXTENT);
-
+		struct net_device *dev = dev_eepro[i];
+		unregister_netdev(dev);
+		release_region(dev->base_addr, EEPRO_IO_EXTENT);
+		free_netdev(dev);
 	}
 }
 #endif /* MODULE */
