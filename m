From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] netem: add cell concept to simulate special MAC behavior
Date: Tue, 13 Dec 2011 01:30:00 +0100
Message-ID: <1323736200-1252-1-git-send-email-hagen@jauu.net>
References: <20111212.190132.2127710068935598402.davem@davemloft.net>
Cc: davem@davemloft.net, Hagen Paul Pfeifer <hagen@jauu.net>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:49006 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753634Ab1LMAaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 19:30:08 -0500
In-Reply-To: <20111212.190132.2127710068935598402.davem@davemloft.net>
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
overhead is an additional variable to change the per-cell-overhead
(e.g.  5 byte header per fragment).

Example (5 kbit/s, 20 byte per packet overhead, cell-size 100 byte, per
cell overhead 5 byte):

  tc qdisc add dev eth0 root netem rate 5kbit 20 100 5

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 include/linux/pkt_sched.h |    3 +++
 net/sched/sch_netem.c     |   33 +++++++++++++++++++++++++++++----
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 8786ea7..8daced3 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -502,6 +502,9 @@ struct tc_netem_corrupt {
 
 struct tc_netem_rate {
 	__u32	rate;	/* byte/s */
+	__s32	packet_overhead;
+	__u32	cell_size;
+	__s32	cell_overhead;
 };
 
 enum {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3bfd733..1fa2f90 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -22,6 +22,7 @@
 #include <linux/skbuff.h>
 #include <linux/vmalloc.h>
 #include <linux/rtnetlink.h>
+#include <linux/reciprocal_div.h>
 
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
@@ -80,6 +81,10 @@ struct netem_sched_data {
 	u32 reorder;
 	u32 corrupt;
 	u32 rate;
+	s32 packet_overhead;
+	u32 cell_size;
+	u32 cell_size_reciprocal;
+	s32 cell_overhead;
 
 	struct crndstate {
 		u32 last;
@@ -299,11 +304,23 @@ static psched_tdiff_t tabledist(psched_tdiff_t mu, psched_tdiff_t sigma,
 	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
 }
 
-static psched_time_t packet_len_2_sched_time(unsigned int len, u32 rate)
+static psched_time_t packet_len_2_sched_time(unsigned int len, struct netem_sched_data *q)
 {
-	u64 ticks = (u64)len * NSEC_PER_SEC;
+	u64 ticks;
 
-	do_div(ticks, rate);
+	len += q->packet_overhead;
+
+	if (q->cell_size) {
+		u32 cells = reciprocal_divide(len, q->cell_size_reciprocal);
+
+		if (len > cells * q->cell_size)	/* extra cell needed for remainder */
+			cells++;
+		len = cells * (q->cell_size + q->cell_overhead);
+	}
+
+	ticks = (u64)len * NSEC_PER_SEC;
+
+	do_div(ticks, q->rate);
 	return PSCHED_NS2TICKS(ticks);
 }
 
@@ -384,7 +401,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (q->rate) {
 			struct sk_buff_head *list = &q->qdisc->q;
 
-			delay += packet_len_2_sched_time(skb->len, q->rate);
+			delay += packet_len_2_sched_time(skb->len, q);
 
 			if (!skb_queue_empty(list)) {
 				/*
@@ -568,6 +585,11 @@ static void get_rate(struct Qdisc *sch, const struct nlattr *attr)
 	const struct tc_netem_rate *r = nla_data(attr);
 
 	q->rate = r->rate;
+	q->packet_overhead = r->packet_overhead;
+	q->cell_size = r->cell_size;
+	if (q->cell_size)
+		q->cell_size_reciprocal = reciprocal_value(q->cell_size);
+	q->cell_overhead = r->cell_overhead;
 }
 
 static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
@@ -909,6 +931,9 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
 
 	rate.rate = q->rate;
+	rate.packet_overhead = q->packet_overhead;
+	rate.cell_size = q->cell_size;
+	rate.cell_overhead = q->cell_overhead;
 	NLA_PUT(skb, TCA_NETEM_RATE, sizeof(rate), &rate);
 
 	if (dump_loss_model(q, skb) != 0)
-- 
1.7.7.3
