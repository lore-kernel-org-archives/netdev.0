From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 3/8] fib_trie: Fib find node should return parent
Date: Wed, 04 Mar 2015 15:01:59 -0800
Message-ID: <20150304225925.1612.40190.stgit@ahduyck-vm-fedora20>
References: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105AbbCDXCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 18:02:01 -0500
In-Reply-To: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the parent pointer is returned by reference in
fib_find_node.  By doing this I can use it to find the parent node when I
am performing an insertion and I don't have to look for it again in
fib_insert_node.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

v2: Updated index check to use 1ul << n->bits and add bits == KEYLENGTH info
    Renamed tp to tn in order to be consistent with leaf_walk_rcu
    Added pn to track parent via local variable instead of pointer

 net/ipv4/fib_trie.c |   42 ++++++++++++++++++++++++------------------
 1 file changed, 24 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index bf488ce..5d0f145 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -912,9 +912,9 @@ static void fib_insert_alias(struct tnode *l, struct fib_alias *fa,
 }
 
 /* rcu_read_lock needs to be hold by caller from readside */
-static struct tnode *fib_find_node(struct trie *t, u32 key)
+static struct tnode *fib_find_node(struct trie *t, struct tnode **tn, u32 key)
 {
-	struct tnode *n = rcu_dereference_rtnl(t->trie);
+	struct tnode *pn = NULL, *n = rcu_dereference_rtnl(t->trie);
 
 	while (n) {
 		unsigned long index = get_index(key, n);
@@ -924,21 +924,30 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 		 * prefix plus zeros for the bits in the cindex. The index
 		 * is the difference between the key and this value.  From
 		 * this we can actually derive several pieces of data.
-		 *   if (index & (~0ul << bits))
+		 *   if (index >= (1ul << bits))
 		 *     we have a mismatch in skip bits and failed
 		 *   else
 		 *     we know the value is cindex
+		 *
+		 * This check is safe even if bits == KEYLENGTH due to the
+		 * fact that we can only allocate a node with 32 bits if a
+		 * long is greater than 32 bits.
 		 */
-		if (index & (~0ul << n->bits))
-			return NULL;
+		if (index >= (1ul << n->bits)) {
+			n = NULL;
+			break;
+		}
 
 		/* we have found a leaf. Prefixes have already been compared */
 		if (IS_LEAF(n))
 			break;
 
+		pn = n;
 		n = tnode_get_child_rcu(n, index);
 	}
 
+	*tn = pn;
+
 	return n;
 }
 
@@ -1071,15 +1080,15 @@ static struct tnode *fib_insert_node(struct trie *t, u32 key, int plen)
  */
 int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
+	struct tnode *l, *tp;
 	struct fib_info *fi;
 	u8 plen = cfg->fc_dst_len;
 	u8 slen = KEYLENGTH - plen;
 	u8 tos = cfg->fc_tos;
-	u32 key, mask;
+	u32 key;
 	int err;
-	struct tnode *l;
 
 	if (plen > KEYLENGTH)
 		return -EINVAL;
@@ -1088,9 +1097,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
 
-	mask = ntohl(inet_make_mask(plen));
-
-	if (key & ~mask)
+	if ((plen < KEYLENGTH) && (key << plen))
 		return -EINVAL;
 
 	fi = fib_create_info(cfg);
@@ -1099,7 +1106,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		goto err;
 	}
 
-	l = fib_find_node(t, key);
+	l = fib_find_node(t, &tp, key);
 	fa = l ? fib_find_alias(&l->leaf, slen, tos, fi->fib_priority) : NULL;
 
 	/* Now fa, if non-NULL, points to the first fib alias
@@ -1406,22 +1413,21 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *fa_to_delete;
+	struct tnode *l, *tp;
 	u8 plen = cfg->fc_dst_len;
-	u8 tos = cfg->fc_tos;
 	u8 slen = KEYLENGTH - plen;
-	struct tnode *l;
-	u32 key, mask;
+	u8 tos = cfg->fc_tos;
+	u32 key;
 
 	if (plen > KEYLENGTH)
 		return -EINVAL;
 
 	key = ntohl(cfg->fc_dst);
-	mask = ntohl(inet_make_mask(plen));
 
-	if (key & ~mask)
+	if ((plen < KEYLENGTH) && (key << plen))
 		return -EINVAL;
 
-	l = fib_find_node(t, key);
+	l = fib_find_node(t, &tp, key);
 	if (!l)
 		return -ESRCH;
 
