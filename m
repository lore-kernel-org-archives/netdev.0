From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 02/14] net: sched: reduce qdisc size to 24 byte
Date: Mon,  2 Mar 2015 18:40:16 +0100
Message-ID: <1425318028-26531-3-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54105 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753702AbbCBRkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:40 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its fine as-is, BUT infiniband cb includes qdisc_skb_cb
as first member so it can preserve its cb even if skb is
enqueued in a packet scheduler.

And I haven't found a way to change infiniband so that
it doesn't have to do that yet.
The infiniband cb is currently exactly 48 bytes, reducing
qdisc_cb also reduces ipoib_cb struct to 44 bytes as a result.

Reducing qdisc_cb means we can no longer use flow_keys struct
in sfq, but thats easy to work around, we don't need all its fields.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sch_generic.h |  2 +-
 net/sched/sch_sfq.c       | 29 ++++++++++++++++++++++++-----
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c605d30..baf7e96 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -252,7 +252,7 @@ struct qdisc_skb_cb {
 	unsigned int		pkt_len;
 	u16			slave_dev_queue_mapping;
 	u16			_pad;
-#define QDISC_CB_PRIV_LEN 20
+#define QDISC_CB_PRIV_LEN 16
 	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b877140..06485e8 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -158,10 +158,18 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 
 /*
  * In order to be able to quickly rehash our queue when timer changes
- * q->perturbation, we store flow_keys in skb->cb[]
+ * q->perturbation, we store a few flow keys in skb->cb[]
+ *
+ * We're not using flow_key directly due to cb[] size limitation.
  */
+struct sfq_flow_keys {
+	__be32 src;
+	__be32 dst;
+	__be32 ports;
+};
+
 struct sfq_skb_cb {
-       struct flow_keys        keys;
+	struct sfq_flow_keys keys;
 };
 
 static inline struct sfq_skb_cb *sfq_skb_cb(const struct sk_buff *skb)
@@ -173,15 +181,26 @@ static inline struct sfq_skb_cb *sfq_skb_cb(const struct sk_buff *skb)
 static unsigned int sfq_hash(const struct sfq_sched_data *q,
 			     const struct sk_buff *skb)
 {
-	const struct flow_keys *keys = &sfq_skb_cb(skb)->keys;
+	const struct sfq_flow_keys *keys = &sfq_skb_cb(skb)->keys;
 	unsigned int hash;
 
 	hash = jhash_3words((__force u32)keys->dst,
-			    (__force u32)keys->src ^ keys->ip_proto,
+			    (__force u32)keys->src,
 			    (__force u32)keys->ports, q->perturbation);
 	return hash & (q->divisor - 1);
 }
 
+static void sfq_flow_dissect(const struct sk_buff *skb, struct sfq_flow_keys *flow)
+{
+	struct flow_keys flowk;
+
+	if (skb_flow_dissect(skb, &flowk)) {
+		flow->src = flowk.src ^ flowk.ip_proto,
+		flow->dst = flowk.dst;
+		flow->ports = flowk.ports;
+	}
+}
+
 static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 				 int *qerr)
 {
@@ -197,7 +216,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 
 	fl = rcu_dereference_bh(q->filter_list);
 	if (!fl) {
-		skb_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
+		sfq_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
 		return sfq_hash(q, skb) + 1;
 	}
 
-- 
2.0.5
