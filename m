From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [8390] Do not use dev->name before register_netdev
Date: Sat, 13 Mar 2004 13:58:59 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313025859.GA8186@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch replaces/removes all uses of dev->name in 8390 drivers.
As it is, these drivers will do printks or allocate resources with
the name eth%d.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="devname.2"

Index: kernel-2.5/drivers/net/3c503.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/3c503.c,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 3c503.c
--- kernel-2.5/drivers/net/3c503.c	19 Feb 2004 08:54:53 -0000	1.1.1.6
+++ kernel-2.5/drivers/net/3c503.c	13 Mar 2004 00:58:56 -0000
@@ -147,6 +147,7 @@
 	release_region(dev->base_addr, EL2_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init el2_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -161,7 +162,7 @@
 	err = do_el2_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -171,6 +172,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 /* Probe for the Etherlink II card at I/O port base IOADDR,
    returning non-zero on success.  If found, set the station
@@ -182,10 +184,10 @@
     static unsigned version_printed;
     unsigned long vendor_id;
 
-    if (!request_region(ioaddr, EL2_IO_EXTENT, dev->name))
+    if (!request_region(ioaddr, EL2_IO_EXTENT, "3c503"))
 	return -EBUSY;
 
-    if (!request_region(ioaddr + 0x400, 8, dev->name)) {
+    if (!request_region(ioaddr + 0x400, 8, "3c503")) {
 	retval = -EBUSY;
 	goto out;
     }
@@ -226,11 +228,11 @@
 
     dev->base_addr = ioaddr;
 
-    printk("%s: 3c503 at i/o base %#3x, node ", dev->name, ioaddr);
+    printk("3c503 at i/o base %#3x", ioaddr);
 
-    /* Retrieve and print the ethernet address. */
+    /* Retrieve the ethernet address. */
     for (i = 0; i < 6; i++)
-	printk(" %2.2x", dev->dev_addr[i] = inb(ioaddr + i));
+	dev->dev_addr[i] = inb(ioaddr + i);
 
     /* Map the 8390 back into the window. */
     outb(ECNTRL_THIN, ioaddr + 0x406);
@@ -339,16 +341,16 @@
     dev->ethtool_ops = &netdev_ethtool_ops;
 
     if (dev->mem_start)
-	printk("%s: %s - %dkB RAM, 8kB shared mem window at %#6lx-%#6lx.\n",
-		dev->name, ei_status.name, (wordlength+1)<<3,
+	printk("3c503: %s - %dkB RAM, 8kB shared mem window at %#6lx-%#6lx.\n",
+		ei_status.name, (wordlength+1)<<3,
 		dev->mem_start, dev->mem_end-1);
 
     else
     {
 	ei_status.tx_start_page = EL2_MB1_START_PG;
 	ei_status.rx_start_page = EL2_MB1_START_PG + TX_PAGES;
-	printk("\n%s: %s, %dkB RAM, using programmed I/O (REJUMPER for SHARED MEMORY).\n",
-	       dev->name, ei_status.name, (wordlength+1)<<3);
+	printk("3c503: %s, %dkB RAM, using programmed I/O (REJUMPER for SHARED MEMORY).\n",
+	       ei_status.name, (wordlength+1)<<3);
     }
     release_region(ioaddr + 0x400, 8);
     return 0;
@@ -697,7 +699,7 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
 		if (do_el2_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_el2[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/8390.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/8390.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 8390.c
--- kernel-2.5/drivers/net/8390.c	11 Mar 2004 02:55:22 -0000	1.1.1.8
+++ kernel-2.5/drivers/net/8390.c	13 Mar 2004 00:24:28 -0000
@@ -1024,6 +1024,27 @@
 				ethdev_setup);
 }
 
+/**
+ * register_ei_netdev - register_netdev counterpart for 8390
+ *
+ * Register 8390-specific net_device.
+ */
+int register_ei_netdev(struct net_device *dev)
+{
+	int err;
+	int i;
+
+	err = register_netdev(dev);
+	if (err)
+		return err;
+
+	printk(KERN_INFO "%s: %s found at %#lx, IRQ %d,",
+		dev->name, ei_status.name, dev->base_addr, dev->irq);
+	for (i = 0; i < ETHER_ADDR_LEN; i++)
+		printk("%2.2X%s", dev->dev_addr[i], i == 5 ? ".\n" : ":");
+	return 0;
+}
+
 
 
 
Index: kernel-2.5/drivers/net/8390.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/8390.h,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 8390.h
--- kernel-2.5/drivers/net/8390.h	19 Feb 2004 08:54:54 -0000	1.1.1.6
+++ kernel-2.5/drivers/net/8390.h	12 Mar 2004 22:56:26 -0000
@@ -48,6 +48,7 @@
 {
 	return __alloc_ei_netdev(0);
 }
+extern int register_ei_netdev(struct net_device *dev);
 
 /* You have one of these per-board */
 struct ei_device {
Index: kernel-2.5/drivers/net/ac3200.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/ac3200.c,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 ac3200.c
--- kernel-2.5/drivers/net/ac3200.c	19 Feb 2004 08:54:55 -0000	1.1.1.6
+++ kernel-2.5/drivers/net/ac3200.c	13 Mar 2004 01:00:51 -0000
@@ -130,6 +130,7 @@
 		iounmap((void *)dev->mem_start);
 }
 
+#ifndef MODULE
 struct net_device * __init ac3200_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -144,7 +145,7 @@
 	err = do_ac3200_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -154,12 +155,13 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ac_probe1(int ioaddr, struct net_device *dev)
 {
 	int i, retval;
 
-	if (!request_region(ioaddr, AC_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, AC_IO_EXTENT, "ac3200"))
 		return -EBUSY;
 
 	if (inb_p(ioaddr + AC_ID_PORT) == 0xff) {
@@ -179,9 +181,9 @@
 		   inb(ioaddr + AC_ID_PORT + 2), inb(ioaddr + AC_ID_PORT + 3));
 #endif
 
-	printk("AC3200 in EISA slot %d, node", ioaddr/0x1000);
+	printk("AC3200 in EISA slot %d", ioaddr/0x1000);
 	for(i = 0; i < 6; i++)
-		printk(" %02x", dev->dev_addr[i] = inb(ioaddr + AC_SA_PROM + i));
+		dev->dev_addr[i] = inb(ioaddr + AC_SA_PROM + i);
 
 #if 0
 	/* Check the vendor ID/prefix. Redundant after checking the EISA ID */
@@ -203,7 +205,7 @@
 		printk(", assigning");
 	}
 
-	retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, ei_interrupt, 0, "ac3200", dev);
 	if (retval) {
 		printk (" nothing! Unable to get IRQ %d.\n", dev->irq);
 		goto out1;
@@ -227,8 +229,8 @@
 	dev->if_port = inb(ioaddr + AC_CONFIG) >> 6;
 	dev->mem_start = config2mem(inb(ioaddr + AC_CONFIG));
 
-	printk("%s: AC3200 at %#3x with %dkB memory at physical address %#lx.\n", 
-			dev->name, ioaddr, AC_STOP_PG/4, dev->mem_start);
+	printk("ac3200: AC3200 at %#3x with %dkB memory at physical address %#lx.\n", 
+			ioaddr, AC_STOP_PG/4, dev->mem_start);
 
 	/*
 	 *  BEWARE!! Some dain-bramaged EISA SCUs will allow you to put
@@ -395,7 +397,7 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];		/* Currently ignored by driver */
 		if (do_ac3200_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_ac32[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/apne.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/apne.c,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 apne.c
--- kernel-2.5/drivers/net/apne.c	11 Mar 2004 02:55:54 -0000	1.1.1.6
+++ kernel-2.5/drivers/net/apne.c	13 Mar 2004 00:24:37 -0000
@@ -168,7 +168,7 @@
 		return ERR_PTR(-ENODEV);
 	}
 
-	if (!request_region(IOBASE, 0x20, dev->name)) {
+	if (!request_region(IOBASE, 0x20, "apne")) {
 		free_netdev(dev);
 		return ERR_PTR(-EBUSY);
 	}
@@ -179,7 +179,7 @@
 		free_netdev(dev);
 		return ERR_PTR(err);
 	}
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (!err)
 		return dev;
 
@@ -310,15 +310,12 @@
     dev->base_addr = ioaddr;
 
     /* Install the Interrupt handler */
-    i = request_irq(IRQ_AMIGA_PORTS, apne_interrupt, SA_SHIRQ, dev->name, dev);
+    i = request_irq(IRQ_AMIGA_PORTS, apne_interrupt, SA_SHIRQ, "apne", dev);
     if (i) return i;
 
-    for(i = 0; i < ETHER_ADDR_LEN; i++) {
-	printk(" %2.2x", SA_prom[i]);
-	dev->dev_addr[i] = SA_prom[i];
-    }
+    memcpy(dev_addr, SA_prom, ETHER_ADDR_LEN);
 
-    printk("\n%s: %s found.\n", dev->name, name);
+    printk("\n");
 
     ei_status.name = name;
     ei_status.tx_start_page = start_page;
Index: kernel-2.5/drivers/net/e2100.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/e2100.c,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 e2100.c
--- kernel-2.5/drivers/net/e2100.c	19 Feb 2004 08:54:59 -0000	1.1.1.5
+++ kernel-2.5/drivers/net/e2100.c	13 Mar 2004 01:52:57 -0000
@@ -144,6 +144,7 @@
 	release_region(dev->base_addr, E21_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init e2100_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -158,7 +159,7 @@
 	err = do_e2100_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -168,6 +169,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init e21_probe1(struct net_device *dev, int ioaddr)
 {
@@ -175,7 +177,7 @@
 	unsigned char *station_addr = dev->dev_addr;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, E21_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, E21_IO_EXTENT, "e2100"))
 		return -EBUSY;
 
 	/* First check the station address for the Ctron prefix. */
@@ -205,8 +207,7 @@
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	for (i = 0; i < 6; i++)
-		printk(" %02X", station_addr[i]);
+	printk("e2100: E2100 at %#3x", ioaddr);
 
 	if (dev->irq < 2) {
 		int irqlist[] = {15,11,10,12,5,9,3,4}, i;
@@ -438,7 +439,7 @@
 		dev->mem_start = mem[this_dev];
 		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
 		if (do_e2100_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_e21[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/es3210.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/es3210.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 es3210.c
--- kernel-2.5/drivers/net/es3210.c	19 Feb 2004 08:55:00 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/es3210.c	13 Mar 2004 00:25:39 -0000
@@ -161,6 +161,7 @@
 	release_region(dev->base_addr, ES_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init es_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -175,7 +176,7 @@
 	err = do_es_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -185,6 +186,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init es_probe1(struct net_device *dev, int ioaddr)
 {
@@ -221,9 +223,9 @@
 		goto out;
 	}
 
-	printk("es3210.c: ES3210 rev. %ld at %#x, node", eisa_id>>24, ioaddr);
+	printk("es3210.c: ES3210 rev. %ld at %#x", eisa_id>>24, ioaddr);
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
-		printk(" %02x", (dev->dev_addr[i] = inb(ioaddr + ES_SA_PROM + i)));
+		dev->dev_addr[i] = inb(ioaddr + ES_SA_PROM + i);
 
 	/* Snarf the interrupt now. */
 	if (dev->irq == 0) {
@@ -434,7 +436,7 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];
 		if (do_es_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_es3210[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/hp-plus.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/hp-plus.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 hp-plus.c
--- kernel-2.5/drivers/net/hp-plus.c	19 Feb 2004 08:55:01 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/hp-plus.c	13 Mar 2004 01:57:57 -0000
@@ -142,6 +142,7 @@
 	release_region(dev->base_addr - NIC_OFFSET, HP_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init hp_plus_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -156,7 +157,7 @@
 	err = do_hpp_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -166,6 +167,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 /* Do the interesting part of the probe at a single address. */
 static int __init hpp_probe1(struct net_device *dev, int ioaddr)
@@ -176,7 +178,7 @@
 	int mem_start;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, HP_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, HP_IO_EXTENT, "hp-plus"))
 		return -EBUSY;
 
 	/* Check for the HP+ signature, 50 48 0x 53. */
@@ -189,7 +191,7 @@
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk("%s: %s at %#3x,", dev->name, name, ioaddr);
+	printk("hp-plus: %s at %#3x,", name, ioaddr);
 
 	/* Retrieve and checksum the station address. */
 	outw(MAC_Page, ioaddr + HP_PAGING);
@@ -456,7 +458,7 @@
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_hpp_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_hpp[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/hp.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/hp.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 hp.c
--- kernel-2.5/drivers/net/hp.c	19 Feb 2004 08:55:01 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/hp.c	13 Mar 2004 02:00:32 -0000
@@ -106,6 +106,7 @@
 	release_region(dev->base_addr - NIC_OFFSET, HP_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init hp_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -120,7 +121,7 @@
 	err = do_hp_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -130,6 +131,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init hp_probe1(struct net_device *dev, int ioaddr)
 {
@@ -137,7 +139,7 @@
 	const char *name;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, HP_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, HP_IO_EXTENT, "hp"))
 		return -EBUSY;
 
 	/* Check for the HP physical address, 08 00 09 xx xx xx. */
@@ -164,10 +166,10 @@
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk("%s: %s (ID %02x) at %#3x,", dev->name, name, board_id, ioaddr);
+	printk("hp: %s (ID %02x) at %#3x", name, board_id, ioaddr);
 
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
-		printk(" %2.2x", dev->dev_addr[i] = inb(ioaddr + i));
+		dev->dev_addr[i] = inb(ioaddr + i);
 
 	/* Snarf the interrupt now.  Someday this could be moved to open(). */
 	if (dev->irq < 2) {
@@ -182,7 +184,7 @@
 				outb_p(irqmap[irq] | HP_RUN, ioaddr + HP_CONFIGURE);
 				outb_p( 0x00 | HP_RUN, ioaddr + HP_CONFIGURE);
 				if (irq == probe_irq_off(cookie)		 /* It's a good IRQ line! */
-					&& request_irq (irq, ei_interrupt, 0, dev->name, dev) == 0) {
+					&& request_irq (irq, ei_interrupt, 0, "hp", dev) == 0) {
 					printk(" selecting IRQ %d.\n", irq);
 					dev->irq = *irqp;
 					break;
@@ -197,12 +199,14 @@
 	} else {
 		if (dev->irq == 2)
 			dev->irq = 9;
-		if ((retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev))) {
+		if ((retval = request_irq(dev->irq, ei_interrupt, 0, "hp", dev))) {
 			printk (" unable to get IRQ %d.\n", dev->irq);
 			goto out;
 		}
 	}
 
+	printk("\n");
+
 	/* Set the base address to point to the NIC, not the "real" base! */
 	dev->base_addr = ioaddr + NIC_OFFSET;
 	dev->open = &hp_open;
@@ -425,7 +429,7 @@
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_hp_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_hp[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/hydra.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/hydra.c,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 hydra.c
--- kernel-2.5/drivers/net/hydra.c	11 Mar 2004 02:55:27 -0000	1.1.1.5
+++ kernel-2.5/drivers/net/hydra.c	13 Mar 2004 00:32:58 -0000
@@ -123,10 +123,6 @@
 	return -EAGAIN;
     }
 
-    printk("%s: hydra at 0x%08lx, address %02x:%02x:%02x:%02x:%02x:%02x (hydra.c " HYDRA_VERSION ")\n", dev->name, z->resource.start,
-	dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
-
     ei_status.name = name;
     ei_status.tx_start_page = start_page;
     ei_status.stop_page = stop_page;
@@ -144,7 +140,7 @@
     dev->stop = &hydra_close;
     NS8390_init(dev, 0);
 
-    err = register_netdev(dev);
+    err = register_ei_netdev(dev);
     if (err) {
 	free_irq(IRQ_AMIGA_PORTS, dev);
 	free_netdev(dev);
@@ -235,6 +231,7 @@
 
 static int __init hydra_init_module(void)
 {
+    printk("hydra.c " HYDRA_VERSION "\n");
     return zorro_module_init(&hydra_driver);
 }
 
Index: kernel-2.5/drivers/net/lne390.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/lne390.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 lne390.c
--- kernel-2.5/drivers/net/lne390.c	19 Feb 2004 08:55:01 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/lne390.c	13 Mar 2004 00:33:37 -0000
@@ -112,7 +112,7 @@
 	SET_MODULE_OWNER(dev);
 
 	if (ioaddr > 0x1ff) {		/* Check a single specified location. */
-		if (!request_region(ioaddr, LNE390_IO_EXTENT, dev->name))
+		if (!request_region(ioaddr, LNE390_IO_EXTENT, "lne390"))
 			return -EBUSY;
 		ret = lne390_probe1(dev, ioaddr);
 		if (ret)
@@ -131,7 +131,7 @@
 
 	/* EISA spec allows for up to 16 slots, but 8 is typical. */
 	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000) {
-		if (!request_region(ioaddr, LNE390_IO_EXTENT, dev->name))
+		if (!request_region(ioaddr, LNE390_IO_EXTENT, "lne390"))
 			continue;
 		if (lne390_probe1(dev, ioaddr) == 0)
 			return 0;
@@ -151,6 +151,7 @@
 		iounmap((void *)dev->mem_start);
 }
 
+#ifndef MODULE
 struct net_device * __init lne390_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -165,7 +166,7 @@
 	err = do_lne390_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -175,6 +176,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init lne390_probe1(struct net_device *dev, int ioaddr)
 {
@@ -211,10 +213,9 @@
 	}
 #endif
 
-	printk("lne390.c: LNE390%X in EISA slot %d, address", 0xa+revision, ioaddr/0x1000);
+	printk("lne390.c: LNE390%X in EISA slot %d.\nlne3900.c: ", 0xa+revision, ioaddr/0x1000);
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
-		printk(" %02x", (dev->dev_addr[i] = inb(ioaddr + LNE390_SA_PROM + i)));
-	printk(".\nlne390.c: ");
+		dev->dev_addr[i] = inb(ioaddr + LNE390_SA_PROM + i);
 
 	/* Snarf the interrupt now. CFG file has them all listed as `edge' with share=NO */
 	if (dev->irq == 0) {
@@ -228,7 +229,7 @@
 	}
 	printk(" IRQ %d,", dev->irq);
 
-	if ((ret = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev))) {
+	if ((ret = request_irq(dev->irq, ei_interrupt, 0, "lne390", dev))) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
 		return ret;
 	}
@@ -429,7 +430,7 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];
 		if (do_lne390_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_lne[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/mac8390.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/mac8390.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 mac8390.c
--- kernel-2.5/drivers/net/mac8390.c	19 Feb 2004 08:55:01 -0000	1.1.1.8
+++ kernel-2.5/drivers/net/mac8390.c	13 Mar 2004 00:34:42 -0000
@@ -273,16 +273,15 @@
 		   of where its memory and registers are. */
 
 		if (nubus_get_func_dir(ndev, &dir) == -1) {
-			printk(KERN_ERR "%s: Unable to get Nubus functional"
+			printk(KERN_ERR "mac8390: Unable to get Nubus functional"
 					" directory for slot %X!\n",
-			       dev->name, ndev->board->slot);
+			       ndev->board->slot);
 			continue;
 		}
 		
 		/* Get the MAC address */
 		if ((nubus_find_rsrc(&dir, NUBUS_RESID_MAC_ADDRESS, &ent)) == -1) {
-			printk(KERN_INFO "%s: Couldn't get MAC address!\n",
-					dev->name);
+			printk(KERN_INFO "mac8390: Couldn't get MAC address!\n");
 			continue;
 		} else {
 			nubus_get_rsrc_mem(dev->dev_addr, &ent, 6);
@@ -299,9 +298,9 @@
 		if (useresources[cardtype] == 1) {
 			nubus_rewinddir(&dir);
 			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_BASEOS, &ent) == -1) {
-				printk(KERN_ERR "%s: Memory offset resource"
+				printk(KERN_ERR "mac8390: Memory offset resource"
 						" for slot %X not found!\n",
-				       dev->name, ndev->board->slot);
+				       ndev->board->slot);
 				continue;
 			}
 			nubus_get_rsrc_mem(&offset, &ent, 4);
@@ -310,10 +309,10 @@
 			dev->base_addr = dev->mem_start + 0x10000;
 			nubus_rewinddir(&dir);
 			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_LENGTH, &ent) == -1) {
-				printk(KERN_INFO "%s: Memory length resource"
+				printk(KERN_INFO "mac8390: Memory length resource"
 						 " for slot %X not found"
 						 ", probing\n",
-				       dev->name, ndev->board->slot);
+				       ndev->board->slot);
 				offset = mac8390_memsize(dev->mem_start);
 				} else {
 					nubus_get_rsrc_mem(&offset, &ent, 4);
@@ -368,7 +367,7 @@
 
 	if (!ndev)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out;
 	return dev;
@@ -515,18 +514,9 @@
 	NS8390_init(dev, 0);
 
 	/* Good, done, now spit out some messages */
-	printk(KERN_INFO "%s: %s in slot %X (type %s)\n",
-		   dev->name, ndev->board->name, ndev->board->slot, cardname[type]);
-	printk(KERN_INFO "MAC ");
-	{
-		int i;
-		for (i = 0; i < 6; i++) {
-			printk("%2.2x", dev->dev_addr[i]);
-			if (i < 5)
-				printk(":");
-		}
-	}
-	printk(" IRQ %d, shared memory at %#lx-%#lx,  %d-bit access.\n",
+	printk(KERN_INFO "%s in slot %X (type %s)\n",
+		   ndev->board->name, ndev->board->slot, cardname[type]);
+	printk(KERN_INFO "IRQ %d, shared memory at %#lx-%#lx,  %d-bit access.\n",
 		   dev->irq, dev->mem_start, dev->mem_end-1, 
 		   access_bitmode?32:16);
 	return 0;
Index: kernel-2.5/drivers/net/ne.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/ne.c,v
retrieving revision 1.1.1.7
diff -u -r1.1.1.7 ne.c
--- kernel-2.5/drivers/net/ne.c	11 Mar 2004 02:55:26 -0000	1.1.1.7
+++ kernel-2.5/drivers/net/ne.c	13 Mar 2004 00:35:03 -0000
@@ -203,6 +203,7 @@
 	release_region(dev->base_addr, NE_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -217,7 +218,7 @@
 	err = do_ne_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -227,6 +228,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ne_probe_isapnp(struct net_device *dev)
 {
@@ -284,7 +286,7 @@
 	int reg0, ret;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, NE_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, NE_IO_EXTENT, "ne"))
 		return -EBUSY;
 
 	reg0 = inb_p(ioaddr);
@@ -472,13 +474,9 @@
 
 	dev->base_addr = ioaddr;
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++) {
-		printk(" %2.2x", SA_prom[i]);
-		dev->dev_addr[i] = SA_prom[i];
-	}
+	memcpy(dev->dev_addr, SA_prom, ETHER_ADDR_LEN);
 
-	printk("\n%s: %s found at %#x, using IRQ %d.\n",
-		dev->name, name, ioaddr, dev->irq);
+	printk("\n");
 
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
@@ -791,7 +789,7 @@
 		dev->mem_end = bad[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_ne_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_ne[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/ne2.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/ne2.c,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 ne2.c
--- kernel-2.5/drivers/net/ne2.c	19 Feb 2004 08:55:02 -0000	1.1.1.5
+++ kernel-2.5/drivers/net/ne2.c	13 Mar 2004 00:35:26 -0000
@@ -284,6 +284,7 @@
 	release_region(dev->base_addr, NE_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init ne2_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -298,7 +299,7 @@
 	err = do_ne2_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -308,6 +309,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int ne2_procinfo(char *buf, int slot, struct net_device *dev)
 {
@@ -368,7 +370,7 @@
 		irq = irqs[(POS & 0x60)>>5];
 	}
 
-	if (!request_region(base_addr, NE_IO_EXTENT, dev->name))
+	if (!request_region(base_addr, NE_IO_EXTENT, "ne2"))
 		return -EBUSY;
 
 #ifdef DEBUG
@@ -470,7 +472,7 @@
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, ei_interrupt, 0, "ne2", dev);
 	if (retval) {
 		printk (" unable to get IRQ %d (irqval=%d).\n", 
 				dev->irq, retval);
@@ -479,13 +481,9 @@
 
 	dev->base_addr = base_addr;
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++) {
-		printk(" %2.2x", SA_prom[i]);
-		dev->dev_addr[i] = SA_prom[i];
-	}
+	memcpy(dev->dev_addr, SA_prom, ETHER_ADDR_LEN);
 
-	printk("\n%s: %s found at %#x, using IRQ %d.\n",
-			dev->name, name, base_addr, dev->irq);
+	printk("\n");
 
 	mca_set_adapter_procfn(slot, (MCA_ProcFn) ne2_procinfo, dev);
 
@@ -793,7 +791,7 @@
 		dev->mem_end = bad[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_ne2_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_ne[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/ne2k-pci.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/ne2k-pci.c,v
retrieving revision 1.1.1.10
diff -u -r1.1.1.10 ne2k-pci.c
--- kernel-2.5/drivers/net/ne2k-pci.c	19 Feb 2004 08:55:02 -0000	1.1.1.10
+++ kernel-2.5/drivers/net/ne2k-pci.c	13 Mar 2004 00:20:04 -0000
@@ -361,17 +361,12 @@
 	dev->ethtool_ops = &ne2k_pci_ethtool_ops;
 	NS8390_init(dev, 0);
 
-	i = register_netdev(dev);
+	memcpy(dev->dev_addr, SA_prom, 6);
+
+	i = register_ei_netdev(dev);
 	if (i)
 		goto err_out_free_netdev;
 
-	printk("%s: %s found at %#lx, IRQ %d, ",
-		   dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq);
-	for(i = 0; i < 6; i++) {
-		printk("%2.2X%s", SA_prom[i], i == 5 ? ".\n": ":");
-		dev->dev_addr[i] = SA_prom[i];
-	}
-
 	return 0;
 
 err_out_free_netdev:
Index: kernel-2.5/drivers/net/ne2k_cbus.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/ne2k_cbus.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 ne2k_cbus.c
--- kernel-2.5/drivers/net/ne2k_cbus.c	19 Feb 2004 08:55:02 -0000	1.1.1.3
+++ kernel-2.5/drivers/net/ne2k_cbus.c	13 Mar 2004 02:03:51 -0000
@@ -187,6 +187,7 @@
 	ne2k_cbus_destroy(dev);
 }
 
+#ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -201,7 +202,7 @@
 	err = do_ne_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -211,6 +212,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ne_probe_cbus(struct net_device *dev, const struct ne2k_cbus_hwinfo *hw, int ioaddr, int irq)
 {
@@ -263,7 +265,7 @@
 
 	for (rlist = hw->regionlist; rlist->range; rlist++)
 		if (!request_region(ioaddr + rlist->start,
-					rlist->range, dev->name)) {
+					rlist->range, "ne2k_cbus")) {
 			ret = -EBUSY;
 			goto err_out;
 		}
@@ -508,13 +510,10 @@
 
 	dev->base_addr = ioaddr;
 
-	for(i = 0; i < ETHER_ADDR_LEN; i++) {
-		printk(" %2.2x", SA_prom[i]);
-		dev->dev_addr[i] = SA_prom[i];
-	}
+	memcpy(dev->dev_addr, SA_prom, ETHER_ADDR_LEN);
 
-	printk("\n%s: %s found at %#x, hardware type %d(%s), using IRQ %d.\n",
-		   dev->name, name, ioaddr, hw->hwtype, hw->hwident, dev->irq);
+	printk("\nne2k_cbus: %s found at %#x, hardware type %d(%s), using IRQ %d.\n",
+		   name, ioaddr, hw->hwtype, hw->hwident, dev->irq);
 
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
@@ -847,7 +846,7 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_start = hwtype[this_dev];
 		if (do_ne_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_ne[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/ne3210.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/ne3210.c,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 ne3210.c
--- kernel-2.5/drivers/net/ne3210.c	19 Feb 2004 08:55:02 -0000	1.1.1.5
+++ kernel-2.5/drivers/net/ne3210.c	13 Mar 2004 00:47:38 -0000
@@ -111,13 +111,13 @@
 	device->driver_data = dev;
 	ioaddr = edev->base_addr;
 
-	if (!request_region(ioaddr, NE3210_IO_EXTENT, dev->name)) {
+	if (!request_region(ioaddr, NE3210_IO_EXTENT, "ne3210")) {
 		retval = -EBUSY;
 		goto out;
 	}
 
 	if (!request_region(ioaddr + NE3210_CFG1,
-			    NE3210_CFG_EXTENT, dev->name)) {
+			    NE3210_CFG_EXTENT, "ne3210")) {
 		retval = -EBUSY;
 		goto out1;
 	}
@@ -133,14 +133,14 @@
 	printk("ne3210.c: NE3210 in EISA slot %d, media: %s, addr:",
 		edev->slot, ifmap[port_index]);
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
-		printk(" %02x", (dev->dev_addr[i] = inb(ioaddr + NE3210_SA_PROM + i)));
+		dev->dev_addr[i] = inb(ioaddr + NE3210_SA_PROM + i);
 	
 
 	/* Snarf the interrupt now. CFG file has them all listed as `edge' with share=NO */
 	dev->irq = irq_map[(inb(ioaddr + NE3210_CFG2) >> 3) & 0x07];
 	printk(".\nne3210.c: using IRQ %d, ", dev->irq);
 
-	retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, ei_interrupt, 0, "ne3210", dev);
 	if (retval) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
 		goto out2;
@@ -163,7 +163,7 @@
 		}
 	}
 	
-	if (!request_mem_region (phys_mem, NE3210_STOP_PG*0x100, dev->name)) {
+	if (!request_mem_region (phys_mem, NE3210_STOP_PG*0x100, "ne3210")) {
 		printk ("ne3210.c: Unable to request shared memory at physical address %#lx\n",
 			phys_mem);
 		goto out3;
@@ -207,7 +207,7 @@
 	dev->stop = &ne3210_close;
 	dev->if_port = ifmap_val[port_index];
 
-	if ((retval = register_netdev (dev)))
+	if ((retval = register_ei_netdev (dev)))
 		goto out5;
 		
 	NS8390_init(dev, 0);
Index: kernel-2.5/drivers/net/oaknet.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/oaknet.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 oaknet.c
--- kernel-2.5/drivers/net/oaknet.c	19 Feb 2004 08:55:02 -0000	1.1.1.3
+++ kernel-2.5/drivers/net/oaknet.c	13 Mar 2004 00:50:27 -0000
@@ -164,18 +164,13 @@
 	ret = -EAGAIN;
 	if (request_irq(dev->irq, ei_interrupt, 0, name, dev)) {
 		printk("%s: unable to request interrupt %d.\n",
-		       dev->name, dev->irq);
+		       name, dev->irq);
 		goto out_region;
 	}
 
 	/* Tell the world about what and where we've found. */
 
-	printk("%s: %s at", dev->name, name);
-	for (i = 0; i < ETHER_ADDR_LEN; ++i) {
-		dev->dev_addr[i] = bip->bi_enetaddr[i];
-		printk("%c%.2x", (i ? ':' : ' '), dev->dev_addr[i]);
-	}
-	printk(", found at %#lx, using IRQ %d.\n", dev->base_addr, dev->irq);
+	memcpy(dev->dev_addr, bip->bi_enetaddr, ETHER_ADDR_LEN);
 
 	/* Set up some required driver fields and then we're done. */
 
@@ -194,7 +189,7 @@
 	dev->stop = oaknet_close;
 
 	NS8390_init(dev, FALSE);
-	ret = register_netdev(dev);
+	ret = register_ei_netdev(dev);
 	if (ret)
 		goto out_irq;
 	
Index: kernel-2.5/drivers/net/smc-mca.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/smc-mca.c,v
retrieving revision 1.1.1.7
diff -u -r1.1.1.7 smc-mca.c
--- kernel-2.5/drivers/net/smc-mca.c	19 Feb 2004 08:55:05 -0000	1.1.1.7
+++ kernel-2.5/drivers/net/smc-mca.c	13 Mar 2004 00:51:12 -0000
@@ -265,7 +265,7 @@
 		goto err_unclaim;
 	}
 
-	if (!request_region(ioaddr, ULTRA_IO_EXTENT, dev->name)) {
+	if (!request_region(ioaddr, ULTRA_IO_EXTENT, "smc-mca")) {
 		rc = -ENODEV;
 		goto err_unclaim;
 	}
@@ -276,7 +276,7 @@
 	printk(KERN_INFO "smc_mca[%d]: Parameters: %#3x,", slot + 1, ioaddr);
 
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
 	/* Switch from the station address to the alternate register set
 	 * and read the useful registers there.
@@ -327,7 +327,7 @@
 
 	NS8390_init(dev, 0);
 
-	rc = register_netdev(dev);
+	rc = register_ei_netdev(dev);
 	if (rc)
 		goto err_release_region;
 
Index: kernel-2.5/drivers/net/smc-ultra.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/smc-ultra.c,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 smc-ultra.c
--- kernel-2.5/drivers/net/smc-ultra.c	19 Feb 2004 08:55:05 -0000	1.1.1.6
+++ kernel-2.5/drivers/net/smc-ultra.c	13 Mar 2004 02:17:34 -0000
@@ -167,6 +167,7 @@
 	release_region(dev->base_addr - ULTRA_NIC_OFFSET, ULTRA_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init ultra_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -181,7 +182,7 @@
 	err = do_ultra_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -191,6 +192,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 {
@@ -204,7 +206,7 @@
 	unsigned char idreg = inb(ioaddr + 7);
 	unsigned char reg4 = inb(ioaddr + 4) & 0x7f;
 
-	if (!request_region(ioaddr, ULTRA_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, ULTRA_IO_EXTENT, "smc-ultra"))
 		return -EBUSY;
 
 	/* Check the ID nibble. */
@@ -229,10 +231,10 @@
 
 	model_name = (idreg & 0xF0) == 0x20 ? "SMC Ultra" : "SMC EtherEZ";
 
-	printk("%s: %s at %#3x,", dev->name, model_name, ioaddr);
+	printk("smc-ultra: %s at %#3x", model_name, ioaddr);
 
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
@@ -561,7 +563,7 @@
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_ultra_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_ultra[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/smc-ultra32.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/smc-ultra32.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 smc-ultra32.c
--- kernel-2.5/drivers/net/smc-ultra32.c	19 Feb 2004 08:55:05 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/smc-ultra32.c	13 Mar 2004 02:17:55 -0000
@@ -141,7 +141,7 @@
 	}
 	if (base >= 0x9000)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -163,7 +163,7 @@
 	unsigned char reg4;
 	const char *ifmap[] = {"UTP No Link", "", "UTP/AUI", "UTP/BNC"};
 
-	if (!request_region(ioaddr, ULTRA32_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, ULTRA32_IO_EXTENT, "smc-ultra32"))
 		return -EBUSY;
 
 	if (inb(ioaddr + ULTRA32_IDPORT) == 0xff ||
@@ -202,10 +202,10 @@
 
 	model_name = "SMC Ultra32";
 
-	printk("%s: %s at 0x%X,", dev->name, model_name, ioaddr);
+	printk("smc-ultra32: %s at 0x%X,", model_name, ioaddr);
 
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
Index: kernel-2.5/drivers/net/stnic.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/stnic.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 stnic.c
--- kernel-2.5/drivers/net/stnic.c	19 Feb 2004 08:55:05 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/stnic.c	13 Mar 2004 00:53:55 -0000
@@ -127,14 +127,14 @@
 
   /* Snarf the interrupt now.  There's no point in waiting since we cannot
      share and the board will usually be enabled. */
-  err = request_irq (dev->irq, ei_interrupt, 0, dev->name, dev);
+  err = request_irq (dev->irq, ei_interrupt, 0, "stnic", dev);
   if (err)  {
       printk (KERN_EMERG " unable to get IRQ %d.\n", dev->irq);
       free_netdev(dev);
       return err;
     }
 
-  ei_status.name = dev->name;
+  ei_status.name = "stnic";
   ei_status.word16 = 1;
 #ifdef __LITTLE_ENDIAN__ 
   ei_status.bigendian = 0;
@@ -152,7 +152,7 @@
 
   stnic_init (dev);
 
-  err = register_netdev(dev);
+  err = register_ei_netdev(dev);
   if (err) {
     free_irq(dev->irq, dev);
     free_netdev(dev);
Index: kernel-2.5/drivers/net/wd.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/wd.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 wd.c
--- kernel-2.5/drivers/net/wd.c	19 Feb 2004 08:55:07 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/wd.c	13 Mar 2004 02:18:23 -0000
@@ -131,6 +131,7 @@
 	release_region(dev->base_addr - WD_NIC_OFFSET, WD_IO_EXTENT);
 }
 
+#ifndef MODULE
 struct net_device * __init wd_probe(int unit)
 {
 	struct net_device *dev = alloc_ei_netdev();
@@ -145,7 +146,7 @@
 	err = do_wd_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
+	err = register_ei_netdev(dev);
 	if (err)
 		goto out1;
 	return dev;
@@ -155,6 +156,7 @@
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
+#endif
 
 static int __init wd_probe1(struct net_device *dev, int ioaddr)
 {
@@ -182,9 +184,9 @@
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(version);
 
-	printk("%s: WD80x3 at %#3x,", dev->name, ioaddr);
+	printk("wd: WD80x3 at %#3x,", ioaddr);
 	for (i = 0; i < 6; i++)
-		printk(" %2.2X", dev->dev_addr[i] = inb(ioaddr + 8 + i));
+		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
 	/* The following PureData probe code was contributed by
 	   Mike Jagdis <jaggy@purplet.demon.co.uk>. Puredata does software
@@ -300,7 +302,7 @@
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	i = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	i = request_irq(dev->irq, ei_interrupt, 0, "wd", dev);
 	if (i) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
 		return i;
@@ -512,7 +514,7 @@
 		dev->mem_start = mem[this_dev];
 		dev->mem_end = mem_end[this_dev];
 		if (do_wd_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
+			if (register_ei_netdev(dev) == 0) {
 				dev_wd[found++] = dev;
 				continue;
 			}
Index: kernel-2.5/drivers/net/zorro8390.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/zorro8390.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 zorro8390.c
--- kernel-2.5/drivers/net/zorro8390.c	11 Mar 2004 02:55:33 -0000	1.1.1.4
+++ kernel-2.5/drivers/net/zorro8390.c	13 Mar 2004 00:56:56 -0000
@@ -115,7 +115,7 @@
     if (!dev)
 	return -ENOMEM;
     SET_MODULE_OWNER(dev);
-    if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, dev->name)) {
+    if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, "zorro8390")) {
 	free_netdev(dev);
 	return -EBUSY;
     }
@@ -198,7 +198,7 @@
     dev->irq = IRQ_AMIGA_PORTS;
 
     /* Install the Interrupt handler */
-    i = request_irq(IRQ_AMIGA_PORTS, ei_interrupt, SA_SHIRQ, dev->name, dev);
+    i = request_irq(IRQ_AMIGA_PORTS, ei_interrupt, SA_SHIRQ, "zorro8390", dev);
     if (i) return i;
 
     for(i = 0; i < ETHER_ADDR_LEN; i++) {
@@ -208,11 +208,6 @@
 	dev->dev_addr[i] = SA_prom[i];
     }
 
-    printk("%s: %s at 0x%08lx, Ethernet Address "
-	   "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name, name, board,
-	   dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-	   dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
-
     ei_status.name = name;
     ei_status.tx_start_page = start_page;
     ei_status.stop_page = stop_page;
@@ -228,7 +223,7 @@
     dev->open = &zorro8390_open;
     dev->stop = &zorro8390_close;
     NS8390_init(dev, 0);
-    err = register_netdev(dev);
+    err = register_ei_netdev(dev);
     if (err)
 	free_irq(IRQ_AMIGA_PORTS, dev);
     return err;

--DocE+STaALJfprDB--
