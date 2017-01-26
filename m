From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/14] netfilter: nf_tables: fix set->nelems counting with no NLM_F_EXCL
Date: Thu, 26 Jan 2017 17:38:05 +0100
Message-ID: <1485448687-6072-13-git-send-email-pablo@netfilter.org>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48658 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753799AbdAZQjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 11:39:25 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 46FDC8106
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:37 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 38EEAA7BEC
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:37 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D5A1CA7BF3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:34 +0100 (CET)
In-Reply-To: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the element exists and no NLM_F_EXCL is specified, do not bump
set->nelems, otherwise we leak one set element slot. This problem
amplifies if the set is full since the abort path always decrements the
counter for the -ENFILE case too, giving one spare extra slot.

Fix this by moving set->nelems update to nft_add_set_elem() after
successful element insertion. Moreover, remove the element if the set is
full so there is no need to rely on the abort path to undo things
anymore.

Fixes: c016c7e45ddf ("netfilter: nf_tables: honor NLM_F_EXCL flag in set element insertion")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b84c7b25219b..831a9a16f563 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3745,10 +3745,18 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err5;
 	}
 
+	if (set->size &&
+	    !atomic_add_unless(&set->nelems, 1, set->size + set->ndeact)) {
+		err = -ENFILE;
+		goto err6;
+	}
+
 	nft_trans_elem(trans) = elem;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
 	return 0;
 
+err6:
+	set->ops->remove(set, &elem);
 err5:
 	kfree(trans);
 err4:
@@ -3795,15 +3803,9 @@ static int nf_tables_newsetelem(struct net *net, struct sock *nlsk,
 		return -EBUSY;
 
 	nla_for_each_nested(attr, nla[NFTA_SET_ELEM_LIST_ELEMENTS], rem) {
-		if (set->size &&
-		    !atomic_add_unless(&set->nelems, 1, set->size + set->ndeact))
-			return -ENFILE;
-
 		err = nft_add_set_elem(&ctx, set, attr, nlh->nlmsg_flags);
-		if (err < 0) {
-			atomic_dec(&set->nelems);
+		if (err < 0)
 			break;
-		}
 	}
 	return err;
 }
-- 
2.1.4
