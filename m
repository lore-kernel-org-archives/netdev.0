From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/16] PKT_SCHED: Add dump_stats qdisc op
Date: Thu, 21 Oct 2004 14:36:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021123626.GH21977@postel.suug.ch>
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

Adds a new qdisc operation dump_stats which qdiscs can use
to dump statistics. The op is invoked between gnet_stats_start_copy
and gnet_stats_finish_copy and therefore stats_lock is already
held. This is required to ensure proper locking throughout the
whole statistic dumping procedure.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/include/net/pkt_sched.h	2004-10-21 10:44:44.000000000 +0200
+++ linux-2.6.9-rc5/include/net/pkt_sched.h	2004-10-21 11:11:45.000000000 +0200
@@ -64,6 +64,7 @@
 	int			(*change)(struct Qdisc *, struct rtattr *arg);
 
 	int			(*dump)(struct Qdisc *, struct sk_buff *);
+	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
 
 	struct module		*owner;
 };
--- linux-2.6.9-rc5.orig/net/sched/sch_api.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_api.c	2004-10-21 11:11:45.000000000 +0200
@@ -767,6 +767,9 @@
 			TCA_XSTATS, q->stats_lock, &d) < 0)
 		goto rtattr_failure;
 
+	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
+		goto rtattr_failure;
+
 	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
 #ifdef CONFIG_NET_ESTIMATOR
 	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
