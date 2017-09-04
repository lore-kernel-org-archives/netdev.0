From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/12] netfilter: nf_tables: support for recursive chain deletion
Date: Mon,  4 Sep 2017 22:11:14 +0200
Message-ID: <1504555874-4168-13-git-send-email-pablo@netfilter.org>
References: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch sorts out an asymmetry in deletions. Currently, table and set
deletion commands come with an implicit content flush on deletion.
However, chain deletion results in -EBUSY if there is content in this
chain, so no implicit flush happens. So you have to send a flush command
in first place to delete chains, this is inconsistent and it can be
annoying in terms of user experience.

This patch uses the new NLM_F_NONREC flag to request non-recursive chain
deletion, ie. if the chain to be removed contains rules, then this
returns EBUSY. This problem was discussed during the NFWS'17 in Faro,
Portugal. In iptables, you hit -EBUSY if you try to delete a chain that
contains rules, so you have to flush first before you can remove
anything. Since iptables-compat uses the nf_tables netlink interface, it
has to use the NLM_F_NONREC flag from userspace to retain the original
iptables semantics, ie.  bail out on removing chains that contain rules.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 47fc7cd3f936..929927171426 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1617,8 +1617,11 @@ static int nf_tables_delchain(struct net *net, struct sock *nlsk,
 	struct nft_af_info *afi;
 	struct nft_table *table;
 	struct nft_chain *chain;
+	struct nft_rule *rule;
 	int family = nfmsg->nfgen_family;
 	struct nft_ctx ctx;
+	u32 use;
+	int err;
 
 	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
@@ -1631,11 +1634,30 @@ static int nf_tables_delchain(struct net *net, struct sock *nlsk,
 	chain = nf_tables_chain_lookup(table, nla[NFTA_CHAIN_NAME], genmask);
 	if (IS_ERR(chain))
 		return PTR_ERR(chain);
-	if (chain->use > 0)
+
+	if (nlh->nlmsg_flags & NLM_F_NONREC &&
+	    chain->use > 0)
 		return -EBUSY;
 
 	nft_ctx_init(&ctx, net, skb, nlh, afi, table, chain, nla);
 
+	use = chain->use;
+	list_for_each_entry(rule, &chain->rules, list) {
+		if (!nft_is_active_next(net, rule))
+			continue;
+		use--;
+
+		err = nft_delrule(&ctx, rule);
+		if (err < 0)
+			return err;
+	}
+
+	/* There are rules and elements that are still holding references to us,
+	 * we cannot do a recursive removal in this case.
+	 */
+	if (use > 0)
+		return -EBUSY;
+
 	return nft_delchain(&ctx);
 }
 
-- 
2.1.4

