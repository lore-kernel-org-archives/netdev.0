From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] get rid of read/write lock in gen_estimator
Date: Mon, 28 Sep 2009 11:38:55 -0700
Message-ID: <20090928113855.52eab44b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35928 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbZI1Si5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 14:38:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't need a read/write lock here sinc there already is a spin lock that
is being acquired.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/gen_estimator.c	2009-09-24 16:27:01.239755070 -0700
+++ b/net/core/gen_estimator.c	2009-09-24 16:41:09.290751273 -0700
@@ -101,9 +101,6 @@ struct gen_estimator_head
 
 static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
 
-/* Protects against NULL dereference */
-static DEFINE_RWLOCK(est_lock);
-
 /* Protects against soft lockup during large deletion */
 static struct rb_root est_root = RB_ROOT;
 
@@ -118,9 +115,8 @@ static void est_timer(unsigned long arg)
 		u64 brate;
 		u32 npackets;
 		u32 rate;
-
+
 		spin_lock(e->stats_lock);
-		read_lock(&est_lock);
 		if (e->bstats == NULL)
 			goto skip;
 
@@ -136,7 +132,6 @@ static void est_timer(unsigned long arg)
 		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
 		e->rate_est->pps = (e->avpps+0x1FF)>>10;
 skip:
-		read_unlock(&est_lock);
 		spin_unlock(e->stats_lock);
 	}
 
@@ -270,9 +265,9 @@ void gen_kill_estimator(struct gnet_stat
 	while ((e = gen_find_node(bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
 
-		write_lock_bh(&est_lock);
+		spin_lock(e->stats_lock);
 		e->bstats = NULL;
-		write_unlock_bh(&est_lock);
+		spin_unlock(e->stats_lock);
 
 		list_del_rcu(&e->list);
 		call_rcu(&e->e_rcu, __gen_kill_estimator);
