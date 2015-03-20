From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next 1/3] net core: Add support for netdevice proto_down.
Date: Fri, 20 Mar 2015 08:11:56 -0700
Message-ID: <1426864318-25132-2-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34775 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbCTPMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 11:12:08 -0400
Received: by pacwe9 with SMTP id we9so111734647pac.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 08:12:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch introduces a netdevice proto_down field to allow multiple
applications to disable a device independent of each other and
independent of the admin. If any of the bits in this field is set an
oper DOWN is done on the device via the IFF_PROTO_DOWN flag. Changes to
IFF_PROTO_DOWN are also notified to interested drivers.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/linux/netdevice.h    |    3 +++
 include/uapi/linux/if.h      |   29 ++++++++++++++++++++++++++++-
 include/uapi/linux/if_link.h |    9 +++++++++
 net/8021q/vlan_dev.c         |    3 ++-
 net/core/dev.c               |   36 ++++++++++++++++++++++++++++++++++++
 net/core/link_watch.c        |    2 +-
 net/core/net-sysfs.c         |    2 ++
 net/core/rtnetlink.c         |   21 +++++++++++++++++++++
 8 files changed, 102 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dd1d069..4a58ec2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1729,6 +1729,7 @@ struct net_device {
 	struct lock_class_key *qdisc_tx_busylock;
 	int group;
 	struct pm_qos_request	pm_qos_req;
+	unsigned int proto_down; /* protocol bits to hold down the operstate */
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -2945,6 +2946,8 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb);
+void dev_set_proto_down(struct net_device *dev, unsigned int proto_down,
+			unsigned int proto_down_change);
 
 extern int		netdev_budget;
 
diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 9cf2394..84c9526 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -66,6 +66,8 @@
  * @IFF_LOWER_UP: driver signals L1 up. Volatile.
  * @IFF_DORMANT: driver signals dormant. Volatile.
  * @IFF_ECHO: echo sent packets. Volatile.
+ * @IFF_PROTO_DOWN: protocol is down on the interface. Userspace can toggle
+ *	this by toggling the net_device proto_down bits. Volatile.
  */
 enum net_device_flags {
 	IFF_UP				= 1<<0,  /* sysfs */
@@ -87,6 +89,7 @@ enum net_device_flags {
 	IFF_LOWER_UP			= 1<<16, /* volatile */
 	IFF_DORMANT			= 1<<17, /* volatile */
 	IFF_ECHO			= 1<<18, /* volatile */
+	IFF_PROTO_DOWN			= 1<<19, /* volatile */
 };
 
 #define IFF_UP				IFF_UP
@@ -108,9 +111,11 @@ enum net_device_flags {
 #define IFF_LOWER_UP			IFF_LOWER_UP
 #define IFF_DORMANT			IFF_DORMANT
 #define IFF_ECHO			IFF_ECHO
+#define IFF_PROTO_DOWN			IFF_PROTO_DOWN
 
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
-		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
+		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT|\
+		IFF_PROTO_DOWN)
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
@@ -156,6 +161,28 @@ enum {
 	IF_LINK_MODE_DORMANT,	/* limit upward transition to dormant */
 };
 
+/**
+ * enum net_device_proto_down - &struct net_device proto_down
+ *
+ * These are the &struct net_device proto_down bits and define a list of
+ * protocols that could hold the device in a IFF_PROTO_DOWN state. Setting of
+ * these bits is triggered by userspace. Userspace can query and set these
+ * flags using userspace utilities. There is also a sysfs entry available
+ * which can only be queried. The sysfs entries are available via
+ * /sys/class/net/<dev>/proto_down
+ *
+ *
+ * @IF_LINK_PROTO_DOWN_MLAG: proto_down by a multi-chassis LAG application.
+ * @IF_LINK_PROTO_DOWN_STP: proto_down by an STP application.
+ */
+enum net_device_proto_down {
+	IF_LINK_PROTO_DOWN_MLAG		= 1<<0,
+	IF_LINK_PROTO_DOWN_STP		= 1<<1,
+};
+
+#define IF_LINK_PROTO_DOWN_MLAG		IF_LINK_PROTO_DOWN_MLAG
+#define IF_LINK_PROTO_DOWN_STP		IF_LINK_PROTO_DOWN_STP
+
 /*
  *	Device mapping structure. I'd just gone off and designed a 
  *	beautiful scheme using only loadable modules with arguments
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 756436e..ebcfbcb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -80,6 +80,13 @@ struct rtnl_link_ifmap {
 	__u8	port;
 };
 
+/* link protodown */
+struct rtnl_link_protodown {
+	__u32	proto_down;		/* Bit mask of protocols that want
+					 * to hold the device down */
+	__u32	proto_down_change;	/* Change mask for proto_down */
+};
+
 /*
  * IFLA_AF_SPEC
  *   Contains nested attributes for address family specific attributes.
@@ -147,6 +154,8 @@ enum {
 	IFLA_CARRIER_CHANGES,
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
+	IFLA_LINKPROTODOWN,	/* Bit mask of protocols that want to
+				 * hold the device down */
 	__IFLA_MAX
 };
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f196552..ea684d2 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -537,7 +537,8 @@ static int vlan_dev_init(struct net_device *dev)
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
-					  IFF_MASTER | IFF_SLAVE);
+					  IFF_MASTER | IFF_SLAVE |
+					  IFF_PROTO_DOWN);
 	dev->iflink = real_dev->ifindex;
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |
diff --git a/net/core/dev.c b/net/core/dev.c
index 39fe369..ac8b4da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5780,6 +5780,42 @@ int dev_change_flags(struct net_device *dev, unsigned int flags)
 }
 EXPORT_SYMBOL(dev_change_flags);
 
+/**
+ *	dev_set_proto_down - Set the link protocol state
+ *	@dev: device
+ *	@proto_down: bitmap of protocols that want to hold the link down
+ *	@proto_down_change: bitmap of protocols that need to be changed
+ *
+ */
+void dev_set_proto_down(struct net_device *dev, unsigned int proto_down,
+			unsigned int proto_down_change)
+{
+	unsigned int old_flags;
+
+	proto_down = (proto_down & proto_down_change) |
+				(dev->proto_down & ~proto_down_change);
+	if (proto_down == dev->proto_down)
+		return;
+
+	old_flags = dev->flags & IFF_PROTO_DOWN;
+	write_lock_bh(&dev_base_lock);
+	dev->proto_down = proto_down;
+	if (dev->proto_down)
+		dev->flags |= IFF_PROTO_DOWN;
+	else
+		dev->flags &= ~IFF_PROTO_DOWN;
+	write_unlock_bh(&dev_base_lock);
+
+	if (old_flags != (dev->flags & IFF_PROTO_DOWN)) {
+		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_PROTO_DOWN, GFP_KERNEL);
+		call_netdevice_notifiers(NETDEV_CHANGE, dev);
+
+		/* the operstate may need to be re-evaluated */
+		linkwatch_fire_event(dev);
+	}
+}
+EXPORT_SYMBOL(dev_set_proto_down);
+
 static int __dev_set_mtu(struct net_device *dev, int new_mtu)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 49a9e3e..c30d653 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -39,7 +39,7 @@ static DEFINE_SPINLOCK(lweventlist_lock);
 
 static unsigned char default_operstate(const struct net_device *dev)
 {
-	if (!netif_carrier_ok(dev))
+	if (!netif_carrier_ok(dev) || (dev->flags & IFF_PROTO_DOWN))
 		return (dev->ifindex != dev->iflink ?
 			IF_OPER_LOWERLAYERDOWN : IF_OPER_DOWN);
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index cf30620..ac3e443 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -113,6 +113,7 @@ NETDEVICE_SHOW_RO(iflink, fmt_dec);
 NETDEVICE_SHOW_RO(ifindex, fmt_dec);
 NETDEVICE_SHOW_RO(type, fmt_dec);
 NETDEVICE_SHOW_RO(link_mode, fmt_dec);
+NETDEVICE_SHOW_RO(proto_down, fmt_hex);
 
 static ssize_t format_name_assign_type(const struct net_device *dev, char *buf)
 {
@@ -466,6 +467,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_gro_flush_timeout.attr,
 	&dev_attr_phys_port_id.attr,
 	&dev_attr_phys_switch_id.attr,
+	&dev_attr_proto_down.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 25b4b5d..ae2a48c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -876,6 +876,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
 	       + nla_total_size(4) /* IFLA_LINK_NETNSID */
+	       + nla_total_size(sizeof(struct rtnl_link_protodown))
 	       + nla_total_size(ext_filter_mask
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
@@ -1059,8 +1060,17 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			.dma         = dev->dma,
 			.port        = dev->if_port,
 		};
+		struct rtnl_link_protodown link_proto_down = {
+			.proto_down		= dev->proto_down,
+			.proto_down_change	= ~0,
+		};
+
 		if (nla_put(skb, IFLA_MAP, sizeof(map), &map))
 			goto nla_put_failure;
+
+		if (nla_put(skb, IFLA_LINKPROTODOWN, sizeof(link_proto_down),
+			    &link_proto_down))
+			goto nla_put_failure;
 	}
 
 	if (dev->addr_len) {
@@ -1249,6 +1259,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
+	[IFLA_LINKPROTODOWN]	= { .len = sizeof(struct rtnl_link_protodown) },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1680,6 +1691,14 @@ static int do_setlink(const struct sk_buff *skb,
 		write_unlock_bh(&dev_base_lock);
 	}
 
+	if (tb[IFLA_LINKPROTODOWN]) {
+		struct rtnl_link_protodown *link_proto_down;
+
+		link_proto_down = nla_data(tb[IFLA_LINKPROTODOWN]);
+		dev_set_proto_down(dev, link_proto_down->proto_down,
+				   link_proto_down->proto_down_change);
+	}
+
 	if (tb[IFLA_VFINFO_LIST]) {
 		struct nlattr *attr;
 		int rem;
@@ -1919,6 +1938,8 @@ struct net_device *rtnl_create_link(struct net *net,
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
 	if (tb[IFLA_GROUP])
 		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
+	if (tb[IFLA_LINKPROTODOWN])
+		dev->proto_down = nla_get_u32(tb[IFLA_LINKPROTODOWN]);
 
 	return dev;
 
-- 
1.7.10.4
