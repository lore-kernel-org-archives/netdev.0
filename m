From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/06]: Fix endless loops (part 2): "simple" qdiscs
Date: Mon, 20 Nov 2006 14:08:44 +0100 (MET)
Message-ID: <20061120130843.22347.67166.sendpatchset@localhost.localdomain>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:10494 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965843AbWKTNIp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 08:08:45 -0500
To: davem@davemloft.net
In-Reply-To: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Fix endless loops (part 2): "simple" qdiscs

Convert the "simple" qdiscs to use qdisc_tree_decrease_qlen() where
necessary:

- all graft operations
- destruction of old child qdiscs in prio, red and tbf change operation
- purging of queue in sfq change operation

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0ce9475d7baf678698eb70369f734b8feeb03e13
tree de989fa5b32c7f53e7b7b6aac686dc39bb1839bb
parent 42706d154c660ac3915cc0debcfa09339af29de3
author Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:45:41 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:45:41 +0100

 net/sched/sch_cbq.c    |    2 +-
 net/sched/sch_dsmark.c |    2 +-
 net/sched/sch_netem.c  |    2 +-
 net/sched/sch_prio.c   |   11 ++++++++---
 net/sched/sch_red.c    |    6 ++++--
 net/sched/sch_sfq.c    |    3 +++
 net/sched/sch_tbf.c    |    6 ++++--
 7 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 908b10d..ba82dfa 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1687,7 +1687,7 @@ #endif
 		sch_tree_lock(sch);
 		*old = cl->q;
 		cl->q = new;
-		sch->q.qlen -= (*old)->q.qlen;
+		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 		qdisc_reset(*old);
 		sch_tree_unlock(sch);
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 7809073..e341fd9 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -96,8 +96,8 @@ static int dsmark_graft(struct Qdisc *sc
 
 	sch_tree_lock(sch);
 	*old = xchg(&p->q, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
-	sch->q.qlen = 0;
 	sch_tree_unlock(sch);
 
         return 0;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 90aeeb7..672c354 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -662,8 +662,8 @@ static int netem_graft(struct Qdisc *sch
 
 	sch_tree_lock(sch);
 	*old = xchg(&q->qdisc, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
-	sch->q.qlen = 0;
 	sch_tree_unlock(sch);
 
 	return 0;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 3fc0c0f..2567b4c 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -222,8 +222,10 @@ static int prio_tune(struct Qdisc *sch, 
 
 	for (i=q->bands; i<TCQ_PRIO_BANDS; i++) {
 		struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);
-		if (child != &noop_qdisc)
+		if (child != &noop_qdisc) {
+			qdisc_tree_decrease_qlen(child, child->q.qlen);
 			qdisc_destroy(child);
+		}
 	}
 	sch_tree_unlock(sch);
 
@@ -236,8 +238,11 @@ static int prio_tune(struct Qdisc *sch, 
 				sch_tree_lock(sch);
 				child = xchg(&q->queues[i], child);
 
-				if (child != &noop_qdisc)
+				if (child != &noop_qdisc) {
+					qdisc_tree_decrease_qlen(child,
+								 child->q.qlen);
 					qdisc_destroy(child);
+				}
 				sch_tree_unlock(sch);
 			}
 		}
@@ -295,7 +300,7 @@ static int prio_graft(struct Qdisc *sch,
 	sch_tree_lock(sch);
 	*old = q->queues[band];
 	q->queues[band] = new;
-	sch->q.qlen -= (*old)->q.qlen;
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
 	sch_tree_unlock(sch);
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index ee66c5c..acddad0 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -229,8 +229,10 @@ static int red_change(struct Qdisc *sch,
 	sch_tree_lock(sch);
 	q->flags = ctl->flags;
 	q->limit = ctl->limit;
-	if (child)
+	if (child) {
+		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
 		qdisc_destroy(xchg(&q->qdisc, child));
+	}
 
 	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
 				 ctl->Plog, ctl->Scell_log,
@@ -308,8 +310,8 @@ static int red_graft(struct Qdisc *sch, 
 
 	sch_tree_lock(sch);
 	*old = xchg(&q->qdisc, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
-	sch->q.qlen = 0;
 	sch_tree_unlock(sch);
 	return 0;
 }
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d0d6e59..459cda2 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -393,6 +393,7 @@ static int sfq_change(struct Qdisc *sch,
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
+	unsigned int qlen;
 
 	if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
 		return -EINVAL;
@@ -403,8 +404,10 @@ static int sfq_change(struct Qdisc *sch,
 	if (ctl->limit)
 		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
 
+	qlen = sch->q.qlen;
 	while (sch->q.qlen >= q->limit-1)
 		sfq_drop(sch);
+	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
 	del_timer(&q->perturb_timer);
 	if (q->perturb_period) {
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 2562a60..23b7624 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -348,8 +348,10 @@ static int tbf_change(struct Qdisc* sch,
 	}
 
 	sch_tree_lock(sch);
-	if (child)
+	if (child) {
+		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
 		qdisc_destroy(xchg(&q->qdisc, child));
+	}
 	q->limit = qopt->limit;
 	q->mtu = qopt->mtu;
 	q->max_size = max_size;
@@ -451,8 +453,8 @@ static int tbf_graft(struct Qdisc *sch, 
 
 	sch_tree_lock(sch);
 	*old = xchg(&q->qdisc, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
-	sch->q.qlen = 0;
 	sch_tree_unlock(sch);
 
 	return 0;
