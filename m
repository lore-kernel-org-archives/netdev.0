From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (19/42) 3c515-T10
Date: Wed, 12 Nov 2003 16:43:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130043.hAD0hSw30717@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE43-3c515
	* convert to dynamic allocation
	* fixed up device list handling

diff -Nru a/drivers/net/3c515.c b/drivers/net/3c515.c
--- a/drivers/net/3c515.c	Wed Nov 12 13:20:13 2003
+++ b/drivers/net/3c515.c	Wed Nov 12 13:20:13 2003
@@ -307,7 +307,8 @@
 
 struct corkscrew_private {
 	const char *product_name;
-	struct net_device *next_module;
+	struct list_head list;
+	struct net_device *our_dev;
 	/* The Rx and Tx rings are here to keep them quad-word-aligned. */
 	struct boom_rx_desc rx_ring[RX_RING_SIZE];
 	struct boom_tx_desc tx_ring[TX_RING_SIZE];
@@ -329,6 +330,7 @@
 		full_bus_master_tx:1, full_bus_master_rx:1,	/* Boomerang  */
 		tx_full:1;
 	spinlock_t lock;
+	struct device *dev;
 };
 
 /* The action to take with a media selection timer tick.
@@ -367,17 +369,12 @@
 
 MODULE_DEVICE_TABLE(isapnp, corkscrew_isapnp_adapters);
 
-static int corkscrew_isapnp_phys_addr[3];
-
 static int nopnp;
 #endif /* __ISAPNP__ */
 
-static int corkscrew_scan(struct net_device *dev);
-static struct net_device *corkscrew_found_device(struct net_device *dev,
-						 int ioaddr, int irq,
-						 int product_index,
-						 int options);
-static int corkscrew_probe1(struct net_device *dev);
+static struct net_device *corkscrew_scan(int unit);
+static void corkscrew_setup(struct net_device *dev, int ioaddr,
+			    struct pnp_dev *idev, int card_number);
 static int corkscrew_open(struct net_device *dev);
 static void corkscrew_timer(unsigned long arg);
 static int corkscrew_start_xmit(struct sk_buff *skb,
@@ -413,47 +410,99 @@
 #ifdef MODULE
 static int debug = -1;
 /* A list of all installed Vortex devices, for removing the driver module. */
-static struct net_device *root_corkscrew_dev;
+/* we will need locking (and refcounting) if we ever use it for more */
+static LIST_HEAD(root_corkscrew_dev);
 
 int init_module(void)
 {
-	int cards_found;
-
+	int found = 0;
 	if (debug >= 0)
 		corkscrew_debug = debug;
 	if (corkscrew_debug)
 		printk(version);
-
-	root_corkscrew_dev = NULL;
-	cards_found = corkscrew_scan(NULL);
-	return cards_found ? 0 : -ENODEV;
+	while (corkscrew_scan(-1))
+		found++;
+	return found ? 0 : -ENODEV;
 }
 
 #else
-int tc515_probe(struct net_device *dev)
+struct net_device *tc515_probe(int unit)
 {
-	int cards_found = 0;
+	struct net_device *dev = corkscrew_scan(unit);
+	static int printed;
 
-	SET_MODULE_OWNER(dev);
-
-	cards_found = corkscrew_scan(dev);
+	if (!dev)
+		return ERR_PTR(-ENODEV);
 
-	if (corkscrew_debug > 0 && cards_found)
+	if (corkscrew_debug > 0 && !printed) {
+		printed = 1;
 		printk(version);
+	}
 
-	return cards_found ? 0 : -ENODEV;
+	return dev;
 }
 #endif				/* not MODULE */
 
-static int corkscrew_scan(struct net_device *dev)
+static int check_device(unsigned ioaddr)
+{
+	int timer;
+
+	if (!request_region(ioaddr, CORKSCREW_TOTAL_SIZE, "3c515"))
+		return 0;
+	/* Check the resource configuration for a matching ioaddr. */
+	if ((inw(ioaddr + 0x2002) & 0x1f0) != (ioaddr & 0x1f0)) {
+		release_region(ioaddr, CORKSCREW_TOTAL_SIZE);
+		return 0;
+	}
+	/* Verify by reading the device ID from the EEPROM. */
+	outw(EEPROM_Read + 7, ioaddr + Wn0EepromCmd);
+	/* Pause for at least 162 us. for the read to take place. */
+	for (timer = 4; timer >= 0; timer--) {
+		udelay(162);
+		if ((inw(ioaddr + Wn0EepromCmd) & 0x0200) == 0)
+			break;
+	}
+	if (inw(ioaddr + Wn0EepromData) != 0x6d50) {
+		release_region(ioaddr, CORKSCREW_TOTAL_SIZE);
+		return 0;
+	}
+	return 1;
+}
+
+static void cleanup_card(struct net_device *dev)
+{
+	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	list_del_init(&vp->list);
+	if (dev->dma)
+		free_dma(dev->dma);
+	outw(TotalReset, dev->base_addr + EL3_CMD);
+	release_region(dev->base_addr, CORKSCREW_TOTAL_SIZE);
+	if (vp->dev)
+		pnp_device_detach(to_pnp_dev(vp->dev));
+}
+
+static struct net_device *corkscrew_scan(int unit)
 {
-	int cards_found = 0;
+	struct net_device *dev;
+	static int cards_found = 0;
 	static int ioaddr;
+	int err;
 #ifdef __ISAPNP__
 	short i;
 	static int pnp_cards;
 #endif
 
+	dev = alloc_etherdev(sizeof(struct corkscrew_private));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
+
+	SET_MODULE_OWNER(dev);
+
 #ifdef __ISAPNP__
 	if(nopnp == 1)
 		goto no_pnp;
@@ -470,7 +519,7 @@
 			if (pnp_activate_dev(idev) < 0) {
 				printk("pnp activate failed (out of resources?)\n");
 				pnp_device_detach(idev);
-				return -ENOMEM;
+				continue;
 			}
 			if (!pnp_port_valid(idev, 0) || !pnp_irq_valid(idev, 0)) {
 				pnp_device_detach(idev);
@@ -478,40 +527,22 @@
 			}
 			ioaddr = pnp_port_start(idev, 0);
 			irq = pnp_irq(idev, 0);
-			if(corkscrew_debug)
-				printk ("ISAPNP reports %s at i/o 0x%x, irq %d\n",
-					(char*) corkscrew_isapnp_adapters[i].driver_data, ioaddr, irq);
-					
-			if ((inw(ioaddr + 0x2002) & 0x1f0) != (ioaddr & 0x1f0)) {
+			if (!check_device(ioaddr)) {
 				pnp_device_detach(idev);
 				continue;
 			}
-			/* Verify by reading the device ID from the EEPROM. */
-			{
-				int timer;
-				outw(EEPROM_Read + 7, ioaddr + Wn0EepromCmd);
-				/* Pause for at least 162 us. for the read to take place. */
-				for (timer = 4; timer >= 0; timer--) {
-					udelay(162);
-					if ((inw(ioaddr + Wn0EepromCmd) & 0x0200)
-				    		== 0)
-							break;
-				}
-				if (inw(ioaddr + Wn0EepromData) != 0x6d50) {
-					pnp_device_detach(idev);
-					continue;
-				}
-			}
+			if(corkscrew_debug)
+				printk ("ISAPNP reports %s at i/o 0x%x, irq %d\n",
+					(char*) corkscrew_isapnp_adapters[i].driver_data, ioaddr, irq);
 			printk(KERN_INFO "3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
 		     		inl(ioaddr + 0x2002), inw(ioaddr + 0x2000));
 			/* irq = inw(ioaddr + 0x2002) & 15; */ /* Use the irq from isapnp */
-			corkscrew_isapnp_phys_addr[pnp_cards] = ioaddr;
-			corkscrew_found_device(dev, ioaddr, irq, CORKSCREW_ID, dev
-				       	&& dev->mem_start ? dev->
-				       	mem_start : options[cards_found]);
-			dev = 0;
+			corkscrew_setup(dev, ioaddr, idev, cards_found++);
 			pnp_cards++;
-			cards_found++;
+			err = register_netdev(dev);
+			if (!err)
+				return dev;
+			cleanup_card(dev);
 		}
 	}
 no_pnp:
@@ -519,123 +550,62 @@
 
 	/* Check all locations on the ISA bus -- evil! */
 	for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x20) {
-		int irq;
-#ifdef __ISAPNP__
-		/* Make sure this was not already picked up by isapnp */
-		if(ioaddr == corkscrew_isapnp_phys_addr[0]) continue;
-		if(ioaddr == corkscrew_isapnp_phys_addr[1]) continue;
-		if(ioaddr == corkscrew_isapnp_phys_addr[2]) continue;
-#endif /* __ISAPNP__ */
-		if (check_region(ioaddr, CORKSCREW_TOTAL_SIZE))
-			continue;
-		/* Check the resource configuration for a matching ioaddr. */
-		if ((inw(ioaddr + 0x2002) & 0x1f0) != (ioaddr & 0x1f0))
+		if (!check_device(ioaddr))
 			continue;
-		/* Verify by reading the device ID from the EEPROM. */
-		{
-			int timer;
-			outw(EEPROM_Read + 7, ioaddr + Wn0EepromCmd);
-			/* Pause for at least 162 us. for the read to take place. */
-			for (timer = 4; timer >= 0; timer--) {
-				udelay(162);
-				if ((inw(ioaddr + Wn0EepromCmd) & 0x0200)
-				    == 0)
-					break;
-			}
-			if (inw(ioaddr + Wn0EepromData) != 0x6d50)
-				continue;
-		}
+
 		printk(KERN_INFO "3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
 		     inl(ioaddr + 0x2002), inw(ioaddr + 0x2000));
-		irq = inw(ioaddr + 0x2002) & 15;
-		corkscrew_found_device(dev, ioaddr, irq, CORKSCREW_ID,
-				       dev && dev->mem_start ?  dev->mem_start :
-				         (cards_found >= MAX_UNITS ? -1 :
-						options[cards_found]));
-		dev = 0;
-		cards_found++;
+		corkscrew_setup(dev, ioaddr, NULL, cards_found++);
+		err = register_netdev(dev);
+		if (!err)
+			return dev;
+		cleanup_card(dev);
 	}
-	if (corkscrew_debug)
-		printk(KERN_INFO "%d 3c515 cards found.\n", cards_found);
-	return cards_found;
+	free_netdev(dev);
+	return NULL;
 }
 
-static struct net_device *corkscrew_found_device(struct net_device *dev,
-						 int ioaddr, int irq,
-						 int product_index,
-						 int options)
+static void corkscrew_setup(struct net_device *dev, int ioaddr,
+			    struct pnp_dev *idev, int card_number)
 {
-	struct corkscrew_private *vp;
-
-#ifdef MODULE
-	/* Allocate and fill new device structure. */
-	int dev_size = sizeof(struct corkscrew_private);
-
-	dev = alloc_etherdev(dev_size);
-	if (!dev)
-		goto err_out;
-	memset(dev, 0, dev_size);
+	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
+	unsigned int eeprom[0x40], checksum = 0;	/* EEPROM contents */
+	int i;
+	int irq;
 
-	vp = (struct corkscrew_private *) dev->priv;
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
-	dev->dma = (product_index == CORKSCREW_ID ? inw(ioaddr + 0x2000) & 7 : 0);
-	dev->init = corkscrew_probe1;
-	vp->product_name = "3c515";
-	vp->options = options;
-	if (options >= 0) {
-		vp->media_override = ((options & 7) == 2) ? 0 : options & 7;
-		vp->full_duplex = (options & 8) ? 1 : 0;
-		vp->bus_master = (options & 16) ? 1 : 0;
+	if (idev) {
+		irq = pnp_irq(idev, 0);
+		vp->dev = &idev->dev;
 	} else {
-		vp->media_override = 7;
-		vp->full_duplex = 0;
-		vp->bus_master = 0;
+		irq = inw(ioaddr + 0x2002) & 15;
 	}
-	vp->next_module = root_corkscrew_dev;
-	root_corkscrew_dev = dev;
-	SET_MODULE_OWNER(dev);
-	if (register_netdev(dev) < 0)
-		goto err_free_dev;
-#else				/* not a MODULE */
-	/* Caution: quad-word alignment required for rings! */
-	dev->priv = kmalloc(sizeof(struct corkscrew_private), GFP_KERNEL);
-	if (!dev->priv)
-		goto err_out;
-	memset(dev->priv, 0, sizeof(struct corkscrew_private));
-	dev = init_etherdev(dev, sizeof(struct corkscrew_private));
+
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
-	dev->dma = (product_index == CORKSCREW_ID ? inw(ioaddr + 0x2000) & 7 : 0);
-	vp = (struct corkscrew_private *) dev->priv;
+	dev->dma = inw(ioaddr + 0x2000) & 7;
 	vp->product_name = "3c515";
-	vp->options = options;
-	if (options >= 0) {
-		vp->media_override = ((options & 7) == 2) ? 0 : options & 7;
-		vp->full_duplex = (options & 8) ? 1 : 0;
-		vp->bus_master = (options & 16) ? 1 : 0;
+	vp->options = dev->mem_start;
+	vp->our_dev = dev;
+
+	if (!vp->options) {
+		 if (card_number >= MAX_UNITS)
+			vp->options = -1;
+		else
+			vp->options = options[card_number];
+	}
+
+	if (vp->options >= 0) {
+		vp->media_override = vp->options & 7;
+		if (vp->media_override == 2)
+			vp->media_override = 0;
+		vp->full_duplex = (vp->options & 8) ? 1 : 0;
+		vp->bus_master = (vp->options & 16) ? 1 : 0;
 	} else {
 		vp->media_override = 7;
 		vp->full_duplex = 0;
 		vp->bus_master = 0;
 	}
-
-	corkscrew_probe1(dev);
-#endif				/* MODULE */
-	return dev;
-
-err_free_dev:
-	free_netdev(dev);
-err_out:
-	return NULL;
-}
-
-static int corkscrew_probe1(struct net_device *dev)
-{
-	int ioaddr = dev->base_addr;
-	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
-	unsigned int eeprom[0x40], checksum = 0;	/* EEPROM contents */
-	int i;
+	list_add(&vp->list, &root_corkscrew_dev);
 
 	printk(KERN_INFO "%s: 3Com %s at %#3x,", dev->name, vp->product_name, ioaddr);
 
@@ -707,9 +677,6 @@
 	/* vp->full_bus_master_rx = 0; */
 	vp->full_bus_master_rx = (vp->capabilities & 0x20) ? 1 : 0;
 
-	/* We do a request_region() to register /proc/ioports info. */
-	request_region(ioaddr, CORKSCREW_TOTAL_SIZE, vp->product_name);
-
 	/* The 3c51x-specific entries in the device structure. */
 	dev->open = &corkscrew_open;
 	dev->hard_start_xmit = &corkscrew_start_xmit;
@@ -719,8 +686,6 @@
 	dev->get_stats = &corkscrew_get_stats;
 	dev->set_multicast_list = &set_rx_mode;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-
-	return 0;
 }
 
 
@@ -1608,20 +1573,16 @@
 #ifdef MODULE
 void cleanup_module(void)
 {
-	struct net_device *next_dev;
-
-	while (root_corkscrew_dev) {
-		next_dev =
-		    ((struct corkscrew_private *) root_corkscrew_dev->
-		     priv)->next_module;
-		if (root_corkscrew_dev->dma)
-			free_dma(root_corkscrew_dev->dma);
-		unregister_netdev(root_corkscrew_dev);
-		outw(TotalReset, root_corkscrew_dev->base_addr + EL3_CMD);
-		release_region(root_corkscrew_dev->base_addr,
-			       CORKSCREW_TOTAL_SIZE);
-		free_netdev(root_corkscrew_dev);
-		root_corkscrew_dev = next_dev;
+	while (!list_empty(&root_corkscrew_dev)) {
+		struct net_device *dev;
+		struct corkscrew_private *vp;
+
+		vp = list_entry(root_corkscrew_dev.next,
+				struct corkscrew_private, list);
+		dev = vp->our_dev;
+		unregister_netdev(dev);
+		cleanup_card(dev);
+		free_netdev(dev);
 	}
 }
 #endif				/* MODULE */
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Nov 12 13:20:13 2003
+++ b/drivers/net/Space.c	Wed Nov 12 13:20:13 2003
@@ -84,7 +84,7 @@
 extern int hplance_probe(struct net_device *dev);
 extern int bagetlance_probe(struct net_device *);
 extern int mvme147lance_probe(struct net_device *dev);
-extern int tc515_probe(struct net_device *dev);
+extern struct net_device *tc515_probe(int unit);
 extern struct net_device *lance_probe(int unit);
 extern int mace_probe(struct net_device *dev);
 extern int macsonic_probe(struct net_device *dev);
@@ -201,13 +201,13 @@
 #ifdef CONFIG_HP100 		/* ISA, EISA & PCI */
 	{hp100_probe, 0},
 #endif	
-#ifdef CONFIG_3C515
-	{tc515_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_3C515
+	{tc515_probe, 0},
+#endif
 #ifdef CONFIG_ULTRA 
 	{ultra_probe, 0},
 #endif
