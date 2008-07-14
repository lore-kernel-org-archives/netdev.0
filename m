From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/14]: pkt_sched: Make main qdisc configuration operations
 multiqueue aware.
Date: Mon, 14 Jul 2008 15:59:35 -0700 (PDT)
Message-ID: <20080714.155935.184374140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49265
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758316AbYGNW7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:40 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8D7BEC8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add/create/delete/get/dump qdisc are all multiqueue aware for the
most part now.

The basic idea is that we build an array of configuration changes,
one per queue.  Then we validate each and every change, if any
errors are signalled we unwind.  Otherwise we commit the changes
at which point it cannot fail on us.

Later, this can be easily extended to accept a TX queue specification
using netlink attributes, to filter the queues which will actually be
operated upon.  Lack of such attributes will mean "all queues".

One part that isn't completely fleshed out is qdisc_change().  We
need to make that have a prep/commit/cancel sequence just like the
rest of this stuff.

After that, the next area to attack will be the traffic filter APIs.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |  792 +++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 584 insertions(+), 208 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fdc79b4..a59f99f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -521,46 +521,15 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 }
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
 
-/* Graft qdisc "new" to class "classid" of qdisc "parent" or
-   to device queue "dev_queue".
-
-   Old qdisc is not destroyed but returned in *old.
+/* Grab a reference to the qdisc operations described by 'kind'.
+ * A single module reference to the operations will be held
+ * upon success.
+ *
+ * The RTNL semaphore might be dropped if an attempt is made
+ * to lead the necessary packet scheduler module.  In such
+ * a case -EAGAIN will be returned and the top level should
+ * unwind and retry the operation from the beginning.
  */
-
-static int qdisc_graft(struct netdev_queue *dev_queue, struct Qdisc *parent,
-		       u32 classid, struct Qdisc *new, struct Qdisc **old)
-{
-	struct Qdisc *q = *old;
-	int err = 0;
-
-	if (parent == NULL) {
-		if (q && q->flags&TCQ_F_INGRESS) {
-			*old = graft_qdisc(dev_queue, q);
-		} else {
-			*old = graft_qdisc(dev_queue, new);
-		}
-	} else {
-		const struct Qdisc_class_ops *cops = parent->ops->cl_ops;
-
-		err = -EINVAL;
-
-		if (cops) {
-			unsigned long cl = cops->get(parent, classid);
-			if (cl) {
-				void *gp = cops->prepare_graft(parent, cl, new);
-
-				err = 0;
-				if (IS_ERR(gp))
-					err = PTR_ERR(gp);
-				else
-					cops->commit_graft(parent, cl, new, gp, old);
-				cops->put(parent, cl);
-			}
-		}
-	}
-	return err;
-}
-
 static struct Qdisc_ops *tc_grab_ops(struct nlattr *kind)
 {
 	struct Qdisc_ops *ops = qdisc_lookup_ops(kind);
@@ -659,6 +628,9 @@ err_out:
 	return NULL;
 }
 
+/* Change the parameters on qdisc 'sch', using the attributes described
+ * in 'tca'.
+ */
 static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 {
 	if (tca[TCA_OPTIONS]) {
@@ -685,6 +657,11 @@ struct check_loop_arg
 
 static int check_loop_fn(struct Qdisc *q, unsigned long cl, struct qdisc_walker *w);
 
+/* Walk the qdisc tree looking for loops starting at qdisc 'q' which
+ * has parent 'p'.  'depth' is the current depth of the loop search.
+ *
+ * A maximum queue depth of '7' is all that is allowed.
+ */
 static int check_loop(struct Qdisc *q, struct Qdisc *p, int depth)
 {
 	struct check_loop_arg	arg;
@@ -716,19 +693,213 @@ check_loop_fn(struct Qdisc *q, unsigned long cl, struct qdisc_walker *w)
 	return 0;
 }
 
-/*
- * Delete/get qdisc.
+/* We setup each Qdisc config operation by recording, per netdev-queue,
+ * whether that queue gets the operation and what parameters will be
+ * used for that instance of the operation.
+ */
+struct tc_qdisc_op_info {
+	struct Qdisc		*parent_q;
+	struct Qdisc		*op_q;
+	unsigned long		cl;
+	void			*graft_mem;
+	unsigned int		flags;
+#define TC_QDISC_OP_CREATE	0x00000001
+#define TC_QDISC_OP_GRAFT	0x00000002
+#define TC_QDISC_OP_CHANGE	0x00000004
+#define TC_QDISC_OP_ALLOCATED	0x00000008
+#define TC_QDISC_OP_GRAFT_PREP	0x00000010
+};
+
+/* Prepare a request for a get or delete operation.  */
+static int tc_get_prep_request(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+			       struct net_device *dev, struct tcmsg *tcm,
+			       struct nlattr **tca, u32 clid)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		struct netdev_queue *dev_queue;
+
+		if (clid && TC_H_MAJ(clid) == TC_H_MAJ(TC_H_INGRESS))
+			dev_queue = &dev->rx_queue;
+		else
+			dev_queue = netdev_get_tx_queue(dev, i);
+
+		if (!clid) {
+			qp->op_q = __qdisc_lookup(dev_queue, tcm->tcm_handle);
+			if (!qp->op_q)
+				return -ENOENT;
+		} else {
+			if (clid == TC_H_ROOT) {
+				qp->op_q = dev_queue->qdisc_sleeping;
+			} else {
+				if (TC_H_MAJ(clid) == TC_H_MAJ(TC_H_INGRESS)) {
+					qp->op_q = dev_queue->qdisc;
+				} else {
+					qp->parent_q = qdisc_lookup(dev, TC_H_MAJ(clid));
+					if (!qp->parent_q)
+						return -ENOENT;
+					qp->op_q = qdisc_leaf(qp->parent_q, clid);
+				}
+			}
+			if (!qp->op_q)
+				return -ENOENT;
+			if (tcm->tcm_handle && qp->op_q->handle != tcm->tcm_handle)
+				return -EINVAL;
+		}
+
+		if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], qp->op_q->ops->id))
+			return -EINVAL;
+	}
+	return 0;
+}
+
+/* Validate and prepare a single delete operation.  */
+static int tc_delete_prep_one(struct tc_qdisc_op_info *qp, u32 clid)
+{
+	const struct Qdisc_class_ops *cops;
+	void *gp;
+
+	if (!qp->op_q->handle)
+		return -ENOENT;
+
+	if (!qp->parent_q)
+		return 0;
+
+	cops = qp->parent_q->ops->cl_ops;
+	if (!cops)
+		return -EINVAL;
+
+	qp->cl = cops->get(qp->parent_q, clid);
+	if (!qp->cl)
+		return -EINVAL;
+
+	gp = cops->prepare_graft(qp->parent_q, qp->cl, NULL);
+	if (IS_ERR(gp)) {
+		cops->put(qp->parent_q, clid);
+		return PTR_ERR(gp);
+	}
+
+	qp->graft_mem = gp;
+	qp->flags |= TC_QDISC_OP_GRAFT_PREP;
+
+	return 0;
+}
+
+/* Commit one qdisc delete operation, it must not fail.  */
+static void tc_delete_commit(struct tc_qdisc_op_info *qp, struct netdev_queue *dev_queue,
+			     struct sk_buff *skb, struct nlmsghdr *n, u32 clid)
+{
+	struct Qdisc *parent, *old;
+
+	parent = qp->parent_q;
+	old = qp->op_q;
+	if (!parent) {
+		if (old->flags&TCQ_F_INGRESS) {
+			old = graft_qdisc(dev_queue, old);
+		} else {
+			old = graft_qdisc(dev_queue, NULL);
+		}
+	} else {
+		const struct Qdisc_class_ops *cops = parent->ops->cl_ops;
+
+		cops->commit_graft(parent, qp->cl, NULL, qp->graft_mem, &old);
+		cops->put(parent, qp->cl);
+	}
+
+	if (old) {
+		qdisc_notify(skb, n, clid, old, NULL);
+		spin_lock_bh(&dev_queue->lock);
+		qdisc_destroy(old);
+		spin_unlock_bh(&dev_queue->lock);
+	}
+}
+
+/* Cancel a previous qdisc graft operation for add/change/delete.  */
+static void tc_graft_cancel(struct tc_qdisc_op_info *queue_arr, unsigned int num_q)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		const struct Qdisc_class_ops *cops;
+
+		if (!(qp->flags & TC_QDISC_OP_GRAFT_PREP))
+			continue;
+
+		BUG_ON(!qp->parent_q);
+
+		cops = qp->parent_q->ops->cl_ops;
+		cops->cancel_graft(qp->parent_q, qp->cl, qp->op_q, qp->graft_mem);
+		cops->put(qp->parent_q, qp->cl);
+
+		qp->graft_mem = NULL;
+		qp->flags &= ~TC_QDISC_OP_GRAFT_PREP;
+	}
+}
+
+/* Delete all qdiscs described by 'queue_arr' and 'num_q'.  */
+static int tc_delete_all(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+			 struct net_device *dev, struct sk_buff *skb,
+			 struct nlmsghdr *n, u32 clid)
+{
+	unsigned int i;
+
+	if (!clid)
+		return -EINVAL;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		int err;
+
+		err = tc_delete_prep_one(qp, clid);
+		if (err) {
+			tc_graft_cancel(queue_arr, num_q);
+			return err;
+		}
+	}
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		struct netdev_queue *dev_queue;
+
+		if (clid && TC_H_MAJ(clid) == TC_H_MAJ(TC_H_INGRESS))
+			dev_queue = &dev->rx_queue;
+		else
+			dev_queue = netdev_get_tx_queue(dev, i);
+
+		tc_delete_commit(qp, dev_queue, skb, n, clid);
+	}
+	return 0;
+}
+
+/* Perform a get operation on all qdiscs described by 'queue_arr'
+ * and 'num_q'.
  */
+static int tc_get_all(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+		      struct sk_buff *skb, struct nlmsghdr *n, u32 clid)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+
+		qdisc_notify(skb, n, clid, NULL, qp->op_q);
+	}
+
+	return 0;
+}
 
 static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
+	struct tc_qdisc_op_info *queue_arr;
 	struct tcmsg *tcm = NLMSG_DATA(n);
 	struct nlattr *tca[TCA_MAX + 1];
-	struct net_device *dev;
 	u32 clid = tcm->tcm_parent;
-	struct Qdisc *q = NULL;
-	struct Qdisc *p = NULL;
+	struct net_device *dev;
+	unsigned int num_q;
 	int err;
 
 	if (net != &init_net)
@@ -741,52 +912,32 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	if (err < 0)
 		return err;
 
-	if (clid) {
-		if (clid != TC_H_ROOT) {
-			if (TC_H_MAJ(clid) != TC_H_MAJ(TC_H_INGRESS)) {
-				if ((p = qdisc_lookup(dev, TC_H_MAJ(clid))) == NULL)
-					return -ENOENT;
-				q = qdisc_leaf(p, clid);
-			} else { /* ingress */
-				q = dev->rx_queue.qdisc;
-			}
-		} else {
-			struct netdev_queue *dev_queue;
-			dev_queue = netdev_get_tx_queue(dev, 0);
-			q = dev_queue->qdisc_sleeping;
-		}
-		if (!q)
-			return -ENOENT;
+	if (clid && TC_H_MAJ(clid) == TC_H_MAJ(TC_H_INGRESS))
+		num_q = 1;
+	else
+		num_q = dev->num_tx_queues;
 
-		if (tcm->tcm_handle && q->handle != tcm->tcm_handle)
-			return -EINVAL;
-	} else {
-		if ((q = qdisc_lookup(dev, tcm->tcm_handle)) == NULL)
-			return -ENOENT;
+	queue_arr = kzalloc(num_q * sizeof(*queue_arr), GFP_KERNEL);
+	if (!queue_arr)
+		return -ENOMEM;
+
+	err = tc_get_prep_request(queue_arr, num_q, dev, tcm, tca, clid);
+	if (err) {
+		kfree(queue_arr);
+		return err;
 	}
 
-	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
-		return -EINVAL;
+	if (n->nlmsg_type == RTM_DELQDISC)
+		err = tc_delete_all(queue_arr, num_q, dev, skb, n, clid);
+	else
+		err = tc_get_all(queue_arr, num_q, skb, n, clid);
+
+	kfree(queue_arr);
 
-	if (n->nlmsg_type == RTM_DELQDISC) {
-		if (!clid)
-			return -EINVAL;
-		if (q->handle == 0)
-			return -ENOENT;
-		if ((err = qdisc_graft(q->dev_queue, p, clid, NULL, &q)) != 0)
-			return err;
-		if (q) {
-			qdisc_notify(skb, n, clid, q, NULL);
-			qdisc_lock_tree(dev);
-			qdisc_destroy(q);
-			qdisc_unlock_tree(dev);
-		}
-	} else {
-		qdisc_notify(skb, n, clid, NULL, q);
-	}
 	return 0;
 }
 
+/* Allocate and create one new qdisc instance.  */
 static struct Qdisc *tc_create(struct net_device *dev,
 			       struct netdev_queue *dev_queue,
 			       u32 parent, u32 handle,
@@ -808,125 +959,259 @@ static struct Qdisc *tc_create(struct net_device *dev,
 	return q;
 }
 
-static int tc_graft(struct net_device *dev, struct netdev_queue *dev_queue,
-		    struct Qdisc *new_q, struct Qdisc *parent_q,
-		    u32 clid, struct sk_buff *skb, struct nlmsghdr *n)
+static int tc_create_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
+			 struct netdev_queue *dev_queue, struct nlattr **tca,
+			 struct tcmsg *tcm, u32 clid)
 {
-	struct Qdisc *old_q = NULL;
-	int err;
+	u32 parent, handle;
+	struct Qdisc *q;
 
-	err = qdisc_graft(dev_queue, parent_q, clid, new_q, &old_q);
-	if (err) {
-		if (new_q) {
-			qdisc_lock_tree(dev);
-			qdisc_destroy(new_q);
-			qdisc_unlock_tree(dev);
+	parent = tcm->tcm_parent;
+	if (clid == TC_H_INGRESS)
+		handle = parent;
+	else
+		handle = tcm->tcm_handle;
+
+	q = tc_create(dev, dev_queue, parent, handle, tca);
+	if (IS_ERR(q))
+		return PTR_ERR(q);
+
+	qp->op_q = q;
+	qp->flags |= TC_QDISC_OP_ALLOCATED;
+
+	return 0;
+}
+
+/* Cancel a set of one or more qdisc creations.  */
+static void tc_create_cancel(struct tc_qdisc_op_info *queue_arr, int num_q)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+
+		if (qp->flags & TC_QDISC_OP_ALLOCATED) {
+			qdisc_destroy(qp->op_q);
+			qp->op_q = NULL;
+			qp->flags &= ~TC_QDISC_OP_ALLOCATED;
 		}
-		return err;
 	}
+}
 
-	qdisc_notify(skb, n, clid, old_q, new_q);
+/* Create new qdiscs, as described by 'queue_arr' and 'num_q', using parameters
+ * in 'tcm' and 'tca'.
+ */
+static int tc_create_all(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+			 struct net_device *dev, struct tcmsg *tcm,
+			 struct nlattr **tca, u32 clid)
+{
+	unsigned int i;
 
-	if (old_q) {
-		qdisc_lock_tree(dev);
-		qdisc_destroy(old_q);
-		qdisc_unlock_tree(dev);
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		struct netdev_queue *dev_queue;
+		int err;
+
+		if (!(qp->flags & TC_QDISC_OP_CREATE))
+			continue;
+
+		if (clid == TC_H_INGRESS)
+			dev_queue = &dev->rx_queue;
+		else
+			dev_queue = netdev_get_tx_queue(dev, i);
+
+		err = tc_create_one(qp, dev, dev_queue, tca, tcm, clid);
+		if (err) {
+			tc_create_cancel(queue_arr, num_q);
+			return err;
+		}
 	}
 
 	return 0;
 }
 
-static int tc_create_and_graft(struct net_device *dev, u32 clid,
-			       struct tcmsg *tcm, struct nlattr **tca,
-			       struct Qdisc *parent_q,
-			       struct sk_buff *skb, struct nlmsghdr *n)
+/* Prepare to graft one new qdisc.  */
+static int tc_graft_prep_one(struct tc_qdisc_op_info *qp, u32 clid)
 {
-	struct netdev_queue *dev_queue;
-	u32 parent, handle;
-	struct Qdisc *q;
+	const struct Qdisc_class_ops *cops;
+	void *gp;
 
-	parent = tcm->tcm_parent;
-	if (clid == TC_H_INGRESS) {
-		dev_queue = &dev->rx_queue;
-		handle = parent;
-	} else {
-		dev_queue = netdev_get_tx_queue(dev, 0);
-		handle = tcm->tcm_handle;
+	if (!qp->parent_q)
+		return 0;
+
+	cops = qp->parent_q->ops->cl_ops;
+	if (!cops)
+		return -EINVAL;
+
+	qp->cl = cops->get(qp->parent_q, clid);
+	if (!qp->cl)
+		return -EINVAL;
+
+	gp = cops->prepare_graft(qp->parent_q, qp->cl, qp->op_q);
+	if (IS_ERR(gp)) {
+		cops->put(qp->parent_q, clid);
+		return PTR_ERR(gp);
 	}
-	q = tc_create(dev, dev_queue, parent, handle, tca);
-	if (IS_ERR(q))
-		return PTR_ERR(q);
 
-	return tc_graft(dev, dev_queue, q, parent_q, clid, skb, n);
+	qp->graft_mem = gp;
+	qp->flags |= TC_QDISC_OP_GRAFT_PREP;
+
+	return 0;
 }
 
-/* Create/change qdisc.  */
+/* Commit one new qdisc.  Emit netlink notifications.  This operation
+ * must not fail.
+ */
+static void tc_graft_commit(struct tc_qdisc_op_info *qp, struct netdev_queue *dev_queue,
+			    struct sk_buff *skb, struct nlmsghdr *n, u32 clid)
+{
+	struct Qdisc *parent, *new, *old;
 
-static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+	parent = qp->parent_q;
+	new = qp->op_q;
+
+	/* Grafting to an existing qdisc rather than a new one?  */
+	if ((qp->flags & TC_QDISC_OP_GRAFT) &&
+	    !(qp->flags & TC_QDISC_OP_CREATE))
+		atomic_inc(&new->refcnt);
+
+	old = NULL;
+	if (!parent) {
+		old = graft_qdisc(dev_queue, new);
+	} else {
+		const struct Qdisc_class_ops *cops = parent->ops->cl_ops;
+
+		cops->commit_graft(parent, qp->cl, new, qp->graft_mem, &old);
+		cops->put(parent, qp->cl);
+	}
+
+	qdisc_notify(skb, n, clid, old, new);
+
+	if (old) {
+		spin_lock_bh(&dev_queue->lock);
+		qdisc_destroy(old);
+		spin_unlock_bh(&dev_queue->lock);
+	}
+}
+
+/* Prepare and graft all qdiscs described by 'queue_arr' and 'num_q'.  */
+static int tc_graft_all(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+			struct net_device *dev, struct sk_buff *skb,
+			struct nlmsghdr *n, u32 clid)
 {
-	struct net *net = sock_net(skb->sk);
-	struct tcmsg *tcm;
-	struct nlattr *tca[TCA_MAX + 1];
-	struct net_device *dev;
-	u32 clid;
-	struct Qdisc *q, *p;
-	int err;
+	unsigned int i;
 
-	if (net != &init_net)
-		return -EINVAL;
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		int err;
 
-replay:
-	/* Reinit, just in case something touches this. */
-	tcm = NLMSG_DATA(n);
-	clid = tcm->tcm_parent;
-	q = p = NULL;
+		if (!(qp->flags & TC_QDISC_OP_GRAFT))
+			continue;
 
-	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
-		return -ENODEV;
+		err = tc_graft_prep_one(qp, clid);
+		if (err) {
+			tc_graft_cancel(queue_arr, num_q);
+			return err;
+		}
+	}
 
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
-	if (err < 0)
-		return err;
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		struct netdev_queue *dev_queue;
+
+		if (!(qp->flags & TC_QDISC_OP_GRAFT))
+			continue;
+
+		if (clid == TC_H_INGRESS)
+			dev_queue = &dev->rx_queue;
+		else
+			dev_queue = netdev_get_tx_queue(dev, i);
+
+		tc_graft_commit(qp, dev_queue, skb, n, clid);
+	}
+
+	return 0;
+}
 
+/* Make qdisc parameter changes as requested in 'tca' to the qdiscs
+ * recorded in 'queue_arr' and 'num_q'.
+ */
+static int tc_change_all(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+			 struct net_device *dev, struct nlattr **tca)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		int err;
+
+		if (!(qp->flags & TC_QDISC_OP_CHANGE))
+			continue;
+
+		err = qdisc_change(qp->op_q, tca);
+		if (err) {
+			/* XXX In multiqueue case, need rollback... */
+			return err;
+		}
+	}
+	return 0;
+}
+
+/* Parepare one qdisc op array entry for a change/create request.  */
+static int tc_prepare_one(struct tc_qdisc_op_info *qp, struct net_device *dev,
+			  struct netdev_queue *dev_queue, struct nlmsghdr *n,
+			  struct tcmsg *tcm, struct nlattr **tca, u32 clid)
+{
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (clid != TC_H_INGRESS) {
-				if ((p = qdisc_lookup(dev, TC_H_MAJ(clid))) == NULL)
+				qp->parent_q = qdisc_lookup(dev, TC_H_MAJ(clid));
+				if (!qp->parent_q)
 					return -ENOENT;
-				q = qdisc_leaf(p, clid);
+				qp->op_q = qdisc_leaf(qp->parent_q, clid);
 			} else { /*ingress */
-				q = dev->rx_queue.qdisc;
+				qp->op_q = dev_queue->qdisc;
 			}
 		} else {
-			struct netdev_queue *dev_queue;
-			dev_queue = netdev_get_tx_queue(dev, 0);
-			q = dev_queue->qdisc_sleeping;
+			qp->op_q = dev_queue->qdisc_sleeping;
 		}
 
 		/* It may be default qdisc, ignore it */
-		if (q && q->handle == 0)
-			q = NULL;
+		if (qp->op_q && qp->op_q->handle == 0)
+			qp->op_q = NULL;
 
-		if (!q || !tcm->tcm_handle || q->handle != tcm->tcm_handle) {
+		if (!qp->op_q ||
+		    !tcm->tcm_handle ||
+		    qp->op_q->handle != tcm->tcm_handle) {
 			if (tcm->tcm_handle) {
-				if (q && !(n->nlmsg_flags&NLM_F_REPLACE))
+				if (qp->op_q && !(n->nlmsg_flags&NLM_F_REPLACE))
 					return -EEXIST;
 				if (TC_H_MIN(tcm->tcm_handle))
 					return -EINVAL;
-				if ((q = qdisc_lookup(dev, tcm->tcm_handle)) == NULL)
-					goto create_n_graft;
+
+				qp->op_q = __qdisc_lookup(dev_queue, tcm->tcm_handle);
+				if (!qp->op_q)
+					goto create_and_graft;
+
 				if (n->nlmsg_flags&NLM_F_EXCL)
 					return -EEXIST;
-				if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
+
+				if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], qp->op_q->ops->id))
 					return -EINVAL;
-				if (q == p ||
-				    (p && check_loop(q, p, 0)))
+
+				if (qp->parent_q == qp->op_q ||
+				    (qp->parent_q &&
+				     check_loop(qp->op_q, qp->parent_q, 0)))
 					return -ELOOP;
-				atomic_inc(&q->refcnt);
-				goto graft;
+
+				/* We'll grab a reference to qp->op_q once the
+				 * graft is fully validated and we commit.
+				 */
+				qp->flags |= TC_QDISC_OP_GRAFT;
+				return 0;
 			} else {
-				if (q == NULL)
-					goto create_n_graft;
+				if (!qp->op_q)
+					goto create_and_graft;
 
 				/* This magic test requires explanation.
 				 *
@@ -951,38 +1236,119 @@ replay:
 				    (n->nlmsg_flags&NLM_F_REPLACE) &&
 				    ((n->nlmsg_flags&NLM_F_EXCL) ||
 				     (tca[TCA_KIND] &&
-				      nla_strcmp(tca[TCA_KIND], q->ops->id))))
-					goto create_n_graft;
+				      nla_strcmp(tca[TCA_KIND],
+						 qp->op_q->ops->id))))
+					goto create_and_graft;
 			}
 		}
 	} else {
 		if (!tcm->tcm_handle)
 			return -EINVAL;
-		q = qdisc_lookup(dev, tcm->tcm_handle);
+		qp->op_q = qdisc_lookup(dev, tcm->tcm_handle);
 	}
 
 	/* Change qdisc parameters */
-	if (q == NULL)
+	if (!qp->op_q)
 		return -ENOENT;
 	if (n->nlmsg_flags&NLM_F_EXCL)
 		return -EEXIST;
-	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
+	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], qp->op_q->ops->id))
 		return -EINVAL;
-	err = qdisc_change(q, tca);
-	if (err == 0)
-		qdisc_notify(skb, n, clid, NULL, q);
-	return err;
+	qp->flags |= TC_QDISC_OP_CHANGE;
+	return 0;
 
-create_n_graft:
+create_and_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
-	err = tc_create_and_graft(dev, clid, tcm, tca, p, skb, n);
-	if (err == -EAGAIN)
-		goto replay;
-	return err;
+	qp->flags |= (TC_QDISC_OP_CREATE | TC_QDISC_OP_GRAFT);
+	return 0;
+}
 
-graft:
-	return tc_graft(dev, q->dev_queue, q, p, clid, skb, n);
+/* Prepare an entire array of qdisc operation info entries.  */
+static int tc_prepare(struct tc_qdisc_op_info *queue_arr, unsigned int num_q,
+		      struct net_device *dev, struct nlmsghdr *n,
+		      struct tcmsg *tcm,
+		      struct nlattr **tca, u32 clid)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tc_qdisc_op_info *qp = queue_arr + i;
+		struct netdev_queue *dev_queue;
+		int err;
+
+		if (clid == TC_H_INGRESS)
+			dev_queue = &dev->rx_queue;
+		else
+			dev_queue = netdev_get_tx_queue(dev, i);
+
+		err = tc_prepare_one(qp, dev, dev_queue, n, tcm, tca, clid);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+/* Create/change qdisc.  */
+
+static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct tc_qdisc_op_info *queue_arr;
+	struct nlattr *tca[TCA_MAX + 1];
+	struct net_device *dev;
+	unsigned int num_q;
+	struct tcmsg *tcm;
+	u32 clid;
+	int err;
+
+	if (net != &init_net)
+		return -EINVAL;
+
+	tcm = NLMSG_DATA(n);
+
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+		return -ENODEV;
+
+	clid = tcm->tcm_parent;
+	if (clid == TC_H_INGRESS)
+		num_q = 1;
+	else
+		num_q = dev->num_tx_queues;
+
+	queue_arr = kmalloc(num_q * sizeof(*queue_arr), GFP_KERNEL);
+	if (!queue_arr)
+		return -ENOMEM;
+
+replay:
+	memset(queue_arr, 0, sizeof(*queue_arr) * num_q);
+
+	err = tc_prepare(queue_arr, num_q, dev, n, tcm, tca, clid);
+	if (err)
+		goto err_free;
+
+	err = tc_create_all(queue_arr, num_q, dev, tcm, tca, clid);
+	if (err) {
+		if (err == -EAGAIN)
+			goto replay;
+		goto err_free;
+	}
+
+	err = tc_graft_all(queue_arr, num_q, dev, skb, n, clid);
+	if (err) {
+		tc_create_cancel(queue_arr, num_q);
+		goto err_free;
+	}
+
+	err = tc_change_all(queue_arr, num_q, dev, tca);
+
+err_free:
+	kfree(queue_arr);
+	return err;
 }
 
 static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
@@ -1074,22 +1440,30 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	read_lock(&dev_base_lock);
 	idx = 0;
 	for_each_netdev(&init_net, dev) {
-		struct netdev_queue *dev_queue;
+		unsigned int i;
 		if (idx < s_idx)
 			goto cont;
 		if (idx > s_idx)
 			s_q_idx = 0;
 		q_idx = 0;
-		dev_queue = netdev_get_tx_queue(dev, 0);
-		list_for_each_entry(q, &dev_queue->qdisc_list, list) {
-			if (q_idx < s_q_idx) {
+		for (i = 0; i < dev->num_tx_queues; i++) {
+			struct netdev_queue *dev_queue;
+
+			dev_queue = netdev_get_tx_queue(dev, i);
+			list_for_each_entry(q, &dev_queue->qdisc_list,
+					    list) {
+				if (q_idx < s_q_idx) {
+					q_idx++;
+					continue;
+				}
+				if (tc_fill_qdisc(skb, q, q->parent,
+						  NETLINK_CB(cb->skb).pid,
+						  cb->nlh->nlmsg_seq,
+						  NLM_F_MULTI,
+						  RTM_NEWQDISC) <= 0)
+					goto done;
 				q_idx++;
-				continue;
 			}
-			if (tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
-					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0)
-				goto done;
-			q_idx++;
 		}
 cont:
 		idx++;
@@ -1310,14 +1684,13 @@ static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct qdisc_walk
 
 static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct tcmsg *tcm = (struct tcmsg*)NLMSG_DATA(cb->nlh);
 	struct net *net = sock_net(skb->sk);
-	struct netdev_queue *dev_queue;
-	int t;
-	int s_t;
+	struct qdisc_dump_args arg;
 	struct net_device *dev;
 	struct Qdisc *q;
-	struct tcmsg *tcm = (struct tcmsg*)NLMSG_DATA(cb->nlh);
-	struct qdisc_dump_args arg;
+	unsigned int i;
+	int s_t, t;
 
 	if (net != &init_net)
 		return 0;
@@ -1330,29 +1703,32 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	s_t = cb->args[0];
 	t = 0;
 
-	dev_queue = netdev_get_tx_queue(dev, 0);
-	list_for_each_entry(q, &dev_queue->qdisc_list, list) {
-		if (t < s_t || !q->ops->cl_ops ||
-		    (tcm->tcm_parent &&
-		     TC_H_MAJ(tcm->tcm_parent) != q->handle)) {
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, i);
+		list_for_each_entry(q, &dev_queue->qdisc_list, list) {
+			if (t < s_t || !q->ops->cl_ops ||
+			    (tcm->tcm_parent &&
+			     TC_H_MAJ(tcm->tcm_parent) != q->handle)) {
+				t++;
+				continue;
+			}
+			if (t > s_t)
+				memset(&cb->args[1], 0,
+				       sizeof(cb->args) - sizeof(cb->args[0]));
+			arg.w.fn = qdisc_class_dump;
+			arg.skb = skb;
+			arg.cb = cb;
+			arg.w.stop  = 0;
+			arg.w.skip = cb->args[1];
+			arg.w.count = 0;
+			q->ops->cl_ops->walk(q, &arg.w);
+			cb->args[1] = arg.w.count;
+			if (arg.w.stop)
+				goto stop;
 			t++;
-			continue;
 		}
-		if (t > s_t)
-			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
-		arg.w.fn = qdisc_class_dump;
-		arg.skb = skb;
-		arg.cb = cb;
-		arg.w.stop  = 0;
-		arg.w.skip = cb->args[1];
-		arg.w.count = 0;
-		q->ops->cl_ops->walk(q, &arg.w);
-		cb->args[1] = arg.w.count;
-		if (arg.w.stop)
-			break;
-		t++;
 	}
-
+stop:
 	cb->args[0] = t;
 
 	dev_put(dev);
-- 
1.5.6.2.255.gbed62

