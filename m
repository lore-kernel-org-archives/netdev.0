From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/7] bridge: Fix netpoll support
Date: Thu, 10 Jun 2010 22:42:07 +1000
Message-ID: <E1OMh5D-0004O4-KQ@gondolin.me.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52039 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759086Ab0FJMmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 08:42:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Fix netpoll support

There are multiple problems with the newly added netpoll support:

1) Use-after-free on each netpoll packet.
2) Invoking unsafe code on netpoll/IRQ path.
3) Breaks when netpoll is enabled on the underlying device.

This patch fixes all of these problems.  In particular, we now
allocate proper netpoll structures for each underlying device.

We only allow netpoll to be enabled on the bridge when all the
devices underneath it support netpoll.  Once it is enabled, we
do not allow non-netpoll devices to join the bridge (until netpoll
is disabled again).

This allows us to do away with the npinfo juggling that caused
problem number 1.

Incidentally this patch fixes number 2 by bypassing unsafe code
such as multicast snooping and netfilter.

Reported-by: Qianfeng Zhang <frzhang@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_device.c  |   99 +++++++++++++++++++++++++-----------------------
 net/bridge/br_forward.c |   33 ++++++----------
 net/bridge/br_if.c      |   12 +++--
 net/bridge/br_private.h |   31 +++++++++++----
 4 files changed, 95 insertions(+), 80 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index dce0611..4a572f7 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -47,6 +47,12 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_pull(skb, ETH_HLEN);
 
 	if (is_multicast_ether_addr(dest)) {
+#ifdef CONFIG_NET_POLL_CONTROLLER
+		if (unlikely(in_irq())) {
+			br_flood_deliver(br, skb);
+			goto out;
+		}
+#endif
 		if (br_multicast_rcv(br, NULL, skb))
 			goto out;
 
@@ -199,72 +205,70 @@ static int br_set_tx_csum(struct net_device *dev, u32 data)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static bool br_devices_support_netpoll(struct net_bridge *br)
+static void br_poll_controller(struct net_device *br_dev)
 {
-	struct net_bridge_port *p;
-	bool ret = true;
-	int count = 0;
-	unsigned long flags;
-
-	spin_lock_irqsave(&br->lock, flags);
-	list_for_each_entry(p, &br->port_list, list) {
-		count++;
-		if ((p->dev->priv_flags & IFF_DISABLE_NETPOLL) ||
-		    !p->dev->netdev_ops->ndo_poll_controller)
-			ret = false;
-	}
-	spin_unlock_irqrestore(&br->lock, flags);
-	return count != 0 && ret;
 }
 
-static void br_poll_controller(struct net_device *br_dev)
+static void br_netpoll_cleanup(struct net_device *dev)
 {
-	struct netpoll *np = br_dev->npinfo->netpoll;
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p, *n;
 
-	if (np->real_dev != br_dev)
-		netpoll_poll_dev(np->real_dev);
+	list_for_each_entry_safe(p, n, &br->port_list, list) {
+		br_netpoll_disable(p);
+	}
 }
 
-void br_netpoll_cleanup(struct net_device *dev)
+static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_port *p, *n;
-	const struct net_device_ops *ops;
+	int err = 0;
 
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
-		if (p->dev) {
-			ops = p->dev->netdev_ops;
-			if (ops->ndo_netpoll_cleanup)
-				ops->ndo_netpoll_cleanup(p->dev);
-			else
-				p->dev->npinfo = NULL;
-		}
+		if (!p->dev)
+			continue;
+
+		err = br_netpoll_enable(p);
+		if (err)
+			goto fail;
 	}
+
+out:
+	return err;
+
+fail:
+	br_netpoll_cleanup(dev);
+	goto out;
 }
 
-void br_netpoll_disable(struct net_bridge *br,
-			struct net_device *dev)
+int br_netpoll_enable(struct net_bridge_port *p)
 {
-	if (br_devices_support_netpoll(br))
-		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-	if (dev->netdev_ops->ndo_netpoll_cleanup)
-		dev->netdev_ops->ndo_netpoll_cleanup(dev);
-	else
-		dev->npinfo = NULL;
+	int err = 0;
+
+	p->np = kzalloc(sizeof(*p->np), GFP_KERNEL);
+	err = -ENOMEM;
+	if (!p->np)
+		goto out;
+
+	p->np->dev = p->dev;
+
+	err = __netpoll_setup(p->np);
+	if (err)
+		kfree(p->np);
+
+out:
+	return err;
 }
 
-void br_netpoll_enable(struct net_bridge *br,
-		       struct net_device *dev)
+void br_netpoll_disable(struct net_bridge_port *p)
 {
-	if (br_devices_support_netpoll(br)) {
-		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-		if (br->dev->npinfo)
-			dev->npinfo = br->dev->npinfo;
-	} else if (!(br->dev->priv_flags & IFF_DISABLE_NETPOLL)) {
-		br->dev->priv_flags |= IFF_DISABLE_NETPOLL;
-		br_info(br,"new device %s does not support netpoll (disabling)",
-			dev->name);
-	}
+	if (!p->np)
+		return;
+
+	__netpoll_cleanup(p->np);
+	kfree(p->np);
+	p->np = NULL;
 }
 
 #endif
@@ -293,6 +297,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_netpoll_setup	 = br_netpoll_setup,
 	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
 	.ndo_poll_controller	 = br_poll_controller,
 #endif
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index a98ef13..707b92a 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -50,14 +50,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 			kfree_skb(skb);
 		else {
 			skb_push(skb, ETH_HLEN);
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-			if (unlikely(skb->dev->priv_flags & IFF_IN_NETPOLL)) {
-				netpoll_send_skb(skb->dev->npinfo->netpoll, skb);
-				skb->dev->priv_flags &= ~IFF_IN_NETPOLL;
-			} else
-#endif
-				dev_queue_xmit(skb);
+			dev_queue_xmit(skb);
 		}
 	}
 
@@ -73,23 +66,23 @@ int br_forward_finish(struct sk_buff *skb)
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
+	skb->dev = to->dev;
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	struct net_bridge *br = to->br;
-	if (unlikely(br->dev->priv_flags & IFF_IN_NETPOLL)) {
-		struct netpoll *np;
-		to->dev->npinfo = skb->dev->npinfo;
-		np = skb->dev->npinfo->netpoll;
-		np->real_dev = np->dev = to->dev;
-		to->dev->priv_flags |= IFF_IN_NETPOLL;
+	if (unlikely(in_irq())) {
+		if ((packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb)) ||
+		    !to->np)
+			kfree_skb(skb);
+		else {
+			skb_push(skb, ETH_HLEN);
+			netpoll_send_skb(to->np, skb);
+		}
+		return;
 	}
 #endif
-	skb->dev = to->dev;
+
 	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 		br_forward_finish);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	if (skb->dev->npinfo)
-		skb->dev->npinfo->netpoll->dev = br->dev;
-#endif
 }
 
 static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 18b245e..13102e0 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -154,7 +154,8 @@ static void del_nbp(struct net_bridge_port *p)
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
 	kobject_del(&p->kobj);
 
-	br_netpoll_disable(br, dev);
+	br_netpoll_disable(p);
+
 	call_rcu(&p->rcu, destroy_nbp_rcu);
 }
 
@@ -167,8 +168,6 @@ static void del_br(struct net_bridge *br, struct list_head *head)
 		del_nbp(p);
 	}
 
-	br_netpoll_cleanup(br->dev);
-
 	del_timer_sync(&br->gc_timer);
 
 	br_sysfs_delbr(br->dev);
@@ -428,6 +427,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err2;
 
+	if (br_netpoll_info(br) && ((err = br_netpoll_enable(p))))
+		goto err3;
+
 	rcu_assign_pointer(dev->br_port, p);
 	dev_disable_lro(dev);
 
@@ -448,9 +450,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
-	br_netpoll_enable(br, dev);
-
 	return 0;
+err3:
+	sysfs_remove_link(br->ifobj, p->dev->name);
 err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0f4a74b..1c55c98 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -143,6 +143,10 @@ struct net_bridge_port
 #ifdef CONFIG_SYSFS
 	char				sysfs_name[IFNAMSIZ];
 #endif
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll			*np;
+#endif
 };
 
 struct br_cpu_netstats {
@@ -273,16 +277,27 @@ extern void br_dev_setup(struct net_device *dev);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
-extern void br_netpoll_cleanup(struct net_device *dev);
-extern void br_netpoll_enable(struct net_bridge *br,
-			      struct net_device *dev);
-extern void br_netpoll_disable(struct net_bridge *br,
-			       struct net_device *dev);
+static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+{
+	return br->dev->npinfo;
+}
+
+extern int br_netpoll_enable(struct net_bridge_port *p);
+extern void br_netpoll_disable(struct net_bridge_port *p);
 #else
-#define br_netpoll_cleanup(br)
-#define br_netpoll_enable(br, dev)
-#define br_netpoll_disable(br, dev)
+static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+{
+	return NULL;
+}
+
+static inline int br_netpoll_enable(struct net_bridge_port *p)
+{
+	return 0;
+}
 
+static inline void br_netpoll_disable(struct net_bridge_port *p)
+{
+}
 #endif
 
 /* br_fdb.c */
