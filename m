From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] sch_sfq: store flow_keys in skb->cb[]
Date: Fri, 16 Dec 2011 06:39:39 +0100
Message-ID: <1324013979.2562.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41511 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198Ab1LPFjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 00:39:43 -0500
Received: by werm1 with SMTP id m1so286053wer.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 21:39:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using automatic flow_keys variable in sfq_hash(), use storage
from skb->cb[] so that we can reuse it later if we want to rehash queues
when perturbation timer fires.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 46d0d77..72bccd0 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -136,16 +136,31 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 	return &q->dep[val - SFQ_SLOTS];
 }
 
+/*
+ * In order to be able to quickly rehash our queue when timer changes
+ * q->perturbation, we store flow_keys in skb->cb[]
+ */
+struct sfq_skb_cb {
+	struct flow_keys	keys;
+};
+
+static inline struct sfq_skb_cb *sfq_skb_cb(const struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) <
+		sizeof(struct qdisc_skb_cb) + sizeof(struct sfq_skb_cb));
+	return (struct sfq_skb_cb *)qdisc_skb_cb(skb)->data;
+}
+
 static unsigned int sfq_hash(const struct sfq_sched_data *q,
-			     const struct sk_buff *skb)
+			     struct sk_buff *skb)
 {
-	struct flow_keys keys;
+	struct flow_keys *keys = &sfq_skb_cb(skb)->keys;
 	unsigned int hash;
 
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
+	skb_flow_dissect(skb, keys);
+	hash = jhash_3words((__force u32)keys->dst,
+			    (__force u32)keys->src ^ keys->ip_proto,
+			    (__force u32)keys->ports, q->perturbation);
 	return hash & (q->divisor - 1);
 }
 
