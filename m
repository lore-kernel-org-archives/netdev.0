From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] more sdla fixes
Date: Thu, 4 Sep 2003 14:42:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904144248.0599cdaf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since sdla.c now has locking instead of cli/sti, it shouldn't be
completely busted on SMP.

Also, the frad interface registration needed to be done once
(and check the result), and undone on module unload.

diff -Nru a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
--- a/drivers/net/wan/Kconfig	Thu Sep  4 14:41:49 2003
+++ b/drivers/net/wan/Kconfig	Thu Sep  4 14:41:49 2003
@@ -465,7 +465,7 @@
 
 config SDLA
 	tristate "SDLA (Sangoma S502/S508) support"
-	depends on DLCI && ISA && BROKEN_ON_SMP
+	depends on DLCI && ISA
 	help
 	  Say Y here if you need a driver for the Sangoma S502A, S502E, and
 	  S508 Frame Relay Access Devices. These are multi-protocol cards, but
diff -Nru a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
--- a/drivers/net/wan/sdla.c	Thu Sep  4 14:41:49 2003
+++ b/drivers/net/wan/sdla.c	Thu Sep  4 14:41:49 2003
@@ -1634,12 +1634,26 @@
 	dev->mtu		= SDLA_MAX_MTU;
 }
 
+static int frad_registered;
+
 struct net_device * __init sdla_init(void)
 {
 	struct net_device *dev;
 	struct frad_local *flp;
 	int err = -ENOMEM;
 
+	if (!frad_registered) {
+		err = register_frad(devname);
+		if (err) {
+			printk(KERN_ERR "%s: frad registration failed %d\n",
+			       devname, err);
+			return ERR_PTR(err);
+		}
+		frad_registered = 1;
+		printk("%s.\n", version);
+	}
+		
+
 	dev = alloc_netdev(sizeof(struct frad_local), "sdla0", setup_sdla);
 	if (!dev)
 		goto out;
@@ -1678,39 +1692,35 @@
 	return ERR_PTR(err);
 }
 
-int __init sdla_c_setup(void)
-{
-	printk("%s.\n", version);
-	register_frad(devname);
-	return 0;
-}
-
 #ifdef MODULE
 static struct net_device *sdla0;
-#endif /* MODULE */
 
 static int __init init_sdla(void)
 {
 	int result = 0;
 
-	sdla_c_setup();
-#ifdef MODULE
 	sdla0 = sdla_init();
 	if (IS_ERR(sdla0))
 		result = PTR_ERR(sdla0);
-#endif
+
 	return result;
 }
 
 static void __exit exit_sdla(void)
 {
-#ifdef MODULE
+	struct frad_local *flp;
+
 	unregister_netdev(sdla0);
 	if (sdla0->irq)
 		free_irq(sdla0->irq, sdla0);
+
+	flp = sdla0->priv;
+	del_timer_sync(&flp->timer);
 	free_netdev(sdla0);
-#endif
+	
+	unregister_frad(devname);
 }
+#endif
 
 MODULE_LICENSE("GPL");
 
