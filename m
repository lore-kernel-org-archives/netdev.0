From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: nf_tables: fix error handling of rule replacement
Date: Thu,  5 Mar 2015 21:48:49 +0100
Message-ID: <1425588529-4573-8-git-send-email-pablo@netfilter.org>
References: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34458 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244AbbCEUpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 15:45:22 -0500
In-Reply-To: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In general, if a transaction object is added to the list successfully,
we can rely on the abort path to undo what we've done. This allows us to
simplify the error handling of the rule replacement path in
nf_tables_newrule().

This implicitly fixes an unnecessary removal of the old rule, which
needs to be left in place if we fail to replace.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 74e4b87..6ab7779 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2045,12 +2045,6 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 
 err3:
 	list_del_rcu(&rule->list);
-	if (trans) {
-		list_del_rcu(&nft_trans_rule(trans)->list);
-		nft_rule_clear(net, nft_trans_rule(trans));
-		nft_trans_destroy(trans);
-		chain->use++;
-	}
 err2:
 	nf_tables_rule_destroy(&ctx, rule);
 err1:
-- 
1.7.10.4
