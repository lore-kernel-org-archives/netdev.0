From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/13 net-3.1-stable] ipv4: fix lockdep splat in
 rt_cache_seq_show
Date: Tue, 06 Dec 2011 16:33:21 -0500 (EST)
Message-ID: <20111206.163321.1118302066607130320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754429Ab1LFVdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:23 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXMlL024145
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:22 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Eric Dumazet <eric.dumazet@gmail.com>

[ Upstream commit 218fa90f072e4aeff9003d57e390857f4f35513e ]

After commit f2c31e32b378 (fix NULL dereferences in check_peer_redir()),
dst_get_neighbour() should be guarded by rcu_read_lock() /
rcu_read_unlock() section.

Reported-by: Miles Lane <miles.lane@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 075212e..8b3661b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -417,9 +417,13 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 	else {
 		struct rtable *r = v;
 		struct neighbour *n;
-		int len;
+		int len, HHUptod;
 
+		rcu_read_lock();
 		n = dst_get_neighbour(&r->dst);
+		HHUptod = (n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0;
+		rcu_read_unlock();
+
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
 			r->dst.dev ? r->dst.dev->name : "*",
@@ -433,7 +437,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->rt_key_tos,
 			-1,
-			(n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0,
+			HHUptod,
 			r->rt_spec_dst, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
-- 
1.7.7.3
