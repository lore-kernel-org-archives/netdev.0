From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 05/11] net: Add full IPv6 addresses to flow_keys
Date: Thu, 28 May 2015 11:19:02 -0700
Message-ID: <1432837148-1359931-6-git-send-email-tom@herbertland.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51646 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754519AbbE1STc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 14:19:32 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t4SIHWNZ013775
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1up50pgdmp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:31 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 14c5c73e056611e589d40002c95209d8-cd3fa3a0 for <netdev@vger.kernel.org>;	Thu,
 28 May 2015 11:19:29 -0700
In-Reply-To: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds full IPv6 addresses into flow_keys and uses them as
input to the flow hash function. The implementation supports either
IPv4 or IPv6 addresses in a union, and selector is used to determine
how may words to input to jhash2.

We also add flow_get_u32_dst and flow_get_u32_src functions which are
used to get a u32 representation of the source and destination
addresses. For IPv6, ipv6_addr_hash is called. These functions retain
getting the legacy values of src and dst in flow_keys.

With this patch, Ethertype and IP protocol are now included in the
flow hash input.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/bonding/bond_main.c                |   9 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c    |   8 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |   4 +-
 include/net/flow_dissector.h                   |  52 +++++++----
 include/net/ip.h                               |  19 +++-
 include/net/ipv6.h                             |  21 ++++-
 net/core/flow_dissector.c                      | 116 +++++++++++++++++++++----
 net/ethernet/eth.c                             |   2 +-
 net/sched/cls_flow.c                           |  14 ++-
 net/sched/cls_flower.c                         |  11 +--
 10 files changed, 193 insertions(+), 63 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2268438..19eb990 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3059,8 +3059,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph))))
 			return false;
 		iph = ip_hdr(skb);
-		fk->addrs.src = iph->saddr;
-		fk->addrs.dst = iph->daddr;
+		iph_to_flow_copy_v4addrs(fk, iph);
 		noff += iph->ihl << 2;
 		if (!ip_is_fragment(iph))
 			proto = iph->protocol;
@@ -3068,8 +3067,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph6))))
 			return false;
 		iph6 = ipv6_hdr(skb);
-		fk->addrs.src = (__force __be32)ipv6_addr_hash(&iph6->saddr);
-		fk->addrs.dst = (__force __be32)ipv6_addr_hash(&iph6->daddr);
+		iph_to_flow_copy_v6addrs(fk, iph6);
 		noff += sizeof(*iph6);
 		proto = iph6->nexthdr;
 	} else {
@@ -3103,7 +3101,8 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 		hash = bond_eth_hash(skb);
 	else
 		hash = (__force u32)flow.ports.ports;
-	hash ^= (__force u32)flow.addrs.dst ^ (__force u32)flow.addrs.src;
+	hash ^= (__force u32)flow_get_u32_dst(&flow) ^
+		(__force u32)flow_get_u32_src(&flow);
 	hash ^= (hash >> 16);
 	hash ^= (hash >> 8);
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index a31b57a..d106186 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -33,8 +33,8 @@ int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq)
 		return -EPROTONOSUPPORT;
 	};
 	data.type = FILTER_IPV4_5TUPLE;
-	data.u.ipv4.src_addr = ntohl(keys->addrs.src);
-	data.u.ipv4.dst_addr = ntohl(keys->addrs.dst);
+	data.u.ipv4.src_addr = ntohl(keys->addrs.v4addrs.src);
+	data.u.ipv4.dst_addr = ntohl(keys->addrs.v4addrs.dst);
 	data.u.ipv4.src_port = ntohs(keys->ports.src);
 	data.u.ipv4.dst_port = ntohs(keys->ports.dst);
 	data.u.ipv4.flags = FILTER_FIELDS_IPV4_5TUPLE;
@@ -158,8 +158,8 @@ static struct enic_rfs_fltr_node *htbl_key_search(struct hlist_head *h,
 	struct enic_rfs_fltr_node *tpos;
 
 	hlist_for_each_entry(tpos, h, node)
-		if (tpos->keys.addrs.src == k->addrs.src &&
-		    tpos->keys.addrs.dst == k->addrs.dst &&
+		if (tpos->keys.addrs.v4addrs.src == k->addrs.v4addrs.src &&
+		    tpos->keys.addrs.v4addrs.dst == k->addrs.v4addrs.dst &&
 		    tpos->keys.ports.ports == k->ports.ports &&
 		    tpos->keys.basic.ip_proto == k->basic.ip_proto &&
 		    tpos->keys.basic.n_proto == k->basic.n_proto)
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 117c096..73874b2 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -346,10 +346,10 @@ static int enic_grxclsrule(struct enic *enic, struct ethtool_rxnfc *cmd)
 		break;
 	}
 
-	fsp->h_u.tcp_ip4_spec.ip4src = n->keys.addrs.src;
+	fsp->h_u.tcp_ip4_spec.ip4src = flow_get_u32_src(&n->keys);
 	fsp->m_u.tcp_ip4_spec.ip4src = (__u32)~0;
 
-	fsp->h_u.tcp_ip4_spec.ip4dst = n->keys.addrs.dst;
+	fsp->h_u.tcp_ip4_spec.ip4dst = flow_get_u32_dst(&n->keys);
 	fsp->m_u.tcp_ip4_spec.ip4dst = (__u32)~0;
 
 	fsp->h_u.tcp_ip4_spec.psrc = n->keys.ports.src;
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index cba6a10..306d461 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -12,7 +12,7 @@
  */
 struct flow_dissector_key_control {
 	u16	thoff;
-	u16	padding;
+	u16	addr_type;
 };
 
 /**
@@ -28,19 +28,40 @@ struct flow_dissector_key_basic {
 };
 
 /**
- * struct flow_dissector_key_addrs:
- * @src: source ip address in case of IPv4
- *	 For IPv6 it contains 32bit hash of src address
- * @dst: destination ip address in case of IPv4
- *	 For IPv6 it contains 32bit hash of dst address
+ * struct flow_dissector_key_ipv4_addrs:
+ * @src: source ip address
+ * @dst: destination ip address
  */
-struct flow_dissector_key_addrs {
+struct flow_dissector_key_ipv4_addrs {
 	/* (src,dst) must be grouped, in the same way than in IP header */
 	__be32 src;
 	__be32 dst;
 };
 
 /**
+ * struct flow_dissector_key_ipv6_addrs:
+ * @src: source ip address
+ * @dst: destination ip address
+ */
+struct flow_dissector_key_ipv6_addrs {
+	/* (src,dst) must be grouped, in the same way than in IP header */
+	struct in6_addr src;
+	struct in6_addr dst;
+};
+
+/**
+ * struct flow_dissector_key_addrs:
+ * @v4addrs: IPv4 addresses
+ * @v6addrs: IPv6 addresses
+ */
+struct flow_dissector_key_addrs {
+	union {
+		struct flow_dissector_key_ipv4_addrs v4addrs;
+		struct flow_dissector_key_ipv6_addrs v6addrs;
+	};
+};
+
+/**
  * flow_dissector_key_tp_ports:
  *	@ports: port numbers of Transport header
  *		src: source port number
@@ -56,16 +77,6 @@ struct flow_dissector_key_ports {
 	};
 };
 
-/**
- * struct flow_dissector_key_ipv6_addrs:
- * @src: source ip address
- * @dst: destination ip address
- */
-struct flow_dissector_key_ipv6_addrs {
-	/* (src,dst) must be grouped, in the same way than in IP header */
-	struct in6_addr src;
-	struct in6_addr dst;
-};
 
 /**
  * struct flow_dissector_key_eth_addrs:
@@ -81,10 +92,10 @@ struct flow_dissector_key_eth_addrs {
 enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
-	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_addrs */
+	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
+	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
-	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 
 	FLOW_DISSECTOR_KEY_MAX,
@@ -129,6 +140,9 @@ struct flow_keys {
 #define FLOW_KEYS_HASH_OFFSET		\
 	offsetof(struct flow_keys, FLOW_KEYS_HASH_START_FIELD)
 
+__be32 flow_get_u32_src(const struct flow_keys *flow);
+__be32 flow_get_u32_dst(const struct flow_keys *flow);
+
 extern struct flow_dissector flow_keys_dissector;
 extern struct flow_dissector flow_keys_buf_dissector;
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 16cfc87..0750a18 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -355,6 +355,20 @@ static inline __wsum inet_compute_pseudo(struct sk_buff *skb, int proto)
 				  skb->len, proto, 0);
 }
 
+/* copy IPv4 saddr & daddr to flow_keys, possibly using 64bit load/store
+ * Equivalent to :	flow->v4addrs.src = iph->saddr;
+ *			flow->v4addrs.dst = iph->daddr;
+ */
+static inline void iph_to_flow_copy_v4addrs(struct flow_keys *flow,
+					    const struct iphdr *iph)
+{
+	BUILD_BUG_ON(offsetof(typeof(flow->addrs), v4addrs.dst) !=
+		     offsetof(typeof(flow->addrs), v4addrs.src) +
+			      sizeof(flow->addrs.v4addrs.src));
+	memcpy(&flow->addrs.v4addrs, &iph->saddr, sizeof(flow->addrs.v4addrs));
+	flow->control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+}
+
 static inline void inet_set_txhash(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -362,8 +376,9 @@ static inline void inet_set_txhash(struct sock *sk)
 
 	memset(&keys, 0, sizeof(keys));
 
-	keys.addrs.src = inet->inet_saddr;
-	keys.addrs.dst = inet->inet_daddr;
+	keys.addrs.v4addrs.src = inet->inet_saddr;
+	keys.addrs.v4addrs.dst = inet->inet_daddr;
+	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
 	keys.ports.src = inet->inet_sport;
 	keys.ports.dst = inet->inet_dport;
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 474ca46..82dbdb0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -692,6 +692,20 @@ static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
 	return hlimit;
 }
 
+/* copy IPv6 saddr & daddr to flow_keys, possibly using 64bit load/store
+ * Equivalent to :	flow->v6addrs.src = iph->saddr;
+ *			flow->v6addrs.dst = iph->daddr;
+ */
+static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
+					    const struct ipv6hdr *iph)
+{
+	BUILD_BUG_ON(offsetof(typeof(flow->addrs), v6addrs.dst) !=
+		     offsetof(typeof(flow->addrs), v6addrs.src) +
+		     sizeof(flow->addrs.v6addrs.src));
+	memcpy(&flow->addrs.v6addrs, &iph->saddr, sizeof(flow->addrs.v6addrs));
+	flow->control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static inline void ip6_set_txhash(struct sock *sk)
 {
@@ -701,8 +715,11 @@ static inline void ip6_set_txhash(struct sock *sk)
 
 	memset(&keys, 0, sizeof(keys));
 
-	keys.addrs.src = (__force __be32)ipv6_addr_hash(&np->saddr);
-	keys.addrs.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
+	memcpy(&keys.addrs.v6addrs.src, &np->saddr,
+	       sizeof(keys.addrs.v6addrs.src));
+	memcpy(&keys.addrs.v6addrs.dst, &sk->sk_v6_daddr,
+	       sizeof(keys.addrs.v6addrs.dst));
+	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
 	keys.ports.src = inet->inet_sport;
 	keys.ports.dst = inet->inet_dport;
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 55b5f29..ca9d224 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -178,10 +178,12 @@ ip:
 		if (!skb_flow_dissector_uses_key(flow_dissector,
 						 FLOW_DISSECTOR_KEY_IPV4_ADDRS))
 			break;
+
 		key_addrs = skb_flow_dissector_target(flow_dissector,
-						      FLOW_DISSECTOR_KEY_IPV4_ADDRS,
-						      target_container);
-		memcpy(key_addrs, &iph->saddr, sizeof(*key_addrs));
+			      FLOW_DISSECTOR_KEY_IPV4_ADDRS, target_container);
+		memcpy(&key_addrs->v4addrs, &iph->saddr,
+		       sizeof(key_addrs->v4addrs));
+		key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
 		break;
 	}
 	case htons(ETH_P_IPV6): {
@@ -203,8 +205,11 @@ ipv6:
 							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
 							      target_container);
 
-			key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
-			key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
+			key_addrs->v4addrs.src =
+				(__force __be32)ipv6_addr_hash(&iph->saddr);
+			key_addrs->v4addrs.dst =
+				(__force __be32)ipv6_addr_hash(&iph->daddr);
+			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
 			goto flow_label;
 		}
 		if (skb_flow_dissector_uses_key(flow_dissector,
@@ -216,6 +221,7 @@ ipv6:
 								   target_container);
 
 			memcpy(key_ipv6_addrs, &iph->saddr, sizeof(*key_ipv6_addrs));
+			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
 			goto flow_label;
 		}
 		break;
@@ -292,8 +298,9 @@ flow_label:
 			key_addrs = skb_flow_dissector_target(flow_dissector,
 							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
 							      target_container);
-			key_addrs->src = hdr->srcnode;
-			key_addrs->dst = 0;
+			key_addrs->v4addrs.src = hdr->srcnode;
+			key_addrs->v4addrs.dst = 0;
+			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
 		}
 		return true;
 	}
@@ -389,21 +396,88 @@ static inline void *flow_keys_hash_start(struct flow_keys *flow)
 
 static inline size_t flow_keys_hash_length(struct flow_keys *flow)
 {
+	size_t diff = FLOW_KEYS_HASH_OFFSET + sizeof(flow->addrs);
 	BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
-	return (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) / sizeof(u32);
+	BUILD_BUG_ON(offsetof(typeof(*flow), addrs) !=
+		     sizeof(*flow) - sizeof(flow->addrs));
+
+	switch (flow->control.addr_type) {
+	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
+		diff -= sizeof(flow->addrs.v4addrs);
+		break;
+	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
+		diff -= sizeof(flow->addrs.v6addrs);
+		break;
+	}
+	return (sizeof(*flow) - diff) / sizeof(u32);
+}
+
+__be32 flow_get_u32_src(const struct flow_keys *flow)
+{
+	switch (flow->control.addr_type) {
+	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
+		return flow->addrs.v4addrs.src;
+	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
+		return (__force __be32)ipv6_addr_hash(
+			&flow->addrs.v6addrs.src);
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(flow_get_u32_src);
+
+__be32 flow_get_u32_dst(const struct flow_keys *flow)
+{
+	switch (flow->control.addr_type) {
+	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
+		return flow->addrs.v4addrs.dst;
+	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
+		return (__force __be32)ipv6_addr_hash(
+			&flow->addrs.v6addrs.dst);
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(flow_get_u32_dst);
+
+static inline void __flow_hash_consistentify(struct flow_keys *keys)
+{
+	int addr_diff, i;
+
+	switch (keys->control.addr_type) {
+	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
+		addr_diff = (__force u32)keys->addrs.v4addrs.dst -
+			    (__force u32)keys->addrs.v4addrs.src;
+		if ((addr_diff < 0) ||
+		    (addr_diff == 0 &&
+		     ((__force u16)keys->ports.dst <
+		      (__force u16)keys->ports.src))) {
+			swap(keys->addrs.v4addrs.src, keys->addrs.v4addrs.dst);
+			swap(keys->ports.src, keys->ports.dst);
+		}
+		break;
+	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
+		addr_diff = memcmp(&keys->addrs.v6addrs.dst,
+				   &keys->addrs.v6addrs.src,
+				   sizeof(keys->addrs.v6addrs.dst));
+		if ((addr_diff < 0) ||
+		    (addr_diff == 0 &&
+		     ((__force u16)keys->ports.dst <
+		      (__force u16)keys->ports.src))) {
+			for (i = 0; i < 4; i++)
+				swap(keys->addrs.v6addrs.src.s6_addr32[i],
+				     keys->addrs.v6addrs.dst.s6_addr32[i]);
+			swap(keys->ports.src, keys->ports.dst);
+		}
+		break;
+	}
 }
 
 static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
 {
 	u32 hash;
 
-	/* get a consistent hash (same value on both flow directions) */
-	if (((__force u32)keys->addrs.dst < (__force u32)keys->addrs.src) ||
-	    (((__force u32)keys->addrs.dst == (__force u32)keys->addrs.src) &&
-	     ((__force u16)keys->ports.dst < (__force u16)keys->ports.src))) {
-		swap(keys->addrs.dst, keys->addrs.src);
-		swap(keys->ports.src, keys->ports.dst);
-	}
+	__flow_hash_consistentify(keys);
 
 	hash = __flow_hash_words((u32 *)flow_keys_hash_start(keys),
 				 flow_keys_hash_length(keys), keyval);
@@ -451,8 +525,8 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
 	data->n_proto = flow->basic.n_proto;
 	data->ip_proto = flow->basic.ip_proto;
 	data->ports = flow->ports.ports;
-	data->src = flow->addrs.src;
-	data->dst = flow->addrs.dst;
+	data->src = flow->addrs.v4addrs.src;
+	data->dst = flow->addrs.v4addrs.dst;
 }
 EXPORT_SYMBOL(make_flow_keys_digest);
 
@@ -566,11 +640,15 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 	},
 	{
 		.key_id = FLOW_DISSECTOR_KEY_IPV4_ADDRS,
-		.offset = offsetof(struct flow_keys, addrs),
+		.offset = offsetof(struct flow_keys, addrs.v4addrs),
+	},
+	{
+		.key_id = FLOW_DISSECTOR_KEY_IPV6_ADDRS,
+		.offset = offsetof(struct flow_keys, addrs.v6addrs),
 	},
 	{
 		.key_id = FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
-		.offset = offsetof(struct flow_keys, addrs),
+		.offset = offsetof(struct flow_keys, addrs.v4addrs),
 	},
 	{
 		.key_id = FLOW_DISSECTOR_KEY_PORTS,
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index c3325bd..b8b277e 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -133,7 +133,7 @@ u32 eth_get_headlen(void *data, unsigned int len)
 	/* parse any remaining L2/L3 headers, check for L4 */
 	if (!skb_flow_dissect_flow_keys_buf(&keys, data, eth->h_proto,
 					    sizeof(*eth), len))
-		return max_t(u32, keys.basic.thoff, sizeof(*eth));
+		return max_t(u32, keys.control.thoff, sizeof(*eth));
 
 	/* parse for any L4 headers */
 	return min_t(u32, __skb_get_poff(NULL, data, &keys, len), len);
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index b435992..76bc3a2 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -68,15 +68,21 @@ static inline u32 addr_fold(void *addr)
 
 static u32 flow_get_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->addrs.src)
-		return ntohl(flow->addrs.src);
+	__be32 src = flow_get_u32_src(flow);
+
+	if (src)
+		return ntohl(src);
+
 	return addr_fold(skb->sk);
 }
 
 static u32 flow_get_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->addrs.dst)
-		return ntohl(flow->addrs.dst);
+	__be32 dst = flow_get_u32_dst(flow);
+
+	if (dst)
+		return ntohl(dst);
+
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 5a7d66c..b92d3f4 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -28,8 +28,9 @@ struct fl_flow_key {
 	struct flow_dissector_key_control control;
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_eth_addrs eth;
+	struct flow_dissector_key_addrs ipaddrs;
 	union {
-		struct flow_dissector_key_addrs ipv4;
+		struct flow_dissector_key_ipv4_addrs ipv4;
 		struct flow_dissector_key_ipv6_addrs ipv6;
 	};
 	struct flow_dissector_key_ports tp;
@@ -260,14 +261,14 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       &mask->basic.ip_proto, TCA_FLOWER_UNSPEC,
 			       sizeof(key->basic.ip_proto));
 	}
-	if (key->basic.n_proto == htons(ETH_P_IP)) {
+	if (key->control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
 		fl_set_key_val(tb, &key->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC,
 			       &mask->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC_MASK,
 			       sizeof(key->ipv4.src));
 		fl_set_key_val(tb, &key->ipv4.dst, TCA_FLOWER_KEY_IPV4_DST,
 			       &mask->ipv4.dst, TCA_FLOWER_KEY_IPV4_DST_MASK,
 			       sizeof(key->ipv4.dst));
-	} else if (key->basic.n_proto == htons(ETH_P_IPV6)) {
+	} else if (key->control.addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
 		fl_set_key_val(tb, &key->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC,
 			       &mask->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC_MASK,
 			       sizeof(key->ipv6.src));
@@ -610,7 +611,7 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			    sizeof(key->basic.ip_proto)))
 		goto nla_put_failure;
 
-	if (key->basic.n_proto == htons(ETH_P_IP) &&
+	if (key->control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS &&
 	    (fl_dump_key_val(skb, &key->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC,
 			     &mask->ipv4.src, TCA_FLOWER_KEY_IPV4_SRC_MASK,
 			     sizeof(key->ipv4.src)) ||
@@ -618,7 +619,7 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			     &mask->ipv4.dst, TCA_FLOWER_KEY_IPV4_DST_MASK,
 			     sizeof(key->ipv4.dst))))
 		goto nla_put_failure;
-	else if (key->basic.n_proto == htons(ETH_P_IPV6) &&
+	else if (key->control.addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS &&
 		 (fl_dump_key_val(skb, &key->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC,
 				  &mask->ipv6.src, TCA_FLOWER_KEY_IPV6_SRC_MASK,
 				  sizeof(key->ipv6.src)) ||
-- 
1.8.1
