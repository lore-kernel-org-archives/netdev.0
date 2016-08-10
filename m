From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/9] netfilter: nft_rbtree: ignore inactive matching element with no descendants
Date: Wed, 10 Aug 2016 21:16:39 +0200
Message-ID: <1470856605-7903-4-git-send-email-pablo@netfilter.org>
References: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58020 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933587AbcHJTQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 15:16:56 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9AFE81F18D1
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8C583100A63
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9F8AFFF154
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:52 +0200 (CEST)
In-Reply-To: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we find a matching element that is inactive with no descendants, we
jump to the found label, then crash because of nul-dereference on the
left branch.

Fix this by checking that the element is active and not an interval end
and skipping the logic that only applies to the tree iteration.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Tested-by: Anders K. Pedersen <akp@akp.dk>
---
 net/netfilter/nft_rbtree.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 6473936..ffe9ae0 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -70,7 +70,6 @@ static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
 		} else if (d > 0)
 			parent = parent->rb_right;
 		else {
-found:
 			if (!nft_set_elem_active(&rbe->ext, genmask)) {
 				parent = parent->rb_left;
 				continue;
@@ -84,9 +83,12 @@ found:
 		}
 	}
 
-	if (set->flags & NFT_SET_INTERVAL && interval != NULL) {
-		rbe = interval;
-		goto found;
+	if (set->flags & NFT_SET_INTERVAL && interval != NULL &&
+	    nft_set_elem_active(&interval->ext, genmask) &&
+	    !nft_rbtree_interval_end(interval)) {
+		spin_unlock_bh(&nft_rbtree_lock);
+		*ext = &interval->ext;
+		return true;
 	}
 out:
 	spin_unlock_bh(&nft_rbtree_lock);
-- 
2.1.4
