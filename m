From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] netfilter: nft_compat: fix error path in nft_parse_compat()
Date: Thu, 21 Nov 2013 10:05:26 +0100
Message-ID: <1385024728-4057-6-git-send-email-pablo@netfilter.org>
References: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch 0ca743a55991: "netfilter: nf_tables: add compatibility
layer for x_tables", leads to the following Smatch

 warning: "net/netfilter/nft_compat.c:140 nft_parse_compat()
          warn: signedness bug returning '(-34)'"

This nft_parse_compat function returns error codes but the return
type is u8 so the error codes are transformed into small positive
values. The callers don't check the return.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index a82667c..da0c1f4 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -128,7 +128,7 @@ static const struct nla_policy nft_rule_compat_policy[NFTA_RULE_COMPAT_MAX + 1]
 	[NFTA_RULE_COMPAT_FLAGS]	= { .type = NLA_U32 },
 };
 
-static u8 nft_parse_compat(const struct nlattr *attr, bool *inv)
+static int nft_parse_compat(const struct nlattr *attr, u8 *proto, bool *inv)
 {
 	struct nlattr *tb[NFTA_RULE_COMPAT_MAX+1];
 	u32 flags;
@@ -148,7 +148,8 @@ static u8 nft_parse_compat(const struct nlattr *attr, bool *inv)
 	if (flags & NFT_RULE_COMPAT_F_INV)
 		*inv = true;
 
-	return ntohl(nla_get_be32(tb[NFTA_RULE_COMPAT_PROTO]));
+	*proto = ntohl(nla_get_be32(tb[NFTA_RULE_COMPAT_PROTO]));
+	return 0;
 }
 
 static int
@@ -166,8 +167,11 @@ nft_target_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 
 	target_compat_from_user(target, nla_data(tb[NFTA_TARGET_INFO]), info);
 
-	if (ctx->nla[NFTA_RULE_COMPAT])
-		proto = nft_parse_compat(ctx->nla[NFTA_RULE_COMPAT], &inv);
+	if (ctx->nla[NFTA_RULE_COMPAT]) {
+		ret = nft_parse_compat(ctx->nla[NFTA_RULE_COMPAT], &proto, &inv);
+		if (ret < 0)
+			goto err;
+	}
 
 	nft_target_set_tgchk_param(&par, ctx, target, info, &e, proto, inv);
 
@@ -356,8 +360,11 @@ nft_match_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 
 	match_compat_from_user(match, nla_data(tb[NFTA_MATCH_INFO]), info);
 
-	if (ctx->nla[NFTA_RULE_COMPAT])
-		proto = nft_parse_compat(ctx->nla[NFTA_RULE_COMPAT], &inv);
+	if (ctx->nla[NFTA_RULE_COMPAT]) {
+		ret = nft_parse_compat(ctx->nla[NFTA_RULE_COMPAT], &proto, &inv);
+		if (ret < 0)
+			goto err;
+	}
 
 	nft_match_set_mtchk_param(&par, ctx, match, info, &e, proto, inv);
 
-- 
1.7.10.4

