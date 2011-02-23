From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 4/6] [PATCH] Revert "sch_netem: Remove classful functionality"
Date: Wed, 23 Feb 2011 15:04:20 -0800
Message-ID: <20110223230534.361268007@vyatta.com>
References: <20110223230416.532009518@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47476 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278Ab1BWXHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:07:50 -0500
Content-Disposition: inline; filename=netem-classful.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many users have wanted the old functionality that was lost
to be able to use pfifo as inner qdisc for netem. The reason that
netem could not be classful with the older API was because of the
limitations of the old dequeue/requeue interface; now that qdisc API has
a peek function, there is no longer a problem with using any
inner qdisc's.

This reverts commit 02201464119334690fe209849843881b8e9cfa9f.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/sched/sch_netem.c |   87 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 79 insertions(+), 8 deletions(-)

--- a/net/sched/sch_netem.c	2011-02-23 14:50:10.329760558 -0800
+++ b/net/sched/sch_netem.c	2011-02-23 14:50:19.933925120 -0800
@@ -238,14 +238,15 @@ static int netem_enqueue(struct sk_buff
 		ret = NET_XMIT_SUCCESS;
 	}
 
-	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->q.qlen++;
-	} else if (net_xmit_drop_count(ret)) {
-		sch->qstats.drops++;
+	if (ret != NET_XMIT_SUCCESS) {
+		if (net_xmit_drop_count(ret)) {
+			sch->qstats.drops++;
+			return ret;
+		}
 	}
 
-	pr_debug("netem: enqueue ret %d\n", ret);
-	return ret;
+	sch->q.qlen++;
+	return NET_XMIT_SUCCESS;
 }
 
 static unsigned int netem_drop(struct Qdisc *sch)
@@ -287,9 +288,10 @@ static struct sk_buff *netem_dequeue(str
 			if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
 				skb->tstamp.tv64 = 0;
 #endif
-			pr_debug("netem_dequeue: return skb=%p\n", skb);
-			qdisc_bstats_update(sch, skb);
+
 			sch->q.qlen--;
+			qdisc_unthrottled(sch);
+			qdisc_bstats_update(sch, skb);
 			return skb;
 		}
 
@@ -610,8 +612,77 @@ nla_put_failure:
 	return -1;
 }
 
+static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+
+	if (cl != 1) 	/* only one class */
+		return -ENOENT;
+
+	tcm->tcm_handle |= TC_H_MIN(1);
+	tcm->tcm_info = q->qdisc->handle;
+
+	return 0;
+}
+
+static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		     struct Qdisc **old)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = q->qdisc;
+	q->qdisc = new;
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+
+	return 0;
+}
+
+static struct Qdisc *netem_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	return q->qdisc;
+}
+
+static unsigned long netem_get(struct Qdisc *sch, u32 classid)
+{
+	return 1;
+}
+
+static void netem_put(struct Qdisc *sch, unsigned long arg)
+{
+}
+
+static void netem_walk(struct Qdisc *sch, struct qdisc_walker *walker)
+{
+	if (!walker->stop) {
+		if (walker->count >= walker->skip)
+			if (walker->fn(sch, 1, walker) < 0) {
+				walker->stop = 1;
+				return;
+			}
+		walker->count++;
+	}
+}
+
+static const struct Qdisc_class_ops netem_class_ops = {
+	.graft		=	netem_graft,
+	.leaf		=	netem_leaf,
+	.get		=	netem_get,
+	.put		=	netem_put,
+	.walk		=	netem_walk,
+	.dump		=	netem_dump_class,
+};
+
 static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.id		=	"netem",
+	.cl_ops		=	&netem_class_ops,
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,


