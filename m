From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/3][NET] gen_estimator: faster gen_kill_estimator
Date: Mon, 21 Jan 2008 00:46:59 +0100
Message-ID: <20080120234659.GA2691@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.236]:64445 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267AbYATXoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 18:44:37 -0500
Received: by hu-out-0506.google.com with SMTP id 19so683597hue.21
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 15:44:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gen_kill_estimator() is called during qdisc_destroy() with BHs disabled,
and each time does searching for each list member. This can block soft
interrupts for quite a long time when many classes are used. This patch 
changes this by storing a pointer to internal gen_estimator structures
with gnet_stats_rate_est structures used by clients of gen_estimator.

This method removes currently possibile registering in gen_estimator the
same structures more than once, but it isn't used after all. (There is
added a warning if gen_new_estimator() is called with structures being
used by gen_estimator already.)

Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

[needs more testing]

---

 include/linux/gen_stats.h |    2 ++
 net/core/gen_estimator.c  |   36 +++++++++++++++++++++++++++++++++---
 2 files changed, 35 insertions(+), 3 deletions(-)

diff -Nurp 2.6.24-rc8-mm1-/include/linux/gen_stats.h 2.6.24-rc8-mm1+/include/linux/gen_stats.h
--- 2.6.24-rc8-mm1-/include/linux/gen_stats.h	2007-10-09 22:31:38.000000000 +0200
+++ 2.6.24-rc8-mm1+/include/linux/gen_stats.h	2008-01-20 20:37:08.000000000 +0100
@@ -28,11 +28,13 @@ struct gnet_stats_basic
  * struct gnet_stats_rate_est - rate estimator
  * @bps: current byte rate
  * @pps: current packet rate
+ * @gen_estimator: internal data
  */
 struct gnet_stats_rate_est
 {
 	__u32	bps;
 	__u32	pps;
+	unsigned long	gen_estimator;
 };
 
 /**
diff -Nurp 2.6.24-rc8-mm1-/net/core/gen_estimator.c 2.6.24-rc8-mm1+/net/core/gen_estimator.c
--- 2.6.24-rc8-mm1-/net/core/gen_estimator.c	2008-01-19 17:54:45.000000000 +0100
+++ 2.6.24-rc8-mm1+/net/core/gen_estimator.c	2008-01-20 20:58:35.000000000 +0100
@@ -139,6 +139,9 @@ skip:
 	rcu_read_unlock();
 }
 
+static void gen_kill_estimator_find(struct gnet_stats_basic *bstats,
+				    struct gnet_stats_rate_est *rate_est);
+
 /**
  * gen_new_estimator - create a new rate estimator
  * @bstats: basic statistics
@@ -171,6 +174,10 @@ int gen_new_estimator(struct gnet_stats_
 	if (parm->interval < -2 || parm->interval > 3)
 		return -EINVAL;
 
+	if (rate_est->gen_estimator)
+		/* not sure: not zeroed in alloc or reused */
+		gen_kill_estimator_find(bstats, rate_est);
+
 	est = kzalloc(sizeof(*est), GFP_KERNEL);
 	if (est == NULL)
 		return -ENOBUFS;
@@ -184,6 +191,7 @@ int gen_new_estimator(struct gnet_stats_
 	est->avbps = rate_est->bps<<5;
 	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
+	rate_est->gen_estimator = (unsigned long)est;
 
 	if (!elist[idx].timer.function) {
 		INIT_LIST_HEAD(&elist[idx].list);
@@ -209,13 +217,30 @@ static void __gen_kill_estimator(struct 
  * @bstats: basic statistics
  * @rate_est: rate estimator statistics
  *
- * Removes the rate estimator specified by &bstats and &rate_est
- * and deletes the timer.
+ * Removes the rate estimator specified by &bstats and &rate_est.
  *
  * NOTE: Called under rtnl_mutex
  */
 void gen_kill_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est)
+			struct gnet_stats_rate_est *rate_est)
+{
+	if (rate_est && rate_est->gen_estimator) {
+		struct gen_estimator *e;
+		
+		e = (struct gen_estimator *)rate_est->gen_estimator;
+
+		rate_est->gen_estimator = 0;
+		write_lock_bh(&est_lock);
+		e->bstats = NULL;
+		write_unlock_bh(&est_lock);
+
+		list_del_rcu(&e->list);
+		call_rcu(&e->e_rcu, __gen_kill_estimator);
+	}
+}
+
+static void gen_kill_estimator_find(struct gnet_stats_basic *bstats,
+				    struct gnet_stats_rate_est *rate_est)
 {
 	int idx;
 	struct gen_estimator *e, *n;
@@ -236,6 +261,11 @@ void gen_kill_estimator(struct gnet_stat
 
 			list_del_rcu(&e->list);
 			call_rcu(&e->e_rcu, __gen_kill_estimator);
+
+			WARN_ON_ONCE(1); /* gen_new_estimator() repeated? */
+			rate_est->gen_estimator = 0;
+
+			return;
 		}
 	}
 }
