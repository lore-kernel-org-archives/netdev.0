From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 9/9] fib_trie: avoid rescan on dump
Date: Tue, 22 Jan 2008 15:37:42 -0800
Message-ID: <20080122233927.293043530@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33111 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757543AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Content-Disposition: inline; filename=trie-dump-desquare.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts dumping (and flushing) of large route tables
form O(N^2) to O(N). If the route dump took multiple pages then
the dump routine gets called again. The old code kept track of
location by counter, the new code instead uses the last key.

This is a really big win ( 0.3 sec vs 12 sec) for big route tables.

One side effect is that if the table changes during the dump, 
then the last key will not be found, and we will return -EBUSY.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-22 15:25:32.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-22 15:26:41.000000000 -0800
@@ -1914,35 +1914,43 @@ static int fn_trie_dump_leaf(struct leaf
 	return skb->len;
 }
 
-
-
 static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb,
 			struct netlink_callback *cb)
 {
 	struct leaf *l;
 	struct trie *t = (struct trie *) tb->tb_data;
-	int h = 0;
-	int s_h = cb->args[2];
+	t_key key = cb->args[2];
 
 	rcu_read_lock();
-	for (h = 0, l = trie_firstleaf(t); l != NULL; h++, l = trie_nextleaf(l)) {
-		if (h < s_h)
-			continue;
-
-		if (h > s_h) {
-			cb->args[3] = 0;
-			cb->args[4] = 0;
+	/* Dump starting at last key.
+	 * Note: 0.0.0.0/0 (ie default) is first key.
+	 */
+	if (!key)
+		l = trie_firstleaf(t);
+	else {
+		l = fib_find_node(t, key);
+		if (!l) {
+			/* The table changed during the dump, rather than
+			 * giving partial data, just make application retry.
+			 */
+			rcu_read_unlock();
+			return -EBUSY;
 		}
+	}
 
+	while (l) {
+		cb->args[2] = l->key;
 		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
 			rcu_read_unlock();
-			cb->args[2] = h;
 			return -1;
 		}
+
+		l = trie_nextleaf(l);
+		memset(&cb->args[3], 0,
+		       sizeof(cb->args) - 3*sizeof(cb->args[0]));
 	}
 	rcu_read_unlock();
 
-	cb->args[2] = h;
 	return skb->len;
 }
 

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

