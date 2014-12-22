From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 06/17] fib_trie: Optimize fib_find_node
Date: Mon, 22 Dec 2014 09:41:30 -0800
Message-ID: <20141222174130.1119.85241.stgit@ahduyck-vm-fedora20>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071AbaLVRlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:41:32 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHfVnc021437
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:41:31 -0500
Received: from [192.168.122.173] (ovpn-112-82.phx2.redhat.com [10.3.112.82])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHfU3c007943
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:41:30 -0500
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes use of the same features I made use of for
fib_table_lookup to streamline fib_find_node.  The resultant code should be
smaller and run faster than the original.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index fe2f60a..c182143 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -892,28 +892,34 @@ static void insert_leaf_info(struct hlist_head *head, struct leaf_info *new)
 }
 
 /* rcu_read_lock needs to be hold by caller from readside */
-
 static struct tnode *fib_find_node(struct trie *t, u32 key)
 {
 	struct tnode *n = rcu_dereference_rtnl(t->trie);
-	int pos = 0;
 
-	while (n && IS_TNODE(n)) {
-		if (tkey_sub_equals(n->key, pos, n->pos-pos, key)) {
-			pos = n->pos + n->bits;
-			n = tnode_get_child_rcu(n,
-						tkey_extract_bits(key,
-								  n->pos,
-								  n->bits));
-		} else
+	while (n) {
+		unsigned long index = get_index(key, n);
+
+		/* This bit of code is a bit tricky but it combines multiple
+		 * checks into a single check.  The prefix consists of the
+		 * prefix plus zeros for the bits in the cindex. The index
+		 * is the difference between the key and this value.  From
+		 * this we can actually derive several pieces of data.
+		 *   if !(index >> bits)
+		 *     we know the value is cindex
+		 *   else
+		 *     we have a mismatch in skip bits and failed
+		 */
+		if (index >> n->bits)
+			return NULL;
+
+		/* we have found a leaf. Prefixes have already been compared */
+		if (IS_LEAF(n))
 			break;
-	}
-	/* Case we have found a leaf. Compare prefixes */
 
-	if (n != NULL && IS_LEAF(n) && tkey_equals(key, n->key))
-		return n;
+		n = rcu_dereference_rtnl(n->child[index]);
+	}
 
-	return NULL;
+	return n;
 }
 
 static void trie_rebalance(struct trie *t, struct tnode *tn)
