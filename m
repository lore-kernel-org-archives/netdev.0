From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (13/42) e2100
Date: Wed, 12 Nov 2003 16:42:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130042.hAD0gSK30513@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE37-e2100
	* switched e2100 to dynamic allocation
	* e2100: fixed order of freeing bugs
	* e2100: fixed resource leaks on failure exits
	* e2100: fixed clobbering on autoprobe

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:55 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:55 2003
@@ -66,7 +66,7 @@
 extern int ac3200_probe(struct net_device *);
 extern int es_probe(struct net_device *);
 extern int lne390_probe(struct net_device *);
-extern int e2100_probe(struct net_device *);
+extern struct net_device *e2100_probe(int unit);
 extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
@@ -219,13 +219,13 @@
 #ifdef CONFIG_HPLAN_PLUS
 	{hp_plus_probe, 0},
 #endif
-#ifdef CONFIG_E2100		/* Cabletron E21xx series. */
-	{e2100_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_E2100		/* Cabletron E21xx series. */
+	{e2100_probe, 0},
+#endif
 #if defined(CONFIG_NE2000) || defined(CONFIG_NE2K_CBUS)	/* ISA & PC-9800 CBUS (use ne2k-pci for PCI cards) */
 	{ne_probe, 0},
 #endif
diff -Nru a/drivers/net/e2100.c b/drivers/net/e2100.c
--- a/drivers/net/e2100.c	Tue Nov 11 09:35:55 2003
+++ b/drivers/net/e2100.c	Tue Nov 11 09:35:55 2003
@@ -95,7 +95,6 @@
 #define E21_BIG_RX_STOP_PG	0xF0	/* Last page +1 of RX ring */
 #define E21_TX_START_PG		E21_RX_STOP_PG	/* First page of TX buffer */
 
-int e2100_probe(struct net_device *dev);
 static int e21_probe1(struct net_device *dev, int ioaddr);
 
 static int e21_open(struct net_device *dev);
@@ -117,10 +116,11 @@
 	station address).
  */
 
-int  __init e2100_probe(struct net_device *dev)
+static int  __init do_e2100_probe(struct net_device *dev)
 {
 	int *port;
 	int base_addr = dev->base_addr;
+	int irq = dev->irq;
 
 	SET_MODULE_OWNER(dev);
 
@@ -129,13 +129,50 @@
 	else if (base_addr != 0)	/* Don't probe at all. */
 		return -ENXIO;
 
-	for (port = e21_probe_list; *port; port++)
+	for (port = e21_probe_list; *port; port++) {
+		dev->irq = irq;
 		if (e21_probe1(dev, *port) == 0)
 			return 0;
+	}
 
 	return -ENODEV;
 }
 
+static void cleanup_card(struct net_device *dev)
+{
+	void *priv = dev->priv;
+	/* NB: e21_close() handles free_irq */
+	release_region(dev->base_addr, E21_IO_EXTENT);
+	kfree(priv);
+}
+
+struct net_device * __init e2100_probe(int unit)
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
+	err = do_e2100_probe(dev);
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
 static int __init e21_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, status, retval;
@@ -376,7 +413,7 @@
 
 #ifdef MODULE
 #define MAX_E21_CARDS	4	/* Max number of E21 cards per module */
-static struct net_device dev_e21[MAX_E21_CARDS];
+static struct net_device *dev_e21[MAX_E21_CARDS];
 static int io[MAX_E21_CARDS];
 static int irq[MAX_E21_CARDS];
 static int mem[MAX_E21_CARDS];
@@ -398,29 +435,36 @@
 int
 init_module(void)
 {
+	struct net_device *dev;
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_E21_CARDS; this_dev++) {
-		struct net_device *dev = &dev_e21[this_dev];
-		dev->irq = irq[this_dev];
-		dev->base_addr = io[this_dev];
-		dev->mem_start = mem[this_dev];
-		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
-		dev->init = e2100_probe;
 		if (io[this_dev] == 0)  {
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "e2100.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		if (register_netdev(dev) != 0) {
-			printk(KERN_WARNING "e2100.c: No E2100 card found (i/o = 0x%x).\n", io[this_dev]);
-			if (found != 0) {	/* Got at least one. */
-				return 0;
+		dev = alloc_etherdev(0);
+		if (!dev)
+			break;
+		dev->priv = NULL;
+		dev->irq = irq[this_dev];
+		dev->base_addr = io[this_dev];
+		dev->mem_start = mem[this_dev];
+		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
+		if (do_e2100_probe(dev) == 0) {
+			if (register_netdev(dev) == 0) {
+				dev_e21[found++] = dev;
+				continue;
 			}
-			return -ENXIO;
+			cleanup_card(dev);
 		}
-		found++;
+		free_netdev(dev);
+		printk(KERN_WARNING "e2100.c: No E2100 card found (i/o = 0x%x).\n", io[this_dev]);
+		break;
 	}
-	return 0;
+	if (found)
+		return 0;
+	return -ENXIO;
 }
 
 void
@@ -429,13 +473,11 @@
 	int this_dev;
 
 	for (this_dev = 0; this_dev < MAX_E21_CARDS; this_dev++) {
-		struct net_device *dev = &dev_e21[this_dev];
-		if (dev->priv != NULL) {
-			void *priv = dev->priv;
-			/* NB: e21_close() handles free_irq */
-			release_region(dev->base_addr, E21_IO_EXTENT);
+		struct net_device *dev = dev_e21[this_dev];
+		if (dev) {
 			unregister_netdev(dev);
-			kfree(priv);
+			cleanup_card(dev);
+			free_netdev(dev);
 		}
 	}
 }
