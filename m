From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 12/13] bridge: Dump vlan information from a bridge port
Date: Tue, 29 Jan 2013 14:52:59 -0500
Message-ID: <1359489180-10012-13-git-send-email-vyasevic@redhat.com>
References: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50354 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753132Ab3A2TxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:53:20 -0500
In-Reply-To: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the RTM_GETLINK dump the vlan filter list of a given
bridge port.  The information depends on setting the filter
flag similar to how nic VF info is dumped.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +-
 include/linux/netdevice.h                     |    3 +-
 include/uapi/linux/rtnetlink.h                |    1 +
 net/bridge/br_netlink.c                       |   97 ++++++++++++++++++++++---
 net/bridge/br_private.h                       |    3 +-
 net/bridge/br_vlan.c                          |    4 +-
 net/core/rtnetlink.c                          |   16 +++-
 7 files changed, 107 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 23fc510..b5e9df5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7078,7 +7078,8 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 }
 
 static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				    struct net_device *dev)
+				    struct net_device *dev,
+				    u32 filter_mask)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	u16 mode;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2dec09e..6eb70eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1020,7 +1020,8 @@ struct net_device_ops {
 						      struct nlmsghdr *nlh);
 	int			(*ndo_bridge_getlink)(struct sk_buff *skb,
 						      u32 pid, u32 seq,
-						      struct net_device *dev);
+						      struct net_device *dev,
+						      u32 filter_mask);
 	int			(*ndo_bridge_dellink)(struct net_device *dev,
 						      struct nlmsghdr *nlh);
 	int			(*ndo_change_carrier)(struct net_device *dev,
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 7a5eb19..7a2144e 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -630,6 +630,7 @@ struct tcamsg {
 
 /* New extended info filters for IFLA_EXT_MASK */
 #define RTEXT_FILTER_VF		(1 << 0)
+#define RTEXT_FILTER_BRVLAN	(1 << 1)
 
 /* End of information exported to user level */
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 0089a3f..ddbb2c7 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -65,15 +65,21 @@ static int br_port_fill_attrs(struct sk_buff *skb,
  * Create one netlink message for one interface
  * Contains port and master info as well as carrier and bridge state.
  */
-static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *port,
-			  u32 pid, u32 seq, int event, unsigned int flags)
+static int br_fill_ifinfo(struct sk_buff *skb,
+			  const struct net_bridge_port *port,
+			  u32 pid, u32 seq, int event, unsigned int flags,
+			  u32 filter_mask, const struct net_device *dev)
 {
-	const struct net_bridge *br = port->br;
-	const struct net_device *dev = port->dev;
+	const struct net_bridge *br;
 	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
 	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
 
+	if (port)
+		br = port->br;
+	else
+		br = netdev_priv(dev);
+
 	br_debug(br, "br_fill_info event %d port %s master %s\n",
 		     event, dev->name, br->dev->name);
 
@@ -99,7 +105,7 @@ static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *por
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
 		goto nla_put_failure;
 
-	if (event == RTM_NEWLINK) {
+	if (event == RTM_NEWLINK && port) {
 		struct nlattr *nest
 			= nla_nest_start(skb, IFLA_PROTINFO | NLA_F_NESTED);
 
@@ -108,6 +114,43 @@ static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *por
 		nla_nest_end(skb, nest);
 	}
 
+	/* Check if  the VID information is requested */
+	if (filter_mask & RTEXT_FILTER_BRVLAN) {
+		struct nlattr *af;
+		const struct net_port_vlans *pv;
+		struct bridge_vlan_info vinfo;
+		u16 vid;
+
+		if (port)
+			pv = nbp_get_vlan_info(port);
+		else
+			pv = br_get_vlan_info(br);
+
+		if (!pv || bitmap_empty(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN))
+			goto done;
+
+		af = nla_nest_start(skb, IFLA_AF_SPEC);
+		if (!af)
+			goto nla_put_failure;
+
+		for (vid = find_first_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN);
+		     vid < BR_VLAN_BITMAP_LEN;
+		     vid = find_next_bit(pv->vlan_bitmap,
+					 BR_VLAN_BITMAP_LEN, vid+1)) {
+			vinfo.vid = vid;
+			vinfo.flags = 0;
+			if (vid == pv->pvid)
+				vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
+
+			if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
+				    sizeof(vinfo), &vinfo))
+				goto nla_put_failure;
+		}
+
+		nla_nest_end(skb, af);
+	}
+
+done:
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -135,7 +178,7 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	if (skb == NULL)
 		goto errout;
 
-	err = br_fill_ifinfo(skb, port, 0, 0, event, 0);
+	err = br_fill_ifinfo(skb, port, 0, 0, event, 0, 0, port->dev);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in br_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -154,16 +197,17 @@ errout:
  * Dump information about all ports, in response to GETLINK
  */
 int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-	       struct net_device *dev)
+	       struct net_device *dev, u32 filter_mask)
 {
 	int err = 0;
 	struct net_bridge_port *port = br_port_get_rcu(dev);
 
-	/* not a bridge port */
-	if (!port)
+	/* not a bridge port and  */
+	if (!port && !(filter_mask & RTEXT_FILTER_BRVLAN))
 		goto out;
 
-	err = br_fill_ifinfo(skb, port, pid, seq, RTM_NEWLINK, NLM_F_MULTI);
+	err = br_fill_ifinfo(skb, port, pid, seq, RTM_NEWLINK, NLM_F_MULTI,
+			     filter_mask, dev);
 out:
 	return err;
 }
@@ -396,6 +440,29 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static size_t br_get_link_af_size(const struct net_device *dev)
+{
+	struct net_port_vlans *pv;
+
+	if (br_port_exists(dev))
+		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
+	else if (dev->priv_flags & IFF_EBRIDGE)
+		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
+	else
+		return 0;
+
+	if (!pv)
+		return 0;
+
+	/* Each VLAN is returned in bridge_vlan_info along with flags */
+	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
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
@@ -409,11 +476,18 @@ int __init br_netlink_init(void)
 	int err;
 
 	br_mdb_init();
-	err = rtnl_link_register(&br_link_ops);
+	err = rtnl_af_register(&br_af_ops);
 	if (err)
 		goto out;
 
+	err = rtnl_link_register(&br_link_ops);
+	if (err)
+		goto out_af;
+
 	return 0;
+
+out_af:
+	rtnl_af_unregister(&br_af_ops);
 out:
 	br_mdb_uninit();
 	return err;
@@ -422,5 +496,6 @@ out:
 void __exit br_netlink_fini(void)
 {
 	br_mdb_uninit();
+	rtnl_af_unregister(&br_af_ops);
 	rtnl_link_unregister(&br_link_ops);
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 57fb7e3..40688ad 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -73,6 +73,7 @@ struct net_port_vlans {
 	void				*parent;
 	struct rcu_head			rcu;
 	unsigned long			vlan_bitmap[BR_VLAN_BITMAP_LEN];
+	u16				num_vlans;
 };
 
 struct net_bridge_fdb_entry
@@ -736,7 +737,7 @@ extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
 extern int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg);
 extern int br_dellink(struct net_device *dev, struct nlmsghdr *nlmsg);
 extern int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-		      struct net_device *dev);
+		      struct net_device *dev, u32 filter_mask);
 
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 6a02519..2243795 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -71,6 +71,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 	}
 
 	set_bit(vid, v->vlan_bitmap);
+	v->num_vlans++;
 	if (flags & BRIDGE_VLAN_INFO_PVID)
 		__vlan_add_pvid(v, vid);
 
@@ -100,6 +101,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 	}
 
 	clear_bit(vid, v->vlan_bitmap);
+	v->num_vlans--;
 	if (first_bit == last_bit) {
 		if (v->port_idx) {
 			struct net_bridge_port *p = vlans_to_port(v);
@@ -364,8 +366,6 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 	pv->parent = port;
 	pv->pvid = BR_INVALID_VID;
 	err = __vlan_add(pv, vid, flags);
-	if (err)
-		goto clean_up;
 
 	if (vid) {
 		err = br_fdb_insert(port->br, port, port->dev->dev_addr, vid);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 87b07d8..257b73e 100644
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
 		if (br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
 			if (idx >= cb->args[0] &&
 			    br_dev->netdev_ops->ndo_bridge_getlink(
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
 	    br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
-		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
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
