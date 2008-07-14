From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/14]: pkt_sched: Rewrite tc_ctl_tclass() to be multiqueue
 aware.
Date: Mon, 14 Jul 2008 16:00:38 -0700 (PDT)
Message-ID: <20080714.160038.25781008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758552AbYGNXAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 19:00:44 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 173EBC8C189
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 16:00:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that delete and change class operations have seperate validate and
commit operations, this is mostly a trivial transformation.

At this point every aspect of the generic networking is pretty much
fully multiqueue aware.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |  292 +++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 211 insertions(+), 81 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a4020a6..7e4faaa 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1495,132 +1495,262 @@ done:
  *	Traffic classes manipulation.		*
  ************************************************/
 
+struct tc_ctl_op_info {
+	struct Qdisc			*q;
+	u32				qid;
+	u32				clid;
+	unsigned long			cl;
+	unsigned long			new_cl;
+	const struct Qdisc_class_ops	*cops;
+	unsigned int			flags;
+#define TC_CTL_OP_CHANGE_VALIDATED	0x00000001
+};
 
-
-static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+/* parent == TC_H_UNSPEC - unspecified parent.
+ * parent == TC_H_ROOT   - class is root, which has no parent.
+ * parent == X:0	 - parent is root class.
+ * parent == X:Y	 - parent is a node in hierarchy.
+ * parent == 0:Y	 - parent is X:Y, where X:0 is qdisc.
+ *
+ * handle == 0:0	 - generate handle from kernel pool.
+ * handle == 0:Y	 - class is X:Y, where X:0 is qdisc.
+ * handle == X:Y	 - clear.
+ * handle == X:0	 - root class.
+ */
+static int prep_qid_one(struct tc_ctl_op_info *qp, struct netdev_queue *txq,
+			u32 qid, u32 pid, u32 clid)
 {
-	struct net *net = sock_net(skb->sk);
-	struct netdev_queue *dev_queue;
-	struct tcmsg *tcm = NLMSG_DATA(n);
-	struct nlattr *tca[TCA_MAX + 1];
-	struct net_device *dev;
-	struct Qdisc *q = NULL;
-	const struct Qdisc_class_ops *cops;
-	unsigned long cl = 0;
-	unsigned long new_cl;
-	u32 pid = tcm->tcm_parent;
-	u32 clid = tcm->tcm_handle;
-	u32 qid = TC_H_MAJ(clid);
-	int err;
-
-	if (net != &init_net)
-		return -EINVAL;
-
-	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
-		return -ENODEV;
-
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
-	if (err < 0)
-		return err;
-
-	/*
-	   parent == TC_H_UNSPEC - unspecified parent.
-	   parent == TC_H_ROOT   - class is root, which has no parent.
-	   parent == X:0	 - parent is root class.
-	   parent == X:Y	 - parent is a node in hierarchy.
-	   parent == 0:Y	 - parent is X:Y, where X:0 is qdisc.
-
-	   handle == 0:0	 - generate handle from kernel pool.
-	   handle == 0:Y	 - class is X:Y, where X:0 is qdisc.
-	   handle == X:Y	 - clear.
-	   handle == X:0	 - root class.
-	 */
-
-	/* Step 1. Determine qdisc handle X:0 */
-
-	dev_queue = netdev_get_tx_queue(dev, 0);
 	if (pid != TC_H_ROOT) {
 		u32 qid1 = TC_H_MAJ(pid);
 
 		if (qid && qid1) {
-			/* If both majors are known, they must be identical. */
+			/* If both majors are known, they must be
+			 * identical.
+			 */
 			if (qid != qid1)
 				return -EINVAL;
 		} else if (qid1) {
 			qid = qid1;
 		} else if (qid == 0)
-			qid = dev_queue->qdisc_sleeping->handle;
-
-		/* Now qid is genuine qdisc handle consistent
-		   both with parent and child.
+			qid = txq->qdisc_sleeping->handle;
 
-		   TC_H_MAJ(pid) still may be unspecified, complete it now.
+		/* Now qid is genuine qdisc handle consistent both
+		 * with parent and child.
+		 *
+		 * TC_H_MAJ(pid) still may be unspecified, complete it
+		 * now.
 		 */
 		if (pid)
 			pid = TC_H_MAKE(qid, pid);
 	} else {
 		if (qid == 0)
-			qid = dev_queue->qdisc_sleeping->handle;
+			qid = txq->qdisc_sleeping->handle;
 	}
 
-	/* OK. Locate qdisc */
-	if ((q = qdisc_lookup(dev_queue, qid)) == NULL)
+	qp->qid = qid;
+	qp->q = qdisc_lookup(txq, qid);
+	if (!qp->q)
 		return -ENOENT;
 
-	/* An check that it supports classes */
-	cops = q->ops->cl_ops;
-	if (cops == NULL)
+	qp->cops = qp->q->ops->cl_ops;
+	if (!qp->cops)
 		return -EINVAL;
 
-	/* Now try to get class */
 	if (clid == 0) {
 		if (pid == TC_H_ROOT)
 			clid = qid;
 	} else
 		clid = TC_H_MAKE(qid, clid);
+	qp->clid = clid;
 
-	if (clid)
-		cl = cops->get(q, clid);
+	if (qp->clid)
+		qp->cl = qp->cops->get(qp->q, qp->clid);
 
-	if (cl == 0) {
-		err = -ENOENT;
-		if (n->nlmsg_type != RTM_NEWTCLASS || !(n->nlmsg_flags&NLM_F_CREATE))
-			goto out;
+	return 0;
+}
+
+static void put_classes(struct tc_ctl_op_info *queue_arr, unsigned int num_q)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_ctl_op_info *qp = queue_arr + i;
+
+		if (qp->cl)
+			qp->cops->put(qp->q, qp->cl);
+	}
+}
+
+static int prep_qids(struct tc_ctl_op_info *queue_arr, unsigned int num_q,
+		     struct net_device *dev, struct tcmsg *tcm)
+{
+	u32 pid = tcm->tcm_parent;
+	u32 clid = tcm->tcm_handle;
+	u32 qid = TC_H_MAJ(clid);
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		struct tc_ctl_op_info *qp = queue_arr + i;
+		int err = prep_qid_one(qp, txq, qid, pid, clid);
+
+		if (err) {
+			put_classes(queue_arr, num_q);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+static void cancel_tc_ops(struct tc_ctl_op_info *queue_arr, unsigned int num_q,
+			  struct tcmsg *tcm, struct nlattr **tca)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_ctl_op_info *qp = queue_arr + i;
+
+		if (qp->flags & TC_CTL_OP_CHANGE_VALIDATED)
+			qp->cops->cancel_change(qp->q, qp->clid,
+						tcm->tcm_parent,
+						tca, qp->new_cl);
+	}
+}
+
+static int validate_tc_one(struct tc_ctl_op_info *qp, struct sk_buff *skb,
+			   struct nlmsghdr *n, struct tcmsg *tcm,
+			   struct nlattr **tca)
+{
+	int err;
+
+	if (!qp->cl) {
+		if (n->nlmsg_type != RTM_NEWTCLASS ||
+		    !(n->nlmsg_flags&NLM_F_CREATE))
+			return -ENOENT;
 	} else {
 		switch (n->nlmsg_type) {
 		case RTM_NEWTCLASS:
-			err = -EEXIST;
 			if (n->nlmsg_flags&NLM_F_EXCL)
-				goto out;
+				return -EEXIST;
 			break;
+
 		case RTM_DELTCLASS:
-			err = cops->validate_delete(q, cl);
-			if (!err) {
-				cops->commit_delete(q, cl);
-				tclass_notify(skb, n, q, cl, RTM_DELTCLASS);
-			}
-			goto out;
+			return qp->cops->validate_delete(qp->q, qp->cl);
+
 		case RTM_GETTCLASS:
-			err = tclass_notify(skb, n, q, cl, RTM_NEWTCLASS);
-			goto out;
+			return tclass_notify(skb, n, qp->q, qp->cl,
+					     RTM_NEWTCLASS);
+
 		default:
-			err = -EINVAL;
-			goto out;
+			return -EINVAL;
 		}
 	}
 
-	new_cl = cl;
+	qp->new_cl = qp->cl;
+	err = qp->cops->validate_change(qp->q, qp->clid, tcm->tcm_parent,
+					tca, &qp->new_cl);
+
+	if (!err)
+		qp->flags |= TC_CTL_OP_CHANGE_VALIDATED;
+
+	return err;
+}
+
+static int validate_tc_ops(struct tc_ctl_op_info *queue_arr, unsigned int num_q,
+			   struct sk_buff *skb, struct nlmsghdr *n,
+			   struct tcmsg *tcm, struct nlattr **tca)
+{
+	unsigned int i;
 
-	err = cops->validate_change(q, clid, pid, tca, &new_cl);
-	if (!err) {
-		cops->commit_change(q, clid, pid, tca, new_cl);
-		tclass_notify(skb, n, q, new_cl, RTM_NEWTCLASS);
+	for (i = 0; i < num_q; i++) {
+		struct tc_ctl_op_info *qp = queue_arr + i;
+		int err = validate_tc_one(qp, skb, n, tcm, tca);
+
+		if (err) {
+			cancel_tc_ops(queue_arr, num_q, tcm, tca);
+			return err;
+		}
 	}
+	return 0;
+}
 
-out:
-	if (cl)
-		cops->put(q, cl);
+static void commit_tc_one(struct tc_ctl_op_info *qp, struct sk_buff *skb,
+			  struct nlmsghdr *n, struct tcmsg *tcm,
+			  struct nlattr **tca)
+{
+	if (qp->cl) {
+		switch (n->nlmsg_type) {
+		case RTM_NEWTCLASS:
+			break;
+
+		case RTM_DELTCLASS:
+			qp->cops->commit_delete(qp->q, qp->cl);
+			tclass_notify(skb, n, qp->q, qp->cl, RTM_DELTCLASS);
+			return;
+
+		default:
+			return;
+		}
+	}
+	qp->cops->commit_change(qp->q, qp->clid, tcm->tcm_parent,
+				tca, qp->new_cl);
+	tclass_notify(skb, n, qp->q, qp->new_cl, RTM_NEWTCLASS);
+}
 
+static void commit_tc_ops(struct tc_ctl_op_info *queue_arr, unsigned int num_q,
+			  struct sk_buff *skb, struct nlmsghdr *n,
+			  struct tcmsg *tcm, struct nlattr **tca)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++)
+		commit_tc_one(queue_arr + i, skb, n, tcm, tca);
+}
+
+static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct tcmsg *tcm = NLMSG_DATA(n);
+	struct tc_ctl_op_info *queue_arr;
+	struct nlattr *tca[TCA_MAX + 1];
+	struct net_device *dev;
+	unsigned int num_q;
+	int err;
+
+	if (net != &init_net)
+		return -EINVAL;
+
+	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+		return -ENODEV;
+
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	num_q = dev->num_tx_queues;
+	queue_arr = kzalloc(sizeof(struct tc_ctl_op_info) * num_q,
+			    GFP_KERNEL);
+	if (!queue_arr)
+		return -ENOMEM;
+
+	err = prep_qids(queue_arr, num_q, dev, tcm);
+	if (err)
+		goto err_free_queue;
+
+	err = validate_tc_ops(queue_arr, num_q, skb, n, tcm, tca);
+	if (err)
+		goto err_put_classes;
+
+	commit_tc_ops(queue_arr, num_q, skb, n, tcm, tca);
+
+	err = 0;
+
+err_put_classes:
+	put_classes(queue_arr, num_q);
+
+err_free_queue:
+	kfree(queue_arr);
 	return err;
 }
 
-- 
1.5.6.2.255.gbed62

