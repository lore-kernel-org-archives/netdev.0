From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7] ipv4: Store prefixlen in fib_info.
Date: Fri, 27 Jul 2012 21:18:30 -0700 (PDT)
Message-ID: <20120727.211830.1658642139621947040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2G1ESb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The shrinks fib_result by 4 bytes since we don't have to write
it there any longer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    8 +++-----
 net/ipv4/fib_frontend.c  |    2 +-
 net/ipv4/fib_semantics.c |    6 ++++--
 net/ipv4/fib_trie.c      |    1 -
 net/ipv4/route.c         |    4 ++--
 5 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 3cb9e45..43be7230 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -96,11 +96,13 @@ struct fib_info {
 	struct net		*fib_net;
 	int			fib_treeref;
 	atomic_t		fib_clntref;
-	unsigned int		fib_flags;
+	unsigned char		fib_flags;
 	unsigned char		fib_dead;
 	unsigned char		fib_protocol;
 	unsigned char		fib_scope;
 	unsigned char		fib_type;
+	unsigned char		fib_prefixlen;
+	unsigned short		__pad;
 	__be32			fib_prefsrc;
 	u32			fib_priority;
 	u32			*fib_metrics;
@@ -124,10 +126,6 @@ struct fib_rule;
 
 struct fib_table;
 struct fib_result {
-	unsigned char		prefixlen;
-	unsigned char		__pad;
-	unsigned char		__pad2;
-	unsigned char		__pad3;
 	u32			tclassid;
 	struct fib_nh		*nh;
 	struct fib_table	*table;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 495b540..1e1907c 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -943,7 +943,7 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 			fi = nh->nh_parent;
 			nhsel = nh - &fi->fib_nh[0];
 
-			frn->prefixlen = res.prefixlen;
+			frn->prefixlen = fi->fib_prefixlen;
 			frn->nh_sel = nhsel;
 			frn->type = fi->fib_type;
 			frn->scope = fi->fib_scope;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 13b801a..bf4c809 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -252,8 +252,8 @@ static inline unsigned int fib_info_hashfn(const struct fib_info *fi)
 	unsigned int mask = (fib_info_hash_size - 1);
 	unsigned int val = fi->fib_nhs;
 
-	val ^= ((fi->fib_protocol << 16) | (fi->fib_scope << 8) |
-		fi->fib_type);
+	val ^= ((fi->fib_protocol << 24) | (fi->fib_scope << 16) |
+		(fi->fib_type << 8) | fi->fib_prefixlen);
 	val ^= (__force u32)fi->fib_prefsrc;
 	val ^= fi->fib_priority;
 	for_nexthops(fi) {
@@ -281,6 +281,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 		if (nfi->fib_protocol == fi->fib_protocol &&
 		    nfi->fib_scope == fi->fib_scope &&
 		    nfi->fib_type == fi->fib_type &&
+		    nfi->fib_prefixlen == fi->fib_prefixlen &&
 		    nfi->fib_prefsrc == fi->fib_prefsrc &&
 		    nfi->fib_priority == fi->fib_priority &&
 		    memcmp(nfi->fib_metrics, fi->fib_metrics,
@@ -801,6 +802,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi->fib_protocol = cfg->fc_protocol;
 	fi->fib_scope = cfg->fc_scope;
 	fi->fib_type = cfg->fc_type;
+	fi->fib_prefixlen = cfg->fc_dst_len;
 	fi->fib_flags = cfg->fc_flags;
 	fi->fib_priority = cfg->fc_priority;
 	fi->fib_prefsrc = cfg->fc_prefsrc;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f812f06..3d1d450 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1391,7 +1391,6 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 				t->stats.semantic_match_passed++;
 #endif
-				res->prefixlen = li->plen;
 				res->nh = nh;
 				res->table = tb;
 				res->fa_head = &li->falh;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6d4353b..597fbc0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1740,7 +1740,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		 * default one, but do not gateway in this case.
 		 * Yes, it is hack.
 		 */
-		if (nh && res->prefixlen < 4)
+		if (nh && nh->nh_parent->fib_prefixlen < 4)
 			nh = NULL;
 	}
 
@@ -1967,7 +1967,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		fib_select_multipath(&res);
 	else
 #endif
-	if (!res.prefixlen &&
+	if (!res.nh->nh_parent->fib_prefixlen &&
 	    res.table->tb_num_default > 1 &&
 	    type == RTN_UNICAST && !fl4->flowi4_oif)
 		fib_select_default(&res);
-- 
1.7.10.4
