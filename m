From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/50] netfilter: nft_quota: add stateful object type
Date: Wed,  7 Dec 2016 22:52:40 +0100
Message-ID: <1481147576-5690-35-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60248 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933400AbcLGVxs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:48 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BF5878CD8E
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AFA50DA853
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 64F5EDA86E
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:45 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register a new quota stateful object type into the new stateful object
infrastructure.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  1 +
 net/netfilter/nft_quota.c                | 96 +++++++++++++++++++++++++++-----
 2 files changed, 84 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index e352ef65d753..ad0577ba5d2a 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1187,6 +1187,7 @@ enum nft_fib_flags {
 
 #define NFT_OBJECT_UNSPEC	0
 #define NFT_OBJECT_COUNTER	1
+#define NFT_OBJECT_QUOTA	2
 
 /**
  * enum nft_object_attributes - nf_tables stateful object netlink attributes
diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
index c00104c07095..09ce72b1d6bf 100644
--- a/net/netfilter/nft_quota.c
+++ b/net/netfilter/nft_quota.c
@@ -27,12 +27,10 @@ static inline bool nft_overquota(struct nft_quota *priv,
 	return atomic64_sub_return(pkt->skb->len, &priv->remain) < 0;
 }
 
-static void nft_quota_eval(const struct nft_expr *expr,
-			   struct nft_regs *regs,
-			   const struct nft_pktinfo *pkt)
+static inline void nft_quota_do_eval(struct nft_quota *priv,
+				     struct nft_regs *regs,
+				     const struct nft_pktinfo *pkt)
 {
-	struct nft_quota *priv = nft_expr_priv(expr);
-
 	if (nft_overquota(priv, pkt) ^ priv->invert)
 		regs->verdict.code = NFT_BREAK;
 }
@@ -42,11 +40,18 @@ static const struct nla_policy nft_quota_policy[NFTA_QUOTA_MAX + 1] = {
 	[NFTA_QUOTA_FLAGS]	= { .type = NLA_U32 },
 };
 
-static int nft_quota_init(const struct nft_ctx *ctx,
-			  const struct nft_expr *expr,
-			  const struct nlattr * const tb[])
+static void nft_quota_obj_eval(struct nft_object *obj,
+			       struct nft_regs *regs,
+			       const struct nft_pktinfo *pkt)
+{
+	struct nft_quota *priv = nft_obj_data(obj);
+
+	nft_quota_do_eval(priv, regs, pkt);
+}
+
+static int nft_quota_do_init(const struct nlattr * const tb[],
+			     struct nft_quota *priv)
 {
-	struct nft_quota *priv = nft_expr_priv(expr);
 	u32 flags = 0;
 	u64 quota;
 
@@ -70,9 +75,16 @@ static int nft_quota_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static int nft_quota_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_quota_obj_init(const struct nlattr * const tb[],
+			      struct nft_object *obj)
+{
+	struct nft_quota *priv = nft_obj_data(obj);
+
+	return nft_quota_do_init(tb, priv);
+}
+
+static int nft_quota_do_dump(struct sk_buff *skb, const struct nft_quota *priv)
 {
-	const struct nft_quota *priv = nft_expr_priv(expr);
 	u32 flags = priv->invert ? NFT_QUOTA_F_INV : 0;
 
 	if (nla_put_be64(skb, NFTA_QUOTA_BYTES, cpu_to_be64(priv->quota),
@@ -85,6 +97,49 @@ static int nft_quota_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
+static int nft_quota_obj_dump(struct sk_buff *skb, const struct nft_object *obj)
+{
+	struct nft_quota *priv = nft_obj_data(obj);
+
+	return nft_quota_do_dump(skb, priv);
+}
+
+static struct nft_object_type nft_quota_obj __read_mostly = {
+	.type		= NFT_OBJECT_QUOTA,
+	.size		= sizeof(struct nft_quota),
+	.maxattr	= NFTA_QUOTA_MAX,
+	.policy		= nft_quota_policy,
+	.init		= nft_quota_obj_init,
+	.eval		= nft_quota_obj_eval,
+	.dump		= nft_quota_obj_dump,
+	.owner		= THIS_MODULE,
+};
+
+static void nft_quota_eval(const struct nft_expr *expr,
+			   struct nft_regs *regs,
+			   const struct nft_pktinfo *pkt)
+{
+	struct nft_quota *priv = nft_expr_priv(expr);
+
+	nft_quota_do_eval(priv, regs, pkt);
+}
+
+static int nft_quota_init(const struct nft_ctx *ctx,
+			  const struct nft_expr *expr,
+			  const struct nlattr * const tb[])
+{
+	struct nft_quota *priv = nft_expr_priv(expr);
+
+	return nft_quota_do_init(tb, priv);
+}
+
+static int nft_quota_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_quota *priv = nft_expr_priv(expr);
+
+	return nft_quota_do_dump(skb, priv);
+}
+
 static struct nft_expr_type nft_quota_type;
 static const struct nft_expr_ops nft_quota_ops = {
 	.type		= &nft_quota_type,
@@ -105,12 +160,26 @@ static struct nft_expr_type nft_quota_type __read_mostly = {
 
 static int __init nft_quota_module_init(void)
 {
-        return nft_register_expr(&nft_quota_type);
+	int err;
+
+	err = nft_register_obj(&nft_quota_obj);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_quota_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_obj(&nft_quota_obj);
+	return err;
 }
 
 static void __exit nft_quota_module_exit(void)
 {
-        nft_unregister_expr(&nft_quota_type);
+	nft_unregister_expr(&nft_quota_type);
+	nft_unregister_obj(&nft_quota_obj);
 }
 
 module_init(nft_quota_module_init);
@@ -119,3 +188,4 @@ module_exit(nft_quota_module_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
 MODULE_ALIAS_NFT_EXPR("quota");
+MODULE_ALIAS_NFT_OBJ(NFT_OBJECT_QUOTA);
-- 
2.1.4
