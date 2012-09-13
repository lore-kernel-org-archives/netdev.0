From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 4/4] net_sched: gred: actually perform idling in WRED mode
Date: Thu, 13 Sep 2012 11:22:35 -0400
Message-ID: <1347549755-19438-4-git-send-email-david.ward@ll.mit.edu>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bruce Osler <brosler@cisco.com>, Cyril Chemparathy <cyril@ti.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:48066 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758106Ab2IMPf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 11:35:59 -0400
In-Reply-To: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gred_dequeue() and gred_drop() do not seem to get called when the
queue is empty, meaning that we never start idling while in WRED
mode. And since qidlestart is not stored by gred_store_wred_set(),
we would never stop idling while in WRED mode if we ever started.
This messes up the average queue size calculation that influences
packet marking/dropping behavior.

Now, we start WRED mode idling as we are removing the last packet
from the queue. Also we now actually stop WRED mode idling when we
are enqueuing a packet.

Cc: Bruce Osler <brosler@cisco.com>
Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/sched/sch_gred.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index b2570b5..d42234c 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -136,6 +136,7 @@ static inline void gred_store_wred_set(struct gred_sched *table,
 				       struct gred_sched_data *q)
 {
 	table->wred_set.qavg = q->vars.qavg;
+	table->wred_set.qidlestart = q->vars.qidlestart;
 }
 
 static inline int gred_use_ecn(struct gred_sched *t)
@@ -259,16 +260,18 @@ static struct sk_buff *gred_dequeue(struct Qdisc *sch)
 		} else {
 			q->backlog -= qdisc_pkt_len(skb);
 
-			if (!q->backlog && !gred_wred_mode(t))
-				red_start_of_idle_period(&q->vars);
+			if (gred_wred_mode(t)) {
+				if (!sch->qstats.backlog)
+					red_start_of_idle_period(&t->wred_set);
+			} else {
+				if (!q->backlog)
+					red_start_of_idle_period(&q->vars);
+			}
 		}
 
 		return skb;
 	}
 
-	if (gred_wred_mode(t) && !red_is_idling(&t->wred_set))
-		red_start_of_idle_period(&t->wred_set);
-
 	return NULL;
 }
 
@@ -290,19 +293,20 @@ static unsigned int gred_drop(struct Qdisc *sch)
 			q->backlog -= len;
 			q->stats.other++;
 
-			if (!q->backlog && !gred_wred_mode(t))
-				red_start_of_idle_period(&q->vars);
+			if (gred_wred_mode(t)) {
+				if (!sch->qstats.backlog)
+					red_start_of_idle_period(&t->wred_set);
+			} else {
+				if (!q->backlog)
+					red_start_of_idle_period(&q->vars);
+			}
 		}
 
 		qdisc_drop(skb, sch);
 		return len;
 	}
 
-	if (gred_wred_mode(t) && !red_is_idling(&t->wred_set))
-		red_start_of_idle_period(&t->wred_set);
-
 	return 0;
-
 }
 
 static void gred_reset(struct Qdisc *sch)
-- 
1.7.4.1
