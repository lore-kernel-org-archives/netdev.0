From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] neigh: recompute reachabletime before returning from neigh_periodic_work()
Date: Thu, 27 Feb 2014 17:14:41 +0800
Message-ID: <530F0201.2040303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49457 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbaB0JPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 04:15:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If the neigh table's entries is less than gc_thresh1, the function
will return directly, and the reachabletime will not be recompute,
so the reachabletime can be guessed.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/core/neighbour.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 026bfd1..7c62a34 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -766,9 +766,6 @@ static void neigh_periodic_work(struct work_struct *work)
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 
-	if (atomic_read(&tbl->entries) < tbl->gc_thresh1)
-		goto out;
-
 	/*
 	 *	periodically recompute ReachableTime from random function
 	 */
@@ -781,6 +778,9 @@ static void neigh_periodic_work(struct work_struct *work)
 				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 	}
 
+	if (atomic_read(&tbl->entries) < tbl->gc_thresh1)
+		goto out;
+
 	for (i = 0 ; i < (1 << nht->hash_shift); i++) {
 		np = &nht->hash_buckets[i];
 
-- 
1.8.3.1
