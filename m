From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/16] CBQ: Use gnet_stats for class statistics
Date: Thu, 21 Oct 2004 14:40:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124039.GL21977@postel.suug.ch>
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

Converts CBQ class statistics counters to gnet_stats
structures.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_cbq.c	2004-10-21 12:45:47.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_cbq.c	2004-10-21 12:57:37.000000000 +0200
@@ -146,7 +146,9 @@
 	long			avgidle;
 	long			deficit;	/* Saved deficit for WRR */
 	unsigned long		penalized;
-	struct tc_stats		stats;
+	struct gnet_stats_basic bstats;
+	struct gnet_stats_queue qstats;
+	struct gnet_stats_rate_est rate_est;
 	spinlock_t		*stats_lock;
 	struct tc_cbq_xstats	xstats;
 
@@ -448,7 +450,7 @@
 		kfree_skb(skb);
 	else {
 		cbq_mark_toplevel(q, cl);
-		cl->stats.drops++;
+		cl->qstats.drops++;
 	}
 #else
 	if ( NET_XMIT_DROP == ret) {
@@ -457,7 +459,7 @@
 
 	if (cl != NULL) {
 		cbq_mark_toplevel(q, cl);
-		cl->stats.drops++;
+		cl->qstats.drops++;
 	}
 #endif
 	return ret;
@@ -491,7 +493,7 @@
 		return 0;
 	}
 	sch->qstats.drops++;
-	cl->stats.drops++;
+	cl->qstats.drops++;
 	return ret;
 }
 
@@ -789,8 +791,8 @@
 		long avgidle = cl->avgidle;
 		long idle;
 
-		cl->stats.packets++;
-		cl->stats.bytes += len;
+		cl->bstats.packets++;
+		cl->bstats.bytes += len;
 
 		/*
 		   (now - last) is total time between packet right edges.
@@ -888,7 +890,7 @@
 		   no another solution exists.
 		 */
 		if ((cl = cl->borrow) == NULL) {
-			this_cl->stats.overlimits++;
+			this_cl->qstats.overlimits++;
 			this_cl->overlimit(this_cl);
 			return NULL;
 		}
