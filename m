From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/12) Probe2 -- wavelan
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYAG30175@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Original by Al Viro (NE21-wavelan)
	* switched wavelan to dynamic allocation
	* wavelan: embedded ->priv
	* wavelan: fixed clobbering on autoprobe
	* wavelan: fixed IO before request_region()
	* wavelan: fixed resource leaks on failure exits
	* wavelan: fixed order of freeing bugs
Updated to apply agains jgarzik/net-drivers-2.5-exp


diff -urN 08-arlan/drivers/net/Space.c 09-wavelan/drivers/net/Space.c
--- 08-arlan/drivers/net/Space.c	2003-09-29 16:23:44.000000000 -0700
+++ 09-wavelan/drivers/net/Space.c	2003-09-29 16:30:02.000000000 -0700
@@ -58,7 +58,7 @@
 extern int i82596_probe(struct net_device *);
 extern int ewrk3_probe(struct net_device *);
 extern int el1_probe(struct net_device *);
-extern int wavelan_probe(struct net_device *);
+extern struct net_device *wavelan_probe(int unit);
 extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
 extern int elmc_probe(struct net_device *);
@@ -269,13 +269,13 @@
 #ifdef CONFIG_EL1		/* 3c501 */
 	{el1_probe, 0},
 #endif
-#ifdef CONFIG_WAVELAN		/* WaveLAN */
-	{wavelan_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_WAVELAN		/* WaveLAN */
+	{wavelan_probe, 0},
+#endif
 #ifdef CONFIG_ARLAN		/* Aironet */
 	{arlan_probe, 0},
 #endif
diff -urN 08-arlan/drivers/net/wireless/wavelan.c 09-wavelan/drivers/net/wireless/wavelan.c
--- 08-arlan/drivers/net/wireless/wavelan.c	2003-09-27 17:50:59.000000000 -0700
+++ 09-wavelan/drivers/net/wireless/wavelan.c	2003-09-29 16:30:09.000000000 -0700
@@ -4091,12 +4091,24 @@
  * device structure
  * (called by wavelan_probe() and via init_module()).
  */
-static int __init wavelan_config(device * dev)
+static int __init wavelan_config(device *dev, unsigned short ioaddr)
 {
-	unsigned long ioaddr = dev->base_addr;
 	u8 irq_mask;
 	int irq;
 	net_local *lp;
+	mac_addr mac;
+	int err;
+
+	if (!request_region(ioaddr, sizeof(ha_t), "wavelan"))
+		return -EADDRINUSE;
+
+	err = wv_check_ioaddr(ioaddr, mac);
+	if (err)
+		goto out;
+
+	memcpy(dev->dev_addr, mac, 6);
+
+	dev->base_addr = ioaddr;
 
 #ifdef DEBUG_CALLBACK_TRACE
 	printk(KERN_DEBUG "%s: ->wavelan_config(dev=0x%x, ioaddr=0x%lx)\n",
@@ -4136,25 +4148,18 @@
 		       "%s: wavelan_config(): could not wavelan_map_irq(%d).\n",
 		       dev->name, irq_mask);
 #endif
-		return -EAGAIN;
+		err = -EAGAIN;
+		goto out;
 	}
 
 	dev->irq = irq;
 
-	if (!request_region(ioaddr, sizeof(ha_t), "wavelan"))
-		return -EBUSY;
-
 	dev->mem_start = 0x0000;
 	dev->mem_end = 0x0000;
 	dev->if_port = 0;
 
 	/* Initialize device structures */
-	dev->priv = kmalloc(sizeof(net_local), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		release_region(ioaddr, sizeof(ha_t));
-		return -ENOMEM;
-	}
-	memset(dev->priv, 0x00, sizeof(net_local));
+	memset(dev->priv, 0, sizeof(net_local));
 	lp = (net_local *) dev->priv;
 
 	/* Back link to the device structure. */
@@ -4172,12 +4177,6 @@
 	/* Init spinlock */
 	spin_lock_init(&lp->spinlock);
 
-	/*
-	 * Fill in the fields of the device structure
-	 * with generic Ethernet values.
-	 */
-	ether_setup(dev);
-
 	SET_MODULE_OWNER(dev);
 	dev->open = wavelan_open;
 	dev->stop = wavelan_close;
@@ -4204,6 +4203,9 @@
 	printk(KERN_DEBUG "%s: <-wavelan_config()\n", dev->name);
 #endif
 	return 0;
+out:
+	release_region(ioaddr, sizeof(ha_t));
+	return err;
 }
 
 /*------------------------------------------------------------------*/
@@ -4214,19 +4216,13 @@
  * We follow the example in drivers/net/ne.c.
  * (called in "Space.c")
  */
-int __init wavelan_probe(device * dev)
+struct net_device * __init wavelan_probe(int unit)
 {
+	struct net_device *dev;
 	short base_addr;
-	mac_addr mac;		/* MAC address (check existence of WaveLAN) */
+	int def_irq;
 	int i;
-	int r;
-
-#ifdef DEBUG_CALLBACK_TRACE
-	printk(KERN_DEBUG
-	       "%s: ->wavelan_probe(dev=0x%x (base_addr=0x%x))\n",
-	       dev->name, (unsigned int) dev,
-	       (unsigned int) dev->base_addr);
-#endif
+	int r = 0;
 
 #ifdef	STRUCT_CHECK
 	if (wv_struct_check() != (char *) NULL) {
@@ -4237,8 +4233,20 @@
 	}
 #endif				/* STRUCT_CHECK */
 
-	/* Check the value of the command line parameter for base address. */
+	dev = alloc_etherdev(sizeof(net_local));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
 	base_addr = dev->base_addr;
+	def_irq = dev->irq;
+
+#ifdef DEBUG_CALLBACK_TRACE
+	printk(KERN_DEBUG
+	       "%s: ->wavelan_probe(dev=%p (base_addr=0x%x))\n",
+	       dev->name, dev, (unsigned int) dev->base_addr);
+#endif
 
 	/* Don't probe at all. */
 	if (base_addr < 0) {
@@ -4247,16 +4255,9 @@
 		       "%s: wavelan_probe(): invalid base address\n",
 		       dev->name);
 #endif
-		return -ENXIO;
-	}
-
-	/* Check a single specified location. */
-	if (base_addr > 0x100) {
-		/* Check if there is something at this base address */
-		if ((r = wv_check_ioaddr(base_addr, mac)) == 0) {
-			memcpy(dev->dev_addr, mac, 6);	/* Copy MAC address. */
-			r = wavelan_config(dev);
-		}
+		r = -ENXIO;
+	} else if (base_addr > 0x100) { /* Check a single specified location. */
+		r = wavelan_config(dev, base_addr);
 #ifdef DEBUG_CONFIG_INFO
 		if (r != 0)
 			printk(KERN_DEBUG
@@ -4267,35 +4268,33 @@
 #ifdef DEBUG_CALLBACK_TRACE
 		printk(KERN_DEBUG "%s: <-wavelan_probe()\n", dev->name);
 #endif
-		return r;
-	}
-
-	/* Scan all possible addresses of the WaveLAN hardware. */
-	for (i = 0; i < NELS(iobase); i++) {
-		/* Check whether there is something at this base address. */
-		if (wv_check_ioaddr(iobase[i], mac) == 0) {
-			dev->base_addr = iobase[i];	/* Copy base address. */
-			memcpy(dev->dev_addr, mac, 6);	/* Copy MAC address. */
-			if (wavelan_config(dev) == 0) {
+	} else { /* Scan all possible addresses of the WaveLAN hardware. */
+		for (i = 0; i < NELS(iobase); i++) {
+			dev->irq = def_irq;
+			if (wavelan_config(dev, iobase[i]) == 0) {
 #ifdef DEBUG_CALLBACK_TRACE
 				printk(KERN_DEBUG
 				       "%s: <-wavelan_probe()\n",
 				       dev->name);
 #endif
-				return 0;
+				break;
 			}
 		}
+		if (i == NELS(iobase))
+			r = -ENODEV;
 	}
-
-	/* We may have touched base_addr.  Another driver may not like it. */
-	dev->base_addr = base_addr;
-
-#ifdef DEBUG_CONFIG_INFO
-	printk(KERN_DEBUG "%s: wavelan_probe(): no device found\n",
-	       dev->name);
-#endif
-
-	return -ENODEV;
+	if (r) 
+		goto out;
+	r = register_netdev(dev);
+	if (r)
+		goto out1;
+	return dev;
+out1:
+	release_region(dev->base_addr, sizeof(ha_t));
+	wavelan_list = wavelan_list->next;
+out:
+	kfree(dev);
+	return ERR_PTR(r);
 }
 
 /****************************** MODULE ******************************/
@@ -4311,7 +4310,6 @@
  */
 int init_module(void)
 {
-	mac_addr mac;		/* MAC address (check WaveLAN existence) */
 	int ret = -EIO;		/* Return error if no cards found */
 	int i;
 
@@ -4337,38 +4335,28 @@
 	/* Loop on all possible base addresses. */
 	i = -1;
 	while ((io[++i] != 0) && (i < NELS(io))) {
-		/* Check if there is something at this base address. */
-		if (wv_check_ioaddr(io[i], mac) == 0) {
-			device *dev;
+		struct net_device *dev = alloc_etherdev(sizeof(net_local));
+		if (!dev)
+			break;
+		memcpy(dev->name, name[i], IFNAMSIZ);	/* Copy name */
+		dev->base_addr = io[i];
+		dev->irq = irq[i];
 
-			/* Create device and set basic arguments. */
-			dev =
-			    kmalloc(sizeof(struct net_device), GFP_KERNEL);
-			if (dev == NULL) {
-				ret = -ENOMEM;
-				break;
-			}
-			memset(dev, 0x00, sizeof(struct net_device));
-			memcpy(dev->name, name[i], IFNAMSIZ);	/* Copy name */
-			dev->base_addr = io[i];
-			dev->irq = irq[i];
-			dev->init = &wavelan_config;
-			memcpy(dev->dev_addr, mac, 6);	/* Copy MAC address. */
-
-			/* Try to create the device. */
+		/* Check if there is something at this base address. */
+		if (wavelan_config(dev, io[i]) == 0) {
 			if (register_netdev(dev) != 0) {
-				/* Deallocate everything. */
-				/* Note: if dev->priv is mallocated, there is no way to fail. */
-				kfree(dev);
+				release_region(dev->base_addr, sizeof(ha_t));
+				wavelan_list = wavelan_list->next;
 			} else {
-				/* If at least one device OK, we do not fail */
 				ret = 0;
+				continue;
 			}
-		}		/* if there is something at the address */
-	}			/* Loop on all addresses. */
+		}
+		kfree(dev);
+	}
 
 #ifdef DEBUG_CONFIG_ERROR
-	if (wavelan_list == (net_local *) NULL)
+	if (!wavelan_list)
 		printk(KERN_WARNING
 		       "WaveLAN init_module(): no device found\n");
 #endif
@@ -4390,7 +4378,7 @@
 #endif
 
 	/* Loop on all devices and release them. */
-	while (wavelan_list != (net_local *) NULL) {
+	while (wavelan_list) {
 		device *dev = wavelan_list->dev;
 
 #ifdef DEBUG_CONFIG_INFO
@@ -4398,18 +4386,11 @@
 		       "%s: cleanup_module(): removing device at 0x%x\n",
 		       dev->name, (unsigned int) dev);
 #endif
-
-		/* Release the ioport region. */
-		release_region(dev->base_addr, sizeof(ha_t));
-
-		/* Definitely remove the device. */
 		unregister_netdev(dev);
 
-		/* Unlink the device. */
+		release_region(dev->base_addr, sizeof(ha_t));
 		wavelan_list = wavelan_list->next;
 
-		/* Free pieces. */
-		kfree(dev->priv);
 		free_netdev(dev);
 	}
 
diff -urN 08-arlan/drivers/net/wireless/wavelan.p.h 09-wavelan/drivers/net/wireless/wavelan.p.h
--- 08-arlan/drivers/net/wireless/wavelan.p.h	2003-09-27 17:50:38.000000000 -0700
+++ 09-wavelan/drivers/net/wireless/wavelan.p.h	2003-09-29 16:30:09.000000000 -0700
@@ -656,9 +656,8 @@
 static int
 	wavelan_open(device *),		/* Open the device. */
 	wavelan_close(device *),	/* Close the device. */
-	wavelan_config(device *);	/* Configure one device. */
-extern int
-	wavelan_probe(device *);	/* See Space.c. */
+	wavelan_config(device *, unsigned short);/* Configure one device. */
+extern struct net_device *wavelan_probe(int unit);	/* See Space.c. */
 
 /**************************** VARIABLES ****************************/
 
