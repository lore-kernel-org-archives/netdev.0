From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) Space.c -- fix boot param string setup
Date: Tue, 23 Sep 2003 10:14:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923101448.71ea19d5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My conversion of probing to dynamic allocation, lost the ability to
set boot parameters properly.  Need to assign network device name before
lookup in order for this to work.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Sep 23 09:36:37 2003
+++ b/drivers/net/Space.c	Tue Sep 23 09:36:37 2003
@@ -103,7 +103,7 @@
 extern int iph5526_probe(struct net_device *dev);
 
 /* SBNI adapters */
-extern int sbni_probe(void);
+extern int sbni_probe(int unit);
 
 struct devprobe
 {
@@ -338,7 +338,7 @@
  * per bus interface. This drives the legacy devices only for now.
  */
  
-static int __init ethif_probe(void)
+static int __init ethif_probe(int unit)
 {
 	struct net_device *dev;
 	int err = -ENODEV;
@@ -347,6 +347,7 @@
 	if (!dev)
 		return -ENOMEM;
 
+	sprintf(dev->name, "eth%d", unit);
 	netdev_boot_setup_check(dev);
 
 	/* 
@@ -383,7 +384,7 @@
 extern int proteon_probe(struct net_device *);
 extern int smctr_probe(struct net_device *);
 
-static __init int trif_probe(void)
+static __init int trif_probe(int unit)
 {
 	struct net_device *dev;
 	int err = -ENODEV;
@@ -392,6 +393,7 @@
 	if (!dev)
 		return -ENOMEM;
 
+	sprintf(dev->name, "tr%d", unit);
 	netdev_boot_setup_check(dev);
 	if (
 #ifdef CONFIG_IBMTR
@@ -435,16 +437,16 @@
 	
 #ifdef CONFIG_SBNI
 	for (num = 0; num < 8; ++num)
-		if (sbni_probe())
+		if (sbni_probe(num))
 			break;
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		if (trif_probe())
+		if (trif_probe(num))
 			break;
 #endif
 	for (num = 0; num < 8; ++num)
-		if (ethif_probe())
+		if (ethif_probe(num))
 			break;
 #ifdef CONFIG_COPS
 	cops_probe(0);
diff -Nru a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
--- a/drivers/net/wan/sbni.c	Tue Sep 23 09:36:37 2003
+++ b/drivers/net/wan/sbni.c	Tue Sep 23 09:36:37 2003
@@ -221,24 +221,26 @@
 	SET_MODULE_OWNER( dev );
 }
 
-int __init sbni_probe(void)
+int __init sbni_probe(int unit)
 {
 	struct net_device *dev;
 	static unsigned  version_printed __initdata = 0;
+	int err;
 
-	if( version_printed++ == 0 )
-		printk( KERN_INFO "%s", version );
-
-	dev = alloc_netdev(sizeof(struct net_local), "sbni%d", sbni_devsetup);
+	dev = alloc_netdev(sizeof(struct net_local), "sbni", sbni_devsetup);
 	if (!dev)
 		return -ENOMEM;
 
+	sprintf(dev->name, "sbni%d", unit);
 	netdev_boot_setup_check(dev);
 
-	if (register_netdev(dev)) {
-		kfree(dev);
-		return -ENODEV;
+	err = register_netdev(dev);
+	if (err) {
+		free_netdev(dev);
+		return err;
 	}
+	if( version_printed++ == 0 )
+		printk( KERN_INFO "%s", version );
 	return 0;
 }
 
