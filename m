From: Amerigo Wang <amwang@redhat.com>
Subject: [v4 Patch 2/3] bridge: make bridge support netpoll
Date: Tue, 27 Apr 2010 03:55:56 -0400
Message-ID: <20100427075952.4908.60515.sendpatchset@localhost.localdomain>
References: <20100427075937.4908.18468.sendpatchset@localhost.localdomain>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>,
	Jeff Moyer <jmoyer@redhat.com>, Matt Mackall <mpm@selenic.com>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34587 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656Ab0D0H4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 03:56:37 -0400
In-Reply-To: <20100427075937.4908.18468.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Based on the previous patch, make bridge support netpoll by:

1) implement the 2 methods to support netpoll for bridge;

2) modify netpoll during forwarding packets via bridge;

3) disable netpoll support of bridge when a netpoll-unabled device
   is added to bridge;

4) enable netpoll support when all underlying devices support netpoll.

Cc: David Miller <davem@davemloft.net>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: WANG Cong <amwang@redhat.com>

---

Index: linux-2.6/net/bridge/br_device.c
===================================================================
--- linux-2.6.orig/net/bridge/br_device.c
+++ linux-2.6/net/bridge/br_device.c
@@ -13,8 +13,10 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/list.h>
 
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -162,6 +164,59 @@ static int br_set_tx_csum(struct net_dev
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+bool br_devices_support_netpoll(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+	bool ret = true;
+	int count = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&br->lock, flags);
+	list_for_each_entry(p, &br->port_list, list) {
+		count++;
+		if (p->dev->priv_flags & IFF_DISABLE_NETPOLL
+				|| !p->dev->netdev_ops->ndo_poll_controller)
+			ret = false;
+	}
+	spin_unlock_irqrestore(&br->lock, flags);
+	return count != 0 && ret;
+}
+
+static void br_poll_controller(struct net_device *br_dev)
+{
+	struct netpoll *np = br_dev->npinfo->netpoll;
+
+	if (np->real_dev != br_dev)
+		netpoll_poll_dev(np->real_dev);
+}
+
+void br_netpoll_cleanup(struct net_device *br_dev)
+{
+	struct net_bridge *br = netdev_priv(br_dev);
+	struct net_bridge_port *p, *n;
+	const struct net_device_ops *ops;
+
+	br->dev->npinfo = NULL;
+	list_for_each_entry_safe(p, n, &br->port_list, list) {
+		if (p->dev) {
+			ops = p->dev->netdev_ops;
+			if (ops->ndo_netpoll_cleanup)
+				ops->ndo_netpoll_cleanup(p->dev);
+			else
+				p->dev->npinfo = NULL;
+		}
+	}
+}
+
+#else
+
+void br_netpoll_cleanup(struct net_device *br_dev)
+{
+}
+
+#endif
+
 static const struct ethtool_ops br_ethtool_ops = {
 	.get_drvinfo    = br_getinfo,
 	.get_link	= ethtool_op_get_link,
@@ -184,6 +239,10 @@ static const struct net_device_ops br_ne
 	.ndo_set_multicast_list	 = br_dev_set_multicast_list,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
+	.ndo_poll_controller	 = br_poll_controller,
+#endif
 };
 
 void br_dev_setup(struct net_device *dev)
Index: linux-2.6/net/bridge/br_forward.c
===================================================================
--- linux-2.6.orig/net/bridge/br_forward.c
+++ linux-2.6/net/bridge/br_forward.c
@@ -15,6 +15,7 @@
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <linux/netfilter_bridge.h>
@@ -50,7 +51,13 @@ int br_dev_queue_push_xmit(struct sk_buf
 		else {
 			skb_push(skb, ETH_HLEN);
 
-			dev_queue_xmit(skb);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+			if (unlikely(skb->dev->priv_flags & IFF_IN_NETPOLL)) {
+				netpoll_send_skb(skb->dev->npinfo->netpoll, skb);
+				skb->dev->priv_flags &= ~IFF_IN_NETPOLL;
+			} else
+#endif
+				dev_queue_xmit(skb);
 		}
 	}
 
@@ -66,9 +73,23 @@ int br_forward_finish(struct sk_buff *sk
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct net_bridge *br = to->br;
+	if (unlikely(br->dev->priv_flags & IFF_IN_NETPOLL)) {
+		struct netpoll *np;
+		to->dev->npinfo = skb->dev->npinfo;
+		np = skb->dev->npinfo->netpoll;
+		np->real_dev = np->dev = to->dev;
+		to->dev->priv_flags |= IFF_IN_NETPOLL;
+	}
+#endif
 	skb->dev = to->dev;
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 			br_forward_finish);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (skb->dev->npinfo)
+		skb->dev->npinfo->netpoll->dev = br->dev;
+#endif
 }
 
 static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
Index: linux-2.6/net/bridge/br_if.c
===================================================================
--- linux-2.6.orig/net/bridge/br_if.c
+++ linux-2.6/net/bridge/br_if.c
@@ -13,6 +13,7 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/ethtool.h>
 #include <linux/if_arp.h>
 #include <linux/module.h>
@@ -153,6 +154,14 @@ static void del_nbp(struct net_bridge_po
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
 	kobject_del(&p->kobj);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (br_devices_support_netpoll(br))
+		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+	if (dev->netdev_ops->ndo_netpoll_cleanup)
+		dev->netdev_ops->ndo_netpoll_cleanup(dev);
+	else
+		dev->npinfo = NULL;
+#endif
 	call_rcu(&p->rcu, destroy_nbp_rcu);
 }
 
@@ -165,6 +174,8 @@ static void del_br(struct net_bridge *br
 		del_nbp(p);
 	}
 
+	br_netpoll_cleanup(br->dev);
+
 	del_timer_sync(&br->gc_timer);
 
 	br_sysfs_delbr(br->dev);
@@ -438,6 +449,20 @@ int br_add_if(struct net_bridge *br, str
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (br_devices_support_netpoll(br)) {
+		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+		if (br->dev->npinfo)
+			dev->npinfo = br->dev->npinfo;
+	} else if (!(br->dev->priv_flags & IFF_DISABLE_NETPOLL)) {
+		br->dev->priv_flags |= IFF_DISABLE_NETPOLL;
+		printk(KERN_INFO "New device %s does not support netpoll\n",
+			dev->name);
+		printk(KERN_INFO "Disabling netpoll for %s\n",
+			br->dev->name);
+	}
+#endif
+
 	return 0;
 err2:
 	br_fdb_delete_by_port(br, p, 1);
Index: linux-2.6/net/bridge/br_private.h
===================================================================
--- linux-2.6.orig/net/bridge/br_private.h
+++ linux-2.6/net/bridge/br_private.h
@@ -233,6 +233,8 @@ static inline int br_is_root_bridge(cons
 extern void br_dev_setup(struct net_device *dev);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
+extern bool br_devices_support_netpoll(struct net_bridge *br);
+extern void br_netpoll_cleanup(struct net_device *br_dev);
 
 /* br_fdb.c */
 extern int br_fdb_init(void);
