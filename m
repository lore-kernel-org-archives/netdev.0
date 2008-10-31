From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Fri, 31 Oct 2008 13:20:10 +0000
Message-ID: <20081031132010.GA18895@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:49657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbYJaNUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 09:20:20 -0400
Received: by ug-out-1314.google.com with SMTP id 39so1224393ugf.37
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 06:20:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy noticed that: "a lot of the functionality of netem
requires the inner tfifo anyways and rate-limiting is usually done
on top of netem. So I would suggest so either hard-wire the tfifo
qdisc or at least make the assumption that inner qdiscs are
work-conserving.", and later: "- a lot of other qdiscs still don't
work as inner qdiscs of netem [...]".

So, according to his suggestion, this patch removes classful options
of netem. The main reason of this change is to remove ops->requeue()
method, which is currently used only by netem.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3080bd6..2ad0959 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -622,95 +622,8 @@ nla_put_failure:
 	return -1;
 }
 
-static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
-			  struct sk_buff *skb, struct tcmsg *tcm)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-
-	if (cl != 1) 	/* only one class */
-		return -ENOENT;
-
-	tcm->tcm_handle |= TC_H_MIN(1);
-	tcm->tcm_info = q->qdisc->handle;
-
-	return 0;
-}
-
-static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
-		     struct Qdisc **old)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-
-	if (new == NULL)
-		new = &noop_qdisc;
-
-	sch_tree_lock(sch);
-	*old = xchg(&q->qdisc, new);
-	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
-	qdisc_reset(*old);
-	sch_tree_unlock(sch);
-
-	return 0;
-}
-
-static struct Qdisc *netem_leaf(struct Qdisc *sch, unsigned long arg)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-	return q->qdisc;
-}
-
-static unsigned long netem_get(struct Qdisc *sch, u32 classid)
-{
-	return 1;
-}
-
-static void netem_put(struct Qdisc *sch, unsigned long arg)
-{
-}
-
-static int netem_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
-{
-	return -ENOSYS;
-}
-
-static int netem_delete(struct Qdisc *sch, unsigned long arg)
-{
-	return -ENOSYS;
-}
-
-static void netem_walk(struct Qdisc *sch, struct qdisc_walker *walker)
-{
-	if (!walker->stop) {
-		if (walker->count >= walker->skip)
-			if (walker->fn(sch, 1, walker) < 0) {
-				walker->stop = 1;
-				return;
-			}
-		walker->count++;
-	}
-}
-
-static struct tcf_proto **netem_find_tcf(struct Qdisc *sch, unsigned long cl)
-{
-	return NULL;
-}
-
-static const struct Qdisc_class_ops netem_class_ops = {
-	.graft		=	netem_graft,
-	.leaf		=	netem_leaf,
-	.get		=	netem_get,
-	.put		=	netem_put,
-	.change		=	netem_change_class,
-	.delete		=	netem_delete,
-	.walk		=	netem_walk,
-	.tcf_chain	=	netem_find_tcf,
-	.dump		=	netem_dump_class,
-};
-
 static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.id		=	"netem",
-	.cl_ops		=	&netem_class_ops,
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
-- 
1.5.6.5

