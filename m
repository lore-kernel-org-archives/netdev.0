From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] switch sb1000 to new style net init & pnp
Date: Sat, 10 May 2003 12:47:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030510124710.A16201@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This cleans up the driver big time and gets rid of a big ugly wart
in setup.c.  Note that I don't have the hardware so this is only
compile-tested.


--- 1.25/drivers/net/Kconfig	Mon Apr 28 00:05:07 2003
+++ edited/drivers/net/Kconfig	Sat May 10 07:07:56 2003
@@ -158,7 +158,7 @@
 
 config NET_SB1000
 	tristate "General Instruments Surfboard 1000"
-	depends on NETDEVICES && ISAPNP
+	depends on NETDEVICES && PNP
 	---help---
 	  This is a driver for the General Instrument (also known as
 	  NextLevel) SURFboard 1000 internal
--- 1.16/drivers/net/sb1000.c	Sun Apr 27 23:36:20 2003
+++ edited/drivers/net/sb1000.c	Sat May 10 07:34:43 2003
@@ -49,7 +49,7 @@
 #include <linux/skbuff.h>
 #include <linux/delay.h>	/* for udelay() */
 #include <linux/etherdevice.h>
-#include <linux/isapnp.h>
+#include <linux/pnp.h>
 
 #include <asm/bitops.h>
 #include <asm/io.h>
@@ -131,146 +131,122 @@
 static inline int sb1000_rx(struct net_device *dev);
 static inline void sb1000_error_dpc(struct net_device *dev);
 
-static struct isapnp_device_id id_table[] = {
-	{	ISAPNP_ANY_ID, ISAPNP_ANY_ID,
-		ISAPNP_VENDOR('G','I','C'), ISAPNP_FUNCTION(0x1000), 0 },
-	{0}
+static const struct pnp_device_id sb1000_pnp_ids[] = {
+	{ "GIC1000", 0 },
+	{ "", 0 }
 };
+MODULE_DEVICE_TABLE(pnp, sb1000_pnp_ids);
 
-MODULE_DEVICE_TABLE(isapnp, id_table);
-
-/* probe for SB1000 using Plug-n-Play mechanism */
-int
-sb1000_probe(struct net_device *dev)
+static void
+sb1000_setup(struct net_device *dev)
 {
+	dev->type		= ARPHRD_ETHER;
+	dev->mtu		= 1500;
+	dev->addr_len		= ETH_ALEN;
+
+	/* New-style flags. */
+	dev->flags		= IFF_POINTOPOINT|IFF_NOARP;
+}
 
+static int
+sb1000_probe_one(struct pnp_dev *pdev, const struct pnp_device_id *id)
+{
+	struct net_device *dev;
 	unsigned short ioaddr[2], irq;
-	struct pnp_dev *idev=NULL;
 	unsigned int serial_number;
+	int error = -ENODEV;
 	
-	while(1)
-	{
-		/*
-		 *	Find the card
-		 */
-		 
-		idev=pnp_find_dev(NULL, ISAPNP_VENDOR('G','I','C'),
-			ISAPNP_FUNCTION(0x1000), idev);
-			
-		/*
-		 *	No card
-		 */
-		 
-		if(idev==NULL || idev->card == NULL)
-			return -ENODEV;
-			
-		/*
-		 *	Bring it online
-		 */
-		 
-		if (pnp_device_attach(idev) < 0)
-			continue;
-		if (pnp_activate_dev(idev) < 0) {
-		      __again:
-			pnp_device_detach(idev);
-			continue;
-		}
-		
-		/*
-		 *	Ports free ?
-		 */
-		 
-		if(!pnp_port_valid(idev, 0) || !pnp_port_valid(idev, 1) || !pnp_irq_valid(idev, 0))
-			goto __again;
+	if (pnp_device_attach(pdev) < 0)
+		return -ENODEV;
+	if (pnp_activate_dev(pdev) < 0)
+		goto out_detach;
+
+	if (!pnp_port_valid(pdev, 0) || !pnp_port_valid(pdev, 1))
+		goto out_disable;
+	if (!pnp_irq_valid(pdev, 0))
+		goto out_disable;
 		
-		serial_number = idev->card->serial;
+	serial_number = pdev->card->serial;
 		
-		ioaddr[0]=pnp_port_start(idev, 0);
-		ioaddr[1]=pnp_port_start(idev, 0);
+	ioaddr[0] = pnp_port_start(pdev, 0);
+	ioaddr[1] = pnp_port_start(pdev, 0);
 		
-		irq = pnp_irq(idev, 0);
+	irq = pnp_irq(pdev, 0);
 
-		/* check I/O base and IRQ */
-		if (dev->base_addr != 0 && dev->base_addr != ioaddr[0])
-			goto __again;
-		if (dev->mem_start != 0 && dev->mem_start != ioaddr[1])
-			goto __again;
-		if (dev->irq != 0 && dev->irq != irq)
-			goto __again;
-			
-		/*
-		 *	Ok set it up.
-		 */
-		if (!request_region(ioaddr[0], 16, dev->name))
-			goto __again;
-		if (!request_region(ioaddr[1], 16, dev->name)) {
-			release_region(ioaddr[0], 16);
-			goto __again;
-		}
+	if (!request_region(ioaddr[0], 16, dev->name))
+		goto out_disable;
+	if (!request_region(ioaddr[1], 16, dev->name))
+		goto out_release_region0;
 		 
-		dev->base_addr = ioaddr[0];
-		/* mem_start holds the second I/O address */
-		dev->mem_start = ioaddr[1];
-		dev->irq = irq;
-
-		if (sb1000_debug > 0)
-			printk(KERN_NOTICE "%s: sb1000 at (%#3.3lx,%#3.3lx), "
-				"S/N %#8.8x, IRQ %d.\n", dev->name, dev->base_addr,
-				dev->mem_start, serial_number, dev->irq);
-
-		dev = init_etherdev(dev, 0);
-		if (!dev) {
-			pnp_device_detach(idev);
-			release_region(ioaddr[1], 16);
-			release_region(ioaddr[0], 16);
-			return -ENOMEM;
-		}
-		SET_MODULE_OWNER(dev);
-
-		/* Make up a SB1000-specific-data structure. */
-		dev->priv = kmalloc(sizeof(struct sb1000_private), GFP_KERNEL);
-		if (dev->priv == NULL)
-			return -ENOMEM;
-		memset(dev->priv, 0, sizeof(struct sb1000_private));
-
-		if (sb1000_debug > 0)
-			printk(KERN_NOTICE "%s", version);
-
-		/* The SB1000-specific entries in the device structure. */
-		dev->open = sb1000_open;
-		dev->do_ioctl = sb1000_dev_ioctl;
-		dev->hard_start_xmit = sb1000_start_xmit;
-		dev->stop = sb1000_close;
-		dev->get_stats = sb1000_stats;
-
-		/* Fill in the generic fields of the device structure. */
-		dev->change_mtu		= NULL;
-		dev->hard_header	= NULL;
-		dev->rebuild_header 	= NULL;
-		dev->set_mac_address 	= NULL;
-		dev->header_cache_update= NULL;
-
-		dev->type		= ARPHRD_ETHER;
-		dev->hard_header_len 	= 0;
-		dev->mtu		= 1500;
-		dev->addr_len		= ETH_ALEN;
-		/* hardware address is 0:0:serial_number */
-		dev->dev_addr[0] = 0;
-		dev->dev_addr[1] = 0;
-		dev->dev_addr[2] = serial_number >> 24 & 0xff;
-		dev->dev_addr[3] = serial_number >> 16 & 0xff;
-		dev->dev_addr[4] = serial_number >>  8 & 0xff;
-		dev->dev_addr[5] = serial_number >>  0 & 0xff;
-		dev->tx_queue_len	= 0;
-	
-		/* New-style flags. */
-		dev->flags		= IFF_POINTOPOINT|IFF_NOARP;
+	dev->base_addr = ioaddr[0];
+	/* mem_start holds the second I/O address */
+	dev->mem_start = ioaddr[1];
+	dev->irq = irq;
 
-		/* Lock resources */
+	if (sb1000_debug > 0)
+		printk(KERN_NOTICE "%s: sb1000 at (%#3.3lx,%#3.3lx), "
+			"S/N %#8.8x, IRQ %d.\n", dev->name, dev->base_addr,
+			dev->mem_start, serial_number, dev->irq);
+
+	dev = alloc_netdev(sizeof(struct sb1000_private), "cm%d", sb1000_setup);
+	if (!dev) {
+		error = -ENOMEM;
+		goto out_release_regions;
+	}
+	SET_MODULE_OWNER(dev);
+
+	if (sb1000_debug > 0)
+		printk(KERN_NOTICE "%s", version);
+
+	/* The SB1000-specific entries in the device structure. */
+	dev->open		= sb1000_open;
+	dev->do_ioctl		= sb1000_dev_ioctl;
+	dev->hard_start_xmit	= sb1000_start_xmit;
+	dev->stop		= sb1000_close;
+	dev->get_stats		= sb1000_stats;
+
+	/* hardware address is 0:0:serial_number */
+	dev->dev_addr[2]	= serial_number >> 24 & 0xff;
+	dev->dev_addr[3]	= serial_number >> 16 & 0xff;
+	dev->dev_addr[4]	= serial_number >>  8 & 0xff;
+	dev->dev_addr[5]	= serial_number >>  0 & 0xff;
+
+	pnp_set_drvdata(pdev, dev);
+
+	error = register_netdev(dev);
+	if (error)
+		goto out_unregister;
+	return 0;
 
-		return 0;
-	}
-}
+ out_unregister:
+	unregister_netdev(dev);
+ out_release_regions:
+	release_region(ioaddr[1], 16);
+ out_release_region0:
+	release_region(ioaddr[0], 16);
+ out_disable:
+	pnp_disable_dev(pdev);
+ out_detach:
+	pnp_device_detach(pdev);
+	return error;
+}
+
+static void
+sb1000_remove_one(struct pnp_dev *pdev)
+{
+	struct net_device *dev = pnp_get_drvdata(pdev);
+
+	unregister_netdev(dev);
+	release_region(dev->base_addr, 16);
+	release_region(dev->mem_start, 16);
+}
+
+static struct pnp_driver sb1000_driver = {
+	.name		= "sb1000",
+	.id_table	= sb1000_pnp_ids,
+	.probe		= sb1000_probe_one,
+	.remove		= sb1000_remove_one,
+};
 
 
 /*
@@ -1207,60 +1183,21 @@
 	return 0;
 }
 
-#ifdef MODULE
 MODULE_AUTHOR("Franco Venturi <fventuri@mediaone.net>");
 MODULE_DESCRIPTION("General Instruments SB1000 driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(io, "1-2i");
-MODULE_PARM(irq, "i");
-MODULE_PARM_DESC(io, "SB1000 I/O base addresses");
-MODULE_PARM_DESC(irq, "SB1000 IRQ number");
-
-static struct net_device dev_sb1000;
-static int io[2];
-static int irq;
-
-int
-init_module(void)
+static int __init
+sb1000_init(void)
 {
-	int i;
-	for (i = 0; i < 100; i++) {
-		sprintf(dev_sb1000.name, "cm%d", i);
-		if (dev_get(dev_sb1000.name) == 0) break;
-	}
-	if (i == 100) {
-		printk(KERN_ERR "sb1000: can't register any device cm<n>\n");
-		return -ENFILE;
-	}
-	dev_sb1000.init = sb1000_probe;
-	dev_sb1000.base_addr = io[0];
-	/* mem_start holds the second I/O address */
-	dev_sb1000.mem_start = io[1];
-	dev_sb1000.irq = irq;
-	if (register_netdev(&dev_sb1000) != 0) {
-		printk(KERN_ERR "sb1000: failed to register device (io: %03x,%03x   "
-			"irq: %d)\n", io[0], io[1], irq);
-		return -EIO;
-	}
-	return 0;
+	return pnp_register_driver(&sb1000_driver);
 }
 
-void cleanup_module(void)
+static void __exit
+sb1000_exit(void)
 {
-	unregister_netdev(&dev_sb1000);
-	release_region(dev_sb1000.base_addr, 16);
-	release_region(dev_sb1000.mem_start, 16);
-	kfree(dev_sb1000.priv);
-	dev_sb1000.priv = NULL;
+	pnp_unregister_driver(&sb1000_driver);
 }
-#endif /* MODULE */
-
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -DMODULE -Wall -Wstrict-prototypes -O -m486 -c sb1000.c"
- *  version-control: t
- *  tab-width: 4
- *  c-basic-offset: 4
- * End:
- */
+
+module_init(sb1000_init);
+module_exit(sb1000_exit);
===== drivers/net/setup.c 1.9 vs edited =====
--- 1.9/drivers/net/setup.c	Fri May  9 12:35:53 2003
+++ edited/drivers/net/setup.c	Sat May 10 07:07:26 2003
@@ -21,14 +21,6 @@
 
 extern int madgemc_probe(void);
 
-/* Pad device name to IFNAMSIZ=16. F.e. __PAD6 is string of 9 zeros. */
-#define __PAD6 "\0\0\0\0\0\0\0\0\0"
-#define __PAD5 __PAD6 "\0"
-#define __PAD4 __PAD5 "\0"
-#define __PAD3 __PAD4 "\0"
-#define __PAD2 __PAD3 "\0"
-
-
 /*
  *	Devices in this list must do new style probing. That is they must
  *	allocate their own device objects and do their own bus scans.
@@ -84,7 +76,7 @@
  *	into them.
  */
  
-static void __init network_probe(void)
+void __init net_device_init(void)
 {
 	struct net_probe *p = pci_probes;
 
@@ -93,29 +85,4 @@
 		p->status = p->probe();
 		p++;
 	}
-}
-
-static void __init special_device_init(void)
-{
-#ifdef CONFIG_NET_SB1000
-	extern int sb1000_probe(struct net_device *dev);
-
-	static struct net_device sb1000_dev = {
-		.name = "cm0" __PAD3,
-		.init = sb1000_probe,
-	};
-	register_netdev(&sb1000_dev);
-#endif
-}
-
-/*
- *	Initialise network devices
- */
- 
-void __init net_device_init(void)
-{
-	/* Devices supporting the new^H^H^Hold probing API */
-	network_probe();
-	/* Special devices */
-	special_device_init();
 }
