From: Patrick McHardy <kaber@trash.net>
Subject: [IFB 08/18]: Use rtnl_link API
Date: Wed, 13 Jun 2007 18:50:53 +0200 (MEST)
Message-ID: <20070613165050.7780.98922.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35930 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758866AbXFMQuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:50:54 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IFB]: Use rtnl_link API

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7cd41b2caa4f124f84d6f458fe913de8e3b492a3
tree c62fa740c7e41ab388da72b67a4e4538ad97eda7
parent cfbc876235237d990af80b7fc396f4458b5a1657
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:22 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:30 +0200

 drivers/net/ifb.c |   80 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 60 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 819945e..669ee1a 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -139,13 +139,14 @@ resched:
 
 }
 
-static void __init ifb_setup(struct net_device *dev)
+static void ifb_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
 	dev->get_stats = ifb_get_stats;
 	dev->hard_start_xmit = ifb_xmit;
 	dev->open = &ifb_open;
 	dev->stop = &ifb_close;
+	dev->destructor = free_netdev;
 
 	/* Fill in device structure with ethernet-generic values. */
 	ether_setup(dev);
@@ -229,6 +230,37 @@ static int ifb_open(struct net_device *dev)
 	return 0;
 }
 
+static int ifb_newlink(struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct ifb_private *priv = netdev_priv(dev);
+	int err;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		return err;
+
+	priv->dev = dev;
+	list_add_tail(&priv->list, &ifbs);
+	return 0;
+}
+
+static void ifb_dellink(struct net_device *dev)
+{
+	struct ifb_private *priv = netdev_priv(dev);
+
+	list_del(&priv->list);
+	unregister_netdevice(dev);
+}
+
+static struct rtnl_link_ops ifb_link_ops __read_mostly = {
+	.kind		= "ifb",
+	.priv_size	= sizeof(struct ifb_private),
+	.setup		= ifb_setup,
+	.newlink	= ifb_newlink,
+	.dellink	= ifb_dellink,
+};
+
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
@@ -241,38 +273,41 @@ static int __init ifb_init_one(int index)
 	if (!dev_ifb)
 		return -ENOMEM;
 
-	if ((err = register_netdev(dev_ifb))) {
-		free_netdev(dev_ifb);
-		dev_ifb = NULL;
-	} else {
-		priv = netdev_priv(dev_ifb);
-		priv->dev = dev_ifb;
-		list_add_tail(&priv->list, &ifbs);
-	}
+	err = dev_alloc_name(dev_ifb, dev_ifb->name);
+	if (err < 0)
+		goto err;
 
-	return err;
-}
+	dev_ifb->rtnl_link_ops = &ifb_link_ops;
+	err = register_netdevice(dev_ifb);
+	if (err < 0)
+		goto err;
 
-static void ifb_free_one(struct net_device *dev)
-{
-	struct ifb_private *priv = netdev_priv(dev);
+	priv = netdev_priv(dev_ifb);
+	priv->dev = dev_ifb;
+	list_add_tail(&priv->list, &ifbs);
+	return 0;
 
-	list_del(&priv->list);
-	unregister_netdev(dev);
-	free_netdev(dev);
+err:
+	free_netdev(dev_ifb);
+	return err;
 }
 
 static int __init ifb_init_module(void)
 {
 	struct ifb_private *priv, *next;
-	int i, err = 0;
+	int i, err;
+
+	rtnl_lock();
+	err = __rtnl_link_register(&ifb_link_ops);
 
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i);
 	if (err) {
 		list_for_each_entry_safe(priv, next, &ifbs, list)
-			ifb_free_one(priv->dev);
+			ifb_dellink(priv->dev);
+		__rtnl_link_unregister(&ifb_link_ops);
 	}
+	rtnl_unlock();
 
 	return err;
 }
@@ -281,11 +316,16 @@ static void __exit ifb_cleanup_module(void)
 {
 	struct ifb_private *priv, *next;
 
+	rtnl_lock();
 	list_for_each_entry_safe(priv, next, &ifbs, list)
-		ifb_free_one(priv->dev);
+		ifb_dellink(priv->dev);
+
+	__rtnl_link_unregister(&ifb_link_ops);
+	rtnl_unlock();
 }
 
 module_init(ifb_init_module);
 module_exit(ifb_cleanup_module);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jamal Hadi Salim");
+MODULE_ALIAS_RTNL_LINK("ifb");
