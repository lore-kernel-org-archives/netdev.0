From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.74] convert appletalk/ltpc over to dynamic allocation
Date: Wed, 9 Jul 2003 13:24:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709132438.432fcd2b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Jay Schulist <jschlst@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Part of the continuing campaign to fix all network devices to allocate dynamically.

Built, loaded/unloaded and configured but don't have real hardware.

--- linux-2.5.74/drivers/net/appletalk/ltpc.c	2003-07-09 13:19:55.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/appletalk/ltpc.c	2003-07-09 13:22:14.000000000 -0700
@@ -884,18 +884,8 @@
 	/* Initialize the device structure. */
   
 	/* Fill in the fields of the device structure with ethernet-generic values. */
-	ltalk_setup(dev);
 	dev->hard_start_xmit = ltpc_xmit;
 	dev->hard_header = ltpc_hard_header;
-
-	dev->priv = kmalloc(sizeof(struct ltpc_private), GFP_KERNEL);
-	if(!dev->priv)
-	{
-		printk(KERN_INFO "%s: could not allocate statistics buffer\n", dev->name);
-		return -ENOMEM;
-	}
-
-	memset(dev->priv, 0, sizeof(struct ltpc_private));
 	dev->get_stats = ltpc_get_stats;
 
 	/* add the ltpc-specific things */
@@ -1169,6 +1159,7 @@
 		printk(KERN_INFO "Apple/Farallon LocalTalk-PC card at %03x, DMA%d.  Using polled mode.\n",io,dma);
 
 	/* seems more logical to do this *after* probing the card... */
+	ltalk_setup(dev);
 	err = ltpc_init(dev);
 	if (err) return err;
 
@@ -1256,11 +1247,10 @@
 }
 
 __setup("ltpc=", ltpc_setup);
-#endif /* MODULE */
 
-static struct net_device dev_ltpc;
+#else 	/* MODULE */
 
-#ifdef MODULE
+static struct net_device *dev_ltpc;
 
 MODULE_LICENSE("GPL");
 MODULE_PARM(debug, "i");
@@ -1268,23 +1258,22 @@
 MODULE_PARM(irq, "i");
 MODULE_PARM(dma, "i");
 
-
-int __init init_module(void)
+static int __init ltpc_init_module(void)
 {
-	int err, result;
+	int result;
 	
         if(io == 0)
 		printk(KERN_NOTICE
 		       "ltpc: Autoprobing is not recommended for modules\n");
 
-	/* Find a name for this unit */
-	dev_ltpc.init = ltpc_probe;
-	err=dev_alloc_name(&dev_ltpc,"lt%d");
-	
-	if(err<0)
-		return err;
+	dev_ltpc = alloc_netdev(sizeof(struct ltpc_private), "lt%d",
+				ltalk_setup);
+
 
-	if ((result = register_netdev(&dev_ltpc)) != 0) {
+	dev_ltpc->init = ltpc_probe;
+
+	if ((result = register_netdev(dev_ltpc)) != 0) {
+		kfree(dev_ltpc);
 		printk(KERN_DEBUG "could not register Localtalk-PC device\n");
 		return result;
 	} else {
@@ -1292,7 +1281,6 @@
 		return 0;
 	}
 }
-#endif
 
 static void __exit ltpc_cleanup(void)
 {
@@ -1302,9 +1290,9 @@
 
 	if(debug & DEBUG_VERBOSE) printk("freeing irq\n");
 
-	if(dev_ltpc.irq) {
-		free_irq(dev_ltpc.irq,&dev_ltpc);
-		dev_ltpc.irq = 0;
+	if(dev_ltpc->irq) {
+		free_irq(dev_ltpc->irq,dev_ltpc);
+		dev_ltpc->irq = 0;
 	}
 
 	if(del_timer(&ltpc_timer)) 
@@ -1323,16 +1311,16 @@
 
 	if(debug & DEBUG_VERBOSE) printk("freeing dma\n");
 
-	if(dev_ltpc.dma) {
-		free_dma(dev_ltpc.dma);
-		dev_ltpc.dma = 0;
+	if(dev_ltpc->dma) {
+		free_dma(dev_ltpc->dma);
+		dev_ltpc->dma = 0;
 	}
 
 	if(debug & DEBUG_VERBOSE) printk("freeing ioaddr\n");
 
-	if(dev_ltpc.base_addr) {
-		release_region(dev_ltpc.base_addr,8);
-		dev_ltpc.base_addr = 0;
+	if(dev_ltpc->base_addr) {
+		release_region(dev_ltpc->base_addr,8);
+		dev_ltpc->base_addr = 0;
 	}
 
 	if(debug & DEBUG_VERBOSE) printk("free_pages\n");
@@ -1343,9 +1331,14 @@
 
 	if(debug & DEBUG_VERBOSE) printk("unregister_netdev\n");
 
-	unregister_netdev(&dev_ltpc);
+	unregister_netdev(dev_ltpc);
 
 	if(debug & DEBUG_VERBOSE) printk("returning from cleanup_module\n");
+
+	kfree(dev_ltpc);
 }
 
+module_init(ltpc_init_module);
 module_exit(ltpc_cleanup);
+
+#endif
