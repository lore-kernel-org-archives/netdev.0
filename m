From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) sdla - move out of Space.c
Date: Mon, 8 Sep 2003 14:14:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908141439.2e41b516.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch against 2.60-test5 to move sdla driver out of Space.c for initialization
in non-module case.  Since this driver doesn't come up until the device has
been configured with an ioctl (set_config); there is no way it can have
startup order problems.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep  8 14:01:25 2003
+++ b/drivers/net/Space.c	Mon Sep  8 14:01:25 2003
@@ -97,7 +97,6 @@
 extern int mac8390_probe(struct net_device *dev);
 extern int mac89x0_probe(struct net_device *dev);
 extern int mc32_probe(struct net_device *dev);
-extern struct net_device *sdla_init(void);
 extern struct net_device *cops_probe(int unit);
 extern struct net_device *ltpc_probe(void);
   
@@ -470,10 +469,6 @@
 #ifdef CONFIG_LTPC
 	ltpc_probe();
 #endif
-#ifdef CONFIG_SDLA
-	sdla_init();
-#endif
-
 }
 
 /*
diff -Nru a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
--- a/drivers/net/wan/sdla.c	Mon Sep  8 14:01:25 2003
+++ b/drivers/net/wan/sdla.c	Mon Sep  8 14:01:25 2003
@@ -1626,41 +1626,16 @@
 
 static void setup_sdla(struct net_device *dev)
 {
+	struct frad_local *flp = dev->priv;
+
+	netdev_boot_setup_check(dev);
+
+	SET_MODULE_OWNER(dev);
 	dev->flags		= 0;
 	dev->type		= 0xFFFF;
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->mtu		= SDLA_MAX_MTU;
-}
-
-static int frad_registered;
-
-struct net_device * __init sdla_init(void)
-{
-	struct net_device *dev;
-	struct frad_local *flp;
-	int err = -ENOMEM;
-
-	if (!frad_registered) {
-		err = register_frad(devname);
-		if (err) {
-			printk(KERN_ERR "%s: frad registration failed %d\n",
-			       devname, err);
-			return ERR_PTR(err);
-		}
-		frad_registered = 1;
-		printk("%s.\n", version);
-	}
-		
-
-	dev = alloc_netdev(sizeof(struct frad_local), "sdla0", setup_sdla);
-	if (!dev)
-		goto out;
-
-	SET_MODULE_OWNER(dev);
-	netdev_boot_setup_check(dev);
-
-	flp = dev->priv;
 
 	dev->open		= sdla_open;
 	dev->stop		= sdla_close;
@@ -1680,42 +1655,44 @@
 	flp->timer.expires	= 1;
 	flp->timer.data		= (unsigned long) dev;
 	flp->timer.function	= sdla_poll;
-
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
-	return dev;
-out1:
-	kfree(dev);
-out:
-	return ERR_PTR(err);
 }
 
-#ifdef MODULE
-static struct net_device *sdla0;
+static struct net_device *sdla;
 
 static int __init init_sdla(void)
 {
-	int result = 0;
+	int err;
+
+	printk("%s.\n", version);
+	err = register_frad(devname);
+	if (err) {
+		printk(KERN_ERR "%s: frad registration failed %d\n",
+		       devname, err);
+		return err;
+	}
 
-	sdla0 = sdla_init();
-	if (IS_ERR(sdla0))
-		result = PTR_ERR(sdla0);
+	sdla = alloc_netdev(sizeof(struct frad_local), "sdla0", setup_sdla);
+	if (!sdla) 
+		return -ENOMEM;
+
+	err = register_netdev(sdla);
+	if (err) 
+		kfree(sdla);
 
-	return result;
+	return err;
 }
 
 static void __exit exit_sdla(void)
 {
 	struct frad_local *flp;
 
-	unregister_netdev(sdla0);
-	if (sdla0->irq)
-		free_irq(sdla0->irq, sdla0);
+	unregister_netdev(sdla);
+	if (sdla->irq)
+		free_irq(sdla->irq, sdla);
 
-	flp = sdla0->priv;
+	flp = sdla->priv;
 	del_timer_sync(&flp->timer);
-	free_netdev(sdla0);
+	free_netdev(sdla);
 	
 	unregister_frad(devname);
 }
@@ -1724,4 +1701,3 @@
 
 module_init(init_sdla);
 module_exit(exit_sdla);
-#endif
