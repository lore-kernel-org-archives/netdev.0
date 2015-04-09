From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/20] netfilter: nf_tables: support different set binding types
Date: Thu,  9 Apr 2015 13:35:02 +0200
Message-ID: <1428579304-5520-19-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33150 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933041AbbDILbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:21 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Currently a set binding is assumed to be related to a lookup and, in
case of maps, a data load.

In order to use bindings for set updates, the loop detection checks
must be restricted to map operations only. Add a flags member to the
binding struct to hold the set "action" flags such as NFT_SET_MAP,
and perform loop detection based on these.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c     |   11 ++++++++---
 net/netfilter/nft_lookup.c        |    2 ++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 7464233..e7e6365 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -316,6 +316,7 @@ static inline unsigned long nft_set_gc_interval(const struct nft_set *set)
  *
  *	@list: set bindings list node
  *	@chain: chain containing the rule bound to the set
+ *	@flags: set action flags
  *
  *	A set binding contains all information necessary for validation
  *	of new elements added to a bound set.
@@ -323,6 +324,7 @@ static inline unsigned long nft_set_gc_interval(const struct nft_set *set)
 struct nft_set_binding {
 	struct list_head		list;
 	const struct nft_chain		*chain;
+	u32				flags;
 };
 
 int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 27d1bf5..90b8984 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2811,12 +2811,13 @@ int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
 	if (!list_empty(&set->bindings) && set->flags & NFT_SET_ANONYMOUS)
 		return -EBUSY;
 
-	if (set->flags & NFT_SET_MAP) {
+	if (binding->flags & NFT_SET_MAP) {
 		/* If the set is already bound to the same chain all
 		 * jumps are already validated for that chain.
 		 */
 		list_for_each_entry(i, &set->bindings, list) {
-			if (i->chain == binding->chain)
+			if (binding->flags & NFT_SET_MAP &&
+			    i->chain == binding->chain)
 				goto bind;
 		}
 
@@ -3312,6 +3313,9 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 				.chain	= (struct nft_chain *)binding->chain,
 			};
 
+			if (!(binding->flags & NFT_SET_MAP))
+				continue;
+
 			err = nft_validate_data_load(&bind_ctx, dreg,
 						     &data, d2.type);
 			if (err < 0)
@@ -4063,7 +4067,8 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 			continue;
 
 		list_for_each_entry(binding, &set->bindings, list) {
-			if (binding->chain != chain)
+			if (!(binding->flags & NFT_SET_MAP) ||
+			    binding->chain != chain)
 				continue;
 
 			iter.skip 	= 0;
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index a5f30b8..d8cf86f 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -92,6 +92,8 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 	} else if (set->flags & NFT_SET_MAP)
 		return -EINVAL;
 
+	priv->binding.flags = set->flags & NFT_SET_MAP;
+
 	err = nf_tables_bind_set(ctx, set, &priv->binding);
 	if (err < 0)
 		return err;
-- 
1.7.10.4
