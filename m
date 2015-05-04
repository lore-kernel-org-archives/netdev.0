From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/6] net: Add full IPv6 addresses to flow_keys
Date: Mon, 4 May 2015 16:02:36 -0700
Message-ID: <1430780560-2758924-3-git-send-email-tom@herbertland.com>
References: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:1968 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751852AbbEDXC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:02:57 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t44N2FcR003124
	for <netdev@vger.kernel.org>; Mon, 4 May 2015 16:02:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u6e0qgfy8-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 May 2015 16:02:57 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 b371ca58f2b111e488910002c991e86a-df986e0 for <netdev@vger.kernel.org>;	Mon,
 04 May 2015 16:02:56 -0700
In-Reply-To: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
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
 drivers/net/bonding/bond_main.c                |   9 +--
 drivers/net/ethernet/cisco/enic/enic_clsf.c    |   8 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |   4 +-
 include/net/flow_keys.h                        |  29 ++++++-
 include/net/ip.h                               |  21 ++++-
 include/net/ipv6.h                             |  21 ++++-
 net/core/flow_dissector.c                      | 108 +++++++++++++++++++------
 net/sched/cls_flow.c                           |  14 +++-
 8 files changed, 166 insertions(+), 48 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d5fe5d5..31f5fd6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3062,8 +3062,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph))))
 			return false;
 		iph = ip_hdr(skb);
-		fk->src = iph->saddr;
-		fk->dst = iph->daddr;
+		iph_to_flow_copy_v4addrs(fk, iph);
 		noff += iph->ihl << 2;
 		if (!ip_is_fragment(iph))
 			proto = iph->protocol;
@@ -3071,8 +3070,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph6))))
 			return false;
 		iph6 = ipv6_hdr(skb);
-		fk->src = (__force __be32)ipv6_addr_hash(&iph6->saddr);
-		fk->dst = (__force __be32)ipv6_addr_hash(&iph6->daddr);
+		iph_to_flow_copy_v6addrs(fk, iph6);
 		noff += sizeof(*iph6);
 		proto = iph6->nexthdr;
 	} else {
@@ -3106,7 +3104,8 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 		hash = bond_eth_hash(skb);
 	else
 		hash = (__force u32)flow.ports;
-	hash ^= (__force u32)flow.dst ^ (__force u32)flow.src;
+	hash ^= (__force u32)flow_get_u32_dst(&flow) ^
+		(__force u32)flow_get_u32_src(&flow);
 	hash ^= (hash >> 16);
 	hash ^= (hash >> 8);
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index 0be6850..d8cbea1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -33,8 +33,8 @@ int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq)
 		return -EPROTONOSUPPORT;
 	};
 	data.type = FILTER_IPV4_5TUPLE;
-	data.u.ipv4.src_addr = ntohl(keys->src);
-	data.u.ipv4.dst_addr = ntohl(keys->dst);
+	data.u.ipv4.src_addr = ntohl(keys->v4addrs.src);
+	data.u.ipv4.dst_addr = ntohl(keys->v4addrs.dst);
 	data.u.ipv4.src_port = ntohs(keys->port16[0]);
 	data.u.ipv4.dst_port = ntohs(keys->port16[1]);
 	data.u.ipv4.flags = FILTER_FIELDS_IPV4_5TUPLE;
@@ -158,8 +158,8 @@ static struct enic_rfs_fltr_node *htbl_key_search(struct hlist_head *h,
 	struct enic_rfs_fltr_node *tpos;
 
 	hlist_for_each_entry(tpos, h, node)
-		if (tpos->keys.src == k->src &&
-		    tpos->keys.dst == k->dst &&
+		if (tpos->keys.v4addrs.src == k->v4addrs.src &&
+		    tpos->keys.v4addrs.dst == k->v4addrs.dst &&
 		    tpos->keys.ports == k->ports &&
 		    tpos->keys.ip_proto == k->ip_proto &&
 		    tpos->keys.n_proto == k->n_proto)
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 28d9ca6..6596c98 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -346,10 +346,10 @@ static int enic_grxclsrule(struct enic *enic, struct ethtool_rxnfc *cmd)
 		break;
 	}
 
-	fsp->h_u.tcp_ip4_spec.ip4src = n->keys.src;
+	fsp->h_u.tcp_ip4_spec.ip4src = flow_get_u32_src(&n->keys);
 	fsp->m_u.tcp_ip4_spec.ip4src = (__u32)~0;
 
-	fsp->h_u.tcp_ip4_spec.ip4dst = n->keys.dst;
+	fsp->h_u.tcp_ip4_spec.ip4dst = flow_get_u32_dst(&n->keys);
 	fsp->m_u.tcp_ip4_spec.ip4dst = (__u32)~0;
 
 	fsp->h_u.tcp_ip4_spec.psrc = n->keys.port16[0];
diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 5907472..c8bc6aa 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -16,23 +16,46 @@
  */
 struct flow_keys {
 	u16	thoff;
+	u16	addr_proto;
+#define	FLOW_KEYS_ADDR_NONE	0
+#define	FLOW_KEYS_ADDR_IPV4	1
+#define	FLOW_KEYS_ADDR_IPV6	2
+
+	/* Fields below this point are taken as input to skb_hash */
 #define FLOW_KEYS_HASH_START_FIELD	n_proto
 	__be16	n_proto;
 	u8	ip_proto;
 	u8	padding;
 
-	/* (src,dst) must be grouped, in the same way than in IP header */
-	__be32 src;
-	__be32 dst;
 	union {
 		__be32 ports;
 		__be16 port16[2];
 	};
+
+	/* (src,dst) must be grouped, in the same way than in IP header */
+	union {
+		u32	addrs;
+#define FLOW_KEYS_HASH_ADDR_START_FIELD	addrs
+		struct {
+			__be32 src;
+			__be32 dst;
+		} v4addrs;
+		struct {
+			__be32 src[4];
+			__be32 dst[4];
+		} v6addrs;
+	};
 };
 
 #define FLOW_KEYS_HASH_OFFSET		\
 	offsetof(struct flow_keys, FLOW_KEYS_HASH_START_FIELD)
 
+#define FLOW_KEYS_HASH_ADDRS_OFFSET	\
+	offsetof(struct flow_keys, FLOW_KEYS_HASH_ADDR_START_FIELD)
+
+__be32 flow_get_u32_src(const struct flow_keys *flow);
+__be32 flow_get_u32_dst(const struct flow_keys *flow);
+
 bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
 			void *data, __be16 proto, int nhoff, int hlen);
 static inline bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
diff --git a/include/net/ip.h b/include/net/ip.h
index d14af7e..fa89279 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -355,13 +355,30 @@ static inline __wsum inet_compute_pseudo(struct sk_buff *skb, int proto)
 				  skb->len, proto, 0);
 }
 
+/* copy IPv4 saddr & daddr to flow_keys, possibly using 64bit load/store
+ * Equivalent to :	flow->v4addrs.src = iph->saddr;
+ *			flow->v4addrs.dst = iph->daddr;
+ */
+static inline void iph_to_flow_copy_v4addrs(struct flow_keys *flow,
+					    const struct iphdr *iph)
+{
+	BUILD_BUG_ON(offsetof(typeof(*flow), v4addrs.dst) !=
+		     offsetof(typeof(*flow), v4addrs.src) +
+			      sizeof(flow->v4addrs.src));
+	memcpy(&flow->v4addrs, &iph->saddr, sizeof(flow->v4addrs));
+	flow->addr_proto = FLOW_KEYS_ADDR_IPV4;
+}
+
 static inline void inet_set_txhash(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct flow_keys keys;
 
-	keys.src = inet->inet_saddr;
-	keys.dst = inet->inet_daddr;
+	memset(&keys, 0, sizeof(keys));
+
+	keys.v4addrs.src = inet->inet_saddr;
+	keys.v4addrs.dst = inet->inet_daddr;
+	keys.addr_proto = FLOW_KEYS_ADDR_IPV4;
 	keys.port16[0] = inet->inet_sport;
 	keys.port16[1] = inet->inet_dport;
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 53d25ef..5e2b8dc 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -691,6 +691,20 @@ static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
 	return hlimit;
 }
 
+/* copy IPv6 saddr & daddr to flow_keys, possibly using 64bit load/store
+ * Equivalent to :	flow->v6addrs.src = iph->saddr;
+ *			flow->v6addrs.dst = iph->daddr;
+ */
+static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
+					    const struct ipv6hdr *iph)
+{
+	BUILD_BUG_ON(offsetof(typeof(*flow), v6addrs.dst) !=
+		     offsetof(typeof(*flow), v6addrs.src) +
+			      sizeof(flow->v6addrs.src));
+	memcpy(&flow->v6addrs, &iph->saddr, sizeof(flow->v6addrs));
+	flow->addr_proto = FLOW_KEYS_ADDR_IPV6;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static inline void ip6_set_txhash(struct sock *sk)
 {
@@ -698,8 +712,11 @@ static inline void ip6_set_txhash(struct sock *sk)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flow_keys keys;
 
-	keys.src = (__force __be32)ipv6_addr_hash(&np->saddr);
-	keys.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
+	memset(&keys, 0, sizeof(keys));
+
+	memcpy(&keys.v6addrs.src, &np->saddr, sizeof(keys.v6addrs.src));
+	memcpy(&keys.v6addrs.dst, &sk->sk_v6_daddr, sizeof(keys.v6addrs.dst));
+	keys.addr_proto = FLOW_KEYS_ADDR_IPV6;
 	keys.port16[0] = inet->inet_sport;
 	keys.port16[1] = inet->inet_dport;
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 02c5104..69fbaf9 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -15,17 +15,6 @@
 #include <net/flow_keys.h>
 #include <scsi/fc/fc_fcoe.h>
 
-/* copy saddr & daddr, possibly using 64bit load/store
- * Equivalent to :	flow->src = iph->saddr;
- *			flow->dst = iph->daddr;
- */
-static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *iph)
-{
-	BUILD_BUG_ON(offsetof(typeof(*flow), dst) !=
-		     offsetof(typeof(*flow), src) + sizeof(flow->src));
-	memcpy(&flow->src, &iph->saddr, sizeof(flow->src) + sizeof(flow->dst));
-}
-
 /**
  * __skb_flow_get_ports - extract the upper layer ports and return them
  * @skb: sk_buff to extract the ports from
@@ -107,7 +96,7 @@ ip:
 		if (!skb)
 			break;
 
-		iph_to_flow_copy_addrs(flow, iph);
+		iph_to_flow_copy_v4addrs(flow, iph);
 		break;
 	}
 	case htons(ETH_P_IPV6): {
@@ -127,8 +116,7 @@ ipv6:
 		if (!skb)
 			break;
 
-		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
-		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
+		iph_to_flow_copy_v6addrs(flow, iph);
 
 		flow_label = ip6_flowlabel(iph);
 		if (flow_label) {
@@ -186,8 +174,9 @@ ipv6:
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
 			return false;
-		flow->src = hdr->srcnode;
-		flow->dst = 0;
+		flow->v4addrs.src = hdr->srcnode;
+		flow->v4addrs.dst = 0;
+		flow->addr_proto = FLOW_KEYS_ADDR_IPV4;
 		flow->n_proto = proto;
 		flow->thoff = (u16)nhoff;
 		return true;
@@ -279,20 +268,87 @@ static inline void *flow_keys_hash_start(struct flow_keys *flow)
 
 static inline size_t flow_keys_hash_length(struct flow_keys *flow)
 {
-	return (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) / sizeof(u32);
+	size_t len = (FLOW_KEYS_HASH_ADDRS_OFFSET -
+		       FLOW_KEYS_HASH_OFFSET) / sizeof(u32);
+
+	switch (flow->addr_proto) {
+	case FLOW_KEYS_ADDR_IPV4:
+		len += sizeof(flow->v4addrs) / sizeof(u32);
+		break;
+	case FLOW_KEYS_ADDR_IPV6:
+		len += sizeof(flow->v6addrs) / sizeof(u32);
+		break;
+	}
+
+	return len;
 }
 
-static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
+__be32 flow_get_u32_src(const struct flow_keys *flow)
 {
-	u32 hash;
+	switch (flow->addr_proto) {
+	case FLOW_KEYS_ADDR_IPV4:
+		return flow->v4addrs.src;
+	case FLOW_KEYS_ADDR_IPV6:
+		return (__force __be32)ipv6_addr_hash(
+				(struct in6_addr *)flow->v6addrs.src);
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(flow_get_u32_src);
+
+__be32 flow_get_u32_dst(const struct flow_keys *flow)
+{
+	switch (flow->addr_proto) {
+	case FLOW_KEYS_ADDR_IPV4:
+		return flow->v4addrs.dst;
+	case FLOW_KEYS_ADDR_IPV6:
+		return (__force __be32)ipv6_addr_hash(
+				(struct in6_addr *)flow->v6addrs.dst);
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(flow_get_u32_dst);
+
+static inline void __flow_hash_consistentify(struct flow_keys *keys)
+{
+	int addr_diff, i;
 
 	/* get a consistent hash (same value on both flow directions) */
-	if (((__force u32)keys->dst < (__force u32)keys->src) ||
-	    (((__force u32)keys->dst == (__force u32)keys->src) &&
-	     ((__force u16)keys->port16[1] < (__force u16)keys->port16[0]))) {
-		swap(keys->dst, keys->src);
-		swap(keys->port16[0], keys->port16[1]);
+	switch (keys->addr_proto) {
+	case FLOW_KEYS_ADDR_IPV4:
+		addr_diff = (__force u32)keys->v4addrs.dst -
+			    (__force u32)keys->v4addrs.src;
+		if ((addr_diff < 0) ||
+		    (addr_diff == 0 &&
+		     ((__force u16)keys->port16[1] <
+		      (__force u16)keys->port16[0]))) {
+			swap(keys->v4addrs.dst, keys->v4addrs.src);
+			swap(keys->port16[0], keys->port16[1]);
+		}
+		break;
+	case FLOW_KEYS_ADDR_IPV6:
+		addr_diff = memcmp(keys->v6addrs.dst, keys->v6addrs.src,
+				   sizeof(keys->v6addrs.dst));
+		if ((addr_diff < 0) ||
+		    (addr_diff == 0 &&
+		     ((__force u16)keys->port16[1] <
+		      (__force u16)keys->port16[0]))) {
+			for (i = 0; i < 4; i++)
+				swap(keys->v6addrs.dst[i],
+				     keys->v6addrs.src[i]);
+			swap(keys->port16[0], keys->port16[1]);
+		}
+		break;
 	}
+}
+
+static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
+{
+	u32 hash;
+
+	__flow_hash_consistentify(keys);
 
 	hash = __flow_hash_words((u32 *)flow_keys_hash_start(keys),
 				 flow_keys_hash_length(keys), keyval);
@@ -340,8 +396,8 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
 	data->n_proto = flow->n_proto;
 	data->ip_proto = flow->ip_proto;
 	data->ports = flow->ports;
-	data->src = flow->src;
-	data->dst = flow->dst;
+	data->src = flow_get_u32_src(flow);
+	data->dst = flow_get_u32_dst(flow);
 }
 EXPORT_SYMBOL(make_flow_keys_digest);
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index a620c4e..3788b929 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -68,15 +68,21 @@ static inline u32 addr_fold(void *addr)
 
 static u32 flow_get_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->src)
-		return ntohl(flow->src);
+	__be32 src = flow_get_u32_src(flow);
+
+	if (src)
+		return ntohl(src);
+
 	return addr_fold(skb->sk);
 }
 
 static u32 flow_get_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->dst)
-		return ntohl(flow->dst);
+	__be32 dst = flow_get_u32_dst(flow);
+
+	if (dst)
+		return ntohl(dst);
+
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
 
-- 
1.8.1
