From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/36] netfilter: nft_rbtree: allow adjacent intervals with dynamic updates
Date: Mon,  9 May 2016 20:46:28 +0200
Message-ID: <1462819614-5402-11-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45703 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469AbcEISrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:14 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 26ECAE8E85
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:13 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 15FC3134700
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:13 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0C06E134704
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:11 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes dynamic element updates for adjacent intervals in the
rb-tree representation.

Since elements are sorted in the rb-tree, in case of adjacent nodes with
the same key, the assumption is that an interval end node must be placed
before an interval opening.

In tree lookup operations, the idea is to search for the closer element
that is smaller than the one we're searching for. Given that we'll have
two possible matchings, we have to take the opening interval in case of
adjacent nodes.

Range merges are not trivial with the current representation,
specifically we have to check if node extensions are equal and make sure
we keep the existing internal states around.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_rbtree.c | 40 +++++++++++++++++++++++++++++++++++-----
 1 file changed, 35 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 29f2ab8..f762094 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -35,6 +35,12 @@ static bool nft_rbtree_interval_end(const struct nft_rbtree_elem *rbe)
 	       (*nft_set_ext_flags(&rbe->ext) & NFT_SET_ELEM_INTERVAL_END);
 }
 
+static bool nft_rbtree_equal(const struct nft_set *set, const void *this,
+			     const struct nft_rbtree_elem *interval)
+{
+	return memcmp(this, nft_set_ext_key(&interval->ext), set->klen) == 0;
+}
+
 static bool nft_rbtree_lookup(const struct nft_set *set, const u32 *key,
 			      const struct nft_set_ext **ext)
 {
@@ -42,6 +48,7 @@ static bool nft_rbtree_lookup(const struct nft_set *set, const u32 *key,
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
 	const struct rb_node *parent;
 	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
+	const void *this;
 	int d;
 
 	spin_lock_bh(&nft_rbtree_lock);
@@ -49,9 +56,16 @@ static bool nft_rbtree_lookup(const struct nft_set *set, const u32 *key,
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
-		d = memcmp(nft_set_ext_key(&rbe->ext), key, set->klen);
+		this = nft_set_ext_key(&rbe->ext);
+		d = memcmp(this, key, set->klen);
 		if (d < 0) {
 			parent = parent->rb_left;
+			/* In case of adjacent ranges, we always see the high
+			 * part of the range in first place, before the low one.
+			 * So don't update interval if the keys are equal.
+			 */
+			if (interval && nft_rbtree_equal(set, this, interval))
+				continue;
 			interval = rbe;
 		} else if (d > 0)
 			parent = parent->rb_right;
@@ -101,9 +115,16 @@ static int __nft_rbtree_insert(const struct nft_set *set,
 		else if (d > 0)
 			p = &parent->rb_right;
 		else {
-			if (nft_set_elem_active(&rbe->ext, genmask))
-				return -EEXIST;
-			p = &parent->rb_left;
+			if (nft_set_elem_active(&rbe->ext, genmask)) {
+				if (nft_rbtree_interval_end(rbe) &&
+				    !nft_rbtree_interval_end(new))
+					p = &parent->rb_left;
+				else if (!nft_rbtree_interval_end(rbe) &&
+					 nft_rbtree_interval_end(new))
+					p = &parent->rb_right;
+				else
+					return -EEXIST;
+			}
 		}
 	}
 	rb_link_node(&new->node, parent, p);
@@ -148,7 +169,7 @@ static void *nft_rbtree_deactivate(const struct nft_set *set,
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct rb_node *parent = priv->root.rb_node;
-	struct nft_rbtree_elem *rbe;
+	struct nft_rbtree_elem *rbe, *this = elem->priv;
 	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 	int d;
 
@@ -166,6 +187,15 @@ static void *nft_rbtree_deactivate(const struct nft_set *set,
 				parent = parent->rb_left;
 				continue;
 			}
+			if (nft_rbtree_interval_end(rbe) &&
+			    !nft_rbtree_interval_end(this)) {
+				parent = parent->rb_left;
+				continue;
+			} else if (!nft_rbtree_interval_end(rbe) &&
+				   nft_rbtree_interval_end(this)) {
+				parent = parent->rb_right;
+				continue;
+			}
 			nft_set_elem_change_active(set, &rbe->ext);
 			return rbe;
 		}
-- 
2.1.4
