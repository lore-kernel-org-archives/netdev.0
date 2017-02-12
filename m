From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/21] netfilter: nft_exthdr: add TCP option matching
Date: Sun, 12 Feb 2017 20:42:44 +0100
Message-ID: <1486928573-24773-13-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Manuel Messner <mm@skelett.io>

This patch implements the kernel side of the TCP option patch.

Signed-off-by: Manuel Messner <mm@skelett.io>
Reviewed-by: Florian Westphal <fw@strlen.de>
Acked-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  17 ++++-
 net/netfilter/Kconfig                    |   4 +-
 net/netfilter/nft_exthdr.c               | 119 +++++++++++++++++++++++++++----
 3 files changed, 124 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 3e60ed78c538..207951516ede 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -709,13 +709,27 @@ enum nft_exthdr_flags {
 };
 
 /**
- * enum nft_exthdr_attributes - nf_tables IPv6 extension header expression netlink attributes
+ * enum nft_exthdr_op - nf_tables match options
+ *
+ * @NFT_EXTHDR_OP_IPV6: match against ipv6 extension headers
+ * @NFT_EXTHDR_OP_TCP: match against tcp options
+ */
+enum nft_exthdr_op {
+	NFT_EXTHDR_OP_IPV6,
+	NFT_EXTHDR_OP_TCPOPT,
+	__NFT_EXTHDR_OP_MAX
+};
+#define NFT_EXTHDR_OP_MAX	(__NFT_EXTHDR_OP_MAX - 1)
+
+/**
+ * enum nft_exthdr_attributes - nf_tables extension header expression netlink attributes
  *
  * @NFTA_EXTHDR_DREG: destination register (NLA_U32: nft_registers)
  * @NFTA_EXTHDR_TYPE: extension header type (NLA_U8)
  * @NFTA_EXTHDR_OFFSET: extension header offset (NLA_U32)
  * @NFTA_EXTHDR_LEN: extension header length (NLA_U32)
  * @NFTA_EXTHDR_FLAGS: extension header flags (NLA_U32)
+ * @NFTA_EXTHDR_OP: option match type (NLA_U8)
  */
 enum nft_exthdr_attributes {
 	NFTA_EXTHDR_UNSPEC,
@@ -724,6 +738,7 @@ enum nft_exthdr_attributes {
 	NFTA_EXTHDR_OFFSET,
 	NFTA_EXTHDR_LEN,
 	NFTA_EXTHDR_FLAGS,
+	NFTA_EXTHDR_OP,
 	__NFTA_EXTHDR_MAX
 };
 #define NFTA_EXTHDR_MAX		(__NFTA_EXTHDR_MAX - 1)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ea479ed43373..9b28864cc36a 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -467,10 +467,10 @@ config NF_TABLES_NETDEV
 	  This option enables support for the "netdev" table.
 
 config NFT_EXTHDR
-	tristate "Netfilter nf_tables IPv6 exthdr module"
+	tristate "Netfilter nf_tables exthdr module"
 	help
 	  This option adds the "exthdr" expression that you can use to match
-	  IPv6 extension headers.
+	  IPv6 extension headers and tcp options.
 
 config NFT_META
 	tristate "Netfilter nf_tables meta module"
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index a89e5ab150db..c308920b194c 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -15,20 +15,29 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
-// FIXME:
-#include <net/ipv6.h>
+#include <net/tcp.h>
 
 struct nft_exthdr {
 	u8			type;
 	u8			offset;
 	u8			len;
+	u8			op;
 	enum nft_registers	dreg:8;
 	u8			flags;
 };
 
-static void nft_exthdr_eval(const struct nft_expr *expr,
-			    struct nft_regs *regs,
-			    const struct nft_pktinfo *pkt)
+static unsigned int optlen(const u8 *opt, unsigned int offset)
+{
+	/* Beware zero-length options: make finite progress */
+	if (opt[offset] <= TCPOPT_NOP || opt[offset + 1] == 0)
+		return 1;
+	else
+		return opt[offset + 1];
+}
+
+static void nft_exthdr_ipv6_eval(const struct nft_expr *expr,
+				 struct nft_regs *regs,
+				 const struct nft_pktinfo *pkt)
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
 	u32 *dest = &regs->data[priv->dreg];
@@ -52,6 +61,53 @@ static void nft_exthdr_eval(const struct nft_expr *expr,
 	regs->verdict.code = NFT_BREAK;
 }
 
+static void nft_exthdr_tcp_eval(const struct nft_expr *expr,
+				struct nft_regs *regs,
+				const struct nft_pktinfo *pkt)
+{
+	u8 buff[sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE];
+	struct nft_exthdr *priv = nft_expr_priv(expr);
+	unsigned int i, optl, tcphdr_len, offset;
+	u32 *dest = &regs->data[priv->dreg];
+	struct tcphdr *tcph;
+	u8 *opt;
+
+	if (!pkt->tprot_set || pkt->tprot != IPPROTO_TCP)
+		goto err;
+
+	tcph = skb_header_pointer(pkt->skb, pkt->xt.thoff, sizeof(*tcph), buff);
+	if (!tcph)
+		goto err;
+
+	tcphdr_len = __tcp_hdrlen(tcph);
+	if (tcphdr_len < sizeof(*tcph))
+		goto err;
+
+	tcph = skb_header_pointer(pkt->skb, pkt->xt.thoff, tcphdr_len, buff);
+	if (!tcph)
+		goto err;
+
+	opt = (u8 *)tcph;
+	for (i = sizeof(*tcph); i < tcphdr_len - 1; i += optl) {
+		optl = optlen(opt, i);
+
+		if (priv->type != opt[i])
+			continue;
+
+		if (i + optl > tcphdr_len || priv->len + priv->offset > optl)
+			goto err;
+
+		offset = i + priv->offset;
+		dest[priv->len / NFT_REG32_SIZE] = 0;
+		memcpy(dest, opt + offset, priv->len);
+
+		return;
+	}
+
+err:
+	regs->verdict.code = NFT_BREAK;
+}
+
 static const struct nla_policy nft_exthdr_policy[NFTA_EXTHDR_MAX + 1] = {
 	[NFTA_EXTHDR_DREG]		= { .type = NLA_U32 },
 	[NFTA_EXTHDR_TYPE]		= { .type = NLA_U8 },
@@ -65,13 +121,13 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
-	u32 offset, len, flags = 0;
+	u32 offset, len, flags = 0, op = NFT_EXTHDR_OP_IPV6;
 	int err;
 
-	if (tb[NFTA_EXTHDR_DREG] == NULL ||
-	    tb[NFTA_EXTHDR_TYPE] == NULL ||
-	    tb[NFTA_EXTHDR_OFFSET] == NULL ||
-	    tb[NFTA_EXTHDR_LEN] == NULL)
+	if (!tb[NFTA_EXTHDR_DREG] ||
+	    !tb[NFTA_EXTHDR_TYPE] ||
+	    !tb[NFTA_EXTHDR_OFFSET] ||
+	    !tb[NFTA_EXTHDR_LEN])
 		return -EINVAL;
 
 	err = nft_parse_u32_check(tb[NFTA_EXTHDR_OFFSET], U8_MAX, &offset);
@@ -91,11 +147,18 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 			return -EINVAL;
 	}
 
+	if (tb[NFTA_EXTHDR_OP]) {
+		err = nft_parse_u32_check(tb[NFTA_EXTHDR_OP], U8_MAX, &op);
+		if (err < 0)
+			return err;
+	}
+
 	priv->type   = nla_get_u8(tb[NFTA_EXTHDR_TYPE]);
 	priv->offset = offset;
 	priv->len    = len;
 	priv->dreg   = nft_parse_register(tb[NFTA_EXTHDR_DREG]);
 	priv->flags  = flags;
+	priv->op     = op;
 
 	return nft_validate_register_store(ctx, priv->dreg, NULL,
 					   NFT_DATA_VALUE, priv->len);
@@ -115,6 +178,8 @@ static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_EXTHDR_FLAGS, htonl(priv->flags)))
 		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_EXTHDR_OP, htonl(priv->op)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -122,17 +187,45 @@ static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr)
 }
 
 static struct nft_expr_type nft_exthdr_type;
-static const struct nft_expr_ops nft_exthdr_ops = {
+static const struct nft_expr_ops nft_exthdr_ipv6_ops = {
+	.type		= &nft_exthdr_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_exthdr)),
+	.eval		= nft_exthdr_ipv6_eval,
+	.init		= nft_exthdr_init,
+	.dump		= nft_exthdr_dump,
+};
+
+static const struct nft_expr_ops nft_exthdr_tcp_ops = {
 	.type		= &nft_exthdr_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_exthdr)),
-	.eval		= nft_exthdr_eval,
+	.eval		= nft_exthdr_tcp_eval,
 	.init		= nft_exthdr_init,
 	.dump		= nft_exthdr_dump,
 };
 
+static const struct nft_expr_ops *
+nft_exthdr_select_ops(const struct nft_ctx *ctx,
+		      const struct nlattr * const tb[])
+{
+	u32 op;
+
+	if (!tb[NFTA_EXTHDR_OP])
+		return &nft_exthdr_ipv6_ops;
+
+	op = ntohl(nla_get_u32(tb[NFTA_EXTHDR_OP]));
+	switch (op) {
+	case NFT_EXTHDR_OP_TCPOPT:
+		return &nft_exthdr_tcp_ops;
+	case NFT_EXTHDR_OP_IPV6:
+		return &nft_exthdr_ipv6_ops;
+	}
+
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
 static struct nft_expr_type nft_exthdr_type __read_mostly = {
 	.name		= "exthdr",
-	.ops		= &nft_exthdr_ops,
+	.select_ops	= &nft_exthdr_select_ops,
 	.policy		= nft_exthdr_policy,
 	.maxattr	= NFTA_EXTHDR_MAX,
 	.owner		= THIS_MODULE,
-- 
2.1.4

