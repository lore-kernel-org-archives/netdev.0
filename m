From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (41/42) sun3_lance
Date: Wed, 12 Nov 2003 16:47:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130047.hAD0l8n31630@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE67-sun3lance
	* switched to dynamic allocation
	* fixed resource leaks on failure exits

diff -urN B9-sun3_82586/drivers/net/Space.c B9-sun3_lance/drivers/net/Space.c
--- B9-sun3_82586/drivers/net/Space.c	Tue Nov 11 20:25:10 2003
+++ B9-sun3_lance/drivers/net/Space.c	Tue Nov 11 20:49:12 2003
@@ -75,7 +75,7 @@
 extern struct net_device *seeq8005_probe(int unit);
 extern struct net_device *smc_init(int unit);
 extern int atarilance_probe(struct net_device *);
-extern int sun3lance_probe(struct net_device *);
+extern struct net_device *sun3lance_probe(int unit);
 extern struct net_device *sun3_82586_probe(int unit);
 extern struct net_device *apne_probe(int unit);
 extern struct net_device *bionet_probe(int unit);
@@ -300,13 +300,13 @@
 #ifdef CONFIG_ATARILANCE	/* Lance-based Atari ethernet boards */
 	{atarilance_probe, 0},
 #endif
-#ifdef CONFIG_SUN3LANCE         /* sun3 onboard Lance chip */
-	{sun3lance_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_SUN3LANCE         /* sun3 onboard Lance chip */
+	{sun3lance_probe, 0},
+#endif
 #ifdef CONFIG_SUN3_82586        /* sun3 onboard Intel 82586 chip */
 	{sun3_82586_probe, 0},
 #endif
diff -urN B9-sun3_82586/drivers/net/sun3lance.c B9-sun3_lance/drivers/net/sun3lance.c
--- B9-sun3_82586/drivers/net/sun3lance.c	Mon May 26 22:21:36 2003
+++ B9-sun3_lance/drivers/net/sun3lance.c	Tue Nov 11 20:49:12 2003
@@ -246,9 +246,11 @@
 
 /************************* End of Prototypes **************************/
 
-int __init sun3lance_probe( struct net_device *dev )
-{	
+struct net_device * __init sun3lance_probe(int unit)
+{
+	struct net_device *dev;
 	static int found;
+	int err = -ENODEV;
 
 	/* check that this machine has an onboard lance */
 	switch(idprom->id_machtype) {
@@ -259,18 +261,37 @@
 		break;
 
 	default:
-		return(-ENODEV);
+		return ERR_PTR(-ENODEV);
 	}
 
-	if(found)
-		return(-ENODEV);
+	if (found)
+		return ERR_PTR(-ENODEV);
 
-	if (lance_probe(dev)) {
-			found = 1;
-			return( 0 );
+	dev = alloc_etherdev(sizeof(struct lance_private));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
 	}
+	SET_MODULE_OWNER(dev);
+
+	if (!lance_probe(dev))
+		goto out;
 
-	return( -ENODEV );
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	found = 1;
+	return dev;
+
+out1:
+#ifdef CONFIG_SUN3
+	iounmap(dev->base_addr);
+#endif
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static int __init lance_probe( struct net_device *dev)
@@ -285,6 +306,8 @@
 
 #ifdef CONFIG_SUN3
 	ioaddr = (unsigned long)ioremap(LANCE_OBIO, PAGE_SIZE);
+	if (!ioaddr)
+		return 0;
 #else
 	ioaddr = SUN3X_LANCE;
 #endif
@@ -303,17 +326,15 @@
 		ioaddr_probe[0] = tmp1;
 		ioaddr_probe[1] = tmp2;
 
+#ifdef CONFIG_SUN3
+		iounmap(ioaddr);
+#endif
 		return 0;
 	}
 
-	init_etherdev( dev, sizeof(struct lance_private) );
-	if (!dev->priv) {
-		dev->priv = kmalloc( sizeof(struct lance_private), GFP_KERNEL );
-		if (!dev->priv)
-			return 0;
-	}
 	lp = (struct lance_private *)dev->priv;
 
+	/* XXX - leak? */
 	MEM = dvma_malloc_align(sizeof(struct lance_memory), 0x10000);
 
 	lp->iobase = (volatile unsigned short *)ioaddr;
@@ -921,32 +942,24 @@
 
 
 #ifdef MODULE
-static char devicename[9];
 
-static struct net_device sun3lance_dev =
-{
-	devicename,	/* filled in by register_netdev() */
-	0, 0, 0, 0,	/* memory */
-	0, 0,		/* base, irq */
-	0, 0, 0, NULL, sun3lance_probe,
-};
+static struct net_device *sun3lance_dev;
 
 int init_module(void)
 {
-	int err;
-
-	if ((err = register_netdev( &sun3lance_dev ))) {
-		if (err == -EIO)  {
-			printk( "SUN3 Lance not detected.  Module not loaded.\n");
-		}
-		return( err );
-	}
-	return( 0 );
+	sun3lance_dev = sun3lance_probe(-1);
+	if (IS_ERR(sun3lance_dev))
+		return PTR_ERR(sun3lance_dev);
+	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev( &sun3lance_dev );
+	unregister_netdev(sun3lance_dev);
+#ifdef CONFIG_SUN3
+	iounmap(sun3lance_dev->base_addr);
+#endif
+	free_netdev(sun3lance_dev);
 }
 
 #endif /* MODULE */
