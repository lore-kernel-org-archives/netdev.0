From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (24/42) ne2
Date: Wed, 12 Nov 2003 16:44:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130044.hAD0iIv30919@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE48-ne2 from viro
	* switched ne2 to dynamic allocation
	* ne2: fixed order of freeing bugs
	* ne2: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 13:52:10 2003
+++ b/drivers/net/Space.c	Tue Nov 11 13:52:10 2003
@@ -40,7 +40,7 @@
    ethernet adaptor have the name "eth[0123...]".
    */
 
-extern int ne2_probe(struct net_device *dev);
+extern struct net_device *ne2_probe(int unit);
 extern struct net_device *hp100_probe(int unit);
 extern struct net_device *ultra_probe(int unit);
 extern int ultra32_probe(struct net_device *dev);
@@ -176,15 +176,10 @@
 	{NULL, 0},
 };
 
-
-static struct devprobe mca_probes[] __initdata = {
+static struct devprobe2 mca_probes[] __initdata = {
 #ifdef CONFIG_NE2_MCA
 	{ne2_probe, 0},
 #endif
-	{NULL, 0},
-};
-
-static struct devprobe2 mca_probes2[] __initdata = {
 #ifdef CONFIG_ELMC		/* 3c523 */
 	{elmc_probe, 0},
 #endif
@@ -201,7 +196,7 @@
  * ISA probes that touch addresses < 0x400 (including those that also
  * look for EISA/PCI/MCA cards in addition to ISA cards).
  */
-static struct devprobe2 isa_probes2[] __initdata = {
+static struct devprobe2 isa_probes[] __initdata = {
 #ifdef CONFIG_HP100 		/* ISA, EISA & PCI */
 	{hp100_probe, 0},
 #endif	
@@ -381,8 +376,7 @@
 	 */
 	if (probe_list(dev, m68k_probes) == 0 ||
 	    probe_list(dev, mips_probes) == 0 ||
-	    probe_list(dev, eisa_probes) == 0 ||
-	    probe_list(dev, mca_probes) == 0)
+	    probe_list(dev, eisa_probes) == 0)
 		err = register_netdev(dev);
 
 	if (err)
@@ -398,8 +392,8 @@
 	if (base_addr == 1)
 		return;
 
-	probe_list2(unit, mca_probes2, base_addr == 0) &&
-	probe_list2(unit, isa_probes2, base_addr == 0) &&
+	probe_list2(unit, mca_probes, base_addr == 0) &&
+	probe_list2(unit, isa_probes, base_addr == 0) &&
 	probe_list2(unit, parport_probes, base_addr == 0);
 }
 
diff -Nru a/drivers/net/ne2.c b/drivers/net/ne2.c
--- a/drivers/net/ne2.c	Tue Nov 11 13:52:10 2003
+++ b/drivers/net/ne2.c	Tue Nov 11 13:52:10 2003
@@ -242,7 +242,7 @@
  * Note that at boot, this probe only picks up one card at a time.
  */
 
-int __init ne2_probe(struct net_device *dev)
+static int __init do_ne2_probe(struct net_device *dev)
 {
 	static int current_mca_slot = -1;
 	int i;
@@ -262,16 +262,55 @@
 			mca_find_unused_adapter(ne2_adapters[i].id, 0);
 
 		if((current_mca_slot != MCA_NOTFOUND) && !adapter_found) {
+			int res;
 			mca_set_adapter_name(current_mca_slot, 
 					ne2_adapters[i].name);
 			mca_mark_as_used(current_mca_slot);
 			
-			return ne2_probe1(dev, current_mca_slot);
+			res = ne2_probe1(dev, current_mca_slot);
+			if (res)
+				mca_mark_as_unused(current_mca_slot);
+			return res;
 		}
 	}
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	mca_mark_as_unused(ei_status.priv);
+	mca_set_adapter_procfn( ei_status.priv, NULL, NULL);
+	kfree(dev->priv);
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, NE_IO_EXTENT);
+}
+
+struct net_device * __init ne2_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(0);
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+
+	dev->priv = NULL;	/* until all 8390-based use alloc_etherdev() */
+
+	err = do_ne2_probe(dev);
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
 
 static int ne2_procinfo(char *buf, int slot, struct net_device *dev)
 {
@@ -735,7 +774,7 @@
 
 #ifdef MODULE
 #define MAX_NE_CARDS	4	/* Max number of NE cards per module */
-static struct net_device dev_ne[MAX_NE_CARDS];
+static struct net_device *dev_ne[MAX_NE_CARDS];
 static int io[MAX_NE_CARDS];
 static int irq[MAX_NE_CARDS];
 static int bad[MAX_NE_CARDS];	/* 0xbad = bad sig or no reset ack */
@@ -754,23 +793,31 @@
 
 int init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne[this_dev];
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
 		dev->irq = irq[this_dev];
 		dev->mem_end = bad[this_dev];
 		dev->base_addr = io[this_dev];
-		dev->init = ne2_probe;
-		if (register_netdev(dev) != 0) {
-			if (found != 0) return 0;   /* Got at least one. */
-
-			printk(KERN_WARNING "ne2.c: No NE/2 card found.\n");
-			return -ENXIO;
+		if (do_ne2_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_ne[found++] = dev;
+				continue;
+			}
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	printk(KERN_WARNING "ne2.c: No NE/2 card found\n");
+	return -ENXIO;
 }
 
 void cleanup_module(void)
@@ -778,14 +825,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = &dev_ne[this_dev];
-		if (dev->priv != NULL) {
-			mca_mark_as_unused(ei_status.priv);
-			mca_set_adapter_procfn( ei_status.priv, NULL, NULL);
-			kfree(dev->priv);
-			free_irq(dev->irq, dev);
-			release_region(dev->base_addr, NE_IO_EXTENT);
+		struct net_device *dev = dev_ne[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
