From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 1/2] netdrvr/ibmlana: modularization cleanup
Date: Mon, 29 Oct 2007 15:33:36 -0400 (EDT)
Message-ID: <47dcd058deaaf90802c720df243f5c8b26ed9de3.1193686354.git.jeff@garzik.org>
Cc: akpm@linux-foundation.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43373 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbXJ2Tdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 15:33:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* move alloc_netdev() call, register_netdev() call, and associated failure
  cleanup into ibmlana_probe()

* move per-net_device cleanup into ibmlana_remove_one()

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/net/ibmlana.c |  109 +++++++++++++++++++++++++++++--------------------
 1 files changed, 64 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 91d83ac..006d0d7 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -890,11 +890,14 @@ static void ibmlana_set_multicast_list(struct net_device *dev)
  * hardware check
  * ------------------------------------------------------------------------ */
 
+static int ibmlana_irq;
+static int ibmlana_io;
 static int startslot;		/* counts through slots when probing multiple devices */
 
-static int ibmlana_probe(struct net_device *dev)
+static int ibmlana_probe(struct net_device **dev_out)
 {
-	int slot, z;
+	struct net_device *dev;
+	int slot, z, rc;
 	int base = 0, irq = 0, iobase = 0, memlen = 0;
 	ibmlana_priv *priv;
 	ibmlana_medium medium;
@@ -904,6 +907,13 @@ static int ibmlana_probe(struct net_device *dev)
 	if (MCA_bus == 0)
 		return -ENODEV;
 
+	dev = alloc_etherdev(sizeof(ibmlana_priv));
+	if (!dev)
+		return -ENOMEM;
+
+	dev->irq = ibmlana_irq;
+	dev->base_addr = ibmlana_io;
+
 	base = dev->mem_start;
 	irq = dev->irq;
 
@@ -924,8 +934,10 @@ static int ibmlana_probe(struct net_device *dev)
 	}
 
 	/* nothing found ? */
-	if (slot == -1)
-		return (base != 0 || irq != 0) ? -ENXIO : -ENODEV;
+	if (slot == -1) {
+		rc = (base != 0 || irq != 0) ? -ENXIO : -ENODEV;
+		goto err_out;
+	}
 
 	/* announce success */
 	printk(KERN_INFO "%s: IBM LAN Adapter/A found in slot %d\n", dev->name, slot + 1);
@@ -934,7 +946,8 @@ static int ibmlana_probe(struct net_device *dev)
 	if (!request_region(iobase, IBM_LANA_IORANGE, DRV_NAME)) {
 		printk(KERN_ERR "%s: cannot allocate I/O range at %#x!\n", DRV_NAME, iobase);
 		startslot = slot + 1;
-		return -EBUSY;
+		rc = -EBUSY;
+		goto err_out;
 	}
 
 	priv = netdev_priv(dev);
@@ -955,8 +968,8 @@ static int ibmlana_probe(struct net_device *dev)
 	if (!priv->base) {
 		printk(KERN_ERR "%s: cannot remap memory!\n", DRV_NAME);
 		startslot = slot + 1;
-		release_region(iobase, IBM_LANA_IORANGE);
-		return -EBUSY;
+		rc = -EBUSY;
+		goto err_out_reg;
 	}
 
 	/* make procfs entries */
@@ -996,73 +1009,79 @@ static int ibmlana_probe(struct net_device *dev)
 
 	startslot = slot + 1;
 
+	rc = register_netdev(dev);
+	if (rc)
+		goto err_out_claimed;
+
+	*dev_out = dev;
 	return 0;
+
+err_out_claimed:
+	mca_mark_as_unused(priv->slot);
+	mca_set_adapter_name(priv->slot, "");
+	mca_set_adapter_procfn(priv->slot, NULL, NULL);
+	iounmap(priv->base);
+err_out_reg:
+	release_region(iobase, IBM_LANA_IORANGE);
+err_out:
+	free_netdev(dev);
+	return rc;
+}
+
+static void ibmlana_remove_one(struct net_device *_dev)
+{
+	struct net_device *dev = _dev;
+	ibmlana_priv *priv = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	/*DeinitBoard(dev); */
+	release_region(dev->base_addr, IBM_LANA_IORANGE);
+	mca_mark_as_unused(priv->slot);
+	mca_set_adapter_name(priv->slot, "");
+	mca_set_adapter_procfn(priv->slot, NULL, NULL);
+	iounmap(priv->base);
+	free_netdev(dev);
 }
 
 /* ------------------------------------------------------------------------
  * modularization support
  * ------------------------------------------------------------------------ */
 
-#ifdef MODULE
-
 #define DEVMAX 5
 
 static struct net_device *moddevs[DEVMAX];
-static int irq;
-static int io;
 
-module_param(irq, int, 0);
-module_param(io, int, 0);
+module_param_named(irq, ibmlana_irq, int, 0);
+module_param_named(io, ibmlana_io, int, 0);
 MODULE_PARM_DESC(irq, "IBM LAN/A IRQ number");
 MODULE_PARM_DESC(io, "IBM LAN/A I/O base address");
 MODULE_LICENSE("GPL");
 
-int init_module(void)
+static int __init ibmlana_init_module(void)
 {
 	int z;
 
 	startslot = 0;
 	for (z = 0; z < DEVMAX; z++) {
-		struct net_device *dev = alloc_etherdev(sizeof(ibmlana_priv));
-		if (!dev)
-			break;
-		dev->irq = irq;
-		dev->base_addr = io;
-		if (ibmlana_probe(dev)) {
-			free_netdev(dev);
-			break;
-		}
-		if (register_netdev(dev)) {
-			ibmlana_priv *priv = netdev_priv(dev);
-			release_region(dev->base_addr, IBM_LANA_IORANGE);
-			mca_mark_as_unused(priv->slot);
-			mca_set_adapter_name(priv->slot, "");
-			mca_set_adapter_procfn(priv->slot, NULL, NULL);
-			iounmap(priv->base);
-			free_netdev(dev);
+		struct net_device *dev = NULL;
+
+		if (ibmlana_probe(&dev))
 			break;
-		}
+
 		moddevs[z] = dev;
 	}
 	return (z > 0) ? 0 : -EIO;
 }
 
-void cleanup_module(void)
+static void __exit ibmlana_cleanup_module(void)
 {
 	int z;
 	for (z = 0; z < DEVMAX; z++) {
 		struct net_device *dev = moddevs[z];
-		if (dev) {
-			ibmlana_priv *priv = netdev_priv(dev);
-			unregister_netdev(dev);
-			/*DeinitBoard(dev); */
-			release_region(dev->base_addr, IBM_LANA_IORANGE);
-			mca_mark_as_unused(priv->slot);
-			mca_set_adapter_name(priv->slot, "");
-			mca_set_adapter_procfn(priv->slot, NULL, NULL);
-			iounmap(priv->base);
-			free_netdev(dev);
-		}
+		if (dev)
+			ibmlana_remove_one(dev);
 	}
 }
-#endif				/* MODULE */
+
+module_init(ibmlana_init_module);
+module_exit(ibmlana_cleanup_module);
-- 
1.5.2.4

