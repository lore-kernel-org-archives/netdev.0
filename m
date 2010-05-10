From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] bridge: netpoll cleanup
Date: Mon, 10 May 2010 12:31:08 -0700
Message-ID: <20100510193320.775633381@vyatta.com>
References: <20100510193107.722574297@vyatta.com>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43063 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388Ab0EJTfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 15:35:16 -0400
Content-Disposition: inline; filename=br-netpoll-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move code around so that the ifdef for NETPOLL_CONTROLLER don't have to
show up in main code path. The control functions should be in helpers
that are only compiled if needed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_device.c	2010-05-10 09:51:51.568057462 -0700
+++ b/net/bridge/br_device.c	2010-05-10 11:19:04.867327762 -0700
@@ -191,7 +191,7 @@ static int br_set_tx_csum(struct net_dev
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-bool br_devices_support_netpoll(struct net_bridge *br)
+static bool br_devices_support_netpoll(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
 	bool ret = true;
@@ -217,9 +217,9 @@ static void br_poll_controller(struct ne
 		netpoll_poll_dev(np->real_dev);
 }
 
-void br_netpoll_cleanup(struct net_device *br_dev)
+void br_netpoll_cleanup(struct net_device *dev)
 {
-	struct net_bridge *br = netdev_priv(br_dev);
+	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_port *p, *n;
 	const struct net_device_ops *ops;
 
@@ -235,10 +235,30 @@ void br_netpoll_cleanup(struct net_devic
 	}
 }
 
-#else
-
-void br_netpoll_cleanup(struct net_device *br_dev)
+void br_netpoll_disable(struct net_bridge *br,
+			struct net_device *dev)
 {
+	if (br_devices_support_netpoll(br))
+		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+	if (dev->netdev_ops->ndo_netpoll_cleanup)
+		dev->netdev_ops->ndo_netpoll_cleanup(dev);
+	else
+		dev->npinfo = NULL;
+}
+
+void br_netpoll_enable(struct net_bridge *br,
+		       struct net_device *dev)
+{
+	if (br_devices_support_netpoll(br)) {
+		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+		if (br->dev->npinfo)
+			dev->npinfo = br->dev->npinfo;
+	} else if (!(br->dev->priv_flags & IFF_DISABLE_NETPOLL)) {
+		br->dev->priv_flags |= IFF_DISABLE_NETPOLL;
+		printk(KERN_INFO "%s:new device %s"
+			" does not support netpoll (disabling)",
+			br->dev->name, dev->name);
+	}
 }
 
 #endif
--- a/net/bridge/br_if.c	2010-05-10 09:51:47.878057482 -0700
+++ b/net/bridge/br_if.c	2010-05-10 10:47:51.089679264 -0700
@@ -154,14 +154,7 @@ static void del_nbp(struct net_bridge_po
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
 	kobject_del(&p->kobj);
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	if (br_devices_support_netpoll(br))
-		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-	if (dev->netdev_ops->ndo_netpoll_cleanup)
-		dev->netdev_ops->ndo_netpoll_cleanup(dev);
-	else
-		dev->npinfo = NULL;
-#endif
+	br_netpoll_disable(br, dev);
 	call_rcu(&p->rcu, destroy_nbp_rcu);
 }
 
@@ -455,19 +448,7 @@ int br_add_if(struct net_bridge *br, str
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	if (br_devices_support_netpoll(br)) {
-		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-		if (br->dev->npinfo)
-			dev->npinfo = br->dev->npinfo;
-	} else if (!(br->dev->priv_flags & IFF_DISABLE_NETPOLL)) {
-		br->dev->priv_flags |= IFF_DISABLE_NETPOLL;
-		printk(KERN_INFO "New device %s does not support netpoll\n",
-			dev->name);
-		printk(KERN_INFO "Disabling netpoll for %s\n",
-			br->dev->name);
-	}
-#endif
+	br_netpoll_enable(br, dev);
 
 	return 0;
 err2:
--- a/net/bridge/br_private.h	2010-05-10 09:51:55.267744944 -0700
+++ b/net/bridge/br_private.h	2010-05-10 10:08:09.117432563 -0700
@@ -253,8 +253,18 @@ static inline int br_is_root_bridge(cons
 extern void br_dev_setup(struct net_device *dev);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
-extern bool br_devices_support_netpoll(struct net_bridge *br);
-extern void br_netpoll_cleanup(struct net_device *br_dev);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+extern void br_netpoll_cleanup(struct net_device *dev);
+extern void br_netpoll_enable(struct net_bridge *br,
+			      struct net_device *dev);
+extern void br_netpoll_disable(struct net_bridge *br,
+			       struct net_device *dev);
+#else
+#define br_netpoll_cleanup(br)
+#define br_netpoll_enable(br, dev)
+#define br_netpoll_disable(br, dev)
+
+#endif
 
 /* br_fdb.c */
 extern int br_fdb_init(void);


