From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) delay scheduler - retry if requeue fails
Date: Thu, 17 Jun 2004 15:55:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617155559.5aeba553@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If delay scheduler decides not to send the packet right away, it requeues
it.  If the requeue fails, it should go and look again rather than waking
up prematurely.

Same patch should apply to both 2.6 and 2.4

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_delay.c b/net/sched/sch_delay.c
--- a/net/sched/sch_delay.c	2004-06-17 15:19:07 -07:00
+++ b/net/sched/sch_delay.c	2004-06-17 15:19:07 -07:00
@@ -104,8 +104,10 @@
 static struct sk_buff *dly_dequeue(struct Qdisc *sch)
 {
 	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	struct sk_buff *skb = q->qdisc->dequeue(q->qdisc);
+	struct sk_buff *skb;
 
+ retry:
+	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
 		struct dly_skb_cb *cb = (struct dly_skb_cb *)skb->cb;
 		psched_time_t now;
@@ -120,6 +122,12 @@
 			return skb;
 		}
 
+		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
+			sch->q.qlen--;
+			sch->stats.drops++;
+			goto retry;
+		}
+
 		if (!netif_queue_stopped(sch->dev)) {
 			long delay = PSCHED_US2JIFFIE(diff);
 			if (delay <= 0)
@@ -127,10 +135,6 @@
 			mod_timer(&q->timer, jiffies+delay);
 		}
 
-		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
-			sch->q.qlen--;
-			sch->stats.drops++;
-		}
 		sch->flags |= TCQ_F_THROTTLED;
 	}
 	return NULL;
