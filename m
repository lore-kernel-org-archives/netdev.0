From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 2/2] netdrvr/ibmlana: move away from legacy MCA API
Date: Mon, 29 Oct 2007 15:33:38 -0400 (EDT)
Message-ID: <cbe6f335b6d7f4199e235a4925d1c931dd512fe5.1193686354.git.jeff@garzik.org>
References: <47dcd058deaaf90802c720df243f5c8b26ed9de3.1193686354.git.jeff@garzik.org>
Cc: akpm@linux-foundation.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37209 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbXJ2Tdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 15:33:39 -0400
In-Reply-To: <47dcd058deaaf90802c720df243f5c8b26ed9de3.1193686354.git.jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/net/ibmlana.c |  119 +++++++++++++++++++++----------------------------
 1 files changed, 51 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 006d0d7..188c0a9 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -83,7 +83,7 @@ History:
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/time.h>
-#include <linux/mca-legacy.h>
+#include <linux/mca.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -161,13 +161,13 @@ static void PrTime(void)
 
 /* deduce resources out of POS registers */
 
-static void getaddrs(int slot, int *base, int *memlen, int *iobase,
-		     int *irq, ibmlana_medium * medium)
+static void getaddrs(struct mca_device *mdev, int *base, int *memlen,
+		     int *iobase, int *irq, ibmlana_medium *medium)
 {
 	u_char pos0, pos1;
 
-	pos0 = mca_read_stored_pos(slot, 2);
-	pos1 = mca_read_stored_pos(slot, 3);
+	pos0 = mca_device_read_stored_pos(mdev, 2);
+	pos1 = mca_device_read_stored_pos(mdev, 3);
 
 	*base = 0xc0000 + ((pos1 & 0xf0) << 9);
 	*memlen = (pos1 & 0x01) ? 0x8000 : 0x4000;
@@ -744,6 +744,7 @@ static irqreturn_t irq_handler(int irq, void *device)
 
 /* MCA info */
 
+#if 0 /* info available elsewhere, but this is kept for reference */
 static int ibmlana_getinfo(char *buf, int slot, void *d)
 {
 	int len = 0, i;
@@ -771,6 +772,7 @@ static int ibmlana_getinfo(char *buf, int slot, void *d)
 
 	return len;
 }
+#endif
 
 /* open driver.  Means also initialization and start of LANCE */
 
@@ -894,19 +896,26 @@ static int ibmlana_irq;
 static int ibmlana_io;
 static int startslot;		/* counts through slots when probing multiple devices */
 
-static int ibmlana_probe(struct net_device **dev_out)
+static short ibmlana_adapter_ids[] __initdata = {
+	IBM_LANA_ID,
+	0x0000
+};
+
+static char *ibmlana_adapter_names[] __initdata = {
+	"IBM LAN Adapter/A",
+	NULL
+};
+
+static int ibmlana_init_one(struct device *kdev)
 {
+	struct mca_device *mdev = to_mca_device(kdev);
 	struct net_device *dev;
-	int slot, z, rc;
+	int slot = mdev->slot, z, rc;
 	int base = 0, irq = 0, iobase = 0, memlen = 0;
 	ibmlana_priv *priv;
 	ibmlana_medium medium;
 	DECLARE_MAC_BUF(mac);
 
-	/* can't work without an MCA bus ;-) */
-	if (MCA_bus == 0)
-		return -ENODEV;
-
 	dev = alloc_etherdev(sizeof(ibmlana_priv));
 	if (!dev)
 		return -ENOMEM;
@@ -917,25 +926,16 @@ static int ibmlana_probe(struct net_device **dev_out)
 	base = dev->mem_start;
 	irq = dev->irq;
 
-	for (slot = startslot; (slot = mca_find_adapter(IBM_LANA_ID, slot)) != -1; slot++) {
-		/* deduce card addresses */
-		getaddrs(slot, &base, &memlen, &iobase, &irq, &medium);
-
-		/* slot already in use ? */
-		if (mca_is_adapter_used(slot))
-			continue;
-		/* were we looking for something different ? */
-		if (dev->irq && dev->irq != irq)
-			continue;
-		if (dev->mem_start && dev->mem_start != base)
-			continue;
-		/* found something that matches */
-		break;
-	}
+	/* deduce card addresses */
+	getaddrs(mdev, &base, &memlen, &iobase, &irq, &medium);
 
-	/* nothing found ? */
-	if (slot == -1) {
-		rc = (base != 0 || irq != 0) ? -ENXIO : -ENODEV;
+	/* were we looking for something different ? */
+	if (dev->irq && dev->irq != irq) {
+		rc = -ENODEV;
+		goto err_out;
+	}
+	if (dev->mem_start && dev->mem_start != base) {
+		rc = -ENODEV;
 		goto err_out;
 	}
 
@@ -952,11 +952,10 @@ static int ibmlana_probe(struct net_device **dev_out)
 
 	priv = netdev_priv(dev);
 	priv->slot = slot;
-	priv->realirq = irq;
+	priv->realirq = mca_device_transform_irq(mdev, irq);
 	priv->medium = medium;
 	spin_lock_init(&priv->lock);
 
-
 	/* set base + irq for this device (irq not allocated so far) */
 
 	dev->irq = 0;
@@ -972,18 +971,14 @@ static int ibmlana_probe(struct net_device **dev_out)
 		goto err_out_reg;
 	}
 
-	/* make procfs entries */
-	mca_set_adapter_name(slot, "IBM LAN Adapter/A");
-	mca_set_adapter_procfn(slot, (MCA_ProcFn) ibmlana_getinfo, dev);
-
-	mca_mark_as_used(slot);
+	mca_device_set_name(mdev, ibmlana_adapter_names[mdev->index]);
+	mca_device_set_claim(mdev, 1);
 
 	/* set methods */
 
 	dev->open = ibmlana_open;
 	dev->stop = ibmlana_close;
 	dev->hard_start_xmit = ibmlana_tx;
-	dev->do_ioctl = NULL;
 	dev->set_multicast_list = ibmlana_set_multicast_list;
 	dev->flags |= IFF_MULTICAST;
 
@@ -1013,13 +1008,11 @@ static int ibmlana_probe(struct net_device **dev_out)
 	if (rc)
 		goto err_out_claimed;
 
-	*dev_out = dev;
+	dev_set_drvdata(kdev, dev);
 	return 0;
 
 err_out_claimed:
-	mca_mark_as_unused(priv->slot);
-	mca_set_adapter_name(priv->slot, "");
-	mca_set_adapter_procfn(priv->slot, NULL, NULL);
+	mca_device_set_claim(mdev, 0);
 	iounmap(priv->base);
 err_out_reg:
 	release_region(iobase, IBM_LANA_IORANGE);
@@ -1028,59 +1021,49 @@ err_out:
 	return rc;
 }
 
-static void ibmlana_remove_one(struct net_device *_dev)
+static int ibmlana_remove_one(struct device *kdev)
 {
-	struct net_device *dev = _dev;
+	struct mca_device *mdev = to_mca_device(kdev);
+	struct net_device *dev = dev_get_drvdata(kdev);
 	ibmlana_priv *priv = netdev_priv(dev);
 
 	unregister_netdev(dev);
 	/*DeinitBoard(dev); */
 	release_region(dev->base_addr, IBM_LANA_IORANGE);
-	mca_mark_as_unused(priv->slot);
-	mca_set_adapter_name(priv->slot, "");
-	mca_set_adapter_procfn(priv->slot, NULL, NULL);
+	mca_device_set_claim(mdev, 0);
 	iounmap(priv->base);
 	free_netdev(dev);
+	return 0;
 }
 
 /* ------------------------------------------------------------------------
  * modularization support
  * ------------------------------------------------------------------------ */
 
-#define DEVMAX 5
-
-static struct net_device *moddevs[DEVMAX];
-
 module_param_named(irq, ibmlana_irq, int, 0);
 module_param_named(io, ibmlana_io, int, 0);
 MODULE_PARM_DESC(irq, "IBM LAN/A IRQ number");
 MODULE_PARM_DESC(io, "IBM LAN/A I/O base address");
 MODULE_LICENSE("GPL");
 
+static struct mca_driver ibmlana_driver = {
+	.id_table = ibmlana_adapter_ids,
+	.driver = {
+		.name	= "ibmlana",
+		.bus	= &mca_bus_type,
+		.probe	= ibmlana_init_one,
+		.remove	= ibmlana_remove_one,
+	},
+};
+
 static int __init ibmlana_init_module(void)
 {
-	int z;
-
-	startslot = 0;
-	for (z = 0; z < DEVMAX; z++) {
-		struct net_device *dev = NULL;
-
-		if (ibmlana_probe(&dev))
-			break;
-
-		moddevs[z] = dev;
-	}
-	return (z > 0) ? 0 : -EIO;
+	return mca_register_driver(&ibmlana_driver);
 }
 
 static void __exit ibmlana_cleanup_module(void)
 {
-	int z;
-	for (z = 0; z < DEVMAX; z++) {
-		struct net_device *dev = moddevs[z];
-		if (dev)
-			ibmlana_remove_one(dev);
-	}
+	mca_unregister_driver(&ibmlana_driver);
 }
 
 module_init(ibmlana_init_module);
-- 
1.5.2.4

