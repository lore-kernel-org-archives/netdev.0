From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] switch skfp over to initcalls
Date: Mon, 9 Jun 2003 14:06:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609120603.GA31393@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a PCI driver and has no business in Space.c.  Also
allows to kill all the fddi code in there (and the stale
reference to the long gone apfddi driver)


--- 1.20/drivers/net/Space.c	Wed May 21 03:56:26 2003
+++ edited/drivers/net/Space.c	Tue Jun  3 22:17:09 2003
@@ -105,9 +105,6 @@
 /* Detachable devices ("pocket adaptors") */
 extern int de620_probe(struct net_device *);
 
-/* FDDI adapters */
-extern int skfp_probe(struct net_device *dev);
-
 /* Fibre Channel adapters */
 extern int iph5526_probe(struct net_device *dev);
 
@@ -401,29 +398,6 @@
 	return -ENODEV;
 }
 
-#ifdef CONFIG_FDDI
-static int __init fddiif_probe(struct net_device *dev)
-{
-    unsigned long base_addr = dev->base_addr;
-
-    if (base_addr == 1)
-	    return 1;		/* ENXIO */
-
-    if (1
-#ifdef CONFIG_APFDDI
-	&& apfddi_init(dev)
-#endif
-#ifdef CONFIG_SKFP
-	&& skfp_probe(dev)
-#endif
-	&& 1 ) {
-	    return 1;	/* -ENODEV or -EAGAIN would be more accurate. */
-    }
-    return 0;
-}
-#endif
-
-
 #ifdef CONFIG_NET_FC
 static int fcif_probe(struct net_device *dev)
 {
@@ -614,52 +588,6 @@
 #define      NEXT_DEV        (&tr0_dev)
 
 #endif 
-
-#ifdef CONFIG_FDDI
-static struct net_device fddi7_dev = {
-	.name		= "fddi7",
-	.next		=  NEXT_DEV,
-	.init		= fddiif_probe
-};
-static struct net_device fddi6_dev = {
-	.name		= "fddi6",
-	.next		= &fddi7_dev,
-	.init		= fddiif_probe
-};
-static struct net_device fddi5_dev = {
-	.name		= "fddi5",
-	.next		= &fddi6_dev,
-	.init		= fddiif_probe
-};
-static struct net_device fddi4_dev = {
-	.name		= "fddi4",
-	.next		= &fddi5_dev,
-	.init		= fddiif_probe
-};
-static struct net_device fddi3_dev = {
-	.name		= "fddi3",
-	.next		= &fddi4_dev,
-	.init		= fddiif_probe
-};
-static struct net_device fddi2_dev = {
-	.name		= "fddi2",
-	.next		= &fddi3_dev,
-	.init		= fddiif_probe
-};
-static struct net_device fddi1_dev = {
-	.name		= "fddi1",
-	.next		= &fddi2_dev,
-	.init		= fddiif_probe
-};
-static struct net_device fddi0_dev = {
-	.name		= "fddi0",
-	.next		= &fddi1_dev,
-	.init		= fddiif_probe
-};
-#undef	NEXT_DEV
-#define	NEXT_DEV	(&fddi0_dev)
-#endif 
-
 
 #ifdef CONFIG_NET_FC
 static struct net_device fc1_dev = {
--- 1.12/drivers/net/skfp/skfddi.c	Fri May  9 02:40:17 2003
+++ edited/drivers/net/skfp/skfddi.c	Tue Jun  3 22:19:04 2003
@@ -2539,72 +2539,25 @@
 }				// drv_reset_indication
 
 
-
-//--------------- functions for use as a module ----------------
-
-#ifdef MODULE
-/************************
- *
- * Note now that module autoprobing is allowed under PCI. The
- * IRQ lines will not be auto-detected; instead I'll rely on the BIOSes
- * to "do the right thing".
- *
- ************************/
-#define LP(a) ((struct s_smc*)(a))
 static struct net_device *mdev;
 
-/************************
- *
- * init_module
- *
- *  If compiled as a module, find
- *  adapters and initialize them.
- *
- ************************/
-int init_module(void)
+static int __init skfd_init(void)
 {
 	struct net_device *p;
 
-	PRINTK(KERN_INFO "FDDI init module\n");
 	if ((mdev = insert_device(NULL, skfp_probe)) == NULL)
 		return -ENOMEM;
 
-	for (p = mdev; p != NULL; p = LP(p->priv)->os.next_module) {
-		PRINTK(KERN_INFO "device to register: %s\n", p->name);
+	for (p = mdev; p != NULL; p = ((struct s_smc *)p->priv)->os.next_module) {
 		if (register_netdev(p) != 0) {
 			printk("skfddi init_module failed\n");
 			return -EIO;
 		}
 	}
 
-	PRINTK(KERN_INFO "+++++ exit with success +++++\n");
 	return 0;
-}				// init_module
+}
 
-/************************
- *
- * cleanup_module
- *
- *  Release all resources claimed by this module.
- *
- ************************/
-void cleanup_module(void)
-{
-	PRINTK(KERN_INFO "cleanup_module\n");
-	while (mdev != NULL) {
-		mdev = unlink_modules(mdev);
-	}
-	return;
-}				// cleanup_module
-
-
-/************************
- *
- * unlink_modules
- *
- *  Unregister devices and release their memory.
- *
- ************************/
 static struct net_device *unlink_modules(struct net_device *p)
 {
 	struct net_device *next = NULL;
@@ -2638,5 +2591,11 @@
 	return next;
 }				// unlink_modules
 
+static void __exit skfd_exit(void)
+{
+	while (mdev)
+		mdev = unlink_modules(mdev);
+}
 
-#endif				/* MODULE */
+module_init(skfd_init);
+module_exit(skfd_exit);
