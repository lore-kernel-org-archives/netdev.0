From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/17] netfilter: nf_tables: destroy basechain and rules on netdevice removal
Date: Fri,  8 Jan 2016 15:02:02 +0100
Message-ID: <1452261737-7475-3-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53977 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142AbcAHOCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 09:02:49 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8BF2FDA883
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:02:48 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7BFE94C348
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:02:48 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 771304C348
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:02:46 +0100 (CET)
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the netdevice is destroyed, the resources that are attached should
be released too as they belong to the device that is now gone.

Suggested-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  5 +----
 net/netfilter/nf_tables_api.c     | 31 +++++++++++++++++++++------
 net/netfilter/nf_tables_netdev.c  | 45 ++++++++++++++++-----------------------
 3 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index a50f139..0191fbb 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -821,10 +821,7 @@ static inline struct nft_base_chain *nft_base_chain(const struct nft_chain *chai
 	return container_of(chain, struct nft_base_chain, chain);
 }
 
-int nft_register_basechain(struct nft_base_chain *basechain,
-			   unsigned int hook_nops);
-void nft_unregister_basechain(struct nft_base_chain *basechain,
-			      unsigned int hook_nops);
+int __nft_release_basechain(struct nft_ctx *ctx);
 
 unsigned int nft_do_chain(struct nft_pktinfo *pkt, void *priv);
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 8522731..5729844 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -131,8 +131,8 @@ static void nft_trans_destroy(struct nft_trans *trans)
 	kfree(trans);
 }
 
-int nft_register_basechain(struct nft_base_chain *basechain,
-			   unsigned int hook_nops)
+static int nft_register_basechain(struct nft_base_chain *basechain,
+				  unsigned int hook_nops)
 {
 	struct net *net = read_pnet(&basechain->pnet);
 
@@ -141,10 +141,9 @@ int nft_register_basechain(struct nft_base_chain *basechain,
 
 	return nf_register_net_hooks(net, basechain->ops, hook_nops);
 }
-EXPORT_SYMBOL_GPL(nft_register_basechain);
 
-void nft_unregister_basechain(struct nft_base_chain *basechain,
-			      unsigned int hook_nops)
+static void nft_unregister_basechain(struct nft_base_chain *basechain,
+				     unsigned int hook_nops)
 {
 	struct net *net = read_pnet(&basechain->pnet);
 
@@ -153,7 +152,6 @@ void nft_unregister_basechain(struct nft_base_chain *basechain,
 
 	nf_unregister_net_hooks(net, basechain->ops, hook_nops);
 }
-EXPORT_SYMBOL_GPL(nft_unregister_basechain);
 
 static int nf_tables_register_hooks(const struct nft_table *table,
 				    struct nft_chain *chain,
@@ -4590,6 +4588,27 @@ static int __net_init nf_tables_init_net(struct net *net)
 	return 0;
 }
 
+int __nft_release_basechain(struct nft_ctx *ctx)
+{
+	struct nft_rule *rule, *nr;
+
+	BUG_ON(!(ctx->chain->flags & NFT_BASE_CHAIN));
+
+	nf_tables_unregister_hooks(ctx->chain->table, ctx->chain,
+				   ctx->afi->nops);
+	list_for_each_entry_safe(rule, nr, &ctx->chain->rules, list) {
+		list_del(&rule->list);
+		ctx->chain->use--;
+		nf_tables_rule_destroy(ctx, rule);
+	}
+	list_del(&ctx->chain->list);
+	ctx->table->use--;
+	nf_tables_chain_destroy(ctx->chain);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__nft_release_basechain);
+
 /* Called by nft_unregister_afinfo() from __net_exit path, nfnl_lock is held. */
 static void __nft_release_afinfo(struct net *net, struct nft_af_info *afi)
 {
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 2bfd1fb..3e9c87b 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -156,35 +156,17 @@ static const struct nf_chain_type nft_filter_chain_netdev = {
 	.hook_mask	= (1 << NF_NETDEV_INGRESS),
 };
 
-static void nft_netdev_event(unsigned long event, struct nft_af_info *afi,
-			     struct net_device *dev, struct nft_table *table,
-			     struct nft_base_chain *basechain)
+static void nft_netdev_event(unsigned long event, struct net_device *dev,
+			     struct nft_ctx *ctx)
 {
-	switch (event) {
-	case NETDEV_REGISTER:
-		if (strcmp(basechain->dev_name, dev->name) != 0)
-			return;
+	struct nft_base_chain *basechain = nft_base_chain(ctx->chain);
 
-		BUG_ON(!(basechain->flags & NFT_BASECHAIN_DISABLED));
-
-		dev_hold(dev);
-		basechain->ops[0].dev = dev;
-		basechain->flags &= ~NFT_BASECHAIN_DISABLED;
-		if (!(table->flags & NFT_TABLE_F_DORMANT))
-			nft_register_basechain(basechain, afi->nops);
-		break;
+	switch (event) {
 	case NETDEV_UNREGISTER:
 		if (strcmp(basechain->dev_name, dev->name) != 0)
 			return;
 
-		BUG_ON(basechain->flags & NFT_BASECHAIN_DISABLED);
-
-		if (!(table->flags & NFT_TABLE_F_DORMANT))
-			nft_unregister_basechain(basechain, afi->nops);
-
-		dev_put(basechain->ops[0].dev);
-		basechain->ops[0].dev = NULL;
-		basechain->flags |= NFT_BASECHAIN_DISABLED;
+		__nft_release_basechain(ctx);
 		break;
 	case NETDEV_CHANGENAME:
 		if (dev->ifindex != basechain->ops[0].dev->ifindex)
@@ -201,20 +183,29 @@ static int nf_tables_netdev_event(struct notifier_block *this,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct nft_af_info *afi;
 	struct nft_table *table;
-	struct nft_chain *chain;
+	struct nft_chain *chain, *nr;
+	struct nft_ctx ctx = {
+		.net	= dev_net(dev),
+	};
+
+	if (event != NETDEV_UNREGISTER &&
+	    event != NETDEV_CHANGENAME)
+		return NOTIFY_DONE;
 
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
 	list_for_each_entry(afi, &dev_net(dev)->nft.af_info, list) {
+		ctx.afi = afi;
 		if (afi->family != NFPROTO_NETDEV)
 			continue;
 
 		list_for_each_entry(table, &afi->tables, list) {
-			list_for_each_entry(chain, &table->chains, list) {
+			ctx.table = table;
+			list_for_each_entry_safe(chain, nr, &table->chains, list) {
 				if (!(chain->flags & NFT_BASE_CHAIN))
 					continue;
 
-				nft_netdev_event(event, afi, dev, table,
-						 nft_base_chain(chain));
+				ctx.chain = chain;
+				nft_netdev_event(event, dev, &ctx);
 			}
 		}
 	}
-- 
2.1.4
