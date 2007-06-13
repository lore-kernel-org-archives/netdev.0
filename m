From: Patrick McHardy <kaber@trash.net>
Subject: [DUMMY 06/18]: Use rtnl_link API
Date: Wed, 13 Jun 2007 18:50:50 +0200 (MEST)
Message-ID: <20070613165047.7780.54102.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35936 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758880AbXFMQuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:50:51 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[DUMMY]: Use rtnl_link API

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 379884fb0587cd4832ecf8785467209885204124
tree 8bce1ffae7d2b2afabba9bc5ab2c7b06402c51c1
parent 18094391f33349687e35eaf0e768b18a71523100
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:12 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:30 +0200

 drivers/net/dummy.c |   82 +++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 62 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 2f2cf3c..91126b9 100644
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
+static struct rtnl_link_ops dummy_link_ops __read_mostly = {
+	.kind		= "dummy",
+	.priv_size	= sizeof(struct dummy_priv),
+	.setup		= dummy_setup,
+	.newlink	= dummy_newlink,
+	.dellink	= dummy_dellink,
+};
+
 /* Number of dummy devices to be set up by this module. */
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
@@ -105,25 +138,23 @@ static int __init dummy_init_one(void)
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
+	dev_dummy->rtnl_link_ops = &dummy_link_ops;
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
@@ -131,12 +162,18 @@ static int __init dummy_init_module(void)
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
 
@@ -144,10 +181,15 @@ static void __exit dummy_cleanup_module(void)
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
