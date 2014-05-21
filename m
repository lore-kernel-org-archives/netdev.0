From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/25] netfilter: nf_tables: deconstify table and chain in context structure
Date: Wed, 21 May 2014 11:43:09 +0200
Message-ID: <1400665402-5835-12-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new transaction infrastructure updates the family, table and chain
objects in the context structure, so let's deconstify them. While at it,
move the context structure initialization routine to the top of the
source file as it will be also used from the table and chain routines.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    6 ++--
 net/netfilter/nf_tables_api.c     |   58 ++++++++++++++++++-------------------
 2 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 29ff1dc..9150523 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -83,9 +83,9 @@ struct nft_ctx {
 	struct net			*net;
 	const struct sk_buff		*skb;
 	const struct nlmsghdr		*nlh;
-	const struct nft_af_info	*afi;
-	const struct nft_table		*table;
-	const struct nft_chain		*chain;
+	struct nft_af_info		*afi;
+	struct nft_table		*table;
+	struct nft_chain		*chain;
 	const struct nlattr * const 	*nla;
 };
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a5ca900..3643bbc 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -88,6 +88,23 @@ nf_tables_afinfo_lookup(struct net *net, int family, bool autoload)
 	return ERR_PTR(-EAFNOSUPPORT);
 }
 
+static void nft_ctx_init(struct nft_ctx *ctx,
+			 const struct sk_buff *skb,
+			 const struct nlmsghdr *nlh,
+			 struct nft_af_info *afi,
+			 struct nft_table *table,
+			 struct nft_chain *chain,
+			 const struct nlattr * const *nla)
+{
+	ctx->net   = sock_net(skb->sk);
+	ctx->skb   = skb;
+	ctx->nlh   = nlh;
+	ctx->afi   = afi;
+	ctx->table = table;
+	ctx->chain = chain;
+	ctx->nla   = nla;
+}
+
 /*
  * Tables
  */
@@ -812,7 +829,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nlattr * uninitialized_var(name);
-	const struct nft_af_info *afi;
+	struct nft_af_info *afi;
 	struct nft_table *table;
 	struct nft_chain *chain;
 	struct nft_base_chain *basechain = NULL;
@@ -1024,7 +1041,7 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 			      const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	const struct nft_af_info *afi;
+	struct nft_af_info *afi;
 	struct nft_table *table;
 	struct nft_chain *chain;
 	struct net *net = sock_net(skb->sk);
@@ -1062,23 +1079,6 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 	return 0;
 }
 
-static void nft_ctx_init(struct nft_ctx *ctx,
-			 const struct sk_buff *skb,
-			 const struct nlmsghdr *nlh,
-			 const struct nft_af_info *afi,
-			 const struct nft_table *table,
-			 const struct nft_chain *chain,
-			 const struct nlattr * const *nla)
-{
-	ctx->net   = sock_net(skb->sk);
-	ctx->skb   = skb;
-	ctx->nlh   = nlh;
-	ctx->afi   = afi;
-	ctx->table = table;
-	ctx->chain = chain;
-	ctx->nla   = nla;
-}
-
 /*
  * Expressions
  */
@@ -1582,7 +1582,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 			     const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	const struct nft_af_info *afi;
+	struct nft_af_info *afi;
 	struct net *net = sock_net(skb->sk);
 	struct nft_table *table;
 	struct nft_chain *chain;
@@ -1763,9 +1763,9 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 			     const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	const struct nft_af_info *afi;
+	struct nft_af_info *afi;
 	struct net *net = sock_net(skb->sk);
-	const struct nft_table *table;
+	struct nft_table *table;
 	struct nft_chain *chain = NULL;
 	struct nft_rule *rule;
 	int family = nfmsg->nfgen_family, err = 0;
@@ -2009,8 +2009,8 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx,
 {
 	struct net *net = sock_net(skb->sk);
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	const struct nft_af_info *afi = NULL;
-	const struct nft_table *table = NULL;
+	struct nft_af_info *afi = NULL;
+	struct nft_table *table = NULL;
 
 	if (nfmsg->nfgen_family != NFPROTO_UNSPEC) {
 		afi = nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, false);
@@ -2244,7 +2244,7 @@ static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
 {
 	const struct nft_set *set;
 	unsigned int idx, s_idx = cb->args[0];
-	const struct nft_af_info *afi;
+	struct nft_af_info *afi;
 	struct nft_table *table, *cur_table = (struct nft_table *)cb->args[2];
 	struct net *net = sock_net(skb->sk);
 	int cur_family = cb->args[3];
@@ -2389,7 +2389,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_set_ops *ops;
-	const struct nft_af_info *afi;
+	struct nft_af_info *afi;
 	struct net *net = sock_net(skb->sk);
 	struct nft_table *table;
 	struct nft_set *set;
@@ -2651,8 +2651,8 @@ static int nft_ctx_init_from_elemattr(struct nft_ctx *ctx,
 				      const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	const struct nft_af_info *afi;
-	const struct nft_table *table;
+	struct nft_af_info *afi;
+	struct nft_table *table;
 	struct net *net = sock_net(skb->sk);
 
 	afi = nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, false);
@@ -2959,7 +2959,7 @@ static int nft_add_set_elem(const struct nft_ctx *ctx, struct nft_set *set,
 			struct nft_ctx bind_ctx = {
 				.afi	= ctx->afi,
 				.table	= ctx->table,
-				.chain	= binding->chain,
+				.chain	= (struct nft_chain *)binding->chain,
 			};
 
 			err = nft_validate_data_load(&bind_ctx, dreg,
-- 
1.7.10.4

