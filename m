From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] fib_trie: macro cleanup
Date: Thu, 26 Jul 2007 11:43:34 +0100
Message-ID: <20070726114334.1e3e446c@oldman.hamilton.local>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725181557.GF3572@stusta.de>
	<20070726094648.3b7301ae@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Josh Triplett <josh@kernel.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35673 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755421AbXGZKom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 06:44:42 -0400
In-Reply-To: <20070726094648.3b7301ae@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts the messy macro for MASK_PFX to inline function
and expands TKEY_GET_MASK in the one place it is used.


--- a/net/ipv4/fib_trie.c	2007-07-26 09:26:19.000000000 +0100
+++ b/net/ipv4/fib_trie.c	2007-07-26 10:17:21.000000000 +0100
@@ -85,8 +85,6 @@
 #define MAX_STAT_DEPTH 32
 
 #define KEYLENGTH (8*sizeof(t_key))
-#define MASK_PFX(k, l) (((l)==0)?0:(k >> (KEYLENGTH-l)) << (KEYLENGTH-l))
-#define TKEY_GET_MASK(offset, bits) (((bits)==0)?0:((t_key)(-1) << (KEYLENGTH - bits) >> offset))
 
 typedef unsigned int t_key;
 
@@ -192,6 +190,11 @@ static inline int tnode_child_length(con
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
@@ -676,7 +679,7 @@ static struct tnode *inflate(struct trie
 		    inode->pos == oldtnode->pos + oldtnode->bits &&
 		    inode->bits > 1) {
 			struct tnode *left, *right;
-			t_key m = TKEY_GET_MASK(inode->pos, 1);
+			t_key m = ~0U << (KEYLENGTH - 1) >> inode->pos;
 
 			left = tnode_new(inode->key&(~m), inode->pos + 1,
 					 inode->bits - 1);
@@ -1364,7 +1367,8 @@ fn_trie_lookup(struct fib_table *tb, con
 		bits = pn->bits;
 
 		if (!chopped_off)
-			cindex = tkey_extract_bits(MASK_PFX(key, current_prefix_length), pos, bits);
+			cindex = tkey_extract_bits(mask_pfx(key, current_prefix_length),
+						   pos, bits);
 
 		n = tnode_get_child(pn, cindex);
 
@@ -1450,8 +1454,8 @@ fn_trie_lookup(struct fib_table *tb, con
 		 * to find a matching prefix.
 		 */
 
-		node_prefix = MASK_PFX(cn->key, cn->pos);
-		key_prefix = MASK_PFX(key, cn->pos);
+		node_prefix = mask_pfx(cn->key, cn->pos);
+		key_prefix = mask_pfx(key, cn->pos);
 		pref_mismatch = key_prefix^node_prefix;
 		mp = 0;
 
@@ -2327,7 +2331,7 @@ static int fib_trie_seq_show(struct seq_
 
 	if (IS_TNODE(n)) {
 		struct tnode *tn = (struct tnode *) n;
-		__be32 prf = htonl(MASK_PFX(tn->key, tn->pos));
+		__be32 prf = htonl(mask_pfx(tn->key, tn->pos));
 
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %d.%d.%d.%d/%d %d %d %d\n",
