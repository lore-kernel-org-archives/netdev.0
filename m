From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 09/12] openvswitch: Add tunneling interface.
Date: Thu, 13 Jun 2013 11:24:59 -0700
Message-ID: <1371147899-9442-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:42136 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759002Ab3FMSZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:25:03 -0400
Received: by mail-pb0-f44.google.com with SMTP id uo1so5916401pbc.3
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:25:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ovs tunnel interface for set tunnel action for userspace.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h     |   18 +++++
 net/openvswitch/actions.c            |    4 +
 net/openvswitch/datapath.c           |   78 ++++++++++++++++++++-
 net/openvswitch/datapath.h           |    3 +
 net/openvswitch/flow.c               |  129 +++++++++++++++++++++++++++++++++-
 net/openvswitch/flow.h               |   19 +++++
 net/openvswitch/vport-internal_dev.c |    2 +-
 net/openvswitch/vport-netdev.c       |    2 +-
 net/openvswitch/vport.c              |    4 +-
 net/openvswitch/vport.h              |    3 +-
 10 files changed, 253 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 424672d..b15a445 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -246,11 +246,29 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_ARP,       /* struct ovs_key_arp */
 	OVS_KEY_ATTR_ND,        /* struct ovs_key_nd */
 	OVS_KEY_ATTR_SKB_MARK,  /* u32 skb mark */
+	OVS_KEY_ATTR_TUNNEL,    /* Nested set of ovs_tunnel attributes */
+
+#ifdef __KERNEL__
+	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
+#endif
 	__OVS_KEY_ATTR_MAX
 };
 
 #define OVS_KEY_ATTR_MAX (__OVS_KEY_ATTR_MAX - 1)
 
+enum ovs_tunnel_key_attr {
+	OVS_TUNNEL_KEY_ATTR_ID,                 /* be64 Tunnel ID */
+	OVS_TUNNEL_KEY_ATTR_IPV4_SRC,           /* be32 src IP address. */
+	OVS_TUNNEL_KEY_ATTR_IPV4_DST,           /* be32 dst IP address. */
+	OVS_TUNNEL_KEY_ATTR_TOS,                /* u8 Tunnel IP ToS. */
+	OVS_TUNNEL_KEY_ATTR_TTL,                /* u8 Tunnel IP TTL. */
+	OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT,      /* No argument, set DF. */
+	OVS_TUNNEL_KEY_ATTR_CSUM,               /* No argument. CSUM packet. */
+	__OVS_TUNNEL_KEY_ATTR_MAX
+};
+
+#define OVS_TUNNEL_KEY_ATTR_MAX (__OVS_TUNNEL_KEY_ATTR_MAX - 1)
+
 /**
  * enum ovs_frag_type - IPv4 and IPv6 fragment type
  * @OVS_FRAG_TYPE_NONE: Packet is not a fragment.
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 596d637..22c5f39 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -436,6 +436,10 @@ static int execute_set_action(struct sk_buff *skb,
 		skb->mark = nla_get_u32(nested_attr);
 		break;
 
+	case OVS_KEY_ATTR_IPV4_TUNNEL:
+		OVS_CB(skb)->tun_key = nla_data(nested_attr);
+		break;
+
 	case OVS_KEY_ATTR_ETHERNET:
 		err = set_eth_addr(skb, nla_data(nested_attr));
 		break;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ae1e8fe..6318d00 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -362,6 +362,14 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
 static size_t key_attr_size(void)
 {
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
+		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
+		  + nla_total_size(8)   /* OVS_TUNNEL_KEY_ATTR_ID */
+		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_SRC */
+		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_DST */
+		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TOS */
+		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TTL */
+		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
+		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
@@ -600,8 +608,30 @@ static int validate_tp_port(const struct sw_flow_key *flow_key)
 	return -EINVAL;
 }
 
+static int validate_and_copy_set_tun(const struct nlattr *attr,
+				     struct sw_flow_actions **sfa)
+{
+	struct ovs_key_ipv4_tunnel tun_key;
+	int err, start;
+
+	err = ipv4_tun_from_nlattr(nla_data(attr), &tun_key);
+	if (err)
+		return err;
+
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET);
+	if (start < 0)
+		return start;
+
+	err = add_action(sfa, OVS_KEY_ATTR_IPV4_TUNNEL, &tun_key, sizeof(tun_key));
+	add_nested_action_end(*sfa, start);
+
+	return err;
+}
+
 static int validate_set(const struct nlattr *a,
-			const struct sw_flow_key *flow_key)
+			const struct sw_flow_key *flow_key,
+			struct sw_flow_actions **sfa,
+			bool *set_tun)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
@@ -611,18 +641,27 @@ static int validate_set(const struct nlattr *a,
 		return -EINVAL;
 
 	if (key_type > OVS_KEY_ATTR_MAX ||
-	    nla_len(ovs_key) != ovs_key_lens[key_type])
+	   (ovs_key_lens[key_type] != nla_len(ovs_key) &&
+	    ovs_key_lens[key_type] != -1))
 		return -EINVAL;
 
 	switch (key_type) {
 	const struct ovs_key_ipv4 *ipv4_key;
 	const struct ovs_key_ipv6 *ipv6_key;
+	int err;
 
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
+	case OVS_KEY_ATTR_TUNNEL:
+		*set_tun = true;
+		err = validate_and_copy_set_tun(a, sfa);
+		if (err)
+			return err;
+		break;
+
 	case OVS_KEY_ATTR_IPV4:
 		if (flow_key->eth.type != htons(ETH_P_IP))
 			return -EINVAL;
@@ -771,7 +810,7 @@ static int validate_and_copy_actions(const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_SET:
-			err = validate_set(a, key);
+			err = validate_set(a, key, sfa, &skip_copy);
 			if (err)
 				return err;
 			break;
@@ -993,6 +1032,33 @@ static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
 	return err;
 }
 
+static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
+{
+	const struct nlattr *ovs_key = nla_data(a);
+	int key_type = nla_type(ovs_key);
+	struct nlattr *start;
+	int err;
+
+	switch (key_type) {
+	case OVS_KEY_ATTR_IPV4_TUNNEL:
+		start = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
+		if (!start)
+			return -EMSGSIZE;
+
+		err = ipv4_tun_to_nlattr(skb, nla_data(ovs_key));
+		if (err)
+			return err;
+		nla_nest_end(skb, start);
+		break;
+	default:
+		if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a), ovs_key))
+			return -EMSGSIZE;
+		break;
+	}
+
+	return 0;
+}
+
 static int actions_to_attr(const struct nlattr *attr, int len, struct sk_buff *skb)
 {
 	const struct nlattr *a;
@@ -1002,6 +1068,12 @@ static int actions_to_attr(const struct nlattr *attr, int len, struct sk_buff *s
 		int type = nla_type(a);
 
 		switch (type) {
+		case OVS_ACTION_ATTR_SET:
+			err = set_action_to_attr(a, skb);
+			if (err)
+				return err;
+			break;
+
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample_action_to_attr(a, skb);
 			if (err)
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 16b8406..e88ebc2 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -88,9 +88,12 @@ struct datapath {
 /**
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
+ * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
+ * packet is not being tunneled.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
+	struct ovs_key_ipv4_tunnel  *tun_key;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fba57a0..575c0bd 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -40,6 +40,7 @@
 #include <linux/icmpv6.h>
 #include <linux/rculist.h>
 #include <net/ip.h>
+#include <net/ip_tunnels.h>
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 
@@ -603,6 +604,8 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 	memset(key, 0, sizeof(*key));
 
 	key->phy.priority = skb->priority;
+	if (OVS_CB(skb)->tun_key)
+		memcpy(&key->tun_key, OVS_CB(skb)->tun_key, sizeof(key->tun_key));
 	key->phy.in_port = in_port;
 	key->phy.skb_mark = skb->mark;
 
@@ -818,6 +821,7 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ICMPV6] = sizeof(struct ovs_key_icmpv6),
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
+	[OVS_KEY_ATTR_TUNNEL] = -1,
 };
 
 static int ipv4_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
@@ -938,14 +942,14 @@ static int parse_flow_nlattrs(const struct nlattr *attr,
 		u16 type = nla_type(nla);
 		int expected_len;
 
-		if (type > OVS_KEY_ATTR_MAX || attrs & (1 << type))
+		if (type > OVS_KEY_ATTR_MAX || attrs & (1ULL << type))
 			return -EINVAL;
 
 		expected_len = ovs_key_lens[type];
 		if (nla_len(nla) != expected_len && expected_len != -1)
 			return -EINVAL;
 
-		attrs |= 1 << type;
+		attrs |= 1ULL << type;
 		a[type] = nla;
 	}
 	if (rem)
@@ -955,6 +959,105 @@ static int parse_flow_nlattrs(const struct nlattr *attr,
 	return 0;
 }
 
+int ipv4_tun_from_nlattr(const struct nlattr *attr,
+			 struct ovs_key_ipv4_tunnel *tun_key)
+{
+	struct nlattr *a;
+	int rem;
+	bool ttl = false;
+
+	memset(tun_key, 0, sizeof(*tun_key));
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		static const u32 ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
+			[OVS_TUNNEL_KEY_ATTR_ID] = sizeof(u64),
+			[OVS_TUNNEL_KEY_ATTR_IPV4_SRC] = sizeof(u32),
+			[OVS_TUNNEL_KEY_ATTR_IPV4_DST] = sizeof(u32),
+			[OVS_TUNNEL_KEY_ATTR_TOS] = 1,
+			[OVS_TUNNEL_KEY_ATTR_TTL] = 1,
+			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
+			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
+		};
+
+		if (type > OVS_TUNNEL_KEY_ATTR_MAX ||
+			ovs_tunnel_key_lens[type] != nla_len(a))
+			return -EINVAL;
+
+		switch (type) {
+		case OVS_TUNNEL_KEY_ATTR_ID:
+			tun_key->tun_id = nla_get_be64(a);
+			tun_key->tun_flags |= TUNNEL_KEY;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_IPV4_SRC:
+			tun_key->ipv4_src = nla_get_be32(a);
+			break;
+		case OVS_TUNNEL_KEY_ATTR_IPV4_DST:
+			tun_key->ipv4_dst = nla_get_be32(a);
+			break;
+		case OVS_TUNNEL_KEY_ATTR_TOS:
+			tun_key->ipv4_tos = nla_get_u8(a);
+			break;
+		case OVS_TUNNEL_KEY_ATTR_TTL:
+			tun_key->ipv4_ttl = nla_get_u8(a);
+			ttl = true;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT:
+			tun_key->tun_flags |= TUNNEL_DONT_FRAGMENT;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_CSUM:
+			tun_key->tun_flags |= TUNNEL_CSUM;
+			break;
+		default:
+			return -EINVAL;
+
+		}
+	}
+	if (rem > 0)
+		return -EINVAL;
+
+	if (!tun_key->ipv4_dst)
+		return -EINVAL;
+
+	if (!ttl)
+		return -EINVAL;
+
+	return 0;
+}
+
+int ipv4_tun_to_nlattr(struct sk_buff *skb,
+			const struct ovs_key_ipv4_tunnel *tun_key)
+{
+	struct nlattr *nla;
+
+	nla = nla_nest_start(skb, OVS_KEY_ATTR_TUNNEL);
+	if (!nla)
+		return -EMSGSIZE;
+
+	if (tun_key->tun_flags & TUNNEL_KEY &&
+	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, tun_key->tun_id))
+		return -EMSGSIZE;
+	if (tun_key->ipv4_src &&
+	    nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, tun_key->ipv4_src))
+		return -EMSGSIZE;
+	if (nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, tun_key->ipv4_dst))
+		return -EMSGSIZE;
+	if (tun_key->ipv4_tos &&
+	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, tun_key->ipv4_tos))
+		return -EMSGSIZE;
+	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, tun_key->ipv4_ttl))
+		return -EMSGSIZE;
+	if ((tun_key->tun_flags & TUNNEL_DONT_FRAGMENT) &&
+		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT))
+		return -EMSGSIZE;
+	if ((tun_key->tun_flags & TUNNEL_CSUM) &&
+		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, nla);
+	return 0;
+}
+
 /**
  * ovs_flow_from_nlattrs - parses Netlink attributes into a flow key.
  * @swkey: receives the extracted flow key.
@@ -997,6 +1100,14 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		attrs &= ~(1 << OVS_KEY_ATTR_SKB_MARK);
 	}
 
+	if (attrs & (1ULL << OVS_KEY_ATTR_TUNNEL)) {
+		err = ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], &swkey->tun_key);
+		if (err)
+			return err;
+
+		attrs &= ~(1ULL << OVS_KEY_ATTR_TUNNEL);
+	}
+
 	/* Data attributes. */
 	if (!(attrs & (1 << OVS_KEY_ATTR_ETHERNET)))
 		return -EINVAL;
@@ -1135,17 +1246,21 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
 				   const struct nlattr *attr)
 {
+	struct ovs_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
 	const struct nlattr *nla;
 	int rem;
 
 	flow->key.phy.in_port = DP_MAX_PORTS;
 	flow->key.phy.priority = 0;
 	flow->key.phy.skb_mark = 0;
+	memset(tun_key, 0, sizeof(flow->key.tun_key));
 
 	nla_for_each_nested(nla, attr, rem) {
 		int type = nla_type(nla);
 
 		if (type <= OVS_KEY_ATTR_MAX && ovs_key_lens[type] > 0) {
+			int err;
+
 			if (nla_len(nla) != ovs_key_lens[type])
 				return -EINVAL;
 
@@ -1154,6 +1269,12 @@ int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
 				flow->key.phy.priority = nla_get_u32(nla);
 				break;
 
+			case OVS_KEY_ATTR_TUNNEL:
+				err = ipv4_tun_from_nlattr(nla, tun_key);
+				if (err)
+					return err;
+				break;
+
 			case OVS_KEY_ATTR_IN_PORT:
 				if (nla_get_u32(nla) >= DP_MAX_PORTS)
 					return -EINVAL;
@@ -1180,6 +1301,10 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 	    nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, swkey->phy.priority))
 		goto nla_put_failure;
 
+	if (swkey->tun_key.ipv4_dst &&
+	    ipv4_tun_to_nlattr(skb, &swkey->tun_key))
+		goto nla_put_failure;
+
 	if (swkey->phy.in_port != DP_MAX_PORTS &&
 	    nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port))
 		goto nla_put_failure;
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index e370f62..5183935 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -40,7 +40,22 @@ struct sw_flow_actions {
 	struct nlattr actions[];
 };
 
+/* Used to memset ovs_key_ipv4_tunnel padding. */
+#define OVS_TUNNEL_KEY_SIZE					\
+	(offsetof(struct ovs_key_ipv4_tunnel, ipv4_ttl) +	\
+	FIELD_SIZEOF(struct ovs_key_ipv4_tunnel, ipv4_ttl))
+
+struct ovs_key_ipv4_tunnel {
+	__be64 tun_id;
+	__be32 ipv4_src;
+	__be32 ipv4_dst;
+	u16  tun_flags;
+	u8   ipv4_tos;
+	u8   ipv4_ttl;
+};
+
 struct sw_flow_key {
+	struct ovs_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
 	struct {
 		u32	priority;	/* Packet QoS priority. */
 		u32	skb_mark;	/* SKB mark. */
@@ -179,5 +194,9 @@ u32 ovs_flow_hash(const struct sw_flow_key *key, int key_len);
 
 struct sw_flow *ovs_flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *idx);
 extern const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1];
+int ipv4_tun_from_nlattr(const struct nlattr *attr,
+			 struct ovs_key_ipv4_tunnel *tun_key);
+int ipv4_tun_to_nlattr(struct sk_buff *skb,
+			const struct ovs_key_ipv4_tunnel *tun_key);
 
 #endif /* flow.h */
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index e284c7e..98d3edb 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -67,7 +67,7 @@ static struct rtnl_link_stats64 *internal_dev_get_stats(struct net_device *netde
 static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	rcu_read_lock();
-	ovs_vport_receive(internal_dev_priv(netdev)->vport, skb);
+	ovs_vport_receive(internal_dev_priv(netdev)->vport, skb, NULL);
 	rcu_read_unlock();
 	return 0;
 }
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 018aadf..8c7cd46 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -51,7 +51,7 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 	skb_push(skb, ETH_HLEN);
 	ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
 
-	ovs_vport_receive(vport, skb);
+	ovs_vport_receive(vport, skb, NULL);
 	return;
 
 error:
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 7f20f6d..ef0bb5f 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -325,7 +325,8 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
  * Must be called with rcu_read_lock.  The packet cannot be shared and
  * skb->data should point to the Ethernet header.
  */
-void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
+void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
+		       struct ovs_key_ipv4_tunnel *tun_key)
 {
 	struct pcpu_tstats *stats;
 
@@ -335,6 +336,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
+	OVS_CB(skb)->tun_key = tun_key;
 	ovs_dp_process_received_packet(vport, skb);
 }
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 98f3341..2159e70 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -187,7 +187,8 @@ static inline struct vport *vport_from_priv(const void *priv)
 	return (struct vport *)(priv - ALIGN(sizeof(struct vport), VPORT_ALIGN));
 }
 
-void ovs_vport_receive(struct vport *, struct sk_buff *);
+void ovs_vport_receive(struct vport *, struct sk_buff *,
+		       struct ovs_key_ipv4_tunnel *);
 void ovs_vport_record_error(struct vport *, enum vport_err_type err_type);
 
 /* List of statically compiled vport implementations.  Don't forget to also
-- 
1.7.1
