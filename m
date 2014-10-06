From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 2/5] ipv6: make rt_sernum atomic and serial number fields ordinary ints
Date: Mon,  6 Oct 2014 19:58:35 +0200
Message-ID: <9cf860b036382b1082dd01c53a4a504e7ea5748f.1412618014.git.hannes@stressinduktion.org>
References: <cover.1412618014.git.hannes@stressinduktion.org>
Cc: hideaki@yoshifuji.org, kafai@fb.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58911 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753092AbaJFR6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:58:54 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id C704D2086D
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 13:58:53 -0400 (EDT)
In-Reply-To: <cover.1412618014.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1412618014.git.hannes@stressinduktion.org>
References: <cover.1412618014.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h |  2 +-
 net/ipv6/ip6_fib.c    | 23 +++++++++++++----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9221bf4..8eea35d 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -64,7 +64,7 @@ struct fib6_node {
 
 	__u16			fn_bit;		/* bit key */
 	__u16			fn_flags;
-	__u32			fn_sernum;
+	int			fn_sernum;
 	struct rt6_info		*rr_ptr;
 };
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e8d7465..332f1e0 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -74,7 +74,7 @@ static int fib6_walk_continue(struct fib6_walker *w);
  *	result of redirects, path MTU changes, etc.
  */
 
-static __u32 rt_sernum;
+static atomic_t rt_sernum = ATOMIC_INIT(1);
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
@@ -95,12 +95,15 @@ static void fib6_walker_unlink(struct fib6_walker *w)
 	write_unlock_bh(&fib6_walker_lock);
 }
 
-static u32 fib6_new_sernum(void)
+static int fib6_new_sernum(void)
 {
-	u32 n = ++rt_sernum;
-	if ((__s32)n <= 0)
-		rt_sernum = n = 1;
-	return n;
+	int new, old;
+
+	do {
+		old = atomic_read(&rt_sernum);
+		new = old < INT_MAX ? old + 1 : 1;
+	} while (atomic_cmpxchg(&rt_sernum, old, new) != old);
+	return new;
 }
 
 /*
@@ -421,7 +424,7 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 	struct rt6key *key;
 	int	bit;
 	__be32	dir = 0;
-	__u32	sernum = fib6_new_sernum();
+	int	sernum = fib6_new_sernum();
 
 	RT6_TRACE("fib6_add_1\n");
 
@@ -1598,7 +1601,7 @@ static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
 
 static int fib6_update_sernum(struct rt6_info *rt, void *arg)
 {
-	__u32 sernum = *(__u32 *)arg;
+	int sernum = *(int *)arg;
 
 	if (rt->rt6i_node &&
 	    rt->rt6i_node->fn_sernum != sernum)
@@ -1609,7 +1612,7 @@ static int fib6_update_sernum(struct rt6_info *rt, void *arg)
 
 static void fib6_flush_trees(struct net *net)
 {
-	__u32 new_sernum = fib6_new_sernum();
+	int new_sernum = fib6_new_sernum();
 
 	fib6_clean_all(net, fib6_update_sernum, &new_sernum);
 }
@@ -1822,7 +1825,7 @@ struct ipv6_route_iter {
 	struct fib6_walker w;
 	loff_t skip;
 	struct fib6_table *tbl;
-	__u32 sernum;
+	int sernum;
 };
 
 static int ipv6_route_seq_show(struct seq_file *seq, void *v)
-- 
1.9.3
