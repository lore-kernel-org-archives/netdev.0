From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c501: convert to module_param
Date: Mon, 18 Oct 2004 13:03:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018130302.51f910b9@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert old 3c501 to use:
	* module_param
	* don't need need to zero private area, it's already zero
	* module_init() vs. old style init_module

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/3c501.c b/drivers/net/3c501.c
--- a/drivers/net/3c501.c	2004-10-18 12:22:58 -07:00
+++ b/drivers/net/3c501.c	2004-10-18 12:22:58 -07:00
@@ -112,7 +112,7 @@
  */
 
 #include <linux/module.h>
-
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/fcntl.h>
 #include <linux/ioport.h>
@@ -305,7 +305,6 @@
 	if (el_debug)
 		printk(KERN_DEBUG "%s", version);
 
-	memset(dev->priv, 0, sizeof(struct net_local));
 	lp = netdev_priv(dev);
 	spin_lock_init(&lp->lock);
 	
@@ -892,8 +891,8 @@
 
 static struct net_device *dev_3c501;
 
-MODULE_PARM(io, "i");
-MODULE_PARM(irq, "i");
+module_param(io, int, 0);
+module_param(irq, int, 0);
 MODULE_PARM_DESC(io, "EtherLink I/O base address");
 MODULE_PARM_DESC(irq, "EtherLink IRQ number");
 
@@ -908,14 +907,14 @@
  * Returns 0 for success or -EIO if a card is not found. Returning an error
  * here also causes the module to be unloaded
  */
- 
-int init_module(void)
+static int __init el1_init_module(void) 
 {
 	dev_3c501 = el1_probe(-1);
 	if (IS_ERR(dev_3c501))
 		return PTR_ERR(dev_3c501);
 	return 0;
 }
+module_init(el1_init_module);
 
 /**
  * cleanup_module:
@@ -923,15 +922,14 @@
  * The module is being unloaded. We unhook our network device from the system
  * and then free up the resources we took when the card was found.
  */
- 
-void cleanup_module(void)
+static void __exit el1_cleanup_module(void)
 {
 	struct net_device *dev = dev_3c501;
 	unregister_netdev(dev);
 	release_region(dev->base_addr, EL1_IO_EXTENT);
 	free_netdev(dev);
 }
-
+module_exit(el1_cleanup_module);
 #endif /* MODULE */
 
 MODULE_AUTHOR("Donald Becker, Alan Cox");
