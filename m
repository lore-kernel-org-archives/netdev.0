From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (21/42) sk_mca
Date: Wed, 12 Nov 2003 16:43:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130043.hAD0hmV30812@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE45-sk_mca
	* switched sk-mca to dynamic allocation
	* sk-mca: switched to embedded ->priv
	* sk-mca: fixed order of freeing bugs
	* sk-mca: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 13:50:15 2003
+++ b/drivers/net/Space.c	Tue Nov 11 13:50:15 2003
@@ -61,7 +61,7 @@
 extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
 extern int elmc_probe(struct net_device *);
-extern int skmca_probe(struct net_device *);
+extern struct net_device *skmca_probe(int unit);
 extern struct net_device *elplus_probe(int unit);
 extern int ac3200_probe(struct net_device *);
 extern int es_probe(struct net_device *);
@@ -187,6 +187,10 @@
 #ifdef CONFIG_ELMC_II		/* 3c527 */
 	{mc32_probe, 0},
 #endif
+	{NULL, 0},
+};
+
+static struct devprobe2 mca_probes2[] __initdata = {
 #ifdef CONFIG_SKMC              /* SKnet Microchannel */
         {skmca_probe, 0},
 #endif
@@ -394,6 +398,7 @@
 	if (base_addr == 1)
 		return;
 
+	probe_list2(unit, mca_probes2, base_addr == 0) &&
 	probe_list2(unit, isa_probes2, base_addr == 0) &&
 	probe_list2(unit, parport_probes, base_addr == 0);
 }
diff -Nru a/drivers/net/sk_mca.c b/drivers/net/sk_mca.c
--- a/drivers/net/sk_mca.c	Tue Nov 11 13:50:15 2003
+++ b/drivers/net/sk_mca.c	Tue Nov 11 13:50:15 2003
@@ -1022,18 +1022,39 @@
 
 static int startslot;		/* counts through slots when probing multiple devices */
 
-int __init skmca_probe(struct net_device *dev)
+static void cleanup_card(struct net_device *dev)
 {
+	skmca_priv *priv = dev->priv;
+	DeinitBoard(dev);
+	if (dev->irq != 0)
+		free_irq(dev->irq, dev);
+	mca_mark_as_unused(priv->slot);
+	mca_set_adapter_procfn(priv->slot, NULL, NULL);
+}
+
+struct net_device * __init skmca_probe(int unit)
+{
+	struct net_device *dev;
 	int force_detect = 0;
 	int junior, slot, i;
 	int base = 0, irq = 0;
 	skmca_priv *priv;
 	skmca_medium medium;
+	int err;
 
 	/* can't work without an MCA bus ;-) */
 
 	if (MCA_bus == 0)
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(sizeof(skmca_priv));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 
 	SET_MODULE_OWNER(dev);
 
@@ -1044,37 +1065,24 @@
 
 	/* search through slots */
 
-	if (dev != NULL) {
-		base = dev->mem_start;
-		irq = dev->irq;
-	}
-	slot = dofind(&junior, startslot);
-
-	while (slot != -1) {
+	base = dev->mem_start;
+	irq = dev->base_addr;
+	for (slot = startslot; (slot = dofind(&junior, slot)) != -1; slot++) {
 		/* deduce card addresses */
 
 		getaddrs(slot, junior, &base, &irq, &medium);
 
 		/* slot already in use ? */
 
-		if (mca_is_adapter_used(slot)) {
-			slot = dofind(&junior, slot + 1);
+		if (mca_is_adapter_used(slot))
 			continue;
-		}
 
 		/* were we looking for something different ? */
 
-		if ((dev->irq != 0) || (dev->mem_start != 0)) {
-			if ((dev->irq != 0) && (dev->irq != irq)) {
-				slot = dofind(&junior, slot + 1);
-				continue;
-			}
-			if ((dev->mem_start != 0)
-			    && (dev->mem_start != base)) {
-				slot = dofind(&junior, slot + 1);
-				continue;
-			}
-		}
+		if (dev->irq && dev->irq != irq)
+			continue;
+		if (dev->mem_start && dev->mem_start != base)
+			continue;
 
 		/* found something that matches */
 
@@ -1083,8 +1091,10 @@
 
 	/* nothing found ? */
 
-	if (slot == -1)
-		return ((base != 0) || (irq != 0)) ? ENXIO : ENODEV;
+	if (slot == -1) {
+		free_netdev(dev);
+		return (base || irq) ? ERR_PTR(-ENXIO) : ERR_PTR(-ENODEV);
+	}
 
 	/* make procfs entries */
 
@@ -1102,17 +1112,14 @@
 	       junior ? "Junior MC2" : "MC2+", slot + 1);
 
 	/* allocate structure */
-	priv = dev->priv =
-	    (skmca_priv *) kmalloc(sizeof(skmca_priv), GFP_KERNEL);
-	if (!priv)
-		return -ENOMEM;
+	priv = dev->priv;
 	priv->slot = slot;
 	priv->macbase = base + 0x3fc0;
 	priv->ioregaddr = base + 0x3ff0;
 	priv->ctrladdr = base + 0x3ff2;
 	priv->cmdaddr = base + 0x3ff3;
 	priv->medium = medium;
-	memset(&(priv->stat), 0, sizeof(struct net_device_stats));
+	memset(&priv->stat, 0, sizeof(struct net_device_stats));
 	spin_lock_init(&priv->lock);
 
 	/* set base + irq for this device (irq not allocated so far) */
@@ -1146,9 +1153,6 @@
 	dev->set_multicast_list = skmca_set_multicast_list;
 	dev->flags |= IFF_MULTICAST;
 
-	/* generic setup */
-	ether_setup(dev);
-
 	/* copy out MAC address */
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = SKMCA_READB(priv->macbase + (i << 1));
@@ -1167,7 +1171,13 @@
 
 	startslot = slot + 1;
 
-	return 0;
+	err = register_netdev(dev);
+	if (err) {
+		cleanup_card(dev);
+		free_netdev(dev);
+		dev = ERR_PTR(err);
+	}
+	return dev;
 }
 
 /* ------------------------------------------------------------------------
@@ -1179,51 +1189,34 @@
 
 #define DEVMAX 5
 
-static struct net_device moddevs[DEVMAX] = {
-	{ .name = "    ", .init = skmca_probe },
-	{ .name = "    ", .init = skmca_probe },
-	{ .name = "    ", .init = skmca_probe },
-	{ .name = "    ", .init = skmca_probe },
-	{ .name = "    ", .init = skmca_probe }
-};
-
-int irq;
-int io;
+static struct net_device *moddevs[DEVMAX];
 
 int init_module(void)
 {
-	int z, res;
+	int z;
 
 	startslot = 0;
 	for (z = 0; z < DEVMAX; z++) {
-		strcpy(moddevs[z].name, "     ");
-		res = register_netdev(moddevs + z);
-		if (res != 0)
-			return (z > 0) ? 0 : -EIO;
+		struct net_device *dev = skmca_probe(-1);
+		if (IS_ERR(dev))
+			break;
+		moddevs[z] = dev;
 	}
-
+	if (!z)
+		return -EIO;
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	struct net_device *dev;
-	skmca_priv *priv;
 	int z;
 
 	for (z = 0; z < DEVMAX; z++) {
-		dev = moddevs + z;
-		if (dev->priv != NULL) {
-			priv = (skmca_priv *) dev->priv;
-			DeinitBoard(dev);
-			if (dev->irq != 0)
-				free_irq(dev->irq, dev);
-			dev->irq = 0;
+		struct net_device *dev = moddevs[z];
+		if (dev) {
 			unregister_netdev(dev);
-			mca_mark_as_unused(priv->slot);
-			mca_set_adapter_procfn(priv->slot, NULL, NULL);
-			kfree(dev->priv);
-			dev->priv = NULL;
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
diff -Nru a/drivers/net/sk_mca.h b/drivers/net/sk_mca.h
--- a/drivers/net/sk_mca.h	Tue Nov 11 13:50:15 2003
+++ b/drivers/net/sk_mca.h	Tue Nov 11 13:50:15 2003
@@ -178,7 +178,4 @@
 
 #endif				/* _SK_MCA_DRIVER_ */
 
-extern int skmca_probe(struct net_device *);
-
-
 #endif	/* _SK_MCA_INCLUDE_ */
