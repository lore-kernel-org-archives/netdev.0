From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.74] Change appletalk/cops to dynamic allocation of
 net_device
Date: Wed, 9 Jul 2003 13:29:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709132910.589cf65d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Jay Schulist <jschlst@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Part of the continuing campaign to fix all network devices to allocate dynamically.

Built and loaded/unloaded, but do not have the hardware.  Surprisingly probe suceeds
even without hardware.


diff -Nru a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
--- a/drivers/net/appletalk/cops.c	Wed Jul  9 12:55:30 2003
+++ b/drivers/net/appletalk/cops.c	Wed Jul  9 12:55:30 2003
@@ -235,9 +235,11 @@
 	 * Dayna cards don't autoprobe well at all, but if your card is
 	 * at IRQ 5 & IO 0x240 we find it every time. ;) JS
 	 */
-        for(i=0; cops_portlist[i]; i++)
+        for(i=0; cops_portlist[i]; i++) {
+	    	ltalk_setup(dev);
                 if(cops_probe1(dev, cops_portlist[i]) == 0)
                         return 0;
+	}
 	
         return -ENODEV;
 }
@@ -311,24 +313,12 @@
 	dev->base_addr		= ioaddr;
 
 	/* Initialize the private device structure. */
-        dev->priv = kmalloc(sizeof(struct cops_local), GFP_KERNEL);
-        if(dev->priv == NULL) {
-		if (dev->irq)
-			free_irq(dev->irq, dev);
-        	retval = -ENOMEM;
-		goto err_out;
-	}
-
         lp = (struct cops_local *)dev->priv;
-        memset(lp, 0, sizeof(struct cops_local));
         spin_lock_init(&lp->lock);
 
 	/* Copy local board variable to lp struct. */
 	lp->board               = board;
 
-	/* Fill in the fields of the device structure with LocalTalk values. */
-	ltalk_setup(dev);
-
 	dev->hard_start_xmit    = cops_send_packet;
 	dev->tx_timeout		= cops_timeout;
 	dev->watchdog_timeo	= HZ * 2;
@@ -1012,44 +1002,50 @@
 }
 
 #ifdef MODULE
-static struct net_device cops0_dev = { .init = cops_probe };
+static struct net_device *cops0_dev;
 
 MODULE_LICENSE("GPL");
 MODULE_PARM(io, "i");
 MODULE_PARM(irq, "i");
 MODULE_PARM(board_type, "i");
 
-int init_module(void)
+static int __init cops_init_module(void)
 {
-        int result, err;
+	int err;
 
         if(io == 0)
 		printk(KERN_WARNING "%s: You shouldn't autoprobe with insmod\n",
 			cardname);
 
-        /* Copy the parameters from insmod into the device structure. */
-        cops0_dev.base_addr = io;
-        cops0_dev.irq       = irq;
+	cops0_dev = alloc_netdev(sizeof(struct cops_local), "lt%d",
+				 ltalk_setup);
+
+	cops0_dev->init = cops_probe;
 
-	err=dev_alloc_name(&cops0_dev, "lt%d");
-        if(err < 0)
-                return err;
+        /* Copy the parameters from insmod into the device structure. */
+	cops0_dev->base_addr = io;
+        cops0_dev->irq       = irq;
 
-        if((result = register_netdev(&cops0_dev)) != 0)
-                return result;
+        if ((err = register_netdev(cops0_dev)))
+	    kfree(cops0_dev);
 
-        return 0;
+	return err;
 }
 
-void cleanup_module(void)
+static void __exit cops_cleanup_module(void)
 {
-	unregister_netdev(&cops0_dev);
-	kfree(cops0_dev.priv);
-	if(cops0_dev.irq)
-		free_irq(cops0_dev.irq, &cops0_dev);
-        release_region(cops0_dev.base_addr, COPS_IO_EXTENT);
+	unregister_netdev(cops0_dev);
+
+	if(cops0_dev->irq)
+		free_irq(cops0_dev->irq, &cops0_dev);
+        release_region(cops0_dev->base_addr, COPS_IO_EXTENT);
+	kfree(cops0_dev);
 }
-#endif /* MODULE */
+
+module_init(cops_init_module);
+module_exit(cops_cleanup_module);
+
+#endif
 
 /*
  * Local variables:
