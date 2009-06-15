From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/1 v2] Re: [BUG] fib_tries related Oops in 2.6.30
Date: Mon, 15 Jun 2009 18:08:01 +0200
Message-ID: <20090615160800.GC2767@ami.dom.local>
References: <20090615065333.GA4378@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert.olsson@its.uu.se>,
	Yan Zheng <zheng.yan@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:36200 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbZFOQIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 12:08:23 -0400
Content-Disposition: inline
In-Reply-To: <20090615065333.GA4378@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alas this top tnode needs even more.

Sorry/thanks,
Jarek P.
-------------------> take 2
ipv4: Fix fib_trie rebalancing, part 2

My previous patch, which explicitly delays freeing of tnodes by adding
them to the list to flush them after the update is finished, isn't
strict enough. It treats exceptionally tnodes without parent, assuming
they are newly created, so "invisible" for the read side yet.

But the top tnode doesn't have parent as well, so we have to exclude
all exceptions (at least until a better way is found). Additionally we
need to move rcu assignment of this node before flushing, so the
return type of the trie_rebalance() function is changed.

Reported-by: Yan Zheng <zheng.yan@oracle.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/ipv4/fib_trie.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d1a39b1..6188043 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -391,13 +391,8 @@ static inline void tnode_free(struct tnode *tn)
 static void tnode_free_safe(struct tnode *tn)
 {
 	BUG_ON(IS_LEAF(tn));
-
-	if (node_parent((struct node *) tn)) {
-		tn->tnode_free = tnode_free_head;
-		tnode_free_head = tn;
-	} else {
-		tnode_free(tn);
-	}
+	tn->tnode_free = tnode_free_head;
+	tnode_free_head = tn;
 }
 
 static void tnode_free_flush(void)
@@ -1009,7 +1004,7 @@ fib_find_node(struct trie *t, u32 key)
 	return NULL;
 }
 
-static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
+static void trie_rebalance(struct trie *t, struct tnode *tn)
 {
 	int wasfull;
 	t_key cindex, key;
@@ -1033,12 +1028,14 @@ static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 	}
 
 	/* Handle last (top) tnode */
-	if (IS_TNODE(tn)) {
+	if (IS_TNODE(tn))
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
+
+	rcu_assign_pointer(t->trie, (struct node *)tn);
+	if (IS_TNODE(tn))
 		tnode_free_flush();
-	}
 
-	return (struct node *)tn;
+	return;
 }
 
 /* only used from updater-side */
@@ -1186,7 +1183,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 
 	/* Rebalance the trie */
 
-	rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+	trie_rebalance(t, tp);
 done:
 	return fa_head;
 }
@@ -1605,7 +1602,7 @@ static void trie_leaf_remove(struct trie *t, struct leaf *l)
 	if (tp) {
 		t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
 		put_child(t, (struct tnode *)tp, cindex, NULL);
-		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+		trie_rebalance(t, tp);
 	} else
 		rcu_assign_pointer(t->trie, NULL);
 
