From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCHv10] macvlan: add source mode
Date: Mon, 31 Mar 2014 18:48:05 +0200
Message-ID: <1396284485-17914-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
	<netdev@vger.kernel.org>, <projekt-wlan@fem.tu-ilmenau.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:59282 "EHLO
	mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbaCaQ47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:56:59 -0400
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
 ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
 ip link set link dev macvlan0 type macvlan macaddr add 00:22:22:22:22:22
 ip link set link dev macvlan0 type macvlan macaddr add 00:33:33:33:33:33
 ip link set link dev macvlan1 type macvlan macaddr add 00:33:33:33:33:33
 ip link set link dev macvlan1 type macvlan macaddr add 00:44:44:44:44:44

This allows clients with MAC addresses 00:11:11:11:11:11,
00:22:22:22:22:22 to be part of only VLAN associated with macvlan0
interface. Clients with MAC addresses 00:44:44:44:44:44 with only VLAN
associated with macvlan1 interface. And client with MAC address
00:33:33:33:33:33 to be associated with both VLANs.

Based on work of Stefan Gula <steweg@gmail.com>

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
Cc: <netdev@vger.kernel.org>
Cc: <projekt-wlan@fem.tu-ilmenau.de>

v8: last version of Stefan Gula for Kernel 3.2.1
v9: rework onto linux-next 2014-03-12 by Michael Braun
    add MACADDR_SET command, enable to configure mac for source mode
    while creating interface
v10:
  - reduce indention level
  - rename source_list to source_entry
  - use aligned 64bit ether address
  - use hash_64 instead of addr[5]
---
 drivers/net/macvlan.c        | 304 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_macvlan.h   |   1 +
 include/uapi/linux/if_link.h |  12 ++
 3 files changed, 314 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c683ac2..95e5067 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -33,7 +33,8 @@
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
 
-#define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
+#define MACVLAN_HASH_BITS	8
+#define MACVLAN_HASH_SIZE	(1<<MACVLAN_HASH_BITS)
 
 struct macvlan_port {
 	struct net_device	*dev;
@@ -42,10 +43,32 @@ struct macvlan_port {
 	struct rcu_head		rcu;
 	bool 			passthru;
 	int			count;
+	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
+};
+
+struct macvlan_source_entry {
+	struct hlist_node	hlist;
+	struct macvlan_dev	*vlan;
+	unsigned char		addr[6+2] __aligned(sizeof(u16));
+	struct rcu_head		rcu;
 };
 
 static void macvlan_port_destroy(struct net_device *dev);
 
+/* Hash Ethernet address */
+static u32 macvlan_eth_hash(const unsigned char *addr)
+{
+	u64 value = get_unaligned((u64 *)addr);
+
+        /* only want 6 bytes */
+#ifdef __BIG_ENDIAN
+        value >>= 16;
+#else   
+        value <<= 16;
+#endif  
+        return hash_64(value, MACVLAN_HASH_BITS);
+}
+
 static struct macvlan_port *macvlan_port_get_rcu(const struct net_device *dev)
 {
 	return rcu_dereference(dev->rx_handler_data);
@@ -62,20 +85,62 @@ static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 					       const unsigned char *addr)
 {
 	struct macvlan_dev *vlan;
+	u32 idx = macvlan_eth_hash(addr);
 
-	hlist_for_each_entry_rcu(vlan, &port->vlan_hash[addr[5]], hlist) {
+	hlist_for_each_entry_rcu(vlan, &port->vlan_hash[idx], hlist) {
 		if (ether_addr_equal_64bits(vlan->dev->dev_addr, addr))
 			return vlan;
 	}
 	return NULL;
 }
 
+static struct macvlan_source_entry *macvlan_hash_lookup_source(
+	const struct macvlan_dev *vlan,
+	const unsigned char *addr)
+{
+	struct macvlan_source_entry *entry;
+	u32 idx = macvlan_eth_hash(addr);
+	struct hlist_head *h = &vlan->port->vlan_source_hash[idx];
+
+	hlist_for_each_entry_rcu(entry, h, hlist) {
+		if (ether_addr_equal_64bits(entry->addr, addr) &&
+		    entry->vlan == vlan)
+			return entry;
+	}
+	return NULL;
+}
+
 static void macvlan_hash_add(struct macvlan_dev *vlan)
 {
 	struct macvlan_port *port = vlan->port;
 	const unsigned char *addr = vlan->dev->dev_addr;
+	u32 idx = macvlan_eth_hash(addr);
 
-	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[addr[5]]);
+	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[idx]);
+}
+
+static int macvlan_hash_add_source(struct macvlan_dev *vlan,
+				    const unsigned char *addr)
+{
+	struct macvlan_port *port = vlan->port;
+	struct macvlan_source_entry *entry;
+	struct hlist_head *h;
+
+	entry = macvlan_hash_lookup_source(vlan, addr);
+	if (entry)
+		return 0;
+
+	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	ether_addr_copy(entry->addr, addr);
+	entry->vlan = vlan;
+	h = &port->vlan_source_hash[macvlan_eth_hash(addr)];
+	hlist_add_head_rcu(&entry->hlist, h);
+	vlan->macaddr_count++;
+
+	return 0;
 }
 
 static void macvlan_hash_del(struct macvlan_dev *vlan, bool sync)
@@ -85,6 +150,12 @@ static void macvlan_hash_del(struct macvlan_dev *vlan, bool sync)
 		synchronize_rcu();
 }
 
+static void macvlan_hash_del_source(struct macvlan_source_entry *entry)
+{
+	hlist_del_rcu(&entry->hlist);
+	kfree_rcu(entry, rcu);
+}
+
 static void macvlan_hash_change_addr(struct macvlan_dev *vlan,
 					const unsigned char *addr)
 {
@@ -182,6 +253,66 @@ static void macvlan_broadcast(struct sk_buff *skb,
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
+			struct macvlan_source_entry *entry;
+
+			entry = hlist_entry(h, struct macvlan_source_entry,
+					   hlist);
+			if (entry->vlan == vlan)
+				macvlan_hash_del_source(entry);
+		}
+	}
+	vlan->macaddr_count = 0;
+}
+
+static void macvlan_forward_source_one(struct sk_buff *skb,
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
+static void macvlan_forward_source(struct sk_buff *skb,
+				    struct macvlan_port *port,
+				    const unsigned char *addr)
+{
+	struct macvlan_source_entry *entry;
+	u32 idx = macvlan_eth_hash(addr);
+	struct hlist_head *h = &port->vlan_source_hash[idx];
+
+	hlist_for_each_entry_rcu(entry, h, hlist) {
+		if (ether_addr_equal_64bits(entry->addr, addr))
+			if (entry->vlan->dev->flags & IFF_UP)
+				macvlan_forward_source_one(skb, entry->vlan);
+	}
+	return;
+}
+
 /* called under rcu_read_lock() from netif_receive_skb */
 static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 {
@@ -200,6 +331,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
 		eth = eth_hdr(skb);
+		macvlan_forward_source(skb, port, eth->h_source);
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
@@ -230,6 +362,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_PASS;
 	}
 
+	macvlan_forward_source(skb, port, eth->h_source);
 	if (port->passthru)
 		vlan = list_first_or_null_rcu(&port->vlans,
 					      struct macvlan_dev, list);
@@ -562,6 +695,7 @@ static void macvlan_uninit(struct net_device *dev)
 
 	free_percpu(vlan->pcpu_stats);
 
+	macvlan_flush_sources(port, vlan);
 	port->count -= 1;
 	if (!port->count)
 		macvlan_port_destroy(port->dev);
@@ -763,6 +897,8 @@ static int macvlan_port_create(struct net_device *dev)
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
+	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&port->vlan_source_hash[i]);
 
 	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
 	if (err)
@@ -800,11 +936,101 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		case MACVLAN_MODE_VEPA:
 		case MACVLAN_MODE_BRIDGE:
 		case MACVLAN_MODE_PASSTHRU:
+		case MACVLAN_MODE_SOURCE:
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	if (data && data[IFLA_MACVLAN_MACADDR_MODE]) {
+		switch (nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE])) {
+		case MACVLAN_MACADDR_ADD:
+		case MACVLAN_MACADDR_DEL:
+		case MACVLAN_MACADDR_FLUSH:
+		case MACVLAN_MACADDR_SET:
 			break;
 		default:
 			return -EINVAL;
 		}
 	}
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
+/**
+ * reconfigure list of remote source mac address for macvlan devices in source mode
+ * Note regarding alignment: all netlink data is aligned to 4 Byte, which suffices
+ * for both ether_addr_copy and ether_addr_equal_64bits usage.
+ */
+static int macvlan_changelink_sources(struct macvlan_dev *vlan, u32 mode,
+				      struct nlattr *data[])
+{
+	char *addr = NULL;
+	int ret, rem, len;
+	struct nlattr *nla, *head;
+	struct macvlan_source_entry *entry;
+
+	if (data[IFLA_MACVLAN_MACADDR])
+		addr = nla_data(data[IFLA_MACVLAN_MACADDR]);
+
+	if (mode == MACVLAN_MACADDR_ADD) {
+		if (!addr)
+			return -EINVAL;
+
+		return macvlan_hash_add_source(vlan, addr);
+
+	} else if (mode == MACVLAN_MACADDR_DEL) {
+		if (!addr)
+			return -EINVAL;
+
+		entry = macvlan_hash_lookup_source(vlan, addr);
+		if (entry) {
+			macvlan_hash_del_source(entry);
+			vlan->macaddr_count--;
+		}
+	} else if (mode == MACVLAN_MACADDR_FLUSH) {
+		macvlan_flush_sources(vlan->port, vlan);
+	} else if (mode == MACVLAN_MACADDR_SET) {
+		macvlan_flush_sources(vlan->port, vlan);
+
+		if (addr) {
+			ret = macvlan_hash_add_source(vlan, addr);
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
+			ret = macvlan_hash_add_source(vlan, addr);
+			if (ret)
+				return ret;
+		}
+	} else {
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -815,6 +1041,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	struct macvlan_port *port;
 	struct net_device *lowerdev;
 	int err;
+	int macmode;
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
@@ -867,6 +1094,15 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
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
@@ -903,6 +1139,8 @@ void macvlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (vlan->mode == MACVLAN_MODE_SOURCE)
+		macvlan_flush_sources(vlan->port, vlan);
 	list_del_rcu(&vlan->list);
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(vlan->lowerdev, dev);
@@ -915,6 +1153,8 @@ static int macvlan_changelink(struct net_device *dev,
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	enum macvlan_mode mode;
 	bool set_mode = false;
+	enum macvlan_macaddr_mode macmode;
+	int ret;
 
 	/* Validate mode, but don't set yet: setting flags may fail. */
 	if (data && data[IFLA_MACVLAN_MODE]) {
@@ -924,6 +1164,9 @@ static int macvlan_changelink(struct net_device *dev,
 		if ((mode == MACVLAN_MODE_PASSTHRU) !=
 		    (vlan->mode == MACVLAN_MODE_PASSTHRU))
 			return -EINVAL;
+		if (vlan->mode == MACVLAN_MODE_SOURCE &&
+		    vlan->mode != mode)
+			macvlan_flush_sources(vlan->port, vlan);
 	}
 
 	if (data && data[IFLA_MACVLAN_FLAGS]) {
@@ -943,26 +1186,77 @@ static int macvlan_changelink(struct net_device *dev,
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
+	struct macvlan_source_entry *entry;
+
+	hlist_for_each_entry_rcu(entry, h, hlist) {
+		if (entry->vlan != vlan)
+			continue;
+		if (nla_put(skb, IFLA_MACVLAN_MACADDR, ETH_ALEN, entry->addr))
+			return 1;
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
@@ -972,6 +1266,10 @@ nla_put_failure:
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
