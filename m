From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: nf_tables: fix addition/deletion of elements from commit/abort
Date: Thu,  5 Mar 2015 21:48:44 +0100
Message-ID: <1425588529-4573-3-git-send-email-pablo@netfilter.org>
References: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34425 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757113AbbCEUpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 15:45:17 -0500
In-Reply-To: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have several problems in this path:

1) There is a use-after-free when removing individual elements from
   the commit path.

2) We have to uninit() the data part of the element from the abort
   path to avoid a chain refcount leak.

3) We have to check for set->flags to see if there's a mapping, instead
   of the element flags.

4) We have to check for !(flags & NFT_SET_ELEM_INTERVAL_END) to skip
   elements that are part of the interval that have no data part, so
   they don't need to be uninit().

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 199fd0f..a8c9462 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3612,12 +3612,11 @@ static int nf_tables_commit(struct sk_buff *skb)
 						 &te->elem,
 						 NFT_MSG_DELSETELEM, 0);
 			te->set->ops->get(te->set, &te->elem);
-			te->set->ops->remove(te->set, &te->elem);
 			nft_data_uninit(&te->elem.key, NFT_DATA_VALUE);
-			if (te->elem.flags & NFT_SET_MAP) {
-				nft_data_uninit(&te->elem.data,
-						te->set->dtype);
-			}
+			if (te->set->flags & NFT_SET_MAP &&
+			    !(te->elem.flags & NFT_SET_ELEM_INTERVAL_END))
+				nft_data_uninit(&te->elem.data, te->set->dtype);
+			te->set->ops->remove(te->set, &te->elem);
 			nft_trans_destroy(trans);
 			break;
 		}
@@ -3658,7 +3657,7 @@ static int nf_tables_abort(struct sk_buff *skb)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nft_trans *trans, *next;
-	struct nft_set *set;
+	struct nft_trans_elem *te;
 
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
 		switch (trans->msg_type) {
@@ -3719,9 +3718,13 @@ static int nf_tables_abort(struct sk_buff *skb)
 			break;
 		case NFT_MSG_NEWSETELEM:
 			nft_trans_elem_set(trans)->nelems--;
-			set = nft_trans_elem_set(trans);
-			set->ops->get(set, &nft_trans_elem(trans));
-			set->ops->remove(set, &nft_trans_elem(trans));
+			te = (struct nft_trans_elem *)trans->data;
+			te->set->ops->get(te->set, &te->elem);
+			nft_data_uninit(&te->elem.key, NFT_DATA_VALUE);
+			if (te->set->flags & NFT_SET_MAP &&
+			    !(te->elem.flags & NFT_SET_ELEM_INTERVAL_END))
+				nft_data_uninit(&te->elem.data, te->set->dtype);
+			te->set->ops->remove(te->set, &te->elem);
 			nft_trans_destroy(trans);
 			break;
 		case NFT_MSG_DELSETELEM:
-- 
1.7.10.4
