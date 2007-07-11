From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK 03/04]: rtnl_link API simplification
Date: Wed, 11 Jul 2007 19:38:17 +0200 (MEST)
Message-ID: <20070711173817.18369.57824.sendpatchset@localhost.localdomain>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58350 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757692AbXGKRiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 13:38:19 -0400
In-Reply-To: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RTNETLINK]: rtnl_link API simplification

All drivers need to unregister their devices in the module unload function.
While doing so they must hold the rtnl and atomically unregister the
rtnl_link ops as well. This makes the rtnl_link_unregister function that
takes the rtnl itself completely useless.

Provide default newlink/dellink functions, make __rtnl_link_unregister and
rtnl_link_unregister unregister all devices with matching rtnl_link_ops and
change the existing users to take advantage of that.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 88fcde1e75dbfad7e7210642c0364850eed2591e
tree 0d1fd7e324bc69b02a01d8499a48abb6aeae5704
parent f5402e5ada051f17384c089fc49b247fa62e9723
author Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:27:32 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:27:32 +0200

 drivers/net/dummy.c  |   57 +++----------------------------------------------
 drivers/net/ifb.c    |   58 +++++---------------------------------------------
 net/8021q/vlan.c     |   21 ------------------
 net/core/rtnetlink.c |   18 ++++++++++++----
 4 files changed, 23 insertions(+), 131 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 91126b9..373ff70 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -37,11 +37,6 @@
 #include <linux/rtnetlink.h>
 #include <net/rtnetlink.h>
 
-struct dummy_priv {
-	struct net_device *dev;
-	struct list_head list;
-};
-
 static int numdummies = 1;
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
@@ -89,37 +84,9 @@ static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static LIST_HEAD(dummies);
-
-static int dummy_newlink(struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
-{
-	struct dummy_priv *priv = netdev_priv(dev);
-	int err;
-
-	err = register_netdevice(dev);
-	if (err < 0)
-		return err;
-
-	priv->dev = dev;
-	list_add_tail(&priv->list, &dummies);
-	return 0;
-}
-
-static void dummy_dellink(struct net_device *dev)
-{
-	struct dummy_priv *priv = netdev_priv(dev);
-
-	list_del(&priv->list);
-	unregister_netdevice(dev);
-}
-
 static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 	.kind		= "dummy",
-	.priv_size	= sizeof(struct dummy_priv),
 	.setup		= dummy_setup,
-	.newlink	= dummy_newlink,
-	.dellink	= dummy_dellink,
 };
 
 /* Number of dummy devices to be set up by this module. */
@@ -129,12 +96,9 @@ MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 static int __init dummy_init_one(void)
 {
 	struct net_device *dev_dummy;
-	struct dummy_priv *priv;
 	int err;
 
-	dev_dummy = alloc_netdev(sizeof(struct dummy_priv), "dummy%d",
-				 dummy_setup);
-
+	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
 
@@ -146,10 +110,6 @@ static int __init dummy_init_one(void)
 	err = register_netdevice(dev_dummy);
 	if (err < 0)
 		goto err;
-
-	priv = netdev_priv(dev_dummy);
-	priv->dev = dev_dummy;
-	list_add_tail(&priv->list, &dummies);
 	return 0;
 
 err:
@@ -159,7 +119,6 @@ err:
 
 static int __init dummy_init_module(void)
 {
-	struct dummy_priv *priv, *next;
 	int i, err = 0;
 
 	rtnl_lock();
@@ -167,11 +126,8 @@ static int __init dummy_init_module(void)
 
 	for (i = 0; i < numdummies && !err; i++)
 		err = dummy_init_one();
-	if (err < 0) {
-		list_for_each_entry_safe(priv, next, &dummies, list)
-			dummy_dellink(priv->dev);
+	if (err < 0)
 		__rtnl_link_unregister(&dummy_link_ops);
-	}
 	rtnl_unlock();
 
 	return err;
@@ -179,14 +135,7 @@ static int __init dummy_init_module(void)
 
 static void __exit dummy_cleanup_module(void)
 {
-	struct dummy_priv *priv, *next;
-
-	rtnl_lock();
-	list_for_each_entry_safe(priv, next, &dummies, list)
-		dummy_dellink(priv->dev);
-
-	__rtnl_link_unregister(&dummy_link_ops);
-	rtnl_unlock();
+	rtnl_link_unregister(&dummy_link_ops);
 }
 
 module_init(dummy_init_module);
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 669ee1a..c8e7c8f 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -33,15 +33,12 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
-#include <linux/list.h>
 #include <net/pkt_sched.h>
 
 #define TX_TIMEOUT  (2*HZ)
 
 #define TX_Q_LIMIT    32
 struct ifb_private {
-	struct list_head	list;
-	struct net_device	*dev;
 	struct net_device_stats stats;
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
@@ -201,12 +198,6 @@ static struct net_device_stats *ifb_get_stats(struct net_device *dev)
 	return stats;
 }
 
-static LIST_HEAD(ifbs);
-
-/* Number of ifb devices to be set up by this module. */
-module_param(numifbs, int, 0);
-MODULE_PARM_DESC(numifbs, "Number of ifb devices");
-
 static int ifb_close(struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
@@ -230,41 +221,19 @@ static int ifb_open(struct net_device *dev)
 	return 0;
 }
 
-static int ifb_newlink(struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
-{
-	struct ifb_private *priv = netdev_priv(dev);
-	int err;
-
-	err = register_netdevice(dev);
-	if (err < 0)
-		return err;
-
-	priv->dev = dev;
-	list_add_tail(&priv->list, &ifbs);
-	return 0;
-}
-
-static void ifb_dellink(struct net_device *dev)
-{
-	struct ifb_private *priv = netdev_priv(dev);
-
-	list_del(&priv->list);
-	unregister_netdevice(dev);
-}
-
 static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 	.kind		= "ifb",
 	.priv_size	= sizeof(struct ifb_private),
 	.setup		= ifb_setup,
-	.newlink	= ifb_newlink,
-	.dellink	= ifb_dellink,
 };
 
+/* Number of ifb devices to be set up by this module. */
+module_param(numifbs, int, 0);
+MODULE_PARM_DESC(numifbs, "Number of ifb devices");
+
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
-	struct ifb_private *priv;
 	int err;
 
 	dev_ifb = alloc_netdev(sizeof(struct ifb_private),
@@ -281,10 +250,6 @@ static int __init ifb_init_one(int index)
 	err = register_netdevice(dev_ifb);
 	if (err < 0)
 		goto err;
-
-	priv = netdev_priv(dev_ifb);
-	priv->dev = dev_ifb;
-	list_add_tail(&priv->list, &ifbs);
 	return 0;
 
 err:
@@ -294,7 +259,6 @@ err:
 
 static int __init ifb_init_module(void)
 {
-	struct ifb_private *priv, *next;
 	int i, err;
 
 	rtnl_lock();
@@ -302,11 +266,8 @@ static int __init ifb_init_module(void)
 
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i);
-	if (err) {
-		list_for_each_entry_safe(priv, next, &ifbs, list)
-			ifb_dellink(priv->dev);
+	if (err)
 		__rtnl_link_unregister(&ifb_link_ops);
-	}
 	rtnl_unlock();
 
 	return err;
@@ -314,14 +275,7 @@ static int __init ifb_init_module(void)
 
 static void __exit ifb_cleanup_module(void)
 {
-	struct ifb_private *priv, *next;
-
-	rtnl_lock();
-	list_for_each_entry_safe(priv, next, &ifbs, list)
-		ifb_dellink(priv->dev);
-
-	__rtnl_link_unregister(&ifb_link_ops);
-	rtnl_unlock();
+	rtnl_link_unregister(&ifb_link_ops);
 }
 
 module_init(ifb_init_module);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index c5e5655..ec0c58a 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -115,26 +115,6 @@ err1:
 	return err;
 }
 
-/* Cleanup all vlan devices
- * Note: devices that have been registered that but not
- * brought up will exist but have no module ref count.
- */
-static void __exit vlan_cleanup_devices(void)
-{
-	struct net_device *dev, *nxt;
-
-	rtnl_lock();
-	for_each_netdev_safe(dev, nxt) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			unregister_vlan_dev(VLAN_DEV_INFO(dev)->real_dev,
-					    VLAN_DEV_INFO(dev)->vlan_id);
-
-			unregister_netdevice(dev);
-		}
-	}
-	rtnl_unlock();
-}
-
 /*
  *     Module 'remove' entry point.
  *     o delete /proc/net/router directory and static entries.
@@ -150,7 +130,6 @@ static void __exit vlan_cleanup_module(void)
 	unregister_netdevice_notifier(&vlan_notifier_block);
 
 	dev_remove_pack(&vlan_packet_type);
-	vlan_cleanup_devices();
 
 	/* This table must be empty if there are no module
 	 * references left.
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 54c17e4..7b6b163 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -270,6 +270,9 @@ static LIST_HEAD(link_ops);
  */
 int __rtnl_link_register(struct rtnl_link_ops *ops)
 {
+	if (!ops->dellink)
+		ops->dellink = unregister_netdevice;
+
 	list_add_tail(&ops->list, &link_ops);
 	return 0;
 }
@@ -298,12 +301,16 @@ EXPORT_SYMBOL_GPL(rtnl_link_register);
  * __rtnl_link_unregister - Unregister rtnl_link_ops from rtnetlink.
  * @ops: struct rtnl_link_ops * to unregister
  *
- * The caller must hold the rtnl_mutex. This function should be used
- * by drivers that unregister devices during module unloading. It must
- * be called after unregistering the devices.
+ * The caller must hold the rtnl_mutex.
  */
 void __rtnl_link_unregister(struct rtnl_link_ops *ops)
 {
+	struct net_device *dev, *n;
+
+	for_each_netdev_safe(dev, n) {
+		if (dev->rtnl_link_ops == ops)
+			ops->dellink(dev);
+	}
 	list_del(&ops->list);
 }
 
@@ -1067,7 +1074,10 @@ replay:
 		if (tb[IFLA_LINKMODE])
 			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
 
-		err = ops->newlink(dev, tb, data);
+		if (ops->newlink)
+			err = ops->newlink(dev, tb, data);
+		else
+			err = register_netdevice(dev);
 err_free:
 		if (err < 0)
 			free_netdev(dev);
