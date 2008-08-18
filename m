From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/9]: sch_netem: Use requeue list instead of ops->requeue()
Date: Mon, 18 Aug 2008 01:37:02 -0700 (PDT)
Message-ID: <20080818.013702.111675433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751779AbYHRIhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:37:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sch_netem: Use requeue list instead of ops->requeue()

This code just wants to make this packet the "front" one, and that's
just as simply done by queueing to the ->requeue list.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_netem.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index dbd567f..7e15c0b 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -233,7 +233,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 */
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
-		ret = q->qdisc->ops->requeue(skb, q->qdisc);
+		__skb_queue_tail(&q->qdisc->requeue, skb);
+		ret = NET_XMIT_SUCCESS;
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -295,13 +296,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			return skb;
 		}
 
-		if (unlikely(q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
-			qdisc_tree_decrease_qlen(q->qdisc, 1);
-			sch->qstats.drops++;
-			printk(KERN_ERR "netem: %s could not requeue\n",
-			       q->qdisc->ops->id);
-		}
-
+		__skb_queue_tail(&q->qdisc->requeue, skb);
 		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 	}
 
-- 
1.5.6.5.GIT

