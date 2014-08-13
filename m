From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH 1/2] cbq: incorrectly low bandwidth setting blocks limited
 traffic
Date: Wed, 13 Aug 2014 16:38:18 +0400
Message-ID: <53EB5C3A.1040206@parallels.com>
References: <cover.1407918877.git.vvs@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36069 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223AbaHMMj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 08:39:58 -0400
In-Reply-To: <cover.1407918877.git.vvs@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mainstream commit f0f6ee1f70c4eaab9d52cf7d255df4bd89f8d1c2 have side effect:
if cbq bandwidth setting is less than real interface throughput
non-limited traffic can delay limited traffic for a very long time.

This happen because of q->now changes incorrectly in cbq_dequeue():
in described scenario L2T is much greater than real time delay,
and q->now gets an extra boost for each transmitted packet.

Accumulated boost prevents update q->now, and blocked class can wait
very long time until (q->now >= cl->undertime) will be true again.

To fix the problem the patch updates q->now on each cbq_update() call.
L2T-related pre-modification q->now was moved to cbq_update().

My testing confirmed that it fixes the problem and did not discovered
any side-effects.

Signed-off-by: Vasily Averin <vvs@openvz.org>
---
 net/sched/sch_cbq.c |   37 +++++++++++++------------------------
 1 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index ead5264..550be95 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -700,8 +700,13 @@ cbq_update(struct cbq_sched_data *q)
 	struct cbq_class *this = q->tx_class;
 	struct cbq_class *cl = this;
 	int len = q->tx_len;
+	psched_time_t now;
 
 	q->tx_class = NULL;
+	/* Time integrator. We calculate EOS time
+	 * by adding expected packet transmission time.
+	 */
+	now = q->now + L2T(&q->link, len);
 
 	for ( ; cl; cl = cl->share) {
 		long avgidle = cl->avgidle;
@@ -717,7 +722,7 @@ cbq_update(struct cbq_sched_data *q)
 		 *	idle = (now - last) - last_pktlen/rate
 		 */
 
-		idle = q->now - cl->last;
+		idle = now - cl->last;
 		if ((unsigned long)idle > 128*1024*1024) {
 			avgidle = cl->maxidle;
 		} else {
@@ -761,7 +766,7 @@ cbq_update(struct cbq_sched_data *q)
 			idle -= L2T(&q->link, len);
 			idle += L2T(cl, len);
 
-			cl->undertime = q->now + idle;
+			cl->undertime = now + idle;
 		} else {
 			/* Underlimit */
 
@@ -771,7 +776,8 @@ cbq_update(struct cbq_sched_data *q)
 			else
 				cl->avgidle = avgidle;
 		}
-		cl->last = q->now;
+		if ((s64)(now - cl->last) > 0)
+			cl->last = now;
 	}
 
 	cbq_update_toplevel(q, this, q->tx_borrowed);
@@ -943,30 +949,13 @@ cbq_dequeue(struct Qdisc *sch)
 	struct sk_buff *skb;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	psched_time_t now;
-	psched_tdiff_t incr;
 
 	now = psched_get_time();
-	incr = now - q->now_rt;
-
-	if (q->tx_class) {
-		psched_tdiff_t incr2;
-		/* Time integrator. We calculate EOS time
-		 * by adding expected packet transmission time.
-		 * If real time is greater, we warp artificial clock,
-		 * so that:
-		 *
-		 * cbq_time = max(real_time, work);
-		 */
-		incr2 = L2T(&q->link, q->tx_len);
-		q->now += incr2;
+
+	if (q->tx_class)
 		cbq_update(q);
-		if ((incr -= incr2) < 0)
-			incr = 0;
-		q->now += incr;
-	} else {
-		if (now > q->now)
-			q->now = now;
-	}
+
+	q->now = now;
 	q->now_rt = now;
 
 	for (;;) {
-- 
1.7.1
