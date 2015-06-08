From: Firo Yang <firogm@gmail.com>
Subject: [PATCH] fib_trie: coding style: Use pointer after check
Date: Mon,  8 Jun 2015 11:54:51 +0800
Message-ID: <1433735691-7922-1-git-send-email-firogm@gmail.com>
Cc: alexander.duyck@gmail.com, eric.dumazet@gmail.com, wharms@bfs.de,
	julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	Firo Yang <firogm@gmail.com>
To: davem@davemloft.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As Alexander Duyck pointed out that:
struct tnode {
        ...
        struct key_vector kv[1];
}
The kv[1] member of struct tnode is an arry that refernced by
a null pointer will not crash the system, like this:
struct tnode *p = NULL;
struct key_vector *kv = p->kv;
As such p->kv doesn't actually dereference anything, it is simply a
means for getting the offset to the array from the pointer p.

This patch make the code more regular to avoid making people feel
odd when they look at the code.

Signed-off-by: Firo Yang <firogm@gmail.com>
---
 net/ipv4/fib_trie.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 01bce15..3c699c4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -325,13 +325,15 @@ static inline void empty_child_dec(struct key_vector *n)
 
 static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
 {
-	struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
-	struct key_vector *l = kv->kv;
+	struct key_vector *l;
+	struct tnode *kv;
 
+	kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
 	if (!kv)
 		return NULL;
 
 	/* initialize key vector */
+	l = kv->kv;
 	l->key = key;
 	l->pos = 0;
 	l->bits = 0;
@@ -346,24 +348,26 @@ static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
 
 static struct key_vector *tnode_new(t_key key, int pos, int bits)
 {
-	struct tnode *tnode = tnode_alloc(bits);
 	unsigned int shift = pos + bits;
-	struct key_vector *tn = tnode->kv;
+	struct key_vector *tn;
+	struct tnode *tnode;
 
 	/* verify bits and pos their msb bits clear and values are valid */
 	BUG_ON(!bits || (shift > KEYLENGTH));
 
-	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
-		 sizeof(struct key_vector *) << bits);
-
+	tnode = tnode_alloc(bits);
 	if (!tnode)
 		return NULL;
 
+	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
+		 sizeof(struct key_vector *) << bits);
+
 	if (bits == KEYLENGTH)
 		tnode->full_children = 1;
 	else
 		tnode->empty_children = 1ul << bits;
 
+	tn = tnode->kv;
 	tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
 	tn->pos = pos;
 	tn->bits = bits;
@@ -2054,11 +2058,12 @@ static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 static struct key_vector *fib_trie_get_first(struct fib_trie_iter *iter,
 					     struct trie *t)
 {
-	struct key_vector *n, *pn = t->kv;
+	struct key_vector *n, *pn;
 
 	if (!t)
 		return NULL;
 
+	pn = t->kv;
 	n = rcu_dereference(pn->tnode[0]);
 	if (!n)
 		return NULL;
-- 
2.4.2

