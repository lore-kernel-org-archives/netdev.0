From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 29/47] netfilter: exthdr: tcp option set support
Date: Mon,  4 Sep 2017 00:40:17 +0200
Message-ID: <1504478435-13160-7-git-send-email-pablo@netfilter.org>
References: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52730 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753294AbdICWk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:40:57 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CE0A8190F65
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B9D7EB5026
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:30 +0200 (CEST)
In-Reply-To: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This allows setting 2 and 4 byte quantities in the tcp option space.
Main purpose is to allow native replacement for xt_TCPMSS to
work around pmtu blackholes.

Writes to kind and len are now allowed at the moment, it does not seem
useful to do this as it causes corruption of the tcp option space.

We can always lift this restriction later if a use-case appears.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |   4 +-
 net/netfilter/nft_exthdr.c               | 164 ++++++++++++++++++++++++++++++-
 2 files changed, 165 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index be25cf69295b..40fd199f7531 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -732,7 +732,8 @@ enum nft_exthdr_op {
  * @NFTA_EXTHDR_OFFSET: extension header offset (NLA_U32)
  * @NFTA_EXTHDR_LEN: extension header length (NLA_U32)
  * @NFTA_EXTHDR_FLAGS: extension header flags (NLA_U32)
- * @NFTA_EXTHDR_OP: option match type (NLA_U8)
+ * @NFTA_EXTHDR_OP: option match type (NLA_U32)
+ * @NFTA_EXTHDR_SREG: option match type (NLA_U32)
  */
 enum nft_exthdr_attributes {
 	NFTA_EXTHDR_UNSPEC,
@@ -742,6 +743,7 @@ enum nft_exthdr_attributes {
 	NFTA_EXTHDR_LEN,
 	NFTA_EXTHDR_FLAGS,
 	NFTA_EXTHDR_OP,
+	NFTA_EXTHDR_SREG,
 	__NFTA_EXTHDR_MAX
 };
 #define NFTA_EXTHDR_MAX		(__NFTA_EXTHDR_MAX - 1)
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index e3a6eebe7e0c..f5a0bf5e3bdd 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -8,6 +8,7 @@
  * Development of this code funded by Astaro AG (http://www.astaro.com/)
  */
 
+#include <asm/unaligned.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -23,6 +24,7 @@ struct nft_exthdr {
 	u8			len;
 	u8			op;
 	enum nft_registers	dreg:8;
+	enum nft_registers	sreg:8;
 	u8			flags;
 };
 
@@ -124,6 +126,88 @@ static void nft_exthdr_tcp_eval(const struct nft_expr *expr,
 		regs->verdict.code = NFT_BREAK;
 }
 
+static void nft_exthdr_tcp_set_eval(const struct nft_expr *expr,
+				    struct nft_regs *regs,
+				    const struct nft_pktinfo *pkt)
+{
+	u8 buff[sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE];
+	struct nft_exthdr *priv = nft_expr_priv(expr);
+	unsigned int i, optl, tcphdr_len, offset;
+	struct tcphdr *tcph;
+	u8 *opt;
+	u32 src;
+
+	tcph = nft_tcp_header_pointer(pkt, sizeof(buff), buff, &tcphdr_len);
+	if (!tcph)
+		return;
+
+	opt = (u8 *)tcph;
+	for (i = sizeof(*tcph); i < tcphdr_len - 1; i += optl) {
+		union {
+			u8 octet;
+			__be16 v16;
+			__be32 v32;
+		} old, new;
+
+		optl = optlen(opt, i);
+
+		if (priv->type != opt[i])
+			continue;
+
+		if (i + optl > tcphdr_len || priv->len + priv->offset > optl)
+			return;
+
+		if (!skb_make_writable(pkt->skb, pkt->xt.thoff + i + priv->len))
+			return;
+
+		tcph = nft_tcp_header_pointer(pkt, sizeof(buff), buff,
+					      &tcphdr_len);
+		if (!tcph)
+			return;
+
+		src = regs->data[priv->sreg];
+		offset = i + priv->offset;
+
+		switch (priv->len) {
+		case 2:
+			old.v16 = get_unaligned((u16 *)(opt + offset));
+			new.v16 = src;
+
+			switch (priv->type) {
+			case TCPOPT_MSS:
+				/* increase can cause connection to stall */
+				if (ntohs(old.v16) <= ntohs(new.v16))
+					return;
+			break;
+			}
+
+			if (old.v16 == new.v16)
+				return;
+
+			put_unaligned(new.v16, (u16*)(opt + offset));
+			inet_proto_csum_replace2(&tcph->check, pkt->skb,
+						 old.v16, new.v16, false);
+			break;
+		case 4:
+			new.v32 = src;
+			old.v32 = get_unaligned((u32 *)(opt + offset));
+
+			if (old.v32 == new.v32)
+				return;
+
+			put_unaligned(new.v32, (u32*)(opt + offset));
+			inet_proto_csum_replace4(&tcph->check, pkt->skb,
+						 old.v32, new.v32, false);
+			break;
+		default:
+			WARN_ON_ONCE(1);
+			break;
+		}
+
+		return;
+	}
+}
+
 static const struct nla_policy nft_exthdr_policy[NFTA_EXTHDR_MAX + 1] = {
 	[NFTA_EXTHDR_DREG]		= { .type = NLA_U32 },
 	[NFTA_EXTHDR_TYPE]		= { .type = NLA_U8 },
@@ -180,6 +264,55 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 					   NFT_DATA_VALUE, priv->len);
 }
 
+static int nft_exthdr_tcp_set_init(const struct nft_ctx *ctx,
+				   const struct nft_expr *expr,
+				   const struct nlattr * const tb[])
+{
+	struct nft_exthdr *priv = nft_expr_priv(expr);
+	u32 offset, len, flags = 0, op = NFT_EXTHDR_OP_IPV6;
+	int err;
+
+	if (!tb[NFTA_EXTHDR_SREG] ||
+	    !tb[NFTA_EXTHDR_TYPE] ||
+	    !tb[NFTA_EXTHDR_OFFSET] ||
+	    !tb[NFTA_EXTHDR_LEN])
+		return -EINVAL;
+
+	if (tb[NFTA_EXTHDR_DREG] || tb[NFTA_EXTHDR_FLAGS])
+		return -EINVAL;
+
+	err = nft_parse_u32_check(tb[NFTA_EXTHDR_OFFSET], U8_MAX, &offset);
+	if (err < 0)
+		return err;
+
+	err = nft_parse_u32_check(tb[NFTA_EXTHDR_LEN], U8_MAX, &len);
+	if (err < 0)
+		return err;
+
+	if (offset < 2)
+		return -EOPNOTSUPP;
+
+	switch (len) {
+	case 2: break;
+	case 4: break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	err = nft_parse_u32_check(tb[NFTA_EXTHDR_OP], U8_MAX, &op);
+	if (err < 0)
+		return err;
+
+	priv->type   = nla_get_u8(tb[NFTA_EXTHDR_TYPE]);
+	priv->offset = offset;
+	priv->len    = len;
+	priv->sreg   = nft_parse_register(tb[NFTA_EXTHDR_SREG]);
+	priv->flags  = flags;
+	priv->op     = op;
+
+	return nft_validate_register_load(priv->sreg, priv->len);
+}
+
 static int nft_exthdr_dump_common(struct sk_buff *skb, const struct nft_exthdr *priv)
 {
 	if (nla_put_u8(skb, NFTA_EXTHDR_TYPE, priv->type))
@@ -208,6 +341,16 @@ static int nft_exthdr_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return nft_exthdr_dump_common(skb, priv);
 }
 
+static int nft_exthdr_dump_set(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_exthdr *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_EXTHDR_SREG, priv->sreg))
+		return -1;
+
+	return nft_exthdr_dump_common(skb, priv);
+}
+
 static struct nft_expr_type nft_exthdr_type;
 static const struct nft_expr_ops nft_exthdr_ipv6_ops = {
 	.type		= &nft_exthdr_type,
@@ -225,6 +368,14 @@ static const struct nft_expr_ops nft_exthdr_tcp_ops = {
 	.dump		= nft_exthdr_dump,
 };
 
+static const struct nft_expr_ops nft_exthdr_tcp_set_ops = {
+	.type		= &nft_exthdr_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_exthdr)),
+	.eval		= nft_exthdr_tcp_set_eval,
+	.init		= nft_exthdr_tcp_set_init,
+	.dump		= nft_exthdr_dump_set,
+};
+
 static const struct nft_expr_ops *
 nft_exthdr_select_ops(const struct nft_ctx *ctx,
 		      const struct nlattr * const tb[])
@@ -234,12 +385,21 @@ nft_exthdr_select_ops(const struct nft_ctx *ctx,
 	if (!tb[NFTA_EXTHDR_OP])
 		return &nft_exthdr_ipv6_ops;
 
+	if (tb[NFTA_EXTHDR_SREG] && tb[NFTA_EXTHDR_DREG])
+		return ERR_PTR(-EOPNOTSUPP);
+
 	op = ntohl(nla_get_u32(tb[NFTA_EXTHDR_OP]));
 	switch (op) {
 	case NFT_EXTHDR_OP_TCPOPT:
-		return &nft_exthdr_tcp_ops;
+		if (tb[NFTA_EXTHDR_SREG])
+			return &nft_exthdr_tcp_set_ops;
+		if (tb[NFTA_EXTHDR_DREG])
+			return &nft_exthdr_tcp_ops;
+		break;
 	case NFT_EXTHDR_OP_IPV6:
-		return &nft_exthdr_ipv6_ops;
+		if (tb[NFTA_EXTHDR_DREG])
+			return &nft_exthdr_ipv6_ops;
+		break;
 	}
 
 	return ERR_PTR(-EOPNOTSUPP);
-- 
2.1.4
