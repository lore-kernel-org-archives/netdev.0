From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] ipv4: fib_trie leaf free optimization
Date: Wed, 2 Apr 2008 21:58:59 -0700
Message-ID: <20080402215859.7d024d19@extreme>
References: <20080402215724.4cf5fbf0@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47733 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbYDCE7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 00:59:11 -0400
In-Reply-To: <20080402215724.4cf5fbf0@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid unneeded test in the case where object to be freed
has to be a leaf. Don't need to use the generic tnode_free()
function, instead just setup leaf to be freed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/fib_trie.c	2008-04-02 10:50:42.000000000 -0700
+++ b/net/ipv4/fib_trie.c	2008-04-02 10:50:43.000000000 -0700
@@ -160,7 +160,6 @@ static void tnode_put_child_reorg(struct
 static struct node *resize(struct trie *t, struct tnode *tn);
 static struct tnode *inflate(struct trie *t, struct tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
-static void tnode_free(struct tnode *tn);
 
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
@@ -334,6 +333,11 @@ static void __leaf_free_rcu(struct rcu_h
 	kmem_cache_free(trie_leaf_kmem, l);
 }
 
+static inline void free_leaf(struct leaf *l)
+{
+	call_rcu_bh(&l->rcu, __leaf_free_rcu);
+}
+
 static void __leaf_info_free_rcu(struct rcu_head *head)
 {
 	kfree(container_of(head, struct leaf_info, rcu));
@@ -372,10 +376,9 @@ static void __tnode_free_rcu(struct rcu_
 
 static inline void tnode_free(struct tnode *tn)
 {
-	if (IS_LEAF(tn)) {
-		struct leaf *l = (struct leaf *) tn;
-		call_rcu_bh(&l->rcu, __leaf_free_rcu);
-	} else
+	if (IS_LEAF(tn))
+		free_leaf((struct leaf *) tn);
+	else
 		call_rcu(&tn->rcu, __tnode_free_rcu);
 }
 
@@ -1086,7 +1089,7 @@ static struct list_head *fib_insert_node
 	li = leaf_info_new(plen);
 
 	if (!li) {
-		tnode_free((struct tnode *) l);
+		free_leaf(l);
 		return NULL;
 	}
 
@@ -1122,7 +1125,7 @@ static struct list_head *fib_insert_node
 
 		if (!tn) {
 			free_leaf_info(li);
-			tnode_free((struct tnode *) l);
+			free_leaf(l);
 			return NULL;
 		}
 
@@ -1578,7 +1581,7 @@ static void trie_leaf_remove(struct trie
 	} else
 		rcu_assign_pointer(t->trie, NULL);
 
-	tnode_free((struct tnode *) l);
+	free_leaf(l);
 }
 
 /*

