From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/8] police: use gnet_stats for old policer stats
Date: Wed, 3 Nov 2004 23:02:36 +0100
Message-ID: <20041103220236.GH12289@postel.suug.ch>
References: <20041103215816.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103215816.GA12289@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Transforms old policer to use generic statistic via TCA_STATS2
and maintain backward compatibility via TCA_STATS. Adds a new
API for classifiers to invoke the dumping process.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk13.orig/include/net/act_api.h linux-2.6.10-rc1-bk13/include/net/act_api.h
--- linux-2.6.10-rc1-bk13.orig/include/net/act_api.h	2004-11-03 17:04:58.000000000 +0100
+++ linux-2.6.10-rc1-bk13/include/net/act_api.h	2004-11-03 17:04:44.000000000 +0100
@@ -28,7 +28,9 @@
 	struct qdisc_rate_table *R_tab;
 	struct qdisc_rate_table *P_tab;
 
-	struct tc_stats	stats;
+	struct gnet_stats_basic bstats;
+	struct gnet_stats_queue qstats;
+	struct gnet_stats_rate_est rate_est;
 	spinlock_t	*stats_lock;
 };
 
@@ -101,6 +103,7 @@
 extern void tcf_police_destroy(struct tcf_police *p);
 extern struct tcf_police * tcf_police_locate(struct rtattr *rta, struct rtattr *est);
 extern int tcf_police_dump(struct sk_buff *skb, struct tcf_police *p);
+extern int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *p);
 
 static inline int
 tcf_police_release(struct tcf_police *p, int bind)
diff -Nru linux-2.6.10-rc1-bk13.orig/net/sched/police.c linux-2.6.10-rc1-bk13/net/sched/police.c
--- linux-2.6.10-rc1-bk13.orig/net/sched/police.c	2004-11-03 17:05:10.000000000 +0100
+++ linux-2.6.10-rc1-bk13/net/sched/police.c	2004-11-03 17:04:44.000000000 +0100
@@ -149,7 +149,7 @@
 			*p1p = p->next;
 			write_unlock_bh(&police_lock);
 #ifdef CONFIG_NET_ESTIMATOR
-			qdisc_kill_estimator(&p->stats);
+			gen_kill_estimator(&p->bstats, &p->rate_est);
 #endif
 			if (p->R_tab)
 				qdisc_put_rtab(p->R_tab);
@@ -469,7 +469,7 @@
 	p->action = parm->action;
 #ifdef CONFIG_NET_ESTIMATOR
 	if (est)
-		qdisc_new_estimator(&p->stats, p->stats_lock, est);
+		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
 #endif
 	h = tcf_police_hash(p->index);
 	write_lock_bh(&police_lock);
@@ -493,12 +493,12 @@
 
 	spin_lock(&p->lock);
 
-	p->stats.bytes += skb->len;
-	p->stats.packets++;
+	p->bstats.bytes += skb->len;
+	p->bstats.packets++;
 
 #ifdef CONFIG_NET_ESTIMATOR
-	if (p->ewma_rate && p->stats.bps >= p->ewma_rate) {
-		p->stats.overlimits++;
+	if (p->ewma_rate && p->rate_est.bps >= p->ewma_rate) {
+		p->qstats.overlimits++;
 		spin_unlock(&p->lock);
 		return p->action;
 	}
@@ -534,7 +534,7 @@
 		}
 	}
 
-	p->stats.overlimits++;
+	p->qstats.overlimits++;
 	spin_unlock(&p->lock);
 	return p->action;
 }
@@ -570,9 +570,34 @@
 	return -1;
 }
 
+int tcf_police_dump_stats(struct sk_buff *skb, struct tcf_police *p)
+{
+	struct gnet_dump d;
+	
+	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
+			TCA_XSTATS, p->stats_lock, &d) < 0)
+	
+	if (gnet_stats_copy_basic(&d, &p->bstats) < 0 ||
+#ifdef CONFIG_NET_ESTIMATOR
+	    gnet_stats_copy_rate_est(&d, &p->rate_est) < 0 ||
+#endif
+	    gnet_stats_copy_queue(&d, &p->qstats) < 0)
+		goto errout;
+
+	if (gnet_stats_finish_copy(&d) < 0)
+		goto errout;
+
+	return 0;
+
+errout:
+	return -1;
+}
+
+
 EXPORT_SYMBOL(tcf_police);
 EXPORT_SYMBOL(tcf_police_destroy);
 EXPORT_SYMBOL(tcf_police_dump);
+EXPORT_SYMBOL(tcf_police_dump_stats);
 EXPORT_SYMBOL(tcf_police_hash);
 EXPORT_SYMBOL(tcf_police_ht);
 EXPORT_SYMBOL(tcf_police_locate);
