From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] fib_trie: rescan if key is lost during dump
Date: Thu, 24 Jan 2008 13:51:12 -0800
Message-ID: <20080124135112.32b5c1c7@deepthought>
References: <20080123.205007.16809712.davem@davemloft.net>
	<47983304.3030309@trash.net>
	<479833EE.1090905@linux-foundation.org>
	<20080123.232747.75654058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40271 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753791AbYAXVy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 16:54:58 -0500
In-Reply-To: <20080123.232747.75654058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normally during a dump the key of the last dumped entry is used for
continuation, but since lock is dropped it might be lost. In that case
fallback to the old counter based N^2 behaviour.  This means the dump will end up
skipping some routes which matches what FIB_HASH does.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/linux/netlink.h	2008-01-24 13:39:40.000000000 -0800
+++ b/include/linux/netlink.h	2008-01-24 13:42:05.000000000 -0800
@@ -219,7 +219,7 @@ struct netlink_callback
 	int		(*dump)(struct sk_buff * skb, struct netlink_callback *cb);
 	int		(*done)(struct netlink_callback *cb);
 	int		family;
-	long		args[5];
+	long		args[6];
 };
 
 struct netlink_notify
--- a/net/ipv4/fib_trie.c	2008-01-24 13:39:40.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-24 13:44:26.000000000 -0800
@@ -1743,6 +1743,19 @@ static struct leaf *trie_nextleaf(struct
 	return leaf_walk_rcu(p, c);
 }
 
+static struct leaf *trie_leafindex(struct trie *t, int index)
+{
+	struct leaf *l = trie_firstleaf(t);
+
+	while (index-- > 0) {
+		l = trie_nextleaf(l);
+		if (!l)
+			break;
+	}
+	return l;
+}
+
+
 /*
  * Caller must hold RTNL.
  */
@@ -1848,7 +1861,7 @@ static int fn_trie_dump_fa(t_key key, in
 	struct fib_alias *fa;
 	__be32 xkey = htonl(key);
 
-	s_i = cb->args[4];
+	s_i = cb->args[5];
 	i = 0;
 
 	/* rcu_read_lock is hold by caller */
@@ -1869,12 +1882,12 @@ static int fn_trie_dump_fa(t_key key, in
 				  plen,
 				  fa->fa_tos,
 				  fa->fa_info, NLM_F_MULTI) < 0) {
-			cb->args[4] = i;
+			cb->args[5] = i;
 			return -1;
 		}
 		i++;
 	}
-	cb->args[4] = i;
+	cb->args[5] = i;
 	return skb->len;
 }
 
@@ -1885,7 +1898,7 @@ static int fn_trie_dump_leaf(struct leaf
 	struct hlist_node *node;
 	int i, s_i;
 
-	s_i = cb->args[3];
+	s_i = cb->args[4];
 	i = 0;
 
 	/* rcu_read_lock is hold by caller */
@@ -1896,19 +1909,19 @@ static int fn_trie_dump_leaf(struct leaf
 		}
 
 		if (i > s_i)
-			cb->args[4] = 0;
+			cb->args[5] = 0;
 
 		if (list_empty(&li->falh))
 			continue;
 
 		if (fn_trie_dump_fa(l->key, li->plen, &li->falh, tb, skb, cb) < 0) {
-			cb->args[3] = i;
+			cb->args[4] = i;
 			return -1;
 		}
 		i++;
 	}
 
-	cb->args[3] = i;
+	cb->args[4] = i;
 	return skb->len;
 }
 
@@ -1918,35 +1931,37 @@ static int fn_trie_dump(struct fib_table
 	struct leaf *l;
 	struct trie *t = (struct trie *) tb->tb_data;
 	t_key key = cb->args[2];
+	int count = cb->args[3];
 
 	rcu_read_lock();
 	/* Dump starting at last key.
 	 * Note: 0.0.0.0/0 (ie default) is first key.
 	 */
-	if (!key)
+	if (count == 0)
 		l = trie_firstleaf(t);
 	else {
+		/* Normally, continue from last key, but if that is missing
+		 * fallback to using slow rescan
+		 */
 		l = fib_find_node(t, key);
-		if (!l) {
-			/* The table changed during the dump, rather than
-			 * giving partial data, just make application retry.
-			 */
-			rcu_read_unlock();
-			return -EBUSY;
-		}
+		if (!l)
+			l = trie_leafindex(t, count);
 	}
 
 	while (l) {
 		cb->args[2] = l->key;
 		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
+			cb->args[3] = count;
 			rcu_read_unlock();
 			return -1;
 		}
 
+		++count;
 		l = trie_nextleaf(l);
-		memset(&cb->args[3], 0,
-		       sizeof(cb->args) - 3*sizeof(cb->args[0]));
+		memset(&cb->args[4], 0,
+		       sizeof(cb->args) - 4*sizeof(cb->args[0]));
 	}
+	cb->args[3] = count;
 	rcu_read_unlock();
 
 	return skb->len;
