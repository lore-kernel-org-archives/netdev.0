From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/18] netfilter: nftables: Only run the nftables chains in the proper netns
Date: Tue,  4 Aug 2015 12:02:35 +0200
Message-ID: <1438682568-8346-6-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55990 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933039AbbHDJ5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:22 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

- Register the nftables chains in the network namespace that they need
  to run in.

- Remove the hacks that stopped chains running in the wrong network
  namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c  |    8 ++++++--
 net/netfilter/nf_tables_core.c |    5 -----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index cfe6368..4a41eb9 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -130,20 +130,24 @@ static void nft_trans_destroy(struct nft_trans *trans)
 int nft_register_basechain(struct nft_base_chain *basechain,
 			   unsigned int hook_nops)
 {
+	struct net *net = read_pnet(&basechain->pnet);
+
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return 0;
 
-	return nf_register_hooks(basechain->ops, hook_nops);
+	return nf_register_net_hooks(net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_register_basechain);
 
 void nft_unregister_basechain(struct nft_base_chain *basechain,
 			      unsigned int hook_nops)
 {
+	struct net *net = read_pnet(&basechain->pnet);
+
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return;
 
-	nf_unregister_hooks(basechain->ops, hook_nops);
+	nf_unregister_net_hooks(net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_unregister_basechain);
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index f77bad4..05d0b03 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -114,7 +114,6 @@ unsigned int
 nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
 	const struct nft_chain *chain = ops->priv, *basechain = chain;
-	const struct net *chain_net = read_pnet(&nft_base_chain(basechain)->pnet);
 	const struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
@@ -125,10 +124,6 @@ nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 	int rulenum;
 	unsigned int gencursor = nft_genmask_cur(net);
 
-	/* Ignore chains that are not for the current network namespace */
-	if (!net_eq(net, chain_net))
-		return NF_ACCEPT;
-
 do_chain:
 	rulenum = 0;
 	rule = list_entry(&chain->rules, struct nft_rule, list);
-- 
1.7.10.4
