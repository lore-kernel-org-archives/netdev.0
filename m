From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH]  netem: account for packets in delayed queue in qlen (2.4)
Date: Tue, 29 Mar 2005 15:21:09 -0800
Message-ID: <20050329152109.5194b62c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Netem qlen fix for 2.4.  
This patch changes the statistics to include the packets held but
not ready to send.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2005-03-29 15:19:22 -08:00
+++ b/net/sched/sch_netem.c	2005-03-29 15:19:22 -08:00
@@ -155,8 +155,6 @@
 	/* Always queue at tail to keep packets in order */
 	if (likely(q->delayed.qlen < q->limit)) {
 		__skb_queue_tail(&q->delayed, skb);
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
  
 		if (!timer_pending(&q->timer)) {
 			q->timer.expires = jiffies + PSCHED_US2JIFFIE(td);
@@ -165,7 +163,6 @@
 		return NET_XMIT_SUCCESS;
 	}
 
-	sch->stats.drops++;
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
 }
@@ -173,6 +170,8 @@
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb2;
+	int ret;
 
 	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
 
@@ -185,12 +184,16 @@
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
+			sch->stats.bytes += skb2->len;
+			sch->stats.packets++;
+		} else
+			sch->stats.drops++;
 	}
 
 	/* If doing simple delay then gap == 0 so all packets
@@ -199,22 +202,21 @@
 	 * packets will be delayed.
 	 */
 	if (q->counter < q->gap) {
-		int ret;
-
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
-		if (likely(ret == NET_XMIT_SUCCESS)) {
-			sch->q.qlen++;
-			sch->stats.bytes += skb->len;
-			sch->stats.packets++;
-		} else
-			sch->stats.drops++;
-		return ret;
+	} else {
+		q->counter = 0;
+		ret = delay_skb(sch, skb);
 	}
-	
-	q->counter = 0;
+		
+	if (likely(ret == NET_XMIT_SUCCESS)) {
+		sch->q.qlen++;
+		sch->stats.bytes += skb->len;
+		sch->stats.packets++;
+	} else
+		sch->stats.drops++;
 
-	return delay_skb(sch, skb);
+	return ret;
 }
 
 /* Requeue packets but don't change time stamp */
@@ -284,10 +286,10 @@
 		}
 		__skb_unlink(skb, &q->delayed);
 
-		if (q->qdisc->enqueue(skb, q->qdisc))
+		if (q->qdisc->enqueue(skb, q->qdisc)) {
+			sch->q.qlen--;
 			sch->stats.drops++;
-		else
-			sch->q.qlen++;
+		}
 	}
 	qdisc_run(dev);
 	spin_unlock_bh(&dev->queue_lock);
