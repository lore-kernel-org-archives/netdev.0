From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v1, kernel version 3.2.1] Source mode for macvlan interaface
Date: Mon, 23 Jan 2012 13:30:38 +0100 (CET)
Message-ID: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@gmail.com>

New mode of macvlan interface called "source" allows one to specify, which  frames are allowed to be received by given macvlan interface. This logic is used only on received frames on underlaying interface. The ability to send frames from macvlan interface through underlaying interface is not modified. This feature allows one to simulate 802.1x mac based VLAN bahaviour by using proper netlink message to configure this behavior with utililty such as "ip link" from iproute2 suite.

Signed-off-by: Stefan Gula <steweg@gmail.com>

---

I have also iproute2 patch ready, just need to find out correct process for submitting it.

diff -uprN -X linux/Documentation/dontdiff linux-3.2.1-orig/drivers/net/macvlan.c linux/drivers/net/macvlan.c
--- linux-3.2.1-orig/drivers/net/macvlan.c	2012-01-12 20:42:45.000000000 +0100
+++ linux/drivers/net/macvlan.c	2012-01-23 11:38:12.207845065 +0100
@@ -40,6 +40,7 @@ struct macvlan_port {
 	struct rcu_head		rcu;
 	bool 			passthru;
 	int			count;
+	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
 };
 
 static void macvlan_port_destroy(struct net_device *dev);
@@ -155,6 +156,119 @@ static void macvlan_broadcast(struct sk_
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
+
+	hlist_for_each_entry_rcu(list, n,
+		&vlan->port->vlan_source_hash[addr[5]], hlist) {
+		if (!compare_ether_addr_64bits(list->addr, addr) &&
+			list->vlan == vlan)
+			return list;
+	}
+	return NULL;
+}
+
+static void macvlan_hash_add_sources(struct macvlan_dev *vlan,
+				const unsigned char *addr)
+{
+	struct macvlan_port *port = vlan->port;
+	struct macvlan_source_list *list;
+
+	list = macvlan_hash_lookup_sources_list(vlan, addr);
+	if (!list) {
+		list = kmalloc(sizeof(*list), GFP_ATOMIC);
+		if (list) {
+			memcpy(list->addr, addr, ETH_ALEN);
+			list->vlan = vlan;
+			hlist_add_head_rcu(&list->hlist,
+				&port->vlan_source_hash[addr[5]]);
+		}
+	}
+}
+
+static void macvlan_hash_del_sources(struct macvlan_source_list *list,
+					bool sync)
+{
+	hlist_del_rcu(&list->hlist);
+	kfree_rcu(list, rcu);
+	if (sync)
+		synchronize_rcu();
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
+			struct macvlan_source_list *list
+				= hlist_entry(h, struct macvlan_source_list,
+						hlist);
+			if (list->vlan == vlan)
+				macvlan_hash_del_sources(list, true);
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
+	nskb = skb_share_check(nskb, GFP_ATOMIC);
+	if (!nskb)
+		return;
+
+	nskb->dev = dev;
+	nskb->pkt_type = PACKET_HOST;
+	ret = vlan->receive(nskb);
+	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
+}
+
+static void macvlan_forward_sources(struct sk_buff *skb,
+	const struct macvlan_port *port,
+	const unsigned char *addr)
+{
+	struct macvlan_source_list *list;
+	struct hlist_node *n;
+
+	hlist_for_each_entry_rcu(list, n, &port->vlan_source_hash[addr[5]],
+				hlist) {
+		if (!compare_ether_addr_64bits(list->addr, addr))
+			if (list->vlan->dev->flags & IFF_UP)
+				macvlan_forward_sources_one(skb, list->vlan);
+	}
+	return;
+}
+
+
+
 /* called under rcu_read_lock() from netif_receive_skb */
 static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 {
@@ -172,6 +286,8 @@ static rx_handler_result_t macvlan_handl
 		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
+
+		macvlan_forward_sources(skb, port, eth->h_source);
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
@@ -202,6 +318,7 @@ static rx_handler_result_t macvlan_handl
 		return RX_HANDLER_PASS;
 	}
 
+	macvlan_forward_sources(skb, port, eth->h_source);
 	if (port->passthru)
 		vlan = list_first_entry(&port->vlans, struct macvlan_dev, list);
 	else
@@ -474,6 +591,7 @@ static void macvlan_uninit(struct net_de
 
 	free_percpu(vlan->pcpu_stats);
 
+	macvlan_flush_sources(port, vlan);
 	port->count -= 1;
 	if (!port->count)
 		macvlan_port_destroy(port->dev);
@@ -615,7 +733,8 @@ static int macvlan_port_create(struct ne
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
-
+	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&port->vlan_source_hash[i]);
 	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
 	if (err)
 		kfree(port);
@@ -648,11 +767,31 @@ static int macvlan_validate(struct nlatt
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
 
@@ -749,6 +888,8 @@ void macvlan_dellink(struct net_device *
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (vlan->mode == MACVLAN_MODE_SOURCE)
+		macvlan_flush_sources(vlan->port, vlan);
 	list_del(&vlan->list);
 	unregister_netdevice_queue(dev, head);
 }
@@ -758,8 +899,33 @@ static int macvlan_changelink(struct net
 		struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	if (data && data[IFLA_MACVLAN_MODE])
+
+	if (data && data[IFLA_MACVLAN_MODE]) {
+		if (vlan->mode == MACVLAN_MODE_SOURCE &&
+			vlan->mode != nla_get_u32(data[IFLA_MACVLAN_MODE]))
+			macvlan_flush_sources(vlan->port, vlan);
 		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+	}
+
+	if (data && data[IFLA_MACVLAN_MACADDR_MODE] &&
+		data[IFLA_MACVLAN_MACADDR]) {
+		if (vlan->mode == MACVLAN_MODE_SOURCE) {
+			if ((nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE]) ==
+				MACVLAN_MACADDR_ADD))
+				macvlan_hash_add_sources(vlan,
+					nla_data(data[IFLA_MACVLAN_MACADDR]));
+			else if (nla_get_u32(data[IFLA_MACVLAN_MACADDR_MODE]) ==
+				MACVLAN_MACADDR_DEL) {
+				struct macvlan_source_list *list;
+
+				list = macvlan_hash_lookup_sources_list(vlan,
+					nla_data(data[IFLA_MACVLAN_MACADDR]));
+				if (list)
+					macvlan_hash_del_sources(list, true);
+			}
+		}
+	}
+
 	return 0;
 }
 
@@ -768,20 +934,71 @@ static size_t macvlan_get_size(const str
 	return nla_total_size(4);
 }
 
+
+static int macvlan_fill_nested(struct sk_buff *skb, const char *addr)
+{
+	struct nlattr *nested;
+
+	nested = nla_nest_start(skb, IFLA_MACVLAN_MACADDR_DATA);
+	if (!nested)
+		return -EMSGSIZE;
+	NLA_PUT(skb, IFLA_MACVLAN_MACADDR, ETH_ALEN, addr);
+	nla_nest_end(skb, nested);
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nested);
+
+	return 0;
+}
+
 static int macvlan_fill_info(struct sk_buff *skb,
 				const struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct nlattr *adt;
 
 	NLA_PUT_U32(skb, IFLA_MACVLAN_MODE, vlan->mode);
+
+	if (vlan->mode == MACVLAN_MODE_SOURCE) {
+		int i;
+
+		adt = nla_nest_start(skb, IFLA_MACVLAN_MACADDR_ADT);
+		if (!adt)
+			goto nla_put_failure;
+
+		for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
+			struct hlist_node *n;
+			struct macvlan_source_list *list;
+
+			hlist_for_each_entry_rcu(list, n,
+				&vlan->port->vlan_source_hash[i], hlist) {
+				if (list->vlan == vlan)
+					if (macvlan_fill_nested(skb,
+						list->addr))
+						goto nla_nested_failure;
+			}
+		}
+		nla_nest_end(skb, adt);
+	}
+
 	return 0;
 
+nla_nested_failure:
+	nla_nest_end(skb, adt);
+	return -EMSGSIZE;
+
 nla_put_failure:
 	return -EMSGSIZE;
 }
 
 static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
 	[IFLA_MACVLAN_MODE] = { .type = NLA_U32 },
+	[IFLA_MACVLAN_MACADDR_MODE] = { .type = NLA_U32 },
+	[IFLA_MACVLAN_MACADDR] = { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
+	[IFLA_MACVLAN_MACADDR_DATA] = { .type = NLA_NESTED },
+	[IFLA_MACVLAN_MACADDR_ADT] = { .type = NLA_NESTED },
 };
 
 int macvlan_link_register(struct rtnl_link_ops *ops)
diff -uprN -X linux/Documentation/dontdiff linux-3.2.1-orig/include/linux/if_link.h linux/include/linux/if_link.h
--- linux-3.2.1-orig/include/linux/if_link.h	2012-01-12 20:42:45.000000000 +0100
+++ linux/include/linux/if_link.h	2012-01-22 22:07:58.501011424 +0100
@@ -252,6 +252,10 @@ struct ifla_vlan_qos_mapping {
 enum {
 	IFLA_MACVLAN_UNSPEC,
 	IFLA_MACVLAN_MODE,
+	IFLA_MACVLAN_MACADDR_MODE,
+	IFLA_MACVLAN_MACADDR,
+	IFLA_MACVLAN_MACADDR_DATA,
+	IFLA_MACVLAN_MACADDR_ADT,
 	__IFLA_MACVLAN_MAX,
 };
 
@@ -262,6 +266,12 @@ enum macvlan_mode {
 	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
 	MACVLAN_MODE_PASSTHRU = 8,/* take over the underlying device */
+	MACVLAN_MODE_SOURCE  = 16,/* use source MAC address list to assign */
+};
+
+enum macvlan_macaddr_mode {
+	MACVLAN_MACADDR_ADD,
+	MACVLAN_MACADDR_DEL,
 };
 
 /* SR-IOV virtual function management section */
diff -uprN -X linux/Documentation/dontdiff linux-3.2.1-orig/include/linux/if_macvlan.h linux/include/linux/if_macvlan.h
--- linux-3.2.1-orig/include/linux/if_macvlan.h	2012-01-12 20:42:45.000000000 +0100
+++ linux/include/linux/if_macvlan.h	2012-01-20 16:09:04.899241461 +0100
@@ -104,5 +104,11 @@ extern int macvlan_link_register(struct
 
 extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
-
+/*
+static struct macvlan_dev *macvlan_hash_lookup_sources(
+	const struct macvlan_port *port,
+	const unsigned char *addr);
+static int macvlan_add_sources(struct macvlan_port *port,
+				struct macvlan_dev *vlan);
+*/
 #endif /* _LINUX_IF_MACVLAN_H */
