From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_tbf: segment too big GSO packets
Date: Tue, 21 May 2013 11:16:46 -0700
Message-ID: <1369160206.3301.245.camel@edumazet-glaptop>
References: <20130520044850.31127.24148.reportbug@shadbolt.decadent.org.uk>
	 <1369096123.3469.127.camel@deadeye.wl.decadent.org.uk>
	 <1369097605.3301.203.camel@edumazet-glaptop>
	 <1369101790.3301.206.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:51392 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab3EUSQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 14:16:48 -0400
Received: by mail-oa0-f52.google.com with SMTP id h1so1233693oag.39
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 11:16:48 -0700 (PDT)
In-Reply-To: <1369101790.3301.206.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If a GSO packet has a length above tbf burst limit, the packet
is currently silently dropped.

Current way to handle this is to set the device in non GSO/TSO mode, or
setting high bursts, and its sub optimal.

We can actually segment too big GSO packets, and send individual
segments as tbf parameters allow, allowing for better interoperability.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_tbf.c |   47 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index c8388f3..38008b0 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -116,14 +116,57 @@ struct tbf_sched_data {
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
+
+/* GSO packet is too big, segment it so that tbf can transmit
+ * each segment in time
+ */
+static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct tbf_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *segs, *nskb;
+	netdev_features_t features = netif_skb_features(skb);
+	int ret, nb;
+
+	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
+
+	if (IS_ERR_OR_NULL(segs))
+		return qdisc_reshape_fail(skb, sch);
+
+	nb = 0;
+	while (segs) {
+		nskb = segs->next;
+		segs->next = NULL;
+		if (likely(segs->len <= q->max_size)) {
+			qdisc_skb_cb(segs)->pkt_len = segs->len;
+			ret = qdisc_enqueue(segs, q->qdisc);
+		} else {
+			ret = qdisc_reshape_fail(skb, sch);
+		}
+		if (ret != NET_XMIT_SUCCESS) {
+			if (net_xmit_drop_count(ret))
+				sch->qstats.drops++;
+		} else {
+			nb++;
+		}
+		segs = nskb;
+	}
+	sch->q.qlen += nb;
+	if (nb > 1)
+		qdisc_tree_decrease_qlen(sch, 1 - nb);
+	consume_skb(skb);
+	return nb > 0 ? NET_XMIT_SUCCESS : NET_XMIT_DROP;
+}
+
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (qdisc_pkt_len(skb) > q->max_size)
+	if (qdisc_pkt_len(skb) > q->max_size) {
+		if (skb_is_gso(skb))
+			return tbf_segment(skb, sch);
 		return qdisc_reshape_fail(skb, sch);
-
+	}
 	ret = qdisc_enqueue(skb, q->qdisc);
 	if (ret != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret))
