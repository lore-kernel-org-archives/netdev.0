From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Fri, 2 Jul 2004 13:44:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Catalin BOIE <util@deuroconsult.ro>, netdev@oss.sgi.com,
        lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is an enhancement to netem to do allow emulating lower speed 
networks.  The resolution is close, but obviously limited by the
granularity of timers and size of packets.

Also, fixes a rtnetlink dependency which showed up in some configurations
and optimizes for the non-loss case by avoiding net_random call.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-07-02 13:40:11 -07:00
+++ b/net/sched/sch_netem.c	2004-07-02 13:40:11 -07:00
@@ -18,6 +18,7 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
 
 #include <net/pkt_sched.h>
 
@@ -31,11 +32,13 @@
 	struct sk_buff_head qnormal;
 	struct sk_buff_head qdelay;
 	struct timer_list timer;
+	psched_time_t last;
 
 	u32 latency;
 	u32 loss;
 	u32 counter;
 	u32 gap;
+	u32 rate;
 };
 
 /* Time stamp put into socket buffer control block */
@@ -54,13 +57,23 @@
 	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
 
 	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss >= net_random()) {
+	if (q->loss && q->loss >= net_random()) {
 		sch->stats.drops++;
 		return 0;	/* lie about loss so TCP doesn't know */
 	}
 
 	if (q->qnormal.qlen < sch->dev->tx_queue_len) {
 		PSCHED_GET_TIME(cb->time_to_send);
+		if (q->rate) {
+			if (!PSCHED_IS_PASTPERFECT(q->last) &&
+			    PSCHED_TLESS(cb->time_to_send, q->last))
+				cb->time_to_send = q->last;
+
+			PSCHED_TADD(cb->time_to_send, 
+				    (USEC_PER_SEC * skb->len) / q->rate);
+			q->last = cb->time_to_send;
+		}
+
 		PSCHED_TADD(cb->time_to_send, q->latency);
 
 		__skb_queue_tail(&q->qnormal, skb);
@@ -179,6 +192,7 @@
 	q->gap = qopt->gap;
 	q->loss = qopt->loss;
 	q->latency = qopt->latency;
+	q->rate = qopt->rate;
 
 	return 0;
 }
@@ -196,6 +210,7 @@
 	q->timer.function = netem_timer;
 	q->timer.data = (unsigned long) sch;
 	q->counter = 0;
+	PSCHED_SET_PASTPERFECT(q->last);
 
 	return netem_change(sch, opt);
 }
@@ -217,6 +232,7 @@
 	qopt.limit = sch->dev->tx_queue_len;
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
+	qopt.rate = q->rate;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 
