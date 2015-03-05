From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] netfilter: nft_compat: don't truncate ethernet protocol type to u8
Date: Thu,  5 Mar 2015 21:48:43 +0100
Message-ID: <1425588529-4573-2-git-send-email-pablo@netfilter.org>
References: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

Use u16 for protocol and then cast it to __be16

>> net/netfilter/nft_compat.c:140:37: sparse: incorrect type in assignment (different base types)
   net/netfilter/nft_compat.c:140:37:    expected restricted __be16 [usertype] ethproto
   net/netfilter/nft_compat.c:140:37:    got unsigned char [unsigned] [usertype] proto
>> net/netfilter/nft_compat.c:351:37: sparse: incorrect type in assignment (different base types)
   net/netfilter/nft_compat.c:351:37:    expected restricted __be16 [usertype] ethproto
   net/netfilter/nft_compat.c:351:37:    got unsigned char [unsigned] [usertype] proto

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 1279cd8..213584c 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -123,7 +123,7 @@ static void
 nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 			   const struct nft_ctx *ctx,
 			   struct xt_target *target, void *info,
-			   union nft_entry *entry, u8 proto, bool inv)
+			   union nft_entry *entry, u16 proto, bool inv)
 {
 	par->net	= ctx->net;
 	par->table	= ctx->table->name;
@@ -137,7 +137,7 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 		entry->e6.ipv6.invflags = inv ? IP6T_INV_PROTO : 0;
 		break;
 	case NFPROTO_BRIDGE:
-		entry->ebt.ethproto = proto;
+		entry->ebt.ethproto = (__force __be16)proto;
 		entry->ebt.invflags = inv ? EBT_IPROTO : 0;
 		break;
 	}
@@ -171,7 +171,7 @@ static const struct nla_policy nft_rule_compat_policy[NFTA_RULE_COMPAT_MAX + 1]
 	[NFTA_RULE_COMPAT_FLAGS]	= { .type = NLA_U32 },
 };
 
-static int nft_parse_compat(const struct nlattr *attr, u8 *proto, bool *inv)
+static int nft_parse_compat(const struct nlattr *attr, u16 *proto, bool *inv)
 {
 	struct nlattr *tb[NFTA_RULE_COMPAT_MAX+1];
 	u32 flags;
@@ -203,7 +203,7 @@ nft_target_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	struct xt_target *target = expr->ops->data;
 	struct xt_tgchk_param par;
 	size_t size = XT_ALIGN(nla_len(tb[NFTA_TARGET_INFO]));
-	u8 proto = 0;
+	u16 proto = 0;
 	bool inv = false;
 	union nft_entry e = {};
 	int ret;
@@ -334,7 +334,7 @@ static const struct nla_policy nft_match_policy[NFTA_MATCH_MAX + 1] = {
 static void
 nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 			  struct xt_match *match, void *info,
-			  union nft_entry *entry, u8 proto, bool inv)
+			  union nft_entry *entry, u16 proto, bool inv)
 {
 	par->net	= ctx->net;
 	par->table	= ctx->table->name;
@@ -348,7 +348,7 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 		entry->e6.ipv6.invflags = inv ? IP6T_INV_PROTO : 0;
 		break;
 	case NFPROTO_BRIDGE:
-		entry->ebt.ethproto = proto;
+		entry->ebt.ethproto = (__force __be16)proto;
 		entry->ebt.invflags = inv ? EBT_IPROTO : 0;
 		break;
 	}
@@ -385,7 +385,7 @@ nft_match_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	struct xt_match *match = expr->ops->data;
 	struct xt_mtchk_param par;
 	size_t size = XT_ALIGN(nla_len(tb[NFTA_MATCH_INFO]));
-	u8 proto = 0;
+	u16 proto = 0;
 	bool inv = false;
 	union nft_entry e = {};
 	int ret;
-- 
1.7.10.4

