From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 11/16] HTB: Use dump_stats for class statistics dumping
Date: Thu, 21 Oct 2004 14:46:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124615.GP21977@postel.suug.ch>
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

Makes HTB use dump_stats to dump class statistics, i.e.
moves the statistics dump code from htb_dump_class to
htb_dump_class_stats.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_htb.c	2004-10-21 13:05:35.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_htb.c	2004-10-21 13:06:07.000000000 +0200
@@ -1319,7 +1319,6 @@
 	struct rtattr *rta;
 	struct tc_htb_glob gopt;
 	HTB_DBG(0,1,"htb_dump sch=%p, handle=%X\n",sch,sch->handle);
-	/* stats */
 	HTB_QLOCK(sch);
 	gopt.direct_pkts = q->direct_pkts;
 
@@ -1359,10 +1358,8 @@
 	HTB_QLOCK(sch);
 	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
-	if (!cl->level && cl->un.leaf.q) {
+	if (!cl->level && cl->un.leaf.q)
 		tcm->tcm_info = cl->un.leaf.q->handle;
-		cl->stats.qlen = cl->un.leaf.q->q.qlen;
-	}
 
 	rta = (struct rtattr*)b;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
@@ -1375,16 +1372,6 @@
 	opt.level = cl->level; 
 	RTA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 	rta->rta_len = skb->tail - b;
-
-#ifdef HTB_RATECM
-	cl->stats.bps = cl->rate_bytes/(HTB_EWMAC*HTB_HSIZE);
-	cl->stats.pps = cl->rate_packets/(HTB_EWMAC*HTB_HSIZE);
-#endif
-
-	cl->xstats.tokens = cl->tokens;
-	cl->xstats.ctokens = cl->ctokens;
-	RTA_PUT(skb, TCA_STATS, sizeof(cl->stats), &cl->stats);
-	RTA_PUT(skb, TCA_XSTATS, sizeof(cl->xstats), &cl->xstats);
 	HTB_QUNLOCK(sch);
 	return skb->len;
 rtattr_failure:
@@ -1393,6 +1380,30 @@
 	return -1;
 }
 
+static int
+htb_dump_class_stats(struct Qdisc *sch, unsigned long arg,
+	struct gnet_dump *d)
+{
+	struct htb_class *cl = (struct htb_class*)arg;
+
+#ifdef HTB_RATECM
+	cl->rate_est.bps = cl->rate_bytes/(HTB_EWMAC*HTB_HSIZE);
+	cl->rate_est.pps = cl->rate_packets/(HTB_EWMAC*HTB_HSIZE);
+#endif
+
+	if (!cl->level && cl->un.leaf.q)
+		cl->qstats.qlen = cl->un.leaf.q->q.qlen;
+	cl->xstats.tokens = cl->tokens;
+	cl->xstats.ctokens = cl->ctokens;
+
+	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
+		return -1;
+
+	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
+}
+
 static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	struct Qdisc **old)
 {
@@ -1747,6 +1758,7 @@
 	.bind_tcf	=	htb_bind_filter,
 	.unbind_tcf	=	htb_unbind_filter,
 	.dump		=	htb_dump_class,
+	.dump_stats	=	htb_dump_class_stats,
 };
 
 static struct Qdisc_ops htb_qdisc_ops = {
