From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] PKT_SCHED: Use gnet_stats API to copy statistics into netlink message
Date: Thu, 7 Oct 2004 03:04:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007010431.GC18621@postel.suug.ch>
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

Adapts qdisc API to use new gnet_stats functions to copy
statistics into netlink message.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.9-rc3-bk6.orig/include/linux/rtnetlink.h linux-2.6.9-rc3-bk6/include/linux/rtnetlink.h
--- linux-2.6.9-rc3-bk6.orig/include/linux/rtnetlink.h	2004-10-06 14:19:13.000000000 +0200
+++ linux-2.6.9-rc3-bk6/include/linux/rtnetlink.h	2004-10-06 20:24:32.000000000 +0200
@@ -698,6 +698,7 @@
 	TCA_XSTATS,
 	TCA_RATE,
 	TCA_FCNT,
+	TCA_STATS2,
 	__TCA_MAX
 };
 
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_api.c linux-2.6.9-rc3-bk6/net/sched/sch_api.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_api.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_api.c	2004-10-07 00:39:04.000000000 +0200
@@ -750,6 +750,7 @@
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
+	struct gnet_dump d;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*tcm));
 	nlh->nlmsg_flags = flags;
@@ -762,9 +763,22 @@
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto rtattr_failure;
-	q->stats.qlen = q->q.qlen;
-	if (qdisc_copy_stats(skb, &q->stats, q->stats_lock))
+	q->qstats.qlen = q->q.qlen;
+
+	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
+			TCA_XSTATS, q->stats_lock, &d) < 0)
+		goto rtattr_failure;
+
+	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
+#ifdef CONFIG_NET_ESTIMATOR
+	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
+#endif
+	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
+		goto rtattr_failure;
+	
+	if (gnet_stats_finish_copy(&d) < 0)
 		goto rtattr_failure;
+	
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
