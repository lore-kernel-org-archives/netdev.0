From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v7, kernel version 3.2.1] Source mode for macvlan interface
Date: Mon, 30 Jan 2012 12:51:37 +0100 (CET)
Message-ID: <13688762.701327924297781.JavaMail.root@5-MeO-DMT.ynet.sk>
References: <21672990.651327923923151.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21672990.651327923923151.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@gmail.com>

New mode of macvlan interface called "source" allows one to set a list
of allowed mac address, which is used to match against source mac
address from received frames on underlying interface. This allows
creating mac based VLAN associations, instead of standard port or tag
based. The feature is useful to deploy 802.1x mac based behavior,
where drivers of underlying interfaces doesn't allows that.
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

Signed-off-by: Stefan Gula <steweg@gmail.com>

---

V6 changes:
 - removed ability to fill the list of macaddr per link to fix the
   issue of netlink skb size. This can be added back by using separate
   netlink dumper in kernel and parse inside iproute2 codes. Those codes
   are beyond my abilities so if anyone actually need that feel free to 
   help.
 - added ability to flush all mac address associated with given macvlan
   interface, by using "flush" command.

diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/drivers/net/macvlan.c linux/drivers/net/macvlan.c
--- linux-3.2.1-orig/drivers/net/macvlan.c	2012-01-27 13:38:51.000000000 +0000
+++ linux/drivers/net/macvlan.c	2012-01-30 09:54:51.000000000 +0000
@@ -40,6 +40,7 @@ struct macvlan_port {
 	struct rcu_head		rcu;
 	bool 			passthru;
 	int			count;
+	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
 };
 
 static void macvlan_port_destroy(struct net_device *dev);
@@ -155,6 +156,115 @@ static void macvlan_broadcast(struct sk_
 	}
 }
 
+struct macvlan_source_list {
+	struct hlist_node	hlist;
+	struct macvlan_dev	*vlan;
+	unsigned char		addr[ETH_ALEN];
+	struct rcu_head		rcu;
+};
+
+static struct macvlan_source_list *macvlan_hash_lookup_sources_list(
+	const struct macvlan_dev *vlan,
+	const unsigned char *addr)
+{
+	struct macvlan_source_list *list;
+	struct hlist_node *n;
+	struct hlist_head *h = &vlan->port->vlan_source_hash[addr[5]];
+
+	hlist_for_each_entry(list, n, h, hlist) {
+		if (!compare_ether_addr_64bits(list->addr, addr) &&
+		    list->vlan == vlan)
+			return list;
+	}
+	return NULL;
+}
+
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
+			memcpy(list->addr, addr, ETH_ALEN);
+			list->vlan = vlan;
+			h = &port->vlan_source_hash[addr[5]];
+			hlist_add_head_rcu(&list->hlist, h);
+		} else {
+			return -ENOMEM;
+		}
+	}
+	return 0;
+}
+
+static void macvlan_hash_del_sources(struct macvlan_source_list *list)
+{
+	hlist_del_rcu(&list->hlist);
+	kfree_rcu(list, rcu);
+}
+
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
+	ret = vlan->receive(nskb);
+	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
+}
+
+static void macvlan_forward_sources(struct sk_buff *skb,
+				    struct macvlan_port *port,
+				    const unsigned char *addr)
+{
+	struct macvlan_source_list *list;
+	struct hlist_node *n;
+	struct hlist_head *h = &port->vlan_source_hash[addr[5]];
+
+	hlist_for_each_entry_rcu(list, n, h, hlist) {
+		if (!compare_ether_addr_64bits(list->addr, addr))
+			if (list->vlan->dev->flags & IFF_UP)
+				macvlan_forward_sources_one(skb, list->vlan);
+	}
+	return;
+}
+
 /* called under rcu_read_lock() from netif_receive_skb */
 static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 {
@@ -172,6 +282,8 @@ static rx_handler_result_t macvlan_handl
 		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
+
+		macvlan_forward_sources(skb, port, eth->h_source);
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
@@ -202,6 +314,7 @@ static rx_handler_result_t macvlan_handl
 		return RX_HANDLER_PASS;
 	}
 
+	macvlan_forward_sources(skb, port, eth->h_source);
 	if (port->passthru)
 		vlan = list_first_entry(&port->vlans, struct macvlan_dev, list);
 	else
@@ -474,6 +587,7 @@ static void macvlan_uninit(struct net_de
 
 	free_percpu(vlan->pcpu_stats);
 
+	macvlan_flush_sources(port, vlan);
 	port->count -= 1;
 	if (!port->count)
 		macvlan_port_destroy(port->dev);
@@ -615,7 +729,8 @@ static int macvlan_port_create(struct ne
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
-
+	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&port->vlan_source_hash[i]);
 	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
 	if (err)
 		kfree(port);
@@ -648,11 +763,32 @@ static int macvlan_validate(struct nlatt
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
 	return 0;
 }
 
@@ -749,17 +885,69 @@ void macvlan_dellink(struct net_device *
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (vlan->mode == MACVLAN_MODE_SOURCE)
+		macvlan_flush_sources(vlan->port, vlan);
 	list_del(&vlan->list);
 	unregister_netdevice_queue(dev, head);
 }
 EXPORT_SYMBOL_GPL(macvlan_dellink);
 
+static int macvlan_changelink_sources(struct macvlan_dev *vlan, u32 mode,
+				      unsigned char *addr)
+{
+	if (mode == MACVLAN_MACADDR_ADD) {
+		if (!addr)
+			return -EINVAL;
+		return macvlan_hash_add_sources(vlan, addr);
+
+	} else if (mode == MACVLAN_MACADDR_DEL) {
+		struct macvlan_source_list *list;
+
+		if (!addr)
+			return -EINVAL;
+		list = macvlan_hash_lookup_sources_list(vlan, addr);
+		if (list)
+			macvlan_hash_del_sources(list);
+	} else if (mode == MACVLAN_MACADDR_FLUSH) {
+		macvlan_flush_sources(vlan->port, vlan);
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int macvlan_changelink(struct net_device *dev,
 		struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	if (data && data[IFLA_MACVLAN_MODE])
+	u32 mode;
+	unsigned char *addr;
+
+	if (data && data[IFLA_MACVLAN_MODE]) {
+		if (vlan->mode == MACVLAN_MODE_SOURCE &&
+		    vlan->mode != nla_get_u32(data[IFLA_MACVLAN_MODE]))
+			macvlan_flush_sources(vlan->port, vlan);
 		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+	}
+
+	if (data && data[IFLA_MACVLAN_MACADDR_MODE] &&
+	    data[IFLA_MACVLAN_MACADDR]) {
+		mode = nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE]);
+		addr = nla_data(nla_data(data[IFLA_MACVLAN_MACADDR]));
+		if (vlan->mode == MACVLAN_MODE_SOURCE)
+			return macvlan_changelink_sources(vlan, mode, addr);
+		else
+			return -EINVAL;
+
+	} else if (data && data[IFLA_MACVLAN_MACADDR_MODE]) {
+		mode = nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE]);
+		if (vlan->mode == MACVLAN_MODE_SOURCE)
+			return macvlan_changelink_sources(vlan, mode, NULL);
+		else
+			return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -782,6 +970,9 @@ nla_put_failure:
 
 static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
 	[IFLA_MACVLAN_MODE] = { .type = NLA_U32 },
+	[IFLA_MACVLAN_MACADDR_MODE] = { .type = NLA_U32 },
+	[IFLA_MACVLAN_MACADDR] = { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
+	[IFLA_MACVLAN_MACADDR_DATA] = { .type = NLA_NESTED },
 };
 
 int macvlan_link_register(struct rtnl_link_ops *ops)
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/include/linux/if_link.h linux/include/linux/if_link.h
--- linux-3.2.1-orig/include/linux/if_link.h	2012-01-27 13:38:57.000000000 +0000
+++ linux/include/linux/if_link.h	2012-01-30 09:23:27.000000000 +0000
@@ -252,6 +252,9 @@ struct ifla_vlan_qos_mapping {
 enum {
 	IFLA_MACVLAN_UNSPEC,
 	IFLA_MACVLAN_MODE,
+	IFLA_MACVLAN_MACADDR_MODE,
+	IFLA_MACVLAN_MACADDR,
+	IFLA_MACVLAN_MACADDR_DATA,
 	__IFLA_MACVLAN_MAX,
 };
 
@@ -262,6 +265,13 @@ enum macvlan_mode {
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
 };
 
 /* SR-IOV virtual function management section */
