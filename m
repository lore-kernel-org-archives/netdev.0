From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IFB 09/09]: Use rtnl_link API
Date: Tue,  5 Jun 2007 16:13:05 +0200 (MEST)
Message-ID: <20070605141304.15650.69675.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63946 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764140AbXFEONH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:13:07 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IFB]: Use rtnl_link API

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 6a0492fd68c8c5f528e4277bec20bef8047aec2e
tree 7e2ae7fb9e33d7c547c3030b9923de232aaf9ab3
parent 279921d3d97ab5f310142bdb27b5459742dbba4f
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:29 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:29 +0200

 drivers/net/ifb.c |   79 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 59 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 819945e..9ec01ff 100644
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
+static struct rtnl_link_ops ifb_link_ops = {
+	.name		= "ifb",
+	.priv_size	= sizeof(struct ifb_private),
+	.setup		= ifb_setup,
+	.newlink	= ifb_newlink,
+	.dellink	= ifb_dellink,
+};
+
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
@@ -241,38 +273,40 @@ static int __init ifb_init_one(int index)
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
@@ -281,11 +315,16 @@ static void __exit ifb_cleanup_module(void)
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
