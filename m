From: Sabrina Dubroca <sd@queasysnail.net>
Subject: ipv4 route dump broken with multiple subnets
Date: Tue, 10 Mar 2015 18:07:46 +0100
Message-ID: <20150310170746.GA1743@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:3411 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbbCJRHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 13:07:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With this setup (no other address assigned):

ip link add type dummy
ip link set dummy0 up
ip a a 10.0.0.1/24 dev dummy0

route dump works:

# ip r
10.0.0.0/24 dev dummy0 proto kernel scope link src 10.0.0.1


If I add another address:

ip a a 10.0.1.1/24 dev dummy0

or a route:

ip r a 10.0.1.0/24 via 10.0.0.2

# ip r
<empty>

It's the same with /proc/net/route instead of ip route.

But with a default route the table appears again.


This patch seems to fix the problem, but I'm not sure it is correct.

---

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 90955455884e..418043dc3a12 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1767,6 +1767,11 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 	 */
 	int count = cb->args[2];
 	t_key key = cb->args[3];
+	if (!key) {
+		struct key_vector *n = get_child_rcu(tp, 0);
+		if (n)
+			key = n->key;
+	}
 
 	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
 		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
@@ -2276,10 +2281,12 @@ static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
 		pos -= iter->pos;
 		key = iter->key;
 	} else {
+		struct key_vector *n;
 		t = (struct trie *)tb->tb_data;
 		iter->tnode = t->kv;
 		iter->pos = 0;
-		key = 0;
+		n = rcu_dereference(t->kv->tnode[0]);
+		key = n ? n->key : 0;
 	}
 
 	while ((l = leaf_walk_rcu(tp, key)) != NULL) {
@@ -2308,6 +2315,7 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
 	struct fib_route_iter *iter = seq->private;
+	struct key_vector *n;
 	struct fib_table *tb;
 	struct trie *t;
 
@@ -2323,9 +2331,15 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 		return fib_route_get_idx(iter, *pos);
 
 	t = (struct trie *)tb->tb_data;
-	iter->tnode = t->kv;
+	n = rcu_dereference(t->kv->tnode[0]);
+	if (IS_TNODE(n)) {
+		iter->tnode = n;
+		iter->key = n->key;
+	} else {
+		iter->tnode = t->kv;
+		iter->key = 0;
+	}
 	iter->pos = 0;
-	iter->key = 0;
 
 	return SEQ_START_TOKEN;
 }
