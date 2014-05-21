From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/25] netfilter: nf_tables: pass context to nf_tables_updtable()
Date: Wed, 21 May 2014 11:43:17 +0200
Message-ID: <1400665402-5835-20-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So nf_tables_uptable() only takes one single parameter.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   51 +++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5f71703..d71125a 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -393,36 +393,34 @@ static void nf_tables_table_disable(const struct nft_af_info *afi,
 	}
 }
 
-static int nf_tables_updtable(struct sock *nlsk, struct sk_buff *skb,
-			      const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[],
-			      struct nft_af_info *afi, struct nft_table *table)
+static int nf_tables_updtable(struct nft_ctx *ctx)
 {
-	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
+	const struct nfgenmsg *nfmsg = nlmsg_data(ctx->nlh);
 	int family = nfmsg->nfgen_family, ret = 0;
+	u32 flags;
 
-	if (nla[NFTA_TABLE_FLAGS]) {
-		u32 flags;
+	if (!ctx->nla[NFTA_TABLE_FLAGS])
+		return 0;
 
-		flags = ntohl(nla_get_be32(nla[NFTA_TABLE_FLAGS]));
-		if (flags & ~NFT_TABLE_F_DORMANT)
-			return -EINVAL;
+	flags = ntohl(nla_get_be32(ctx->nla[NFTA_TABLE_FLAGS]));
+	if (flags & ~NFT_TABLE_F_DORMANT)
+		return -EINVAL;
 
-		if ((flags & NFT_TABLE_F_DORMANT) &&
-		    !(table->flags & NFT_TABLE_F_DORMANT)) {
-			nf_tables_table_disable(afi, table);
-			table->flags |= NFT_TABLE_F_DORMANT;
-		} else if (!(flags & NFT_TABLE_F_DORMANT) &&
-			   table->flags & NFT_TABLE_F_DORMANT) {
-			ret = nf_tables_table_enable(afi, table);
-			if (ret >= 0)
-				table->flags &= ~NFT_TABLE_F_DORMANT;
-		}
-		if (ret < 0)
-			goto err;
-	}
+	if ((flags & NFT_TABLE_F_DORMANT) &&
+	    !(ctx->table->flags & NFT_TABLE_F_DORMANT)) {
+		nf_tables_table_disable(ctx->afi, ctx->table);
+		ctx->table->flags |= NFT_TABLE_F_DORMANT;
+	} else if (!(flags & NFT_TABLE_F_DORMANT) &&
+		   ctx->table->flags & NFT_TABLE_F_DORMANT) {
+		ret = nf_tables_table_enable(ctx->afi, ctx->table);
+		if (ret >= 0)
+			ctx->table->flags &= ~NFT_TABLE_F_DORMANT;
+	}
+	if (ret < 0)
+		goto err;
 
-	nf_tables_table_notify(skb, nlh, table, NFT_MSG_NEWTABLE, family);
+	nf_tables_table_notify(ctx->skb, ctx->nlh, ctx->table,
+			       NFT_MSG_NEWTABLE, family);
 err:
 	return ret;
 }
@@ -438,6 +436,7 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	u32 flags = 0;
+	struct nft_ctx ctx;
 
 	afi = nf_tables_afinfo_lookup(net, family, true);
 	if (IS_ERR(afi))
@@ -456,7 +455,9 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 			return -EEXIST;
 		if (nlh->nlmsg_flags & NLM_F_REPLACE)
 			return -EOPNOTSUPP;
-		return nf_tables_updtable(nlsk, skb, nlh, nla, afi, table);
+
+		nft_ctx_init(&ctx, skb, nlh, afi, table, NULL, nla);
+		return nf_tables_updtable(&ctx);
 	}
 
 	if (nla[NFTA_TABLE_FLAGS]) {
-- 
1.7.10.4

