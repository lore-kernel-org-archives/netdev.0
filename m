From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] Sysfs class - device hook
Date: Thu, 15 May 2003 16:27:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515162722.45dc315e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, greg@kroah.com, mochel@osdl.org, jkenisto@us.ibm.com,
   lkessler@us.ibm.com, Daniel Stekloff
 <dsteklof@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Patrick Mochel <mochel@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In order to created device and driver objects for class/net/mynetdev, 
the driver needs to set the generic device pointer in the network device
structure before registering.

If a driver doesn't set the entry, nothing bad happens, just the
device and driver symlink's do not get made.  So there is no backward
compatiablity problem.

If a driver still needs to work on 2.4, then it can define SET_NETDEV_DEV
as a no-op.

The e100 and 8139too have been tested; other drivers have been built
but don't have that hardware.

diff -urNp -X dontdiff linux-2.5/drivers/net/3c59x.c linux-2.5-sysfs/drivers/net/3c59x.c
--- linux-2.5/drivers/net/3c59x.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/3c59x.c	2003-05-15 10:13:25.000000000 -0700
@@ -1103,6 +1103,7 @@ static int __devinit vortex_probe1(struc
 		goto out;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, gendev);
 	vp = dev->priv;
 
 	option = global_options;
diff -urNp -X dontdiff linux-2.5/drivers/net/8139cp.c linux-2.5-sysfs/drivers/net/8139cp.c
--- linux-2.5/drivers/net/8139cp.c	2003-04-29 09:57:40.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/8139cp.c	2003-05-15 10:04:45.000000000 -0700
@@ -1801,6 +1801,8 @@ static int __devinit cp_init_one (struct
 	if (!dev)
 		return -ENOMEM;
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
 	cp = dev->priv;
 	cp->pdev = pdev;
 	cp->board_type = board_type;
diff -urNp -X dontdiff linux-2.5/drivers/net/8139too.c linux-2.5-sysfs/drivers/net/8139too.c
--- linux-2.5/drivers/net/8139too.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/8139too.c	2003-05-15 10:04:10.000000000 -0700
@@ -768,6 +768,8 @@ static int __devinit rtl8139_init_board 
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
 	tp = dev->priv;
 	tp->pci_dev = pdev;
 
diff -urNp -X dontdiff linux-2.5/drivers/net/acenic.c linux-2.5-sysfs/drivers/net/acenic.c
--- linux-2.5/drivers/net/acenic.c	2003-05-09 09:33:37.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/acenic.c	2003-05-15 10:06:25.000000000 -0700
@@ -188,6 +188,9 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl)
 #define ACE_MOD_DEC_USE_COUNT		do{} while(0)
 #endif
 
+#ifndef SET_NETDEV_DEV
+#define SET_NETDEV_DEV(net, pdev)	do{} while(0)
+#endif
 
 #if LINUX_VERSION_CODE >= 0x2051c
 #define ace_sync_irq(irq)	synchronize_irq(irq)
@@ -651,6 +654,7 @@ int __devinit acenic_probe (ACE_PROBE_AR
 		}
 
 		SET_MODULE_OWNER(dev);
+		SET_NETDEV_DEV(dev, &pdev->dev);
 
 		if (!dev->priv)
 			dev->priv = kmalloc(sizeof(*ap), GFP_KERNEL);
diff -urNp -X dontdiff linux-2.5/drivers/net/amd8111e.c linux-2.5-sysfs/drivers/net/amd8111e.c
--- linux-2.5/drivers/net/amd8111e.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/amd8111e.c	2003-05-15 10:06:48.000000000 -0700
@@ -1542,6 +1542,7 @@ static int __devinit amd8111e_probe_one(
 	}
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if AMD8111E_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX ;
diff -urNp -X dontdiff linux-2.5/drivers/net/defxx.c linux-2.5-sysfs/drivers/net/defxx.c
--- linux-2.5/drivers/net/defxx.c	2003-04-14 13:32:01.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/defxx.c	2003-05-15 10:16:03.000000000 -0700
@@ -443,6 +443,7 @@ static int __devinit dfx_init_one_pci_or
 	}
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	bp = dev->priv;
 
diff -urNp -X dontdiff linux-2.5/drivers/net/dl2k.c linux-2.5-sysfs/drivers/net/dl2k.c
--- linux-2.5/drivers/net/dl2k.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/dl2k.c	2003-05-15 10:07:22.000000000 -0700
@@ -154,6 +154,7 @@ rio_probe1 (struct pci_dev *pdev, const 
 		goto err_out_res;
 	}
 	SET_MODULE_OWNER (dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #ifdef MEM_MAPPING
 	ioaddr = pci_resource_start (pdev, 1);
diff -urNp -X dontdiff linux-2.5/drivers/net/e100/e100_main.c linux-2.5-sysfs/drivers/net/e100/e100_main.c
--- linux-2.5/drivers/net/e100/e100_main.c	2003-04-21 08:58:19.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/e100/e100_main.c	2003-05-15 10:11:00.000000000 -0700
@@ -591,6 +591,7 @@ e100_found1(struct pci_dev *pcid, const 
 	bdp->device = dev;
 
 	pci_set_drvdata(pcid, dev);
+	SET_NETDEV_DEV(dev, &pcid->dev);
 
 	if ((rc = e100_alloc_space(bdp)) != 0) {
 		goto err_dev;
diff -urNp -X dontdiff linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5-sysfs/drivers/net/e1000/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2003-04-29 09:57:40.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/e1000/e1000_main.c	2003-05-15 10:26:04.000000000 -0700
@@ -391,6 +391,7 @@ e1000_probe(struct pci_dev *pdev,
 		goto err_alloc_etherdev;
 
 	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev->priv;
diff -urNp -X dontdiff linux-2.5/drivers/net/eepro100.c linux-2.5-sysfs/drivers/net/eepro100.c
--- linux-2.5/drivers/net/eepro100.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/eepro100.c	2003-05-15 14:47:07.000000000 -0700
@@ -678,6 +678,7 @@ static int __devinit speedo_found1(struc
 	}
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (dev->mem_start > 0)
 		option = dev->mem_start;
@@ -829,6 +830,7 @@ static int __devinit speedo_found1(struc
 	pci_set_power_state(pdev, acpi_idle_state);
 
 	pci_set_drvdata (pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	dev->irq = pdev->irq;
 
diff -urNp -X dontdiff linux-2.5/drivers/net/epic100.c linux-2.5-sysfs/drivers/net/epic100.c
--- linux-2.5/drivers/net/epic100.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/epic100.c	2003-05-15 10:17:45.000000000 -0700
@@ -409,6 +409,7 @@ static int __devinit epic_init_one (stru
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_request_regions(pdev, DRV_NAME))
 		goto err_out_free_netdev;
diff -urNp -X dontdiff linux-2.5/drivers/net/fealnx.c linux-2.5-sysfs/drivers/net/fealnx.c
--- linux-2.5/drivers/net/fealnx.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/fealnx.c	2003-05-15 10:18:12.000000000 -0700
@@ -539,6 +539,7 @@ static int __devinit fealnx_init_one(str
 		goto err_out_unmap;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* read ethernet id */
 	for (i = 0; i < 6; ++i)
diff -urNp -X dontdiff linux-2.5/drivers/net/hamachi.c linux-2.5-sysfs/drivers/net/hamachi.c
--- linux-2.5/drivers/net/hamachi.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/hamachi.c	2003-05-15 10:18:56.000000000 -0700
@@ -613,6 +613,7 @@ static int __init hamachi_init_one (stru
 		goto err_out_iounmap;
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #ifdef TX_CHECKSUM
 	printk("check that skbcopy in ip_queue_xmit isn't happening\n");
diff -urNp -X dontdiff linux-2.5/drivers/net/hp100.c linux-2.5-sysfs/drivers/net/hp100.c
--- linux-2.5/drivers/net/hp100.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/hp100.c	2003-05-15 10:19:20.000000000 -0700
@@ -776,6 +776,7 @@ static int __init hp100_probe1(struct ne
 	hp100_clear_stats(lp, ioaddr);
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pci_dev->dev);
 	ether_setup(dev);
 
 	/* If busmaster mode is wanted, a dma-capable memory area is needed for
diff -urNp -X dontdiff linux-2.5/drivers/net/ioc3-eth.c linux-2.5-sysfs/drivers/net/ioc3-eth.c
--- linux-2.5/drivers/net/ioc3-eth.c	2003-04-29 09:57:40.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/ioc3-eth.c	2003-05-15 10:20:03.000000000 -0700
@@ -1532,6 +1532,8 @@ static int __devinit ioc3_probe(struct p
 		goto out_free;
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
 	ip = dev->priv;
 	ip->dev = dev;
 
diff -urNp -X dontdiff linux-2.5/drivers/net/ixgb/ixgb_main.c linux-2.5-sysfs/drivers/net/ixgb/ixgb_main.c
--- linux-2.5/drivers/net/ixgb/ixgb_main.c	2003-04-29 10:17:00.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/ixgb/ixgb_main.c	2003-05-15 12:00:30.000000000 -0700
@@ -333,6 +333,7 @@ ixgb_probe(struct pci_dev *pdev, const s
 	}
 
 	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev->priv;
diff -urNp -X dontdiff linux-2.5/drivers/net/natsemi.c linux-2.5-sysfs/drivers/net/natsemi.c
--- linux-2.5/drivers/net/natsemi.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/natsemi.c	2003-05-15 10:20:39.000000000 -0700
@@ -762,6 +762,7 @@ static int __devinit natsemi_probe1 (str
 	if (!dev)
 		return -ENOMEM;
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	i = pci_request_regions(pdev, dev->name);
 	if (i) {
diff -urNp -X dontdiff linux-2.5/drivers/net/ne2k-pci.c linux-2.5-sysfs/drivers/net/ne2k-pci.c
--- linux-2.5/drivers/net/ne2k-pci.c	2003-04-14 13:32:01.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/ne2k-pci.c	2003-05-15 10:20:54.000000000 -0700
@@ -265,6 +265,7 @@ static int __devinit ne2k_pci_init_one (
 		goto err_out_free_res;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* Reset card. Who knows what dain-bramaged state it was left in. */
 	{
diff -urNp -X dontdiff linux-2.5/drivers/net/pci-skeleton.c linux-2.5-sysfs/drivers/net/pci-skeleton.c
--- linux-2.5/drivers/net/pci-skeleton.c	2003-04-29 09:57:40.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/pci-skeleton.c	2003-05-15 10:21:36.000000000 -0700
@@ -610,6 +610,7 @@ static int __devinit netdrv_init_board (
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = dev->priv;
 
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
diff -urNp -X dontdiff linux-2.5/drivers/net/pcnet32.c linux-2.5-sysfs/drivers/net/pcnet32.c
--- linux-2.5/drivers/net/pcnet32.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/pcnet32.c	2003-05-15 10:21:51.000000000 -0700
@@ -638,6 +638,7 @@ pcnet32_probe1(unsigned long ioaddr, uns
 	    release_region(ioaddr, PCNET32_TOTAL_SIZE);
 	    return -ENOMEM;
     }
+    SET_NETDEV_DEV(dev, &pdev->dev);
 
     printk(KERN_INFO PFX "%s at %#3lx,", chipname, ioaddr);
 
@@ -718,6 +719,7 @@ pcnet32_probe1(unsigned long ioaddr, uns
     spin_lock_init(&lp->lock);
     
     SET_MODULE_OWNER(dev);
+    SET_NETDEV_DEV(dev, &pdev->dev);
     dev->priv = lp;
     lp->name = chipname;
     lp->shared_irq = shared;
diff -urNp -X dontdiff linux-2.5/drivers/net/r8169.c linux-2.5-sysfs/drivers/net/r8169.c
--- linux-2.5/drivers/net/r8169.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/r8169.c	2003-05-15 10:22:02.000000000 -0700
@@ -373,6 +373,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = dev->priv;
 
 	// enable device (incl. PCI PM wakeup and hotplug setup)
diff -urNp -X dontdiff linux-2.5/drivers/net/rcpci45.c linux-2.5-sysfs/drivers/net/rcpci45.c
--- linux-2.5/drivers/net/rcpci45.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/rcpci45.c	2003-05-15 10:22:09.000000000 -0700
@@ -179,6 +179,7 @@ rcpci45_init_one (struct pci_dev *pdev, 
 		goto err_out;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	error = pci_enable_device (pdev);
 	if (error) {
diff -urNp -X dontdiff linux-2.5/drivers/net/rrunner.c linux-2.5-sysfs/drivers/net/rrunner.c
--- linux-2.5/drivers/net/rrunner.c	2003-04-29 09:57:40.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/rrunner.c	2003-05-15 10:22:16.000000000 -0700
@@ -114,6 +114,7 @@ static int __devinit rr_init_one(struct 
 	rrpriv = (struct rr_private *)dev->priv;
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_request_regions(pdev, "rrunner")) {
 		ret = -EIO;
diff -urNp -X dontdiff linux-2.5/drivers/net/sb1000.c linux-2.5-sysfs/drivers/net/sb1000.c
--- linux-2.5/drivers/net/sb1000.c	2003-05-12 09:35:52.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/sb1000.c	2003-05-15 14:39:19.000000000 -0700
@@ -194,6 +194,7 @@ sb1000_probe_one(struct pnp_dev *pdev, c
 		goto out_release_regions;
 	}
 	SET_MODULE_OWNER(dev);
+	set_netdev_dev(dev, &pdev->dev);
 
 	if (sb1000_debug > 0)
 		printk(KERN_NOTICE "%s", version);
diff -urNp -X dontdiff linux-2.5/drivers/net/sis900.c linux-2.5-sysfs/drivers/net/sis900.c
--- linux-2.5/drivers/net/sis900.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/sis900.c	2003-05-15 10:10:07.000000000 -0700
@@ -397,6 +397,7 @@ static int __devinit sis900_probe (struc
 	if (!net_dev)
 		return -ENOMEM;
 	SET_MODULE_OWNER(net_dev);
+	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	/* We do a request_region() to register /proc/ioports info. */
 	ioaddr = pci_resource_start(pci_dev, 0);	
diff -urNp -X dontdiff linux-2.5/drivers/net/sk98lin/skge.c linux-2.5-sysfs/drivers/net/sk98lin/skge.c
--- linux-2.5/drivers/net/sk98lin/skge.c	2003-05-09 09:33:37.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/sk98lin/skge.c	2003-05-15 12:01:22.000000000 -0700
@@ -460,6 +460,7 @@ static int __init skge_probe (void)
 		dev->irq = pdev->irq;
 
 		SET_MODULE_OWNER(dev);
+		SET_NETDEV_DEV(dev, &pdev->dev);
 		dev->open =		&SkGeOpen;
 		dev->stop =		&SkGeClose;
 		dev->hard_start_xmit =	&SkGeXmit;
diff -urNp -X dontdiff linux-2.5/drivers/net/smc-mca.c linux-2.5-sysfs/drivers/net/smc-mca.c
--- linux-2.5/drivers/net/smc-mca.c	2003-04-14 13:32:01.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/smc-mca.c	2003-05-15 10:22:59.000000000 -0700
@@ -207,6 +207,7 @@ int __init ultramca_probe(struct device 
 		return -ENODEV;
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, gen_dev);
 
 	if((i = register_netdev(dev)) != 0)
 		return i;
diff -urNp -X dontdiff linux-2.5/drivers/net/starfire.c linux-2.5-sysfs/drivers/net/starfire.c
--- linux-2.5/drivers/net/starfire.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/starfire.c	2003-05-15 10:23:16.000000000 -0700
@@ -876,6 +876,7 @@ static int __devinit starfire_init_one(s
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	irq = pdev->irq;
 
diff -urNp -X dontdiff linux-2.5/drivers/net/sundance.c linux-2.5-sysfs/drivers/net/sundance.c
--- linux-2.5/drivers/net/sundance.c	2003-04-26 21:10:38.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/sundance.c	2003-05-15 10:23:36.000000000 -0700
@@ -548,6 +548,7 @@ static int __devinit sundance_probe1 (st
 	if (!dev)
 		return -ENOMEM;
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_request_regions(pdev, DRV_NAME))
 		goto err_out_netdev;
diff -urNp -X dontdiff linux-2.5/drivers/net/sungem.c linux-2.5-sysfs/drivers/net/sungem.c
--- linux-2.5/drivers/net/sungem.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/sungem.c	2003-05-15 10:23:47.000000000 -0700
@@ -2928,6 +2928,7 @@ static int __devinit gem_init_one(struct
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	gp = dev->priv;
 
diff -urNp -X dontdiff linux-2.5/drivers/net/sunhme.c linux-2.5-sysfs/drivers/net/sunhme.c
--- linux-2.5/drivers/net/sunhme.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/sunhme.c	2003-05-15 10:24:00.000000000 -0700
@@ -3025,6 +3025,7 @@ static int __init happy_meal_pci_init(st
 	if (!dev)
 		goto err_out;
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (hme_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
diff -urNp -X dontdiff linux-2.5/drivers/net/tg3.c linux-2.5-sysfs/drivers/net/tg3.c
--- linux-2.5/drivers/net/tg3.c	2003-04-26 21:10:38.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tg3.c	2003-05-15 10:24:30.000000000 -0700
@@ -6764,6 +6764,7 @@ static int __devinit tg3_init_one(struct
 	}
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
diff -urNp -X dontdiff linux-2.5/drivers/net/tlan.c linux-2.5-sysfs/drivers/net/tlan.c
--- linux-2.5/drivers/net/tlan.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tlan.c	2003-05-15 10:10:35.000000000 -0700
@@ -521,6 +521,7 @@ static int __devinit TLan_probe1(struct 
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	
 	priv = dev->priv;
 
diff -urNp -X dontdiff linux-2.5/drivers/net/tulip/de2104x.c linux-2.5-sysfs/drivers/net/tulip/de2104x.c
--- linux-2.5/drivers/net/tulip/de2104x.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tulip/de2104x.c	2003-05-15 12:02:29.000000000 -0700
@@ -2006,6 +2006,7 @@ static int __init de_init_one (struct pc
 		return -ENOMEM;
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	dev->open = de_open;
 	dev->stop = de_close;
 	dev->set_multicast_list = de_set_rx_mode;
diff -urNp -X dontdiff linux-2.5/drivers/net/tulip/de4x5.c linux-2.5-sysfs/drivers/net/tulip/de4x5.c
--- linux-2.5/drivers/net/tulip/de4x5.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tulip/de4x5.c	2003-05-15 12:03:02.000000000 -0700
@@ -1350,6 +1350,7 @@ de4x5_hw_init(struct net_device *dev, u_
     
     /* The DE4X5-specific entries in the device structure. */
     SET_MODULE_OWNER(dev);
+    SET_NETDEV_DEV(dev, &pdev->dev);
     dev->open = &de4x5_open;
     dev->hard_start_xmit = &de4x5_queue_pkt;
     dev->stop = &de4x5_close;
diff -urNp -X dontdiff linux-2.5/drivers/net/tulip/dmfe.c linux-2.5-sysfs/drivers/net/tulip/dmfe.c
--- linux-2.5/drivers/net/tulip/dmfe.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tulip/dmfe.c	2003-05-15 12:03:09.000000000 -0700
@@ -348,6 +348,7 @@ static int __devinit dmfe_init_one (stru
 	if (dev == NULL)
 		return -ENOMEM;
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, 0xffffffff)) {
 		printk(KERN_WARNING DRV_NAME ": 32-bit PCI DMA not available.\n");
diff -urNp -X dontdiff linux-2.5/drivers/net/tulip/tulip_core.c linux-2.5-sysfs/drivers/net/tulip/tulip_core.c
--- linux-2.5/drivers/net/tulip/tulip_core.c	2003-05-12 09:35:52.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tulip/tulip_core.c	2003-05-15 12:03:18.000000000 -0700
@@ -1360,6 +1360,7 @@ static int __devinit tulip_init_one (str
 	}
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	if (pci_resource_len (pdev, 0) < tulip_tbl[chip_idx].io_size) {
 		printk (KERN_ERR PFX "%s: I/O region (0x%lx@0x%lx) too small, "
 			"aborting\n", pdev->slot_name,
diff -urNp -X dontdiff linux-2.5/drivers/net/tulip/winbond-840.c linux-2.5-sysfs/drivers/net/tulip/winbond-840.c
--- linux-2.5/drivers/net/tulip/winbond-840.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tulip/winbond-840.c	2003-05-15 12:03:24.000000000 -0700
@@ -423,6 +423,7 @@ static int __devinit w840_probe1 (struct
 	if (!dev)
 		return -ENOMEM;
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_request_regions(pdev, DRV_NAME))
 		goto err_out_netdev;
diff -urNp -X dontdiff linux-2.5/drivers/net/tulip/xircom_cb.c linux-2.5-sysfs/drivers/net/tulip/xircom_cb.c
--- linux-2.5/drivers/net/tulip/xircom_cb.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tulip/xircom_cb.c	2003-05-15 12:03:37.000000000 -0700
@@ -276,6 +276,7 @@ static int __devinit xircom_probe(struct
 		return -ENODEV;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	printk(KERN_INFO "%s: Xircom cardbus revision %i at irq %i \n", dev->name, chip_rev, pdev->irq);
 
 	private->dev = dev;
diff -urNp -X dontdiff linux-2.5/drivers/net/tulip/xircom_tulip_cb.c linux-2.5-sysfs/drivers/net/tulip/xircom_tulip_cb.c
--- linux-2.5/drivers/net/tulip/xircom_tulip_cb.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/tulip/xircom_tulip_cb.c	2003-05-15 12:04:01.000000000 -0700
@@ -560,6 +560,7 @@ static int __devinit xircom_init_one(str
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	dev->base_addr = ioaddr;
 	dev->irq = pdev->irq;
diff -urNp -X dontdiff linux-2.5/drivers/net/typhoon.c linux-2.5-sysfs/drivers/net/typhoon.c
--- linux-2.5/drivers/net/typhoon.c	2003-04-26 21:10:38.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/typhoon.c	2003-05-15 10:24:44.000000000 -0700
@@ -2266,6 +2266,7 @@ typhoon_init_one(struct pci_dev *pdev, c
 		goto error_out;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = pci_enable_device(pdev);
 	if(err < 0) {
diff -urNp -X dontdiff linux-2.5/drivers/net/via-rhine.c linux-2.5-sysfs/drivers/net/via-rhine.c
--- linux-2.5/drivers/net/via-rhine.c	2003-04-26 21:10:38.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/via-rhine.c	2003-05-15 10:24:55.000000000 -0700
@@ -660,6 +660,7 @@ static int __devinit via_rhine_init_one 
 		goto err_out;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	
 	if (pci_request_regions(pdev, shortname))
 		goto err_out_free_netdev;
diff -urNp -X dontdiff linux-2.5/drivers/net/yellowfin.c linux-2.5-sysfs/drivers/net/yellowfin.c
--- linux-2.5/drivers/net/yellowfin.c	2003-04-24 16:02:05.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/yellowfin.c	2003-05-15 10:25:05.000000000 -0700
@@ -444,6 +444,7 @@ static int __devinit yellowfin_init_one(
 		return -ENOMEM;
 	}
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	np = dev->priv;
 
diff -urNp -X dontdiff linux-2.5/drivers/usb/net/usbnet.c linux-2.5-sysfs/drivers/usb/net/usbnet.c
--- linux-2.5/drivers/usb/net/usbnet.c	2003-05-01 11:19:59.000000000 -0700
+++ linux-2.5-sysfs/drivers/usb/net/usbnet.c	2003-05-15 15:03:33.000000000 -0700
@@ -2597,7 +2597,8 @@ usbnet_probe (struct usb_interface *udev
 		return status;
 	}
 	dev->maxpacket = usb_maxpacket (dev->udev, dev->out, 1);
-
+	
+	SET_NETDEV_DEV(&dev->net, &dev->udev->dev);
 	register_netdev (&dev->net);
 	devinfo (dev, "register usbnet at usb-%s-%s, %s",
 		xdev->bus->bus_name, xdev->devpath,
