From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/7] ipv4: Perform multihop and default route resolution in
 check_leaf().
Date: Fri, 27 Jul 2012 21:18:42 -0700 (PDT)
Message-ID: <20120727.211842.1107309185639769464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819Ab2G1ESo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And thus eliminate two more members of fib_result.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h |    2 --
 net/ipv4/fib_trie.c  |   11 +++++++++--
 net/ipv4/route.c     |   17 -----------------
 3 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 66f5365..400c1a7 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -128,8 +128,6 @@ struct fib_table;
 struct fib_result {
 	u32			tclassid;
 	struct fib_nh		*nh;
-	struct fib_table	*table;
-	struct list_head	*fa_head;
 };
 
 struct fib_result_nl {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3d1d450..afd5048 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1391,9 +1391,16 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 				t->stats.semantic_match_passed++;
 #endif
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+				if (fi->fib_nhs > 1 && !flp->flowi4_oif)
+					nh = fib_select_multipath(nh);
+				else
+#endif
+				if (!li->plen && tb->tb_num_default > 1 &&
+				    fi->fib_type == RTN_UNICAST &&
+				    !flp->flowi4_oif)
+					nh = fib_select_default(nh, &li->falh, tb);
 				res->nh = nh;
-				res->table = tb;
-				res->fa_head = &li->falh;
 				if (!(fib_flags & FIB_LOOKUP_NOREF))
 					atomic_inc(&fi->fib_clntref);
 				return 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6b54323..2d1ede9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1459,11 +1459,6 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res->nh->nh_parent->fib_nhs > 1)
-		res->nh = fib_select_multipath(res->nh);
-#endif
-
 	/* create a routing cache entry */
 	return __mkroute_input(skb, res, in_dev, daddr, saddr, tos);
 }
@@ -1814,7 +1809,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 	res.tclassid	= 0;
 	res.nh		= NULL;
-	res.table	= NULL;
 
 	orig_oif = fl4->flowi4_oif;
 
@@ -1916,7 +1910,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 	if (fib_lookup(net, fl4, &res)) {
 		res.nh = NULL;
-		res.table = NULL;
 		if (fl4->flowi4_oif) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
@@ -1962,16 +1955,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		goto make_route;
 	}
 
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.nh->nh_parent->fib_nhs > 1 && fl4->flowi4_oif == 0)
-		res.nh = fib_select_multipath(res.nh);
-	else
-#endif
-	if (!res.nh->nh_parent->fib_prefixlen &&
-	    res.table->tb_num_default > 1 &&
-	    type == RTN_UNICAST && !fl4->flowi4_oif)
-		res.nh = fib_select_default(res.nh, res.fa_head, res.table);
-
 	if (!fl4->saddr)
 		fl4->saddr = fib_res_prefsrc(net, &res);
 
-- 
1.7.10.4
