From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/23] netfilter: nf_tables: split chain policy validation from actually setting it
Date: Fri, 10 Jan 2014 01:35:30 +0100
Message-ID: <1389314142-17969-12-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51538 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756989AbaAJAgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:09 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Currently nf_tables_newchain() atomicity is broken because of having
validation of some netlink attributes performed after changing attributes
of the chain. The chain policy is (currently) fine, but split it up as
preparation for the following fixes and to avoid future mistakes.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   56 +++++++++++++++--------------------------
 1 file changed, 20 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 572d88d..30fad4f 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -760,22 +760,6 @@ err:
 	return err;
 }
 
-static int
-nf_tables_chain_policy(struct nft_base_chain *chain, const struct nlattr *attr)
-{
-	switch (ntohl(nla_get_be32(attr))) {
-	case NF_DROP:
-		chain->policy = NF_DROP;
-		break;
-	case NF_ACCEPT:
-		chain->policy = NF_ACCEPT;
-		break;
-	default:
-		return -EINVAL;
-	}
-	return 0;
-}
-
 static const struct nla_policy nft_counter_policy[NFTA_COUNTER_MAX + 1] = {
 	[NFTA_COUNTER_PACKETS]	= { .type = NLA_U64 },
 	[NFTA_COUNTER_BYTES]	= { .type = NLA_U64 },
@@ -834,6 +818,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	struct nlattr *ha[NFTA_HOOK_MAX + 1];
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
+	u8 policy = NF_ACCEPT;
 	u64 handle = 0;
 	unsigned int i;
 	int err;
@@ -869,6 +854,22 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		}
 	}
 
+	if (nla[NFTA_CHAIN_POLICY]) {
+		if ((chain != NULL &&
+		    !(chain->flags & NFT_BASE_CHAIN)) ||
+		    nla[NFTA_CHAIN_HOOK] == NULL)
+			return -EOPNOTSUPP;
+
+		policy = nla_get_be32(nla[NFTA_CHAIN_POLICY]);
+		switch (policy) {
+		case NF_DROP:
+		case NF_ACCEPT:
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
 	if (chain != NULL) {
 		if (nlh->nlmsg_flags & NLM_F_EXCL)
 			return -EEXIST;
@@ -879,15 +880,8 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		    !IS_ERR(nf_tables_chain_lookup(table, nla[NFTA_CHAIN_NAME])))
 			return -EEXIST;
 
-		if (nla[NFTA_CHAIN_POLICY]) {
-			if (!(chain->flags & NFT_BASE_CHAIN))
-				return -EOPNOTSUPP;
-
-			err = nf_tables_chain_policy(nft_base_chain(chain),
-						     nla[NFTA_CHAIN_POLICY]);
-			if (err < 0)
-				return err;
-		}
+		if (nla[NFTA_CHAIN_POLICY])
+			nft_base_chain(chain)->policy = policy;
 
 		if (nla[NFTA_CHAIN_COUNTERS]) {
 			if (!(chain->flags & NFT_BASE_CHAIN))
@@ -958,17 +952,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		}
 
 		chain->flags |= NFT_BASE_CHAIN;
-
-		if (nla[NFTA_CHAIN_POLICY]) {
-			err = nf_tables_chain_policy(basechain,
-						     nla[NFTA_CHAIN_POLICY]);
-			if (err < 0) {
-				free_percpu(basechain->stats);
-				kfree(basechain);
-				return err;
-			}
-		} else
-			basechain->policy = NF_ACCEPT;
+		basechain->policy = policy;
 
 		if (nla[NFTA_CHAIN_COUNTERS]) {
 			err = nf_tables_counters(basechain,
-- 
1.7.10.4
