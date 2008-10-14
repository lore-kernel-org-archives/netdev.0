From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 04/14] sch_netem: Use requeue list instead of ops->requeue()
Date: Tue, 14 Oct 2008 09:53:49 +0000
Message-ID: <20081014095349.GE10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915AbYJNJxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:53:55 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:53:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [PATCH 5/9]: sch_netem: Use requeue list instead of ops->requeue()
Date: Mon, 18 Aug 2008 01:37:02 -0700 (PDT)
From: David Miller <davem@davemloft.net>

--------------->
From: David Miller <davem@davemloft.net>
sch_netem: Use requeue list instead of ops->requeue()

This code just wants to make this packet the "front" one, and that's
just as simply done by queueing to the ->requeue list.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_netem.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index cc4d057..5ca92d9 100644
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
1.5.6.5

