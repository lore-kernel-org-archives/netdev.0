From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 14/16] HFSC: Use generic rate estimator
Date: Thu, 21 Oct 2004 14:49:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124924.GS21977@postel.suug.ch>
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

Makes HFSC use the generic rate estimator.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_hfsc.c	2004-10-21 13:12:24.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_hfsc.c	2004-10-21 13:12:53.000000000 +0200
@@ -1100,11 +1100,9 @@
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
@@ -1162,8 +1160,8 @@
 
 #ifdef CONFIG_NET_ESTIMATOR
 	if (tca[TCA_RATE-1])
-		qdisc_new_estimator(&cl->stats, cl->stats_lock,
-				    tca[TCA_RATE-1]);
+		gen_new_estimator(&cl->bstats, &cl->rate_est,
+			cl->stats_lock, tca[TCA_RATE-1]);
 #endif
 	*arg = (unsigned long)cl;
 	return 0;
@@ -1188,7 +1186,7 @@
 	hfsc_destroy_filters(&cl->filter_list);
 	qdisc_destroy(cl->qdisc);
 #ifdef CONFIG_NET_ESTIMATOR
-	qdisc_kill_estimator(&cl->stats);
+	gen_kill_estimator(&cl->bstats, &cl->rate_est);
 #endif
 	if (cl != &q->root)
 		kfree(cl);
