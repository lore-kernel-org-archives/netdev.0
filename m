From: Andi Kleen <ak@muc.de>
Subject: [patch] variable number of dummy devices
Date: Thu, 11 Dec 2003 09:36:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031211083621.GA2455@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Uses the new module_params that nobody else uses now.

diff -u linux-2.6.0test11-amd64/drivers/net/dummy.c-DUMMY linux-2.6.0test11-amd64/drivers/net/dummy.c
--- linux-2.6.0test11-amd64/drivers/net/dummy.c-DUMMY	2003-11-29 16:34:26.000000000 +0100
+++ linux-2.6.0test11-amd64/drivers/net/dummy.c	2003-12-11 09:34:17.000000000 +0100
@@ -33,6 +33,9 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/init.h>
+#include <linux/moduleparam.h>
+
+static int numdummies = 1;
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
 static struct net_device_stats *dummy_get_stats(struct net_device *dev);
@@ -83,10 +86,14 @@
 	return dev->priv;
 }
 
-static struct net_device *dev_dummy;
+static struct net_device **dummies;
 
-static int __init dummy_init_module(void)
+/* Number of dummy devices to be set up by this module. */
+module_param(numdummies, int, 0);
+
+static int __init dummy_init_one(int index)
 {
+	struct net_device *dev_dummy;
 	int err;
 
 	dev_dummy = alloc_netdev(sizeof(struct net_device_stats),
@@ -98,15 +105,40 @@
 	if ((err = register_netdev(dev_dummy))) {
 		kfree(dev_dummy);
 		dev_dummy = NULL;
+	} else {
+		dummies[index] = dev_dummy; 
 	}
+
 	return err;
 }
 
+static void __exit dummy_free_one(int index) 
+{
+	unregister_netdev(dummies[index]);
+	free_netdev(dummies[index]);
+} 
+
+static int __init dummy_init_module(void)
+{ 
+	int i, err = 0;
+	dummies = kmalloc(numdummies * sizeof(void *), GFP_KERNEL); 
+	if (!dummies)
+		return -ENOMEM; 
+	for (i = 0; i < numdummies && !err; i++)
+		err = dummy_init_one(i); 
+	if (err) { 
+		while (--i >= 0)
+			dummy_free_one(i);
+	}
+	return err;
+} 
+
 static void __exit dummy_cleanup_module(void)
 {
-	unregister_netdev(dev_dummy);
-	free_netdev(dev_dummy);
-	dev_dummy = NULL;
+	int i;
+	for (i = 0; i < numdummies; i++) 
+		dummy_free_one(i); 
+	kfree(dummies);	
 }
 
 module_init(dummy_init_module);
