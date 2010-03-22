From: Amerigo Wang <amwang@redhat.com>
Subject: [RFC Patch 2/3] bridge: make bridge support netpoll
Date: Mon, 22 Mar 2010 04:17:30 -0400
Message-ID: <20100322082112.4967.5504.sendpatchset@localhost.localdomain>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Based on the previous patch, make bridge support netpoll by:

1) implement the 4 methods to support netpoll for bridge;

2) modify netpoll during forwarding packets in bridge;

3) disable netpoll support of bridge when a netpoll-unabled device
   is added to bridge;

4) enable netpoll support when all underlying devices support netpoll.

Cc: David Miller <davem@davemloft.net>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: WANG Cong <amwang@redhat.com>

---
Index: linux-2.6/net/bridge/br_device.c
===================================================================
--- linux-2.6.orig/net/bridge/br_device.c
+++ linux-2.6/net/bridge/br_device.c
@@ -13,6 +13,7 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 
@@ -162,6 +163,87 @@ static int br_set_tx_csum(struct net_dev
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
+	struct net_bridge *br = netdev_priv(br_dev);
+	struct net_bridge_port *p;
+	unsigned long flags;
+
+	spin_lock_irqsave(&br->lock, flags);
+	list_for_each_entry(p, &br->port_list, list) {
+		if (p->dev->netdev_ops->ndo_poll_controller)
+			netpoll_poll_dev(p->dev);
+	}
+	spin_unlock_irqrestore(&br->lock, flags);
+}
+
+static void br_netpoll_setup(struct net_device *br_dev, struct netpoll_info *npinfo)
+{
+	struct net_bridge *br = netdev_priv(br_dev);
+	struct net_bridge_port *p;
+	unsigned long flags;
+
+	spin_lock_irqsave(&br->lock, flags);
+	list_for_each_entry(p, &br->port_list, list) {
+		if (p->dev)
+			p->dev->npinfo = npinfo;
+	}
+	spin_unlock_irqrestore(&br->lock, flags);
+}
+
+static void br_netpoll_cleanup(struct net_device *br_dev)
+{
+	struct net_bridge *br = netdev_priv(br_dev);
+	struct net_bridge_port *p;
+	const struct net_device_ops *ops;
+	unsigned long flags;
+
+	spin_lock_irqsave(&br->lock, flags);
+	br->dev->npinfo = NULL;
+	list_for_each_entry(p, &br->port_list, list) {
+		if (p->dev) {
+			ops = p->dev->netdev_ops;
+			if (ops->ndo_netpoll_cleanup)
+				ops->ndo_netpoll_cleanup(p->dev);
+			else
+				p->dev->npinfo = NULL;
+		}
+	}
+	spin_unlock_irqrestore(&br->lock, flags);
+}
+
+static int br_netpoll_xmit(struct netpoll *np, struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	dev->priv_flags |= IFF_IN_NETPOLL;
+	ret = dev->netdev_ops->ndo_start_xmit(skb, dev);
+	np->dev = dev;
+	dev->priv_flags &= ~IFF_IN_NETPOLL;
+	return ret;
+}
+
+#endif
+
 static const struct ethtool_ops br_ethtool_ops = {
 	.get_drvinfo    = br_getinfo,
 	.get_link	= ethtool_op_get_link,
@@ -184,6 +266,12 @@ static const struct net_device_ops br_ne
 	.ndo_set_multicast_list	 = br_dev_set_multicast_list,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_netpoll_setup	 = br_netpoll_setup,
+	.ndo_netpoll_xmit	 = br_netpoll_xmit,
+	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
+	.ndo_poll_controller	 = br_poll_controller,
+#endif
 };
 
 void br_dev_setup(struct net_device *dev)
Index: linux-2.6/net/bridge/br_forward.c
===================================================================
--- linux-2.6.orig/net/bridge/br_forward.c
+++ linux-2.6/net/bridge/br_forward.c
@@ -14,6 +14,7 @@
 #include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <linux/netfilter_bridge.h>
@@ -44,7 +45,13 @@ int br_dev_queue_push_xmit(struct sk_buf
 		else {
 			skb_push(skb, ETH_HLEN);
 
-			dev_queue_xmit(skb);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+			if (skb->dev->priv_flags & IFF_IN_NETPOLL) {
+				netpoll_send_skb(skb->dev->npinfo->netpoll, skb);
+				skb->dev->priv_flags &= ~IFF_IN_NETPOLL;
+			} else
+#endif
+				dev_queue_xmit(skb);
 		}
 	}
 
@@ -60,6 +67,16 @@ int br_forward_finish(struct sk_buff *sk
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct net_bridge *br = to->br;
+	if (br->dev->priv_flags & IFF_IN_NETPOLL) {
+		skb->dev->npinfo->netpoll->dev = to->dev;
+		if (!to->dev->npinfo)
+			to->dev->npinfo = skb->dev->npinfo;
+
+		to->dev->priv_flags |= IFF_IN_NETPOLL;
+	}
+#endif
 	skb->dev = to->dev;
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 			br_forward_finish);
Index: linux-2.6/net/bridge/br_if.c
===================================================================
--- linux-2.6.orig/net/bridge/br_if.c
+++ linux-2.6/net/bridge/br_if.c
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_ether.h>
+#include <linux/netpoll.h>
 #include <net/sock.h>
 
 #include "br_private.h"
@@ -152,6 +153,14 @@ static void del_nbp(struct net_bridge_po
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
 	kobject_del(&p->kobj);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (br_devices_support_netpoll(br))
+		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+	if (br->dev->netdev_ops->ndo_netpoll_cleanup)
+		br->dev->netdev_ops->ndo_netpoll_cleanup(br->dev);
+	else
+		dev->npinfo = NULL;
+#endif
 	call_rcu(&p->rcu, destroy_nbp_rcu);
 }
 
@@ -437,6 +446,20 @@ int br_add_if(struct net_bridge *br, str
 
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
@@ -225,6 +225,7 @@ static inline int br_is_root_bridge(cons
 extern void br_dev_setup(struct net_device *dev);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
+extern bool br_devices_support_netpoll(struct net_bridge *br);
 
 /* br_fdb.c */
 extern int br_fdb_init(void);
