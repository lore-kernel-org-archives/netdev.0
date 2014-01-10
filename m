From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/23] netfilter: nf_tables: restore chain change atomicity
Date: Fri, 10 Jan 2014 01:35:31 +0100
Message-ID: <1389314142-17969-13-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51548 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757176AbaAJAgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:10 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Chain counter validation is performed after the chain policy has
potentially been changed. Move counter validation/setting before
changing of the chain policy to fix this.

Additionally fix a memory leak if chain counter allocation fails
for new chains, remove an unnecessary free_percpu() and move
counter allocation for new chains

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   43 ++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 30fad4f..d275d38 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -880,9 +880,6 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		    !IS_ERR(nf_tables_chain_lookup(table, nla[NFTA_CHAIN_NAME])))
 			return -EEXIST;
 
-		if (nla[NFTA_CHAIN_POLICY])
-			nft_base_chain(chain)->policy = policy;
-
 		if (nla[NFTA_CHAIN_COUNTERS]) {
 			if (!(chain->flags & NFT_BASE_CHAIN))
 				return -EOPNOTSUPP;
@@ -893,6 +890,9 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 				return err;
 		}
 
+		if (nla[NFTA_CHAIN_POLICY])
+			nft_base_chain(chain)->policy = policy;
+
 		if (nla[NFTA_CHAIN_HANDLE] && name)
 			nla_strlcpy(chain->name, name, NFT_CHAIN_MAXNAMELEN);
 
@@ -934,6 +934,24 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		if (basechain == NULL)
 			return -ENOMEM;
 
+		if (nla[NFTA_CHAIN_COUNTERS]) {
+			err = nf_tables_counters(basechain,
+						 nla[NFTA_CHAIN_COUNTERS]);
+			if (err < 0) {
+				kfree(basechain);
+				return err;
+			}
+		} else {
+			struct nft_stats __percpu *newstats;
+
+			newstats = alloc_percpu(struct nft_stats);
+			if (newstats == NULL) {
+				kfree(basechain);
+				return -ENOMEM;
+			}
+			rcu_assign_pointer(basechain->stats, newstats);
+		}
+
 		basechain->type = type;
 		chain = &basechain->chain;
 
@@ -953,25 +971,6 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 		chain->flags |= NFT_BASE_CHAIN;
 		basechain->policy = policy;
-
-		if (nla[NFTA_CHAIN_COUNTERS]) {
-			err = nf_tables_counters(basechain,
-						 nla[NFTA_CHAIN_COUNTERS]);
-			if (err < 0) {
-				free_percpu(basechain->stats);
-				kfree(basechain);
-				return err;
-			}
-		} else {
-			struct nft_stats __percpu *newstats;
-
-			newstats = alloc_percpu(struct nft_stats);
-			if (newstats == NULL)
-				return -ENOMEM;
-
-			rcu_assign_pointer(nft_base_chain(chain)->stats,
-					   newstats);
-		}
 	} else {
 		chain = kzalloc(sizeof(*chain), GFP_KERNEL);
 		if (chain == NULL)
-- 
1.7.10.4
