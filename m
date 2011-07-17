From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] neigh: Simply destroy handling wrt. hh_cache.
Date: Sun, 17 Jul 2011 12:30:12 -0700 (PDT)
Message-ID: <20110717.123012.721873262387612011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756220Ab1GQTaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:30:13 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6HJUCT4028625
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 12:30:13 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that hh_cache entries are embedded inside of neighbour
entries, their lifetimes and accesses are now synchronous
to that of the encompassing neighbour object.

Therefore we don't need to hook up the blackhole op to
hh_output on destroy.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/neighbour.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 77a399f..83f9998 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -689,8 +689,6 @@ static void neigh_destroy_rcu(struct rcu_head *head)
  */
 void neigh_destroy(struct neighbour *neigh)
 {
-	struct hh_cache *hh;
-
 	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
 
 	if (!neigh->dead) {
@@ -703,13 +701,6 @@ void neigh_destroy(struct neighbour *neigh)
 	if (neigh_del_timer(neigh))
 		printk(KERN_WARNING "Impossible event.\n");
 
-	hh = &neigh->hh;
-	if (hh->hh_len) {
-		write_seqlock_bh(&hh->hh_lock);
-		hh->hh_output = neigh_blackhole;
-		write_sequnlock_bh(&hh->hh_lock);
-	}
-
 	skb_queue_purge(&neigh->arp_queue);
 
 	dev_put(neigh->dev);
-- 
1.7.6

