From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 9/16] CBQ: Use generic rate estimator
Date: Thu, 21 Oct 2004 14:44:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124426.GN21977@postel.suug.ch>
References: <20041021123209.GE21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041021123209.GE21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Makes CBQ use the generic rate estimator.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_cbq.c	2004-10-21 13:00:53.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_cbq.c	2004-10-21 13:01:20.000000000 +0200
@@ -1759,7 +1759,7 @@
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
 #ifdef CONFIG_NET_ESTIMATOR
-	qdisc_kill_estimator(&cl->stats);
+	gen_kill_estimator(&cl->bstats, &cl->rate_est);
 #endif
 	if (cl != &q->link)
 		kfree(cl);
@@ -1905,11 +1905,9 @@
 		sch_tree_unlock(sch);
 
 #ifdef CONFIG_NET_ESTIMATOR
-		if (tca[TCA_RATE-1]) {
-			qdisc_kill_estimator(&cl->stats);
-			qdisc_new_estimator(&cl->stats, cl->stats_lock,
-					    tca[TCA_RATE-1]);
-		}
+		if (tca[TCA_RATE-1])
+			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+				cl->stats_lock, tca[TCA_RATE-1]);
 #endif
 		return 0;
 	}
@@ -1999,8 +1997,8 @@
 
 #ifdef CONFIG_NET_ESTIMATOR
 	if (tca[TCA_RATE-1])
-		qdisc_new_estimator(&cl->stats, cl->stats_lock,
-				    tca[TCA_RATE-1]);
+		gen_new_estimator(&cl->bstats, &cl->rate_est,
+			cl->stats_lock, tca[TCA_RATE-1]);
 #endif
 
 	*arg = (unsigned long)cl;
