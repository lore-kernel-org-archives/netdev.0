From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V3 12/13] bridge: Dump vlan information from a bridge port
Date: Wed, 19 Dec 2012 12:30:47 -0500
Message-ID: <1355938248-8407-13-git-send-email-vyasevic@redhat.com>
References: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755803Ab2LSRbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 12:31:19 -0500
In-Reply-To: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the RTM_GETLINK dump the vlan filter list of a given
bridge port.  The information depends on setting the filter
flag similar to how nic VF info is dumped.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +-
 include/linux/netdevice.h                     |    3 +-
 include/uapi/linux/if_bridge.h                |    1 +
 include/uapi/linux/rtnetlink.h                |    1 +
 net/bridge/br_if.c                            |    2 +
 net/bridge/br_netlink.c                       |   69 ++++++++++++++++++++++--
 net/bridge/br_private.h                       |    3 +-
 net/core/rtnetlink.c                          |   16 ++++--
 8 files changed, 85 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ec97efe..2f2a8e0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7062,7 +7062,8 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 }
 
 static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				    struct net_device *dev)
+				    struct net_device *dev,
+				    u32 filter_mask)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	u16 mode;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3ee7a80..d93c47c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1008,7 +1008,8 @@ struct net_device_ops {
 						      struct nlmsghdr *nlh);
 	int			(*ndo_bridge_getlink)(struct sk_buff *skb,
 						      u32 pid, u32 seq,
-						      struct net_device *dev);
+						      struct net_device *dev,
+						      u32 filter_mask);
 };
 
 /*
diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 988d858..6b63e3b 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -115,6 +115,7 @@ enum {
 	IFLA_BRIDGE_FLAGS,
 	IFLA_BRIDGE_MODE,
 	IFLA_BRIDGE_VLAN_INFO,
+	IFLA_BRIDGE_VLAN,
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 354a1e7..f20654a 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -624,6 +624,7 @@ struct tcamsg {
 
 /* New extended info filters for IFLA_EXT_MASK */
 #define RTEXT_FILTER_VF		(1 << 0)
+#define RTEXT_FILTER_BRVLAN	(1 << 1)
 
 /* End of information exported to user level */
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 210ce3a..8f27da7 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -373,6 +373,7 @@ int nbp_vlan_add(struct net_bridge_port *p, u16 vid, u16 flags)
 	set_bit(p->port_no, vlan->port_bitmap);
 
 	list_add_tail_rcu(&pve->list, &p->vlan_list);
+	p->num_vlans++;
 
 	if (flags & BRIDGE_VLAN_INFO_UNTAGGED) {
 		err = nbp_vlan_add_untagged(p, vlan, flags);
@@ -420,6 +421,7 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
 	br_vlan_put(vlan);
 
 	list_del_rcu(&pve->list);
+	p->num_vlans--;
 	kfree_rcu(pve, rcu);
 
 	br_vlan_del(p->br, vlan, flags);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 7208899..103c6c7 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -65,8 +65,10 @@ static int br_port_fill_attrs(struct sk_buff *skb,
  * Create one netlink message for one interface
  * Contains port and master info as well as carrier and bridge state.
  */
-static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *port,
-			  u32 pid, u32 seq, int event, unsigned int flags)
+static int br_fill_ifinfo(struct sk_buff *skb,
+			  const struct net_bridge_port *port,
+			  u32 pid, u32 seq, int event, unsigned int flags,
+			  u32 filter_mask)
 {
 	const struct net_bridge *br = port->br;
 	const struct net_device *dev = port->dev;
@@ -108,6 +110,27 @@ static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *por
 		nla_nest_end(skb, nest);
 	}
 
+	/* Check if  the VID information is requested */
+	if (filter_mask & RTEXT_FILTER_BRVLAN) {
+		struct nlattr *af;
+		struct net_port_vlan *pve;
+
+		if (list_empty(&port->vlan_list))
+			goto done;
+
+		af = nla_nest_start(skb, IFLA_AF_SPEC | NLA_F_NESTED);
+		if (!af)
+			goto nla_put_failure;
+
+		list_for_each_entry_rcu(pve, &port->vlan_list, list) {
+			if (nla_put_u16(skb, IFLA_BRIDGE_VLAN, pve->vid))
+				goto nla_put_failure;
+		}
+
+		nla_nest_end(skb, af);
+	}
+
+done:
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -135,7 +158,7 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	if (skb == NULL)
 		goto errout;
 
-	err = br_fill_ifinfo(skb, port, 0, 0, event, 0);
+	err = br_fill_ifinfo(skb, port, 0, 0, event, 0, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in br_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -153,7 +176,7 @@ errout:
  * Dump information about all ports, in response to GETLINK
  */
 int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-	       struct net_device *dev)
+	       struct net_device *dev, u32 filter_mask)
 {
 	int err = 0;
 	struct net_bridge_port *port = br_port_get_rcu(dev);
@@ -162,7 +185,8 @@ int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	if (!port)
 		goto out;
 
-	err = br_fill_ifinfo(skb, port, pid, seq, RTM_NEWLINK, NLM_F_MULTI);
+	err = br_fill_ifinfo(skb, port, pid, seq, RTM_NEWLINK, NLM_F_MULTI,
+			     filter_mask);
 out:
 	return err;
 }
@@ -362,6 +386,23 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static size_t br_get_link_af_size(const struct net_device *dev)
+{
+	struct net_bridge_port *p;
+
+	p = br_port_get_rcu(dev);
+	if (!p)
+		return 0;
+
+	/* Each VLAN is returned as a short in IFLA_BRIDGE_VLAN attr */
+	return p->num_vlans * nla_total_size(2);
+}
+
+struct rtnl_af_ops br_af_ops = {
+	.family			= AF_BRIDGE,
+	.get_link_af_size	= br_get_link_af_size,
+};
+
 struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind		= "bridge",
 	.priv_size	= sizeof(struct net_bridge),
@@ -372,11 +413,27 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 
 int __init br_netlink_init(void)
 {
-	return rtnl_link_register(&br_link_ops);
+	int err;
+
+	err = rtnl_af_register(&br_af_ops);
+	if (err < 0)
+		goto err2;
+
+	err = rtnl_link_register(&br_link_ops);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+
+err2:
+	rtnl_af_unregister(&br_af_ops);
+err1:
+	return err;
 }
 
 void __exit br_netlink_fini(void)
 {
+	rtnl_af_unregister(&br_af_ops);
 	rtnl_link_unregister(&br_link_ops);
 	rtnl_unregister_all(PF_BRIDGE);
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6f662a4..00e07c8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -178,6 +178,7 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
+	u16				num_vlans;
 	struct list_head		vlan_list;
 	struct net_bridge_vlan __rcu	*untagged;
 };
@@ -618,7 +619,7 @@ extern void br_netlink_fini(void);
 extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
 extern int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg);
 extern int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-		      struct net_device *dev);
+		      struct net_device *dev, u32 filter_mask);
 
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8352302..208965f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2326,6 +2326,13 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 	int idx = 0;
 	u32 portid = NETLINK_CB(cb->skb).portid;
 	u32 seq = cb->nlh->nlmsg_seq;
+	struct nlattr *extfilt;
+	u32 filter_mask = 0;
+
+	extfilt = nlmsg_find_attr(cb->nlh, sizeof(struct rtgenmsg),
+				  IFLA_EXT_MASK);
+	if (extfilt)
+		filter_mask = nla_get_u32(extfilt);
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
@@ -2335,14 +2342,15 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 		if (master && master->netdev_ops->ndo_bridge_getlink) {
 			if (idx >= cb->args[0] &&
 			    master->netdev_ops->ndo_bridge_getlink(
-				    skb, portid, seq, dev) < 0)
+				    skb, portid, seq, dev, filter_mask) < 0)
 				break;
 			idx++;
 		}
 
 		if (ops->ndo_bridge_getlink) {
 			if (idx >= cb->args[0] &&
-			    ops->ndo_bridge_getlink(skb, portid, seq, dev) < 0)
+			    ops->ndo_bridge_getlink(skb, portid, seq, dev,
+						    filter_mask) < 0)
 				break;
 			idx++;
 		}
@@ -2383,14 +2391,14 @@ static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
 
 	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
 	    master && master->netdev_ops->ndo_bridge_getlink) {
-		err = master->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+		err = master->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
 		if (err < 0)
 			goto errout;
 	}
 
 	if ((flags & BRIDGE_FLAGS_SELF) &&
 	    dev->netdev_ops->ndo_bridge_getlink) {
-		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
 		if (err < 0)
 			goto errout;
 	}
-- 
1.7.7.6
