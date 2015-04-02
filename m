From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 01/12] dev: introduce dev_get_iflink()
Date: Thu,  2 Apr 2015 17:07:00 +0200
Message-ID: <1427987231-3669-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56590 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbbDBPHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:23 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patch is to prepare the removal of the iflink field. It
introduces a new ndo function, which will be implemented by virtual interfaces.

There is no functional change into this patch. All readers of iflink field
now call dev_get_iflink().

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/ipvlan/ipvlan_core.c |  2 +-
 include/linux/netdevice.h        |  4 ++++
 net/batman-adv/hard-interface.c  |  5 +++--
 net/bridge/br_netlink.c          |  4 ++--
 net/core/dev.c                   | 21 +++++++++++++++++++--
 net/core/link_watch.c            |  4 ++--
 net/core/net-sysfs.c             | 10 +++++++++-
 net/core/rtnetlink.c             |  8 ++++----
 net/ipv4/ipmr.c                  |  2 +-
 net/ipv6/addrconf.c              |  4 ++--
 net/ipv6/ip6mr.c                 |  2 +-
 11 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 2a175006028b..131bde98188d 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -330,7 +330,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 	struct rtable *rt;
 	int err, ret = NET_XMIT_DROP;
 	struct flowi4 fl4 = {
-		.flowi4_oif = dev->iflink,
+		.flowi4_oif = dev_get_iflink(dev),
 		.flowi4_tos = RT_TOS(ip4h->tos),
 		.flowi4_flags = FLOWI_FLAG_ANYSRC,
 		.daddr = ip4h->daddr,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 967bb4c8caf1..788eb7a622ad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1030,6 +1030,8 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *			     int queue_index, u32 maxrate);
  *	Called when a user wants to set a max-rate limitation of specific
  *	TX queue.
+ * int (*ndo_get_iflink)(const struct net_device *dev);
+ *	Called to get the iflink value of this device.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1191,6 +1193,7 @@ struct net_device_ops {
 	int			(*ndo_set_tx_maxrate)(struct net_device *dev,
 						      int queue_index,
 						      u32 maxrate);
+	int			(*ndo_get_iflink)(const struct net_device *dev);
 };
 
 /**
@@ -2149,6 +2152,7 @@ void __dev_remove_pack(struct packet_type *pt);
 void dev_add_offload(struct packet_offload *po);
 void dev_remove_offload(struct packet_offload *po);
 
+int dev_get_iflink(const struct net_device *dev);
 struct net_device *__dev_get_by_flags(struct net *net, unsigned short flags,
 				      unsigned short mask);
 struct net_device *dev_get_by_name(struct net *net, const char *name);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index fbda6b54baff..baf1f9843f2c 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -83,11 +83,12 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 		return true;
 
 	/* no more parents..stop recursion */
-	if (net_dev->iflink == 0 || net_dev->iflink == net_dev->ifindex)
+	if (dev_get_iflink(net_dev) == 0 ||
+	    dev_get_iflink(net_dev) == net_dev->ifindex)
 		return false;
 
 	/* recurse over the parent device */
-	parent_dev = __dev_get_by_index(&init_net, net_dev->iflink);
+	parent_dev = __dev_get_by_index(&init_net, dev_get_iflink(net_dev));
 	/* if we got a NULL parent_dev there is something broken.. */
 	if (WARN(!parent_dev, "Cannot find parent device"))
 		return false;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e1115a224a95..0e4ddb81610d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -305,8 +305,8 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_OPERSTATE, operstate) ||
 	    (dev->addr_len &&
 	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
-	    (dev->ifindex != dev->iflink &&
-	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
+	    (dev->ifindex != dev_get_iflink(dev) &&
+	     nla_put_u32(skb, IFLA_LINK, dev_get_iflink(dev))))
 		goto nla_put_failure;
 
 	if (event == RTM_NEWLINK && port) {
diff --git a/net/core/dev.c b/net/core/dev.c
index 65492b0354c0..77172d085760 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -660,6 +660,23 @@ __setup("netdev=", netdev_boot_setup);
 *******************************************************************************/
 
 /**
+ *	dev_get_iflink	- get 'iflink' value of a interface
+ *	@dev: targeted interface
+ *
+ *	Indicates the ifindex the interface is linked to.
+ *	Physical interfaces have the same 'ifindex' and 'iflink' values.
+ */
+
+int dev_get_iflink(const struct net_device *dev)
+{
+	if (dev->netdev_ops && dev->netdev_ops->ndo_get_iflink)
+		return dev->netdev_ops->ndo_get_iflink(dev);
+
+	return dev->iflink;
+}
+EXPORT_SYMBOL(dev_get_iflink);
+
+/**
  *	__dev_get_by_name	- find a device by its name
  *	@net: the applicable net namespace
  *	@name: name to find
@@ -6345,7 +6362,7 @@ int register_netdevice(struct net_device *dev)
 	else if (__dev_get_by_index(net, dev->ifindex))
 		goto err_uninit;
 
-	if (dev->iflink == -1)
+	if (dev_get_iflink(dev) == -1)
 		dev->iflink = dev->ifindex;
 
 	/* Transfer changeable features to wanted_features and enable
@@ -7061,7 +7078,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* If there is an ifindex conflict assign a new one */
 	if (__dev_get_by_index(net, dev->ifindex)) {
-		int iflink = (dev->iflink == dev->ifindex);
+		int iflink = (dev_get_iflink(dev) == dev->ifindex);
 		dev->ifindex = dev_new_index(net);
 		if (iflink)
 			dev->iflink = dev->ifindex;
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 49a9e3e06c08..982861607f88 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -40,7 +40,7 @@ static DEFINE_SPINLOCK(lweventlist_lock);
 static unsigned char default_operstate(const struct net_device *dev)
 {
 	if (!netif_carrier_ok(dev))
-		return (dev->ifindex != dev->iflink ?
+		return (dev->ifindex != dev_get_iflink(dev) ?
 			IF_OPER_LOWERLAYERDOWN : IF_OPER_DOWN);
 
 	if (netif_dormant(dev))
@@ -89,7 +89,7 @@ static bool linkwatch_urgent_event(struct net_device *dev)
 	if (!netif_running(dev))
 		return false;
 
-	if (dev->ifindex != dev->iflink)
+	if (dev->ifindex != dev_get_iflink(dev))
 		return true;
 
 	if (dev->priv_flags & IFF_TEAM_PORT)
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index cc5cf689809c..4238d6da5c60 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -109,11 +109,19 @@ NETDEVICE_SHOW_RO(dev_id, fmt_hex);
 NETDEVICE_SHOW_RO(dev_port, fmt_dec);
 NETDEVICE_SHOW_RO(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW_RO(addr_len, fmt_dec);
-NETDEVICE_SHOW_RO(iflink, fmt_dec);
 NETDEVICE_SHOW_RO(ifindex, fmt_dec);
 NETDEVICE_SHOW_RO(type, fmt_dec);
 NETDEVICE_SHOW_RO(link_mode, fmt_dec);
 
+static ssize_t iflink_show(struct device *dev, struct device_attribute *attr,
+			   char *buf)
+{
+	struct net_device *ndev = to_net_dev(dev);
+
+	return sprintf(buf, fmt_dec, dev_get_iflink(ndev));
+}
+static DEVICE_ATTR_RO(iflink);
+
 static ssize_t format_name_assign_type(const struct net_device *dev, char *buf)
 {
 	return sprintf(buf, fmt_dec, dev->name_assign_type);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b96ac2109c82..ee0186cdd5cf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1055,8 +1055,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 #ifdef CONFIG_RPS
 	    nla_put_u32(skb, IFLA_NUM_RX_QUEUES, dev->num_rx_queues) ||
 #endif
-	    (dev->ifindex != dev->iflink &&
-	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
+	    (dev->ifindex != dev_get_iflink(dev) &&
+	     nla_put_u32(skb, IFLA_LINK, dev_get_iflink(dev))) ||
 	    (upper_dev &&
 	     nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex)) ||
 	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
@@ -2863,8 +2863,8 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	     nla_put_u32(skb, IFLA_MASTER, br_dev->ifindex)) ||
 	    (dev->addr_len &&
 	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
-	    (dev->ifindex != dev->iflink &&
-	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
+	    (dev->ifindex != dev_get_iflink(dev) &&
+	     nla_put_u32(skb, IFLA_LINK, dev_get_iflink(dev))))
 		goto nla_put_failure;
 
 	br_afspec = nla_nest_start(skb, IFLA_AF_SPEC);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b4a545d24adb..eec68b0c3bc8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -801,7 +801,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 	v->pkt_out = 0;
 	v->link = dev->ifindex;
 	if (v->flags & (VIFF_TUNNEL | VIFF_REGISTER))
-		v->link = dev->iflink;
+		v->link = dev_get_iflink(dev);
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5c9e94cb1b2c..37b70e82bff8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4858,8 +4858,8 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 	    (dev->addr_len &&
 	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
 	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
-	    (dev->ifindex != dev->iflink &&
-	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
+	    (dev->ifindex != dev_get_iflink(dev) &&
+	     nla_put_u32(skb, IFLA_LINK, dev_get_iflink(dev))))
 		goto nla_put_failure;
 	protoinfo = nla_nest_start(skb, IFLA_PROTINFO);
 	if (!protoinfo)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index caf6b99374e6..18a5ab286420 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -992,7 +992,7 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 	v->pkt_out = 0;
 	v->link = dev->ifindex;
 	if (v->flags & MIFF_REGISTER)
-		v->link = dev->iflink;
+		v->link = dev_get_iflink(dev);
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
-- 
2.2.2
