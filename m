From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] sch_netem: replace magic numbers with enumerate
Date: Sat, 18 Jan 2014 18:13:31 +0800
Message-ID: <1390040011-13296-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:18126 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbaARKNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 05:13:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace some magic numbers which describe states of 4-state model
loss generator with enumerate.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 47 ++++++++++++++++++++++++++++-------------------
 1 file changed, 28 insertions(+), 19 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3019c10..a2bfc37 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -110,6 +110,13 @@ struct netem_sched_data {
 		CLG_GILB_ELL,
 	} loss_model;
 
+	enum {
+		TX_IN_GAP_PERIOD = 1,
+		TX_IN_BURST_PERIOD,
+		LOST_IN_GAP_PERIOD,
+		LOST_IN_BURST_PERIOD,
+	} _4_state_model;
+
 	/* Correlated Loss Generation models */
 	struct clgstate {
 		/* state of the Markov chain */
@@ -205,43 +212,45 @@ static bool loss_4state(struct netem_sched_data *q)
 	 * probabilities outgoing from the current state, then decides the
 	 * next state and if the next packet has to be transmitted or lost.
 	 * The four states correspond to:
-	 *   1 => successfully transmitted packets within a gap period
-	 *   4 => isolated losses within a gap period
-	 *   3 => lost packets within a burst period
-	 *   2 => successfully transmitted packets within a burst period
+	 *   TX_IN_GAP_PERIOD => successfully transmitted packets within a gap period
+	 *   LOST_IN_BURST_PERIOD => isolated losses within a gap period
+	 *   LOST_IN_GAP_PERIOD => lost packets within a burst period
+	 *   TX_IN_GAP_PERIOD => successfully transmitted packets within a burst period
 	 */
 	switch (clg->state) {
-	case 1:
+	case TX_IN_GAP_PERIOD:
 		if (rnd < clg->a4) {
-			clg->state = 4;
+			clg->state = LOST_IN_BURST_PERIOD;
 			return true;
 		} else if (clg->a4 < rnd && rnd < clg->a1 + clg->a4) {
-			clg->state = 3;
+			clg->state = LOST_IN_GAP_PERIOD;
 			return true;
-		} else if (clg->a1 + clg->a4 < rnd)
-			clg->state = 1;
+		} else if (clg->a1 + clg->a4 < rnd) {
+			clg->state = TX_IN_GAP_PERIOD;
+		}
 
 		break;
-	case 2:
+	case TX_IN_BURST_PERIOD:
 		if (rnd < clg->a5) {
-			clg->state = 3;
+			clg->state = LOST_IN_GAP_PERIOD;
 			return true;
-		} else
-			clg->state = 2;
+		} else {
+			clg->state = TX_IN_BURST_PERIOD;
+		}
 
 		break;
-	case 3:
+	case LOST_IN_GAP_PERIOD:
 		if (rnd < clg->a3)
-			clg->state = 2;
+			clg->state = TX_IN_BURST_PERIOD;
 		else if (clg->a3 < rnd && rnd < clg->a2 + clg->a3) {
-			clg->state = 1;
+			clg->state = TX_IN_GAP_PERIOD;
 		} else if (clg->a2 + clg->a3 < rnd) {
-			clg->state = 3;
+			clg->state = LOST_IN_GAP_PERIOD;
 			return true;
 		}
 		break;
-	case 4:
-		clg->state = 1;
+	case LOST_IN_BURST_PERIOD:
+		clg->state = TX_IN_GAP_PERIOD;
 		break;
 	}
 
-- 
1.8.0
