From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert lp486e driver to dynamic allocation
Date: Mon, 4 Aug 2003 16:21:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804162147.591c55f6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert this driver from static net_device to using alloc_etherdev.

Patch against 2.6.0-test2. Loads and unloads, but don't have the actual hardware.

diff -Nru a/drivers/net/lp486e.c b/drivers/net/lp486e.c
--- a/drivers/net/lp486e.c	Mon Aug  4 14:53:55 2003
+++ b/drivers/net/lp486e.c	Mon Aug  4 14:53:55 2003
@@ -975,15 +975,7 @@
 		return -EBUSY;
 	}
 
-	/*
-	 * Allocate working memory, 16-byte aligned
-	 */
-	dev->mem_start = (unsigned long) kmalloc(sizeof(struct i596_private) + 0x0f, GFP_KERNEL);
-	if (!dev->mem_start)
-		goto err_out;
-	dev->priv = (void *)((dev->mem_start + 0xf) & 0xfffffff0);
 	lp = (struct i596_private *) dev->priv;
-	memset((void *)lp, 0, sizeof(struct i596_private));
 	spin_lock_init(&lp->cmd_lock);
 	
 	/*
@@ -997,7 +989,6 @@
 	dev->base_addr = IOADDR;
 	dev->irq = IRQ;
 
-	ether_setup(dev);
 
 	/*
 	 * How do we find the ethernet address? I don't know.
@@ -1045,8 +1036,6 @@
 	return 0;
 
 err_out_kfree:
-	kfree ((void *) dev->mem_start);
-err_out:
 	release_region(IOADDR, LP486E_TOTAL_SIZE);
 	return ret;
 }
@@ -1318,29 +1307,36 @@
 MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
 
-static struct net_device dev_lp486e;
+static struct net_device *dev_lp486e;
 static int full_duplex;
 static int options;
 static int io = IOADDR;
 static int irq = IRQ;
 
 static int __init lp486e_init_module(void) {
-	struct net_device *dev = &dev_lp486e;
+	struct net_device *dev;
+
+	dev = alloc_etherdev(sizeof(struct i596_private));
+	if (!dev)
+		return -ENOMEM;
+
 	dev->irq = irq;
 	dev->base_addr = io;
 	dev->init = lp486e_probe;
-	if (register_netdev(dev) != 0)
+	if (register_netdev(dev) != 0) {
+		kfree(dev);
 		return -EIO;
+	}
+	dev_lp486e = dev;
 	full_duplex = 0;
 	options = 0;
 	return 0;
 }
 
 static void __exit lp486e_cleanup_module(void) {
-	unregister_netdev(&dev_lp486e);
-	kfree((void *)dev_lp486e.mem_start);
-	dev_lp486e.priv = NULL;
-	release_region(dev_lp486e.base_addr, LP486E_TOTAL_SIZE);
+	unregister_netdev(dev_lp486e);
+	release_region(dev_lp486e->base_addr, LP486E_TOTAL_SIZE);
+	kfree(dev_lp486e);
 }
 
 module_init(lp486e_init_module);
