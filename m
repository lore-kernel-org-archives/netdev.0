From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/25] netfilter: nft_compat: put back match/target module if init fail
Date: Sat, 23 Jul 2016 13:08:38 +0200
Message-ID: <1469272119-29942-25-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

If the user specify the invalid NFTA_MATCH_INFO/NFTA_TARGET_INFO attr
or memory alloc fail, we should call module_put to the related match
or target. Otherwise, we cannot remove the module even nobody use it.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 6228c42..2e07cec 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -634,6 +634,7 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 	struct xt_match *match;
 	char *mt_name;
 	u32 rev, family;
+	int err;
 
 	if (tb[NFTA_MATCH_NAME] == NULL ||
 	    tb[NFTA_MATCH_REV] == NULL ||
@@ -660,13 +661,17 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 	if (IS_ERR(match))
 		return ERR_PTR(-ENOENT);
 
-	if (match->matchsize > nla_len(tb[NFTA_MATCH_INFO]))
-		return ERR_PTR(-EINVAL);
+	if (match->matchsize > nla_len(tb[NFTA_MATCH_INFO])) {
+		err = -EINVAL;
+		goto err;
+	}
 
 	/* This is the first time we use this match, allocate operations */
 	nft_match = kzalloc(sizeof(struct nft_xt), GFP_KERNEL);
-	if (nft_match == NULL)
-		return ERR_PTR(-ENOMEM);
+	if (nft_match == NULL) {
+		err = -ENOMEM;
+		goto err;
+	}
 
 	nft_match->ops.type = &nft_match_type;
 	nft_match->ops.size = NFT_EXPR_SIZE(XT_ALIGN(match->matchsize));
@@ -680,6 +685,9 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 	list_add(&nft_match->head, &nft_match_list);
 
 	return &nft_match->ops;
+err:
+	module_put(match->me);
+	return ERR_PTR(err);
 }
 
 static void nft_match_release(void)
@@ -717,6 +725,7 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 	struct xt_target *target;
 	char *tg_name;
 	u32 rev, family;
+	int err;
 
 	if (tb[NFTA_TARGET_NAME] == NULL ||
 	    tb[NFTA_TARGET_REV] == NULL ||
@@ -743,13 +752,17 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 	if (IS_ERR(target))
 		return ERR_PTR(-ENOENT);
 
-	if (target->targetsize > nla_len(tb[NFTA_TARGET_INFO]))
-		return ERR_PTR(-EINVAL);
+	if (target->targetsize > nla_len(tb[NFTA_TARGET_INFO])) {
+		err = -EINVAL;
+		goto err;
+	}
 
 	/* This is the first time we use this target, allocate operations */
 	nft_target = kzalloc(sizeof(struct nft_xt), GFP_KERNEL);
-	if (nft_target == NULL)
-		return ERR_PTR(-ENOMEM);
+	if (nft_target == NULL) {
+		err = -ENOMEM;
+		goto err;
+	}
 
 	nft_target->ops.type = &nft_target_type;
 	nft_target->ops.size = NFT_EXPR_SIZE(XT_ALIGN(target->targetsize));
@@ -767,6 +780,9 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 	list_add(&nft_target->head, &nft_target_list);
 
 	return &nft_target->ops;
+err:
+	module_put(target->me);
+	return ERR_PTR(err);
 }
 
 static void nft_target_release(void)
-- 
2.1.4

