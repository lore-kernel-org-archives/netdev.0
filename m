From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove sdla from setup.c
Date: Wed, 28 May 2003 13:06:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030528110658.GA26411@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sdla had calls from both Space.c and setup.c.  Leave the Space.c one
alone as per previous discussion but move over the setup.c one to
initcalls.  (and remove the prototype for a third one from setup.c!)


--- 1.14/drivers/net/setup.c	Tue May 27 01:32:22 2003
+++ edited/drivers/net/setup.c	Tue May 27 14:36:58 2003
@@ -13,8 +13,6 @@
 
 extern int scc_enet_init(void); 
 extern int fec_enet_init(void); 
-extern int sdla_setup(void); 
-extern int sdla_c_setup(void); 
 
 /*
  *	Devices in this list must do new style probing. That is they must
@@ -35,9 +33,6 @@
 #if defined(CONFIG_DMASCC)
 	{dmascc_init, 0},
 #endif	
-#if defined(CONFIG_SDLA)
-	{sdla_c_setup, 0},
-#endif
 #if defined(CONFIG_SCC_ENET)
         {scc_enet_init, 0},
 #endif
===== drivers/net/wan/sdla.c 1.10 vs edited =====
--- 1.10/drivers/net/wan/sdla.c	Sun May 18 17:18:07 2003
+++ edited/drivers/net/wan/sdla.c	Tue May 27 15:07:49 2003
@@ -1667,20 +1667,20 @@
 	.name = "sdla0",
 	.init = sdla_init
 };
+#endif /* MODULE */
 
-MODULE_LICENSE("GPL");
-
-int init_module(void)
+static int __init init_sdla(void)
 {
-	int result;
+	int result = 0;
 
 	sdla_c_setup();
-	if ((result = register_netdev(&sdla0)) != 0)
-		return result;
-	return 0;
+#ifdef MODULE
+	result = register_netdev(&sdla0);
+#endif
+	return result;
 }
 
-void cleanup_module(void)
+static void __exit exit_sdla(void)
 {
 	unregister_netdev(&sdla0);
 	if (sdla0.priv)
@@ -1688,4 +1688,8 @@
 	if (sdla0.irq)
 		free_irq(sdla0.irq, &sdla0);
 }
-#endif /* MODULE */
+
+MODULE_LICENSE("GPL");
+
+module_init(init_sdla);
+module_exit(exit_sdla);
