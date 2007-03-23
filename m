From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/11]: kill PSCHED_TLESS
Date: Fri, 23 Mar 2007 14:35:44 +0100 (MET)
Message-ID: <20070323133518.10264.68134.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61423 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934279AbXCWNfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:45 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: kill PSCHED_TLESS

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4f8fc418f88c0b7ee6e726b05f27c42d8e20593c
tree c70508f2e0174aef42aaf99bf0cef4184d7ed07e
parent 145a1a6010c6b852ffab28c110d8911a6161aa8b
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 00:00:55 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:28 +0100

 include/net/pkt_sched.h |    1 -
 net/sched/sch_cbq.c     |    7 +++----
 net/sched/sch_netem.c   |    6 +++---
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 32cdf01..49325ff 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -54,7 +54,6 @@ typedef long	psched_tdiff_t;
 #define PSCHED_TDIFF(tv1, tv2)		(long)((tv1) - (tv2))
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 					min_t(long long, (tv1) - (tv2), bound)
-#define PSCHED_TLESS(tv1, tv2)		((tv1) < (tv2))
 #define PSCHED_SET_PASTPERFECT(t)	((t) = 0)
 #define PSCHED_IS_PASTPERFECT(t)	((t) == 0)
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 290b26b..9e6cdab 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -390,7 +390,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 		now = q->now + incr;
 
 		do {
-			if (PSCHED_TLESS(cl->undertime, now)) {
+			if (cl->undertime < now) {
 				q->toplevel = cl->level;
 				return;
 			}
@@ -845,8 +845,7 @@ cbq_under_limit(struct cbq_class *cl)
 	if (cl->tparent == NULL)
 		return cl;
 
-	if (PSCHED_IS_PASTPERFECT(cl->undertime) ||
-	    !PSCHED_TLESS(q->now, cl->undertime)) {
+	if (PSCHED_IS_PASTPERFECT(cl->undertime) || q->now >= cl->undertime) {
 		cl->delayed = 0;
 		return cl;
 	}
@@ -870,7 +869,7 @@ cbq_under_limit(struct cbq_class *cl)
 		if (cl->level > q->toplevel)
 			return NULL;
 	} while (!PSCHED_IS_PASTPERFECT(cl->undertime) &&
-		 PSCHED_TLESS(q->now, cl->undertime));
+		 q->now < cl->undertime);
 
 	cl->delayed = 0;
 	return cl;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 6044ae7..5d571aa 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -286,7 +286,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 		/* if more time remaining? */
 		PSCHED_GET_TIME(now);
 
-		if (!PSCHED_TLESS(now, cb->time_to_send)) {
+		if (cb->time_to_send <= now) {
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
 			return skb;
@@ -494,7 +494,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 
 	if (likely(skb_queue_len(list) < q->limit)) {
 		/* Optimize for add at tail */
-		if (likely(skb_queue_empty(list) || !PSCHED_TLESS(tnext, q->oldest))) {
+		if (likely(skb_queue_empty(list) || tnext >= q->oldest)) {
 			q->oldest = tnext;
 			return qdisc_enqueue_tail(nskb, sch);
 		}
@@ -503,7 +503,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 			const struct netem_skb_cb *cb
 				= (const struct netem_skb_cb *)skb->cb;
 
-			if (!PSCHED_TLESS(tnext, cb->time_to_send))
+			if (tnext >= cb->time_to_send)
 				break;
 		}
 
