From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 7/9] fib_trie: dump table in sorted order
Date: Tue, 22 Jan 2008 15:37:40 -0800
Message-ID: <20080122233927.143546260@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33106 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757414AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Content-Disposition: inline; filename=fib-trie-dump-unordered.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is easier with TRIE to dump the data traversal rather than
interating over every possible prefix. This saves some time and makes
the dump come out in sorted order.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/fib_trie.c	2008-01-22 12:58:59.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-22 12:59:03.000000000 -0800
@@ -1905,67 +1905,71 @@ static int fn_trie_dump_fa(t_key key, in
 	return skb->len;
 }
 
-static int fn_trie_dump_plen(struct trie *t, int plen, struct fib_table *tb,
-			     struct sk_buff *skb, struct netlink_callback *cb)
+
+static int fn_trie_dump_leaf(struct leaf *l, struct fib_table *tb,
+			struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int h, s_h;
-	struct list_head *fa_head;
-	struct leaf *l = NULL;
+	struct leaf_info *li;
+	struct hlist_node *node;
+	int i, s_i;
 
-	s_h = cb->args[3];
-	h = 0;
+	s_i = cb->args[3];
+	i = 0;
 
-	for (l = trie_firstleaf(t); l != NULL; h++, l = trie_nextleaf(l)) {
-		if (h < s_h)
+	/* rcu_read_lock is hold by caller */
+	hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
+		if (i < s_i) {
+			i++;
 			continue;
-		if (h > s_h)
-			memset(&cb->args[4], 0,
-			       sizeof(cb->args) - 4*sizeof(cb->args[0]));
-
-		fa_head = get_fa_head(l, plen);
+		}
 
-		if (!fa_head)
-			continue;
+		if (i > s_i)
+			cb->args[4] = 0;
 
-		if (list_empty(fa_head))
+		if (list_empty(&li->falh))
 			continue;
 
-		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb) < 0) {
-			cb->args[3] = h;
+		if (fn_trie_dump_fa(l->key, li->plen, &li->falh, tb, skb, cb) < 0) {
+			cb->args[3] = i;
 			return -1;
 		}
+		i++;
 	}
-	cb->args[3] = h;
+
+	cb->args[3] = i;
 	return skb->len;
 }
 
+
+
 static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb,
 			struct netlink_callback *cb)
 {
-	int m, s_m;
+	struct leaf *l;
 	struct trie *t = (struct trie *) tb->tb_data;
-
-	s_m = cb->args[2];
+	int h = 0;
+	int s_h = cb->args[2];
 
 	rcu_read_lock();
-	for (m = 0; m <= 32; m++) {
-		if (m < s_m)
+	for (h = 0, l = trie_firstleaf(t); l != NULL; h++, l = trie_nextleaf(l)) {
+		if (h < s_h)
 			continue;
-		if (m > s_m)
-			memset(&cb->args[3], 0,
-				sizeof(cb->args) - 3*sizeof(cb->args[0]));
-
-		if (fn_trie_dump_plen(t, 32-m, tb, skb, cb) < 0) {
-			cb->args[2] = m;
-			goto out;
+
+		if (h > s_h) {
+			cb->args[3] = 0;
+			cb->args[4] = 0;
+		}
+
+		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
+			rcu_read_unlock();
+			cb->args[2] = h;
+			return -1;
 		}
 	}
 	rcu_read_unlock();
-	cb->args[2] = m;
+
+	cb->args[2] = h;
 	return skb->len;
-out:
-	rcu_read_unlock();
-	return -1;
 }
 
 void __init fib_hash_init(void)

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

