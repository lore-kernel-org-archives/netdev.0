From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (40/42) sun3_82586
Date: Wed, 12 Nov 2003 16:46:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130046.hAD0kwA31549@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE66-sun3_82586
	* switched to dynamic allocation
	* fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Nov 12 16:16:14 2003
+++ b/drivers/net/Space.c	Wed Nov 12 16:16:14 2003
@@ -76,7 +76,7 @@
 extern struct net_device *smc_init(int unit);
 extern int atarilance_probe(struct net_device *);
 extern int sun3lance_probe(struct net_device *);
-extern int sun3_82586_probe(struct net_device *);
+extern struct net_device *sun3_82586_probe(int unit);
 extern struct net_device *apne_probe(int unit);
 extern struct net_device *bionet_probe(int unit);
 extern struct net_device *pamsnet_probe(int unit);
@@ -302,13 +302,13 @@
 #ifdef CONFIG_SUN3LANCE         /* sun3 onboard Lance chip */
 	{sun3lance_probe, 0},
 #endif
-#ifdef CONFIG_SUN3_82586        /* sun3 onboard Intel 82586 chip */
-	{sun3_82586_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 m68k_probes2[] __initdata = {
+#ifdef CONFIG_SUN3_82586        /* sun3 onboard Intel 82586 chip */
+	{sun3_82586_probe, 0},
+#endif
 #ifdef CONFIG_APNE		/* A1200 PCMCIA NE2000 */
 	{apne_probe, 0},
 #endif
diff -Nru a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
--- a/drivers/net/sun3_82586.c	Wed Nov 12 16:16:14 2003
+++ b/drivers/net/sun3_82586.c	Wed Nov 12 16:16:14 2003
@@ -277,10 +277,12 @@
 	memset((char *)p->scb,0,sizeof(struct scb_struct));
 }
 
-int __init sun3_82586_probe(struct net_device *dev)
+struct net_device * __init sun3_82586_probe(int unit)
 {
+	struct net_device *dev;
 	unsigned long ioaddr;
 	static int found = 0;
+	int err = -ENOMEM;
 	
 	/* check that this machine has an onboard 82586 */
 	switch(idprom->id_machtype) {
@@ -290,31 +292,51 @@
 		break;
 
 	default:
-		return(-ENODEV);
+		return ERR_PTR(-ENODEV);
 	}
 
-	if(found)
-		return -ENODEV;
+	if (found)
+		return ERR_PTR(-ENODEV);
 	
 	ioaddr = (unsigned long)ioremap(IE_OBIO, PAGE_SIZE);
+	if (!ioaddr)
+		return ERR_PTR(-ENOMEM);
 	found = 1;
 	
+	dev = alloc_etherdev(sizeof(struct priv));
+	if (!dev)
+		goto out;
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 	SET_MODULE_OWNER(dev);
 
 	dev->irq = IE_IRQ;
 	dev->base_addr = ioaddr;
-	if(sun3_82586_probe1(dev, ioaddr) == 0)
-		return 0;
-
-	return -ENODEV;
+	err = sun3_82586_probe1(dev, ioaddr);
+	if (err)
+		goto out1;
+	err = register_netdev(dev);
+	if (err)
+		goto out2;
+	return dev;
+
+out2:
+	release_region(ioaddr, SUN3_82586_TOTAL_SIZE);
+out1:
+	free_netdev(dev);
+out:
+	iounmap(ioaddr);
+	return ERR_PTR(err);
 }
 
 static int __init sun3_82586_probe1(struct net_device *dev,int ioaddr)
 {
 	int i, size, retval;
 
-//	if (!request_region(ioaddr, SUN3_82586_TOTAL_SIZE, dev->name))
-//		return -EBUSY;
+	if (!request_region(ioaddr, SUN3_82586_TOTAL_SIZE, dev->name))
+		return -EBUSY;
 
 	/* copy in the ethernet address from the prom */
 	for(i = 0; i < 6 ; i++)
@@ -341,16 +363,6 @@
 		goto out;
 	}
 
-	dev->priv = (void *) kmalloc(sizeof(struct priv),GFP_KERNEL);
-	if(dev->priv == NULL) {
-		printk("%s: Ooops .. can't allocate private driver memory.\n",dev->name);
-		retval = -ENOMEM;
-		goto out;
-	}
-
-	/* warning: we don't free it on errors */
-	memset((char *) dev->priv,0,sizeof(struct priv));
-
 	((struct priv *) (dev->priv))->memtop = (char *)dvma_btov(dev->mem_start);
 	((struct priv *) (dev->priv))->base = (unsigned long) dvma_btov(0);
 	alloc586(dev);
@@ -374,11 +386,9 @@
 	dev->set_multicast_list = set_multicast_list;
 
 	dev->if_port 		= 0;
-
-	ether_setup(dev);
-
 	return 0;
 out:
+	release_region(ioaddr, SUN3_82586_TOTAL_SIZE);
 	return retval;
 }
 
@@ -1138,21 +1148,23 @@
 
 #ifdef MODULE
 #error This code is not currently supported as a module
-static struct net_device dev_sun3_82586;
+static struct net_device *dev_sun3_82586;
 
 int init_module(void)
 {
-	dev_sun3_82586.init = sun3_82586_probe;
-	if (register_netdev(&dev_sun3_82586) != 0)
-		return -EIO;
+	dev_sun3_82586 = sun3_82586_probe(-1);
+	if (IS_ERR(dev_sun3_82586))
+		return PTR_ERR(dev_sun3_82586);
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	unregister_netdev(&dev_sun3_82586);
-	kfree(dev_sun3_82586.priv);
-	dev_sun3_82586.priv = NULL;
+	unsigned long ioaddr = dev_sun3_82586->base_addr;
+	unregister_netdev(dev_sun3_82586);
+	release_region(ioaddr, SUN3_82586_TOTAL_SIZE);
+	iounmap(ioaddr);
+	free_netdev(dev);
 }
 #endif /* MODULE */
 
