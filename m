From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem: account for packets in delayed queue in qlen
Date: Tue, 29 Mar 2005 15:21:10 -0800
Message-ID: <20050329152110.38d50653@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Netem has a private queue for delayed packets, and currently, packets
in this queue are not accounted for in the qdisc qlen statistics.
This is a problem if netem is used inside another qdisc doing rate
control that peeks at the qlen.

This patch changes the statistics to include the packets held but
not ready to send.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2005-03-29 13:54:37 -08:00
+++ b/net/sched/sch_netem.c	2005-03-29 13:54:37 -08:00
@@ -152,9 +152,6 @@
 	/* Always queue at tail to keep packets in order */
 	if (likely(q->delayed.qlen < q->limit)) {
 		__skb_queue_tail(&q->delayed, skb);
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
-
 		if (!timer_pending(&q->timer)) {
 			q->timer.expires = jiffies + PSCHED_US2JIFFIE(td);
 			add_timer(&q->timer);
@@ -162,7 +159,6 @@
 		return NET_XMIT_SUCCESS;
 	}
 
-	sch->qstats.drops++;
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
 }
@@ -170,6 +166,8 @@
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb2;
+	int ret;
 
 	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
 
@@ -182,12 +180,16 @@
 	}
 
 	/* Random duplication */
-	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)) {
-		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
-
+	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)
+	    && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
 		pr_debug("netem_enqueue: dup %p\n", skb2);
-		if (skb2)
-			delay_skb(sch, skb2);
+
+		if (delay_skb(sch, skb2)) {
+			sch->q.qlen++;
+			sch->bstats.bytes += skb2->len;
+			sch->bstats.packets++;
+		} else
+			sch->qstats.drops++;
 	}
 
 	/* If doing simple delay then gap == 0 so all packets
@@ -196,22 +198,21 @@
 	 * packets will be delayed.
 	 */
 	if (q->counter < q->gap) {
-		int ret;
-
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
-		if (likely(ret == NET_XMIT_SUCCESS)) {
-			sch->q.qlen++;
-			sch->bstats.bytes += skb->len;
-			sch->bstats.packets++;
-		} else
-			sch->qstats.drops++;
-		return ret;
+	} else {
+		q->counter = 0;
+		ret = delay_skb(sch, skb);
 	}
-	
-	q->counter = 0;
 
-	return delay_skb(sch, skb);
+	if (likely(ret == NET_XMIT_SUCCESS)) {
+		sch->q.qlen++;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
+	} else
+		sch->qstats.drops++;
+
+	return ret;
 }
 
 /* Requeue packets but don't change time stamp */
@@ -283,10 +284,10 @@
 		}
 		__skb_unlink(skb, &q->delayed);
 
-		if (q->qdisc->enqueue(skb, q->qdisc))
+		if (q->qdisc->enqueue(skb, q->qdisc)) {
+			sch->q.qlen--;
 			sch->qstats.drops++;
-		else
-			sch->q.qlen++;
+		}
 	}
 	qdisc_run(dev);
 	spin_unlock_bh(&dev->queue_lock);
