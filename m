From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 06/17] fib_trie: Optimize fib_find_node
Date: Wed, 31 Dec 2014 10:56:00 -0800
Message-ID: <20141231185600.3006.31057.stgit@ahduyck-vm-fedora20>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbaLaS4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 13:56:02 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBVIu1rD022977
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:56:01 -0500
Received: from [192.168.122.173] (ovpn-112-50.phx2.redhat.com [10.3.112.50])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBVIu0ja020100
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:56:00 -0500
In-Reply-To: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
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
index 3fe4dd9..ac04f31 100644
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
