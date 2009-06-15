From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: [BUG] fib_tries related Oops in 2.6.30
Date: Mon, 15 Jun 2009 06:53:33 +0000
Message-ID: <20090615065333.GA4378@ff.dom.local>
References: <20090612072557.GA2761@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert.olsson@its.uu.se>,
	Yan Zheng <zheng.yan@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f206.google.com ([209.85.220.206]:62971 "EHLO
	mail-fx0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbZFOGxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 02:53:38 -0400
Content-Disposition: inline
In-Reply-To: <20090612072557.GA2761@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-06-2009 09:25, Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 06/11/2009 04:39 PM:
> 
>> Cc Robert Olsson.
>>
>> Jarek P.
>>
>> Yan Zheng wrote, On 06/10/2009 06:05 PM:
>>
>>> Hello,
>>>
>>> I pull linux-2.6.30 from linus-2.6 git tree. I got following oops
>>> immediately after boot.
>>>
>>> # uname -a
>>> Linux zhyan-cn 2.6.30 #1 SMP PREEMPT Wed Jun 10 23:37:22 CST 2009 i686
>>> i686 i386 GNU/Linux
>>>
>>> ---
>>> BUG: sleeping function called from invalid context at
> ...
> 
> Robert, probably I miss something, but since I don't understand this
> last patch with preempt_disable(), I've looked a bit at this place and
> found this parent update after IMHO possible child destruction quite
> suspicious, so I wonder if you could check if this patch could change
> anything with previous oops. (It's mainly to test the idea, not to
> optimally fix it.)

Since I'm not sure Robert is working on this, here is a patch which
I guess should fix this issue more optimally. Alas, until it's tested
by somebody, I can recommend it only for net-next.

Jarek P.
------------------------->
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
---

 net/ipv4/fib_trie.c |   47 +++++++++++++++++++++++++++++++++++++----------
 1 files changed, 37 insertions(+), 10 deletions(-)

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
 
