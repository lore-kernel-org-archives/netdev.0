From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 29/53] netfilter: nft_queue: add _SREG_QNUM attr to select the queue number
Date: Mon, 26 Sep 2016 01:06:39 +0200
Message-ID: <1474844823-2026-30-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

Currently, the user can specify the queue numbers by _QUEUE_NUM and
_QUEUE_TOTAL attributes, this is enough in most situations.

But acctually, it is not very flexible, for example:
  tcp dport 80 mapped to queue0
  tcp dport 81 mapped to queue1
  tcp dport 82 mapped to queue2
In order to do this thing, we must add 3 nft rules, and more
mapping meant more rules ...

So take one register to select the queue number, then we can add one
simple rule to mapping queues, maybe like this:
  queue num tcp dport map { 80:0, 81:1, 82:2 ... }

Florian Westphal also proposed wider usage scenarios:
  queue num jhash ip saddr . ip daddr mod ...
  queue num meta cpu ...
  queue num meta mark ...

The last point is how to load a queue number from sreg, although we can
use *(u16*)&regs->data[reg] to load the queue number, just like nat expr
to load its l4port do.

But we will cooperate with hash expr, meta cpu, meta mark expr and so on.
They all store the result to u32 type, so cast it to u16 pointer and
dereference it will generate wrong result in the big endian system.

So just keep it simple, we treat queue number as u32 type, although u16
type is already enough.

Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |   2 +
 net/netfilter/nft_queue.c                | 102 +++++++++++++++++++++++++++----
 2 files changed, 92 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index bcfb892ff148..1cf41dd838b2 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -894,12 +894,14 @@ enum nft_log_attributes {
  * @NFTA_QUEUE_NUM: netlink queue to send messages to (NLA_U16)
  * @NFTA_QUEUE_TOTAL: number of queues to load balance packets on (NLA_U16)
  * @NFTA_QUEUE_FLAGS: various flags (NLA_U16)
+ * @NFTA_QUEUE_SREG_QNUM: source register of queue number (NLA_U32: nft_registers)
  */
 enum nft_queue_attributes {
 	NFTA_QUEUE_UNSPEC,
 	NFTA_QUEUE_NUM,
 	NFTA_QUEUE_TOTAL,
 	NFTA_QUEUE_FLAGS,
+	NFTA_QUEUE_SREG_QNUM,
 	__NFTA_QUEUE_MAX
 };
 #define NFTA_QUEUE_MAX		(__NFTA_QUEUE_MAX - 1)
diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index d16d59959ff6..393d359a1889 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -22,9 +22,10 @@
 static u32 jhash_initval __read_mostly;
 
 struct nft_queue {
-	u16	queuenum;
-	u16	queues_total;
-	u16	flags;
+	enum nft_registers	sreg_qnum:8;
+	u16			queuenum;
+	u16			queues_total;
+	u16			flags;
 };
 
 static void nft_queue_eval(const struct nft_expr *expr,
@@ -54,26 +55,39 @@ static void nft_queue_eval(const struct nft_expr *expr,
 	regs->verdict.code = ret;
 }
 
+static void nft_queue_sreg_eval(const struct nft_expr *expr,
+				struct nft_regs *regs,
+				const struct nft_pktinfo *pkt)
+{
+	struct nft_queue *priv = nft_expr_priv(expr);
+	u32 queue, ret;
+
+	queue = regs->data[priv->sreg_qnum];
+
+	ret = NF_QUEUE_NR(queue);
+	if (priv->flags & NFT_QUEUE_FLAG_BYPASS)
+		ret |= NF_VERDICT_FLAG_QUEUE_BYPASS;
+
+	regs->verdict.code = ret;
+}
+
 static const struct nla_policy nft_queue_policy[NFTA_QUEUE_MAX + 1] = {
 	[NFTA_QUEUE_NUM]	= { .type = NLA_U16 },
 	[NFTA_QUEUE_TOTAL]	= { .type = NLA_U16 },
 	[NFTA_QUEUE_FLAGS]	= { .type = NLA_U16 },
+	[NFTA_QUEUE_SREG_QNUM]	= { .type = NLA_U32 },
 };
 
 static int nft_queue_init(const struct nft_ctx *ctx,
-			   const struct nft_expr *expr,
-			   const struct nlattr * const tb[])
+			  const struct nft_expr *expr,
+			  const struct nlattr * const tb[])
 {
 	struct nft_queue *priv = nft_expr_priv(expr);
 	u32 maxid;
 
-	if (tb[NFTA_QUEUE_NUM] == NULL)
-		return -EINVAL;
-
-	init_hashrandom(&jhash_initval);
 	priv->queuenum = ntohs(nla_get_be16(tb[NFTA_QUEUE_NUM]));
 
-	if (tb[NFTA_QUEUE_TOTAL] != NULL)
+	if (tb[NFTA_QUEUE_TOTAL])
 		priv->queues_total = ntohs(nla_get_be16(tb[NFTA_QUEUE_TOTAL]));
 	else
 		priv->queues_total = 1;
@@ -85,11 +99,34 @@ static int nft_queue_init(const struct nft_ctx *ctx,
 	if (maxid > U16_MAX)
 		return -ERANGE;
 
-	if (tb[NFTA_QUEUE_FLAGS] != NULL) {
+	if (tb[NFTA_QUEUE_FLAGS]) {
+		priv->flags = ntohs(nla_get_be16(tb[NFTA_QUEUE_FLAGS]));
+		if (priv->flags & ~NFT_QUEUE_FLAG_MASK)
+			return -EINVAL;
+	}
+	return 0;
+}
+
+static int nft_queue_sreg_init(const struct nft_ctx *ctx,
+			       const struct nft_expr *expr,
+			       const struct nlattr * const tb[])
+{
+	struct nft_queue *priv = nft_expr_priv(expr);
+	int err;
+
+	priv->sreg_qnum = nft_parse_register(tb[NFTA_QUEUE_SREG_QNUM]);
+	err = nft_validate_register_load(priv->sreg_qnum, sizeof(u32));
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_QUEUE_FLAGS]) {
 		priv->flags = ntohs(nla_get_be16(tb[NFTA_QUEUE_FLAGS]));
 		if (priv->flags & ~NFT_QUEUE_FLAG_MASK)
 			return -EINVAL;
+		if (priv->flags & NFT_QUEUE_FLAG_CPU_FANOUT)
+			return -EOPNOTSUPP;
 	}
+
 	return 0;
 }
 
@@ -108,6 +145,21 @@ nla_put_failure:
 	return -1;
 }
 
+static int
+nft_queue_sreg_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_queue *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_QUEUE_SREG_QNUM, priv->sreg_qnum) ||
+	    nla_put_be16(skb, NFTA_QUEUE_FLAGS, htons(priv->flags)))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
 static struct nft_expr_type nft_queue_type;
 static const struct nft_expr_ops nft_queue_ops = {
 	.type		= &nft_queue_type,
@@ -117,9 +169,35 @@ static const struct nft_expr_ops nft_queue_ops = {
 	.dump		= nft_queue_dump,
 };
 
+static const struct nft_expr_ops nft_queue_sreg_ops = {
+	.type		= &nft_queue_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_queue)),
+	.eval		= nft_queue_sreg_eval,
+	.init		= nft_queue_sreg_init,
+	.dump		= nft_queue_sreg_dump,
+};
+
+static const struct nft_expr_ops *
+nft_queue_select_ops(const struct nft_ctx *ctx,
+		     const struct nlattr * const tb[])
+{
+	if (tb[NFTA_QUEUE_NUM] && tb[NFTA_QUEUE_SREG_QNUM])
+		return ERR_PTR(-EINVAL);
+
+	init_hashrandom(&jhash_initval);
+
+	if (tb[NFTA_QUEUE_NUM])
+		return &nft_queue_ops;
+
+	if (tb[NFTA_QUEUE_SREG_QNUM])
+		return &nft_queue_sreg_ops;
+
+	return ERR_PTR(-EINVAL);
+}
+
 static struct nft_expr_type nft_queue_type __read_mostly = {
 	.name		= "queue",
-	.ops		= &nft_queue_ops,
+	.select_ops	= &nft_queue_select_ops,
 	.policy		= nft_queue_policy,
 	.maxattr	= NFTA_QUEUE_MAX,
 	.owner		= THIS_MODULE,
-- 
2.1.4

