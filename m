From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Allow multiple dummy devices again
Date: Fri, 28 Nov 2003 01:44:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128004445.GA2870@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


In 2.6 the old trick of copying the dummy module to get multiple dummy
devices doesn't work anymore because the "dummy" device name is embedded
in the module. 

This patch adds a new module option that allows to specify how many
dummy devices you want.

-Andi

diff -u linux/drivers/net/dummy.c-o linux-2.6.0test11-amd64/drivers/net/dummy.c
--- linux/drivers/net/dummy.c-o	2003-09-11 04:12:33.000000000 +0200
+++ linux/drivers/net/dummy.c	2003-11-28 01:40:47.000000000 +0100
@@ -34,6 +34,8 @@
 #include <linux/netdevice.h>
 #include <linux/init.h>
 
+static int numdummies = 1;
+
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
 static struct net_device_stats *dummy_get_stats(struct net_device *dev);
 
@@ -83,10 +85,14 @@
 	return dev->priv;
 }
 
-static struct net_device *dev_dummy;
+static struct net_device **dummies;
 
-static int __init dummy_init_module(void)
+/* Number of dummy devices to be set up by this module. */
+MODULE_PARM(numdummies, "i")
+
+static int __init dummy_init_one(int index)
 {
+	struct net_device *dev_dummy;
 	int err;
 
 	dev_dummy = alloc_netdev(sizeof(struct net_device_stats),
@@ -98,15 +104,40 @@
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
