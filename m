From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (15/42) hp
Date: Wed, 12 Nov 2003 16:42:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130042.hAD0gmt30618@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE39-hp
	* switched hp to dynamic allocation
	* hp: fixed order of freeing bugs
	* hp: fixed resource leaks on failure exits
	* hp: fixed clobbering on autoprobe


diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:36:00 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:36:00 2003
@@ -47,7 +47,7 @@
 extern int wd_probe(struct net_device *dev);
 extern int el2_probe(struct net_device *dev);
 extern struct net_device *ne_probe(int unit);
-extern int hp_probe(struct net_device *dev);
+extern struct net_device *hp_probe(int unit);
 extern struct net_device *hp_plus_probe(int unit);
 extern struct net_device *express_probe(int unit);
 extern struct net_device *eepro_probe(int unit);
@@ -213,13 +213,13 @@
 #ifdef CONFIG_EL2 		/* 3c503 */
 	{el2_probe, 0},
 #endif
-#ifdef CONFIG_HPLAN
-	{hp_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_HPLAN
+	{hp_probe, 0},
+#endif
 #ifdef CONFIG_HPLAN_PLUS
 	{hp_plus_probe, 0},
 #endif
diff -Nru a/drivers/net/hp.c b/drivers/net/hp.c
--- a/drivers/net/hp.c	Tue Nov 11 09:36:00 2003
+++ b/drivers/net/hp.c	Tue Nov 11 09:36:00 2003
@@ -55,7 +55,6 @@
 #define HP_8BSTOP_PG	0x80	/* Last page +1 of RX ring */
 #define HP_16BSTOP_PG	0xFF	/* Same, for 16 bit cards. */
 
-int hp_probe(struct net_device *dev);
 static int hp_probe1(struct net_device *dev, int ioaddr);
 
 static int hp_open(struct net_device *dev);
@@ -79,10 +78,11 @@
 	Also initialize the card and fill in STATION_ADDR with the station
 	address. */
 
-int __init hp_probe(struct net_device *dev)
+static int __init do_hp_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;
+	int irq = dev->irq;
 
 	SET_MODULE_OWNER(dev);
 
@@ -91,13 +91,49 @@
 	else if (base_addr != 0)	/* Don't probe at all. */
 		return -ENXIO;
 
-	for (i = 0; hppclan_portlist[i]; i++)
+	for (i = 0; hppclan_portlist[i]; i++) {
 		if (hp_probe1(dev, hppclan_portlist[i]) == 0)
 			return 0;
+		dev->irq = irq;
+	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr - NIC_OFFSET, HP_IO_EXTENT);
+	kfree(dev->priv);
+}
+
+struct net_device * __init hp_probe(int unit)
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
+	err = do_hp_probe(dev);
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
+
 static int __init hp_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, retval, board_id, wordmode;
@@ -372,7 +408,7 @@
 
 #ifdef MODULE
 #define MAX_HP_CARDS	4	/* Max number of HP cards per module */
-static struct net_device dev_hp[MAX_HP_CARDS];
+static struct net_device *dev_hp[MAX_HP_CARDS];
 static int io[MAX_HP_CARDS];
 static int irq[MAX_HP_CARDS];
 
@@ -388,27 +424,34 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_HP_CARDS; this_dev++) {
-		struct net_device *dev = &dev_hp[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->init = hp_probe;
 		if (io[this_dev] == 0)  {
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "hp.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "hp.c: No HP card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
+		dev->irq = irq[this_dev];
+		dev->base_addr = io[this_dev];
+		if (do_hp_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_hp[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "hp.c: No HP card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -417,14 +460,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_HP_CARDS; this_dev++) {
-		struct net_device *dev = &dev_hp[this_dev];
-		if (dev->priv != NULL) {
-			int ioaddr = dev->base_addr - NIC_OFFSET;
-			void *priv = dev->priv;
-			free_irq(dev->irq, dev);
-			release_region(ioaddr, HP_IO_EXTENT);
+		struct net_device *dev = dev_hp[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
