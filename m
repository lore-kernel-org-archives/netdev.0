From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] (3/4) netem - support packet duplication
Date: Wed, 25 Aug 2004 10:59:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825105906.2f192f28@dell_ss3.pdx.osdl.net>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add support for duplicating packets.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-24 16:58:13 -07:00
+++ b/net/sched/sch_netem.c	2004-08-24 16:58:13 -07:00
@@ -62,6 +62,7 @@
 	u32 counter;
 	u32 gap;
 	u32 jitter;
+	u32 duplicate;
 };
 
 /* Time stamp put into socket buffer control block */
@@ -624,22 +625,13 @@
 /* Enqueue packets with underlying discipline (fifo)
  * but mark them with current time first.
  */
-static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int netem_add_packet(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
 	psched_time_t now;
 	long delay;
 
-	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
-
-	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss && q->loss >= net_random()) {
-		sch->stats.drops++;
-		return 0;	/* lie about loss so TCP doesn't know */
-	}
-
-
 	/* If doing simple delay then gap == 0 so all packets
 	 * go into the delayed holding queue
 	 * otherwise if doing out of order only "1 out of gap"
@@ -671,7 +663,7 @@
 		sch->q.qlen++;
 		sch->stats.bytes += skb->len;
 		sch->stats.packets++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 
 	sch->stats.drops++;
@@ -679,6 +671,31 @@
 	return NET_XMIT_DROP;
 }
 
+static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+
+	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
+
+	/* Random packet drop 0 => none, ~0 => all */
+	if (q->loss && q->loss >= net_random()) {
+		pr_debug("netem_enqueue: random loss\n");
+		sch->stats.drops++;
+		return 0;	/* lie about loss so TCP doesn't know */
+	}
+
+	/* Random duplication */
+	if (q->duplicate && q->duplicate >= net_random()) {
+		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+
+		pr_debug("netem_enqueue: dup %p\n", skb2);
+		if (skb2)
+			netem_add_packet(sch, skb2);
+	}
+
+	return netem_add_packet(sch, skb);
+}
+
 /* Requeue packets but don't change time stamp */
 static int netem_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
@@ -806,6 +823,7 @@
 		q->limit = qopt->limit;
 		q->gap = qopt->gap;
 		q->loss = qopt->loss;
+		q->duplicate = qopt->duplicate;
 	}
 	sch_tree_unlock(sch);
 
@@ -849,6 +867,7 @@
 	qopt.limit = q->limit;
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
+	qopt.duplicate = q->duplicate;
 
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 
