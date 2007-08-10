From: akpm@linux-foundation.org
Subject: [patch 13/28] fib_trie: macro cleanup
Date: Fri, 10 Aug 2007 14:11:57 -0700
Message-ID: <200708102111.l7ALBv6F009410@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38647 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942363AbXHJVMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

This patch converts the messy macro for MASK_PFX to inline function
and expands TKEY_GET_MASK in the one place it is used.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv4/fib_trie.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff -puN net/ipv4/fib_trie.c~fib_trie-macro-cleanup net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c~fib_trie-macro-cleanup
+++ a/net/ipv4/fib_trie.c
@@ -85,8 +85,6 @@
 #define MAX_STAT_DEPTH 32
 
 #define KEYLENGTH (8*sizeof(t_key))
-#define MASK_PFX(k, l) (((l)==0)?0:(k >> (KEYLENGTH-l)) << (KEYLENGTH-l))
-#define TKEY_GET_MASK(offset, bits) (((bits)==0)?0:((t_key)(-1) << (KEYLENGTH - bits) >> offset))
 
 typedef unsigned int t_key;
 
@@ -195,6 +193,11 @@ static inline int tnode_child_length(con
 	return 1 << tn->bits;
 }
 
+static inline t_key mask_pfx(t_key k, unsigned short l)
+{
+	return (l == 0) ? 0 : k >> (KEYLENGTH-l) << (KEYLENGTH-l);
+}
+
 static inline t_key tkey_extract_bits(t_key a, int offset, int bits)
 {
 	if (offset < KEYLENGTH)
@@ -679,7 +682,7 @@ static struct tnode *inflate(struct trie
 		    inode->pos == oldtnode->pos + oldtnode->bits &&
 		    inode->bits > 1) {
 			struct tnode *left, *right;
-			t_key m = TKEY_GET_MASK(inode->pos, 1);
+			t_key m = ~0U << (KEYLENGTH - 1) >> inode->pos;
 
 			left = tnode_new(inode->key&(~m), inode->pos + 1,
 					 inode->bits - 1);
@@ -1367,7 +1370,8 @@ fn_trie_lookup(struct fib_table *tb, con
 		bits = pn->bits;
 
 		if (!chopped_off)
-			cindex = tkey_extract_bits(MASK_PFX(key, current_prefix_length), pos, bits);
+			cindex = tkey_extract_bits(mask_pfx(key, current_prefix_length),
+						   pos, bits);
 
 		n = tnode_get_child(pn, cindex);
 
@@ -1453,8 +1457,8 @@ fn_trie_lookup(struct fib_table *tb, con
 		 * to find a matching prefix.
 		 */
 
-		node_prefix = MASK_PFX(cn->key, cn->pos);
-		key_prefix = MASK_PFX(key, cn->pos);
+		node_prefix = mask_pfx(cn->key, cn->pos);
+		key_prefix = mask_pfx(key, cn->pos);
 		pref_mismatch = key_prefix^node_prefix;
 		mp = 0;
 
@@ -2330,7 +2334,7 @@ static int fib_trie_seq_show(struct seq_
 
 	if (IS_TNODE(n)) {
 		struct tnode *tn = (struct tnode *) n;
-		__be32 prf = htonl(MASK_PFX(tn->key, tn->pos));
+		__be32 prf = htonl(mask_pfx(tn->key, tn->pos));
 
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %d.%d.%d.%d/%d %d %d %d\n",
_
