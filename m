From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/8] police: use gnet_stats for action policer stats
Date: Wed, 3 Nov 2004 23:02:01 +0100
Message-ID: <20041103220201.GG12289@postel.suug.ch>
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

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/police.c linux-2.6.10-rc1-bk11/net/sched/police.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/police.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/police.c	2004-11-02 13:54:14.000000000 +0100
@@ -245,7 +245,7 @@
 	p->index = parm->index ? : tcf_police_new_index();
 #ifdef CONFIG_NET_ESTIMATOR
 	if (est)
-		qdisc_new_estimator(&p->stats, p->stats_lock, est);
+		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
 #endif
 	h = tcf_police_hash(p->index);
 	write_lock_bh(&police_lock);
@@ -275,16 +275,6 @@
 	return 0;
 }
 
-int tcf_act_police_stats(struct sk_buff *skb, struct tc_action *a)
-{
-	struct tcf_police *p;
-	p = PRIV(a);
-	if (NULL != p) 
-		return qdisc_copy_stats(skb, &p->stats, p->stats_lock);
-
-	return 1;
-}
-
 int tcf_act_police(struct sk_buff **pskb, struct tc_action *a)
 {
 	psched_time_t now;
@@ -302,12 +292,12 @@
 
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
@@ -343,7 +333,7 @@
 		}
 	}
 
-	p->stats.overlimits++;
+	p->qstats.overlimits++;
 	spin_unlock(&p->lock);
 	return p->action;
 }
@@ -400,7 +390,6 @@
 	.capab		=	TCA_CAP_NONE, 
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_act_police,
-	.get_stats	=	tcf_act_police_stats,
 	.dump		=	tcf_act_police_dump,
 	.cleanup	=	tcf_act_police_cleanup,
 	.lookup		=	tcf_hash_search,
