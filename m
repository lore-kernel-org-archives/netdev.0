From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 05/13] net_sched: introduce qdisc_drop() helper function
Date: Tue,  4 Nov 2014 09:56:28 -0800
Message-ID: <1415123796-8093-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35849 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbaKDR4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:51 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so14924600pac.2
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:51 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  8 ++++++++
 net/sched/sch_atm.c       |  2 +-
 net/sched/sch_cbq.c       |  7 +++----
 net/sched/sch_drr.c       | 14 ++++++--------
 net/sched/sch_dsmark.c    |  5 +----
 net/sched/sch_hfsc.c      |  3 +--
 net/sched/sch_htb.c       |  3 +--
 net/sched/sch_multiq.c    | 10 ++++------
 net/sched/sch_netem.c     |  4 ++--
 net/sched/sch_prio.c      |  2 +-
 net/sched/sch_qfq.c       |  6 +-----
 net/sched/sch_red.c       |  2 +-
 net/sched/sch_tbf.c       |  2 +-
 13 files changed, 31 insertions(+), 37 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 21df9fb..119e129 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -740,6 +740,14 @@ static inline int qdisc_drop_skb(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_DROP;
 }
 
+static inline unsigned int qdisc_drop(struct Qdisc *sch)
+{
+	if (sch->ops->drop)
+		return sch->ops->drop(sch);
+	else
+		return 0;
+}
+
 static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 {
 	qdisc_qstats_drop(sch);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 1d3fb22..a26e503 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -527,7 +527,7 @@ static unsigned int atm_tc_drop(struct Qdisc *sch)
 
 	pr_debug("atm_tc_drop(sch %p,[qdisc %p])\n", sch, p);
 	list_for_each_entry(flow, &p->flows, list) {
-		if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q)))
+		if ((len = qdisc_drop(flow->q)))
 			return len;
 	}
 	return 0;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index beeb75f..ad2905a 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -542,9 +542,8 @@ static void cbq_ovl_lowprio(struct cbq_class *cl)
 
 static void cbq_ovl_drop(struct cbq_class *cl)
 {
-	if (cl->q->ops->drop)
-		if (cl->q->ops->drop(cl->q))
-			cl->qdisc->q.qlen--;
+	if (qdisc_drop(cl->q))
+		cl->qdisc->q.qlen--;
 	cl->xstats.overactions++;
 	cbq_ovl_classic(cl);
 }
@@ -1180,7 +1179,7 @@ static unsigned int cbq_drop(struct Qdisc *sch)
 
 		cl = cl_head;
 		do {
-			if (cl->q->ops->drop && (len = cl->q->ops->drop(cl->q))) {
+			if ((len = qdisc_drop(cl->q))) {
 				sch->q.qlen--;
 				if (!cl->q->q.qlen)
 					cbq_deactivate_class(cl);
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index a367fea..4007e40 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -424,14 +424,12 @@ static unsigned int drr_drop(struct Qdisc *sch)
 	unsigned int len;
 
 	list_for_each_entry(cl, &q->active, alist) {
-		if (cl->qdisc->ops->drop) {
-			len = cl->qdisc->ops->drop(cl->qdisc);
-			if (len > 0) {
-				sch->q.qlen--;
-				if (cl->qdisc->q.qlen == 0)
-					list_del(&cl->alist);
-				return len;
-			}
+		len = qdisc_drop(cl->qdisc);
+		if (len > 0) {
+			sch->q.qlen--;
+			if (cl->qdisc->q.qlen == 0)
+				list_del(&cl->alist);
+			return len;
 		}
 	}
 	return 0;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index a450c53..0a20722 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -329,10 +329,7 @@ static unsigned int dsmark_drop(struct Qdisc *sch)
 
 	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
-	if (p->q->ops->drop == NULL)
-		return 0;
-
-	len = p->q->ops->drop(p->q);
+	len = qdisc_drop(p->q);
 	if (len)
 		sch->q.qlen--;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 7086ead..3cc44a8 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1686,8 +1686,7 @@ hfsc_drop(struct Qdisc *sch)
 	unsigned int len;
 
 	list_for_each_entry(cl, &q->droplist, dlist) {
-		if (cl->qdisc->ops->drop != NULL &&
-		    (len = cl->qdisc->ops->drop(cl->qdisc)) > 0) {
+		if ((len = qdisc_drop(cl->qdisc)) > 0) {
 			if (cl->qdisc->q.qlen == 0) {
 				update_vf(cl, 0, 0);
 				set_passive(cl);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 89d15e8..b88a159 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -953,8 +953,7 @@ static unsigned int htb_drop(struct Qdisc *sch)
 			struct htb_class *cl = list_entry(p, struct htb_class,
 							  un.leaf.drop_list);
 			unsigned int len;
-			if (cl->un.leaf.q->ops->drop &&
-			    (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
+			if ((len = qdisc_drop(cl->un.leaf.q))) {
 				sch->q.qlen--;
 				if (!cl->un.leaf.q->q.qlen)
 					htb_deactivate(q, cl);
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 1458aa3..af52ec8 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -160,12 +160,10 @@ static unsigned int multiq_drop(struct Qdisc *sch)
 
 	for (band = q->bands - 1; band >= 0; band--) {
 		qdisc = q->queues[band];
-		if (qdisc->ops->drop) {
-			len = qdisc->ops->drop(qdisc);
-			if (len != 0) {
-				sch->q.qlen--;
-				return len;
-			}
+		len = qdisc_drop(qdisc);
+		if (len != 0) {
+			sch->q.qlen--;
+			return len;
 		}
 	}
 	return 0;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 1eb917e..0161193 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -540,8 +540,8 @@ static unsigned int netem_drop(struct Qdisc *sch)
 			kfree_skb(skb);
 		}
 	}
-	if (!len && q->qdisc && q->qdisc->ops->drop)
-	    len = q->qdisc->ops->drop(q->qdisc);
+	if (!len && q->qdisc)
+	    len = qdisc_drop(q->qdisc);
 	if (len)
 		qdisc_qstats_drop(sch);
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 0e06d14..200b3b0 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -134,7 +134,7 @@ static unsigned int prio_drop(struct Qdisc *sch)
 
 	for (prio = q->bands-1; prio >= 0; prio--) {
 		qdisc = q->queues[prio];
-		if (qdisc->ops->drop && (len = qdisc->ops->drop(qdisc)) != 0) {
+		if ((len = qdisc_drop(qdisc)) != 0) {
 			sch->q.qlen--;
 			return len;
 		}
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 9c9a5f3..a847e3a 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1432,11 +1432,7 @@ static unsigned int qfq_drop_from_slot(struct qfq_sched *q,
 
 	hlist_for_each_entry(agg, slot, next) {
 		list_for_each_entry(cl, &agg->active, alist) {
-
-			if (!cl->qdisc->ops->drop)
-				continue;
-
-			len = cl->qdisc->ops->drop(cl->qdisc);
+			len = qdisc_drop(cl->qdisc);
 			if (len > 0) {
 				if (cl->qdisc->q.qlen == 0)
 					qfq_deactivate_class(q, cl);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index c19587d..5ea7306 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -140,7 +140,7 @@ static unsigned int red_drop(struct Qdisc *sch)
 	struct Qdisc *child = q->qdisc;
 	unsigned int len;
 
-	if (child->ops->drop && (len = child->ops->drop(child)) > 0) {
+	if ((len = qdisc_drop(child)) > 0) {
 		q->stats.other++;
 		qdisc_qstats_drop(sch);
 		sch->q.qlen--;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1f63a71..786e7d6 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -214,7 +214,7 @@ static unsigned int tbf_drop(struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	unsigned int len = 0;
 
-	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+	if ((len = qdisc_drop(q->qdisc)) != 0) {
 		sch->q.qlen--;
 		qdisc_qstats_drop(sch);
 	}
-- 
1.8.3.1
