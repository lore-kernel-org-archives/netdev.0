From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/16] PKT_SCHED: Add dump_stats class op
Date: Thu, 21 Oct 2004 14:39:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021123926.GK21977@postel.suug.ch>
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

Adds a new class operation dump_stats which classes can use
to dump statistics. Unlike in qdiscs, there are no common
statistics therefore classes must dump all statistics on their
own. The qdisc stats_lock is being used for locking.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/include/net/pkt_sched.h	2004-10-21 11:13:03.000000000 +0200
+++ linux-2.6.9-rc5/include/net/pkt_sched.h	2004-10-21 12:52:11.000000000 +0200
@@ -42,6 +42,7 @@
 
 	/* rtnetlink specific */
 	int			(*dump)(struct Qdisc *, unsigned long, struct sk_buff *skb, struct tcmsg*);
+	int			(*dump_stats)(struct Qdisc *, unsigned long, struct gnet_dump *);
 };
 
 struct module;
--- linux-2.6.9-rc5.orig/net/sched/sch_api.c	2004-10-21 11:13:03.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_api.c	2004-10-21 12:52:11.000000000 +0200
@@ -985,6 +985,8 @@
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
+	struct gnet_dump d;
+	struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*tcm));
 	nlh->nlmsg_flags = flags;
@@ -995,8 +997,19 @@
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = 0;
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
-	if (q->ops->cl_ops->dump && q->ops->cl_ops->dump(q, cl, skb, tcm) < 0)
+	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
 		goto rtattr_failure;
+
+	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
+			TCA_XSTATS, q->stats_lock, &d) < 0)
+		goto rtattr_failure;
+
+	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
+		goto rtattr_failure;
+
+	if (gnet_stats_finish_copy(&d) < 0)
+		goto rtattr_failure;
+
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
