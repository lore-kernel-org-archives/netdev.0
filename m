From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: rate limiting improvements
Date: Tue, 01 Oct 2013 09:10:16 -0700
Message-ID: <1380643816.19002.29.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:53617 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab3JAQKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:10:19 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so7324860pbc.36
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 09:10:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

FQ rate limiting suffers from two problems, reported
by Steinar :

1) FQ enforces a delay when flow quantum is exhausted in order
to reduce cpu overhead. But if packets are small, current
delay computation is slightly wrong, and observed rates can
be too high.

Steinar had this problem because he disabled TSO and GSO,
and default FQ quantum is 2*1514.

(Of course, I wish recent TSO auto sizing changes will help
to not having to disable TSO in the first place)

2) maxrate was not used for forwarded flows (skbs not attached
to a socket)

Tested:

tc qdisc add dev eth0 root est 1sec 4sec fq maxrate 8Mbit
netperf -H lpq84 -l 1000 &
sleep 10 ; tc -s qdisc show dev eth0
qdisc fq 8003: root refcnt 32 limit 10000p flow_limit 100p buckets 1024
 quantum 3028 initial_quantum 15140 maxrate 8000Kbit 
 Sent 16819357 bytes 11258 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 7831Kbit 653pps backlog 7570b 5p requeues 0 
  44 flows (43 inactive, 1 throttled), next packet delay 2977352 ns
  0 gc, 0 highprio, 5545 throttled

lpq83:~# tcpdump -p -i eth0 host lpq84 -c 12
09:02:52.079484 IP lpq83 > lpq84: . 1389536928:1389538376(1448) ack 3808678021 win 457 <nop,nop,timestamp 961812 572609068>
09:02:52.079499 IP lpq83 > lpq84: . 1448:2896(1448) ack 1 win 457 <nop,nop,timestamp 961812 572609068>
09:02:52.079906 IP lpq84 > lpq83: . ack 2896 win 16384 <nop,nop,timestamp 572609080 961812>
09:02:52.082568 IP lpq83 > lpq84: . 2896:4344(1448) ack 1 win 457 <nop,nop,timestamp 961815 572609071>
09:02:52.082581 IP lpq83 > lpq84: . 4344:5792(1448) ack 1 win 457 <nop,nop,timestamp 961815 572609071>
09:02:52.083017 IP lpq84 > lpq83: . ack 5792 win 16384 <nop,nop,timestamp 572609083 961815>
09:02:52.085678 IP lpq83 > lpq84: . 5792:7240(1448) ack 1 win 457 <nop,nop,timestamp 961818 572609074>
09:02:52.085693 IP lpq83 > lpq84: . 7240:8688(1448) ack 1 win 457 <nop,nop,timestamp 961818 572609074>
09:02:52.086117 IP lpq84 > lpq83: . ack 8688 win 16384 <nop,nop,timestamp 572609086 961818>
09:02:52.088792 IP lpq83 > lpq84: . 8688:10136(1448) ack 1 win 457 <nop,nop,timestamp 961821 572609077>
09:02:52.088806 IP lpq83 > lpq84: . 10136:11584(1448) ack 1 win 457 <nop,nop,timestamp 961821 572609077>
09:02:52.089217 IP lpq84 > lpq83: . ack 11584 win 16384 <nop,nop,timestamp 572609090 961821>

Reported-by: Steinar H. Gunderson <sesse@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c |   45 ++++++++++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 19 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index fc6de56..a2fef8b 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -420,6 +420,7 @@ static struct sk_buff *fq_dequeue(struct Qdisc *sch)
 	struct fq_flow_head *head;
 	struct sk_buff *skb;
 	struct fq_flow *f;
+	u32 rate;
 
 	skb = fq_dequeue_head(sch, &q->internal);
 	if (skb)
@@ -468,28 +469,34 @@ begin:
 	f->time_next_packet = now;
 	f->credit -= qdisc_pkt_len(skb);
 
-	if (f->credit <= 0 &&
-	    q->rate_enable &&
-	    skb->sk && skb->sk->sk_state != TCP_TIME_WAIT) {
-		u32 rate = skb->sk->sk_pacing_rate ?: q->flow_default_rate;
+	if (f->credit > 0 || !q->rate_enable)
+		goto out;
 
-		rate = min(rate, q->flow_max_rate);
-		if (rate) {
-			u64 len = (u64)qdisc_pkt_len(skb) * NSEC_PER_SEC;
-
-			do_div(len, rate);
-			/* Since socket rate can change later,
-			 * clamp the delay to 125 ms.
-			 * TODO: maybe segment the too big skb, as in commit
-			 * e43ac79a4bc ("sch_tbf: segment too big GSO packets")
-			 */
-			if (unlikely(len > 125 * NSEC_PER_MSEC)) {
-				len = 125 * NSEC_PER_MSEC;
-				q->stat_pkts_too_long++;
-			}
+	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT) {
+		rate = skb->sk->sk_pacing_rate ?: q->flow_default_rate;
 
-			f->time_next_packet = now + len;
+		rate = min(rate, q->flow_max_rate);
+	} else {
+		rate = q->flow_max_rate;
+		if (rate == ~0U)
+			goto out;
+	}
+	if (rate) {
+		u32 plen = max(qdisc_pkt_len(skb), q->quantum);
+		u64 len = (u64)plen * NSEC_PER_SEC;
+
+		do_div(len, rate);
+		/* Since socket rate can change later,
+		 * clamp the delay to 125 ms.
+		 * TODO: maybe segment the too big skb, as in commit
+		 * e43ac79a4bc ("sch_tbf: segment too big GSO packets")
+		 */
+		if (unlikely(len > 125 * NSEC_PER_MSEC)) {
+			len = 125 * NSEC_PER_MSEC;
+			q->stat_pkts_too_long++;
 		}
+
+		f->time_next_packet = now + len;
 	}
 out:
 	qdisc_bstats_update(sch, skb);
