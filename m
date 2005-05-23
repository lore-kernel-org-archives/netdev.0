From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem: fix logic bug in reorder conditional
Date: Mon, 23 May 2005 10:43:42 -0700
Message-ID: <20050523104342.78b1032d@dxpl.pdx.osdl.net>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
	<682bc30a05052116005bc813a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julio Kriger <juliokriger@gmail.com>
In-Reply-To: <682bc30a05052116005bc813a2@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks, Julio you spotted the problem with the logic.  This should fix it:

Index: netem-2.6.12-rc4/net/sched/sch_netem.c
===================================================================
--- netem-2.6.12-rc4.orig/net/sched/sch_netem.c
+++ netem-2.6.12-rc4/net/sched/sch_netem.c
@@ -181,13 +181,9 @@ static int netem_enqueue(struct sk_buff 
 		q->duplicate = dupsave;
 	}
 
-	/* 
-	 * Do re-ordering by putting one out of N packets at the front
-	 * of the queue.
-	 * gap == 0 is special case for no-reordering.
-	 */
-	if (q->gap == 0 && q->counter < q->gap && 
-	    q->reorder < get_crandom(&q->reorder_cor)) {
+	if (q->gap == 0 		/* not doing reordering */
+	    || q->counter < q->gap 	/* inside last reordering gap */
+	    || q->reorder < get_crandom(&q->reorder_cor)) {
 		psched_time_t now;
 		PSCHED_GET_TIME(now);
 		PSCHED_TADD2(now, tabledist(q->latency, q->jitter, 
@@ -196,6 +192,10 @@ static int netem_enqueue(struct sk_buff 
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
 	} else {
+		/* 
+		 * Do re-ordering by putting one out of N packets at the front
+		 * of the queue.
+		 */
 		PSCHED_GET_TIME(cb->time_to_send);
 		q->counter = 0;
 		ret = q->qdisc->ops->requeue(skb, q->qdisc);
