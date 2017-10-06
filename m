From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 07/16] ipv6: prepare fib6_locate() for exception table
Date: Fri,  6 Oct 2017 12:06:02 -0700
Message-ID: <20171006190611.110633-8-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
 <20171006190611.110633-6-tracywwnj@gmail.com>
 <20171006190611.110633-7-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:53976 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752692AbdJFTGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:45 -0400
Received: by mail-pg0-f45.google.com with SMTP id s2so2209757pge.10
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:45 -0700 (PDT)
In-Reply-To: <20171006190611.110633-7-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

fib6_locate() is used to find the fib6_node according to the passed in
prefix address key. It currently tries to find the fib6_node with the
exact match of the passed in key. However, when we move cached routes
into the exception table, fib6_locate() will fail to find the fib6_node
for it as the cached routes will be stored in the exception table under
the fib6_node with the longest prefix match of the cache's dst addr key.
This commit adds a new parameter to let the caller specify if it needs
exact match or longest prefix match.
Right now, all callers still does exact match when calling
fib6_locate(). It will be changed in later commit where exception table
is hooked up to store cached routes.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_fib.h |  3 ++-
 net/ipv6/addrconf.c   |  2 +-
 net/ipv6/ip6_fib.c    | 30 +++++++++++++++++++++++-------
 net/ipv6/route.c      |  5 +++--
 4 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 11a79ef87a28..4497a1eb4d41 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -357,7 +357,8 @@ struct fib6_node *fib6_lookup(struct fib6_node *root,
 
 struct fib6_node *fib6_locate(struct fib6_node *root,
 			      const struct in6_addr *daddr, int dst_len,
-			      const struct in6_addr *saddr, int src_len);
+			      const struct in6_addr *saddr, int src_len,
+			      bool exact_match);
 
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    void *arg);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 837418ff2d4b..3ccaf52824c9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2322,7 +2322,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 		return NULL;
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_locate(&table->tb6_root, pfx, plen, NULL, 0);
+	fn = fib6_locate(&table->tb6_root, pfx, plen, NULL, 0, true);
 	if (!fn)
 		goto out;
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 3afbe50f2779..b3e4cf0962f8 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1343,14 +1343,21 @@ struct fib6_node *fib6_lookup(struct fib6_node *root, const struct in6_addr *dad
 /*
  *	Get node with specified destination prefix (and source prefix,
  *	if subtrees are used)
+ *	exact_match == true means we try to find fn with exact match of
+ *	the passed in prefix addr
+ *	exact_match == false means we try to find fn with longest prefix
+ *	match of the passed in prefix addr. This is useful for finding fn
+ *	for cached route as it will be stored in the exception table under
+ *	the node with longest prefix length.
  */
 
 
 static struct fib6_node *fib6_locate_1(struct fib6_node *root,
 				       const struct in6_addr *addr,
-				       int plen, int offset)
+				       int plen, int offset,
+				       bool exact_match)
 {
-	struct fib6_node *fn;
+	struct fib6_node *fn, *prev = NULL;
 
 	for (fn = root; fn ; ) {
 		struct rt6key *key = (struct rt6key *)((u8 *)fn->leaf + offset);
@@ -1360,11 +1367,13 @@ static struct fib6_node *fib6_locate_1(struct fib6_node *root,
 		 */
 		if (plen < fn->fn_bit ||
 		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit))
-			return NULL;
+			goto out;
 
 		if (plen == fn->fn_bit)
 			return fn;
 
+		prev = fn;
+
 		/*
 		 *	We have more bits to go
 		 */
@@ -1373,24 +1382,31 @@ static struct fib6_node *fib6_locate_1(struct fib6_node *root,
 		else
 			fn = fn->left;
 	}
-	return NULL;
+out:
+	if (exact_match)
+		return NULL;
+	else
+		return prev;
 }
 
 struct fib6_node *fib6_locate(struct fib6_node *root,
 			      const struct in6_addr *daddr, int dst_len,
-			      const struct in6_addr *saddr, int src_len)
+			      const struct in6_addr *saddr, int src_len,
+			      bool exact_match)
 {
 	struct fib6_node *fn;
 
 	fn = fib6_locate_1(root, daddr, dst_len,
-			   offsetof(struct rt6_info, rt6i_dst));
+			   offsetof(struct rt6_info, rt6i_dst),
+			   exact_match);
 
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src_len) {
 		WARN_ON(saddr == NULL);
 		if (fn && fn->subtree)
 			fn = fib6_locate_1(fn->subtree, saddr, src_len,
-					   offsetof(struct rt6_info, rt6i_src));
+					   offsetof(struct rt6_info, rt6i_src),
+					   exact_match);
 	}
 #endif
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d2dd55f58b5d..855b4ceec349 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2800,7 +2800,8 @@ static int ip6_route_del(struct fib6_config *cfg,
 
 	fn = fib6_locate(&table->tb6_root,
 			 &cfg->fc_dst, cfg->fc_dst_len,
-			 &cfg->fc_src, cfg->fc_src_len);
+			 &cfg->fc_src, cfg->fc_src_len,
+			 true);
 
 	if (fn) {
 		for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
@@ -3009,7 +3010,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 		return NULL;
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_locate(&table->tb6_root, prefix, prefixlen, NULL, 0);
+	fn = fib6_locate(&table->tb6_root, prefix, prefixlen, NULL, 0, true);
 	if (!fn)
 		goto out;
 
-- 
2.14.2.920.gcf0c67979c-goog
