From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/8] tcf_action: copy generic stats via TCA_ACT_STATS
Date: Wed, 3 Nov 2004 22:59:07 +0100
Message-ID: <20041103215907.GB12289@postel.suug.ch>
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

Dumps the statistic common to all action modules via the newly
introduced TLV type TCA_ACT_STATS in tcf_action_copy_stats but
allows the corresponding module to dump its own statistic by
implementing the get_stats callback.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk11.orig/include/linux/rtnetlink.h linux-2.6.10-rc1-bk11/include/linux/rtnetlink.h
--- linux-2.6.10-rc1-bk11.orig/include/linux/rtnetlink.h	2004-11-02 11:43:04.000000000 +0100
+++ linux-2.6.10-rc1-bk11/include/linux/rtnetlink.h	2004-11-02 12:02:44.000000000 +0100
@@ -699,6 +699,7 @@
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
+	TCA_ACT_STATS,
 	__TCA_MAX
 };
 
diff -Nru linux-2.6.10-rc1-bk11.orig/include/net/act_api.h linux-2.6.10-rc1-bk11/include/net/act_api.h
--- linux-2.6.10-rc1-bk11.orig/include/net/act_api.h	2004-11-02 11:43:07.000000000 +0100
+++ linux-2.6.10-rc1-bk11/include/net/act_api.h	2004-11-02 12:02:33.000000000 +0100
@@ -44,10 +44,16 @@
 	u32 capab; \
 	int action; \
 	struct tcf_t tm; \
-	struct tc_stats stats; \
+	struct gnet_stats_basic bstats; \
+	struct gnet_stats_queue qstats; \
+	struct gnet_stats_rate_est rate_est; \
 	spinlock_t *stats_lock; \
 	spinlock_t lock
 
+struct tcf_act_hdr
+{
+	tca_gen(act_hdr);
+};
 
 struct tc_action
 {
diff -Nru linux-2.6.10-rc1-bk11.orig/include/net/pkt_act.h linux-2.6.10-rc1-bk11/include/net/pkt_act.h
--- linux-2.6.10-rc1-bk11.orig/include/net/pkt_act.h	2004-11-02 11:43:07.000000000 +0100
+++ linux-2.6.10-rc1-bk11/include/net/pkt_act.h	2004-11-02 12:03:01.000000000 +0100
@@ -60,7 +60,7 @@
 			*p1p = p->next;
 			write_unlock_bh(&tcf_t_lock);
 #ifdef CONFIG_NET_ESTIMATOR
-			qdisc_kill_estimator(&p->stats);
+			gen_kill_estimator(&p->bstats, &p->rate_est);
 #endif
 			kfree(p);
 			return;
@@ -256,9 +256,8 @@
 	p->tm.install = jiffies;
 	p->tm.lastuse = jiffies;
 #ifdef CONFIG_NET_ESTIMATOR
-	if (est) {
-		qdisc_new_estimator(&p->stats, p->stats_lock, est);
-	}
+	if (est)
+		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
 #endif
 	h = tcf_hash(p->index);
 	write_lock_bh(&tcf_t_lock);
diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/act_api.c linux-2.6.10-rc1-bk11/net/sched/act_api.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/act_api.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/act_api.c	2004-11-02 12:06:02.000000000 +0100
@@ -416,14 +416,37 @@
 
 int tcf_action_copy_stats (struct sk_buff *skb,struct tc_action *a)
 {
+	struct gnet_dump d;
+	struct tcf_act_hdr *h = a->priv;
+	
 #ifdef CONFIG_KMOD
 	/* place holder */
 #endif
 
-	if (NULL == a->ops || NULL == a->ops->get_stats)
-		return 1;
+	if (NULL == h)
+		goto errout;
+
+	if (gnet_stats_start_copy(skb, TCA_ACT_STATS, h->stats_lock, &d) < 0)
+		goto errout;
+
+	if (NULL != a->ops && NULL != a->ops->get_stats)
+		if (a->ops->get_stats(skb, a) < 0)
+			goto errout;
+
+	if (gnet_stats_copy_basic(&d, &h->bstats) < 0 ||
+#ifdef CONFIG_NET_ESTIMATOR
+	    gnet_stats_copy_rate_est(&d, &h->rate_est) < 0 ||
+#endif
+	    gnet_stats_copy_queue(&d, &h->qstats) < 0)
+		goto errout;
+
+	if (gnet_stats_finish_copy(&d) < 0)
+		goto errout;
+
+	return 0;
 
-	return a->ops->get_stats(skb,a);
+errout:
+	return -1;
 }
 
 
