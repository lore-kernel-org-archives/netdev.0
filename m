From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/2] ipv6: compare sernum when walking fib for /proc/net/ipv6_route as safety net
Date: Sat, 21 Sep 2013 16:56:10 +0200
Message-ID: <20130921145610.GA20769@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: greearb@candelatech.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42097 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab3IUO4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 10:56:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides an additional safety net against NULL
pointer dereferences while walking the fib trie for the new
/proc/net/ipv6_route walkers. I never needed it myself and am unsure
if it is needed at all, but the same checks where introduced in
2bec5a369ee79576a3eea2c23863325089785a2c ("ipv6: fib: fix crash when
changing large fib while dumping it") to fix NULL pointer bugs.

This patch is separated from the first patch to make it easier to revert
if we are sure we can drop this logic.

Cc: Ben Greear <greearb@candelatech.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 05ffa54..5550a81 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1771,6 +1771,7 @@ struct ipv6_route_iter {
 	struct fib6_walker_t w;
 	loff_t skip;
 	struct fib6_table *tbl;
+	__u32 sernum;
 };
 
 static int ipv6_route_seq_show(struct seq_file *seq, void *v)
@@ -1823,6 +1824,7 @@ static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
 	iter->w.state = FWS_INIT;
 	iter->w.node = iter->w.root;
 	iter->w.args = iter;
+	iter->sernum = iter->w.root->fn_sernum;
 	INIT_LIST_HEAD(&iter->w.lh);
 	fib6_walker_link(&iter->w);
 }
@@ -1848,6 +1850,17 @@ static struct fib6_table *ipv6_route_seq_next_table(struct fib6_table *tbl,
 	return hlist_entry_safe(node, struct fib6_table, tb6_hlist);
 }
 
+static void ipv6_route_check_sernum(struct ipv6_route_iter *iter)
+{
+	if (iter->sernum != iter->w.root->fn_sernum) {
+		iter->sernum = iter->w.root->fn_sernum;
+		iter->w.state = FWS_INIT;
+		iter->w.node = iter->w.root;
+		WARN_ON(iter->w.skip);
+		iter->w.skip = iter->w.count;
+	}
+}
+
 static void *ipv6_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	int r;
@@ -1865,6 +1878,7 @@ static void *ipv6_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 
 iter_table:
+	ipv6_route_check_sernum(iter);
 	read_lock(&iter->tbl->tb6_lock);
 	r = fib6_walk_continue(&iter->w);
 	read_unlock(&iter->tbl->tb6_lock);
-- 
1.8.3.1
