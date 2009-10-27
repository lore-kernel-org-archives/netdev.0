From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 3/6] net: add a list_head parameter to dellink() method
Date: Tue, 27 Oct 2009 18:06:36 +0100
Message-ID: <4AE7289C.9050901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36640 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756232AbZJ0RGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:06:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a list_head parameter to rtnl_link_ops->dellink() methods
allow us to queue devices on a list, in order to dismantle
them all at once.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/macvlan.c   |    6 +++---
 drivers/net/veth.c      |    2 +-
 include/net/rtnetlink.h |    3 ++-
 net/8021q/vlan.c        |    8 ++++----
 net/8021q/vlan.h        |    2 +-
 net/core/dev.c          |    2 +-
 net/core/rtnetlink.c    |   14 +++++++-------
 7 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3aabfd9..20b7707 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -555,13 +555,13 @@ static int macvlan_newlink(struct net_device *dev,
 	return 0;
 }
 
-static void macvlan_dellink(struct net_device *dev)
+static void macvlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvlan_port *port = vlan->port;
 
 	list_del(&vlan->list);
-	unregister_netdevice(dev);
+	unregister_netdevice_queue(dev, head);
 
 	if (list_empty(&port->vlans))
 		macvlan_port_destroy(port->dev);
@@ -601,7 +601,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 		break;
 	case NETDEV_UNREGISTER:
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
-			macvlan_dellink(vlan->dev);
+			macvlan_dellink(vlan->dev, NULL);
 		break;
 	}
 	return NOTIFY_DONE;
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index ade5b34..ffb502d 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -442,7 +442,7 @@ err_register_peer:
 	return err;
 }
 
-static void veth_dellink(struct net_device *dev)
+static void veth_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct veth_priv *priv;
 	struct net_device *peer;
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index c3aa044..cd5af1f 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -61,7 +61,8 @@ struct rtnl_link_ops {
 	int			(*changelink)(struct net_device *dev,
 					      struct nlattr *tb[],
 					      struct nlattr *data[]);
-	void			(*dellink)(struct net_device *dev);
+	void			(*dellink)(struct net_device *dev,
+					   struct list_head *head);
 
 	size_t			(*get_size)(const struct net_device *dev);
 	int			(*fill_info)(struct sk_buff *skb,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8836575..6b5c9dd 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -140,7 +140,7 @@ static void vlan_rcu_free(struct rcu_head *rcu)
 	vlan_group_free(container_of(rcu, struct vlan_group, rcu));
 }
 
-void unregister_vlan_dev(struct net_device *dev)
+void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
@@ -164,7 +164,7 @@ void unregister_vlan_dev(struct net_device *dev)
 
 	synchronize_net();
 
-	unregister_netdevice(dev);
+	unregister_netdevice_queue(dev, head);
 
 	/* If the group is now empty, kill off the group. */
 	if (grp->nr_vlans == 0) {
@@ -535,7 +535,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (grp->nr_vlans == 1)
 				i = VLAN_GROUP_ARRAY_LEN;
 
-			unregister_vlan_dev(vlandev);
+			unregister_vlan_dev(vlandev, NULL);
 		}
 		break;
 	}
@@ -642,7 +642,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		unregister_vlan_dev(dev);
+		unregister_vlan_dev(dev, NULL);
 		err = 0;
 		break;
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 4ade5ed..68f9290 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -82,7 +82,7 @@ void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
-void unregister_vlan_dev(struct net_device *dev);
+void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
 
 static inline u32 vlan_get_ingress_priority(struct net_device *dev,
 					    u16 vlan_tci)
diff --git a/net/core/dev.c b/net/core/dev.c
index 15d1453..dedacd8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5629,7 +5629,7 @@ restart:
 
 		/* Delete virtual devices */
 		if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink) {
-			dev->rtnl_link_ops->dellink(dev);
+			dev->rtnl_link_ops->dellink(dev, NULL);
 			goto restart;
 		}
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 52ea418..391a62c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -248,7 +248,7 @@ static LIST_HEAD(link_ops);
 int __rtnl_link_register(struct rtnl_link_ops *ops)
 {
 	if (!ops->dellink)
-		ops->dellink = unregister_netdevice;
+		ops->dellink = unregister_netdevice_queue;
 
 	list_add_tail(&ops->list, &link_ops);
 	return 0;
@@ -277,13 +277,13 @@ EXPORT_SYMBOL_GPL(rtnl_link_register);
 static void __rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
 {
 	struct net_device *dev;
-restart:
+	LIST_HEAD(list_kill);
+
 	for_each_netdev(net, dev) {
-		if (dev->rtnl_link_ops == ops) {
-			ops->dellink(dev);
-			goto restart;
-		}
+		if (dev->rtnl_link_ops == ops)
+			ops->dellink(dev, &list_kill);
 	}
+	unregister_netdevice_many(&list_kill);
 }
 
 void rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
@@ -972,7 +972,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if (!ops)
 		return -EOPNOTSUPP;
 
-	ops->dellink(dev);
+	ops->dellink(dev, NULL);
 	return 0;
 }
 
