From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] dynamic allocation for dummy net device
Date: Thu, 12 Jun 2003 15:05:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612150511.7ed28548.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change dummy driver to dynamically allocate it's net_device using alloc_netdev.
This prevents problems later when network device objects persist after unregister.

--- linux-2.5/drivers/net/dummy.c	2003-06-12 13:35:41.000000000 -0700
+++ linux-2.5-dyn/drivers/net/dummy.c	2003-06-12 15:00:15.000000000 -0700
@@ -51,15 +51,9 @@ static int dummy_accept_fastpath(struct 
 }
 #endif
 
-static int __init dummy_init(struct net_device *dev)
+static void __init dummy_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
-
-	dev->priv = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
-	if (dev->priv == NULL)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof(struct net_device_stats));
-
 	dev->get_stats = dummy_get_stats;
 	dev->hard_start_xmit = dummy_xmit;
 	dev->set_multicast_list = set_multicast_list;
@@ -72,8 +66,7 @@ static int __init dummy_init(struct net_
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
-
-	return 0;
+	SET_MODULE_OWNER(dev);
 }
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -92,32 +85,30 @@ static struct net_device_stats *dummy_ge
 	return dev->priv;
 }
 
-static struct net_device dev_dummy;
+static struct net_device *dev_dummy;
 
 static int __init dummy_init_module(void)
 {
 	int err;
 
-	dev_dummy.init = dummy_init;
-	SET_MODULE_OWNER(&dev_dummy);
+	dev_dummy = alloc_netdev(sizeof(struct net_device_stats),
+				 "dummy%d", dummy_setup);
 
-	/* Find a name for this unit */
-	err=dev_alloc_name(&dev_dummy,"dummy%d");
-	if(err<0)
-		return err;
-	err = register_netdev(&dev_dummy);
-	if (err<0)
-		return err;
-	return 0;
+	if (!dev_dummy)
+		return -ENOMEM;
+
+	if ((err = register_netdev(dev_dummy))) {
+		kfree(dev_dummy);
+		dev_dummy = NULL;
+	}
+	return err;
 }
 
 static void __exit dummy_cleanup_module(void)
 {
-	unregister_netdev(&dev_dummy);
-	kfree(dev_dummy.priv);
-
-	memset(&dev_dummy, 0, sizeof(dev_dummy));
-	dev_dummy.init = dummy_init;
+	unregister_netdev(dev_dummy);
+	kfree(dev_dummy);
+	dev_dummy = NULL;
 }
 
 module_init(dummy_init_module);
