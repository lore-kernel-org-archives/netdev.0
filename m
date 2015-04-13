From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/21] netfilter: nf_tables: switch registers to 32 bit addressing
Date: Mon, 13 Apr 2015 21:29:51 +0200
Message-ID: <1428953401-4838-13-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39699 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589AbbDMT0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:26:00 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Switch the nf_tables registers from 128 bit addressing to 32 bit
addressing to support so called concatenations, where multiple values
can be concatenated over multiple registers for O(1) exact matches of
multiple dimensions using sets.

The old register values are mapped to areas of 128 bits for compatibility.
When dumping register numbers, values are expressed using the old values
if they refer to the beginning of a 128 bit area for compatibility.

To support concatenations, register loads of less than a full 32 bit
value need to be padded. This mainly affects the payload and exthdr
expressions, which both unconditionally zero the last word before
copying the data.

Userspace fully passes the testsuite using both old and new register
addressing.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |   13 +++----
 include/uapi/linux/netfilter/nf_tables.h |   31 ++++++++++++++++-
 net/bridge/netfilter/nft_meta_bridge.c   |    2 +-
 net/ipv4/netfilter/nft_redir_ipv4.c      |    4 +--
 net/ipv6/netfilter/nft_redir_ipv6.c      |    4 +--
 net/netfilter/nf_tables_api.c            |   54 +++++++++++++++++++++++-------
 net/netfilter/nf_tables_core.c           |    5 +--
 net/netfilter/nft_bitwise.c              |    4 +--
 net/netfilter/nft_byteorder.c            |    4 +--
 net/netfilter/nft_ct.c                   |    4 +--
 net/netfilter/nft_exthdr.c               |    3 +-
 net/netfilter/nft_immediate.c            |    2 +-
 net/netfilter/nft_lookup.c               |    2 +-
 net/netfilter/nft_meta.c                 |    7 ++--
 net/netfilter/nft_nat.c                  |   16 ++++-----
 net/netfilter/nft_payload.c              |    3 +-
 16 files changed, 110 insertions(+), 48 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f8f27a4..1f9b848 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -64,17 +64,15 @@ struct nft_data {
  */
 struct nft_regs {
 	union {
-		struct nft_data 	data[NFT_REG_MAX + 1];
+		u32			data[20];
 		struct nft_verdict	verdict;
 	};
 };
 
-static inline void nft_data_copy(struct nft_data *dst,
-				 const struct nft_data *src)
+static inline void nft_data_copy(u32 *dst, const struct nft_data *src,
+				 unsigned int len)
 {
-	BUILD_BUG_ON(__alignof__(*dst) != __alignof__(u64));
-	*(u64 *)&dst->data[0] = *(u64 *)&src->data[0];
-	*(u64 *)&dst->data[2] = *(u64 *)&src->data[2];
+	memcpy(dst, src, len);
 }
 
 static inline void nft_data_debug(const struct nft_data *data)
@@ -502,8 +500,7 @@ static inline struct nft_set_ext *nft_set_elem_ext(const struct nft_set *set,
 
 void *nft_set_elem_init(const struct nft_set *set,
 			const struct nft_set_ext_tmpl *tmpl,
-			const struct nft_data *key,
-			const struct nft_data *data,
+			const u32 *key, const u32 *data,
 			u64 timeout, gfp_t gfp);
 void nft_set_elem_destroy(const struct nft_set *set, void *elem);
 
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 05ee1e0..4221a6c 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -5,16 +5,45 @@
 #define NFT_CHAIN_MAXNAMELEN	32
 #define NFT_USERDATA_MAXLEN	256
 
+/**
+ * enum nft_registers - nf_tables registers
+ *
+ * nf_tables used to have five registers: a verdict register and four data
+ * registers of size 16. The data registers have been changed to 16 registers
+ * of size 4. For compatibility reasons, the NFT_REG_[1-4] registers still
+ * map to areas of size 16, the 4 byte registers are addressed using
+ * NFT_REG32_00 - NFT_REG32_15.
+ */
 enum nft_registers {
 	NFT_REG_VERDICT,
 	NFT_REG_1,
 	NFT_REG_2,
 	NFT_REG_3,
 	NFT_REG_4,
-	__NFT_REG_MAX
+	__NFT_REG_MAX,
+
+	NFT_REG32_00	= 8,
+	MFT_REG32_01,
+	NFT_REG32_02,
+	NFT_REG32_03,
+	NFT_REG32_04,
+	NFT_REG32_05,
+	NFT_REG32_06,
+	NFT_REG32_07,
+	NFT_REG32_08,
+	NFT_REG32_09,
+	NFT_REG32_10,
+	NFT_REG32_11,
+	NFT_REG32_12,
+	NFT_REG32_13,
+	NFT_REG32_14,
+	NFT_REG32_15,
 };
 #define NFT_REG_MAX	(__NFT_REG_MAX - 1)
 
+#define NFT_REG_SIZE	16
+#define NFT_REG32_SIZE	4
+
 /**
  * enum nft_verdicts - nf_tables internal verdicts
  *
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 99dab70..a21269b 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -24,7 +24,7 @@ static void nft_meta_bridge_get_eval(const struct nft_expr *expr,
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct net_device *in = pkt->in, *out = pkt->out;
-	u32 *dest = &regs->data[priv->dreg].data[0];
+	u32 *dest = &regs->data[priv->dreg];
 	const struct net_bridge_port *p;
 
 	switch (priv->key) {
diff --git a/net/ipv4/netfilter/nft_redir_ipv4.c b/net/ipv4/netfilter/nft_redir_ipv4.c
index 312cf6f..d8d795d 100644
--- a/net/ipv4/netfilter/nft_redir_ipv4.c
+++ b/net/ipv4/netfilter/nft_redir_ipv4.c
@@ -27,9 +27,9 @@ static void nft_redir_ipv4_eval(const struct nft_expr *expr,
 	memset(&mr, 0, sizeof(mr));
 	if (priv->sreg_proto_min) {
 		mr.range[0].min.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_min];
 		mr.range[0].max.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_max];
 		mr.range[0].flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
diff --git a/net/ipv6/netfilter/nft_redir_ipv6.c b/net/ipv6/netfilter/nft_redir_ipv6.c
index 0eed774..effd393 100644
--- a/net/ipv6/netfilter/nft_redir_ipv6.c
+++ b/net/ipv6/netfilter/nft_redir_ipv6.c
@@ -27,9 +27,9 @@ static void nft_redir_ipv6_eval(const struct nft_expr *expr,
 	memset(&range, 0, sizeof(range));
 	if (priv->sreg_proto_min) {
 		range.min_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_min],
 		range.max_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_max],
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a25fd19..03faf76 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3201,8 +3201,7 @@ static struct nft_trans *nft_trans_elem_alloc(struct nft_ctx *ctx,
 
 void *nft_set_elem_init(const struct nft_set *set,
 			const struct nft_set_ext_tmpl *tmpl,
-			const struct nft_data *key,
-			const struct nft_data *data,
+			const u32 *key, const u32 *data,
 			u64 timeout, gfp_t gfp)
 {
 	struct nft_set_ext *ext;
@@ -3357,7 +3356,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	}
 
 	err = -ENOMEM;
-	elem.priv = nft_set_elem_init(set, &tmpl, &elem.key, &data,
+	elem.priv = nft_set_elem_init(set, &tmpl, elem.key.data, data.data,
 				      timeout, GFP_KERNEL);
 	if (elem.priv == NULL)
 		goto err3;
@@ -4122,14 +4121,47 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 	return 0;
 }
 
+/**
+ *	nft_parse_register - parse a register value from a netlink attribute
+ *
+ *	@attr: netlink attribute
+ *
+ *	Parse and translate a register value from a netlink attribute.
+ *	Registers used to be 128 bit wide, these register numbers will be
+ *	mapped to the corresponding 32 bit register numbers.
+ */
 unsigned int nft_parse_register(const struct nlattr *attr)
 {
-	return ntohl(nla_get_be32(attr));
+	unsigned int reg;
+
+	reg = ntohl(nla_get_be32(attr));
+	switch (reg) {
+	case NFT_REG_VERDICT...NFT_REG_4:
+		return reg * NFT_REG_SIZE / NFT_REG32_SIZE;
+	default:
+		return reg + NFT_REG_SIZE / NFT_REG32_SIZE - NFT_REG32_00;
+	}
 }
 EXPORT_SYMBOL_GPL(nft_parse_register);
 
+/**
+ *	nft_dump_register - dump a register value to a netlink attribute
+ *
+ *	@skb: socket buffer
+ *	@attr: attribute number
+ *	@reg: register number
+ *
+ *	Construct a netlink attribute containing the register number. For
+ *	compatibility reasons, register numbers being a multiple of 4 are
+ *	translated to the corresponding 128 bit register numbers.
+ */
 int nft_dump_register(struct sk_buff *skb, unsigned int attr, unsigned int reg)
 {
+	if (reg % (NFT_REG_SIZE / NFT_REG32_SIZE) == 0)
+		reg = reg / (NFT_REG_SIZE / NFT_REG32_SIZE);
+	else
+		reg = reg - NFT_REG_SIZE / NFT_REG32_SIZE + NFT_REG32_00;
+
 	return nla_put_be32(skb, attr, htonl(reg));
 }
 EXPORT_SYMBOL_GPL(nft_dump_register);
@@ -4145,14 +4177,13 @@ EXPORT_SYMBOL_GPL(nft_dump_register);
  */
 int nft_validate_register_load(enum nft_registers reg, unsigned int len)
 {
-	if (reg <= NFT_REG_VERDICT)
+	if (reg < NFT_REG_1 * NFT_REG_SIZE / NFT_REG32_SIZE)
 		return -EINVAL;
-	if (reg > NFT_REG_MAX)
-		return -ERANGE;
 	if (len == 0)
 		return -EINVAL;
-	if (len > FIELD_SIZEOF(struct nft_data, data))
+	if (reg * NFT_REG32_SIZE + len > FIELD_SIZEOF(struct nft_regs, data))
 		return -ERANGE;
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nft_validate_register_load);
@@ -4200,13 +4231,12 @@ int nft_validate_register_store(const struct nft_ctx *ctx,
 
 		return 0;
 	default:
-		if (reg < NFT_REG_1)
+		if (reg < NFT_REG_1 * NFT_REG_SIZE / NFT_REG32_SIZE)
 			return -EINVAL;
-		if (reg > NFT_REG_MAX)
-			return -ERANGE;
 		if (len == 0)
 			return -EINVAL;
-		if (len > FIELD_SIZEOF(struct nft_data, data))
+		if (reg * NFT_REG32_SIZE + len >
+		    FIELD_SIZEOF(struct nft_regs, data))
 			return -ERANGE;
 
 		if (data != NULL && type != NFT_DATA_VALUE)
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 5ef07d1..f153b07 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -70,7 +70,7 @@ static void nft_cmp_fast_eval(const struct nft_expr *expr,
 	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
 	u32 mask = nft_cmp_fast_mask(priv->len);
 
-	if ((regs->data[priv->sreg].data[0] & mask) == priv->data)
+	if ((regs->data[priv->sreg] & mask) == priv->data)
 		return;
 	regs->verdict.code = NFT_BREAK;
 }
@@ -81,7 +81,7 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
-	u32 *dest = &regs->data[priv->dreg].data[0];
+	u32 *dest = &regs->data[priv->dreg];
 	unsigned char *ptr;
 
 	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
@@ -94,6 +94,7 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 	if (unlikely(ptr + priv->len >= skb_tail_pointer(skb)))
 		return false;
 
+	*dest = 0;
 	if (priv->len == 2)
 		*(u16 *)dest = *(u16 *)ptr;
 	else if (priv->len == 4)
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index aa11470..f1a9be2 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -30,8 +30,8 @@ static void nft_bitwise_eval(const struct nft_expr *expr,
 			     const struct nft_pktinfo *pkt)
 {
 	const struct nft_bitwise *priv = nft_expr_priv(expr);
-	const u32  *src = &regs->data[priv->sreg].data[0];
-	u32 *dst = &regs->data[priv->dreg].data[0];
+	const u32 *src = &regs->data[priv->sreg];
+	u32 *dst = &regs->data[priv->dreg];
 	unsigned int i;
 
 	for (i = 0; i < DIV_ROUND_UP(priv->len, 4); i++)
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index 2ee3e57..fde5145 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -30,8 +30,8 @@ static void nft_byteorder_eval(const struct nft_expr *expr,
 			       const struct nft_pktinfo *pkt)
 {
 	const struct nft_byteorder *priv = nft_expr_priv(expr);
-	u32 *src = &regs->data[priv->sreg].data[0];
-	u32 *dst = &regs->data[priv->dreg].data[0];
+	u32 *src = &regs->data[priv->sreg];
+	u32 *dst = &regs->data[priv->dreg];
 	union { u32 u32; u16 u16; } *s, *d;
 	unsigned int i;
 
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index fab8e75..8cbca34 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -35,7 +35,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 			    const struct nft_pktinfo *pkt)
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
-	u32 *dest = &regs->data[priv->dreg].data[0];
+	u32 *dest = &regs->data[priv->dreg];
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn *ct;
 	const struct nf_conn_help *help;
@@ -156,7 +156,7 @@ static void nft_ct_set_eval(const struct nft_expr *expr,
 	const struct nft_ct *priv = nft_expr_priv(expr);
 	struct sk_buff *skb = pkt->skb;
 #ifdef CONFIG_NF_CONNTRACK_MARK
-	u32 value = regs->data[priv->sreg].data[0];
+	u32 value = regs->data[priv->sreg];
 #endif
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 098ffee..ba7aed1 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -30,7 +30,7 @@ static void nft_exthdr_eval(const struct nft_expr *expr,
 			    const struct nft_pktinfo *pkt)
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
-	u32 *dest = &regs->data[priv->dreg].data[0];
+	u32 *dest = &regs->data[priv->dreg];
 	unsigned int offset = 0;
 	int err;
 
@@ -39,6 +39,7 @@ static void nft_exthdr_eval(const struct nft_expr *expr,
 		goto err;
 	offset += priv->offset;
 
+	dest[priv->len / NFT_REG32_SIZE] = 0;
 	if (skb_copy_bits(pkt->skb, offset, dest, priv->len) < 0)
 		goto err;
 	return;
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 0682f60..1e8e412 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -29,7 +29,7 @@ static void nft_immediate_eval(const struct nft_expr *expr,
 {
 	const struct nft_immediate_expr *priv = nft_expr_priv(expr);
 
-	nft_data_copy(&regs->data[priv->dreg], &priv->data);
+	nft_data_copy(&regs->data[priv->dreg], &priv->data, priv->dlen);
 }
 
 static const struct nla_policy nft_immediate_policy[NFTA_IMMEDIATE_MAX + 1] = {
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index fc7afff..ba14662 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -36,7 +36,7 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 	if (set->ops->lookup(set, &regs->data[priv->sreg], &ext)) {
 		if (set->flags & NFT_SET_MAP)
 			nft_data_copy(&regs->data[priv->dreg],
-				      nft_set_ext_data(ext));
+				      nft_set_ext_data(ext), set->dlen);
 		return;
 	}
 	regs->verdict.code = NFT_BREAK;
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 5f744eb..52561e1 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -31,13 +31,14 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 	const struct nft_meta *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
 	const struct net_device *in = pkt->in, *out = pkt->out;
-	u32 *dest = &regs->data[priv->dreg].data[0];
+	u32 *dest = &regs->data[priv->dreg];
 
 	switch (priv->key) {
 	case NFT_META_LEN:
 		*dest = skb->len;
 		break;
 	case NFT_META_PROTOCOL:
+		*dest = 0;
 		*(__be16 *)dest = skb->protocol;
 		break;
 	case NFT_META_NFPROTO:
@@ -75,11 +76,13 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 	case NFT_META_IIFTYPE:
 		if (in == NULL)
 			goto err;
+		*dest = 0;
 		*(u16 *)dest = in->type;
 		break;
 	case NFT_META_OIFTYPE:
 		if (out == NULL)
 			goto err;
+		*dest = 0;
 		*(u16 *)dest = out->type;
 		break;
 	case NFT_META_SKUID:
@@ -185,7 +188,7 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 {
 	const struct nft_meta *meta = nft_expr_priv(expr);
 	struct sk_buff *skb = pkt->skb;
-	u32 value = regs->data[meta->sreg].data[0];
+	u32 value = regs->data[meta->sreg];
 
 	switch (meta->key) {
 	case NFT_META_MARK:
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index 065cbda..ee2d717 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -49,26 +49,26 @@ static void nft_nat_eval(const struct nft_expr *expr,
 	if (priv->sreg_addr_min) {
 		if (priv->family == AF_INET) {
 			range.min_addr.ip = (__force __be32)
-					regs->data[priv->sreg_addr_min].data[0];
+					regs->data[priv->sreg_addr_min];
 			range.max_addr.ip = (__force __be32)
-					regs->data[priv->sreg_addr_max].data[0];
+					regs->data[priv->sreg_addr_max];
 
 		} else {
 			memcpy(range.min_addr.ip6,
-			       &regs->data[priv->sreg_addr_min].data,
-			       sizeof(struct nft_data));
+			       &regs->data[priv->sreg_addr_min],
+			       sizeof(range.min_addr.ip6));
 			memcpy(range.max_addr.ip6,
-			       &regs->data[priv->sreg_addr_max].data,
-			       sizeof(struct nft_data));
+			       &regs->data[priv->sreg_addr_max],
+			       sizeof(range.max_addr.ip6));
 		}
 		range.flags |= NF_NAT_RANGE_MAP_IPS;
 	}
 
 	if (priv->sreg_proto_min) {
 		range.min_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_min].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_min];
 		range.max_proto.all =
-			*(__be16 *)&regs->data[priv->sreg_proto_max].data[0];
+			*(__be16 *)&regs->data[priv->sreg_proto_max];
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 5fa9973..94fb3b2 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -23,7 +23,7 @@ static void nft_payload_eval(const struct nft_expr *expr,
 {
 	const struct nft_payload *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
-	u32 *dest = &regs->data[priv->dreg].data[0];
+	u32 *dest = &regs->data[priv->dreg];
 	int offset;
 
 	switch (priv->base) {
@@ -43,6 +43,7 @@ static void nft_payload_eval(const struct nft_expr *expr,
 	}
 	offset += priv->offset;
 
+	dest[priv->len / NFT_REG32_SIZE] = 0;
 	if (skb_copy_bits(skb, offset, dest, priv->len) < 0)
 		goto err;
 	return;
-- 
1.7.10.4
