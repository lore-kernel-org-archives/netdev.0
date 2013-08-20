From: Ferry Huberts <mailings@hupie.com>
Subject: [PATCH 2/2] net: netem: always adjust now/delay when not reordering
Date: Tue, 20 Aug 2013 17:11:09 +0200
Message-ID: <1377011469-26151-2-git-send-email-mailings@hupie.com>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hupie.dyndns.org ([80.101.237.101]:35332 "EHLO hupie.dyndns.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194Ab3HTPa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 11:30:27 -0400
Received: from stinkpad.internal.hupie.com.nl (unknown [188.205.88.52])
	by hupie.dyndns.org (Postfix) with ESMTP id 40C59485DD4
	for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 17:11:10 +0200 (CEST)
In-Reply-To: <1377011469-26151-1-git-send-email-mailings@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ferry Huberts <ferry.huberts@pelagic.nl>

Not doing this (current behaviour) introduces reordering.

The packet_len_2_sched_time call is the only thing that logically
depends on q->rate, so move the now/delay adjustment out of the if.

Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
---
 net/sched/sch_netem.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index abe5fa6..86c73d2 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -457,6 +457,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (q->gap == 0 || q->reorder == 0 || /* not doing reordering */
 	    q->counter < q->gap - 1 ||	/* inside last reordering gap */
 	    q->reorder < get_crandom(&q->reorder_cor)) {
+		struct sk_buff *last;
+
 		psched_time_t now;
 		psched_tdiff_t delay;
 
@@ -465,24 +467,22 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		now = psched_get_time();
 
-		if (q->rate) {
-			struct sk_buff *last;
-
-			if (!skb_queue_empty(&sch->q))
-				last = skb_peek_tail(&sch->q);
-			else
-				last = netem_rb_to_skb(rb_last(&q->t_root));
-			if (last) {
-				/*
-				 * Last packet in queue is reference point (now),
-				 * calculate this time bonus and subtract
-				 * from delay.
-				 */
-				delay -= netem_skb_cb(last)->time_to_send - now;
-				delay = max_t(psched_tdiff_t, 0, delay);
-				now = netem_skb_cb(last)->time_to_send;
-			}
+		if (!skb_queue_empty(&sch->q))
+			last = skb_peek_tail(&sch->q);
+		else
+			last = netem_rb_to_skb(rb_last(&q->t_root));
+		if (last) {
+			/*
+			 * Last packet in queue is reference point (now),
+			 * calculate this time bonus and subtract
+			 * from delay.
+			 */
+			delay -= netem_skb_cb(last)->time_to_send - now;
+			delay = max_t(psched_tdiff_t, 0, delay);
+			now = netem_skb_cb(last)->time_to_send;
+		}
 
+		if (q->rate) {
 			delay += packet_len_2_sched_time(skb->len, q);
 		}
 
-- 
1.8.3.1
