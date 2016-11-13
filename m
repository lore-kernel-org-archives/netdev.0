From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/39] netfilter: nf_tables: simplify the basic expressions' init routine
Date: Sun, 13 Nov 2016 23:25:06 +0100
Message-ID: <1479075933-4491-13-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47652 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965076AbcKMW0R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:17 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 51536A7F27
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3D518DA811
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EBDE0DA849
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:07 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Some basic expressions are built into nf_tables.ko, such as nft_cmp,
nft_lookup, nft_range and so on. But these basic expressions' init
routine is a little ugly, too many goto errX labels, and we forget
to call nft_range_module_exit in the exit routine, although it is
harmless.

Acctually, the init and exit routines of these basic expressions
are same, i.e. do nft_register_expr in the init routine and do
nft_unregister_expr in the exit routine.

So it's better to arrange them into an array and deal with them
together.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h | 33 ++++----------
 net/netfilter/nf_tables_core.c         | 80 +++++++++++-----------------------
 net/netfilter/nft_bitwise.c            | 13 +-----
 net/netfilter/nft_byteorder.c          | 13 +-----
 net/netfilter/nft_cmp.c                | 13 +-----
 net/netfilter/nft_dynset.c             | 13 +-----
 net/netfilter/nft_immediate.c          | 13 +-----
 net/netfilter/nft_lookup.c             | 13 +-----
 net/netfilter/nft_payload.c            | 13 +-----
 net/netfilter/nft_range.c              | 13 +-----
 10 files changed, 43 insertions(+), 174 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 00f4f6b1b1ba..862373d4ea9d 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -1,12 +1,18 @@
 #ifndef _NET_NF_TABLES_CORE_H
 #define _NET_NF_TABLES_CORE_H
 
+extern struct nft_expr_type nft_imm_type;
+extern struct nft_expr_type nft_cmp_type;
+extern struct nft_expr_type nft_lookup_type;
+extern struct nft_expr_type nft_bitwise_type;
+extern struct nft_expr_type nft_byteorder_type;
+extern struct nft_expr_type nft_payload_type;
+extern struct nft_expr_type nft_dynset_type;
+extern struct nft_expr_type nft_range_type;
+
 int nf_tables_core_module_init(void);
 void nf_tables_core_module_exit(void);
 
-int nft_immediate_module_init(void);
-void nft_immediate_module_exit(void);
-
 struct nft_cmp_fast_expr {
 	u32			data;
 	enum nft_registers	sreg:8;
@@ -25,24 +31,6 @@ static inline u32 nft_cmp_fast_mask(unsigned int len)
 
 extern const struct nft_expr_ops nft_cmp_fast_ops;
 
-int nft_cmp_module_init(void);
-void nft_cmp_module_exit(void);
-
-int nft_range_module_init(void);
-void nft_range_module_exit(void);
-
-int nft_lookup_module_init(void);
-void nft_lookup_module_exit(void);
-
-int nft_dynset_module_init(void);
-void nft_dynset_module_exit(void);
-
-int nft_bitwise_module_init(void);
-void nft_bitwise_module_exit(void);
-
-int nft_byteorder_module_init(void);
-void nft_byteorder_module_exit(void);
-
 struct nft_payload {
 	enum nft_payload_bases	base:8;
 	u8			offset;
@@ -62,7 +50,4 @@ struct nft_payload_set {
 extern const struct nft_expr_ops nft_payload_fast_ops;
 extern struct static_key_false nft_trace_enabled;
 
-int nft_payload_module_init(void);
-void nft_payload_module_exit(void);
-
 #endif /* _NET_NF_TABLES_CORE_H */
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index b63b1edb76a6..65dbeadcb118 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -232,68 +232,40 @@ nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 }
 EXPORT_SYMBOL_GPL(nft_do_chain);
 
+static struct nft_expr_type *nft_basic_types[] = {
+	&nft_imm_type,
+	&nft_cmp_type,
+	&nft_lookup_type,
+	&nft_bitwise_type,
+	&nft_byteorder_type,
+	&nft_payload_type,
+	&nft_dynset_type,
+	&nft_range_type,
+};
+
 int __init nf_tables_core_module_init(void)
 {
-	int err;
-
-	err = nft_immediate_module_init();
-	if (err < 0)
-		goto err1;
-
-	err = nft_cmp_module_init();
-	if (err < 0)
-		goto err2;
-
-	err = nft_lookup_module_init();
-	if (err < 0)
-		goto err3;
-
-	err = nft_bitwise_module_init();
-	if (err < 0)
-		goto err4;
+	int err, i;
 
-	err = nft_byteorder_module_init();
-	if (err < 0)
-		goto err5;
-
-	err = nft_payload_module_init();
-	if (err < 0)
-		goto err6;
-
-	err = nft_dynset_module_init();
-	if (err < 0)
-		goto err7;
-
-	err = nft_range_module_init();
-	if (err < 0)
-		goto err8;
+	for (i = 0; i < ARRAY_SIZE(nft_basic_types); i++) {
+		err = nft_register_expr(nft_basic_types[i]);
+		if (err)
+			goto err;
+	}
 
 	return 0;
-err8:
-	nft_dynset_module_exit();
-err7:
-	nft_payload_module_exit();
-err6:
-	nft_byteorder_module_exit();
-err5:
-	nft_bitwise_module_exit();
-err4:
-	nft_lookup_module_exit();
-err3:
-	nft_cmp_module_exit();
-err2:
-	nft_immediate_module_exit();
-err1:
+
+err:
+	while (i-- > 0)
+		nft_unregister_expr(nft_basic_types[i]);
 	return err;
 }
 
 void nf_tables_core_module_exit(void)
 {
-	nft_dynset_module_exit();
-	nft_payload_module_exit();
-	nft_byteorder_module_exit();
-	nft_bitwise_module_exit();
-	nft_lookup_module_exit();
-	nft_cmp_module_exit();
-	nft_immediate_module_exit();
+	int i;
+
+	i = ARRAY_SIZE(nft_basic_types);
+	while (i-- > 0)
+		nft_unregister_expr(nft_basic_types[i]);
 }
diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 31c15ed2e5fc..877d9acd91ef 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -121,7 +121,6 @@ static int nft_bitwise_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
-static struct nft_expr_type nft_bitwise_type;
 static const struct nft_expr_ops nft_bitwise_ops = {
 	.type		= &nft_bitwise_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_bitwise)),
@@ -130,20 +129,10 @@ static const struct nft_expr_ops nft_bitwise_ops = {
 	.dump		= nft_bitwise_dump,
 };
 
-static struct nft_expr_type nft_bitwise_type __read_mostly = {
+struct nft_expr_type nft_bitwise_type __read_mostly = {
 	.name		= "bitwise",
 	.ops		= &nft_bitwise_ops,
 	.policy		= nft_bitwise_policy,
 	.maxattr	= NFTA_BITWISE_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_bitwise_module_init(void)
-{
-	return nft_register_expr(&nft_bitwise_type);
-}
-
-void nft_bitwise_module_exit(void)
-{
-	nft_unregister_expr(&nft_bitwise_type);
-}
diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index ee63d981268d..13d4e421a6b3 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -169,7 +169,6 @@ static int nft_byteorder_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
-static struct nft_expr_type nft_byteorder_type;
 static const struct nft_expr_ops nft_byteorder_ops = {
 	.type		= &nft_byteorder_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_byteorder)),
@@ -178,20 +177,10 @@ static const struct nft_expr_ops nft_byteorder_ops = {
 	.dump		= nft_byteorder_dump,
 };
 
-static struct nft_expr_type nft_byteorder_type __read_mostly = {
+struct nft_expr_type nft_byteorder_type __read_mostly = {
 	.name		= "byteorder",
 	.ops		= &nft_byteorder_ops,
 	.policy		= nft_byteorder_policy,
 	.maxattr	= NFTA_BYTEORDER_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_byteorder_module_init(void)
-{
-	return nft_register_expr(&nft_byteorder_type);
-}
-
-void nft_byteorder_module_exit(void)
-{
-	nft_unregister_expr(&nft_byteorder_type);
-}
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index e25b35d70e4d..2b96effeadc1 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -107,7 +107,6 @@ static int nft_cmp_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
-static struct nft_expr_type nft_cmp_type;
 static const struct nft_expr_ops nft_cmp_ops = {
 	.type		= &nft_cmp_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_cmp_expr)),
@@ -208,20 +207,10 @@ nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 		return &nft_cmp_ops;
 }
 
-static struct nft_expr_type nft_cmp_type __read_mostly = {
+struct nft_expr_type nft_cmp_type __read_mostly = {
 	.name		= "cmp",
 	.select_ops	= nft_cmp_select_ops,
 	.policy		= nft_cmp_policy,
 	.maxattr	= NFTA_CMP_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_cmp_module_init(void)
-{
-	return nft_register_expr(&nft_cmp_type);
-}
-
-void nft_cmp_module_exit(void)
-{
-	nft_unregister_expr(&nft_cmp_type);
-}
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 517f08767a3c..4339e3f1c4b1 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -261,7 +261,6 @@ static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
-static struct nft_expr_type nft_dynset_type;
 static const struct nft_expr_ops nft_dynset_ops = {
 	.type		= &nft_dynset_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_dynset)),
@@ -271,20 +270,10 @@ static const struct nft_expr_ops nft_dynset_ops = {
 	.dump		= nft_dynset_dump,
 };
 
-static struct nft_expr_type nft_dynset_type __read_mostly = {
+struct nft_expr_type nft_dynset_type __read_mostly = {
 	.name		= "dynset",
 	.ops		= &nft_dynset_ops,
 	.policy		= nft_dynset_policy,
 	.maxattr	= NFTA_DYNSET_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_dynset_module_init(void)
-{
-	return nft_register_expr(&nft_dynset_type);
-}
-
-void nft_dynset_module_exit(void)
-{
-	nft_unregister_expr(&nft_dynset_type);
-}
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 4528adea7ede..728baf88295a 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -102,7 +102,6 @@ static int nft_immediate_validate(const struct nft_ctx *ctx,
 	return 0;
 }
 
-static struct nft_expr_type nft_imm_type;
 static const struct nft_expr_ops nft_imm_ops = {
 	.type		= &nft_imm_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_immediate_expr)),
@@ -113,20 +112,10 @@ static const struct nft_expr_ops nft_imm_ops = {
 	.validate	= nft_immediate_validate,
 };
 
-static struct nft_expr_type nft_imm_type __read_mostly = {
+struct nft_expr_type nft_imm_type __read_mostly = {
 	.name		= "immediate",
 	.ops		= &nft_imm_ops,
 	.policy		= nft_immediate_policy,
 	.maxattr	= NFTA_IMMEDIATE_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_immediate_module_init(void)
-{
-	return nft_register_expr(&nft_imm_type);
-}
-
-void nft_immediate_module_exit(void)
-{
-	nft_unregister_expr(&nft_imm_type);
-}
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index a8ce49bcda80..d4f97fa7e21d 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -154,7 +154,6 @@ static int nft_lookup_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
-static struct nft_expr_type nft_lookup_type;
 static const struct nft_expr_ops nft_lookup_ops = {
 	.type		= &nft_lookup_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_lookup)),
@@ -164,20 +163,10 @@ static const struct nft_expr_ops nft_lookup_ops = {
 	.dump		= nft_lookup_dump,
 };
 
-static struct nft_expr_type nft_lookup_type __read_mostly = {
+struct nft_expr_type nft_lookup_type __read_mostly = {
 	.name		= "lookup",
 	.ops		= &nft_lookup_ops,
 	.policy		= nft_lookup_policy,
 	.maxattr	= NFTA_LOOKUP_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_lookup_module_init(void)
-{
-	return nft_register_expr(&nft_lookup_type);
-}
-
-void nft_lookup_module_exit(void)
-{
-	nft_unregister_expr(&nft_lookup_type);
-}
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index b2f88617611a..98fb5d7b8087 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -148,7 +148,6 @@ static int nft_payload_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
-static struct nft_expr_type nft_payload_type;
 static const struct nft_expr_ops nft_payload_ops = {
 	.type		= &nft_payload_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_payload)),
@@ -320,20 +319,10 @@ nft_payload_select_ops(const struct nft_ctx *ctx,
 		return &nft_payload_ops;
 }
 
-static struct nft_expr_type nft_payload_type __read_mostly = {
+struct nft_expr_type nft_payload_type __read_mostly = {
 	.name		= "payload",
 	.select_ops	= nft_payload_select_ops,
 	.policy		= nft_payload_policy,
 	.maxattr	= NFTA_PAYLOAD_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_payload_module_init(void)
-{
-	return nft_register_expr(&nft_payload_type);
-}
-
-void nft_payload_module_exit(void)
-{
-	nft_unregister_expr(&nft_payload_type);
-}
diff --git a/net/netfilter/nft_range.c b/net/netfilter/nft_range.c
index fbc88009ca2e..009062606697 100644
--- a/net/netfilter/nft_range.c
+++ b/net/netfilter/nft_range.c
@@ -122,7 +122,6 @@ static int nft_range_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
-static struct nft_expr_type nft_range_type;
 static const struct nft_expr_ops nft_range_ops = {
 	.type		= &nft_range_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_range_expr)),
@@ -131,20 +130,10 @@ static const struct nft_expr_ops nft_range_ops = {
 	.dump		= nft_range_dump,
 };
 
-static struct nft_expr_type nft_range_type __read_mostly = {
+struct nft_expr_type nft_range_type __read_mostly = {
 	.name		= "range",
 	.ops		= &nft_range_ops,
 	.policy		= nft_range_policy,
 	.maxattr	= NFTA_RANGE_MAX,
 	.owner		= THIS_MODULE,
 };
-
-int __init nft_range_module_init(void)
-{
-	return nft_register_expr(&nft_range_type);
-}
-
-void nft_range_module_exit(void)
-{
-	nft_unregister_expr(&nft_range_type);
-}
-- 
2.1.4
