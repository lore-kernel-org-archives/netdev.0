From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/15] netfilter: nf_tables: add transaction helper functions
Date: Thu, 26 Mar 2015 13:07:01 +0100
Message-ID: <1427371622-4466-15-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add some helper functions for building the genmask as preparation for
set transactions.

Also add a little documentation how this stuff actually works.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   28 ++++++++++++++++++++++++++++
 net/netfilter/nf_tables_api.c     |   17 ++++++-----------
 net/netfilter/nf_tables_core.c    |    6 +-----
 3 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f190d26..4c46a32 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -720,6 +720,34 @@ void nft_unregister_expr(struct nft_expr_type *);
 #define MODULE_ALIAS_NFT_SET() \
 	MODULE_ALIAS("nft-set")
 
+/*
+ * The gencursor defines two generations, the currently active and the
+ * next one. Objects contain a bitmask of 2 bits specifying the generations
+ * they're active in. A set bit means they're inactive in the generation
+ * represented by that bit.
+ *
+ * New objects start out as inactive in the current and active in the
+ * next generation. When committing the ruleset the bitmask is cleared,
+ * meaning they're active in all generations. When removing an object,
+ * it is set inactive in the next generation. After committing the ruleset,
+ * the objects are removed.
+ */
+static inline unsigned int nft_gencursor_next(const struct net *net)
+{
+	return net->nft.gencursor + 1 == 1 ? 1 : 0;
+}
+
+static inline u8 nft_genmask_next(const struct net *net)
+{
+	return 1 << nft_gencursor_next(net);
+}
+
+static inline u8 nft_genmask_cur(const struct net *net)
+{
+	/* Use ACCESS_ONCE() to prevent refetching the value for atomicity */
+	return 1 << ACCESS_ONCE(net->nft.gencursor);
+}
+
 /**
  *	struct nft_trans - nf_tables object update in transaction
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b35512f..66fa5e9 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -198,36 +198,31 @@ static int nft_delchain(struct nft_ctx *ctx)
 static inline bool
 nft_rule_is_active(struct net *net, const struct nft_rule *rule)
 {
-	return (rule->genmask & (1 << net->nft.gencursor)) == 0;
-}
-
-static inline int gencursor_next(struct net *net)
-{
-	return net->nft.gencursor+1 == 1 ? 1 : 0;
+	return (rule->genmask & nft_genmask_cur(net)) == 0;
 }
 
 static inline int
 nft_rule_is_active_next(struct net *net, const struct nft_rule *rule)
 {
-	return (rule->genmask & (1 << gencursor_next(net))) == 0;
+	return (rule->genmask & nft_genmask_next(net)) == 0;
 }
 
 static inline void
 nft_rule_activate_next(struct net *net, struct nft_rule *rule)
 {
 	/* Now inactive, will be active in the future */
-	rule->genmask = (1 << net->nft.gencursor);
+	rule->genmask = nft_genmask_cur(net);
 }
 
 static inline void
 nft_rule_deactivate_next(struct net *net, struct nft_rule *rule)
 {
-	rule->genmask = (1 << gencursor_next(net));
+	rule->genmask = nft_genmask_next(net);
 }
 
 static inline void nft_rule_clear(struct net *net, struct nft_rule *rule)
 {
-	rule->genmask &= ~(1 << gencursor_next(net));
+	rule->genmask &= ~nft_genmask_next(net);
 }
 
 static int
@@ -3626,7 +3621,7 @@ static int nf_tables_commit(struct sk_buff *skb)
 	while (++net->nft.base_seq == 0);
 
 	/* A new generation has just started */
-	net->nft.gencursor = gencursor_next(net);
+	net->nft.gencursor = nft_gencursor_next(net);
 
 	/* Make sure all packets have left the previous generation before
 	 * purging old rules.
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 4429008..ef4dfcb 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -121,11 +121,7 @@ nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
 	struct nft_stats *stats;
 	int rulenum;
-	/*
-	 * Cache cursor to avoid problems in case that the cursor is updated
-	 * while traversing the ruleset.
-	 */
-	unsigned int gencursor = ACCESS_ONCE(net->nft.gencursor);
+	unsigned int gencursor = nft_genmask_cur(net);
 
 do_chain:
 	rulenum = 0;
-- 
1.7.10.4

