From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.0-test6 - more free_netdev() conversion
Date: Tue, 30 Sep 2003 00:06:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930000646.A19220@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Compiles ok (with true .o generated, yeah). Please review.

free_netdev() of devices allocated through use of alloc_netdev().
Though baroque, drivers/net/3c515.c now uses alloc_etherdev().


 drivers/net/3c515.c   |   23 ++++++++++++-----------
 drivers/net/defxx.c   |    2 +-
 drivers/net/dummy.c   |    2 +-
 drivers/net/eql.c     |    2 +-
 drivers/net/ns83820.c |    2 +-
 drivers/net/plip.c    |   14 ++++++++++----
 drivers/net/shaper.c  |   11 ++++++++---
 drivers/net/tun.c     |   18 +++++++++---------
 9 files changed, 43 insertions(+), 31 deletions(-)

diff -puN drivers/net/3c515.c~free_netdev drivers/net/3c515.c
--- linux-2.6.0-test6/drivers/net/3c515.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/3c515.c	Mon Sep 29 21:41:27 2003
@@ -569,14 +569,13 @@ static struct net_device *corkscrew_foun
 
 #ifdef MODULE
 	/* Allocate and fill new device structure. */
-	int dev_size = sizeof(struct net_device) + sizeof(struct corkscrew_private) + 15;	/* Pad for alignment */
+	int dev_size = sizeof(struct corkscrew_private);
 
-	dev = (struct net_device *) kmalloc(dev_size, GFP_KERNEL);
+	dev = alloc_etherdev(dev_size);
 	if (!dev)
-		return NULL;
+		goto err_out;
 	memset(dev, 0, dev_size);
-	/* Align the Rx and Tx ring entries.  */
-	dev->priv = (void *) (((long) dev + sizeof(struct net_device) + 15) & ~15);
+
 	vp = (struct corkscrew_private *) dev->priv;
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
@@ -593,19 +592,16 @@ static struct net_device *corkscrew_foun
 		vp->full_duplex = 0;
 		vp->bus_master = 0;
 	}
-	ether_setup(dev);
 	vp->next_module = root_corkscrew_dev;
 	root_corkscrew_dev = dev;
 	SET_MODULE_OWNER(dev);
-	if (register_netdev(dev) != 0) {
-		kfree(dev);
-		return NULL;
-	}
+	if (register_netdev(dev) < 0)
+		goto err_free_dev;
 #else				/* not a MODULE */
 	/* Caution: quad-word alignment required for rings! */
 	dev->priv = kmalloc(sizeof(struct corkscrew_private), GFP_KERNEL);
 	if (!dev->priv)
-		return NULL;
+		goto err_out;
 	memset(dev->priv, 0, sizeof(struct corkscrew_private));
 	dev = init_etherdev(dev, sizeof(struct corkscrew_private));
 	dev->base_addr = ioaddr;
@@ -627,6 +623,11 @@ static struct net_device *corkscrew_foun
 	corkscrew_probe1(dev);
 #endif				/* MODULE */
 	return dev;
+
+err_free_dev:
+	free_netdev(dev);
+err_out:
+	return NULL;
 }
 
 static int corkscrew_probe1(struct net_device *dev)
diff -puN drivers/net/defxx.c~free_netdev drivers/net/defxx.c
--- linux-2.6.0-test6/drivers/net/defxx.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/defxx.c	Mon Sep 29 21:41:27 2003
@@ -491,7 +491,7 @@ err_out_kfree:
 err_out_region:
 	release_region(ioaddr, pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN);
 err_out:
-	kfree(dev);
+	free_netdev(dev);
 	return err;
 }
 
diff -puN drivers/net/dummy.c~free_netdev drivers/net/dummy.c
--- linux-2.6.0-test6/drivers/net/dummy.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/dummy.c	Mon Sep 29 21:41:27 2003
@@ -96,7 +96,7 @@ static int __init dummy_init_module(void
 		return -ENOMEM;
 
 	if ((err = register_netdev(dev_dummy))) {
-		kfree(dev_dummy);
+		free_netdev(dev_dummy);
 		dev_dummy = NULL;
 	}
 	return err;
diff -puN drivers/net/eql.c~free_netdev drivers/net/eql.c
--- linux-2.6.0-test6/drivers/net/eql.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/eql.c	Mon Sep 29 21:41:27 2003
@@ -600,7 +600,7 @@ static int __init eql_init_module(void)
 
 	err = register_netdev(dev_eql);
 	if (err) 
-		kfree(dev_eql);
+		free_netdev(dev_eql);
 	return err;
 }
 
diff -puN drivers/net/ns83820.c~free_netdev drivers/net/ns83820.c
--- linux-2.6.0-test6/drivers/net/ns83820.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/ns83820.c	Mon Sep 29 21:41:27 2003
@@ -2034,7 +2034,7 @@ out_disable:
 	pci_free_consistent(pci_dev, 4 * DESC_SIZE * NR_RX_DESC, dev->rx_info.descs, dev->rx_info.phy_descs);
 	pci_disable_device(pci_dev);
 out_free:
-	kfree(dev);
+	free_netdev(&dev->net_dev);
 	pci_set_drvdata(pci_dev, NULL);
 out:
 	return err;
diff -puN drivers/net/plip.c~free_netdev drivers/net/plip.c
--- linux-2.6.0-test6/drivers/net/plip.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/plip.c	Mon Sep 29 21:41:27 2003
@@ -1306,17 +1306,23 @@ static void plip_attach (struct parport 
 
 		if (!nl->pardev) {
 			printk(KERN_ERR "%s: parport_register failed\n", name);
-			kfree(dev);
+			goto err_free_dev;
 			return;
 		}
 
 		if (register_netdev(dev)) {
 			printk(KERN_ERR "%s: network register failed\n", name);
-			kfree(dev);
-		} else {
-			dev_plip[unit++] = dev;
+			goto err_parport_unregister;
 		}
+		dev_plip[unit++] = dev;
 	}
+	return;
+
+err_parport_unregister:
+	parport_unregister_device(nl->pardev);
+err_free_dev:
+	free_netdev(dev);
+	return;
 }
 
 /* plip_detach() is called (by the parport code) when a port is
diff -puN drivers/net/rrunner.c~free_netdev drivers/net/rrunner.c
diff -puN drivers/net/shaper.c~free_netdev drivers/net/shaper.c
--- linux-2.6.0-test6/drivers/net/shaper.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/shaper.c	Mon Sep 29 21:41:27 2003
@@ -718,8 +718,10 @@ static int __init shaper_init(void)
 		if (!dev) 
 			break;
 
-		if (register_netdev(dev))
+		if (register_netdev(dev)) {
+			free_netdev(dev);
 			break;
+		}
 
 		devs[i] = dev;
 		shapers_registered++;
@@ -737,9 +739,12 @@ static void __exit shaper_exit (void)
 {
 	int i;
 
-	for (i = 0; i < shapers_registered; i++)
-		if (devs[i])
+	for (i = 0; i < shapers_registered; i++) {
+		if (devs[i]) {
 			unregister_netdev(devs[i]);
+			free_netdev(devs[i]);
+		}
+	}
 
 	kfree(devs);
 	devs = NULL;
diff -puN drivers/net/tun.c~free_netdev drivers/net/tun.c
--- linux-2.6.0-test6/drivers/net/tun.c~free_netdev	Mon Sep 29 21:41:27 2003
+++ linux-2.6.0-test6-fr/drivers/net/tun.c	Mon Sep 29 21:41:27 2003
@@ -377,6 +377,7 @@ static struct tun_struct *tun_get_by_nam
 static int tun_set_iff(struct file *file, struct ifreq *ifr)
 {
 	struct tun_struct *tun;
+	struct net_device *dev;
 	int err;
 
 	tun = tun_get_by_name(ifr->ifr_name);
@@ -394,7 +395,6 @@ static int tun_set_iff(struct file *file
 	else {
 		char *name;
 		unsigned long flags = 0;
-		struct net_device *dev;
 
 		err = -EINVAL;
 
@@ -424,16 +424,13 @@ static int tun_set_iff(struct file *file
 
 		if (strchr(dev->name, '%')) {
 			err = dev_alloc_name(dev, dev->name);
-			if (err < 0) {
-				kfree(dev);
-				goto failed;
-			}
+			if (err < 0)
+				goto err_free_dev;
 		}
 
-		if ((err = register_netdevice(tun->dev))) {
-			kfree(dev);
-			goto failed;
-		}
+		err = register_netdevice(tun->dev);
+		if (err < 0)
+			goto err_free_dev;
 	
 		list_add(&tun->list, &tun_dev_list);
 	}
@@ -451,6 +448,9 @@ static int tun_set_iff(struct file *file
 
 	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
+
+ err_free_dev:
+	free_netdev(dev);
  failed:
 	return err;
 }

_
