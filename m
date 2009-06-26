From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 12:54:49 +0000
Message-ID: <20090626125449.GA8897@ff.dom.local>
References: <4A43E9F1.90209@cosmosbay.com> <20090626080302.GB5204@ff.dom.local> <19012.37515.146191.198843@robur.slu.se> <20090626093727.GA6832@ff.dom.local> <19012.49700.908412.410984@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:45390 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758012AbZFZMy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 08:54:56 -0400
Received: by bwz9 with SMTP id 9so2001382bwz.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 05:54:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <19012.49700.908412.410984@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 02:42:12PM +0200, Robert Olsson wrote:
> 
> Jarek Poplawski writes:
> 
>  > >  But maybe memory allocation experts has some good suggestions.
>  > 
>  > Pawel has reported these problems for a long time:
>  > http://bugzilla.kernel.org/show_bug.cgi?id=6648
>  > 
>  > So, until it's fully investigated, it seems some 'fast' fix is needed
>  > here.
> 
>  We talked about having a fixed pre-allocated root-node long ago but it's only 
>  optimisation for routers w. full BGP. Best if memory problems got solved.
>  

I think the current process of rebalancing can allocate and hold
unnecessarily long a lot of 'temp' memory, so probably something
like the patch below could be useful. It should be applied to the
2.6.30 after two patches below (from 2.6.31-rc). (Alas I can't even
compile-test it now).

Cheers,
Jarek P.

--- (for testing)

 net/ipv4/fib_trie.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 012cf5a..c2fc862 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -366,6 +366,14 @@ static void __tnode_vfree(struct work_struct *arg)
 	vfree(tn);
 }
 
+static void __tnode_free(struct tnode *tn)
+{
+	if (size <= PAGE_SIZE)
+		kfree(tn);
+	else
+		vfree(tn);
+}
+
 static void __tnode_free_rcu(struct rcu_head *head)
 {
 	struct tnode *tn = container_of(head, struct tnode, rcu);
@@ -402,7 +410,7 @@ static void tnode_free_flush(void)
 	while ((tn = tnode_free_head)) {
 		tnode_free_head = tn->tnode_free;
 		tn->tnode_free = NULL;
-		tnode_free(tn);
+		__tnode_free(tn);
 	}
 }
 
@@ -1020,19 +1028,23 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 		tnode_put_child_reorg((struct tnode *)tp, cindex,
 				      (struct node *)tn, wasfull);
 
-		tp = node_parent((struct node *) tn);
+		synchronize_rcu();
 		tnode_free_flush();
+		tp = node_parent((struct node *) tn);
 		if (!tp)
 			break;
 		tn = tp;
 	}
 
 	/* Handle last (top) tnode */
-	if (IS_TNODE(tn))
+	if (IS_TNODE(tn)) {
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
-
-	rcu_assign_pointer(t->trie, (struct node *)tn);
-	tnode_free_flush();
+		rcu_assign_pointer(t->trie, (struct node *)tn);
+		synchronize_rcu();
+		tnode_free_flush();
+	} else {
+		rcu_assign_pointer(t->trie, (struct node *)tn);
+	}
 
 	return;
 }

---
commit e0f7cb8c8cc6cccce28d2ce39ad8c60d23c3799f
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Mon Jun 15 02:31:29 2009 -0700

    ipv4: Fix fib_trie rebalancing
    
    While doing trie_rebalance(): resize(), inflate(), halve() RCU free
    tnodes before updating their parents. It depends on RCU delaying the
    real destruction, but if RCU readers start after call_rcu() and before
    parent update they could access freed memory.
    
    It is currently prevented with preempt_disable() on the update side,
    but it's not safe, except maybe classic RCU, plus it conflicts with
    memory allocations with GFP_KERNEL flag used from these functions.
    
    This patch explicitly delays freeing of tnodes by adding them to the
    list, which is flushed after the update is finished.
    
    Reported-by: Yan Zheng <zheng.yan@oracle.com>
    Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 538d2a9..d1a39b1 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -123,6 +123,7 @@ struct tnode {
 	union {
 		struct rcu_head rcu;
 		struct work_struct work;
+		struct tnode *tnode_free;
 	};
 	struct node *child[0];
 };
@@ -161,6 +162,8 @@ static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
 static struct node *resize(struct trie *t, struct tnode *tn);
 static struct tnode *inflate(struct trie *t, struct tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
+/* tnodes to free after resize(); protected by RTNL */
+static struct tnode *tnode_free_head;
 
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
@@ -385,6 +388,29 @@ static inline void tnode_free(struct tnode *tn)
 		call_rcu(&tn->rcu, __tnode_free_rcu);
 }
 
+static void tnode_free_safe(struct tnode *tn)
+{
+	BUG_ON(IS_LEAF(tn));
+
+	if (node_parent((struct node *) tn)) {
+		tn->tnode_free = tnode_free_head;
+		tnode_free_head = tn;
+	} else {
+		tnode_free(tn);
+	}
+}
+
+static void tnode_free_flush(void)
+{
+	struct tnode *tn;
+
+	while ((tn = tnode_free_head)) {
+		tnode_free_head = tn->tnode_free;
+		tn->tnode_free = NULL;
+		tnode_free(tn);
+	}
+}
+
 static struct leaf *leaf_new(void)
 {
 	struct leaf *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
@@ -495,7 +521,7 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 
 	/* No children */
 	if (tn->empty_children == tnode_child_length(tn)) {
-		tnode_free(tn);
+		tnode_free_safe(tn);
 		return NULL;
 	}
 	/* One child */
@@ -509,7 +535,7 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 
 			/* compress one level */
 			node_set_parent(n, NULL);
-			tnode_free(tn);
+			tnode_free_safe(tn);
 			return n;
 		}
 	/*
@@ -670,7 +696,7 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 			/* compress one level */
 
 			node_set_parent(n, NULL);
-			tnode_free(tn);
+			tnode_free_safe(tn);
 			return n;
 		}
 
@@ -756,7 +782,7 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 			put_child(t, tn, 2*i, inode->child[0]);
 			put_child(t, tn, 2*i+1, inode->child[1]);
 
-			tnode_free(inode);
+			tnode_free_safe(inode);
 			continue;
 		}
 
@@ -801,9 +827,9 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 		put_child(t, tn, 2*i, resize(t, left));
 		put_child(t, tn, 2*i+1, resize(t, right));
 
-		tnode_free(inode);
+		tnode_free_safe(inode);
 	}
-	tnode_free(oldtnode);
+	tnode_free_safe(oldtnode);
 	return tn;
 nomem:
 	{
@@ -885,7 +911,7 @@ static struct tnode *halve(struct trie *t, struct tnode *tn)
 		put_child(t, newBinNode, 1, right);
 		put_child(t, tn, i/2, resize(t, newBinNode));
 	}
-	tnode_free(oldtnode);
+	tnode_free_safe(oldtnode);
 	return tn;
 nomem:
 	{
@@ -989,7 +1015,6 @@ static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 	t_key cindex, key;
 	struct tnode *tp;
 
-	preempt_disable();
 	key = tn->key;
 
 	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {
@@ -1001,16 +1026,18 @@ static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 				      (struct node *)tn, wasfull);
 
 		tp = node_parent((struct node *) tn);
+		tnode_free_flush();
 		if (!tp)
 			break;
 		tn = tp;
 	}
 
 	/* Handle last (top) tnode */
-	if (IS_TNODE(tn))
+	if (IS_TNODE(tn)) {
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
+		tnode_free_flush();
+	}
 
-	preempt_enable();
 	return (struct node *)tn;
 }
 
---
commit 7b85576d15bf2574b0a451108f59f9ad4170dd3f
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Thu Jun 18 00:28:51 2009 -0700

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
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d1a39b1..012cf5a 100644
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
@@ -1033,12 +1028,13 @@ static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 	}
 
 	/* Handle last (top) tnode */
-	if (IS_TNODE(tn)) {
+	if (IS_TNODE(tn))
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
-		tnode_free_flush();
-	}
 
-	return (struct node *)tn;
+	rcu_assign_pointer(t->trie, (struct node *)tn);
+	tnode_free_flush();
+
+	return;
 }
 
 /* only used from updater-side */
@@ -1186,7 +1182,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 
 	/* Rebalance the trie */
 
-	rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+	trie_rebalance(t, tp);
 done:
 	return fa_head;
 }
@@ -1605,7 +1601,7 @@ static void trie_leaf_remove(struct trie *t, struct leaf *l)
 	if (tp) {
 		t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
 		put_child(t, (struct tnode *)tp, cindex, NULL);
-		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+		trie_rebalance(t, tp);
 	} else
 		rcu_assign_pointer(t->trie, NULL);
 
