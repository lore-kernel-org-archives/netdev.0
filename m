From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 13/16] HFSC: Use gnet_stats for class statistics
Date: Thu, 21 Oct 2004 14:48:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124824.GR21977@postel.suug.ch>
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

Converts HTB class statistic counters to gnet_stats
structures.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_hfsc.c	2004-10-21 11:07:46.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_hfsc.c	2004-10-21 13:11:06.000000000 +0200
@@ -122,7 +122,9 @@
 	u32		classid;	/* class id */
 	unsigned int	refcnt;		/* usage count */
 
-	struct tc_stats	stats;		/* generic statistics */
+	struct gnet_stats_basic bstats;
+	struct gnet_stats_queue qstats;
+	struct gnet_stats_rate_est rate_est;
 	spinlock_t	*stats_lock;
 	unsigned int	level;		/* class level in hierarchy */
 	struct tcf_proto *filter_list;	/* filter list */
@@ -1686,7 +1688,7 @@
 
 	err = cl->qdisc->enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
-		cl->stats.drops++;
+		cl->qstats.drops++;
 		sch->qstats.drops++;
 		return err;
 	}
@@ -1694,8 +1696,8 @@
 	if (cl->qdisc->q.qlen == 1)
 		set_active(cl, len);
 
-	cl->stats.packets++;
-	cl->stats.bytes += len;
+	cl->bstats.packets++;
+	cl->bstats.bytes += len;
 	sch->bstats.packets++;
 	sch->bstats.bytes += len;
 	sch->q.qlen++;
@@ -1799,7 +1801,7 @@
 			} else {
 				list_move_tail(&cl->dlist, &q->droplist);
 			}
-			cl->stats.drops++;
+			cl->qstats.drops++;
 			sch->qstats.drops++;
 			sch->q.qlen--;
 			return len;
