From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) add loss option to network delay scheduler
Date: Thu, 17 Jun 2004 15:56:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617155606.558d8eb3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This enhances the network simulation scheduler to do simple random loss.

The loss parameter is a simple 32 bit value such that 0 means no loss, and
0xffffffff is always drop.  I have a new version of the tc command which takes
care of conversion from percent to this value.

Same patch for 2.4 and 2.6

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
--- a/include/linux/pkt_sched.h	2004-06-17 15:26:51 -07:00
+++ b/include/linux/pkt_sched.h	2004-06-17 15:26:51 -07:00
@@ -437,5 +437,6 @@
 {
 	__u32	latency;
 	__u32   limit;
-};	
+	__u32	loss;
+};
 #endif
diff -Nru a/net/sched/sch_delay.c b/net/sched/sch_delay.c
--- a/net/sched/sch_delay.c	2004-06-17 15:26:51 -07:00
+++ b/net/sched/sch_delay.c	2004-06-17 15:26:51 -07:00
@@ -40,6 +40,7 @@
 struct dly_sched_data {
 	u32	latency;
 	u32	limit;
+	u32	loss;
 	struct timer_list timer;
 	struct Qdisc *qdisc;
 };
@@ -58,6 +59,12 @@
 	struct dly_skb_cb *cb = (struct dly_skb_cb *)skb->cb;
 	int ret;
 
+	/* Random packet drop 0 => none, ~0 => all */
+	if (q->loss >= net_random()) {
+		sch->stats.drops++;
+		return 0;	/* lie about loss so TCP doesn't know */
+	}
+
 	PSCHED_GET_TIME(cb->queuetime);
 
 	/* Queue to underlying scheduler */
@@ -196,6 +203,7 @@
 	} else {
 		q->latency = qopt->latency;
 		q->limit = qopt->limit;
+		q->loss = qopt->loss;
 	}
 	return err;
 }
@@ -232,6 +240,7 @@
 
 	qopt.latency = q->latency;
 	qopt.limit = q->limit;
+	qopt.loss = q->loss;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 
