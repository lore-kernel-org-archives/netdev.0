From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (23/42) 3c523
Date: Wed, 12 Nov 2003 16:44:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130044.hAD0i8G30878@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE47-3c523 from viro
	* switched 3c523 to dynamic allocation
	* 3c523: switched to embedded ->priv
	* 3c523: fixed order of freeing bugs
	* 3c523: fixed resource leaks on failure exits

diff -Nru a/drivers/net/3c523.c b/drivers/net/3c523.c
--- a/drivers/net/3c523.c	Tue Nov 11 13:50:42 2003
+++ b/drivers/net/3c523.c	Tue Nov 11 13:50:42 2003
@@ -410,7 +410,7 @@
 
 /*****************************************************************/
 
-int __init elmc_probe(struct net_device *dev)
+static int __init do_elmc_probe(struct net_device *dev)
 {
 	static int slot;
 	int base_addr = dev->base_addr;
@@ -420,7 +420,7 @@
 	int i = 0;
 	unsigned int size = 0;
 	int retval;
-	struct priv *pr;
+	struct priv *pr = dev->priv;
 
 	SET_MODULE_OWNER(dev);
 	if (MCA_bus == 0) {
@@ -455,10 +455,9 @@
 	}
 
 	/* we didn't find any 3c523 in the slots we checked for */
-	if (slot == MCA_NOTFOUND) {
-		retval = ((base_addr || irq) ? -ENXIO : -ENODEV);
-		goto err_out;
-	}
+	if (slot == MCA_NOTFOUND)
+		return ((base_addr || irq) ? -ENXIO : -ENODEV);
+
 	mca_set_adapter_name(slot, "3Com 3c523 Etherlink/MC");
 	mca_set_adapter_procfn(slot, (MCA_ProcFn) elmc_getinfo, dev);
 
@@ -497,13 +496,7 @@
 		break;
 	}
 
-	pr = dev->priv = kmalloc(sizeof(struct priv), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		retval = -ENOMEM;
-		goto err_out;
-	}
 	memset(pr, 0, sizeof(struct priv));
-
 	pr->slot = slot;
 
 	printk(KERN_INFO "%s: 3Com 3c523 Rev 0x%x at %#lx\n", dev->name, (int) revision,
@@ -530,8 +523,6 @@
 	if (!check586(dev, dev->mem_start, size)) {
 		printk(KERN_ERR "%s: memprobe, Can't find memory at 0x%lx!\n", dev->name,
 		       dev->mem_start);
-		kfree(dev->priv);
-		dev->priv = NULL;
 		retval = -ENODEV;
 		goto err_out;
 	}
@@ -573,8 +564,6 @@
 #endif
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	
-	ether_setup(dev);
-
 	/* note that we haven't actually requested the IRQ from the kernel.
 	   That gets done in elmc_open().  I'm not sure that's such a good idea,
 	   but it works, so I'll go with it. */
@@ -585,9 +574,41 @@
 
 	return 0;
 err_out:
+	mca_set_adapter_procfn(slot, NULL, NULL);
 	release_region(dev->base_addr, ELMC_IO_EXTENT);
 	return retval;
 }
+ 
+static void cleanup_card(struct net_device *dev)
+{
+	mca_set_adapter_procfn(((struct priv *) (dev->priv))->slot, NULL, NULL);
+	release_region(dev->base_addr, ELMC_IO_EXTENT);
+}
+
+struct net_device * __init elmc_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct priv));
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	err = do_elmc_probe(dev);
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	cleanup_card(dev);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
 
 /**********************************************
  * init the chip (elmc-interrupt should be disabled?!)
@@ -1245,7 +1266,7 @@
 /* Increase if needed ;) */
 #define MAX_3C523_CARDS 4
 
-static struct net_device dev_elmc[MAX_3C523_CARDS];
+static struct net_device *dev_elmc[MAX_3C523_CARDS];
 static int irq[MAX_3C523_CARDS];
 static int io[MAX_3C523_CARDS];
 MODULE_PARM(irq, "1-" __MODULE_STRING(MAX_3C523_CARDS) "i");
@@ -1258,16 +1279,24 @@
 	int this_dev,found = 0;
 
 	/* Loop until we either can't find any more cards, or we have MAX_3C523_CARDS */	
-	for(this_dev=0; this_dev<MAX_3C523_CARDS; this_dev++) 
-		{
-		struct net_device *dev = &dev_elmc[this_dev];
+	for(this_dev=0; this_dev<MAX_3C523_CARDS; this_dev++) {
+		struct net_device *dev = alloc_etherdev(sizeof(struct priv));
+		if (!dev)
+			break;
 		dev->irq=irq[this_dev];
 		dev->base_addr=io[this_dev];
-		dev->init=elmc_probe;
-		if(register_netdev(dev)!=0) {
-			if(io[this_dev]==0) break;
-			printk(KERN_WARNING "3c523.c: No 3c523 card found at io=%#x\n",io[this_dev]);
-		} else found++;
+		if (do_elmc_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_elmc[this_dev] = dev;
+				found++;
+				continue;
+			}
+			cleanup_card(dev);
+		}
+		free_netdev(dev);
+		if (io[this_dev]==0)
+			break;
+		printk(KERN_WARNING "3c523.c: No 3c523 card found at io=%#x\n",io[this_dev]);
 	}
 
 	if(found==0) {
@@ -1279,31 +1308,12 @@
 void cleanup_module(void)
 {
 	int this_dev;
-	for(this_dev=0; this_dev<MAX_3C523_CARDS; this_dev++) {
-
-		struct net_device *dev = &dev_elmc[this_dev];
-		if(dev->priv) {
-			/* shutdown interrupts on the card */
-			elmc_id_reset586();
-			if (dev->irq != 0) {
-				/* this should be done by close, but if we failed to
-				   initialize properly something may have gotten hosed. */
-				free_irq(dev->irq, dev);
-				dev->irq = 0;
-			}
-			if (dev->base_addr != 0) {
-				release_region(dev->base_addr, ELMC_IO_EXTENT);
-				dev->base_addr = 0;
-			}
-			irq[this_dev] = 0;
-			io[this_dev] = 0;
+	for (this_dev=0; this_dev<MAX_3C523_CARDS; this_dev++) {
+		struct net_device *dev = dev_elmc[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-
-			mca_set_adapter_procfn(((struct priv *) (dev->priv))->slot,
-			       NULL, NULL);
-
-			kfree(dev->priv);
-			dev->priv = NULL;
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 13:50:42 2003
+++ b/drivers/net/Space.c	Tue Nov 11 13:50:42 2003
@@ -60,7 +60,7 @@
 extern struct net_device *wavelan_probe(int unit);
 extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
-extern int elmc_probe(struct net_device *);
+extern struct net_device *elmc_probe(int unit);
 extern struct net_device *skmca_probe(int unit);
 extern struct net_device *elplus_probe(int unit);
 extern int ac3200_probe(struct net_device *);
@@ -181,13 +181,13 @@
 #ifdef CONFIG_NE2_MCA
 	{ne2_probe, 0},
 #endif
-#ifdef CONFIG_ELMC		/* 3c523 */
-	{elmc_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 mca_probes2[] __initdata = {
+#ifdef CONFIG_ELMC		/* 3c523 */
+	{elmc_probe, 0},
+#endif
 #ifdef CONFIG_ELMC_II		/* 3c527 */
 	{mc32_probe, 0},
 #endif
