From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bugfixes for dgrs.c
Date: Thu, 8 Jan 2004 16:53:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108165343.7ed94da9@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update the RightSwitch dgrs.c driver for net-drivers-2.5-exp (2.6.1-rc3)
to resolve some of the outstanding cruft there.  Al may have a better/newer patch.

* Don't copy net_device structure on slave device!  This won't work
  because of state variables in structure.
* make sure and request_regions before doing i/o to the card
* use cpu_relax rather than barrier while spin waiting
* don't use dev->init to do the probing work because hard to get unwind
  correct
* Use new pci/eisa probing model, don't search the bus directly
  Beneficial side effect, don't need to keep on device list anymore.
* Be more careful about releaseing resources in error paths

Compiled and module loaded/unloaded, but don't have this hardware.

diff -Nru a/drivers/net/dgrs.c b/drivers/net/dgrs.c
--- a/drivers/net/dgrs.c	Thu Jan  8 16:44:05 2004
+++ b/drivers/net/dgrs.c	Thu Jan  8 16:44:05 2004
@@ -121,11 +121,22 @@
 #include "dgrs_asstruct.h"
 #include "dgrs_bcomm.h"
 
+#ifdef CONFIG_PCI
 static struct pci_device_id dgrs_pci_tbl[] = {
 	{ SE6_PCI_VENDOR_ID, SE6_PCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }			/* Terminating entry */
 };
 MODULE_DEVICE_TABLE(pci, dgrs_pci_tbl);
+#endif
+
+#ifdef CONFIG_EISA
+static struct eisa_device_id dgrs_eisa_tbl[] = {
+	{ "DBI0A01" },
+	{ }
+};
+MODULE_DEVICE_TABLE(eisa, dgrs_eisa_tbl);
+#endif
+
 MODULE_LICENSE("GPL");
 
 
@@ -179,11 +190,6 @@
 static int	dgrs_nicmode;
 
 /*
- *	Chain of device structures
- */
-static struct net_device *dgrs_root_dev;
-
-/*
  *	Private per-board data structure (dev->priv)
  */
 typedef struct
@@ -191,7 +197,6 @@
 	/*
 	 *	Stuff for generic ethercard I/F
 	 */
-	struct net_device		*next_dev;
 	struct net_device_stats	stats;
 
 	/*
@@ -1187,7 +1192,7 @@
 	priv->intrcnt = 0;
 	for (i = jiffies + 2*HZ + HZ/2; time_after(i, jiffies); )
 	{
-		barrier();		/* gcc 2.95 needs this */
+		cpu_relax();
 		if (priv->intrcnt >= 2)
 			break;
 	}
@@ -1200,16 +1205,6 @@
 	}
 
 	/*
-	 *	Register the /proc/ioports information...
-	 */
-	if (!request_region(dev->base_addr, 256, "RightSwitch")) {
-		printk(KERN_ERR "%s: io 0x%3lX, which is busy.\n", dev->name,
-				dev->base_addr);
-		rc = -EBUSY;
-		goto err_free_irq;
-	}
-	
-	/*
 	 *	Entry points...
 	 */
 	dev->open = &dgrs_open;
@@ -1242,22 +1237,23 @@
 	return (0);
 }
 
-static int __init 
+static struct net_device * __init 
 dgrs_found_device(
 	int		io,
 	ulong		mem,
 	int		irq,
 	ulong		plxreg,
-	ulong		plxdma
+	ulong		plxdma,
+	struct device   *pdev
 )
 {
-	DGRS_PRIV	*priv;
-	struct net_device *dev, *aux;
-	int i, ret;
+	DGRS_PRIV *priv;
+	struct net_device *dev;
+	int i, ret = -ENOMEM;
 
 	dev = alloc_etherdev(sizeof(DGRS_PRIV));
 	if (!dev)
-		return -ENOMEM;
+		goto err0;
 
 	priv = (DGRS_PRIV *)dev->priv;
 
@@ -1272,19 +1268,19 @@
 	priv->chan = 1;
 	priv->devtbl[0] = dev;
 
-	dev->init = dgrs_probe1;
 	SET_MODULE_OWNER(dev);
-
-	if (register_netdev(dev) != 0) {
-		free_netdev(dev);
-		return -EIO;
-	}
-
-	priv->next_dev = dgrs_root_dev;
-	dgrs_root_dev = dev;
+	SET_NETDEV_DEV(dev, pdev);
+	
+	ret = dgrs_probe1(dev);
+	if (ret) 
+		goto err1;
+
+	ret = register_netdev(dev);
+	if (ret)
+		goto err2;
 
 	if ( !dgrs_nicmode )
-		return (0);	/* Switch mode, we are done */
+		return dev;	/* Switch mode, we are done */
 
 	/*
 	 * Operating card as N separate NICs
@@ -1302,8 +1298,7 @@
 		if (!devN) 
 			goto fail;
 
-		/* Make it an exact copy of dev[0]... */
-		*devN = *dev;
+		/* Don't copy the network device structure! */
 
 		/* copy the priv structure of dev[0] */
 		privN = (DGRS_PRIV *)devN->priv;
@@ -1316,123 +1311,212 @@
 		devN->irq = 0;
 			/* ... and base MAC address off address of 1st port */
 		devN->dev_addr[5] += i;
-			/* ... choose a new name */
-		strncpy(devN->name, "eth%d", IFNAMSIZ);
-		devN->init = dgrs_initclone;
+
+		ret = dgrs_initclone(devN);
+		if (ret)
+			goto fail;
+
 		SET_MODULE_OWNER(devN);
+		SET_NETDEV_DEV(dev, pdev);
 
-		ret = -EIO;
-		if (register_netdev(devN)) {
+		ret = register_netdev(devN);
+		if (ret) {
 			free_netdev(devN);
 			goto fail;
 		}
 		privN->chan = i+1;
 		priv->devtbl[i] = devN;
-		privN->next_dev = dgrs_root_dev;
-		dgrs_root_dev = devN;
 	}
-	return 0;
-fail:	aux = priv->next_dev;
-	while (dgrs_root_dev != aux) {
-		struct net_device *d = dgrs_root_dev;
-		
-		dgrs_root_dev = ((DGRS_PRIV *)d->priv)->next_dev;
+	return dev;
+
+ fail:	
+	while (i >= 0) {
+		struct net_device *d = priv->devtbl[i--];
 		unregister_netdev(d);
 		free_netdev(d);
 	}
-	return ret;
+
+ err2:
+	free_irq(dev->irq, dev);
+ err1:
+	free_netdev(dev);
+ err0:
+	return ERR_PTR(ret);
 }
 
-/*
- *	Scan for all boards
- */
-static int is2iv[8] __initdata = { 0, 3, 5, 7, 10, 11, 12, 15 };
+static void __devexit dgrs_remove(struct net_device *dev)
+{
+	DGRS_PRIV *priv = dev->priv;
+	int i;
+
+	unregister_netdev(dev);
+
+	for (i = 1; i < priv->nports; ++i) {
+		struct net_device *d = priv->devtbl[i];
+		if (d) {
+			unregister_netdev(d);
+			free_netdev(d);
+		}
+	}
+
+	proc_reset(priv->devtbl[0], 1);
 
-static int __init  dgrs_scan(void)
+	if (priv->vmem)
+		iounmap(priv->vmem);
+	if (priv->vplxdma)
+		iounmap((uchar *) priv->vplxdma);
+
+	if (dev->irq)
+		free_irq(dev->irq, dev);
+
+	for (i = 1; i < priv->nports; ++i) {
+		if (priv->devtbl[i])
+			unregister_netdev(priv->devtbl[i]);
+	}
+}
+
+#ifdef CONFIG_PCI
+static int __init dgrs_pci_probe(struct pci_dev *pdev,
+				 const struct pci_device_id *ent)
 {
-	int	cards_found = 0;
+	struct net_device *dev;
+	int err;
 	uint	io;
 	uint	mem;
 	uint	irq;
 	uint	plxreg;
 	uint	plxdma;
-	struct pci_dev *pdev = NULL;
 
 	/*
-	 *	First, check for PCI boards
-	 */
-	while ((pdev = pci_find_device(SE6_PCI_VENDOR_ID, SE6_PCI_DEVICE_ID, pdev)) != NULL)
-	{
-		/*
-		 * Get and check the bus-master and latency values.
-		 * Some PCI BIOSes fail to set the master-enable bit,
-		 * and the latency timer must be set to the maximum
-		 * value to avoid data corruption that occurs when the
-		 * timer expires during a transfer.  Yes, it's a bug.
-		 */
-		if (pci_enable_device(pdev))
-			continue;
-		pci_set_master(pdev);
-
-		plxreg = pci_resource_start (pdev, 0);
-		io = pci_resource_start (pdev, 1);
-		mem = pci_resource_start (pdev, 2);
-		pci_read_config_dword(pdev, 0x30, &plxdma);
-		irq = pdev->irq;
-		plxdma &= ~15;
+	 * Get and check the bus-master and latency values.
+	 * Some PCI BIOSes fail to set the master-enable bit,
+	 * and the latency timer must be set to the maximum
+	 * value to avoid data corruption that occurs when the
+	 * timer expires during a transfer.  Yes, it's a bug.
+	 */
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
+	err = pci_request_regions(pdev, "RightSwitch");
+	if (err)
+		return err;
+
+	pci_set_master(pdev);
+
+	plxreg = pci_resource_start (pdev, 0);
+	io = pci_resource_start (pdev, 1);
+	mem = pci_resource_start (pdev, 2);
+	pci_read_config_dword(pdev, 0x30, &plxdma);
+	irq = pdev->irq;
+	plxdma &= ~15;
+
+	/*
+	 * On some BIOSES, the PLX "expansion rom" (used for DMA)
+	 * address comes up as "0".  This is probably because
+	 * the BIOS doesn't see a valid 55 AA ROM signature at
+	 * the "ROM" start and zeroes the address.  To get
+	 * around this problem the SE-6 is configured to ask
+	 * for 4 MB of space for the dual port memory.  We then
+	 * must set its range back to 2 MB, and use the upper
+	 * half for DMA register access
+	 */
+	OUTL(io + PLX_SPACE0_RANGE, 0xFFE00000L);
+	if (plxdma == 0)
+		plxdma = mem + (2048L * 1024L);
+	pci_write_config_dword(pdev, 0x30, plxdma + 1);
+	pci_read_config_dword(pdev, 0x30, &plxdma);
+	plxdma &= ~15;
+
+	dev = dgrs_found_device(io, mem, irq, plxreg, plxdma, &pdev->dev);
+	if (IS_ERR(dev)) {
+		pci_release_regions(pdev);
+		return PTR_ERR(dev);
+	}
 
-		/*
-		 * On some BIOSES, the PLX "expansion rom" (used for DMA)
-		 * address comes up as "0".  This is probably because
-		 * the BIOS doesn't see a valid 55 AA ROM signature at
-		 * the "ROM" start and zeroes the address.  To get
-		 * around this problem the SE-6 is configured to ask
-		 * for 4 MB of space for the dual port memory.  We then
-		 * must set its range back to 2 MB, and use the upper
-		 * half for DMA register access
-		 */
-		OUTL(io + PLX_SPACE0_RANGE, 0xFFE00000L);
-		if (plxdma == 0)
-			plxdma = mem + (2048L * 1024L);
-		pci_write_config_dword(pdev, 0x30, plxdma + 1);
-		pci_read_config_dword(pdev, 0x30, &plxdma);
-		plxdma &= ~15;
+	pci_set_drvdata(pdev, dev);
+	return 0;
+}
 
-		dgrs_found_device(io, mem, irq, plxreg, plxdma);
+static void __devexit dgrs_pci_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
 
-		cards_found++;
-	}
+	dgrs_remove(dev);
+	pci_release_regions(pdev);
+	free_netdev(dev);
+}
 
-	/*
-	 *	Second, check for EISA boards
-	 */
-	if (EISA_bus)
-	{
-		for (io = 0x1000; io < 0x9000; io += 0x1000)
-		{
-			if (inb(io+ES4H_MANUFmsb) != 0x10
-				|| inb(io+ES4H_MANUFlsb) != 0x49
-				|| inb(io+ES4H_PRODUCT) != ES4H_PRODUCT_CODE)
-				continue;
+static struct pci_driver dgrs_pci_driver = {
+	.name = "dgrs",
+	.id_table = dgrs_pci_tbl,
+	.probe = dgrs_pci_probe,
+	.remove = __devexit_p(dgrs_pci_remove),
+};
+#endif
+
+
+#ifdef CONFIG_EISA
+static int is2iv[8] __initdata = { 0, 3, 5, 7, 10, 11, 12, 15 };
 
-			if ( ! (inb(io+ES4H_EC) & ES4H_EC_ENABLE) )
-				continue; /* Not EISA configured */
+static int __init dgrs_eisa_probe (struct device *gendev)
+{
+	struct net_device *dev;
+	struct eisa_device *edev = to_eisa_device(gendev);
+	uint	io = edev->base_addr;
+	uint	mem;
+	uint	irq;
+	int 	rc = -ENODEV; /* Not EISA configured */
+
+	if (!request_region(io, 256, "RightSwitch")) {
+		printk(KERN_ERR "%s: io 0x%3lX, which is busy.\n", dev->name,
+				dev->base_addr);
+		return -EBUSY;
+	}
 
-			mem = (inb(io+ES4H_AS_31_24) << 24)
-				+ (inb(io+ES4H_AS_23_16) << 16);
+	if ( ! (inb(io+ES4H_EC) & ES4H_EC_ENABLE) ) 
+		goto err_out;
 
-			irq = is2iv[ inb(io+ES4H_IS) & ES4H_IS_INTMASK ];
+	mem = (inb(io+ES4H_AS_31_24) << 24)
+		+ (inb(io+ES4H_AS_23_16) << 16);
 
-			dgrs_found_device(io, mem, irq, 0L, 0L);
+	irq = is2iv[ inb(io+ES4H_IS) & ES4H_IS_INTMASK ];
 
-			++cards_found;
-		}
+	dev = dgrs_found_device(io, mem, irq, 0L, 0L, gendev);
+	if (IS_ERR(dev)) {
+		rc = PTR_ERR(dev);
+		goto err_out;
 	}
 
-	return cards_found;
+	gendev->driver_data = dev;
+	return 0;
+ err_out:
+	release_region(io, 256);
+	return rc;
+}
+
+static int __devexit dgrs_eisa_remove(struct device *gendev)
+{
+	struct net_device *dev = gendev->driver_data;
+	
+	dgrs_remove(dev);
+
+	release_region(dev->base_addr, 256);
+		
+	free_netdev(dev);
+	return 0;
 }
 
 
+static struct eisa_driver dgrs_eisa_driver = {
+	.id_table = dgrs_eisa_tbl,
+	.driver = {
+		.name = "dgrs",
+		.probe = dgrs_eisa_probe,
+		.remove = __devexit_p(dgrs_eisa_remove),
+	}
+};
+#endif
+
 /*
  *	Variables that can be overriden from module command line
  */
@@ -1459,8 +1543,8 @@
 
 static int __init dgrs_init_module (void)
 {
-	int	cards_found;
 	int	i;
+	int eisacount = 0, pcicount = 0;
 
 	/*
 	 *	Command line variable overrides
@@ -1501,38 +1585,27 @@
 	/*
 	 *	Find and configure all the cards
 	 */
-	dgrs_root_dev = NULL;
-	cards_found = dgrs_scan();
-
-	return cards_found ? 0 : -ENODEV;
+#ifdef CONFIG_EISA
+	eisacount = eisa_driver_register(&dgrs_eisa_driver);
+	if (eisacount < 0)
+		return eisacount;
+#endif
+#ifdef CONFIG_PCI
+	pcicount = pci_register_driver(&dgrs_pci_driver);
+	if (pcicount < 0)
+		return pcicount;
+#endif
+	return (eisacount + pcicount) == 0 ? -ENODEV : 0;
 }
 
 static void __exit dgrs_cleanup_module (void)
 {
-        while (dgrs_root_dev)
-	{
-		struct net_device	*next_dev;
-		DGRS_PRIV	*priv;
-
-		priv = (DGRS_PRIV *) dgrs_root_dev->priv;
-                next_dev = priv->next_dev;
-                unregister_netdev(dgrs_root_dev);
-
-		proc_reset(priv->devtbl[0], 1);
-
-		if (priv->vmem)
-			iounmap(priv->vmem);
-		if (priv->vplxdma)
-			iounmap((uchar *) priv->vplxdma);
-
-		release_region(dgrs_root_dev->base_addr, 256);
-
-		if (dgrs_root_dev->irq)
-			free_irq(dgrs_root_dev->irq, dgrs_root_dev);
-
-                free_netdev(dgrs_root_dev);
-                dgrs_root_dev = next_dev;
-        }
+#ifdef CONFIG_EISA
+	eisa_driver_unregister (&dgrs_eisa_driver);
+#endif
+#ifdef CONFIG_PCI
+	pci_unregister_driver (&dgrs_pci_driver);
+#endif
 }
 
 module_init(dgrs_init_module);
