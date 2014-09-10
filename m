From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/25] netfilter: nf_tables: extend NFT_MSG_DELTABLE to support flushing the ruleset
Date: Wed, 10 Sep 2014 17:10:37 +0200
Message-ID: <1410361842-4656-21-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55973 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369AbaIJPKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 11:10:42 -0400
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

This patch extend the NFT_MSG_DELTABLE call to support flushing the entire
ruleset.

The options now are:
 * No family speficied, no table specified: flush all the ruleset.
 * Family specified, no table specified: flush all tables in the AF.
 * Family specified, table specified: flush the given table.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   72 ++++++++++++++++++++++++++++++++++++++---
 1 file changed, 68 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 3ce5cfa..8237460 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -707,6 +707,67 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	return 0;
 }
 
+static int nft_flush_table(struct nft_ctx *ctx)
+{
+	int err;
+	struct nft_chain *chain, *nc;
+	struct nft_set *set, *ns;
+
+	list_for_each_entry_safe(chain, nc, &ctx->table->chains, list) {
+		ctx->chain = chain;
+
+		err = nft_delrule_by_chain(ctx);
+		if (err < 0)
+			goto out;
+
+		err = nft_delchain(ctx);
+		if (err < 0)
+			goto out;
+	}
+
+	list_for_each_entry_safe(set, ns, &ctx->table->sets, list) {
+		if (set->flags & NFT_SET_ANONYMOUS &&
+		    !list_empty(&set->bindings))
+			continue;
+
+		err = nft_delset(ctx, set);
+		if (err < 0)
+			goto out;
+	}
+
+	err = nft_deltable(ctx);
+out:
+	return err;
+}
+
+static int nft_flush(struct nft_ctx *ctx, int family)
+{
+	struct nft_af_info *afi;
+	struct nft_table *table, *nt;
+	const struct nlattr * const *nla = ctx->nla;
+	int err = 0;
+
+	list_for_each_entry(afi, &ctx->net->nft.af_info, list) {
+		if (family != AF_UNSPEC && afi->family != family)
+			continue;
+
+		ctx->afi = afi;
+		list_for_each_entry_safe(table, nt, &afi->tables, list) {
+			if (nla[NFTA_TABLE_NAME] &&
+			    nla_strcmp(nla[NFTA_TABLE_NAME], table->name) != 0)
+				continue;
+
+			ctx->table = table;
+
+			err = nft_flush_table(ctx);
+			if (err < 0)
+				goto out;
+		}
+	}
+out:
+	return err;
+}
+
 static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
 			      const struct nlattr * const nla[])
@@ -718,6 +779,10 @@ static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 	int family = nfmsg->nfgen_family;
 	struct nft_ctx ctx;
 
+	nft_ctx_init(&ctx, skb, nlh, NULL, NULL, NULL, nla);
+	if (family == AF_UNSPEC || nla[NFTA_TABLE_NAME] == NULL)
+		return nft_flush(&ctx, family);
+
 	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
@@ -727,12 +792,11 @@ static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 		return PTR_ERR(table);
 	if (table->flags & NFT_TABLE_INACTIVE)
 		return -ENOENT;
-	if (table->use > 0)
-		return -EBUSY;
 
-	nft_ctx_init(&ctx, skb, nlh, afi, table, NULL, nla);
+	ctx.afi = afi;
+	ctx.table = table;
 
-	return nft_deltable(&ctx);
+	return nft_flush_table(&ctx);
 }
 
 static void nf_tables_table_destroy(struct nft_ctx *ctx)
-- 
1.7.10.4
