From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_sfq: rehash queues in perturb timer
Date: Wed, 21 Dec 2011 14:30:11 +0100
Message-ID: <1324474211.2728.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:63681 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751671Ab1LUNaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 08:30:16 -0500
Received: by lahd3 with SMTP id d3so540111lah.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 05:30:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A known Out Of Order (OOO) problem hurts SFQ when timer changes
perturbation value, since all new packets delivered to SFQ enqueue might
end on different slots than previous in-flight packets.

With round robin delivery, we can thus deliver packets in a different
order.

Since SFQ is limited to small amount of in-flight packets, we can rehash
packets so that this OOO problem is fixed.

This rehashing is performed only if internal flow classifier is in use.

We now store in skb->cb[] the "struct flow_keys" so that we dont call
skb_flow_dissect() again while rehashing.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |   87 +++++++++++++++++++++++++++++++++++++++---
 1 file changed, 81 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 30cda70..d329a8a 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -136,16 +136,30 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 	return &q->dep[val - SFQ_SLOTS];
 }
 
+/*
+ * In order to be able to quickly rehash our queue when timer changes
+ * q->perturbation, we store flow_keys in skb->cb[]
+ */
+struct sfq_skb_cb {
+       struct flow_keys        keys;
+};
+
+static inline struct sfq_skb_cb *sfq_skb_cb(const struct sk_buff *skb)
+{
+       BUILD_BUG_ON(sizeof(skb->cb) <
+               sizeof(struct qdisc_skb_cb) + sizeof(struct sfq_skb_cb));
+       return (struct sfq_skb_cb *)qdisc_skb_cb(skb)->data;
+}
+
 static unsigned int sfq_hash(const struct sfq_sched_data *q,
 			     const struct sk_buff *skb)
 {
-	struct flow_keys keys;
+	const struct flow_keys *keys = &sfq_skb_cb(skb)->keys;
 	unsigned int hash;
 
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
+	hash = jhash_3words((__force u32)keys->dst,
+			    (__force u32)keys->src ^ keys->ip_proto,
+			    (__force u32)keys->ports, q->perturbation);
 	return hash & (q->divisor - 1);
 }
 
@@ -161,8 +175,10 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	    TC_H_MIN(skb->priority) <= q->divisor)
 		return TC_H_MIN(skb->priority);
 
-	if (!q->filter_list)
+	if (!q->filter_list) {
+		skb_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
 		return sfq_hash(q, skb) + 1;
+	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	result = tc_classify(skb, q->filter_list, &res);
@@ -423,12 +439,71 @@ sfq_reset(struct Qdisc *sch)
 		kfree_skb(skb);
 }
 
+/*
+ * When q->perturbation is changed, we rehash all queued skbs
+ * to avoid OOO (Out Of Order) effects.
+ * We dont use sfq_dequeue()/sfq_enqueue() because we dont want to change
+ * counters.
+ */
+static void sfq_rehash(struct sfq_sched_data *q)
+{
+	struct sk_buff *skb;
+	int i;
+	struct sfq_slot *slot;
+	struct sk_buff_head list;
+
+	__skb_queue_head_init(&list);
+
+	for (i = 0; i < SFQ_SLOTS; i++) {
+		slot = &q->slots[i];
+		if (!slot->qlen)
+			continue;
+		while (slot->qlen) {
+			skb = slot_dequeue_head(slot);
+			sfq_dec(q, i);
+			__skb_queue_tail(&list, skb);
+		}
+		q->ht[slot->hash] = SFQ_EMPTY_SLOT;
+	}
+	q->tail = NULL;
+
+	while ((skb = __skb_dequeue(&list)) != NULL) {
+		unsigned int hash = sfq_hash(q, skb);
+		sfq_index x = q->ht[hash];
+
+		slot = &q->slots[x];
+		if (x == SFQ_EMPTY_SLOT) {
+			x = q->dep[0].next; /* get a free slot */
+			q->ht[hash] = x;
+			slot = &q->slots[x];
+			slot->hash = hash;
+		}
+		slot_queue_add(slot, skb);
+		sfq_inc(q, x);
+		if (slot->qlen == 1) {		/* The flow is new */
+			if (q->tail == NULL) {	/* It is the first flow */
+				slot->next = x;
+			} else {
+				slot->next = q->tail->next;
+				q->tail->next = x;
+			}
+			q->tail = slot;
+			slot->allot = q->scaled_quantum;
+		}
+	}
+}
+
 static void sfq_perturbation(unsigned long arg)
 {
 	struct Qdisc *sch = (struct Qdisc *)arg;
 	struct sfq_sched_data *q = qdisc_priv(sch);
+	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
 
+	spin_lock(root_lock);
 	q->perturbation = net_random();
+	if (!q->filter_list && q->tail)
+		sfq_rehash(q);
+	spin_unlock(root_lock);
 
 	if (q->perturb_period)
 		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
