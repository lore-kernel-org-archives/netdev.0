From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET_SCHED] sch_cbq: deactivating when grafting, purging etc.
Date: Tue, 28 Nov 2006 07:37:43 +0100
Message-ID: <20061128063743.GA1797@ff.dom.local>
References: <20061127065614.GB1625@ff.dom.local> <456AB61B.3040205@trash.net> <20061127104140.GA2866@ff.dom.local> <456AC07E.6000606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:8128 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S935659AbWK1GbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 01:31:08 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <456AC07E.6000606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED] sch_cbq:

[PATCH 2.6.19-rc6 with "Fix endless loops" set of patches]

- P. McHardy's "Fix endless loops" patch supplement
  (cbq_graft, cbq_qlen_notify, cbq_delete, cbq_class_ops)

- deactivating of active classes when q.qlen drops to zero
  (cbq_drop)

- a redundant instruction removed from cbq_deactivate_class

PS: probably htb_deactivate in htb_delete and
cbq_deactivate_class in cbq_delete are also
redundant now.

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.19-rc6-endless-/net/sched/sch_cbq.c linux-2.6.19-rc6-endless/net/sched/sch_cbq.c
--- linux-2.6.19-rc6-endless-/net/sched/sch_cbq.c	2006-11-27 18:40:16.000000000 +0100
+++ linux-2.6.19-rc6-endless/net/sched/sch_cbq.c	2006-11-27 20:31:46.000000000 +0100
@@ -371,8 +371,6 @@ static void cbq_deactivate_class(struct 
 					return;
 				}
 			}
-
-			cl = cl_prev->next_alive;
 			return;
 		}
 	} while ((cl_prev = cl) != q->active[prio]);
@@ -1258,6 +1256,8 @@ static unsigned int cbq_drop(struct Qdis
 		do {
 			if (cl->q->ops->drop && (len = cl->q->ops->drop(cl->q))) {
 				sch->q.qlen--;
+				if (!cl->q->q.qlen)
+					cbq_deactivate_class(cl);
 				return len;
 			}
 		} while ((cl = cl->next_alive) != cl_head);
@@ -1685,8 +1685,7 @@ static int cbq_graft(struct Qdisc *sch, 
 #endif
 		}
 		sch_tree_lock(sch);
-		*old = cl->q;
-		cl->q = new;
+		*old = xchg(&cl->q, new);
 		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 		qdisc_reset(*old);
 		sch_tree_unlock(sch);
@@ -1704,6 +1703,14 @@ cbq_leaf(struct Qdisc *sch, unsigned lon
 	return cl ? cl->q : NULL;
 }
 
+static void cbq_qlen_notify(struct Qdisc *sch, unsigned long arg)
+{
+	struct cbq_class *cl = (struct cbq_class *)arg;
+
+	if (cl->q->q.qlen == 0)
+		cbq_deactivate_class(cl);
+}
+
 static unsigned long cbq_get(struct Qdisc *sch, u32 classid)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
@@ -1988,12 +1995,17 @@ static int cbq_delete(struct Qdisc *sch,
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class*)arg;
+	unsigned int qlen;
 
 	if (cl->filters || cl->children || cl == &q->link)
 		return -EBUSY;
 
 	sch_tree_lock(sch);
 
+	qlen = cl->q->q.qlen;
+	qdisc_reset(cl->q);
+	qdisc_tree_decrease_qlen(cl->q, qlen);
+
 	if (cl->next_alive)
 		cbq_deactivate_class(cl);
 
@@ -2084,6 +2096,7 @@ static void cbq_walk(struct Qdisc *sch, 
 static struct Qdisc_class_ops cbq_class_ops = {
 	.graft		=	cbq_graft,
 	.leaf		=	cbq_leaf,
+	.qlen_notify	=	cbq_qlen_notify,
 	.get		=	cbq_get,
 	.put		=	cbq_put,
 	.change		=	cbq_change_class,
