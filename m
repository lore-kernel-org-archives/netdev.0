From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Call fib_select_default() only when actually
 necessary.
Date: Thu, 14 Apr 2011 14:50:35 -0700 (PDT)
Message-ID: <20110414.145035.189701333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753729Ab1DNVvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 17:51:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CA67624C088
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 14:50:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fib_select_default() is a complete NOP, and completely pointless
to invoke, when we have no more than 1 default route installed.

And this is far and away the common case.

So remember how many prefixlen==0 routes we have in the routing
table, and elide the call when we have no more than one of those.

This cuts output route creation time by 157 cycles on Niagara2+.

In order to add the new int to fib_table, we have to correct the type
of ->tb_data[] to unsigned long, otherwise the private area will be
unaligned on 64-bit systems.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h |    3 ++-
 net/ipv4/fib_trie.c  |    7 +++++++
 net/ipv4/route.c     |    4 +++-
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 514627f..10422ef 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -160,7 +160,8 @@ struct fib_table {
 	struct hlist_node tb_hlist;
 	u32		tb_id;
 	int		tb_default;
-	unsigned char	tb_data[0];
+	int		tb_num_default;
+	unsigned long	tb_data[0];
 };
 
 extern int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index bde80c4..9ac481a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1332,6 +1332,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		}
 	}
 
+	if (!plen)
+		tb->tb_num_default++;
+
 	list_add_tail_rcu(&new_fa->fa_list,
 			  (fa ? &fa->fa_list : fa_head));
 
@@ -1697,6 +1700,9 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 
 	list_del_rcu(&fa->fa_list);
 
+	if (!plen)
+		tb->tb_num_default--;
+
 	if (list_empty(fa_head)) {
 		hlist_del_rcu(&li->hlist);
 		free_leaf_info(li);
@@ -1987,6 +1993,7 @@ struct fib_table *fib_trie_table(u32 id)
 
 	tb->tb_id = id;
 	tb->tb_default = -1;
+	tb->tb_num_default = 0;
 
 	t = (struct trie *) tb->tb_data;
 	memset(t, 0, sizeof(*t));
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0e7430c..e9aee81 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2615,7 +2615,9 @@ static struct rtable *ip_route_output_slow(struct net *net,
 		fib_select_multipath(&res);
 	else
 #endif
-	if (!res.prefixlen && res.type == RTN_UNICAST && !fl4.flowi4_oif)
+	if (!res.prefixlen &&
+	    res.table->tb_num_default > 1 &&
+	    res.type == RTN_UNICAST && !fl4.flowi4_oif)
 		fib_select_default(&res);
 
 	if (!fl4.saddr)
-- 
1.7.4.3

