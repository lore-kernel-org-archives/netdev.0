From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/5] netem: optimize tfifo
Date: Wed, 21 Mar 2007 10:42:34 -0700
Message-ID: <20070321174422.654525319@linux-foundation.org>
References: <20070321174231.890361963@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46928 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933294AbXCUR7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 13:59:02 -0400
Content-Disposition: inline; filename=netem-tfifo-opt.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In most cases, the next packet will be sent after the
last one. So optimize that case.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/sched/sch_netem.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

--- net-2.6.22.orig/net/sched/sch_netem.c
+++ net-2.6.22/net/sched/sch_netem.c
@@ -478,22 +478,28 @@ static int netem_change(struct Qdisc *sc
  */
 struct fifo_sched_data {
 	u32 limit;
+	psched_time_t oldest;
 };
 
 static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 	struct sk_buff_head *list = &sch->q;
-	const struct netem_skb_cb *ncb
-		= (const struct netem_skb_cb *)nskb->cb;
+	psched_time_t tnext = ((struct netem_skb_cb *)nskb->cb)->time_to_send;
 	struct sk_buff *skb;
 
 	if (likely(skb_queue_len(list) < q->limit)) {
+		/* Optimize for add at tail */
+		if (likely(skb_queue_empty(list) || !PSCHED_TLESS(tnext, q->oldest))) {
+			q->oldest = tnext;
+			return qdisc_enqueue_tail(nskb, sch);
+		}
+
 		skb_queue_reverse_walk(list, skb) {
 			const struct netem_skb_cb *cb
 				= (const struct netem_skb_cb *)skb->cb;
 
-			if (!PSCHED_TLESS(ncb->time_to_send, cb->time_to_send))
+			if (!PSCHED_TLESS(tnext, cb->time_to_send))
 				break;
 		}
 
@@ -506,7 +512,7 @@ static int tfifo_enqueue(struct sk_buff 
 		return NET_XMIT_SUCCESS;
 	}
 
-	return qdisc_drop(nskb, sch);
+	return qdisc_reshape_fail(nskb, sch);
 }
 
 static int tfifo_init(struct Qdisc *sch, struct rtattr *opt)
@@ -522,6 +528,7 @@ static int tfifo_init(struct Qdisc *sch,
 	} else
 		q->limit = max_t(u32, sch->dev->tx_queue_len, 1);
 
+	PSCHED_SET_PASTPERFECT(q->oldest);
 	return 0;
 }
 

-- 

