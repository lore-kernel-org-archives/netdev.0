From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5] PKT_SCHED: Use generic rate estimator
Date: Thu, 7 Oct 2004 03:07:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007010709.GE18621@postel.suug.ch>
References: <20041007010146.GA18621@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041007010146.GA18621@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adapts qdiscs to use generic estimator.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_api.c linux-2.6.9-rc3-bk6/net/sched/sch_api.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_api.c	2004-10-07 00:48:10.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_api.c	2004-10-07 00:46:34.000000000 +0200
@@ -461,8 +461,8 @@
 
 #ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1])
-			qdisc_new_estimator(&sch->stats, sch->stats_lock,
-					    tca[TCA_RATE-1]);
+			gen_new_estimator(&sch->bstats, &sch->rate_est,
+				sch->stats_lock, tca[TCA_RATE-1]);
 #endif
 		return sch;
 	}
@@ -489,11 +489,9 @@
 			return err;
 	}
 #ifdef CONFIG_NET_ESTIMATOR
-	if (tca[TCA_RATE-1]) {
-		qdisc_kill_estimator(&sch->stats);
-		qdisc_new_estimator(&sch->stats, sch->stats_lock,
-				    tca[TCA_RATE-1]);
-	}
+	if (tca[TCA_RATE-1])
+		gen_replace_estimator(&sch->bstats, &sch->rate_est,
+			sch->stats_lock, tca[TCA_RATE-1]);
 #endif
 	return 0;
 }
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_generic.c linux-2.6.9-rc3-bk6/net/sched/sch_generic.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_generic.c	2004-10-07 00:32:25.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_generic.c	2004-10-07 00:46:57.000000000 +0200
@@ -465,7 +465,7 @@
 	struct Qdisc_ops  *ops = qdisc->ops;
 
 #ifdef CONFIG_NET_ESTIMATOR
-	qdisc_kill_estimator(&qdisc->stats);
+	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
 #endif
 	write_lock(&qdisc_tree_lock);
 	if (ops->reset)
