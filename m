From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 16/17] fib_trie: Remove checks for index >=
 tnode_child_length from tnode_get_child
Date: Mon, 22 Dec 2014 09:42:32 -0800
Message-ID: <20141222174232.1119.27495.stgit@ahduyck-vm-fedora20>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540AbaLVRme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:42:34 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHgXqU009053
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:42:33 -0500
Received: from [192.168.122.173] (ovpn-112-82.phx2.redhat.com [10.3.112.82])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHgXpl016538
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:42:33 -0500
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some reason the compiler doesn't seem to understand that when we are in
a loop that runs from tnode_child_length - 1 to 0 we don't expect the value
of tn->bits to change.  As such every call to tnode_get_child was rerunning
tnode_chile_length which ended up consuming quite a bit of space in the
resultant assembly code.

I have gone though and verified that in all cases where tnode_get_child
is used we are either winding though a fixed loop from tnode_child_length -
1 to 0, or are in a fastpath case where we are verifying the value by
either checking for any remaining bits after shifting index by bits and
testing for leaf, or by using tnode_child_length.

size net/ipv4/fib_trie.o
Before:
   text	   data	    bss	    dec	    hex	filename
  15506	    376	      8	  15890	   3e12	net/ipv4/fib_trie.o

After:
   text	   data	    bss	    dec	    hex	filename
  14827	    376	      8	  15211	   3b6b	net/ipv4/fib_trie.o

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1a0f9c5..b6298ed 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -186,8 +186,6 @@ static inline unsigned long tnode_child_length(const struct tnode *tn)
 static inline struct tnode *tnode_get_child(const struct tnode *tn,
 					    unsigned long i)
 {
-	BUG_ON(i >= tnode_child_length(tn));
-
 	return rtnl_dereference(tn->child[i]);
 }
 
@@ -195,8 +193,6 @@ static inline struct tnode *tnode_get_child(const struct tnode *tn,
 static inline struct tnode *tnode_get_child_rcu(const struct tnode *tn,
 						unsigned long i)
 {
-	BUG_ON(i >= tnode_child_length(tn));
-
 	return rcu_dereference_rtnl(tn->child[i]);
 }
 
@@ -371,7 +367,7 @@ static inline int tnode_full(const struct tnode *tn, const struct tnode *n)
  */
 static void put_child(struct tnode *tn, unsigned long i, struct tnode *n)
 {
-	struct tnode *chi = rtnl_dereference(tn->child[i]);
+	struct tnode *chi = tnode_get_child(tn, i);
 	int isfull, wasfull;
 
 	BUG_ON(i >= tnode_child_length(tn));
@@ -867,7 +863,7 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 		if (IS_LEAF(n))
 			break;
 
-		n = rcu_dereference_rtnl(n->child[index]);
+		n = tnode_get_child_rcu(n, index);
 	}
 
 	return n;
@@ -934,7 +930,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		}
 
 		tp = n;
-		n = rcu_dereference_rtnl(n->child[index]);
+		n = tnode_get_child_rcu(n, index);
 	}
 
 	l = leaf_new(key);
@@ -1210,7 +1206,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		pn = n;
 		cindex = index;
 
-		n = rcu_dereference_rtnl(n->child[index]);
+		n = tnode_get_child_rcu(n, index);
 		if (unlikely(!n))
 			goto backtrace;
 	}
@@ -1829,7 +1825,7 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 			if (n->bits < MAX_STAT_DEPTH)
 				s->nodesizes[n->bits]++;
 
-			for (i = 0; i < tnode_child_length(n); i++) {
+			for (i = tnode_child_length(n); i--;) {
 				if (!rcu_access_pointer(n->child[i]))
 					s->nullpointers++;
 			}
