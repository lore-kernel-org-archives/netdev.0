From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: nft_limit: add stateful object type
Date: Mon,  4 Sep 2017 22:11:06 +0200
Message-ID: <1504555874-4168-5-git-send-email-pablo@netfilter.org>
References: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pablo M. Bermudo Garay" <pablombg@gmail.com>

Register a new limit stateful object type into the stateful object
infrastructure.

Signed-off-by: Pablo M. Bermudo Garay <pablombg@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |   3 +-
 net/netfilter/nft_limit.c                | 122 ++++++++++++++++++++++++++++++-
 2 files changed, 123 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index b49da72efa68..871afa4871bf 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1282,7 +1282,8 @@ enum nft_ct_helper_attributes {
 #define NFT_OBJECT_COUNTER	1
 #define NFT_OBJECT_QUOTA	2
 #define NFT_OBJECT_CT_HELPER	3
-#define __NFT_OBJECT_MAX	4
+#define NFT_OBJECT_LIMIT	4
+#define __NFT_OBJECT_MAX	5
 #define NFT_OBJECT_MAX		(__NFT_OBJECT_MAX - 1)
 
 /**
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index aae2d1ec27f3..a9fc298ef4c3 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -229,14 +229,133 @@ static struct nft_expr_type nft_limit_type __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static void nft_limit_obj_pkts_eval(struct nft_object *obj,
+				    struct nft_regs *regs,
+				    const struct nft_pktinfo *pkt)
+{
+	struct nft_limit_pkts *priv = nft_obj_data(obj);
+
+	if (nft_limit_eval(&priv->limit, priv->cost))
+		regs->verdict.code = NFT_BREAK;
+}
+
+static int nft_limit_obj_pkts_init(const struct nft_ctx *ctx,
+				   const struct nlattr * const tb[],
+				   struct nft_object *obj)
+{
+	struct nft_limit_pkts *priv = nft_obj_data(obj);
+	int err;
+
+	err = nft_limit_init(&priv->limit, tb);
+	if (err < 0)
+		return err;
+
+	priv->cost = div64_u64(priv->limit.nsecs, priv->limit.rate);
+	return 0;
+}
+
+static int nft_limit_obj_pkts_dump(struct sk_buff *skb,
+				   struct nft_object *obj,
+				   bool reset)
+{
+	const struct nft_limit_pkts *priv = nft_obj_data(obj);
+
+	return nft_limit_dump(skb, &priv->limit, NFT_LIMIT_PKTS);
+}
+
+static struct nft_object_type nft_limit_obj_type;
+static const struct nft_object_ops nft_limit_obj_pkts_ops = {
+	.type		= &nft_limit_obj_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_limit_pkts)),
+	.init		= nft_limit_obj_pkts_init,
+	.eval		= nft_limit_obj_pkts_eval,
+	.dump		= nft_limit_obj_pkts_dump,
+};
+
+static void nft_limit_obj_bytes_eval(struct nft_object *obj,
+				     struct nft_regs *regs,
+				     const struct nft_pktinfo *pkt)
+{
+	struct nft_limit *priv = nft_obj_data(obj);
+	u64 cost = div64_u64(priv->nsecs * pkt->skb->len, priv->rate);
+
+	if (nft_limit_eval(priv, cost))
+		regs->verdict.code = NFT_BREAK;
+}
+
+static int nft_limit_obj_bytes_init(const struct nft_ctx *ctx,
+				    const struct nlattr * const tb[],
+				    struct nft_object *obj)
+{
+	struct nft_limit *priv = nft_obj_data(obj);
+
+	return nft_limit_init(priv, tb);
+}
+
+static int nft_limit_obj_bytes_dump(struct sk_buff *skb,
+				    struct nft_object *obj,
+				    bool reset)
+{
+	const struct nft_limit *priv = nft_obj_data(obj);
+
+	return nft_limit_dump(skb, priv, NFT_LIMIT_PKT_BYTES);
+}
+
+static struct nft_object_type nft_limit_obj_type;
+static const struct nft_object_ops nft_limit_obj_bytes_ops = {
+	.type		= &nft_limit_obj_type,
+	.size		= sizeof(struct nft_limit),
+	.init		= nft_limit_obj_bytes_init,
+	.eval		= nft_limit_obj_bytes_eval,
+	.dump		= nft_limit_obj_bytes_dump,
+};
+
+static const struct nft_object_ops *
+nft_limit_obj_select_ops(const struct nft_ctx *ctx,
+			 const struct nlattr * const tb[])
+{
+	if (!tb[NFTA_LIMIT_TYPE])
+		return &nft_limit_obj_pkts_ops;
+
+	switch (ntohl(nla_get_be32(tb[NFTA_LIMIT_TYPE]))) {
+	case NFT_LIMIT_PKTS:
+		return &nft_limit_obj_pkts_ops;
+	case NFT_LIMIT_PKT_BYTES:
+		return &nft_limit_obj_bytes_ops;
+	}
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static struct nft_object_type nft_limit_obj_type __read_mostly = {
+	.select_ops	= nft_limit_obj_select_ops,
+	.type		= NFT_OBJECT_LIMIT,
+	.maxattr	= NFTA_LIMIT_MAX,
+	.policy		= nft_limit_policy,
+	.owner		= THIS_MODULE,
+};
+
 static int __init nft_limit_module_init(void)
 {
-	return nft_register_expr(&nft_limit_type);
+	int err;
+
+	err = nft_register_obj(&nft_limit_obj_type);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_limit_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_obj(&nft_limit_obj_type);
+	return err;
 }
 
 static void __exit nft_limit_module_exit(void)
 {
 	nft_unregister_expr(&nft_limit_type);
+	nft_unregister_obj(&nft_limit_obj_type);
 }
 
 module_init(nft_limit_module_init);
@@ -245,3 +364,4 @@ module_exit(nft_limit_module_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_ALIAS_NFT_EXPR("limit");
+MODULE_ALIAS_NFT_OBJ(NFT_OBJECT_LIMIT);
-- 
2.1.4

