From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCHv9] macvlan: add source mode
Date: Fri, 14 Mar 2014 12:49:46 +0100
Message-ID: <1394797786-27420-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
	<netdev@vger.kernel.org>, <projekt-wlan@fem.tu-ilmenau.de>,
	Stefan Gula <steweg@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:56130 "EHLO
	mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506AbaCNLt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 07:49:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new mode of operation to macvlan, called "source".
It allows one to set a list of allowed mac address, which is used
to match against source mac address from received frames on underlying
interface.
This enables creating mac based VLAN associations, instead of standard
port or tag based. The feature is useful to deploy 802.1x mac based
behavior, where drivers of underlying interfaces doesn't allows that.

Configuration is done through the netlink interface using e.g.:
 ip link add link eth0 name macvlan0 type macvlan mode source
 ip link add link eth0 name macvlan1 type macvlan mode source
 ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11:11
 ip link set link macvlan0 type macvlan macaddr add 00:22:22:22:22:22
 ip link set link macvlan0 type macvlan macaddr add 00:33:33:33:33:33
 ip link set link macvlan1 type macvlan macaddr add 00:33:33:33:33:33
 ip link set link macvlan1 type macvlan macaddr add 00:44:44:44:44:44

This allows clients with MAC addresses 00:11:11:11:11:11,
00:22:22:22:22:22 to be part of only VLAN associated with macvlan0
interface. Clients with MAC addresses 00:44:44:44:44:44 with only VLAN
associated with macvlan1 interface. And client with MAC address
00:33:33:33:33:33 to be associated with both VLANs.

Based on work of Stefan Gula <steweg@gmail.com>

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
Cc: <netdev@vger.kernel.org>
Cc: <projekt-wlan@fem.tu-ilmenau.de>
Cc: Stefan Gula <steweg@gmail.com>

v8: last version of Stefan Gula for Kernel 3.2.1
v9: rework onto linux-next 2014-03-12 by Michael Braun
v9: add MACADDR_SET command
v9: enable to configure mac for source mode while creating interface

---
 drivers/net/macvlan.c        | 274 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h   |   1 +
 include/uapi/linux/if_link.h |  12 ++
 3 files changed, 287 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c683ac2..a4268d0 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -42,6 +42,14 @@ struct macvlan_port {
 	struct rcu_head		rcu;
 	bool 			passthru;
 	int			count;
+	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
+};
+
+struct macvlan_source_list {
+	struct hlist_node	hlist;
+	struct macvlan_dev	*vlan;
+	unsigned char		addr[ETH_ALEN];
+	struct rcu_head		rcu;
 };
 
 static void macvlan_port_destroy(struct net_device *dev);
@@ -70,6 +78,21 @@ static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 	return NULL;
 }
 
+static struct macvlan_source_list *macvlan_hash_lookup_sources_list(
+	const struct macvlan_dev *vlan,
+	const unsigned char *addr)
+{
+	struct macvlan_source_list *list;
+	struct hlist_head *h = &vlan->port->vlan_source_hash[addr[5]];
+
+	hlist_for_each_entry_rcu(list, h, hlist) {
+		if (ether_addr_equal_unaligned(list->addr, addr) &&
+		    list->vlan == vlan)
+			return list;
+	}
+	return NULL;
+}
+
 static void macvlan_hash_add(struct macvlan_dev *vlan)
 {
 	struct macvlan_port *port = vlan->port;
@@ -78,6 +101,29 @@ static void macvlan_hash_add(struct macvlan_dev *vlan)
 	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[addr[5]]);
 }
 
+static int macvlan_hash_add_sources(struct macvlan_dev *vlan,
+				    const unsigned char *addr)
+{
+	struct macvlan_port *port = vlan->port;
+	struct macvlan_source_list *list;
+	struct hlist_head *h;
+
+	list = macvlan_hash_lookup_sources_list(vlan, addr);
+	if (!list) {
+		list = kmalloc(sizeof(*list), GFP_KERNEL);
+		if (list) {
+			ether_addr_copy(list->addr, addr);
+			list->vlan = vlan;
+			h = &port->vlan_source_hash[addr[5]];
+			hlist_add_head_rcu(&list->hlist, h);
+			vlan->macaddr_count++;
+		} else {
+			return -ENOMEM;
+		}
+	}
+	return 0;
+}
+
 static void macvlan_hash_del(struct macvlan_dev *vlan, bool sync)
 {
 	hlist_del_rcu(&vlan->hlist);
@@ -85,6 +131,12 @@ static void macvlan_hash_del(struct macvlan_dev *vlan, bool sync)
 		synchronize_rcu();
 }
 
+static void macvlan_hash_del_sources(struct macvlan_source_list *list)
+{
+	hlist_del_rcu(&list->hlist);
+	kfree_rcu(list, rcu);
+}
+
 static void macvlan_hash_change_addr(struct macvlan_dev *vlan,
 					const unsigned char *addr)
 {
@@ -182,6 +234,65 @@ static void macvlan_broadcast(struct sk_buff *skb,
 	}
 }
 
+static void macvlan_flush_sources(struct macvlan_port *port,
+				struct macvlan_dev *vlan)
+{
+	int i;
+
+	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
+		struct hlist_node *h, *n;
+
+		hlist_for_each_safe(h, n, &port->vlan_source_hash[i]) {
+			struct macvlan_source_list *list;
+
+			list = hlist_entry(h, struct macvlan_source_list,
+					   hlist);
+			if (list->vlan == vlan)
+				macvlan_hash_del_sources(list);
+		}
+	}
+	vlan->macaddr_count = 0;
+}
+
+static void macvlan_forward_sources_one(struct sk_buff *skb,
+					struct macvlan_dev *vlan)
+{
+	struct sk_buff *nskb;
+	struct net_device *dev;
+	int len;
+	int ret;
+
+	dev = vlan->dev;
+	if (unlikely(!(dev->flags & IFF_UP)))
+		return;
+
+	nskb = skb_clone(skb, GFP_ATOMIC);
+	if (!nskb)
+		return;
+
+	len = nskb->len + ETH_HLEN;
+	nskb->dev = dev;
+	nskb->pkt_type = PACKET_HOST;
+
+	ret = netif_rx(nskb);
+	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
+}
+
+static void macvlan_forward_sources(struct sk_buff *skb,
+				    struct macvlan_port *port,
+				    const unsigned char *addr)
+{
+	struct macvlan_source_list *list;
+	struct hlist_head *h = &port->vlan_source_hash[addr[5]];
+
+	hlist_for_each_entry_rcu(list, h, hlist) {
+		if (ether_addr_equal_unaligned(list->addr, addr))
+			if (list->vlan->dev->flags & IFF_UP)
+				macvlan_forward_sources_one(skb, list->vlan);
+	}
+	return;
+}
+
 /* called under rcu_read_lock() from netif_receive_skb */
 static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 {
@@ -200,6 +311,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
 		eth = eth_hdr(skb);
+		macvlan_forward_sources(skb, port, eth->h_source);
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
@@ -230,6 +342,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_PASS;
 	}
 
+	macvlan_forward_sources(skb, port, eth->h_source);
 	if (port->passthru)
 		vlan = list_first_or_null_rcu(&port->vlans,
 					      struct macvlan_dev, list);
@@ -562,6 +675,7 @@ static void macvlan_uninit(struct net_device *dev)
 
 	free_percpu(vlan->pcpu_stats);
 
+	macvlan_flush_sources(port, vlan);
 	port->count -= 1;
 	if (!port->count)
 		macvlan_port_destroy(port->dev);
@@ -763,6 +877,8 @@ static int macvlan_port_create(struct net_device *dev)
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
+	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&port->vlan_source_hash[i]);
 
 	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
 	if (err)
@@ -800,11 +916,97 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		case MACVLAN_MODE_VEPA:
 		case MACVLAN_MODE_BRIDGE:
 		case MACVLAN_MODE_PASSTHRU:
+		case MACVLAN_MODE_SOURCE:
 			break;
 		default:
 			return -EINVAL;
 		}
 	}
+
+	if (data && data[IFLA_MACVLAN_MACADDR_MODE]) {
+		switch (nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE])) {
+		case MACVLAN_MACADDR_ADD:
+		case MACVLAN_MACADDR_DEL:
+		case MACVLAN_MACADDR_FLUSH:
+		case MACVLAN_MACADDR_SET:
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	if (data && data[IFLA_MACVLAN_MACADDR]) {
+		if (nla_len(data[IFLA_MACVLAN_MACADDR]) != ETH_ALEN)
+			return -EINVAL;
+
+		if (!is_valid_ether_addr(nla_data(data[IFLA_MACVLAN_MACADDR])))
+			return -EADDRNOTAVAIL;
+	}
+
+	if (data && data[IFLA_MACVLAN_MACADDR_COUNT])
+		return -EINVAL;
+
+	return 0;
+}
+
+static int macvlan_changelink_sources(struct macvlan_dev *vlan, u32 mode,
+				      struct nlattr *data[])
+{
+	char *addr = NULL;
+	int ret, rem, len;
+	struct nlattr *nla, *head;
+
+	if (data[IFLA_MACVLAN_MACADDR])
+		addr = nla_data(data[IFLA_MACVLAN_MACADDR]);
+
+	if (mode == MACVLAN_MACADDR_ADD) {
+		if (!addr)
+			return -EINVAL;
+
+		return macvlan_hash_add_sources(vlan, addr);
+
+	} else if (mode == MACVLAN_MACADDR_DEL) {
+		struct macvlan_source_list *list;
+
+		if (!addr)
+			return -EINVAL;
+
+		list = macvlan_hash_lookup_sources_list(vlan, addr);
+		if (list) {
+			macvlan_hash_del_sources(list);
+			vlan->macaddr_count--;
+		}
+	} else if (mode == MACVLAN_MACADDR_FLUSH) {
+		macvlan_flush_sources(vlan->port, vlan);
+	} else if (mode == MACVLAN_MACADDR_SET) {
+		macvlan_flush_sources(vlan->port, vlan);
+
+		if (addr) {
+			ret = macvlan_hash_add_sources(vlan, addr);
+			if (ret)
+				return ret;
+		}
+
+		if (!data || !data[IFLA_MACVLAN_MACADDR_DATA])
+			return 0;
+
+		head = nla_data(data[IFLA_MACVLAN_MACADDR_DATA]);
+		len = nla_len(data[IFLA_MACVLAN_MACADDR_DATA]);
+
+		nla_for_each_attr(nla, head, len, rem) {
+			if (nla_type(nla) != IFLA_MACVLAN_MACADDR ||
+			    nla_len(nla) != ETH_ALEN)
+				continue;
+
+			addr = nla_data(nla);
+			ret = macvlan_hash_add_sources(vlan, addr);
+			if (ret)
+				return ret;
+		}
+	} else {
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -815,6 +1017,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	struct macvlan_port *port;
 	struct net_device *lowerdev;
 	int err;
+	int macmode;
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
@@ -867,6 +1070,15 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		eth_hw_addr_inherit(dev, lowerdev);
 	}
 
+	if (data && data[IFLA_MACVLAN_MACADDR_MODE]) {
+		if (vlan->mode != MACVLAN_MODE_SOURCE)
+			return -EINVAL;
+		macmode = nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE]);
+		err = macvlan_changelink_sources(vlan, macmode, data);
+		if (err)
+			return err;
+	}
+
 	port->count += 1;
 	err = register_netdevice(dev);
 	if (err < 0)
@@ -903,6 +1115,8 @@ void macvlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (vlan->mode == MACVLAN_MODE_SOURCE)
+		macvlan_flush_sources(vlan->port, vlan);
 	list_del_rcu(&vlan->list);
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(vlan->lowerdev, dev);
@@ -915,6 +1129,8 @@ static int macvlan_changelink(struct net_device *dev,
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	enum macvlan_mode mode;
 	bool set_mode = false;
+	enum macvlan_macaddr_mode macmode;
+	int ret;
 
 	/* Validate mode, but don't set yet: setting flags may fail. */
 	if (data && data[IFLA_MACVLAN_MODE]) {
@@ -924,6 +1140,9 @@ static int macvlan_changelink(struct net_device *dev,
 		if ((mode == MACVLAN_MODE_PASSTHRU) !=
 		    (vlan->mode == MACVLAN_MODE_PASSTHRU))
 			return -EINVAL;
+		if (vlan->mode == MACVLAN_MODE_SOURCE &&
+		    vlan->mode != mode)
+			macvlan_flush_sources(vlan->port, vlan);
 	}
 
 	if (data && data[IFLA_MACVLAN_FLAGS]) {
@@ -943,26 +1162,77 @@ static int macvlan_changelink(struct net_device *dev,
 	}
 	if (set_mode)
 		vlan->mode = mode;
+	if (data && data[IFLA_MACVLAN_MACADDR_MODE]) {
+		if (vlan->mode != MACVLAN_MODE_SOURCE)
+			return -EINVAL;
+		macmode = nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE]);
+		ret = macvlan_changelink_sources(vlan, macmode, data);
+		if (ret)
+			return ret;
+	}
 	return 0;
 }
 
+static size_t macvlan_get_size_mac(const struct macvlan_dev *vlan)
+{
+	if (vlan->macaddr_count == 0)
+		return 0;
+	return nla_total_size(0) /* IFLA_MACVLAN_MACADDR_DATA */
+		+ vlan->macaddr_count * nla_total_size(sizeof(u8) * ETH_ALEN);
+}
+
 static size_t macvlan_get_size(const struct net_device *dev)
 {
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
 	return (0
 		+ nla_total_size(4) /* IFLA_MACVLAN_MODE */
 		+ nla_total_size(2) /* IFLA_MACVLAN_FLAGS */
+		+ nla_total_size(4) /* IFLA_MACVLAN_MACADDR_COUNT */
+		+ macvlan_get_size_mac(vlan) /* IFLA_MACVLAN_MACADDR */
 		);
 }
 
+static int macvlan_fill_info_macaddr(struct sk_buff *skb,
+					const struct macvlan_dev *vlan,
+					const int i)
+{
+	struct hlist_head *h = &vlan->port->vlan_source_hash[i];
+	struct macvlan_source_list *list;
+
+	hlist_for_each_entry_rcu(list, h, hlist) {
+		if (list->vlan == vlan)
+			if (nla_put(skb, IFLA_MACVLAN_MACADDR, ETH_ALEN,
+					list->addr))
+				return 1;
+	}
+	return 0;
+}
+
 static int macvlan_fill_info(struct sk_buff *skb,
 				const struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	int i;
+	struct nlattr *nest;
 
 	if (nla_put_u32(skb, IFLA_MACVLAN_MODE, vlan->mode))
 		goto nla_put_failure;
 	if (nla_put_u16(skb, IFLA_MACVLAN_FLAGS, vlan->flags))
 		goto nla_put_failure;
+	if (nla_put_u32(skb, IFLA_MACVLAN_MACADDR_COUNT, vlan->macaddr_count))
+		goto nla_put_failure;
+	if (vlan->macaddr_count > 0) {
+		nest = nla_nest_start(skb, IFLA_MACVLAN_MACADDR_DATA);
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
+			if (macvlan_fill_info_macaddr(skb, vlan, i))
+				goto nla_put_failure;
+		}
+		nla_nest_end(skb, nest);
+	}
 	return 0;
 
 nla_put_failure:
@@ -972,6 +1242,10 @@ nla_put_failure:
 static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
 	[IFLA_MACVLAN_MODE]  = { .type = NLA_U32 },
 	[IFLA_MACVLAN_FLAGS] = { .type = NLA_U16 },
+	[IFLA_MACVLAN_MACADDR_MODE] = { .type = NLA_U32 },
+	[IFLA_MACVLAN_MACADDR] = { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
+	[IFLA_MACVLAN_MACADDR_DATA] = { .type = NLA_NESTED },
+	[IFLA_MACVLAN_MACADDR_COUNT] = { .type = NLA_U32 },
 };
 
 int macvlan_link_register(struct rtnl_link_ops *ops)
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 7c8b20b..4f50624 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -56,6 +56,7 @@ struct macvlan_dev {
 	int			numqueues;
 	netdev_features_t	tap_features;
 	int			minor;
+	unsigned int		macaddr_count;
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 16410b6..11c1887 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -284,6 +284,10 @@ enum {
 	IFLA_MACVLAN_UNSPEC,
 	IFLA_MACVLAN_MODE,
 	IFLA_MACVLAN_FLAGS,
+	IFLA_MACVLAN_MACADDR_MODE,
+	IFLA_MACVLAN_MACADDR,
+	IFLA_MACVLAN_MACADDR_DATA,
+	IFLA_MACVLAN_MACADDR_COUNT,
 	__IFLA_MACVLAN_MAX,
 };
 
@@ -294,6 +298,14 @@ enum macvlan_mode {
 	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
 	MACVLAN_MODE_PASSTHRU = 8,/* take over the underlying device */
+	MACVLAN_MODE_SOURCE  = 16,/* use source MAC address list to assign */
+};
+
+enum macvlan_macaddr_mode {
+	MACVLAN_MACADDR_ADD,
+	MACVLAN_MACADDR_DEL,
+	MACVLAN_MACADDR_FLUSH,
+	MACVLAN_MACADDR_SET,
 };
 
 #define MACVLAN_FLAG_NOPROMISC	1
-- 
1.8.3.2
