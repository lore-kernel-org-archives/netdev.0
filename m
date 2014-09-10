From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/25] netfilter: nf_tables: refactor rule deletion helper
Date: Wed, 10 Sep 2014 17:10:30 +0200
Message-ID: <1410361842-4656-14-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

This helper function always schedule the rule to be removed in the following
transaction.
In follow-up patches, it is interesting to handle separately the logic of rule
activation/disactivation from the transaction mechanism.

So, this patch simply splits the original nf_tables_delrule_one() in two
functions, allowing further control.

While at it, for the sake of homigeneize the function naming scheme, let's
rename nf_tables_delrule_one() to nft_delrule().

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index deeb95f..3664bab 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1868,12 +1868,10 @@ err1:
 }
 
 static int
-nf_tables_delrule_one(struct nft_ctx *ctx, struct nft_rule *rule)
+nf_tables_delrule_deactivate(struct nft_ctx *ctx, struct nft_rule *rule)
 {
 	/* You cannot delete the same rule twice */
 	if (nft_rule_is_active_next(ctx->net, rule)) {
-		if (nft_trans_rule_add(ctx, NFT_MSG_DELRULE, rule) == NULL)
-			return -ENOMEM;
 		nft_rule_disactivate_next(ctx->net, rule);
 		ctx->chain->use--;
 		return 0;
@@ -1881,13 +1879,31 @@ nf_tables_delrule_one(struct nft_ctx *ctx, struct nft_rule *rule)
 	return -ENOENT;
 }
 
+static int nft_delrule(struct nft_ctx *ctx, struct nft_rule *rule)
+{
+	struct nft_trans *trans;
+	int err;
+
+	trans = nft_trans_rule_add(ctx, NFT_MSG_DELRULE, rule);
+	if (trans == NULL)
+		return -ENOMEM;
+
+	err = nf_tables_delrule_deactivate(ctx, rule);
+	if (err < 0) {
+		nft_trans_destroy(trans);
+		return err;
+	}
+
+	return 0;
+}
+
 static int nf_table_delrule_by_chain(struct nft_ctx *ctx)
 {
 	struct nft_rule *rule;
 	int err;
 
 	list_for_each_entry(rule, &ctx->chain->rules, list) {
-		err = nf_tables_delrule_one(ctx, rule);
+		err = nft_delrule(ctx, rule);
 		if (err < 0)
 			return err;
 	}
@@ -1932,7 +1948,7 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 			if (IS_ERR(rule))
 				return PTR_ERR(rule);
 
-			err = nf_tables_delrule_one(&ctx, rule);
+			err = nft_delrule(&ctx, rule);
 		} else {
 			err = nf_table_delrule_by_chain(&ctx);
 		}
-- 
1.7.10.4

