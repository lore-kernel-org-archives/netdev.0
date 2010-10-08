From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH] remove leftover rcu_read_unlock calls from __mkroute_output
Date: Thu,  7 Oct 2010 17:48:38 -0700
Message-ID: <1286498918-30636-1-git-send-email-dm@chelsio.com>
To: eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18594 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab0JHAwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 20:52:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit "fib: RCU conversion of fib_lookup()" removed rcu_read_lock() from
__mkroute_output but left a couple of calls to rcu_read_unlock() in there.
This causes lockdep to complain that the rcu_read_unlock() call in
__ip_route_output_key causes a lock inbalance and quickly crashes the
kernel. The below fixes this for me.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 net/ipv4/route.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7864d0c..3888f6b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2396,12 +2396,10 @@ static int __mkroute_output(struct rtable **result,
 
 
 	rth = dst_alloc(&ipv4_dst_ops);
-	if (!rth) {
-		rcu_read_unlock();
+	if (!rth)
 		return -ENOBUFS;
-	}
+
 	in_dev_hold(in_dev);
-	rcu_read_unlock();
 	rth->idev = in_dev;
 
 	atomic_set(&rth->dst.__refcnt, 1);
-- 
1.5.4

