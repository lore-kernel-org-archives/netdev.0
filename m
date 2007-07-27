From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT 2/4] fib_trie: convert macros to inline
Date: Fri, 27 Jul 2007 08:59:19 +0100
Message-ID: <20070727080049.543753449@linux-foundation.org>
References: <20070727075917.470055328@linux-foundation.org>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51015 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764578AbXG0IBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 04:01:37 -0400
Content-Disposition: inline; filename=trie-demacro.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of some of the macro's in this code. If only used once, just
expand the usage in that spot. Otherwise convert to inline.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
--- a/net/ipv4/fib_trie.c	2007-07-27 08:00:30.000000000 +0100
+++ b/net/ipv4/fib_trie.c	2007-07-27 08:41:22.000000000 +0100
@@ -85,16 +85,12 @@
 #define MAX_STAT_DEPTH 32
 
 #define KEYLENGTH (8*sizeof(t_key))
-#define MASK_PFX(k, l) (((l)==0)?0:(k >> (KEYLENGTH-l)) << (KEYLENGTH-l))
-#define TKEY_GET_MASK(offset, bits) (((bits)==0)?0:((t_key)(-1) << (KEYLENGTH - bits) >> offset))
 
 typedef unsigned int t_key;
 
 #define T_TNODE 0
 #define T_LEAF  1
 #define NODE_TYPE_MASK	0x1UL
-#define NODE_TYPE(node) ((node)->parent & NODE_TYPE_MASK)
-
 #define IS_TNODE(n) (!(n->parent & T_LEAF))
 #define IS_LEAF(n) (n->parent & T_LEAF)
 
@@ -175,7 +171,8 @@ static inline struct tnode *node_parent(
 
 static inline void node_set_parent(struct node *node, struct tnode *ptr)
 {
-	rcu_assign_pointer(node->parent, (unsigned long)ptr | NODE_TYPE(node));
+	rcu_assign_pointer(node->parent,
+			   (unsigned long)ptr | (node->parent & NODE_TYPE_MASK));
 }
 
 /* rcu_read_lock needs to be hold by caller from readside */
@@ -192,6 +189,11 @@ static inline int tnode_child_length(con
 	return 1 << tn->bits;
 }
 
+static inline t_key mask_pfx(t_key k, unsigned short l)
+{
+	return (l == 0) ? 0 : k >> (KEYLENGTH - l) << (KEYLENGTH - l);
+}
+
 static inline t_key tkey_extract_bits(t_key a, int offset, int bits)
 {
 	if (offset < KEYLENGTH)
@@ -676,7 +678,7 @@ static struct tnode *inflate(struct trie
 		    inode->pos == oldtnode->pos + oldtnode->bits &&
 		    inode->bits > 1) {
 			struct tnode *left, *right;
-			t_key m = TKEY_GET_MASK(inode->pos, 1);
+			t_key m = ~0U << (KEYLENGTH - 1) >> inode->pos;
 
 			left = tnode_new(inode->key&(~m), inode->pos + 1,
 					 inode->bits - 1);
@@ -942,7 +944,7 @@ fib_find_node(struct trie *t, u32 key)
 	pos = 0;
 	n = rcu_dereference(t->trie);
 
-	while (n != NULL &&  NODE_TYPE(n) == T_TNODE) {
+	while (n && IS_TNODE(n)) {
 		tn = (struct tnode *) n;
 
 		check_tnode(tn);
@@ -1021,7 +1023,7 @@ fib_insert_node(struct trie *t, int *err
 	 * If it doesn't, we need to replace it with a T_TNODE.
 	 */
 
-	while (n != NULL &&  NODE_TYPE(n) == T_TNODE) {
+	while (n && IS_TNODE(n)) {
 		tn = (struct tnode *) n;
 
 		check_tnode(tn);
@@ -1364,7 +1366,8 @@ fn_trie_lookup(struct fib_table *tb, con
 		bits = pn->bits;
 
 		if (!chopped_off)
-			cindex = tkey_extract_bits(MASK_PFX(key, current_prefix_length), pos, bits);
+			cindex = tkey_extract_bits(mask_pfx(key, current_prefix_length),
+						   pos, bits);
 
 		n = tnode_get_child(pn, cindex);
 
@@ -1450,8 +1453,8 @@ fn_trie_lookup(struct fib_table *tb, con
 		 * to find a matching prefix.
 		 */
 
-		node_prefix = MASK_PFX(cn->key, cn->pos);
-		key_prefix = MASK_PFX(key, cn->pos);
+		node_prefix = mask_pfx(cn->key, cn->pos);
+		key_prefix = mask_pfx(key, cn->pos);
 		pref_mismatch = key_prefix^node_prefix;
 		mp = 0;
 
@@ -2327,7 +2330,7 @@ static int fib_trie_seq_show(struct seq_
 
 	if (IS_TNODE(n)) {
 		struct tnode *tn = (struct tnode *) n;
-		__be32 prf = htonl(MASK_PFX(tn->key, tn->pos));
+		__be32 prf = htonl(mask_pfx(tn->key, tn->pos));
 
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %d.%d.%d.%d/%d %d %d %d\n",

-- 

