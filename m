From: Patrick McHardy <kaber@trash.net>
Subject: [RFC DUMMY 07/09]: Use rtnl_link API
Date: Tue,  5 Jun 2007 16:13:02 +0200 (MEST)
Message-ID: <20070605141301.15650.47999.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63934 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763602AbXFEOND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:13:03 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[DUMMY]: Use rtnl_link API

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a86d7c15680b4bbeec06f0194c2ca927648e33dd
tree f6f55cbbd72b9643fb2f9c4e5859a3a2d699504a
parent 5785eb9eb2c30be5662261fc115a65d28cc98c17
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:28 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:28 +0200

 drivers/net/dummy.c |   81 ++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 61 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 2f2cf3c..b1bb7a0 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/moduleparam.h>
 #include <linux/rtnetlink.h>
+#include <net/rtnetlink.h>
 
 struct dummy_priv {
 	struct net_device *dev;
@@ -61,12 +62,13 @@ static void set_multicast_list(struct net_device *dev)
 {
 }
 
-static void __init dummy_setup(struct net_device *dev)
+static void dummy_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
 	dev->hard_start_xmit = dummy_xmit;
 	dev->set_multicast_list = set_multicast_list;
 	dev->set_mac_address = dummy_set_address;
+	dev->destructor = free_netdev;
 
 	/* Fill in device structure with ethernet-generic values. */
 	ether_setup(dev);
@@ -89,6 +91,37 @@ static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static LIST_HEAD(dummies);
 
+static int dummy_newlink(struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+	int err;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		return err;
+
+	priv->dev = dev;
+	list_add_tail(&priv->list, &dummies);
+	return 0;
+}
+
+static void dummy_dellink(struct net_device *dev)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	list_del(&priv->list);
+	unregister_netdevice(dev);
+}
+
+static struct rtnl_link_ops dummy_link_ops = {
+	.name		= "dummy",
+	.priv_size	= sizeof(struct dummy_priv),
+	.setup		= dummy_setup,
+	.newlink	= dummy_newlink,
+	.dellink	= dummy_dellink,
+};
+
 /* Number of dummy devices to be set up by this module. */
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
@@ -105,25 +138,22 @@ static int __init dummy_init_one(void)
 	if (!dev_dummy)
 		return -ENOMEM;
 
-	if ((err = register_netdev(dev_dummy))) {
-		free_netdev(dev_dummy);
-		dev_dummy = NULL;
-	} else {
-		priv = netdev_priv(dev_dummy);
-		priv->dev = dev_dummy;
-		list_add_tail(&priv->list, &dummies);
-	}
+	err = dev_alloc_name(dev_dummy, dev_dummy->name);
+	if (err < 0)
+		goto err;
 
-	return err;
-}
+	err = register_netdevice(dev_dummy);
+	if (err < 0)
+		goto err;
 
-static void dummy_free_one(struct net_device *dev)
-{
-	struct dummy_priv *priv = netdev_priv(dev);
+	priv = netdev_priv(dev_dummy);
+	priv->dev = dev_dummy;
+	list_add_tail(&priv->list, &dummies);
+	return 0;
 
-	list_del(&priv->list);
-	unregister_netdev(dev);
-	free_netdev(dev);
+err:
+	free_netdev(dev_dummy);
+	return err;
 }
 
 static int __init dummy_init_module(void)
@@ -131,12 +161,18 @@ static int __init dummy_init_module(void)
 	struct dummy_priv *priv, *next;
 	int i, err = 0;
 
+	rtnl_lock();
+	err = __rtnl_link_register(&dummy_link_ops);
+
 	for (i = 0; i < numdummies && !err; i++)
 		err = dummy_init_one();
-	if (err) {
+	if (err < 0) {
 		list_for_each_entry_safe(priv, next, &dummies, list)
-			dummy_free_one(priv->dev);
+			dummy_dellink(priv->dev);
+		__rtnl_link_unregister(&dummy_link_ops);
 	}
+	rtnl_unlock();
+
 	return err;
 }
 
@@ -144,10 +180,15 @@ static void __exit dummy_cleanup_module(void)
 {
 	struct dummy_priv *priv, *next;
 
+	rtnl_lock();
 	list_for_each_entry_safe(priv, next, &dummies, list)
-		dummy_free_one(priv->dev);
+		dummy_dellink(priv->dev);
+
+	__rtnl_link_unregister(&dummy_link_ops);
+	rtnl_unlock();
 }
 
 module_init(dummy_init_module);
 module_exit(dummy_cleanup_module);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK("dummy");
