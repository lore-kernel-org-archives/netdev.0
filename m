From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/18] netfilter: nft_rbtree: fix data handling of end interval elements
Date: Fri,  7 Feb 2014 18:41:42 +0100
Message-ID: <1391794904-4017-17-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41468 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964AbaBGRmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:17 -0500
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes several things which related to the handling of
end interval elements:

* Chain use underflow with intervals and map: If you add a rule
  using intervals+map that introduces a loop, the error path of the
  rbtree set decrements the chain refcount for each side of the
  interval, leading to a chain use counter underflow.

* Don't copy the data part of the end interval element since, this
  area is uninitialized and this confuses the loop detection code.

* Don't allocate room for the data part of end interval elements
  since this is unused.

So, after this patch the idea is that end interval elements don't
have a data part.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nft_rbtree.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index ca0c1b2..e21d69d 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -69,8 +69,10 @@ static void nft_rbtree_elem_destroy(const struct nft_set *set,
 				    struct nft_rbtree_elem *rbe)
 {
 	nft_data_uninit(&rbe->key, NFT_DATA_VALUE);
-	if (set->flags & NFT_SET_MAP)
+	if (set->flags & NFT_SET_MAP &&
+	    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
 		nft_data_uninit(rbe->data, set->dtype);
+
 	kfree(rbe);
 }
 
@@ -108,7 +110,8 @@ static int nft_rbtree_insert(const struct nft_set *set,
 	int err;
 
 	size = sizeof(*rbe);
-	if (set->flags & NFT_SET_MAP)
+	if (set->flags & NFT_SET_MAP &&
+	    !(elem->flags & NFT_SET_ELEM_INTERVAL_END))
 		size += sizeof(rbe->data[0]);
 
 	rbe = kzalloc(size, GFP_KERNEL);
@@ -117,7 +120,8 @@ static int nft_rbtree_insert(const struct nft_set *set,
 
 	rbe->flags = elem->flags;
 	nft_data_copy(&rbe->key, &elem->key);
-	if (set->flags & NFT_SET_MAP)
+	if (set->flags & NFT_SET_MAP &&
+	    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
 		nft_data_copy(rbe->data, &elem->data);
 
 	err = __nft_rbtree_insert(set, rbe);
@@ -153,7 +157,8 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
 			parent = parent->rb_right;
 		else {
 			elem->cookie = rbe;
-			if (set->flags & NFT_SET_MAP)
+			if (set->flags & NFT_SET_MAP &&
+			    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
 				nft_data_copy(&elem->data, rbe->data);
 			elem->flags = rbe->flags;
 			return 0;
@@ -177,7 +182,8 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
 		nft_data_copy(&elem.key, &rbe->key);
-		if (set->flags & NFT_SET_MAP)
+		if (set->flags & NFT_SET_MAP &&
+		    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
 			nft_data_copy(&elem.data, rbe->data);
 		elem.flags = rbe->flags;
 
-- 
1.7.10.4
