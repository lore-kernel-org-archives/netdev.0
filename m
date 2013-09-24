From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 2/2] l2tp: add vlan pseudowire support
Date: Tue, 24 Sep 2013 17:27:10 +0100
Message-ID: <1380040030-6648-3-git-send-email-jchapman@katalix.com>
References: <1380040030-6648-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42171 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432Ab3IXQ1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 12:27:16 -0400
In-Reply-To: <1380040030-6648-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register the l2tp_eth driver for netlink ops using the vlan pseudowire
type. Add code to create/destroy a VLAN netdevice when the pseudowire
type is VLAN. This requires new exports in the vlan code.

This results in two netdevices per vlan pseudowire:
1. a master, which should never be used
2. a vlan device, which is enslaved to the master device

The session's ifname value is set to the VLAN netdevice name such
that it is the name returned in session_get netlink requests. For vlan
pseudowires, this should always be the interface that userspace
configures.
---
 net/l2tp/l2tp_eth.c |   73 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 76125c5..aae38d9 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -17,6 +17,7 @@
 #include <linux/hash.h>
 #include <linux/l2tp.h>
 #include <linux/in.h>
+#include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
 #include <linux/spinlock.h>
 #include <net/sock.h>
@@ -53,6 +54,7 @@ struct l2tp_eth {
 /* via l2tp_session_priv() */
 struct l2tp_eth_sess {
 	struct net_device	*dev;
+	struct net_device	*vlan_dev;
 };
 
 /* per-net private data for this module */
@@ -178,6 +180,50 @@ error:
 	kfree_skb(skb);
 }
 
+static int l2tp_vlan_create(struct l2tp_session *session, u16 vlan_id)
+{
+	struct l2tp_eth_sess *spriv;
+	struct net_device *dev;
+	struct net_device *vlan_dev;
+	char name[IFNAMSIZ + 1];
+	int rc;
+
+	spriv = l2tp_session_priv(session);
+	dev = spriv->dev;
+
+	if (!vlan_id)
+		return -EINVAL;
+
+	snprintf(name, IFNAMSIZ, "%s.%i", dev->name, vlan_id);
+	rtnl_lock();
+	rc = vlan_register_device(dev, vlan_id, &vlan_dev, name);
+	rtnl_unlock();
+	if (rc < 0)
+		return rc;
+
+	spriv->vlan_dev = vlan_dev;
+	strlcpy(session->ifname, vlan_dev->name, IFNAMSIZ);
+
+	return 0;
+}
+
+static int l2tp_vlan_delete(struct l2tp_session *session)
+{
+	struct l2tp_eth_sess *spriv;
+	struct net_device *dev;
+
+	spriv = l2tp_session_priv(session);
+	dev = spriv->dev;
+
+	rtnl_lock();
+	unregister_vlan_dev(spriv->vlan_dev, NULL);
+	rtnl_unlock();
+	strlcpy(session->ifname, dev->name, IFNAMSIZ);
+	spriv->vlan_dev = NULL;
+
+	return 0;
+}
+
 static void l2tp_eth_delete(struct l2tp_session *session)
 {
 	struct l2tp_eth_sess *spriv;
@@ -186,6 +232,8 @@ static void l2tp_eth_delete(struct l2tp_session *session)
 	if (session) {
 		spriv = l2tp_session_priv(session);
 		dev = spriv->dev;
+		if (spriv->vlan_dev)
+			l2tp_vlan_delete(session);
 		if (dev) {
 			unregister_netdev(dev);
 			spriv->dev = NULL;
@@ -277,10 +325,18 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	if (rc < 0)
 		goto out_del_dev;
 
-	__module_get(THIS_MODULE);
 	/* Must be done after register_netdev() */
 	strlcpy(session->ifname, dev->name, IFNAMSIZ);
 
+	if (cfg->pw_type == L2TP_PWTYPE_ETH_VLAN) {
+		/* Create VLAN interface. Replaces session->ifname */
+		rc = l2tp_vlan_create(session, cfg->vlan_id);
+		if (rc < 0)
+			goto out_unreg;
+	}
+
+	__module_get(THIS_MODULE);
+
 	dev_hold(dev);
 	pn = l2tp_eth_pernet(dev_net(dev));
 	spin_lock(&pn->l2tp_eth_lock);
@@ -289,6 +345,8 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 
 	return 0;
 
+out_unreg:
+	unregister_netdev(dev);
 out_del_dev:
 	free_netdev(dev);
 	spriv->dev = NULL;
@@ -328,6 +386,11 @@ static int __init l2tp_eth_init(void)
 	err = l2tp_nl_register_ops(L2TP_PWTYPE_ETH, &l2tp_eth_nl_cmd_ops);
 	if (err)
 		goto out;
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
+	err = l2tp_nl_register_ops(L2TP_PWTYPE_ETH_VLAN, &l2tp_eth_nl_cmd_ops);
+	if (err)
+		goto out;
+#endif
 
 	err = register_pernet_device(&l2tp_eth_net_ops);
 	if (err)
@@ -338,6 +401,9 @@ static int __init l2tp_eth_init(void)
 	return 0;
 
 out_unreg:
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
+	l2tp_nl_unregister_ops(L2TP_PWTYPE_ETH_VLAN);
+#endif
 	l2tp_nl_unregister_ops(L2TP_PWTYPE_ETH);
 out:
 	return err;
@@ -346,6 +412,9 @@ out:
 static void __exit l2tp_eth_exit(void)
 {
 	unregister_pernet_device(&l2tp_eth_net_ops);
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
+	l2tp_nl_unregister_ops(L2TP_PWTYPE_ETH_VLAN);
+#endif
 	l2tp_nl_unregister_ops(L2TP_PWTYPE_ETH);
 }
 
@@ -355,4 +424,4 @@ module_exit(l2tp_eth_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
 MODULE_DESCRIPTION("L2TP ethernet pseudowire driver");
-MODULE_VERSION("1.0");
+MODULE_VERSION("1.1");
-- 
1.7.0.4
