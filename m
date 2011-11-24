From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH net-next 2/2] netem: add cell concept to simulate special MAC behavior
Date: Thu, 24 Nov 2011 18:39:37 +0100
Message-ID: <1322156378-23257-2-git-send-email-hagen@jauu.net>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:37273 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751196Ab1KXRjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 12:39:51 -0500
In-Reply-To: <1322156378-23257-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extension can be used to simulate special link layer
characteristics. Simulate because packet data is not modified, only the
calculation base is changed to delay a packet based on the original
packet size and artificial cell information.

packet_overhead can be used to simulate a link layer header compression
scheme (e.g. set packet_overhead to -20) or with a positive
packet_overhead value an additional MAC header can be simulated. It is
also possible to "replace" the 14 byte Ethernet header with something
else.

cell_size and cell_overhead can be used to simulate link layer schemes,
based on cells, like some TDMA schemes. Another application area are MAC
schemes using a link layer fragmentation with a (small) header each.
Cell size is the maximum amount of data bytes within one cell. Cell
overhead is an additional variable to change the per-cell-overhead (e.g.
5 byte header per fragment).

Example (5 kbit/s, 20 byte per packet overhead, cellsize 100 byte, per
cell overhead 5 byte):

	tc qdisc add dev eth0 root netem ratelatency 5kbit 20 100 5

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/linux/pkt_sched.h |    3 +++
 net/sched/sch_netem.c     |   30 +++++++++++++++++++++++++++---
 2 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index cf826d3..5ad3858 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -498,6 +498,9 @@ struct tc_netem_corrupt {
 
 struct tc_netem_ratelatency {
 	__u32	ratelatency;	/* byte/s */
+	__s32   packet_overhead;
+	__u32   cell_size;
+	__s32   cell_overhead;
 };
 
 enum {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3ae1cdd..40ad634 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -80,6 +80,9 @@ struct netem_sched_data {
 	u32 reorder;
 	u32 corrupt;
 	u32 ratelatency;
+	s32 packet_overhead;
+	u32 cell_size;
+	s32 cell_overhead;
 
 	struct crndstate {
 		u32 last;
@@ -299,9 +302,24 @@ static psched_tdiff_t tabledist(psched_tdiff_t mu, psched_tdiff_t sigma,
 	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
 }
 
-static psched_time_t packet_len_2_sched_time(unsigned int len, u32 rate)
+static psched_time_t packet_len_2_sched_time(unsigned int len,
+					     struct netem_sched_data *q)
 {
-	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / rate);
+	len += q->packet_overhead;
+
+	if (q->cell_size) {
+		u32 carry = len % q->cell_size;
+		len += carry;
+
+		if (q->cell_overhead) {
+			u32 cells = len / q->cell_size;
+			if (carry)
+				cells += 1;
+			len += cells * q->cell_overhead;
+		}
+	}
+
+	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / q->ratelatency);
 }
 
 /*
@@ -381,7 +399,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (q->ratelatency) {
 			struct sk_buff_head *list = &q->qdisc->q;
 
-			delay += packet_len_2_sched_time(skb->len, q->ratelatency);
+			delay += packet_len_2_sched_time(skb->len, q);
 
 			if (!skb_queue_empty(list)) {
 				/*
@@ -565,6 +583,9 @@ static void get_ratelatency(struct Qdisc *sch, const struct nlattr *attr)
 	const struct tc_netem_ratelatency *r = nla_data(attr);
 
 	q->ratelatency = r->ratelatency;
+	q->packet_overhead = r->packet_overhead;
+	q->cell_size       = r->cell_size;
+	q->cell_overhead   = r->cell_overhead;
 }
 
 static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
@@ -906,6 +927,9 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
 
 	ratelatency.ratelatency = q->ratelatency;
+	ratelatency.packet_overhead = q->packet_overhead;
+	ratelatency.cell_size       = q->cell_size;
+	ratelatency.cell_overhead   = q->cell_overhead;
 	NLA_PUT(skb, TCA_NETEM_RATELATENCY, sizeof(ratelatency), &ratelatency);
 
 	if (dump_loss_model(q, skb) != 0)
-- 
1.7.7
