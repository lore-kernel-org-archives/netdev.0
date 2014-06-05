From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nf_tables: atomic allocation in set notifications from rcu callback
Date: Thu,  5 Jun 2014 17:08:26 +0200
Message-ID: <1401980906-25290-7-git-send-email-pablo@netfilter.org>
References: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use GFP_ATOMIC allocations when sending removal notifications of
anonymous sets from rcu callback context. Sleeping in that context
is illegal.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index dbf8236..624e083 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2191,7 +2191,7 @@ nla_put_failure:
 
 static int nf_tables_set_notify(const struct nft_ctx *ctx,
 				const struct nft_set *set,
-				int event)
+				int event, gfp_t gfp_flags)
 {
 	struct sk_buff *skb;
 	u32 portid = ctx->portid;
@@ -2202,7 +2202,7 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 		return 0;
 
 	err = -ENOBUFS;
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	skb = nlmsg_new(NLMSG_GOODSIZE, gfp_flags);
 	if (skb == NULL)
 		goto err;
 
@@ -2213,7 +2213,7 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 	}
 
 	err = nfnetlink_send(skb, ctx->net, portid, NFNLGRP_NFTABLES,
-			     ctx->report, GFP_KERNEL);
+			     ctx->report, gfp_flags);
 err:
 	if (err < 0)
 		nfnetlink_set_err(ctx->net, portid, NFNLGRP_NFTABLES, err);
@@ -2613,7 +2613,7 @@ static void nft_set_destroy(struct nft_set *set)
 static void nf_tables_set_destroy(const struct nft_ctx *ctx, struct nft_set *set)
 {
 	list_del(&set->list);
-	nf_tables_set_notify(ctx, set, NFT_MSG_DELSET);
+	nf_tables_set_notify(ctx, set, NFT_MSG_DELSET, GFP_ATOMIC);
 	nft_set_destroy(set);
 }
 
@@ -3409,12 +3409,12 @@ static int nf_tables_commit(struct sk_buff *skb)
 				trans->ctx.table->use--;
 
 			nf_tables_set_notify(&trans->ctx, nft_trans_set(trans),
-					     NFT_MSG_NEWSET);
+					     NFT_MSG_NEWSET, GFP_KERNEL);
 			nft_trans_destroy(trans);
 			break;
 		case NFT_MSG_DELSET:
 			nf_tables_set_notify(&trans->ctx, nft_trans_set(trans),
-					     NFT_MSG_DELSET);
+					     NFT_MSG_DELSET, GFP_KERNEL);
 			break;
 		case NFT_MSG_NEWSETELEM:
 			nf_tables_setelem_notify(&trans->ctx,
-- 
1.7.10.4

