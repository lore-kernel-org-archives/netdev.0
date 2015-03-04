From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 7/8] fib_trie: Update last spot w/ idx >>
 n->bits code and explanation
Date: Wed, 04 Mar 2015 15:04:03 -0800
Message-ID: <20150304230250.1612.81387.stgit@ahduyck-vm-fedora20>
References: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbbCDXEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 18:04:06 -0500
In-Reply-To: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change updates the fib_table_lookup function so that it is in sync
with the fib_find_node function in terms of the explanation for the index
check based on the bits value.

I have also updated it from doing a mask to just doing a compare as I have
found that seems to provide more options to the compiler as I have seen it
turn this into a shift of the value and test under some circumstances.

In addition I addressed one minor issue in which we kept computing the key
^ n->key when checking the fib aliases.  I pulled the xor out of the loop
in order to reduce the number of memory reads in the lookup.  As a result
we should save a couple cycles since the xor is only done once much earlier
in the lookup.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3642b17..08676c5 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1201,6 +1201,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	const t_key key = ntohl(flp->daddr);
 	struct tnode *n, *pn;
 	struct fib_alias *fa;
+	unsigned long index;
 	t_key cindex;
 
 	n = rcu_dereference(t->trie);
@@ -1216,19 +1217,23 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 
 	/* Step 1: Travel to the longest prefix match in the trie */
 	for (;;) {
-		unsigned long index = get_index(key, n);
+		index = get_index(key, n);
 
 		/* This bit of code is a bit tricky but it combines multiple
 		 * checks into a single check.  The prefix consists of the
 		 * prefix plus zeros for the "bits" in the prefix. The index
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
+		if (index >= (1ul << n->bits))
 			break;
 
 		/* we have found a leaf. Prefixes have already been compared */
@@ -1302,14 +1307,17 @@ backtrace:
 	}
 
 found:
+	/* this line carries forward the xor from earlier in the function */
+	index = key ^ n->key;
+
 	/* Step 3: Process the leaf, if that fails fall back to backtracing */
 	hlist_for_each_entry_rcu(fa, &n->leaf, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 		int nhsel, err;
 
-		if (((key ^ n->key) >= (1ul << fa->fa_slen)) &&
+		if ((index >= (1ul << fa->fa_slen)) &&
 		    ((BITS_PER_LONG > KEYLENGTH) || (fa->fa_slen != KEYLENGTH)))
-				continue;
+			continue;
 		if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
 			continue;
 		if (fi->fib_dead)
