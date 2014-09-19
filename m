From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/9] switchdev: add basic support for flow matching and actions
Date: Fri, 19 Sep 2014 15:49:47 +0200
Message-ID: <1411134590-4586-7-git-send-email-jiri@resnulli.us>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:53623 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756915AbaISNuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 09:50:02 -0400
Received: by mail-wi0-f182.google.com with SMTP id hi2so2034692wib.15
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 06:50:00 -0700 (PDT)
In-Reply-To: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic support for flows. The infrastructure is prepared
to easily add another flow matching types. So far, only the key one is
implemented.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  16 ++++++
 include/net/switchdev.h   | 113 ++++++++++++++++++++++++++++++++++++++++++
 net/switchdev/switchdev.c | 123 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 252 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b290dcf..034baca 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1005,6 +1005,18 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Called to get an ID of the switch chip this port is part of.
  *	If driver implements this, it indicates that it represents a port
  *	of a switch chip.
+ *
+ * int (*ndo_swdev_flow_insert)(struct net_device *dev,
+ *				const struct swdev_flow *flow);
+ *	Called to insert a flow into switch device. If driver does
+ *	not implement this, it is assumed that the hw does not have
+ *	a capability to work with flows.
+ *
+ * int (*ndo_swdev_flow_remove)(struct net_device *dev,
+ *				const struct swdev_flow *flow);
+ *	Called to remove a flow from switch device. If driver does
+ *	not implement this, it is assumed that the hw does not have
+ *	a capability to work with flows.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1157,6 +1169,10 @@ struct net_device_ops {
 #ifdef CONFIG_NET_SWITCHDEV
 	int			(*ndo_swdev_id_get)(struct net_device *dev,
 						    struct netdev_phys_item_id *psid);
+	int			(*ndo_swdev_flow_insert)(struct net_device *dev,
+							 const struct swdev_flow *flow);
+	int			(*ndo_swdev_flow_remove)(struct net_device *dev,
+							 const struct swdev_flow *flow);
 #endif
 };
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index af30f75..060d3fc 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -12,9 +12,110 @@
 
 #include <linux/netdevice.h>
 
+struct swdev_flow_match_key {
+	struct {
+		u32	priority;	/* Packet QoS priority. */
+		u32	in_port_ifindex; /* Input switch port ifindex (or 0). */
+	} phy;
+	struct {
+		u8     src[ETH_ALEN];	/* Ethernet source address. */
+		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
+		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+		__be16 type;		/* Ethernet frame type. */
+	} eth;
+	struct {
+		u8     proto;		/* IP protocol or lower 8 bits of ARP opcode. */
+		u8     tos;		/* IP ToS. */
+		u8     ttl;		/* IP TTL/hop limit. */
+		u8     frag;		/* One of OVS_FRAG_TYPE_*. */
+	} ip;
+	struct {
+		__be16 src;		/* TCP/UDP/SCTP source port. */
+		__be16 dst;		/* TCP/UDP/SCTP destination port. */
+		__be16 flags;		/* TCP flags. */
+	} tp;
+	union {
+		struct {
+			struct {
+				__be32 src;	/* IP source address. */
+				__be32 dst;	/* IP destination address. */
+			} addr;
+			struct {
+				u8 sha[ETH_ALEN];	/* ARP source hardware address. */
+				u8 tha[ETH_ALEN];	/* ARP target hardware address. */
+			} arp;
+		} ipv4;
+		struct {
+			struct {
+				struct in6_addr src;	/* IPv6 source address. */
+				struct in6_addr dst;	/* IPv6 destination address. */
+			} addr;
+			__be32 label;			/* IPv6 flow label. */
+			struct {
+				struct in6_addr target;	/* ND target address. */
+				u8 sll[ETH_ALEN];	/* ND source link layer address. */
+				u8 tll[ETH_ALEN];	/* ND target link layer address. */
+			} nd;
+		} ipv6;
+	};
+};
+
+enum swdev_flow_match_type {
+	SW_FLOW_MATCH_TYPE_KEY,
+};
+
+struct swdev_flow_match {
+	enum swdev_flow_match_type			type;
+	union {
+		struct {
+			struct swdev_flow_match_key	key;
+			struct swdev_flow_match_key	key_mask;
+		};
+	};
+};
+
+enum swdev_flow_action_type {
+	SW_FLOW_ACTION_TYPE_OUTPUT,
+	SW_FLOW_ACTION_TYPE_VLAN_PUSH,
+	SW_FLOW_ACTION_TYPE_VLAN_POP,
+};
+
+struct swdev_flow_action {
+	enum swdev_flow_action_type	type;
+	union {
+		u32			out_port_ifindex;
+		struct {
+			__be16		proto;
+			__be16		tci;
+		} vlan;
+	};
+};
+
+struct swdev_flow {
+	struct swdev_flow_match		match;
+	unsigned			action_count;
+	struct swdev_flow_action	action[0];
+};
+
+static inline struct swdev_flow *swdev_flow_alloc(unsigned action_count,
+						  gfp_t flags)
+{
+	struct swdev_flow *flow;
+
+	flow = kzalloc(sizeof(struct swdev_flow) +
+		       sizeof(struct swdev_flow_action) * action_count,
+		       flags);
+	if (!flow)
+		return NULL;
+	flow->action_count = action_count;
+	return flow;
+}
+
 #ifdef CONFIG_NET_SWITCHDEV
 
 int swdev_id_get(struct net_device *dev, struct netdev_phys_item_id *psid);
+int swdev_flow_insert(struct net_device *dev, const struct swdev_flow *flow);
+int swdev_flow_remove(struct net_device *dev, const struct swdev_flow *flow);
 
 #else
 
@@ -24,6 +125,18 @@ static inline int swdev_id_get(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int swdev_flow_insert(struct net_device *dev,
+				    const struct swdev_flow *flow)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int swdev_flow_remove(struct net_device *dev,
+				    const struct swdev_flow *flow)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 14a5fc9..90bc5e4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -30,3 +30,126 @@ int swdev_id_get(struct net_device *dev, struct netdev_phys_item_id *psid)
 	return ops->ndo_swdev_id_get(dev, psid);
 }
 EXPORT_SYMBOL(swdev_id_get);
+
+static void print_flow_key_phy(const char *prefix,
+			       const struct swdev_flow_match_key *key)
+{
+	pr_debug("%s phy  { prio %08x, in_port_ifindex %08x }\n",
+		 prefix,
+		 key->phy.priority, key->phy.in_port_ifindex);
+}
+
+static void print_flow_key_eth(const char *prefix,
+			       const struct swdev_flow_match_key *key)
+{
+	pr_debug("%s eth  { sm %pM, dm %pM, tci %04x, type %04x }\n",
+		 prefix,
+		 key->eth.src, key->eth.dst, ntohs(key->eth.tci),
+		 ntohs(key->eth.type));
+}
+
+static void print_flow_key_ip(const char *prefix,
+			      const struct swdev_flow_match_key *key)
+{
+	pr_debug("%s ip   { proto %02x, tos %02x, ttl %02x }\n",
+		 prefix,
+		 key->ip.proto, key->ip.tos, key->ip.ttl);
+}
+
+static void print_flow_key_ipv4(const char *prefix,
+				const struct swdev_flow_match_key *key)
+{
+	pr_debug("%s ipv4 { si %pI4, di %pI4, sm %pM, dm %pM }\n",
+		 prefix,
+		 &key->ipv4.addr.src, &key->ipv4.addr.dst,
+		 key->ipv4.arp.sha, key->ipv4.arp.tha);
+}
+
+static void print_flow_actions(const struct swdev_flow_action *action,
+			       unsigned action_count)
+{
+	int i;
+
+	pr_debug("  actions:\n");
+	for (i = 0; i < action_count; i++) {
+		switch (action->type) {
+		case SW_FLOW_ACTION_TYPE_OUTPUT:
+			pr_debug("    output    { ifindex %u }\n",
+				 action->out_port_ifindex);
+			break;
+		case SW_FLOW_ACTION_TYPE_VLAN_PUSH:
+			pr_debug("    vlan push { proto %04x, tci %04x }\n",
+				 ntohs(action->vlan.proto),
+				 ntohs(action->vlan.tci));
+			break;
+		case SW_FLOW_ACTION_TYPE_VLAN_POP:
+			pr_debug("    vlan pop\n");
+			break;
+		}
+		action++;
+	}
+}
+
+#define PREFIX_NONE "      "
+#define PREFIX_MASK "  mask"
+
+static void print_flow_match(const struct swdev_flow_match *match)
+{
+	switch (match->type) {
+	case SW_FLOW_MATCH_TYPE_KEY:
+		print_flow_key_phy(PREFIX_NONE, &match->key);
+		print_flow_key_phy(PREFIX_MASK, &match->key_mask);
+		print_flow_key_eth(PREFIX_NONE, &match->key);
+		print_flow_key_eth(PREFIX_MASK, &match->key_mask);
+		print_flow_key_ip(PREFIX_NONE, &match->key);
+		print_flow_key_ip(PREFIX_MASK, &match->key_mask);
+		print_flow_key_ipv4(PREFIX_NONE, &match->key);
+		print_flow_key_ipv4(PREFIX_MASK, &match->key_mask);
+	}
+}
+
+static void print_flow(const struct swdev_flow *flow, struct net_device *dev,
+		       const char *comment)
+{
+	pr_debug("%s flow %s:\n", dev->name, comment);
+	print_flow_match(&flow->match);
+	print_flow_actions(flow->action, flow->action_count);
+}
+
+/**
+ *	swdev_flow_insert - Insert a flow into switch
+ *	@dev: port device
+ *	@flow: flow descriptor
+ *
+ *	Insert a flow into switch this port is part of.
+ */
+int swdev_flow_insert(struct net_device *dev, const struct swdev_flow *flow)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	print_flow(flow, dev, "insert");
+	if (!ops->ndo_swdev_flow_insert)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_swdev_id_get);
+	return ops->ndo_swdev_flow_insert(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_insert);
+
+/**
+ *	swdev_flow_remove - Remove a flow from switch
+ *	@dev: port device
+ *	@flow: flow descriptor
+ *
+ *	Remove a flow from switch this port is part of.
+ */
+int swdev_flow_remove(struct net_device *dev, const struct swdev_flow *flow)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	print_flow(flow, dev, "remove");
+	if (!ops->ndo_swdev_flow_remove)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_swdev_id_get);
+	return ops->ndo_swdev_flow_remove(dev, flow);
+}
+EXPORT_SYMBOL(swdev_flow_remove);
-- 
1.9.3
