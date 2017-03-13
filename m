From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netem: apply correct delay when rate throttling
Date: Mon, 13 Mar 2017 10:16:58 -0700
Message-ID: <20170313171658.18606-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Nik Unger <njunger@uwaterloo.ca>,
        Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35879 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753485AbdCMRRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 13:17:36 -0400
Received: by mail-pg0-f46.google.com with SMTP id g2so48739775pge.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 10:17:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nik Unger <njunger@uwaterloo.ca>

I recently reported on the netem list that iperf network benchmarks
show unexpected results when a bandwidth throttling rate has been
configured for netem. Specifically:

1) The measured link bandwidth *increases* when a higher delay is added
2) The measured link bandwidth appears higher than the specified limit
3) The measured link bandwidth for the same very slow settings varies significantly across
  machines

The issue can be reproduced by using tc to configure netem with a
512kbit rate and various (none, 1us, 50ms, 100ms, 200ms) delays on a
veth pair between network namespaces, and then using iperf (or any
other network benchmarking tool) to test throughput. Complete detailed
instructions are in the original email chain here:
https://lists.linuxfoundation.org/pipermail/netem/2017-February/001672.html

There appear to be two underlying bugs causing these effects:

- The first issue causes long delays when the rate is slow and no
  delay is configured (e.g., "rate 512kbit"). This is because SKBs are
  not orphaned when no delay is configured, so orphaning does not
  occur until *after* the rate-induced delay has been applied. For
  this reason, adding a tiny delay (e.g., "rate 512kbit delay 1us")
  dramatically increases the measured bandwidth.

- The second issue is that rate-induced delays are not correctly
  applied, allowing SKB delays to occur in parallel. The indended
  approach is to compute the delay for an SKB and to add this delay to
  the end of the current queue. However, the code does not detect
  existing SKBs in the queue due to improperly testing sch->q.qlen,
  which is nonzero even when packets exist only in the
  rbtree. Consequently, new SKBs do not wait for the current queue to
  empty. When packet delays vary significantly (e.g., if packet sizes
  are different), then this also causes unintended reordering.

I modified the code to expect a delay (and orphan the SKB) when a rate
is configured. I also added some defensive tests that correctly find
the latest scheduled delivery time, even if it is (unexpectedly) for a
packet in sch->q. I have tested these changes on the latest kernel
(4.11.0-rc1+) and the iperf / ping test results are as expected.

Signed-off-by: Nik Unger <njunger@uwaterloo.ca>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sched/sch_netem.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index c8bb62a1e744..94b4928ad413 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -462,7 +462,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	/* If a delay is expected, orphan the skb. (orphaning usually takes
 	 * place at TX completion time, so _before_ the link transit delay)
 	 */
-	if (q->latency || q->jitter)
+	if (q->latency || q->jitter || q->rate)
 		skb_orphan_partial(skb);
 
 	/*
@@ -530,21 +530,31 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		now = psched_get_time();
 
 		if (q->rate) {
-			struct sk_buff *last;
+			struct netem_skb_cb *last = NULL;
+
+			if (sch->q.tail)
+				last = netem_skb_cb(sch->q.tail);
+			if (q->t_root.rb_node) {
+				struct sk_buff *t_skb;
+				struct netem_skb_cb *t_last;
+
+				t_skb = netem_rb_to_skb(rb_last(&q->t_root));
+				t_last = netem_skb_cb(t_skb);
+				if (!last ||
+				    t_last->time_to_send > last->time_to_send) {
+					last = t_last;
+				}
+			}
 
-			if (sch->q.qlen)
-				last = sch->q.tail;
-			else
-				last = netem_rb_to_skb(rb_last(&q->t_root));
 			if (last) {
 				/*
 				 * Last packet in queue is reference point (now),
 				 * calculate this time bonus and subtract
 				 * from delay.
 				 */
-				delay -= netem_skb_cb(last)->time_to_send - now;
+				delay -= last->time_to_send - now;
 				delay = max_t(psched_tdiff_t, 0, delay);
-				now = netem_skb_cb(last)->time_to_send;
+				now = last->time_to_send;
 			}
 
 			delay += packet_len_2_sched_time(qdisc_pkt_len(skb), q);
-- 
2.11.0
