From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH net-next 1/2] pkt_sched: fq: avoid artificial bursts for clocked flows
Date: Mon,  2 Feb 2015 19:59:15 +0100
Message-ID: <1422903556-30393-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out5.uio.no ([129.240.10.17]:56226 "EHLO mail-out5.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbbBBS7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 13:59:43 -0500
Received: from mail-mx4.uio.no ([129.240.10.45])
	by mail-out5.uio.no with esmtp (Exim 4.80.1)
	(envelope-from <kennetkl@ifi.uio.no>)
	id 1YIMDl-0007pG-PI
	for netdev@vger.kernel.org; Mon, 02 Feb 2015 19:59:41 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current pacing behavior always throttle flows for a time equal to one full
quantum, starting at the instance in time when a flow depletes its credit.
This is optimal for burst sizes that are a multiple of the chosen quantum.

For flows with many small and evenly clocked packets, the depletion and
refilling of credits cause packets to queue and transmit in bursts, even
when their clocked rate is below the pacing rate. With TCP ACKs, this
artificial queueing induces significant noise to RTTs, e.g. up to 2.07 ms
for rtt 20 ms, cwnd 10 and quantum 3028.

Packetdrill script to illustrate bursts:
0.000 socket(..., SOCK_DGRAM, IPPROTO_UDP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 connect(3, ..., ...) = 0

// SO_MAX_PACING_RATE: 2500 Bps, 100 ms per quantum, 20 ms per 50B packet.
0.000 setsockopt(3, SOL_SOCKET, 47, [2500], 4) = 0
0.000 `tc qdisc add dev tun0 root fq initial_quantum 250 quantum 250`

// Use 200 credits: send four perfectly spaced 50 byte packets.
0.000 write(3, ..., 22) = 22
0.000 > udp (22)
0.020 write(3, ..., 22) = 22
0.020 > udp (22)
0.040 write(3, ..., 22) = 22
0.040 > udp (22)
0.060 write(3, ..., 22) = 22
0.060 > udp (22)

// Send five perfectly spaced packets. The first credits are depleted at
// 1.000, and the remaining four packets are sent in a burst at 1.100.
// Packets are sent at their intended times when this patch is applied.
1.000 write(3, ..., 22) = 22
1.000 > udp (22)
1.020 write(3, ..., 22) = 22
1.040 write(3, ..., 22) = 22
1.060 write(3, ..., 22) = 22
1.080 write(3, ..., 22) = 22
1.100 > udp (22)
1.100 > udp (22)
1.100 > udp (22)
1.100 > udp (22)

Keep track of when a flows credit was last filled, and use this to
approximate a credit refill for each quantum of time that passes.

Increases memory footprint from 104 to 112 bytes per flow.

Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 net/sched/sch_fq.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 2a50f5c..6f0c45e 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -71,6 +71,7 @@ struct fq_flow {
 
 	struct rb_node  rate_node;	/* anchor in q->delayed tree */
 	u64		time_next_packet;
+	u64		time_credit_filled;
 };
 
 struct fq_flow_head {
@@ -250,6 +251,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 			if (unlikely(skb->sk &&
 				     f->socket_hash != sk->sk_hash)) {
 				f->credit = q->initial_quantum;
+				f->time_credit_filled = ktime_get_ns();
 				f->socket_hash = sk->sk_hash;
 				f->time_next_packet = 0ULL;
 			}
@@ -271,6 +273,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 	if (skb->sk)
 		f->socket_hash = sk->sk_hash;
 	f->credit = q->initial_quantum;
+	f->time_credit_filled = ktime_get_ns();
 
 	rb_link_node(&f->fq_node, parent, p);
 	rb_insert_color(&f->fq_node, root);
@@ -374,8 +377,10 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	qdisc_qstats_backlog_inc(sch, skb);
 	if (fq_flow_is_detached(f)) {
 		fq_flow_add_tail(&q->new_flows, f);
-		if (time_after(jiffies, f->age + q->flow_refill_delay))
+		if (time_after(jiffies, f->age + q->flow_refill_delay)) {
 			f->credit = max_t(u32, f->credit, q->quantum);
+			f->time_credit_filled = ktime_get_ns();
+		}
 		q->inactive_flows--;
 	}
 
@@ -440,6 +445,7 @@ begin:
 
 	if (f->credit <= 0) {
 		f->credit += q->quantum;
+		f->time_credit_filled = max(now, f->time_next_packet);
 		head->first = f->next;
 		fq_flow_add_tail(&q->old_flows, f);
 		goto begin;
@@ -489,7 +495,10 @@ begin:
 			q->stat_pkts_too_long++;
 		}
 
-		f->time_next_packet = now + len;
+		/* If now < time_next_packet, throttles flow for a time equal
+		 * to one quantum (len) after current credits were filled.
+		 */
+		f->time_next_packet = f->time_credit_filled + len;
 	}
 out:
 	qdisc_bstats_update(sch, skb);
-- 
1.9.1
