From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (42/42) atari_lance
Date: Wed, 12 Nov 2003 16:47:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130047.hAD0lI431741@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE68-atarilance
	* switched to dynamic allocation
	* fixed resource leaks on failure exits
	* also kill off last usage of probe_list

diff -urN B9-sun3_lance/drivers/net/Space.c B9-atari_lance/drivers/net/Space.c
--- B9-sun3_lance/drivers/net/Space.c	Tue Nov 11 20:49:12 2003
+++ B9-atari_lance/drivers/net/Space.c	Tue Nov 11 21:17:48 2003
@@ -74,7 +74,7 @@
 extern struct net_device *SK_init(int unit);
 extern struct net_device *seeq8005_probe(int unit);
 extern struct net_device *smc_init(int unit);
-extern int atarilance_probe(struct net_device *);
+extern struct net_device *atarilance_probe(struct net_device *);
 extern struct net_device *sun3lance_probe(int unit);
 extern struct net_device *sun3_82586_probe(int unit);
 extern struct net_device *apne_probe(int unit);
@@ -103,42 +103,11 @@
 /* SBNI adapters */
 extern int sbni_probe(int unit);
 
-struct devprobe
-{
-	int (*probe)(struct net_device *dev);
-	int status;	/* non-zero if autoprobe has failed */
-};
-
 struct devprobe2 {
 	struct net_device *(*probe)(int unit);
 	int status;	/* non-zero if autoprobe has failed */
 };
 
-/*
- * probe_list walks a list of probe functions and calls each so long
- * as a non-zero ioaddr is given, or as long as it hasn't already failed 
- * to find a card in the past (as recorded by "status") when asked to
- * autoprobe (i.e. a probe that fails to find a card when autoprobing
- * will not be asked to autoprobe again).  It exits when a card is found.
- */
-static int __init probe_list(struct net_device *dev, struct devprobe *plist)
-{
-	struct devprobe *p = plist;
-	unsigned long base_addr = dev->base_addr;
-
-	while (p->probe != NULL) {
-		if (base_addr && p->probe(dev) == 0) 	/* probe given addr */
-			return 0;
-		else if (p->status == 0) {		/* has autoprobe failed yet? */
-			p->status = p->probe(dev);	/* no, try autoprobe */
-			if (p->status == 0)
-				return 0;
-		}
-		p++;
-	}
-	return -ENODEV;
-}
-
 static int __init probe_list2(int unit, struct devprobe2 *p, int autoprobe)
 {
 	struct net_device *dev;
@@ -296,14 +265,10 @@
 	{NULL, 0},
 };
 
-static struct devprobe m68k_probes[] __initdata = {
+static struct devprobe2 m68k_probes[] __initdata = {
 #ifdef CONFIG_ATARILANCE	/* Lance-based Atari ethernet boards */
 	{atarilance_probe, 0},
 #endif
-	{NULL, 0},
-};
-
-static struct devprobe2 m68k_probes2[] __initdata = {
 #ifdef CONFIG_SUN3LANCE         /* sun3 onboard Lance chip */
 	{sun3lance_probe, 0},
 #endif
@@ -355,40 +320,6 @@
  * per bus interface. This drives the legacy devices only for now.
  */
  
-static int __init ethif_probe(int unit)
-{
-	struct net_device *dev;
-	int err = -ENODEV;
-
-	dev = alloc_etherdev(0);
-	if (!dev)
-		return -ENOMEM;
-
-	sprintf(dev->name, "eth%d", unit);
-	netdev_boot_setup_check(dev);
-
-	/* 
-	 * Backwards compatibility - historically an I/O base of 1 was 
-	 * used to indicate not to probe for this ethN interface 
-	 */
-	if (dev->base_addr == 1) {
-		free_netdev(dev);
-		return -ENXIO;
-	}
-
-	/* 
-	 * The arch specific probes are 1st so that any on-board ethernet
-	 * will be probed before other ISA/EISA/MCA/PCI bus cards.
-	 */
-	if (probe_list(dev, m68k_probes) == 0)
-		err = register_netdev(dev);
-
-	if (err)
-		free_netdev(dev);
-	return err;
-
-}
- 
 static void __init ethif_probe2(int unit)
 {
 	unsigned long base_addr = netdev_boot_base("eth", unit);
@@ -396,7 +327,7 @@
 	if (base_addr == 1)
 		return;
 
-	probe_list2(unit, m68k_probes2, base_addr == 0) &&
+	probe_list2(unit, m68k_probes, base_addr == 0) &&
 	probe_list2(unit, mips_probes, base_addr == 0) &&
 	probe_list2(unit, eisa_probes, base_addr == 0) &&
 	probe_list2(unit, mca_probes, base_addr == 0) &&
@@ -485,8 +416,7 @@
 			trif_probe2(num);
 #endif
 	for (num = 0; num < 8; ++num)
-		if (!ethif_probe(num))
-			ethif_probe2(num);
+		ethif_probe2(num);
 
 #ifdef CONFIG_COPS
 	cops_probe(0);
diff -urN B9-sun3_lance/drivers/net/atarilance.c B9-atari_lance/drivers/net/atarilance.c
--- B9-sun3_lance/drivers/net/atarilance.c	Mon May  5 03:28:03 2003
+++ B9-atari_lance/drivers/net/atarilance.c	Tue Nov 11 21:17:48 2003
@@ -371,26 +371,39 @@
 }
 
 
-int __init atarilance_probe( struct net_device *dev )
-{	
+struct net_device * __init atarilance_probe(int unit)
+{
 	int i;
 	static int found;
-
-	SET_MODULE_OWNER(dev);
+	struct net_device *dev;
+	int err = -ENODEV;
 
 	if (!MACH_IS_ATARI || found)
 		/* Assume there's only one board possible... That seems true, since
 		 * the Riebl/PAM board's address cannot be changed. */
-		return( ENODEV );
+		return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(sizeof(struct lance_private));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
+	SET_MODULE_OWNER(dev);
 
 	for( i = 0; i < N_LANCE_ADDR; ++i ) {
 		if (lance_probe1( dev, &lance_addr_list[i] )) {
 			found = 1;
-			return( 0 );
+			err = register_netdev(dev);
+			if (!err)
+				return dev;
+			free_irq(dev->irq, dev);
+			break;
 		}
 	}
-
-	return( ENODEV );
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 
@@ -511,12 +524,6 @@
 	return( 0 );
 
   probe_ok:
-	init_etherdev( dev, sizeof(struct lance_private) );
-	if (!dev->priv) {
-		dev->priv = kmalloc( sizeof(struct lance_private), GFP_KERNEL );
-		if (!dev->priv)
-			return 0;
-	}
 	lp = (struct lance_private *)dev->priv;
 	MEM = (struct lance_memory *)memaddr;
 	IO = lp->iobase = (struct lance_ioreg *)ioaddr;
@@ -1171,26 +1178,21 @@
 
 
 #ifdef MODULE
-static struct net_device atarilance_dev;
+static struct net_device *atarilance_dev;
 
 int init_module(void)
-
-{	int err;
-
-	atarilance_dev.init = atarilance_probe;
-	if ((err = register_netdev( &atarilance_dev ))) {
-		if (err == -EIO)  {
-			printk( "No Atari Lance board found. Module not loaded.\n");
-		}
-		return( err );
-	}
-	return( 0 );
+{
+	atarilance_dev = atarilance_probe(-1);
+	if (IS_ERR(atarilance_dev))
+		return PTR_ERR(atarilance_dev);
+	return 0;
 }
 
 void cleanup_module(void)
-
 {
-	unregister_netdev( &atarilance_dev );
+	unregister_netdev(atarilance_dev);
+	free_irq(atarilance_dev->irq, atarilance_dev);
+	free_netdev(atarilance_dev);
 }
 
 #endif /* MODULE */
