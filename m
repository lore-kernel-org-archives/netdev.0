From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] convert madgemc to initcalls
Date: Fri, 23 May 2003 09:18:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030523091858.A28081@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MCA driver so there should be no probe order issues.


--- 1.13/drivers/net/tokenring/madgemc.c	Mon Apr 28 05:36:20 2003
+++ edited/drivers/net/tokenring/madgemc.c	Thu May 22 11:22:50 2003
@@ -63,7 +63,6 @@
 static struct madgemc_card *madgemc_card_list;
 
 
-int madgemc_probe(void);
 static int madgemc_open(struct net_device *dev);
 static int madgemc_close(struct net_device *dev);
 static int madgemc_chipset_init(struct net_device *dev);
@@ -152,7 +151,7 @@
 
 
 
-int __init madgemc_probe(void)
+static int __init madgemc_probe(void)
 {	
 	static int versionprinted;
 	struct net_device *dev;
@@ -773,19 +772,7 @@
 	return len;
 }
 
-#ifdef MODULE
-
-int init_module(void)
-{
-	/* Probe for cards. */
-	if (madgemc_probe()) {
-		printk(KERN_NOTICE "madgemc.c: No cards found.\n");
-	}
-	/* lock_tms380_module(); */
-	return (0);
-}
-
-void cleanup_module(void)
+static void __exit madgemc_exit(void)
 {
 	struct net_device *dev;
 	struct madgemc_card *this_card;
@@ -801,9 +788,10 @@
 		madgemc_card_list = this_card->next;
 		kfree(this_card);
 	}
-	/* unlock_tms380_module(); */
 }
-#endif /* MODULE */
+
+module_init(madgemc_probe);
+module_exit(madgemc_exit);
 
 MODULE_LICENSE("GPL");
 
--- 1.12/drivers/net/setup.c	Thu May 22 10:08:06 2003
+++ edited/drivers/net/setup.c	Thu May 22 11:21:55 2003
@@ -17,8 +17,6 @@
 extern int sdla_c_setup(void); 
 extern int lmc_setup(void);
 
-extern int madgemc_probe(void);
-
 /*
  *	Devices in this list must do new style probing. That is they must
  *	allocate their own device objects and do their own bus scans.
@@ -50,14 +48,6 @@
 #if defined(CONFIG_LANMEDIA)
 	{lmc_setup, 0},
 #endif
-	 
-/*
- *	Token Ring Drivers
- */  
-#ifdef CONFIG_MADGEMC
-	{madgemc_probe, 0},
-#endif
- 
 	{NULL, 0},
 };
 
