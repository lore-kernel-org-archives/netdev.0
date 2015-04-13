From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/21] netfilter: nf_tables: use struct nft_verdict within struct nft_data
Date: Mon, 13 Apr 2015 21:29:46 +0200
Message-ID: <1428953401-4838-8-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    7 ++-----
 net/netfilter/nf_tables_api.c     |   38 ++++++++++++++++++++-----------------
 2 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 79582d0..81cd816 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -49,11 +49,8 @@ struct nft_verdict {
 
 struct nft_data {
 	union {
-		u32				data[4];
-		struct {
-			u32			verdict;
-			struct nft_chain	*chain;
-		};
+		u32			data[4];
+		struct nft_verdict	verdict;
 	};
 } __attribute__((aligned(__alignof__(u64))));
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d47f12b..0bb16a1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4049,10 +4049,10 @@ static int nf_tables_loop_check_setelem(const struct nft_ctx *ctx,
 		return 0;
 
 	data = nft_set_ext_data(ext);
-	switch (data->verdict) {
+	switch (data->verdict.code) {
 	case NFT_JUMP:
 	case NFT_GOTO:
-		return nf_tables_check_loops(ctx, data->chain);
+		return nf_tables_check_loops(ctx, data->verdict.chain);
 	default:
 		return 0;
 	}
@@ -4085,10 +4085,11 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 			if (data == NULL)
 				continue;
 
-			switch (data->verdict) {
+			switch (data->verdict.code) {
 			case NFT_JUMP:
 			case NFT_GOTO:
-				err = nf_tables_check_loops(ctx, data->chain);
+				err = nf_tables_check_loops(ctx,
+							data->verdict.chain);
 				if (err < 0)
 					return err;
 			default:
@@ -4171,15 +4172,17 @@ int nft_validate_register_store(const struct nft_ctx *ctx,
 			return -EINVAL;
 
 		if (data != NULL &&
-		    (data->verdict == NFT_GOTO || data->verdict == NFT_JUMP)) {
-			err = nf_tables_check_loops(ctx, data->chain);
+		    (data->verdict.code == NFT_GOTO ||
+		     data->verdict.code == NFT_JUMP)) {
+			err = nf_tables_check_loops(ctx, data->verdict.chain);
 			if (err < 0)
 				return err;
 
-			if (ctx->chain->level + 1 > data->chain->level) {
+			if (ctx->chain->level + 1 >
+			    data->verdict.chain->level) {
 				if (ctx->chain->level + 1 == NFT_JUMP_STACK_SIZE)
 					return -EMLINK;
-				data->chain->level = ctx->chain->level + 1;
+				data->verdict.chain->level = ctx->chain->level + 1;
 			}
 		}
 
@@ -4220,11 +4223,11 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 
 	if (!tb[NFTA_VERDICT_CODE])
 		return -EINVAL;
-	data->verdict = ntohl(nla_get_be32(tb[NFTA_VERDICT_CODE]));
+	data->verdict.code = ntohl(nla_get_be32(tb[NFTA_VERDICT_CODE]));
 
-	switch (data->verdict) {
+	switch (data->verdict.code) {
 	default:
-		switch (data->verdict & NF_VERDICT_MASK) {
+		switch (data->verdict.code & NF_VERDICT_MASK) {
 		case NF_ACCEPT:
 		case NF_DROP:
 		case NF_QUEUE:
@@ -4250,7 +4253,7 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 			return -EOPNOTSUPP;
 
 		chain->use++;
-		data->chain = chain;
+		data->verdict.chain = chain;
 		desc->len = sizeof(data);
 		break;
 	}
@@ -4261,10 +4264,10 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 
 static void nft_verdict_uninit(const struct nft_data *data)
 {
-	switch (data->verdict) {
+	switch (data->verdict.code) {
 	case NFT_JUMP:
 	case NFT_GOTO:
-		data->chain->use--;
+		data->verdict.chain->use--;
 		break;
 	}
 }
@@ -4277,13 +4280,14 @@ static int nft_verdict_dump(struct sk_buff *skb, const struct nft_data *data)
 	if (!nest)
 		goto nla_put_failure;
 
-	if (nla_put_be32(skb, NFTA_VERDICT_CODE, htonl(data->verdict)))
+	if (nla_put_be32(skb, NFTA_VERDICT_CODE, htonl(data->verdict.code)))
 		goto nla_put_failure;
 
-	switch (data->verdict) {
+	switch (data->verdict.code) {
 	case NFT_JUMP:
 	case NFT_GOTO:
-		if (nla_put_string(skb, NFTA_VERDICT_CHAIN, data->chain->name))
+		if (nla_put_string(skb, NFTA_VERDICT_CHAIN,
+				   data->verdict.chain->name))
 			goto nla_put_failure;
 	}
 	nla_nest_end(skb, nest);
-- 
1.7.10.4

