From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix tx queue selection in tc_modify_qdisc
Date: Mon, 14 Sep 2009 12:22:26 +0000
Message-ID: <20090914122226.GA14087@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:57709 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbZINMW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 08:22:29 -0400
Received: by fxm17 with SMTP id 17so788104fxm.37
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 05:22:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the recent mq change there is the new select_queue qdisc class
method used in tc_modify_qdisc, but it works OK only for direct child
qdiscs of mq qdisc. Grandchildren always get the first tx queue, which
would give wrong qdisc_root etc. results (e.g. for sch_htb as child of
sch_prio). This patch fixes it by using parent's dev_queue for such
grandchildren qdiscs. The select_queue method is replaced BTW with the
static qdisc_select_tx_queue function (it's used only in one place).

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/sch_generic.h |    1 -
 net/sched/sch_api.c       |   29 +++++++++++++++++++++--------
 net/sched/sch_mq.c        |   10 ----------
 3 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 88eb9de..865120c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -81,7 +81,6 @@ struct Qdisc
 struct Qdisc_class_ops
 {
 	/* Child qdisc manipulation */
-	unsigned int		(*select_queue)(struct Qdisc *, struct tcmsg *);
 	int			(*graft)(struct Qdisc *, unsigned long cl,
 					struct Qdisc *, struct Qdisc **);
 	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 3af1061..223a6bc 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -990,6 +990,24 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
+static struct netdev_queue *qdisc_select_tx_queue(struct net_device *dev,
+						  struct Qdisc *p, u32 clid)
+{
+	unsigned long ntx;
+
+	if (!p)
+		return netdev_get_tx_queue(dev, 0);
+
+	if (!(p->flags & TCQ_F_MQROOT))
+		return p->dev_queue;
+
+	ntx = TC_H_MIN(clid) - 1;
+	if (ntx >= dev->num_tx_queues)
+		ntx = 0;
+
+	return netdev_get_tx_queue(dev, ntx);
+}
+
 /*
    Create/change qdisc.
  */
@@ -1110,16 +1128,11 @@ create_n_graft:
 		q = qdisc_create(dev, &dev->rx_queue, p,
 				 tcm->tcm_parent, tcm->tcm_parent,
 				 tca, &err);
-	else {
-		unsigned int ntx = 0;
-
-		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
-			ntx = p->ops->cl_ops->select_queue(p, tcm);
-
-		q = qdisc_create(dev, netdev_get_tx_queue(dev, ntx), p,
+	else
+		q = qdisc_create(dev, qdisc_select_tx_queue(dev, p, clid), p,
 				 tcm->tcm_parent, tcm->tcm_handle,
 				 tca, &err);
-	}
+
 	if (q == NULL) {
 		if (err == -EAGAIN)
 			goto replay;
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index dd5ee02..4ad949b 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -125,15 +125,6 @@ static struct netdev_queue *mq_queue_get(struct Qdisc *sch, unsigned long cl)
 	return netdev_get_tx_queue(dev, ntx);
 }
 
-static unsigned int mq_select_queue(struct Qdisc *sch, struct tcmsg *tcm)
-{
-	unsigned int ntx = TC_H_MIN(tcm->tcm_parent);
-
-	if (!mq_queue_get(sch, ntx))
-		return 0;
-	return ntx - 1;
-}
-
 static int mq_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
 		    struct Qdisc **old)
 {
@@ -213,7 +204,6 @@ static void mq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 }
 
 static const struct Qdisc_class_ops mq_class_ops = {
-	.select_queue	= mq_select_queue,
 	.graft		= mq_graft,
 	.leaf		= mq_leaf,
 	.get		= mq_get,
