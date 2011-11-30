From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH v3 net-next 1/2] netem: rate extension
Date: Wed, 30 Nov 2011 23:20:26 +0100
Message-ID: <1322691627-20551-1-git-send-email-hagen@jauu.net>
Cc: eric.dumazet@gmail.com, Stephen Hemminger <shemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44003 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751664Ab1K3WUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:20:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently netem is not in the ability to emulate channel bandwidth. Only static
delay (and optional random jitter) can be configured.

To emulate the channel rate the token bucket filter (sch_tbf) can be used.  But
TBF has some major emulation flaws. The buffer (token bucket depth/rate) cannot
be 0. Also the idea behind TBF is that the credit (token in buckets) fills if
no packet is transmitted. So that there is always a "positive" credit for new
packets. In real life this behavior contradicts the law of nature where
nothing can travel faster as speed of light. E.g.: on an emulated 1000 byte/s
link a small IPv4/TCP SYN packet with ~50 byte require ~0.05 seconds - not 0
seconds.

Netem is an excellent place to implement a rate limiting feature: static
delay is already implemented, tfifo already has time information and the
user can skip TBF configuration completely.

This patch implement rate feature which can be configured via tc. e.g:

	tc qdisc add dev eth0 root netem rate 10kbit

To emulate a link of 5000byte/s and add an additional static delay of 10ms:

	tc qdisc add dev eth0 root netem delay 10ms rate 5KBps

Note: similar to TBF the rate extension is bounded to the kernel timing
system. Depending on the architecture timer granularity, higher rates (e.g.
10mbit/s and higher) tend to transmission bursts. Also note: further queues
living in network adaptors; see ethtool(8).

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/pkt_sched.h |    5 +++++
 net/sched/sch_netem.c     |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index c533670..26c37ca 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -465,6 +465,7 @@ enum {
 	TCA_NETEM_REORDER,
 	TCA_NETEM_CORRUPT,
 	TCA_NETEM_LOSS,
+	TCA_NETEM_RATE,
 	__TCA_NETEM_MAX,
 };
 
@@ -495,6 +496,10 @@ struct tc_netem_corrupt {
 	__u32	correlation;
 };
 
+struct tc_netem_rate {
+	__u32	rate;	/* byte/s */
+};
+
 enum {
 	NETEM_LOSS_UNSPEC,
 	NETEM_LOSS_GI,		/* General Intuitive - 4 state model */
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index eb3b9a8..9b7af9f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -79,6 +79,7 @@ struct netem_sched_data {
 	u32 duplicate;
 	u32 reorder;
 	u32 corrupt;
+	u32 rate;
 
 	struct crndstate {
 		u32 last;
@@ -298,6 +299,11 @@ static psched_tdiff_t tabledist(psched_tdiff_t mu, psched_tdiff_t sigma,
 	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
 }
 
+static psched_time_t packet_len_2_sched_time(unsigned int len, u32 rate)
+{
+	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / rate);
+}
+
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -371,6 +377,24 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				  &q->delay_cor, q->delay_dist);
 
 		now = psched_get_time();
+
+		if (q->rate) {
+			struct sk_buff_head *list = &q->qdisc->q;
+
+			delay += packet_len_2_sched_time(skb->len, q->rate);
+
+			if (!skb_queue_empty(list)) {
+				/*
+				 * Last packet in queue is reference point (now).
+				 * First packet in queue is already in flight,
+				 * calculate this time bonus and substract
+				 * from delay.
+				 */
+				delay -= now - netem_skb_cb(skb_peek(list))->time_to_send;
+				now = netem_skb_cb(skb_peek_tail(list))->time_to_send;
+			}
+		}
+
 		cb->time_to_send = now + delay;
 		++q->counter;
 		ret = qdisc_enqueue(skb, q->qdisc);
@@ -535,6 +559,14 @@ static void get_corrupt(struct Qdisc *sch, const struct nlattr *attr)
 	init_crandom(&q->corrupt_cor, r->correlation);
 }
 
+static void get_rate(struct Qdisc *sch, const struct nlattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	const struct tc_netem_rate *r = nla_data(attr);
+
+	q->rate = r->rate;
+}
+
 static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -594,6 +626,7 @@ static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
 	[TCA_NETEM_CORR]	= { .len = sizeof(struct tc_netem_corr) },
 	[TCA_NETEM_REORDER]	= { .len = sizeof(struct tc_netem_reorder) },
 	[TCA_NETEM_CORRUPT]	= { .len = sizeof(struct tc_netem_corrupt) },
+	[TCA_NETEM_RATE]	= { .len = sizeof(struct tc_netem_rate) },
 	[TCA_NETEM_LOSS]	= { .type = NLA_NESTED },
 };
 
@@ -666,6 +699,9 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_NETEM_CORRUPT])
 		get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
 
+	if (tb[TCA_NETEM_RATE])
+		get_rate(sch, tb[TCA_NETEM_RATE]);
+
 	q->loss_model = CLG_RANDOM;
 	if (tb[TCA_NETEM_LOSS])
 		ret = get_loss_clg(sch, tb[TCA_NETEM_LOSS]);
@@ -846,6 +882,7 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct tc_netem_corr cor;
 	struct tc_netem_reorder reorder;
 	struct tc_netem_corrupt corrupt;
+	struct tc_netem_rate rate;
 
 	qopt.latency = q->latency;
 	qopt.jitter = q->jitter;
@@ -868,6 +905,9 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	corrupt.correlation = q->corrupt_cor.rho;
 	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
 
+	rate.rate = q->rate;
+	NLA_PUT(skb, TCA_NETEM_RATE, sizeof(rate), &rate);
+
 	if (dump_loss_model(q, skb) != 0)
 		goto nla_put_failure;
 
-- 
1.7.7
