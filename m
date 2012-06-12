From: pablo@netfilter.org
Subject: [PATCH 1/2] netfilter: xt_HMARK: fix endianness and provide consistent hashing
Date: Tue, 12 Jun 2012 19:36:02 +0200
Message-ID: <1339522563-9227-2-git-send-email-pablo@netfilter.org>
References: <1339522563-9227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339522563-9227-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans@schillstrom.com>

This patch addresses two issues:

a) Fix usage of u32 and __be32 that causes endianess warnings via sparse.
b) Ensure consistent hashing in a cluster that is composed of big and
   little endian systems. Thus, we obtain the same hash mark in an
   heterogeneous cluster.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_HMARK.h |    5 +++
 net/netfilter/xt_HMARK.c           |   72 ++++++++++++++++++++----------------
 2 files changed, 46 insertions(+), 31 deletions(-)

diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
index abb1650..826fc58 100644
--- a/include/linux/netfilter/xt_HMARK.h
+++ b/include/linux/netfilter/xt_HMARK.h
@@ -27,7 +27,12 @@ union hmark_ports {
 		__u16	src;
 		__u16	dst;
 	} p16;
+	struct {
+		__be16	src;
+		__be16	dst;
+	} b16;
 	__u32	v32;
+	__be32	b32;
 };
 
 struct xt_hmark_info {
diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
index 0a96a43..1686ca1 100644
--- a/net/netfilter/xt_HMARK.c
+++ b/net/netfilter/xt_HMARK.c
@@ -32,13 +32,13 @@ MODULE_ALIAS("ipt_HMARK");
 MODULE_ALIAS("ip6t_HMARK");
 
 struct hmark_tuple {
-	u32			src;
-	u32			dst;
+	__be32			src;
+	__be32			dst;
 	union hmark_ports	uports;
-	uint8_t			proto;
+	u8			proto;
 };
 
-static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
+static inline __be32 hmark_addr6_mask(const __be32 *addr32, const __be32 *mask)
 {
 	return (addr32[0] & mask[0]) ^
 	       (addr32[1] & mask[1]) ^
@@ -46,8 +46,8 @@ static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
 	       (addr32[3] & mask[3]);
 }
 
-static inline u32
-hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
+static inline __be32
+hmark_addr_mask(int l3num, const __be32 *addr32, const __be32 *mask)
 {
 	switch (l3num) {
 	case AF_INET:
@@ -58,6 +58,22 @@ hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
 	return 0;
 }
 
+static inline void hmark_swap_ports(union hmark_ports *uports,
+				    const struct xt_hmark_info *info)
+{
+	union hmark_ports hp;
+	u16 src, dst;
+
+	hp.b32 = (uports->b32 & info->port_mask.b32) | info->port_set.b32;
+	src = ntohs(hp.b16.src);
+	dst = ntohs(hp.b16.dst);
+
+	if (dst > src)
+		uports->v32 = (dst << 16) | src;
+	else
+		uports->v32 = (src << 16) | dst;
+}
+
 static int
 hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
 		    const struct xt_hmark_info *info)
@@ -74,22 +90,19 @@ hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
 	otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 	rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
 
-	t->src = hmark_addr_mask(otuple->src.l3num, otuple->src.u3.all,
-				 info->src_mask.all);
-	t->dst = hmark_addr_mask(otuple->src.l3num, rtuple->src.u3.all,
-				 info->dst_mask.all);
+	t->src = hmark_addr_mask(otuple->src.l3num, otuple->src.u3.ip6,
+				 info->src_mask.ip6);
+	t->dst = hmark_addr_mask(otuple->src.l3num, rtuple->src.u3.ip6,
+				 info->dst_mask.ip6);
 
 	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
 		return 0;
 
 	t->proto = nf_ct_protonum(ct);
 	if (t->proto != IPPROTO_ICMP) {
-		t->uports.p16.src = otuple->src.u.all;
-		t->uports.p16.dst = rtuple->src.u.all;
-		t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
-				info->port_set.v32;
-		if (t->uports.p16.dst < t->uports.p16.src)
-			swap(t->uports.p16.dst, t->uports.p16.src);
+		t->uports.b16.src = otuple->src.u.all;
+		t->uports.b16.dst = rtuple->src.u.all;
+		hmark_swap_ports(&t->uports, info);
 	}
 
 	return 0;
@@ -98,15 +111,19 @@ hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
 #endif
 }
 
+/* This hash function is endian independent, to ensure consistent hashing if
+ * the cluster is composed of big and little endian systems. */
 static inline u32
 hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
 {
 	u32 hash;
+	u32 src = ntohl(t->src);
+	u32 dst = ntohl(t->dst);
 
-	if (t->dst < t->src)
-		swap(t->src, t->dst);
+	if (dst < src)
+		swap(src, dst);
 
-	hash = jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
+	hash = jhash_3words(src, dst, t->uports.v32, info->hashrnd);
 	hash = hash ^ (t->proto & info->proto_mask);
 
 	return (((u64)hash * info->hmodulus) >> 32) + info->hoffset;
@@ -126,11 +143,7 @@ hmark_set_tuple_ports(const struct sk_buff *skb, unsigned int nhoff,
 	if (skb_copy_bits(skb, nhoff, &t->uports, sizeof(t->uports)) < 0)
 		return;
 
-	t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
-			info->port_set.v32;
-
-	if (t->uports.p16.dst < t->uports.p16.src)
-		swap(t->uports.p16.dst, t->uports.p16.src);
+	hmark_swap_ports(&t->uports, info);
 }
 
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
@@ -178,8 +191,8 @@ hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
 			return -1;
 	}
 noicmp:
-	t->src = hmark_addr6_mask(ip6->saddr.s6_addr32, info->src_mask.all);
-	t->dst = hmark_addr6_mask(ip6->daddr.s6_addr32, info->dst_mask.all);
+	t->src = hmark_addr6_mask(ip6->saddr.s6_addr32, info->src_mask.ip6);
+	t->dst = hmark_addr6_mask(ip6->daddr.s6_addr32, info->dst_mask.ip6);
 
 	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
 		return 0;
@@ -255,11 +268,8 @@ hmark_pkt_set_htuple_ipv4(const struct sk_buff *skb, struct hmark_tuple *t,
 		}
 	}
 
-	t->src = (__force u32) ip->saddr;
-	t->dst = (__force u32) ip->daddr;
-
-	t->src &= info->src_mask.ip;
-	t->dst &= info->dst_mask.ip;
+	t->src = ip->saddr & info->src_mask.ip;
+	t->dst = ip->daddr & info->dst_mask.ip;
 
 	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
 		return 0;
-- 
1.7.10

