From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] switch sdla to initcalls
Date: Wed, 21 May 2003 10:11:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521101126.A30197@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wow, on driver that had it's dirt fingers in both Space.c and setup.c :)


--- 1.20/drivers/net/Space.c	Wed May 21 03:56:26 2003
+++ edited/drivers/net/Space.c	Tue May 20 11:50:12 2003
@@ -453,17 +453,6 @@
 #define NEXT_DEV	(&tap0_dev)
 #endif
 
-#ifdef CONFIG_SDLA
-extern int sdla_init(struct net_device *);
-static struct net_device sdla0_dev = {
-	.name		=  "sdla0",
-	.next		=  NEXT_DEV,
-	.init		=  sdla_init,
-};
-#undef NEXT_DEV
-#define NEXT_DEV	(&sdla0_dev)
-#endif
-
 #if defined(CONFIG_LTPC)
 extern int ltpc_probe(struct net_device *);
 static struct net_device dev_ltpc = {
--- 1.11/drivers/net/setup.c	Tue May 20 08:57:38 2003
+++ edited/drivers/net/setup.c	Tue May 20 11:56:00 2003
@@ -14,8 +14,6 @@
 extern int arcnet_init(void); 
 extern int scc_enet_init(void); 
 extern int fec_enet_init(void); 
-extern int sdla_setup(void); 
-extern int sdla_c_setup(void); 
 extern int lmc_setup(void);
 
 extern int madgemc_probe(void);
@@ -39,9 +37,6 @@
 #if defined(CONFIG_DMASCC)
 	{dmascc_init, 0},
 #endif	
-#if defined(CONFIG_SDLA)
-	{sdla_c_setup, 0},
-#endif
 #if defined(CONFIG_ARCNET)
 	{arcnet_init, 0},
 #endif
--- 1.10/drivers/net/wan/sdla.c	Sun May 18 17:18:07 2003
+++ edited/drivers/net/wan/sdla.c	Tue May 20 11:52:15 2003
@@ -1655,32 +1655,25 @@
 	return(0);
 }
 
-int __init sdla_c_setup(void)
-{
-	printk("%s.\n", version);
-	register_frad(devname);
-	return 0;
-}
-
-#ifdef MODULE
 static struct net_device sdla0 = {
 	.name = "sdla0",
 	.init = sdla_init
 };
 
-MODULE_LICENSE("GPL");
 
-int init_module(void)
+static int __init init_sdla(void)
 {
 	int result;
 
-	sdla_c_setup();
+	printk("%s.\n", version);
+	register_frad(devname);
+
 	if ((result = register_netdev(&sdla0)) != 0)
 		return result;
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit exit_sdla(void)
 {
 	unregister_netdev(&sdla0);
 	if (sdla0.priv)
@@ -1688,4 +1681,8 @@
 	if (sdla0.irq)
 		free_irq(sdla0.irq, &sdla0);
 }
-#endif /* MODULE */
+
+MODULE_LICENSE("GPL");
+
+module_init(init_sdla);
+module_exit(exit_sdla);
