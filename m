From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 10/16] HTB: Use gnet_stats for class statistics
Date: Thu, 21 Oct 2004 14:45:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124517.GO21977@postel.suug.ch>
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

--- linux-2.6.9-rc5.orig/net/sched/sch_htb.c	2004-10-21 11:07:46.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_htb.c	2004-10-21 13:03:29.000000000 +0200
@@ -142,7 +142,9 @@
 #endif
     /* general class parameters */
     u32 classid;
-    struct tc_stats	stats;	/* generic stats */
+    struct gnet_stats_basic bstats;
+    struct gnet_stats_queue qstats;
+    struct gnet_stats_rate_est rate_est;
     spinlock_t		*stats_lock;
     struct tc_htb_xstats xstats;/* our special stats */
     int refcnt;			/* usage count of this class */
@@ -754,10 +756,10 @@
 #endif
     else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
 	sch->qstats.drops++;
-	cl->stats.drops++;
+	cl->qstats.drops++;
 	return NET_XMIT_DROP;
     } else {
-	cl->stats.packets++; cl->stats.bytes += skb->len;
+	cl->bstats.packets++; cl->bstats.bytes += skb->len;
 	htb_activate (q,cl);
     }
 
@@ -788,7 +790,7 @@
 	}
     } else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
 	sch->qstats.drops++;
-	cl->stats.drops++;
+	cl->qstats.drops++;
 	return NET_XMIT_DROP;
     } else 
 	    htb_activate (q,cl);
@@ -906,8 +908,8 @@
 
 		/* update byte stats except for leaves which are already updated */
 		if (cl->level) {
-			cl->stats.bytes += bytes;
-			cl->stats.packets++;
+			cl->bstats.bytes += bytes;
+			cl->bstats.packets++;
 		}
 		cl = cl->parent;
 	}
