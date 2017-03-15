From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/10] netfilter: nf_tables: fix mismatch in big-endian system
Date: Wed, 15 Mar 2017 18:01:07 +0100
Message-ID: <1489597272-30347-6-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Currently, there are two different methods to store an u16 integer to
the u32 data register. For example:
  u32 *dest = &regs->data[priv->dreg];
  1. *dest = 0; *(u16 *) dest = val_u16;
  2. *dest = val_u16;

For method 1, the u16 value will be stored like this, either in
big-endian or little-endian system:
  0          15           31
  +-+-+-+-+-+-+-+-+-+-+-+-+
  |   Value   |     0     |
  +-+-+-+-+-+-+-+-+-+-+-+-+

For method 2, in little-endian system, the u16 value will be the same
as listed above. But in big-endian system, the u16 value will be stored
like this:
  0          15           31
  +-+-+-+-+-+-+-+-+-+-+-+-+
  |     0     |   Value   |
  +-+-+-+-+-+-+-+-+-+-+-+-+

So later we use "memcmp(&regs->data[priv->sreg], data, 2);" to do
compare in nft_cmp, nft_lookup expr ..., method 2 will get the wrong
result in big-endian system, as 0~15 bits will always be zero.

For the similar reason, when loading an u16 value from the u32 data
register, we should use "*(u16 *) sreg;" instead of "(u16)*sreg;",
the 2nd method will get the wrong value in the big-endian system.

So introduce some wrapper functions to store/load an u8 or u16
integer to/from the u32 data register, and use them in the right
place.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h   | 29 +++++++++++++++++++++++++++
 net/ipv4/netfilter/nft_masq_ipv4.c  |  8 ++++----
 net/ipv4/netfilter/nft_redir_ipv4.c |  8 ++++----
 net/ipv6/netfilter/nft_masq_ipv6.c  |  8 ++++----
 net/ipv6/netfilter/nft_redir_ipv6.c |  8 ++++----
 net/netfilter/nft_ct.c              | 18 +++++++++--------
 net/netfilter/nft_meta.c            | 40 +++++++++++++++++++------------------
 net/netfilter/nft_nat.c             |  8 ++++----
 8 files changed, 80 insertions(+), 47 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 2aa8a9d80fbe..70c5ca0c60b1 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -103,6 +103,35 @@ struct nft_regs {
 	};
 };
 
+/* Store/load an u16 or u8 integer to/from the u32 data register.
+ *
+ * Note, when using concatenations, register allocation happens at 32-bit
+ * level. So for store instruction, pad the rest part with zero to avoid
+ * garbage values.
+ */
+
+static inline void nft_reg_store16(u32 *dreg, u16 val)
+{
+	*dreg = 0;
+	*(u16 *)dreg = val;
+}
+
+static inline void nft_reg_store8(u32 *dreg, u8 val)
+{
+	*dreg = 0;
+	*(u8 *)dreg = val;
+}
+
+static inline u16 nft_reg_load16(u32 *sreg)
+{
+	return *(u16 *)sreg;
+}
+
+static inline u8 nft_reg_load8(u32 *sreg)
+{
+	return *(u8 *)sreg;
+}
+
 static inline void nft_data_copy(u32 *dst, const struct nft_data *src,
 				 unsigned int len)
 {
diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index a0ea8aad1bf1..f18677277119 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -26,10 +26,10 @@ static void nft_masq_ipv4_eval(const struct nft_expr *expr,
 	memset(&range, 0, sizeof(range));
 	range.flags = priv->flags;
 	if (priv->sreg_proto_min) {
-		range.min_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min];
-		range.max_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max];
+		range.min_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_min]);
+		range.max_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_max]);
 	}
 	regs->verdict.code = nf_nat_masquerade_ipv4(pkt->skb, nft_hook(pkt),
 						    &range, nft_out(pkt));
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index 1650ed23c15d..5120be1d3118 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -26,10 +26,10 @@ static void nft_redir_ipv4_eval(const struct nft_expr *expr,
 
 	memset(&mr, 0, sizeof(mr));
 	if (priv->sreg_proto_min) {
-		mr.range[0].min.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min];
-		mr.range[0].max.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max];
+		mr.range[0].min.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_min]);
+		mr.range[0].max.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_max]);
 		mr.range[0].flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
diff --git a/net/ipv6/netfilter/nft_masq_ipv6.c b/net/ipv6/netfilter/nft_masq_ipv6.c
index 6c5b5b1830a7..4146536e9c15 100644
--- a/net/ipv6/netfilter/nft_masq_ipv6.c
+++ b/net/ipv6/netfilter/nft_masq_ipv6.c
@@ -27,10 +27,10 @@ static void nft_masq_ipv6_eval(const struct nft_expr *expr,
 	memset(&range, 0, sizeof(range));
 	range.flags = priv->flags;
 	if (priv->sreg_proto_min) {
-		range.min_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min];
-		range.max_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max];
+		range.min_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_min]);
+		range.max_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_max]);
 	}
 	regs->verdict.code = nf_nat_masquerade_ipv6(pkt->skb, &range,
 						    nft_out(pkt));
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index f5ac080fc084..a27e424f690d 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -26,10 +26,10 @@ static void nft_redir_ipv6_eval(const struct nft_expr *expr,
 
 	memset(&range, 0, sizeof(range));
 	if (priv->sreg_proto_min) {
-		range.min_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min],
-		range.max_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max],
+		range.min_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_min]);
+		range.max_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_max]);
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index bf548a7a71ec..91585b5e5307 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -83,7 +83,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 
 	switch (priv->key) {
 	case NFT_CT_DIRECTION:
-		*dest = CTINFO2DIR(ctinfo);
+		nft_reg_store8(dest, CTINFO2DIR(ctinfo));
 		return;
 	case NFT_CT_STATUS:
 		*dest = ct->status;
@@ -151,20 +151,22 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		return;
 	}
 	case NFT_CT_L3PROTOCOL:
-		*dest = nf_ct_l3num(ct);
+		nft_reg_store8(dest, nf_ct_l3num(ct));
 		return;
 	case NFT_CT_PROTOCOL:
-		*dest = nf_ct_protonum(ct);
+		nft_reg_store8(dest, nf_ct_protonum(ct));
 		return;
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	case NFT_CT_ZONE: {
 		const struct nf_conntrack_zone *zone = nf_ct_zone(ct);
+		u16 zoneid;
 
 		if (priv->dir < IP_CT_DIR_MAX)
-			*dest = nf_ct_zone_id(zone, priv->dir);
+			zoneid = nf_ct_zone_id(zone, priv->dir);
 		else
-			*dest = zone->id;
+			zoneid = zone->id;
 
+		nft_reg_store16(dest, zoneid);
 		return;
 	}
 #endif
@@ -183,10 +185,10 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		       nf_ct_l3num(ct) == NFPROTO_IPV4 ? 4 : 16);
 		return;
 	case NFT_CT_PROTO_SRC:
-		*dest = (__force __u16)tuple->src.u.all;
+		nft_reg_store16(dest, (__force u16)tuple->src.u.all);
 		return;
 	case NFT_CT_PROTO_DST:
-		*dest = (__force __u16)tuple->dst.u.all;
+		nft_reg_store16(dest, (__force u16)tuple->dst.u.all);
 		return;
 	default:
 		break;
@@ -205,7 +207,7 @@ static void nft_ct_set_zone_eval(const struct nft_expr *expr,
 	const struct nft_ct *priv = nft_expr_priv(expr);
 	struct sk_buff *skb = pkt->skb;
 	enum ip_conntrack_info ctinfo;
-	u16 value = regs->data[priv->sreg];
+	u16 value = nft_reg_load16(&regs->data[priv->sreg]);
 	struct nf_conn *ct;
 
 	ct = nf_ct_get(skb, &ctinfo);
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index e1f5ca9b423b..7b60e01f38ff 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -45,16 +45,15 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		*dest = skb->len;
 		break;
 	case NFT_META_PROTOCOL:
-		*dest = 0;
-		*(__be16 *)dest = skb->protocol;
+		nft_reg_store16(dest, (__force u16)skb->protocol);
 		break;
 	case NFT_META_NFPROTO:
-		*dest = nft_pf(pkt);
+		nft_reg_store8(dest, nft_pf(pkt));
 		break;
 	case NFT_META_L4PROTO:
 		if (!pkt->tprot_set)
 			goto err;
-		*dest = pkt->tprot;
+		nft_reg_store8(dest, pkt->tprot);
 		break;
 	case NFT_META_PRIORITY:
 		*dest = skb->priority;
@@ -85,14 +84,12 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 	case NFT_META_IIFTYPE:
 		if (in == NULL)
 			goto err;
-		*dest = 0;
-		*(u16 *)dest = in->type;
+		nft_reg_store16(dest, in->type);
 		break;
 	case NFT_META_OIFTYPE:
 		if (out == NULL)
 			goto err;
-		*dest = 0;
-		*(u16 *)dest = out->type;
+		nft_reg_store16(dest, out->type);
 		break;
 	case NFT_META_SKUID:
 		sk = skb_to_full_sk(skb);
@@ -142,19 +139,19 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 #endif
 	case NFT_META_PKTTYPE:
 		if (skb->pkt_type != PACKET_LOOPBACK) {
-			*dest = skb->pkt_type;
+			nft_reg_store8(dest, skb->pkt_type);
 			break;
 		}
 
 		switch (nft_pf(pkt)) {
 		case NFPROTO_IPV4:
 			if (ipv4_is_multicast(ip_hdr(skb)->daddr))
-				*dest = PACKET_MULTICAST;
+				nft_reg_store8(dest, PACKET_MULTICAST);
 			else
-				*dest = PACKET_BROADCAST;
+				nft_reg_store8(dest, PACKET_BROADCAST);
 			break;
 		case NFPROTO_IPV6:
-			*dest = PACKET_MULTICAST;
+			nft_reg_store8(dest, PACKET_MULTICAST);
 			break;
 		case NFPROTO_NETDEV:
 			switch (skb->protocol) {
@@ -168,14 +165,14 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 					goto err;
 
 				if (ipv4_is_multicast(iph->daddr))
-					*dest = PACKET_MULTICAST;
+					nft_reg_store8(dest, PACKET_MULTICAST);
 				else
-					*dest = PACKET_BROADCAST;
+					nft_reg_store8(dest, PACKET_BROADCAST);
 
 				break;
 			}
 			case htons(ETH_P_IPV6):
-				*dest = PACKET_MULTICAST;
+				nft_reg_store8(dest, PACKET_MULTICAST);
 				break;
 			default:
 				WARN_ON_ONCE(1);
@@ -230,7 +227,9 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 {
 	const struct nft_meta *meta = nft_expr_priv(expr);
 	struct sk_buff *skb = pkt->skb;
-	u32 value = regs->data[meta->sreg];
+	u32 *sreg = &regs->data[meta->sreg];
+	u32 value = *sreg;
+	u8 pkt_type;
 
 	switch (meta->key) {
 	case NFT_META_MARK:
@@ -240,9 +239,12 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 		skb->priority = value;
 		break;
 	case NFT_META_PKTTYPE:
-		if (skb->pkt_type != value &&
-		    skb_pkt_type_ok(value) && skb_pkt_type_ok(skb->pkt_type))
-			skb->pkt_type = value;
+		pkt_type = nft_reg_load8(sreg);
+
+		if (skb->pkt_type != pkt_type &&
+		    skb_pkt_type_ok(pkt_type) &&
+		    skb_pkt_type_ok(skb->pkt_type))
+			skb->pkt_type = pkt_type;
 		break;
 	case NFT_META_NFTRACE:
 		skb->nf_trace = !!value;
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index 19a7bf3236f9..439e0bd152a0 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -65,10 +65,10 @@ static void nft_nat_eval(const struct nft_expr *expr,
 	}
 
 	if (priv->sreg_proto_min) {
-		range.min_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min];
-		range.max_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max];
+		range.min_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_min]);
+		range.max_proto.all = (__force __be16)nft_reg_load16(
+			&regs->data[priv->sreg_proto_max]);
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
-- 
2.1.4

