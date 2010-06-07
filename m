From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pkt_sched: gen_estimator: kill est_lock rwlock
Date: Mon, 07 Jun 2010 16:32:51 +0200
Message-ID: <1275921171.2545.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35515 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0FGOc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 10:32:56 -0400
Received: by wyi11 with SMTP id 11so2411995wyi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 07:32:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use RCU in est_timer() and kill est_lock rwlock.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/gen_estimator.c |   45 ++++++++++++++-----------------------
 1 file changed, 18 insertions(+), 27 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cf8e703..406d880 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -102,9 +102,6 @@ struct gen_estimator_head
 
 static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
 
-/* Protects against NULL dereference */
-static DEFINE_RWLOCK(est_lock);
-
 /* Protects against soft lockup during large deletion */
 static struct rb_root est_root = RB_ROOT;
 
@@ -115,29 +112,25 @@ static void est_timer(unsigned long arg)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &elist[idx].list, list) {
-		u64 nbytes;
-		u64 brate;
-		u32 npackets;
-		u32 rate;
+		struct gnet_stats_basic_packed *bstats;
 
 		spin_lock(e->stats_lock);
-		read_lock(&est_lock);
-		if (e->bstats == NULL)
-			goto skip;
-
-		nbytes = e->bstats->bytes;
-		npackets = e->bstats->packets;
-		brate = (nbytes - e->last_bytes)<<(7 - idx);
-		e->last_bytes = nbytes;
-		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
-		e->rate_est->bps = (e->avbps+0xF)>>5;
-
-		rate = (npackets - e->last_packets)<<(12 - idx);
-		e->last_packets = npackets;
-		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
-		e->rate_est->pps = (e->avpps+0x1FF)>>10;
-skip:
-		read_unlock(&est_lock);
+		bstats = rcu_dereference(e->bstats);
+		if (bstats) {
+			u64 nbytes = ACCESS_ONCE(bstats->bytes);
+			u32 npackets = ACCESS_ONCE(bstats->packets);
+			u64 brate = (nbytes - e->last_bytes)<<(7 - idx);
+			u32 rate;
+
+			e->last_bytes = nbytes;
+			e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
+			e->rate_est->bps = (e->avbps+0xF)>>5;
+
+			rate = (npackets - e->last_packets)<<(12 - idx);
+			e->last_packets = npackets;
+			e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
+			e->rate_est->pps = (e->avpps+0x1FF)>>10;
+		}
 		spin_unlock(e->stats_lock);
 	}
 
@@ -271,9 +264,7 @@ void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 	while ((e = gen_find_node(bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
 
-		write_lock_bh(&est_lock);
-		e->bstats = NULL;
-		write_unlock_bh(&est_lock);
+		rcu_assign_pointer(e->bstats, NULL);
 
 		list_del_rcu(&e->list);
 		call_rcu(&e->e_rcu, __gen_kill_estimator);


