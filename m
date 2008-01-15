From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH 5/6] [IPV4] fib_trie: checkleaf calling convention
Date: Mon, 14 Jan 2008 18:58:43 -0800
Message-ID: <20080114185843.0981f0ff@deepthought>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
	<20080114164727.210047f6@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44180 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbYAOFDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 00:03:07 -0500
In-Reply-To: <20080114164727.210047f6@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another case where just returning a negative value gets rid of
call by reference. In this case the return value for checkleaf is
now:
	-1      no match
	0..32   prefix length

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-14 18:02:18.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-14 18:37:51.000000000 -0800
@@ -1277,36 +1277,36 @@ err:
 
 
 /* should be called with rcu_read_lock */
-static inline int check_leaf(struct trie *t, struct leaf *l,
-			     t_key key, int *plen, const struct flowi *flp,
-			     struct fib_result *res)
+static int check_leaf(struct trie *t, struct leaf *l,
+		      t_key key,  const struct flowi *flp,
+		      struct fib_result *res)
 {
-	int err, i;
-	__be32 mask;
 	struct leaf_info *li;
 	struct hlist_head *hhead = &l->list;
 	struct hlist_node *node;
 
 	hlist_for_each_entry_rcu(li, node, hhead, hlist) {
-		i = li->plen;
-		mask = inet_make_mask(i);
+		int err;
+		int plen = li->plen;
+		__be32 mask = inet_make_mask(plen);
+
 		if (l->key != (key & ntohl(mask)))
 			continue;
 
 		err = fib_semantic_match(&li->falh, flp, res,
-					 htonl(l->key), mask, i);
-		if (err <= 0) {
-			*plen = i;
+					 htonl(l->key), mask, plen);
+
 #ifdef CONFIG_IP_FIB_TRIE_STATS
+		if (err <= 0)
 			t->stats.semantic_match_passed++;
+		else
+			t->stats.semantic_match_miss++;
 #endif
-			return err;
-		}
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-		t->stats.semantic_match_miss++;
-#endif
+		if (err <= 0)
+			return plen;
 	}
-	return 1;
+
+	return -1;
 }
 
 static int
@@ -1337,11 +1337,13 @@ fn_trie_lookup(struct fib_table *tb, con
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
-		if (ret <= 0)
-			goto found;
-		goto failed;
+		plen = check_leaf(t, (struct leaf *)n, key, flp, res);
+		if (plen < 0)
+			goto failed;
+		ret = 0;
+		goto found;
 	}
+
 	pn = (struct tnode *) n;
 	chopped_off = 0;
 
@@ -1363,11 +1365,12 @@ fn_trie_lookup(struct fib_table *tb, con
 		}
 
 		if (IS_LEAF(n)) {
-			ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
-			if (ret <= 0)
-				goto found;
-			else
+			plen = check_leaf(t, (struct leaf *)n, key, flp, res);
+			if (plen < 0)
 				goto backtrace;
+
+			ret = 0;
+			goto found;
 		}
 
 		cn = (struct tnode *)n;
