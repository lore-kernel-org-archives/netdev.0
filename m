From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/7] ipv4: Don't store scope in fib_result.
Date: Fri, 27 Jul 2012 21:18:23 -0700 (PDT)
Message-ID: <20120727.211823.1874838501400295217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab2G1ESY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It can be obtained from the nexthop's fib_info.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    2 +-
 net/ipv4/fib_frontend.c  |    2 +-
 net/ipv4/fib_semantics.c |    5 +++--
 net/ipv4/fib_trie.c      |    1 -
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index eb62a2f..847a46b 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -126,7 +126,7 @@ struct fib_result {
 	unsigned char		prefixlen;
 	unsigned char		__pad;
 	unsigned char		type;
-	unsigned char		scope;
+	unsigned char		__pad2;
 	u32			tclassid;
 	struct fib_nh		*nh;
 	struct fib_table	*table;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d2e8dbe..e02390d 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -946,7 +946,7 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 			frn->prefixlen = res.prefixlen;
 			frn->nh_sel = nhsel;
 			frn->type = res.type;
-			frn->scope = res.scope;
+			frn->scope = fi->fib_scope;
 		}
 		rcu_read_unlock();
 		local_bh_enable();
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b830245..6f73403 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -612,7 +612,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		err = -EINVAL;
 		if (res.type != RTN_UNICAST && res.type != RTN_LOCAL)
 			goto out;
-		nh->nh_scope = res.scope;
+		nh->nh_scope = res.nh->nh_parent->fib_scope;
 		nh->nh_oif = res.nh->nh_oif;
 		nh->nh_dev = dev = res.nh->nh_dev;
 		if (!dev)
@@ -1140,7 +1140,8 @@ void fib_select_default(struct fib_result *res)
 	list_for_each_entry_rcu(fa, fa_head, fa_list) {
 		struct fib_nh *next_nh = &fa->fa_info->fib_nh[0];
 
-		if (next_nh->nh_parent->fib_scope != res->scope ||
+		if ((next_nh->nh_parent->fib_scope !=
+		     res->nh->nh_parent->fib_scope) ||
 		    fa->fa_type != RTN_UNICAST)
 			continue;
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 04b0e26..83cf215 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1396,7 +1396,6 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 #endif
 				res->prefixlen = li->plen;
 				res->type = fa->fa_type;
-				res->scope = fi->fib_scope;
 				res->nh = nh;
 				res->table = tb;
 				res->fa_head = &li->falh;
-- 
1.7.10.4
