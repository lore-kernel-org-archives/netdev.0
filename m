From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/22] netfilter: nf_tables: add nft_set_lookup()
Date: Mon, 20 Mar 2017 11:08:35 +0100
Message-ID: <1490004530-9128-8-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52108 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754032AbdCTKJj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 74FAD523EF
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 65C70DA3FA
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DD1BCDA80B
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:05 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new function consolidates set lookup via either name or ID by
introducing a new nft_set_lookup() function. Replace existing spots
where we can use this too.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  9 +++++----
 net/netfilter/nf_tables_api.c     | 31 ++++++++++++++++++++++++-------
 net/netfilter/nft_dynset.c        | 14 ++++----------
 net/netfilter/nft_lookup.c        | 14 ++++----------
 net/netfilter/nft_objref.c        | 14 ++++----------
 5 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 2aa8a9d80fbe..f0d46726d06e 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -385,10 +385,11 @@ static inline struct nft_set *nft_set_container_of(const void *priv)
 	return (void *)priv - offsetof(struct nft_set, data);
 }
 
-struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
-				     const struct nlattr *nla, u8 genmask);
-struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
-					  const struct nlattr *nla, u8 genmask);
+struct nft_set *nft_set_lookup(const struct net *net,
+			       const struct nft_table *table,
+			       const struct nlattr *nla_set_name,
+			       const struct nlattr *nla_set_id,
+			       u8 genmask);
 
 static inline unsigned long nft_set_gc_interval(const struct nft_set *set)
 {
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index fd8789eccc92..4559f5d66bcc 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2534,8 +2534,8 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx, struct net *net,
 	return 0;
 }
 
-struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
-				     const struct nlattr *nla, u8 genmask)
+static struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
+					    const struct nlattr *nla, u8 genmask)
 {
 	struct nft_set *set;
 
@@ -2549,11 +2549,10 @@ struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
 	}
 	return ERR_PTR(-ENOENT);
 }
-EXPORT_SYMBOL_GPL(nf_tables_set_lookup);
 
-struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
-					  const struct nlattr *nla,
-					  u8 genmask)
+static struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
+						 const struct nlattr *nla,
+						 u8 genmask)
 {
 	struct nft_trans *trans;
 	u32 id = ntohl(nla_get_be32(nla));
@@ -2568,7 +2567,25 @@ struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
 	}
 	return ERR_PTR(-ENOENT);
 }
-EXPORT_SYMBOL_GPL(nf_tables_set_lookup_byid);
+
+struct nft_set *nft_set_lookup(const struct net *net,
+			       const struct nft_table *table,
+			       const struct nlattr *nla_set_name,
+			       const struct nlattr *nla_set_id,
+			       u8 genmask)
+{
+	struct nft_set *set;
+
+	set = nf_tables_set_lookup(table, nla_set_name, genmask);
+	if (IS_ERR(set)) {
+		if (!nla_set_id)
+			return set;
+
+		set = nf_tables_set_lookup_byid(net, nla_set_id, genmask);
+	}
+	return set;
+}
+EXPORT_SYMBOL_GPL(nft_set_lookup);
 
 static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 				    const char *name)
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 049ad2d9ee66..3948da380259 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -133,16 +133,10 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 			priv->invert = true;
 	}
 
-	set = nf_tables_set_lookup(ctx->table, tb[NFTA_DYNSET_SET_NAME],
-				   genmask);
-	if (IS_ERR(set)) {
-		if (tb[NFTA_DYNSET_SET_ID])
-			set = nf_tables_set_lookup_byid(ctx->net,
-							tb[NFTA_DYNSET_SET_ID],
-							genmask);
-		if (IS_ERR(set))
-			return PTR_ERR(set);
-	}
+	set = nft_set_lookup(ctx->net, ctx->table, tb[NFTA_DYNSET_SET_NAME],
+			     tb[NFTA_DYNSET_SET_ID], genmask);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
 
 	if (set->ops->update == NULL)
 		return -EOPNOTSUPP;
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index e21aea7e5ec8..475570e89ede 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -71,16 +71,10 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 	    tb[NFTA_LOOKUP_SREG] == NULL)
 		return -EINVAL;
 
-	set = nf_tables_set_lookup(ctx->table, tb[NFTA_LOOKUP_SET], genmask);
-	if (IS_ERR(set)) {
-		if (tb[NFTA_LOOKUP_SET_ID]) {
-			set = nf_tables_set_lookup_byid(ctx->net,
-							tb[NFTA_LOOKUP_SET_ID],
-							genmask);
-		}
-		if (IS_ERR(set))
-			return PTR_ERR(set);
-	}
+	set = nft_set_lookup(ctx->net, ctx->table, tb[NFTA_LOOKUP_SET],
+			     tb[NFTA_LOOKUP_SET_ID], genmask);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
 
 	if (set->flags & NFT_SET_EVAL)
 		return -EOPNOTSUPP;
diff --git a/net/netfilter/nft_objref.c b/net/netfilter/nft_objref.c
index 1ae8c49ca4a1..1dd428fbaaa3 100644
--- a/net/netfilter/nft_objref.c
+++ b/net/netfilter/nft_objref.c
@@ -116,16 +116,10 @@ static int nft_objref_map_init(const struct nft_ctx *ctx,
 	struct nft_set *set;
 	int err;
 
-	set = nf_tables_set_lookup(ctx->table, tb[NFTA_OBJREF_SET_NAME], genmask);
-	if (IS_ERR(set)) {
-		if (tb[NFTA_OBJREF_SET_ID]) {
-			set = nf_tables_set_lookup_byid(ctx->net,
-							tb[NFTA_OBJREF_SET_ID],
-							genmask);
-		}
-		if (IS_ERR(set))
-			return PTR_ERR(set);
-	}
+	set = nft_set_lookup(ctx->net, ctx->table, tb[NFTA_OBJREF_SET_NAME],
+			     tb[NFTA_OBJREF_SET_ID], genmask);
+	if (IS_ERR(set))
+		return PTR_ERR(set);
 
 	if (!(set->flags & NFT_SET_OBJECT))
 		return -EINVAL;
-- 
2.1.4
