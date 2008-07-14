From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/14]: pkt_sched: Make classifier filter config changes
 multiqueue aware.
Date: Mon, 14 Jul 2008 15:59:59 -0700 (PDT)
Message-ID: <20080714.155959.168275046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758533AbYGNXAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 19:00:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 55722C8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcf_proto_ops is modified to seperate change and delete requests
into a validate and a commit stage.  And in the case of change
requests, a cancel operation is provided to release resources.

The classifier filter API layer is modified, in turn, to operate
on all device TX queues.  All of the operations are validated,
and if all validations succeed then commits are performed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |   15 +-
 net/sched/cls_api.c       |  463 +++++++++++++++++++++++++++++++--------------
 net/sched/cls_basic.c     |  183 +++++++++++++-----
 net/sched/cls_flow.c      |  267 ++++++++++++++++++---------
 net/sched/cls_fw.c        |  247 ++++++++++++++++++-------
 net/sched/cls_route.c     |  305 +++++++++++++++++++++---------
 net/sched/cls_rsvp.h      |  256 ++++++++++++++++++--------
 net/sched/cls_tcindex.c   |  314 ++++++++++++++++++++++---------
 net/sched/cls_u32.c       |  324 ++++++++++++++++++++++++--------
 9 files changed, 1692 insertions(+), 682 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4d11b29..150ecd0 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -131,10 +131,17 @@ struct tcf_proto_ops
 
 	unsigned long		(*get)(struct tcf_proto*, u32 handle);
 	void			(*put)(struct tcf_proto*, unsigned long);
-	int			(*change)(struct tcf_proto*, unsigned long,
-					u32 handle, struct nlattr **,
-					unsigned long *);
-	int			(*delete)(struct tcf_proto*, unsigned long);
+	int			(*validate_change)(struct tcf_proto*, unsigned long,
+						   u32 handle, struct nlattr **,
+						   unsigned long *);
+	void			(*commit_change)(struct tcf_proto*, unsigned long,
+						 u32 handle, struct nlattr **,
+						 unsigned long);
+	void			(*cancel_change)(struct tcf_proto*, unsigned long,
+						 u32 handle, struct nlattr **,
+						 unsigned long);
+	int			(*validate_delete)(struct tcf_proto *, unsigned long);
+	void			(*commit_delete)(struct tcf_proto *, unsigned long);
 	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
 
 	/* rtnetlink specific */
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d0b0a9b..65ca460 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -114,215 +114,384 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 	return first;
 }
 
-/* Add/change/delete/get a filter node */
+struct tcf_op_parms {
+	u32			protocol;
+	u32			prio;
+	u32			nprio;
+	u32			parent;
+};
 
-static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
-{
-	struct net *net = sock_net(skb->sk);
-	struct nlattr *tca[TCA_MAX + 1];
-	struct tcmsg *t;
-	u32 protocol;
-	u32 prio;
-	u32 nprio;
-	u32 parent;
-	struct net_device *dev;
-	struct Qdisc  *q;
-	struct tcf_proto **back, **chain;
-	struct tcf_proto *tp;
-	struct tcf_proto_ops *tp_ops;
-	const struct Qdisc_class_ops *cops;
-	unsigned long cl;
-	unsigned long fh;
-	int err;
+struct tcf_op_info {
+	struct Qdisc		*q;
+	unsigned long		cl;
+	unsigned long		fh;
+	struct tcf_proto	*tproto;
+	struct tcf_proto	**insertion_point;
+	unsigned int		flags;
+#define TCF_OP_FLAG_NEW		0x00000001
+#define TCF_OP_FLAG_PREP_CHG	0x00000002
+};
 
-	if (net != &init_net)
-		return -EINVAL;
+static struct tcf_proto_ops *tcf_proto_grab_ops(struct nlattr *kind)
+{
+	struct tcf_proto_ops *tp_ops = tcf_proto_lookup_ops(kind);
 
-replay:
-	t = NLMSG_DATA(n);
-	protocol = TC_H_MIN(t->tcm_info);
-	prio = TC_H_MAJ(t->tcm_info);
-	nprio = prio;
-	parent = t->tcm_parent;
-	cl = 0;
-
-	if (prio == 0) {
-		/* If no priority is given, user wants we allocated it. */
-		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
-			return -ENOENT;
-		prio = TC_H_MAKE(0x80000000U, 0U);
+	if (!tp_ops) {
+		int err = -ENOENT;
+#ifdef CONFIG_KMOD
+		char name[IFNAMSIZ];
+
+		if (kind != NULL &&
+		    nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
+			rtnl_unlock();
+			request_module("cls_%s", name);
+			rtnl_lock();
+			tp_ops = tcf_proto_lookup_ops(kind);
+			/* We dropped the RTNL semaphore in order to
+			 * perform the module load.  So, even if we
+			 * succeeded in loading the module we have to
+			 * replay the request.  We indicate this using
+			 * -EAGAIN.
+			 */
+			if (tp_ops != NULL) {
+				module_put(tp_ops->owner);
+				err = -EAGAIN;
+			}
+		}
+#endif
+		return ERR_PTR(err);
 	}
+	return tp_ops;
+}
 
-	/* Find head of filter chain. */
-
-	/* Find link */
-	dev = __dev_get_by_index(&init_net, t->tcm_ifindex);
-	if (dev == NULL)
-		return -ENODEV;
-
-	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
-	if (err < 0)
-		return err;
+static int tcf_prepare_one(struct tcf_op_parms *parms, struct tcf_op_info *tp,
+			   struct netdev_queue *dev_queue, struct nlmsghdr *n,
+			   struct tcmsg *t, struct nlattr **tca)
+{
+	struct tcf_proto *tproto, *new_tproto;
+	const struct Qdisc_class_ops *cops;
+	struct tcf_proto **back, **chain;
+	u32 parent = parms->parent;
+	int err;
 
 	/* Find qdisc */
 	if (!parent) {
-		struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
-		q = dev_queue->qdisc_sleeping;
-		parent = q->handle;
+		tp->q = dev_queue->qdisc_sleeping;
+		parent = tp->q->handle;
 	} else {
-		q = qdisc_lookup(dev, TC_H_MAJ(t->tcm_parent));
-		if (q == NULL)
+		tp->q = __qdisc_lookup(dev_queue, TC_H_MAJ(t->tcm_parent));
+		if (!tp->q)
 			return -EINVAL;
 	}
 
 	/* Is it classful? */
-	if ((cops = q->ops->cl_ops) == NULL)
+	cops = tp->q->ops->cl_ops;
+	if (!cops)
 		return -EINVAL;
 
 	/* Do we search for filter, attached to class? */
+	tp->cl = 0;
 	if (TC_H_MIN(parent)) {
-		cl = cops->get(q, parent);
-		if (cl == 0)
+		tp->cl = cops->get(tp->q, parent);
+		if (tp->cl == 0)
 			return -ENOENT;
 	}
 
 	/* And the last stroke */
-	chain = cops->tcf_chain(q, cl);
+	chain = cops->tcf_chain(tp->q, tp->cl);
 	err = -EINVAL;
 	if (chain == NULL)
-		goto errout;
+		goto err_unwind;
+
+	err = -EINVAL;
+	if (!chain)
+		goto err_unwind;
 
 	/* Check the chain for existence of proto-tcf with this priority */
-	for (back = chain; (tp=*back) != NULL; back = &tp->next) {
-		if (tp->prio >= prio) {
-			if (tp->prio == prio) {
-				if (!nprio || (tp->protocol != protocol && protocol))
-					goto errout;
+	for (back = chain; (tproto = *back) != NULL; back = &tproto->next) {
+		if (tproto->prio >= parms->prio) {
+			if (tproto->prio == parms->prio) {
+				if (!parms->nprio ||
+				    (tproto->protocol != parms->protocol &&
+				     parms->protocol))
+					goto err_unwind;
 			} else
-				tp = NULL;
+				tproto = NULL;
 			break;
 		}
 	}
+	tp->insertion_point = back;
 
-	if (tp == NULL) {
-		/* Proto-tcf does not exist, create new one */
+	new_tproto = NULL;
+	if (!tproto) {
+		struct tcf_proto_ops *tp_ops;
 
-		if (tca[TCA_KIND] == NULL || !protocol)
-			goto errout;
+		if (!tca[TCA_KIND] || !parms->protocol)
+			goto err_unwind;
 
 		err = -ENOENT;
 		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
-			goto errout;
+			goto err_unwind;
 
+		err = -ENOBUFS;
+		tproto = kzalloc(sizeof(*tproto), GFP_KERNEL);
+		if (!tproto)
+			goto err_unwind;
 
-		/* Create new proto tcf */
+		new_tproto = tproto;
 
-		err = -ENOBUFS;
-		tp = kzalloc(sizeof(*tp), GFP_KERNEL);
-		if (tp == NULL)
-			goto errout;
-		err = -ENOENT;
-		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
-		if (tp_ops == NULL) {
-#ifdef CONFIG_KMOD
-			struct nlattr *kind = tca[TCA_KIND];
-			char name[IFNAMSIZ];
-
-			if (kind != NULL &&
-			    nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
-				rtnl_unlock();
-				request_module("cls_%s", name);
-				rtnl_lock();
-				tp_ops = tcf_proto_lookup_ops(kind);
-				/* We dropped the RTNL semaphore in order to
-				 * perform the module load.  So, even if we
-				 * succeeded in loading the module we have to
-				 * replay the request.  We indicate this using
-				 * -EAGAIN.
-				 */
-				if (tp_ops != NULL) {
-					module_put(tp_ops->owner);
-					err = -EAGAIN;
-				}
-			}
-#endif
-			kfree(tp);
-			goto errout;
+		tp_ops = tcf_proto_grab_ops(tca[TCA_KIND]);
+		if (IS_ERR(tp_ops)) {
+			err = PTR_ERR(tp_ops);
+			kfree(tproto);
+			goto err_unwind;
 		}
-		tp->ops = tp_ops;
-		tp->protocol = protocol;
-		tp->prio = nprio ? : tcf_auto_prio(*back);
-		tp->q = q;
-		tp->classify = tp_ops->classify;
-		tp->classid = parent;
-
-		err = tp_ops->init(tp);
+
+		tproto->ops = tp_ops;
+		tproto->protocol = parms->protocol;
+		tproto->prio = parms->nprio ? : tcf_auto_prio(*back);
+		tproto->q = tp->q;
+		tproto->classify = tp_ops->classify;
+		tproto->classid = parms->parent;
+
+		err = tp_ops->init(tproto);
 		if (err != 0) {
 			module_put(tp_ops->owner);
-			kfree(tp);
-			goto errout;
+			kfree(tproto);
+			goto err_unwind;
 		}
+	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tproto->ops->kind))
+		goto err_unwind;
 
-		qdisc_lock_tree(dev);
-		tp->next = *back;
-		*back = tp;
-		qdisc_unlock_tree(dev);
-
-	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
-		goto errout;
-
-	fh = tp->ops->get(tp, t->tcm_handle);
-
-	if (fh == 0) {
-		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
-			qdisc_lock_tree(dev);
-			*back = tp->next;
-			qdisc_unlock_tree(dev);
-
-			tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
-			tcf_destroy(tp);
-			err = 0;
-			goto errout;
-		}
+	tp->tproto = tproto;
 
+	tp->fh = tproto->ops->get(tproto, t->tcm_handle);
+	if (tp->fh == 0) {
+		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0)
+			return 0;
 		err = -ENOENT;
 		if (n->nlmsg_type != RTM_NEWTFILTER ||
 		    !(n->nlmsg_flags & NLM_F_CREATE))
-			goto errout;
+			goto err_unwind_destroy;
 	} else {
 		switch (n->nlmsg_type) {
 		case RTM_NEWTFILTER:
 			err = -EEXIST;
 			if (n->nlmsg_flags & NLM_F_EXCL)
-				goto errout;
+				goto err_unwind_destroy;
 			break;
 		case RTM_DELTFILTER:
-			err = tp->ops->delete(tp, fh);
-			if (err == 0)
-				tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
-			goto errout;
+			err = tproto->ops->validate_delete(tproto, tp->fh);
+			if (err)
+				goto err_unwind_destroy;
+			return 0;
 		case RTM_GETTFILTER:
-			err = tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
-			goto errout;
+			return 0;
 		default:
 			err = -EINVAL;
-			goto errout;
+			goto err_unwind_destroy;
 		}
 	}
+	err = tproto->ops->validate_change(tproto, tp->cl, t->tcm_handle, tca, &tp->fh);
+	if (err)
+		goto err_unwind_destroy;
 
-	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
-		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	tp->flags |= TCF_OP_FLAG_PREP_CHG;
 
-errout:
-	if (cl)
-		cops->put(q, cl);
-	if (err == -EAGAIN)
-		/* Replay the request. */
-		goto replay;
+	return 0;
+
+err_unwind_destroy:
+	if (new_tproto)
+		tcf_destroy(new_tproto);
+	goto err_unwind;
+
+err_unwind:
+	if (tp->cl) {
+		cops->put(tp->q, tp->cl);
+		tp->cl = 0;
+	}
 	return err;
 }
 
+static void tcf_cancel_op(struct tcf_op_info *queue_arr, unsigned int num_q,
+			  struct tcmsg *t, struct nlattr **tca)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tcf_op_info *tp = queue_arr + i;
+		struct tcf_proto *tproto;
+
+		tproto = tp->tproto;
+
+		if (tp->flags & TCF_OP_FLAG_PREP_CHG)
+			tproto->ops->cancel_change(tproto, tp->cl, t->tcm_handle,
+						   tca, tp->fh);
+
+		if (tp->flags & TCF_OP_FLAG_NEW) {
+			tcf_destroy(tp->tproto);
+			tp->tproto = NULL;
+		}
+
+		if (tp->cl) {
+			const struct Qdisc_class_ops *cops;
+
+			cops = tp->q->ops->cl_ops;
+			cops->put(tp->q, tp->cl);
+
+			tp->cl = 0;
+		}
+	}
+}
+
+static int tcf_prepare_op(struct tcf_op_parms *parms, struct tcf_op_info *queue_arr,
+			  unsigned int num_q, struct net_device *dev,
+			  struct nlmsghdr *n, struct tcmsg *t, struct nlattr **tca)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tcf_op_info *tp = queue_arr + i;
+		struct netdev_queue *dev_queue;
+		int err;
+
+		dev_queue = netdev_get_tx_queue(dev, i);
+		err = tcf_prepare_one(parms, tp, dev_queue, n, t, tca);
+		if (err) {
+			tcf_cancel_op(queue_arr, num_q, t, tca);
+			return err;
+		}
+	}
+	return 0;
+}
+
+static void tcf_commit_one(struct tcf_op_parms *parms, struct tcf_op_info *tp,
+			   struct netdev_queue *dev_queue,
+			   struct nlmsghdr *n, struct sk_buff *skb,
+			   struct tcmsg *t, struct nlattr **tca)
+{
+	const struct Qdisc_class_ops *cops;
+
+	if (tp->flags & TCF_OP_FLAG_NEW) {
+		spin_lock_bh(&dev_queue->lock);
+
+		tp->tproto->next = *tp->insertion_point;
+		*tp->insertion_point = tp->tproto;
+
+		spin_unlock_bh(&dev_queue->lock);
+	}
+
+	if (tp->fh == 0) {
+		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
+			spin_lock_bh(&dev_queue->lock);
+			*tp->insertion_point = tp->tproto->next;
+			spin_unlock_bh(&dev_queue->lock);
+
+			tfilter_notify(skb, n, tp->tproto, tp->fh, RTM_DELTFILTER);
+			tcf_destroy(tp->tproto);
+			return;
+		}
+	} else {
+		switch (n->nlmsg_type) {
+		case RTM_NEWTFILTER:
+			break;
+		case RTM_DELTFILTER:
+			tp->tproto->ops->commit_delete(tp->tproto, tp->fh);
+			tfilter_notify(skb, n, tp->tproto, tp->fh, RTM_DELTFILTER);
+			return;
+
+		case RTM_GETTFILTER:
+			tfilter_notify(skb, n, tp->tproto, tp->fh, RTM_NEWTFILTER);
+			return;
+		default:
+			return;
+		}
+	}
+	tp->tproto->ops->commit_change(tp->tproto, tp->cl, t->tcm_handle, tca, tp->fh);
+	tfilter_notify(skb, n, tp->tproto, tp->fh, RTM_NEWTFILTER);
+
+	cops = tp->q->ops->cl_ops;
+	if (tp->cl) {
+		cops->put(tp->q, tp->cl);
+		tp->cl = 0;
+	}
+}
+
+static void tcf_commit_op(struct tcf_op_parms *parms, struct tcf_op_info *queue_arr,
+			  unsigned int num_q, struct net_device *dev,
+			  struct nlmsghdr *n, struct sk_buff *skb,
+			  struct tcmsg *t, struct nlattr **tca)
+{
+	unsigned int i;
+
+	for (i = 0; i < num_q; i++) {
+		struct tcf_op_info *tp = queue_arr + i;
+		struct netdev_queue *dev_queue;
+
+		dev_queue = netdev_get_tx_queue(dev, i);
+
+		tcf_commit_one(parms, tp, dev_queue, n, skb, t, tca);
+	}
+}
+
+/* Add/change/delete/get a filter node */
+
+static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nlattr *tca[TCA_MAX + 1];
+	struct tcf_op_info *queue_arr;
+	struct tcf_op_parms parms;
+	struct net_device *dev;
+	unsigned int num_q;
+	struct tcmsg *t;
+	int err;
+
+	if (net != &init_net)
+		return -EINVAL;
+
+	t = NLMSG_DATA(n);
+
+	/* Find link */
+	dev = __dev_get_by_index(&init_net, t->tcm_ifindex);
+	if (dev == NULL)
+		return -ENODEV;
+
+	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	num_q = dev->num_tx_queues;
+	queue_arr = kmalloc(num_q * sizeof(*queue_arr), GFP_KERNEL);
+	if (!queue_arr)
+		return -ENOMEM;
+
+replay:
+	memset(queue_arr, 0, sizeof(*queue_arr) * num_q);
+	parms.protocol = TC_H_MIN(t->tcm_info);
+	parms.prio = TC_H_MAJ(t->tcm_info);
+	parms.nprio = parms.prio;
+	parms.parent = t->tcm_parent;
+
+	if (parms.prio == 0) {
+		/* If no priority is given, user wants us to allocate it. */
+		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
+			return -ENOENT;
+		parms.prio = TC_H_MAKE(0x80000000U, 0U);
+	}
+
+	err = tcf_prepare_op(&parms, queue_arr, num_q, dev, n, t, tca);
+	if (err) {
+		if (err == -EAGAIN)
+			goto replay;
+		return err;
+	}
+
+	tcf_commit_op(&parms, queue_arr, num_q, dev, n, skb, t, tca);
+
+	return 0;
+}
+
 static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 			 unsigned long fh, u32 pid, u32 seq, u16 flags, int event)
 {
@@ -414,7 +583,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if (!tcm->tcm_parent)
 		q = dev_queue->qdisc_sleeping;
 	else
-		q = qdisc_lookup(dev, TC_H_MAJ(tcm->tcm_parent));
+		q = __qdisc_lookup(dev_queue, TC_H_MAJ(tcm->tcm_parent));
 	if (!q)
 		goto out;
 	if ((cops = q->ops->cl_ops) == NULL)
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 956915c..af48876 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -24,6 +24,8 @@ struct basic_head
 {
 	u32			hgenerator;
 	struct list_head	flist;
+
+	void			*pending_config;
 };
 
 struct basic_filter
@@ -112,67 +114,95 @@ static void basic_destroy(struct tcf_proto *tp)
 	kfree(head);
 }
 
-static int basic_delete(struct tcf_proto *tp, unsigned long arg)
+static int basic_validate_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct basic_head *head = (struct basic_head *) tp->root;
 	struct basic_filter *t, *f = (struct basic_filter *) arg;
 
-	list_for_each_entry(t, &head->flist, link)
-		if (t == f) {
-			tcf_tree_lock(tp);
-			list_del(&t->link);
-			tcf_tree_unlock(tp);
-			basic_delete_filter(tp, t);
+	list_for_each_entry(t, &head->flist, link) {
+		if (t == f)
 			return 0;
-		}
+	}
 
 	return -ENOENT;
 }
 
+static void basic_commit_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct basic_filter *f = (struct basic_filter *) arg;
+
+	tcf_tree_lock(tp);
+	list_del(&f->link);
+	tcf_tree_unlock(tp);
+	basic_delete_filter(tp, f);
+}
+
 static const struct nla_policy basic_policy[TCA_BASIC_MAX + 1] = {
 	[TCA_BASIC_CLASSID]	= { .type = NLA_U32 },
 	[TCA_BASIC_EMATCHES]	= { .type = NLA_NESTED },
 };
 
-static inline int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
-				  unsigned long base, struct nlattr **tb,
-				  struct nlattr *est)
+
+struct basic_pending_config {
+	struct basic_filter	*new_filter;
+	struct tcf_exts		exts;
+	struct tcf_ematch_tree	em_tree;
+	u32			classid;
+	unsigned int		flags;
+#define FLAG_HAVE_CLASSID	0x00000001
+};
+
+static int basic_validate_parms(struct basic_head *head,
+				struct basic_pending_config *p,
+				struct tcf_proto *tp, struct basic_filter *f,
+				unsigned long base, struct nlattr **tb,
+				struct nlattr *est)
 {
-	int err = -EINVAL;
-	struct tcf_exts e;
-	struct tcf_ematch_tree t;
+	int err = tcf_exts_validate(tp, tb, est, &p->exts, &basic_ext_map);
 
-	err = tcf_exts_validate(tp, tb, est, &e, &basic_ext_map);
 	if (err < 0)
 		return err;
 
-	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &t);
-	if (err < 0)
-		goto errout;
-
+	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &p->em_tree);
+	if (err < 0) {
+		tcf_exts_destroy(tp, &p->exts);
+		return err;
+	}
 	if (tb[TCA_BASIC_CLASSID]) {
-		f->res.classid = nla_get_u32(tb[TCA_BASIC_CLASSID]);
-		tcf_bind_filter(tp, &f->res, base);
+		p->classid = nla_get_u32(tb[TCA_BASIC_CLASSID]);
+		p->flags |= FLAG_HAVE_CLASSID;
 	}
+	return 0;
+}
 
-	tcf_exts_change(tp, &f->exts, &e);
-	tcf_em_tree_change(tp, &f->ematches, &t);
+static void basic_cancel_parms(struct tcf_proto *tp, struct basic_pending_config *p)
+{
+	tcf_em_tree_destroy(tp, &p->em_tree);
+	tcf_exts_destroy(tp, &p->exts);
+}
 
-	return 0;
-errout:
-	tcf_exts_destroy(tp, &e);
-	return err;
+static void basic_commit_parms(struct tcf_proto *tp, struct basic_pending_config *p,
+			       struct basic_filter *f, unsigned long base)
+{
+	if (p->flags & FLAG_HAVE_CLASSID) {
+		f->res.classid = p->classid;
+		tcf_bind_filter(tp, &f->res, base);
+	}
+
+	tcf_exts_change(tp, &f->exts, &p->exts);
+	tcf_em_tree_change(tp, &f->ematches, &p->em_tree);
 }
 
-static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
-			struct nlattr **tca, unsigned long *arg)
+static int basic_validate_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+				 struct nlattr **tca, unsigned long *arg)
 {
-	int err;
 	struct basic_head *head = (struct basic_head *) tp->root;
 	struct nlattr *tb[TCA_BASIC_MAX + 1];
 	struct basic_filter *f = (struct basic_filter *) *arg;
+	struct basic_pending_config *p;
+	int err;
 
-	if (tca[TCA_OPTIONS] == NULL)
+	if (!tca[TCA_OPTIONS])
 		return -EINVAL;
 
 	err = nla_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS],
@@ -180,18 +210,27 @@ static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (err < 0)
 		return err;
 
+	BUG_ON(head->pending_config);
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
 	if (f != NULL) {
 		if (handle && f->handle != handle)
 			return -EINVAL;
-		return basic_set_parms(tp, f, base, tb, tca[TCA_RATE]);
+		err = basic_validate_parms(head, p, tp, f, base, tb, tca[TCA_RATE]);
+		if (err)
+			goto err_free_config;
+		goto success;
 	}
 
-	err = -ENOBUFS;
 	f = kzalloc(sizeof(*f), GFP_KERNEL);
-	if (f == NULL)
-		goto errout;
+	err = -ENOBUFS;
+	if (!f)
+		goto err_free_config;
+
+	p->new_filter = f;
 
-	err = -EINVAL;
 	if (handle)
 		f->handle = handle;
 	else {
@@ -201,31 +240,78 @@ static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 				head->hgenerator = 1;
 		} while (--i > 0 && basic_get(tp, head->hgenerator));
 
+		err = -EINVAL;
 		if (i <= 0) {
 			printk(KERN_ERR "Insufficient number of handles\n");
-			goto errout;
+			goto err_free_filter;
 		}
 
 		f->handle = head->hgenerator;
 	}
 
-	err = basic_set_parms(tp, f, base, tb, tca[TCA_RATE]);
+	err = basic_validate_parms(head, p, tp, f, base, tb, tca[TCA_RATE]);
 	if (err < 0)
-		goto errout;
+		goto err_free_filter;
 
-	tcf_tree_lock(tp);
-	list_add(&f->link, &head->flist);
-	tcf_tree_unlock(tp);
+success:
+	head->pending_config = p;
 	*arg = (unsigned long) f;
 
 	return 0;
-errout:
-	if (*arg == 0UL && f)
-		kfree(f);
 
+err_free_filter:
+	kfree(f);
+
+err_free_config:
+	kfree(p);
 	return err;
 }
 
+static void basic_commit_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+				struct nlattr **tca, unsigned long arg)
+{
+	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_filter *f = (struct basic_filter *) arg;
+	struct basic_pending_config *p;
+
+	BUG_ON(!head->pending_config);
+	p = head->pending_config;
+	head->pending_config = NULL;
+
+	basic_commit_parms(tp, p, f, base);
+
+	if (p->new_filter) {
+		tcf_tree_lock(tp);
+		list_add(&f->link, &head->flist);
+		tcf_tree_unlock(tp);
+
+		p->new_filter = NULL;
+	}
+
+	kfree(p);
+}
+
+static void basic_cancel_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+				struct nlattr **tca, unsigned long arg)
+{
+	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_pending_config *p;
+
+	BUG_ON(!head->pending_config);
+
+	p = head->pending_config;
+	head->pending_config = NULL;
+
+	basic_cancel_parms(tp, p);
+
+	if (p->new_filter) {
+		kfree(p->new_filter);
+		p->new_filter = NULL;
+	}
+
+	kfree(p);
+}
+
 static void basic_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
 	struct basic_head *head = (struct basic_head *) tp->root;
@@ -281,8 +367,11 @@ static struct tcf_proto_ops cls_basic_ops __read_mostly = {
 	.destroy	=	basic_destroy,
 	.get		=	basic_get,
 	.put		=	basic_put,
-	.change		=	basic_change,
-	.delete		=	basic_delete,
+	.validate_change=	basic_validate_change,
+	.commit_change	=	basic_commit_change,
+	.cancel_change	=	basic_cancel_change,
+	.validate_delete=	basic_validate_delete,
+	.commit_delete	=	basic_commit_delete,
 	.walk		=	basic_walk,
 	.dump		=	basic_dump,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 971b867..35b46bb 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -30,6 +30,8 @@
 
 struct flow_head {
 	struct list_head	filters;
+
+	void			*pending_config;
 };
 
 struct flow_filter {
@@ -383,131 +385,215 @@ static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_EMATCHES]	= { .type = NLA_NESTED },
 };
 
-static int flow_change(struct tcf_proto *tp, unsigned long base,
-		       u32 handle, struct nlattr **tca,
-		       unsigned long *arg)
+struct flow_pending_config {
+	unsigned int		nkeys;
+	u32			baseclass, keymask, mode;
+	struct tcf_exts		e;
+	struct tcf_ematch_tree	t;
+	struct flow_filter	*new_f;
+
+	u32			mask;
+	u32			xor;
+	u32			rshift;
+	u32			addend;
+	u32			divisor;
+
+	unsigned int		flags;
+#define FLAG_FLOW_KEYS		0x00000001
+#define FLAG_FLOW_MASK		0x00000002
+#define FLAG_FLOW_XOR		0x00000004
+#define FLAG_FLOW_RSHIFT	0x00000008
+#define FLAG_FLOW_ADDEND	0x00000010
+#define FLAG_FLOW_DIVISOR	0x00000020
+};
+
+static int flow_validate_change(struct tcf_proto *tp, unsigned long base,
+				u32 handle, struct nlattr **tca,
+				unsigned long *arg)
 {
 	struct flow_head *head = tp->root;
+	struct flow_pending_config *p;
 	struct flow_filter *f;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FLOW_MAX + 1];
-	struct tcf_exts e;
-	struct tcf_ematch_tree t;
-	unsigned int nkeys = 0;
-	u32 baseclass = 0;
-	u32 keymask = 0;
-	u32 mode;
 	int err;
 
-	if (opt == NULL)
+	if (!opt)
 		return -EINVAL;
 
 	err = nla_parse_nested(tb, TCA_FLOW_MAX, opt, flow_policy);
 	if (err < 0)
 		return err;
 
+	BUG_ON(head->pending_config);
+
+	p = kzalloc(sizeof(struct flow_pending_config),
+				       GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	p->nkeys = p->baseclass = p->keymask = p->mode = 0;
+	err = -EINVAL;
 	if (tb[TCA_FLOW_BASECLASS]) {
-		baseclass = nla_get_u32(tb[TCA_FLOW_BASECLASS]);
-		if (TC_H_MIN(baseclass) == 0)
-			return -EINVAL;
+		p->baseclass = nla_get_u32(tb[TCA_FLOW_BASECLASS]);
+		if (TC_H_MIN(p->baseclass) == 0)
+			goto err_free_config;
 	}
-
 	if (tb[TCA_FLOW_KEYS]) {
-		keymask = nla_get_u32(tb[TCA_FLOW_KEYS]);
-
-		nkeys = hweight32(keymask);
-		if (nkeys == 0)
-			return -EINVAL;
-
-		if (fls(keymask) - 1 > FLOW_KEY_MAX)
-			return -EOPNOTSUPP;
+		p->keymask = nla_get_u32(tb[TCA_FLOW_KEYS]);
+		p->nkeys = hweight32(p->keymask);
+		if (!p->nkeys)
+			goto err_free_config;
+		err = -EOPNOTSUPP;
+		if (fls(p->keymask) - 1 > FLOW_KEY_MAX)
+			goto err_free_config;
 	}
-
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &flow_ext_map);
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &p->e, &flow_ext_map);
 	if (err < 0)
-		return err;
-
-	err = tcf_em_tree_validate(tp, tb[TCA_FLOW_EMATCHES], &t);
+		goto err_free_config;
+	err = tcf_em_tree_validate(tp, tb[TCA_FLOW_EMATCHES], &p->t);
 	if (err < 0)
-		goto err1;
+		goto err_destroy_ext;
 
-	f = (struct flow_filter *)*arg;
-	if (f != NULL) {
-		err = -EINVAL;
-		if (f->handle != handle && handle)
-			goto err2;
+	f = (struct flow_filter *) *arg;
+	err = -EINVAL;
 
-		mode = f->mode;
-		if (tb[TCA_FLOW_MODE])
-			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
-		if (mode != FLOW_MODE_HASH && nkeys > 1)
-			goto err2;
+	if (f)
+		p->mode = f->mode;
+	else if (tb[TCA_FLOW_MODE])
+		p->mode = nla_get_u32(tb[TCA_FLOW_MODE]);
+	else
+		p->mode = FLOW_MODE_MAP;
+	if (p->mode != FLOW_MODE_HASH && p->nkeys > 1)
+		goto err_destroy_em;
+
+	if (f) {
+		if (f->handle != handle && handle)
+			goto err_destroy_em;
 	} else {
-		err = -EINVAL;
-		if (!handle)
-			goto err2;
-		if (!tb[TCA_FLOW_KEYS])
-			goto err2;
-
-		mode = FLOW_MODE_MAP;
-		if (tb[TCA_FLOW_MODE])
-			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
-		if (mode != FLOW_MODE_HASH && nkeys > 1)
-			goto err2;
-
-		if (TC_H_MAJ(baseclass) == 0)
-			baseclass = TC_H_MAKE(tp->q->handle, baseclass);
-		if (TC_H_MIN(baseclass) == 0)
-			baseclass = TC_H_MAKE(baseclass, 1);
+		if (!handle || !tb[TCA_FLOW_KEYS])
+			goto err_destroy_em;
+		if (TC_H_MAJ(p->baseclass) == 0)
+			p->baseclass = TC_H_MAKE(tp->q->handle, p->baseclass);
+		if (TC_H_MIN(p->baseclass) == 0)
+			p->baseclass = TC_H_MAKE(p->baseclass, 1);
 
 		err = -ENOBUFS;
 		f = kzalloc(sizeof(*f), GFP_KERNEL);
 		if (f == NULL)
-			goto err2;
+			goto err_destroy_em;
 
+		p->new_f = f;
 		f->handle = handle;
 		f->mask	  = ~0U;
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
-	tcf_em_tree_change(tp, &f->ematches, &t);
+	if (tb[TCA_FLOW_KEYS])
+		p->flags |= FLAG_FLOW_KEYS;
+	if (tb[TCA_FLOW_MASK]) {
+		p->mask = nla_get_u32(tb[TCA_FLOW_MASK]);
+		p->flags |= FLAG_FLOW_MASK;
+	}
+	if (tb[TCA_FLOW_XOR]) {
+		p->xor = nla_get_u32(tb[TCA_FLOW_XOR]);
+		p->flags |= FLAG_FLOW_XOR;
+	}
+	if (tb[TCA_FLOW_RSHIFT]) {
+		p->rshift = nla_get_u32(tb[TCA_FLOW_RSHIFT]);
+		p->flags |= FLAG_FLOW_RSHIFT;
+	}
+	if (tb[TCA_FLOW_ADDEND]) {
+		p->addend = nla_get_u32(tb[TCA_FLOW_ADDEND]);
+		p->flags |= FLAG_FLOW_ADDEND;
+	}
+	if (tb[TCA_FLOW_DIVISOR]) {
+		p->divisor = nla_get_u32(tb[TCA_FLOW_DIVISOR]);
+		p->flags |= FLAG_FLOW_DIVISOR;
+	}
 
-	tcf_tree_lock(tp);
+	head->pending_config = p;
+	*arg = (unsigned long) f;
 
-	if (tb[TCA_FLOW_KEYS]) {
-		f->keymask = keymask;
-		f->nkeys   = nkeys;
-	}
+	return 0;
+
+err_destroy_em:
+	tcf_em_tree_destroy(tp, &p->t);
 
-	f->mode = mode;
+err_destroy_ext:
+	tcf_exts_destroy(tp, &p->e);
+
+err_free_config:
+	kfree(p);
+	return err;
+}
 
-	if (tb[TCA_FLOW_MASK])
-		f->mask = nla_get_u32(tb[TCA_FLOW_MASK]);
-	if (tb[TCA_FLOW_XOR])
-		f->xor = nla_get_u32(tb[TCA_FLOW_XOR]);
-	if (tb[TCA_FLOW_RSHIFT])
-		f->rshift = nla_get_u32(tb[TCA_FLOW_RSHIFT]);
-	if (tb[TCA_FLOW_ADDEND])
-		f->addend = nla_get_u32(tb[TCA_FLOW_ADDEND]);
+static void flow_commit_change(struct tcf_proto *tp, unsigned long base,
+			       u32 handle, struct nlattr **tca,
+			       unsigned long arg)
+{
+	struct flow_head *head = tp->root;
+	struct flow_pending_config *p;
+	struct flow_filter *f;
 
-	if (tb[TCA_FLOW_DIVISOR])
-		f->divisor = nla_get_u32(tb[TCA_FLOW_DIVISOR]);
-	if (baseclass)
-		f->baseclass = baseclass;
+	f = (struct flow_filter *) arg;
 
-	if (*arg == 0)
+	p = head->pending_config;
+	head->pending_config = NULL;
+	BUG_ON(!p);
+
+	tcf_exts_change(tp, &f->exts, &p->e);
+	tcf_em_tree_change(tp, &f->ematches, &p->t);
+
+	tcf_tree_lock(tp);
+
+	if (p->flags & FLAG_FLOW_KEYS) {
+		f->keymask = p->keymask;
+		f->nkeys   = p->nkeys;
+	}
+
+	f->mode = p->mode;
+
+	if (p->flags & FLAG_FLOW_MASK)
+		f->mask = p->mask;
+	if (p->flags & FLAG_FLOW_XOR)
+		f->xor = p->xor;
+	if (p->flags & FLAG_FLOW_RSHIFT)
+		f->rshift = p->rshift;
+	if (p->flags & FLAG_FLOW_ADDEND)
+		f->addend = p->addend;
+	if (p->flags & FLAG_FLOW_DIVISOR)
+		f->divisor = p->divisor;
+	if (p->baseclass)
+		f->baseclass = p->baseclass;
+
+	if (p->new_f)
 		list_add_tail(&f->list, &head->filters);
 
 	tcf_tree_unlock(tp);
 
-	*arg = (unsigned long)f;
-	return 0;
+	kfree(p);
+}
 
-err2:
-	tcf_em_tree_destroy(tp, &t);
-err1:
-	tcf_exts_destroy(tp, &e);
-	return err;
+static void flow_cancel_change(struct tcf_proto *tp, unsigned long base,
+			       u32 handle, struct nlattr **tca,
+			       unsigned long arg)
+{
+	struct flow_head *head = tp->root;
+	struct flow_pending_config *p;
+
+	p = head->pending_config;
+	head->pending_config = NULL;
+	BUG_ON(!p);
+
+	if (p->new_f) {
+		kfree(p->new_f);
+		p->new_f = NULL;
+	}
+
+	tcf_em_tree_destroy(tp, &p->t);
+	tcf_exts_destroy(tp, &p->e);
+
+	kfree(p);
 }
 
 static void flow_destroy_filter(struct tcf_proto *tp, struct flow_filter *f)
@@ -517,7 +603,12 @@ static void flow_destroy_filter(struct tcf_proto *tp, struct flow_filter *f)
 	kfree(f);
 }
 
-static int flow_delete(struct tcf_proto *tp, unsigned long arg)
+static int flow_validate_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	return 0;
+}
+
+static void flow_commit_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct flow_filter *f = (struct flow_filter *)arg;
 
@@ -525,7 +616,6 @@ static int flow_delete(struct tcf_proto *tp, unsigned long arg)
 	list_del(&f->list);
 	tcf_tree_unlock(tp);
 	flow_destroy_filter(tp, f);
-	return 0;
 }
 
 static int flow_init(struct tcf_proto *tp)
@@ -646,8 +736,11 @@ static struct tcf_proto_ops cls_flow_ops __read_mostly = {
 	.classify	= flow_classify,
 	.init		= flow_init,
 	.destroy	= flow_destroy,
-	.change		= flow_change,
-	.delete		= flow_delete,
+	.validate_change= flow_validate_change,
+	.commit_change	= flow_commit_change,
+	.cancel_change	= flow_cancel_change,
+	.validate_delete= flow_validate_delete,
+	.commit_delete	= flow_commit_delete,
 	.get		= flow_get,
 	.put		= flow_put,
 	.dump		= flow_dump,
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index b0f90e5..3810abc 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -32,8 +32,10 @@
 
 struct fw_head
 {
-	struct fw_filter *ht[HTSIZE];
-	u32 mask;
+	struct fw_filter	*ht[HTSIZE];
+	u32			mask;
+
+	void			*pending_config;
 };
 
 struct fw_filter
@@ -164,26 +166,36 @@ static void fw_destroy(struct tcf_proto *tp)
 	kfree(head);
 }
 
-static int fw_delete(struct tcf_proto *tp, unsigned long arg)
+static int fw_validate_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct fw_head *head = (struct fw_head*)tp->root;
+	struct fw_filter *f1, *f = (struct fw_filter*)arg;
+
+	if (!head || !f)
+		return -EINVAL;
+
+	for (f1 = head->ht[fw_hash(f->id)]; f1; f1 = f1->next) {
+		if (f1 == f)
+			return 0;
+	}
+	return -EINVAL;
+}
+
+static void fw_commit_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct fw_head *head = (struct fw_head*)tp->root;
 	struct fw_filter *f = (struct fw_filter*)arg;
 	struct fw_filter **fp;
 
-	if (head == NULL || f == NULL)
-		goto out;
-
-	for (fp=&head->ht[fw_hash(f->id)]; *fp; fp = &(*fp)->next) {
+	for (fp = &head->ht[fw_hash(f->id)]; *fp; fp = &(*fp)->next) {
 		if (*fp == f) {
 			tcf_tree_lock(tp);
 			*fp = f->next;
 			tcf_tree_unlock(tp);
 			fw_delete_filter(tp, f);
-			return 0;
+			return;
 		}
 	}
-out:
-	return -EINVAL;
 }
 
 static const struct nla_policy fw_policy[TCA_FW_MAX + 1] = {
@@ -192,76 +204,94 @@ static const struct nla_policy fw_policy[TCA_FW_MAX + 1] = {
 	[TCA_FW_MASK]		= { .type = NLA_U32 },
 };
 
-static int
-fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
-	struct nlattr **tb, struct nlattr **tca, unsigned long base)
+struct fw_pending_config {
+	struct tcf_exts		ext;
+	struct fw_filter	*new_filter;
+	u32			classid;
+	int			new;
+	char			indev[IFNAMSIZ];
+	unsigned int		flags;
+#define FLAG_HAVE_CLASSID	0x00000001
+#define FLAG_HAVE_INDEV		0x00000002
+};
+
+static int fw_validate_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
+				    struct fw_pending_config *p,
+				    struct nlattr **tb, struct nlattr **tca,
+				    unsigned long base)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
-	struct tcf_exts e;
-	u32 mask;
+	struct fw_head *head = (struct fw_head *) tp->root;
 	int err;
 
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &fw_ext_map);
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &p->ext, &fw_ext_map);
 	if (err < 0)
 		return err;
 
-	err = -EINVAL;
 	if (tb[TCA_FW_CLASSID]) {
-		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
-		tcf_bind_filter(tp, &f->res, base);
+		p->classid = nla_get_u32(tb[TCA_FW_CLASSID]);
+		p->flags |= FLAG_HAVE_CLASSID;
 	}
 
+	err = -EINVAL;
+
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_FW_INDEV]) {
-		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV]);
-		if (err < 0)
-			goto errout;
+		if (nla_len(tb[TCA_FW_INDEV]) >= IFNAMSIZ)
+			goto err_destroy;
+		nla_strlcpy(p->indev, tb[TCA_FW_INDEV], IFNAMSIZ);
+		p->flags |= FLAG_HAVE_INDEV;
 	}
 #endif /* CONFIG_NET_CLS_IND */
 
 	if (tb[TCA_FW_MASK]) {
-		mask = nla_get_u32(tb[TCA_FW_MASK]);
+		u32 mask = nla_get_u32(tb[TCA_FW_MASK]);
 		if (mask != head->mask)
-			goto errout;
+			goto err_destroy;
 	} else if (head->mask != 0xFFFFFFFF)
-		goto errout;
-
-	tcf_exts_change(tp, &f->exts, &e);
+		goto err_destroy;
 
 	return 0;
-errout:
-	tcf_exts_destroy(tp, &e);
+
+err_destroy:
+	tcf_exts_destroy(tp, &p->ext);
 	return err;
 }
 
-static int fw_change(struct tcf_proto *tp, unsigned long base,
-		     u32 handle,
-		     struct nlattr **tca,
-		     unsigned long *arg)
+static void fw_commit_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
+				   struct fw_pending_config *p,
+				   unsigned long base)
 {
-	struct fw_head *head = (struct fw_head*)tp->root;
-	struct fw_filter *f = (struct fw_filter *) *arg;
-	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct nlattr *tb[TCA_FW_MAX + 1];
-	int err;
+	if (p->flags & FLAG_HAVE_CLASSID) {
+		f->res.classid = p->classid;
+		tcf_bind_filter(tp, &f->res, base);
+	}
 
-	if (!opt)
-		return handle ? -EINVAL : 0;
+#ifdef CONFIG_NET_CLS_IND
+	if (p->flags & FLAG_HAVE_INDEV)
+		strlcpy(f->indev, p->indev, IFNAMSIZ);
+#endif /* CONFIG_NET_CLS_IND */
 
-	err = nla_parse_nested(tb, TCA_FW_MAX, opt, fw_policy);
-	if (err < 0)
-		return err;
+	tcf_exts_change(tp, &f->exts, &p->ext);
+}
 
-	if (f != NULL) {
-		if (f->id != handle && handle)
-			return -EINVAL;
-		return fw_change_attrs(tp, f, tb, tca, base);
-	}
+static void fw_cancel_change_attrs(struct tcf_proto *tp,
+				   struct fw_pending_config *p)
+{
+	tcf_exts_destroy(tp, &p->ext);
+}
 
-	if (!handle)
-		return -EINVAL;
+static int fw_validate_change(struct tcf_proto *tp, unsigned long base,
+			      u32 handle, struct nlattr **tca,
+			      unsigned long *arg)
+{
+	struct fw_filter *f = (struct fw_filter *) *arg;
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_FW_MAX + 1];
+	struct fw_head *head = tp->root;
+	struct fw_pending_config *p;
+	int err;
 
-	if (head == NULL) {
+	if (!head) {
 		u32 mask = 0xFFFFFFFF;
 		if (tb[TCA_FW_MASK])
 			mask = nla_get_u32(tb[TCA_FW_MASK]);
@@ -276,29 +306,115 @@ static int fw_change(struct tcf_proto *tp, unsigned long base,
 		tcf_tree_unlock(tp);
 	}
 
+	if (!opt)
+		return handle ? -EINVAL : 0;
+
+	err = nla_parse_nested(tb, TCA_FW_MAX, opt, fw_policy);
+	if (err < 0)
+		return err;
+
+	BUG_ON(head->pending_config);
+
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	err = -EINVAL;
+	if (f) {
+		if (f->id != handle && handle)
+			goto err_free_config;
+		err = fw_validate_change_attrs(tp, f, p, tb, tca, base);
+		if (err)
+			goto err_free_config;
+		goto success;
+	}
+
+	if (!handle)
+		goto err_free_config;
+
 	f = kzalloc(sizeof(struct fw_filter), GFP_KERNEL);
-	if (f == NULL)
-		return -ENOBUFS;
+	err = -ENOBUFS;
+	if (!f)
+		goto err_free_config;
 
 	f->id = handle;
 
-	err = fw_change_attrs(tp, f, tb, tca, base);
+	err = fw_validate_change_attrs(tp, f, p, tb, tca, base);
 	if (err < 0)
-		goto errout;
+		goto err_free_filter;
 
-	f->next = head->ht[fw_hash(handle)];
-	tcf_tree_lock(tp);
-	head->ht[fw_hash(handle)] = f;
-	tcf_tree_unlock(tp);
+	p->new_filter = f;
 
-	*arg = (unsigned long)f;
+success:
+	head->pending_config = p;
+	*arg = (unsigned long) f;
 	return 0;
 
-errout:
+err_free_filter:
 	kfree(f);
+
+err_free_config:
+	kfree(p);
 	return err;
 }
 
+static void fw_commit_change(struct tcf_proto *tp, unsigned long base,
+			     u32 handle, struct nlattr **tca,
+			     unsigned long arg)
+{
+	struct fw_filter *f = (struct fw_filter *) arg;
+	struct fw_head *head = tp->root;
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct fw_pending_config *p;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!head->pending_config);
+
+	p = head->pending_config;
+	head->pending_config = NULL;
+
+	if (!p->new_filter) {
+		fw_commit_change_attrs(tp, f, p, base);
+	} else {
+		fw_commit_change_attrs(tp, f, p, base);
+
+		f->next = head->ht[fw_hash(f->id)];
+		tcf_tree_lock(tp);
+		head->ht[fw_hash(f->id)] = f;
+		tcf_tree_unlock(tp);
+	}
+
+	kfree(p);
+}
+
+static void fw_cancel_change(struct tcf_proto *tp, unsigned long base,
+			     u32 handle, struct nlattr **tca,
+			     unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct fw_head *head = tp->root;
+	struct fw_pending_config *p;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!head->pending_config);
+
+	p = head->pending_config;
+	head->pending_config = NULL;
+
+	fw_cancel_change_attrs(tp, p);
+
+	if (p->new_filter) {
+		kfree(p->new_filter);
+		p->new_filter = NULL;
+	}
+
+	kfree(p);
+}
+
 static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
 	struct fw_head *head = (struct fw_head*)tp->root;
@@ -378,8 +494,11 @@ static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.destroy	=	fw_destroy,
 	.get		=	fw_get,
 	.put		=	fw_put,
-	.change		=	fw_change,
-	.delete		=	fw_delete,
+	.validate_change=	fw_validate_change,
+	.commit_change	=	fw_commit_change,
+	.cancel_change	=	fw_cancel_change,
+	.validate_delete=	fw_validate_delete,
+	.commit_delete	=	fw_commit_delete,
 	.walk		=	fw_walk,
 	.dump		=	fw_dump,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 5a16ca2..aa40f05 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -40,6 +40,8 @@ struct route4_head
 {
 	struct route4_fastmap	fastmap[16];
 	struct route4_bucket	*table[256+1];
+
+	void			*pending_config;
 };
 
 struct route4_bucket
@@ -282,17 +284,25 @@ static void route4_destroy(struct tcf_proto *tp)
 	kfree(head);
 }
 
-static int route4_delete(struct tcf_proto *tp, unsigned long arg)
+static int route4_validate_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct route4_head *head = (struct route4_head*)tp->root;
-	struct route4_filter **fp, *f = (struct route4_filter*)arg;
-	unsigned h = 0;
-	struct route4_bucket *b;
-	int i;
+	struct route4_filter *f = (struct route4_filter*)arg;
 
 	if (!head || !f)
 		return -EINVAL;
 
+	return 0;
+}
+
+static void route4_commit_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct route4_head *head = (struct route4_head*)tp->root;
+	struct route4_filter **fp, *f = (struct route4_filter*)arg;
+	struct route4_bucket *b;
+	unsigned h = 0;
+	int i;
+
 	h = f->handle;
 	b = f->bkt;
 
@@ -309,7 +319,7 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 
 			for (i=0; i<=32; i++)
 				if (b->ht[i])
-					return 0;
+					return;
 
 			/* OK, session has no flows */
 			tcf_tree_lock(tp);
@@ -317,10 +327,8 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 			tcf_tree_unlock(tp);
 
 			kfree(b);
-			return 0;
 		}
 	}
-	return 0;
 }
 
 static const struct nla_policy route4_policy[TCA_ROUTE4_MAX + 1] = {
@@ -330,50 +338,73 @@ static const struct nla_policy route4_policy[TCA_ROUTE4_MAX + 1] = {
 	[TCA_ROUTE4_IIF]	= { .type = NLA_U32 },
 };
 
-static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
-	struct route4_filter *f, u32 handle, struct route4_head *head,
-	struct nlattr **tb, struct nlattr *est, int new)
+struct route4_pending_config {
+	struct tcf_exts		ext;
+	u32			to;
+	u32			id;
+	u32			handle;
+	u32			classid;
+	unsigned int		flags;
+#define FLAG_HAVE_TO		0x00000001
+#define FLAG_HAVE_FROM		0x00000002
+#define FLAG_HAVE_IIF		0x00000004
+#define FLAG_HAVE_CLASSID	0x00000004
+	int			new;
+	struct route4_bucket	*bucket;
+};
+
+static int route4_validate_parms(struct tcf_proto *tp, unsigned long base,
+				 struct route4_pending_config *p,
+				 struct route4_filter *f, u32 handle,
+				 struct route4_head *head, struct nlattr **tb,
+				 struct nlattr *est, int new)
 {
-	int err;
 	u32 id = 0, to = 0, nhandle = 0x8000;
-	struct route4_filter *fp;
-	unsigned int h1;
 	struct route4_bucket *b;
-	struct tcf_exts e;
+	unsigned int h1;
+	int err;
 
-	err = tcf_exts_validate(tp, tb, est, &e, &route_ext_map);
+	err = tcf_exts_validate(tp, tb, est, &p->ext, &route_ext_map);
 	if (err < 0)
 		return err;
 
 	err = -EINVAL;
 	if (tb[TCA_ROUTE4_TO]) {
-		if (new && handle & 0x8000)
-			goto errout;
+		if (new && (handle & 0x8000))
+			goto err_destroy;
 		to = nla_get_u32(tb[TCA_ROUTE4_TO]);
 		if (to > 0xFF)
-			goto errout;
+			goto err_destroy;
 		nhandle = to;
+		p->flags |= FLAG_HAVE_TO;
 	}
 
 	if (tb[TCA_ROUTE4_FROM]) {
 		if (tb[TCA_ROUTE4_IIF])
-			goto errout;
+			goto err_destroy;
 		id = nla_get_u32(tb[TCA_ROUTE4_FROM]);
 		if (id > 0xFF)
-			goto errout;
+			goto err_destroy;
 		nhandle |= id << 16;
+		p->flags |= FLAG_HAVE_FROM;
 	} else if (tb[TCA_ROUTE4_IIF]) {
 		id = nla_get_u32(tb[TCA_ROUTE4_IIF]);
 		if (id > 0x7FFF)
-			goto errout;
+			goto err_destroy;
 		nhandle |= (id | 0x8000) << 16;
+		p->flags |= FLAG_HAVE_IIF;
 	} else
 		nhandle |= 0xFFFF << 16;
 
 	if (handle && new) {
-		nhandle |= handle & 0x7F00;
+		nhandle |= (handle & 0x7F00);
 		if (nhandle != handle)
-			goto errout;
+			goto err_destroy;
+	}
+
+	if (tb[TCA_ROUTE4_CLASSID]) {
+		p->classid = nla_get_u32(tb[TCA_ROUTE4_CLASSID]);
+		p->flags |= FLAG_HAVE_CLASSID;
 	}
 
 	h1 = to_hash(nhandle);
@@ -381,113 +412,161 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 		err = -ENOBUFS;
 		b = kzalloc(sizeof(struct route4_bucket), GFP_KERNEL);
 		if (b == NULL)
-			goto errout;
+			goto err_destroy;
 
 		tcf_tree_lock(tp);
 		head->table[h1] = b;
 		tcf_tree_unlock(tp);
 	} else {
 		unsigned int h2 = from_hash(nhandle >> 16);
+		struct route4_filter *fp;
+
 		err = -EEXIST;
 		for (fp = b->ht[h2]; fp; fp = fp->next)
 			if (fp->handle == f->handle)
-				goto errout;
+				goto err_destroy;
 	}
 
+	p->to = to;
+	p->id = id;
+	p->handle = nhandle;
+	p->bucket = b;
+
+	return 0;
+
+err_destroy:
+	tcf_exts_destroy(tp, &p->ext);
+	return err;
+}
+
+static void route4_commit_parms(struct tcf_proto *tp, unsigned long base,
+				struct route4_pending_config *p,
+				struct route4_filter *f, int new)
+{
 	tcf_tree_lock(tp);
-	if (tb[TCA_ROUTE4_TO])
-		f->id = to;
+	if (p->flags & FLAG_HAVE_TO)
+		f->id = p->to;
+
+	if (p->flags & FLAG_HAVE_FROM)
+		f->id = (p->to | (p->id << 16));
+	else if (p->flags & FLAG_HAVE_IIF)
+		f->iif = p->id;
 
-	if (tb[TCA_ROUTE4_FROM])
-		f->id = to | id<<16;
-	else if (tb[TCA_ROUTE4_IIF])
-		f->iif = id;
+	f->handle = p->handle;
+
+	f->bkt = p->bucket;
+	p->bucket = NULL;
 
-	f->handle = nhandle;
-	f->bkt = b;
 	tcf_tree_unlock(tp);
 
-	if (tb[TCA_ROUTE4_CLASSID]) {
-		f->res.classid = nla_get_u32(tb[TCA_ROUTE4_CLASSID]);
+	if (p->flags & FLAG_HAVE_CLASSID) {
+		f->res.classid = p->classid;
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_exts_change(tp, &f->exts, &p->ext);
+}
 
-	return 0;
-errout:
-	tcf_exts_destroy(tp, &e);
-	return err;
+static void route4_cancel_parms(struct tcf_proto *tp, struct route4_pending_config *p)
+{
+	if (p->bucket) {
+		kfree(p->bucket);
+		p->bucket = NULL;
+	}
+
+	tcf_exts_destroy(tp, &p->ext);
 }
 
-static int route4_change(struct tcf_proto *tp, unsigned long base,
-		       u32 handle,
-		       struct nlattr **tca,
-		       unsigned long *arg)
+static int route4_validate_change(struct tcf_proto *tp, unsigned long base,
+				  u32 handle, struct nlattr **tca,
+				  unsigned long *arg)
 {
-	struct route4_head *head = tp->root;
-	struct route4_filter *f, *f1, **fp;
-	struct route4_bucket *b;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_ROUTE4_MAX + 1];
-	unsigned int h, th;
-	u32 old_handle = 0;
-	int err;
+	struct route4_head *head = tp->root;
+	struct route4_pending_config *p;
+	struct route4_filter *f;
+	int new, err;
 
-	if (opt == NULL)
+	if (!opt)
 		return handle ? -EINVAL : 0;
 
 	err = nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, route4_policy);
 	if (err < 0)
 		return err;
 
-	if ((f = (struct route4_filter*)*arg) != NULL) {
-		if (f->handle != handle && handle)
-			return -EINVAL;
-
-		if (f->bkt)
-			old_handle = f->handle;
-
-		err = route4_set_parms(tp, base, f, handle, head, tb,
-			tca[TCA_RATE], 0);
-		if (err < 0)
-			return err;
-
-		goto reinsert;
-	}
-
-	err = -ENOBUFS;
-	if (head == NULL) {
+	if (!head) {
 		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
-		if (head == NULL)
-			goto errout;
+		if (!head)
+			return -ENOBUFS;
 
 		tcf_tree_lock(tp);
 		tp->root = head;
 		tcf_tree_unlock(tp);
 	}
 
+	BUG_ON(head->pending_config);
+
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOBUFS;
+
+	f = (struct route4_filter *) *arg;
+	new = 0;
+	err = -EINVAL;
+	if (f) {
+		if (f->handle != handle && handle)
+			goto err_free_config;
+		goto parm_validate;
+	}
+
 	f = kzalloc(sizeof(struct route4_filter), GFP_KERNEL);
+	err = -ENOBUFS;
 	if (f == NULL)
-		goto errout;
+		goto err_free_config;
 
-	err = route4_set_parms(tp, base, f, handle, head, tb,
-		tca[TCA_RATE], 1);
-	if (err < 0)
-		goto errout;
+	new = 1;
+
+parm_validate:
+	p->new = new;
+	err = route4_validate_parms(tp, base, p, f, handle, head,
+				    tb, tca[TCA_RATE], new);
+	if (err)
+		goto err_free_filter;
+
+	head->pending_config = p;
+	*arg = (unsigned long) f;
+	return 0;
+
+err_free_filter:
+	kfree(f);
+
+err_free_config:
+	kfree(p);
+	return err;
+}
+
+static void route4_reinsert(struct tcf_proto *tp, struct route4_filter *f,
+			    u32 old_handle)
+{
+	unsigned int h = from_hash(f->handle >> 16);
+	struct route4_head *head = tp->root;
+	struct route4_filter *f1, **fp;
 
-reinsert:
-	h = from_hash(f->handle >> 16);
-	for (fp = &f->bkt->ht[h]; (f1=*fp) != NULL; fp = &f1->next)
+	for (fp = &f->bkt->ht[h]; (f1=*fp) != NULL; fp = &f1->next) {
 		if (f->handle < f1->handle)
 			break;
-
+	}
 	f->next = f1;
+
 	tcf_tree_lock(tp);
+
 	*fp = f;
 
 	if (old_handle && f->handle != old_handle) {
-		th = to_hash(old_handle);
+		unsigned int th = to_hash(old_handle);
+		struct route4_bucket *b;
+
 		h = from_hash(old_handle >> 16);
 		if ((b = head->table[th]) != NULL) {
 			for (fp = &b->ht[h]; *fp; fp = &(*fp)->next) {
@@ -498,15 +577,62 @@ reinsert:
 			}
 		}
 	}
+
 	tcf_tree_unlock(tp);
+}
+
+static void route4_commit_change(struct tcf_proto *tp, unsigned long base,
+				 u32 handle, struct nlattr **tca,
+				 unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct route4_head *head = tp->root;
+	struct route4_pending_config *p;
+	struct route4_filter *f;
+	u32 old_handle = 0;
 
+	if (!opt)
+		return;
+
+	BUG_ON(!head->pending_config);
+	p = head->pending_config;
+	head->pending_config = NULL;
+
+	f = (struct route4_filter *) arg;
+	if (!p->new) {
+		if (f->bkt)
+			old_handle = f->handle;
+	}
+	route4_commit_parms(tp, base, p, f, p->new);
+	route4_reinsert(tp, f, old_handle);
 	route4_reset_fastmap(qdisc_dev(tp->q), head, f->id);
-	*arg = (unsigned long)f;
-	return 0;
 
-errout:
-	kfree(f);
-	return err;
+	kfree(p);
+}
+
+static void route4_cancel_change(struct tcf_proto *tp, unsigned long base,
+				 u32 handle, struct nlattr **tca,
+				 unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct route4_head *head = tp->root;
+	struct route4_pending_config *p;
+	struct route4_filter *f;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!head->pending_config);
+	p = head->pending_config;
+	head->pending_config = NULL;
+
+	route4_cancel_parms(tp, p);
+
+	f = (struct route4_filter *) arg;
+	if (p->new)
+		kfree(f);
+
+	kfree(p);
 }
 
 static void route4_walk(struct tcf_proto *tp, struct tcf_walker *arg)
@@ -596,8 +722,11 @@ static struct tcf_proto_ops cls_route4_ops __read_mostly = {
 	.destroy	=	route4_destroy,
 	.get		=	route4_get,
 	.put		=	route4_put,
-	.change		=	route4_change,
-	.delete		=	route4_delete,
+	.validate_change=	route4_validate_change,
+	.commit_change	=	route4_commit_change,
+	.cancel_change	=	route4_cancel_change,
+	.validate_delete=	route4_validate_delete,
+	.commit_delete	=	route4_commit_delete,
 	.walk		=	route4_walk,
 	.dump		=	route4_dump,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 7034ea4..16ac4c3 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -72,6 +72,8 @@ struct rsvp_head
 	u32			hgenerator;
 	u8			tgenerator;
 	struct rsvp_session	*ht[256];
+
+	void			*pending_config;
 };
 
 struct rsvp_session
@@ -287,7 +289,12 @@ static void rsvp_destroy(struct tcf_proto *tp)
 	kfree(data);
 }
 
-static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
+static int rsvp_validate_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	return 0;
+}
+
+static void rsvp_commit_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct rsvp_filter **fp, *f = (struct rsvp_filter*)arg;
 	unsigned h = f->handle;
@@ -304,9 +311,11 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 
 			/* Strip tree */
 
-			for (i=0; i<=16; i++)
-				if (s->ht[i])
-					return 0;
+			for (i=0; i<=16; i++) {
+				if (s->ht[i]) {
+					return;
+				}
+			}
 
 			/* OK, session has no flows */
 			for (sp = &((struct rsvp_head*)tp->root)->ht[h&0xFF];
@@ -317,14 +326,13 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 					tcf_tree_unlock(tp);
 
 					kfree(s);
-					return 0;
+					return;
 				}
 			}
 
-			return 0;
+			return;
 		}
 	}
-	return 0;
 }
 
 static unsigned gen_handle(struct tcf_proto *tp, unsigned salt)
@@ -406,88 +414,104 @@ static const struct nla_policy rsvp_policy[TCA_RSVP_MAX + 1] = {
 	[TCA_RSVP_PINFO]	= { .len = sizeof(struct tc_rsvp_pinfo) },
 };
 
-static int rsvp_change(struct tcf_proto *tp, unsigned long base,
-		       u32 handle,
-		       struct nlattr **tca,
-		       unsigned long *arg)
+struct rsvp_pending_config {
+	struct rsvp_session	*session;
+	struct rsvp_filter	*filter;
+	struct tcf_exts		ext;
+	u32			classid;
+	unsigned int		h1;
+	unsigned int		h2;
+	unsigned int		flags;
+#define FLAG_HAVE_CLASSID	0x00000001
+#define FLAG_NEW_SESSION	0x00000002
+#define FLAG_NEW_FILTER		0x00000004
+};
+
+static int rsvp_validate_change(struct tcf_proto *tp, unsigned long base,
+				u32 handle, struct nlattr **tca,
+				unsigned long *arg)
 {
-	struct rsvp_head *data = tp->root;
-	struct rsvp_filter *f, **fp;
-	struct rsvp_session *s, **sp;
-	struct tc_rsvp_pinfo *pinfo = NULL;
 	struct nlattr *opt = tca[TCA_OPTIONS-1];
 	struct nlattr *tb[TCA_RSVP_MAX + 1];
-	struct tcf_exts e;
-	unsigned h1, h2;
+	struct rsvp_head *data = tp->root;
+	struct rsvp_pending_config *p;
+	struct rsvp_session *s, **sp;
+	struct tc_rsvp_pinfo *pinfo;
+	struct rsvp_filter *f;
+	unsigned int h1, h2;
 	__be32 *dst;
 	int err;
 
-	if (opt == NULL)
+	if (!opt)
 		return handle ? -EINVAL : 0;
 
 	err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, rsvp_policy);
 	if (err < 0)
 		return err;
 
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &rsvp_ext_map);
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &p->ext, &rsvp_ext_map);
 	if (err < 0)
-		return err;
+		goto err_free_config;
 
-	if ((f = (struct rsvp_filter*)*arg) != NULL) {
-		/* Node exists: adjust only classid */
+	if (tb[TCA_RSVP_CLASSID-1]) {
+		p->classid = nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
+		p->flags |= FLAG_HAVE_CLASSID;
+	}
 
+	f = (struct rsvp_filter *) *arg;
+	if (f) {
 		if (f->handle != handle && handle)
-			goto errout2;
-		if (tb[TCA_RSVP_CLASSID-1]) {
-			f->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
-			tcf_bind_filter(tp, &f->res, base);
-		}
-
-		tcf_exts_change(tp, &f->exts, &e);
+			goto err_destroy;
 		return 0;
 	}
 
-	/* Now more serious part... */
 	err = -EINVAL;
-	if (handle)
-		goto errout2;
-	if (tb[TCA_RSVP_DST-1] == NULL)
-		goto errout2;
+	if (handle || !tb[TCA_RSVP_DST-1])
+		goto err_destroy;
 
 	err = -ENOBUFS;
 	f = kzalloc(sizeof(struct rsvp_filter), GFP_KERNEL);
-	if (f == NULL)
-		goto errout2;
+	if (!f)
+		goto err_destroy;
 
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC-1]) {
 		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC-1]), sizeof(f->src));
 		h2 = hash_src(f->src);
 	}
+
+	pinfo = NULL;
 	if (tb[TCA_RSVP_PINFO-1]) {
 		pinfo = nla_data(tb[TCA_RSVP_PINFO-1]);
 		f->spi = pinfo->spi;
 		f->tunnelhdr = pinfo->tunnelhdr;
 	}
-	if (tb[TCA_RSVP_CLASSID-1])
-		f->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
+
+	if (p->flags & FLAG_HAVE_CLASSID)
+		f->res.classid = p->classid;
 
 	dst = nla_data(tb[TCA_RSVP_DST-1]);
-	h1 = hash_dst(dst, pinfo ? pinfo->protocol : 0, pinfo ? pinfo->tunnelid : 0);
+	h1 = hash_dst(dst,
+		      pinfo ? pinfo->protocol : 0,
+		      pinfo ? pinfo->tunnelid : 0);
 
 	err = -ENOMEM;
 	if ((f->handle = gen_handle(tp, h1 | (h2<<8))) == 0)
-		goto errout;
+		goto err_free_filter;
 
 	if (f->tunnelhdr) {
 		err = -EINVAL;
 		if (f->res.classid > 255)
-			goto errout;
+			goto err_free_filter;
 
 		err = -ENOMEM;
 		if (f->res.classid == 0 &&
 		    (f->res.classid = gen_tunnel(data)) == 0)
-			goto errout;
+			goto err_free_filter;
 	}
 
 	for (sp = &data->ht[h1]; (s=*sp) != NULL; sp = &s->next) {
@@ -500,43 +524,48 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 		    && dst[2] == s->dst[2]
 #endif
 		    && pinfo->tunnelid == s->tunnelid) {
-
-insert:
-			/* OK, we found appropriate session */
-
-			fp = &s->ht[h2];
-
-			f->sess = s;
-			if (f->tunnelhdr == 0)
-				tcf_bind_filter(tp, &f->res, base);
-
-			tcf_exts_change(tp, &f->exts, &e);
-
-			for (fp = &s->ht[h2]; *fp; fp = &(*fp)->next)
-				if (((*fp)->spi.mask&f->spi.mask) != f->spi.mask)
-					break;
-			f->next = *fp;
-			wmb();
-			*fp = f;
-
-			*arg = (unsigned long)f;
-			return 0;
+			goto success;
 		}
 	}
 
 	/* No session found. Create new one. */
-
 	err = -ENOBUFS;
 	s = kzalloc(sizeof(struct rsvp_session), GFP_KERNEL);
-	if (s == NULL)
-		goto errout;
-	memcpy(s->dst, dst, sizeof(s->dst));
+	if (!s)
+		goto err_free_filter;
 
+	memcpy(s->dst, dst, sizeof(s->dst));
 	if (pinfo) {
 		s->dpi = pinfo->dpi;
 		s->protocol = pinfo->protocol;
 		s->tunnelid = pinfo->tunnelid;
 	}
+	p->flags |= FLAG_NEW_SESSION;
+
+success:
+	p->flags |= FLAG_NEW_FILTER;
+	p->session = s;
+	p->h1 = h1;
+	p->h2 = h2;
+	*arg = (unsigned long) f;
+	return 0;
+
+err_free_filter:
+	kfree(f);
+
+err_destroy:
+	tcf_exts_destroy(tp, &p->ext);
+
+err_free_config:
+	kfree(p);
+	return err;
+}
+
+static void rsvp_link_new_session(struct rsvp_head *data, unsigned int h1,
+				  struct rsvp_session *s)
+{
+	struct rsvp_session **sp;
+
 	for (sp = &data->ht[h1]; *sp; sp = &(*sp)->next) {
 		if (((*sp)->dpi.mask&s->dpi.mask) != s->dpi.mask)
 			break;
@@ -544,14 +573,88 @@ insert:
 	s->next = *sp;
 	wmb();
 	*sp = s;
+}
+
+static void rsvp_commit_change(struct tcf_proto *tp, unsigned long base,
+			       u32 handle, struct nlattr **tca,
+			       unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS-1];
+	struct rsvp_head *data = tp->root;
+	struct rsvp_filter *f, **fp;
+	struct rsvp_pending_config *p;
+	struct rsvp_session *s;
+	unsigned int h1, h2;
 
-	goto insert;
+	if (!opt)
+		return;
 
-errout:
-	kfree(f);
-errout2:
-	tcf_exts_destroy(tp, &e);
-	return err;
+	BUG_ON(!data->pending_config);
+	p = data->pending_config;
+	data->pending_config = NULL;	
+
+	f = (struct rsvp_filter *) arg;
+	if (!(p->flags & FLAG_NEW_FILTER)) {
+		if (p->flags & FLAG_HAVE_CLASSID) {
+			f->res.classid = p->classid;
+			tcf_bind_filter(tp, &f->res, base);
+		}
+
+		tcf_exts_change(tp, &f->exts, &p->ext);
+	} else {
+		s = p->session;
+		h1 = p->h1;
+		if (p->flags & FLAG_NEW_SESSION)
+			rsvp_link_new_session(data, h1, s);
+
+		h2 = p->h2;
+		fp = &s->ht[h2];
+		f->sess = s;
+		if (f->tunnelhdr == 0)
+			tcf_bind_filter(tp, &f->res, base);
+
+		tcf_exts_change(tp, &f->exts, &p->ext);
+
+		for (fp = &s->ht[h2]; *fp; fp = &(*fp)->next)
+			if (((*fp)->spi.mask&f->spi.mask) != f->spi.mask)
+				break;
+
+		f->next = *fp;
+		wmb();
+		*fp = f;
+	}
+
+	kfree(p);
+}
+
+static void rsvp_cancel_change(struct tcf_proto *tp, unsigned long base,
+			       u32 handle, struct nlattr **tca,
+			       unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS-1];
+	struct rsvp_head *data = tp->root;
+	struct rsvp_pending_config *p;
+	struct rsvp_filter *f;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!data->pending_config);
+	p = data->pending_config;
+	data->pending_config = NULL;
+
+	tcf_exts_destroy(tp, &p->ext);
+
+	f = (struct rsvp_filter *) arg;
+	if (p->flags & FLAG_NEW_FILTER)
+		kfree(f);
+
+	if (p->flags & FLAG_NEW_SESSION) {
+		kfree(p->session);
+		p->session = NULL;
+	}
+
+	kfree(p);
 }
 
 static void rsvp_walk(struct tcf_proto *tp, struct tcf_walker *arg)
@@ -639,8 +742,11 @@ static struct tcf_proto_ops RSVP_OPS = {
 	.destroy	=	rsvp_destroy,
 	.get		=	rsvp_get,
 	.put		=	rsvp_put,
-	.change		=	rsvp_change,
-	.delete		=	rsvp_delete,
+	.validate_change=	rsvp_validate_change,
+	.commit_change	=	rsvp_commit_change,
+	.cancel_change	=	rsvp_cancel_change,
+	.validate_delete=	rsvp_validate_delete,
+	.commit_delete	=	rsvp_commit_delete,
 	.walk		=	rsvp_walk,
 	.dump		=	rsvp_dump,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 7a7bff5..f24234d 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -43,7 +43,6 @@ struct tcindex_filter {
 	struct tcindex_filter *next;
 };
 
-
 struct tcindex_data {
 	struct tcindex_filter_result *perfect; /* perfect hash; NULL if none */
 	struct tcindex_filter **h; /* imperfect hash; only used if !perfect;
@@ -53,6 +52,8 @@ struct tcindex_data {
 	int hash;		/* hash table size; 0 if undefined */
 	int alloc_hash;		/* allocated size */
 	int fall_through;	/* 0: only classify if explicit match */
+
+	void				*pending_config;
 };
 
 static const struct tcf_ext_map tcindex_ext_map = {
@@ -83,7 +84,6 @@ tcindex_lookup(struct tcindex_data *p, u16 key)
 	return NULL;
 }
 
-
 static int tcindex_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
@@ -182,13 +182,53 @@ found:
 	return 0;
 }
 
-static int tcindex_delete(struct tcf_proto *tp, unsigned long arg)
+static int tcindex_validate_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	return __tcindex_delete(tp, arg, 1);
+	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
+	struct tcindex_data *p = PRIV(tp);
+
+	if (p->perfect) {
+		if (!r->res.class)
+			return -ENOENT;
+	} else {
+		struct tcindex_filter **walk = NULL;
+		int i;
+
+		for (i = 0; i < p->hash; i++)
+			for (walk = p->h+i; *walk; walk = &(*walk)->next)
+				if (&(*walk)->result == r)
+					goto found;
+		return -ENOENT;
+	}
+found:
+	return 0;
 }
 
-static inline int
-valid_perfect_hash(struct tcindex_data *p)
+static void tcindex_commit_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
+	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_filter *f, **walk;
+	int i;
+
+	if (p->perfect)
+		return;
+
+	for (i = 0; i < p->hash; i++) {
+		for (walk = p->h+i; *walk; walk = &(*walk)->next) {
+			if (&(*walk)->result == r) {
+				f = *walk;
+				tcf_tree_lock(tp);
+				*walk = f->next;
+				tcf_tree_unlock(tp);
+				return;
+			}
+		}
+	}
+
+}
+
+static int valid_perfect_hash(struct tcindex_data *p)
 {
 	return  p->hash > (p->mask >> p->shift);
 }
@@ -201,155 +241,198 @@ static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
 	[TCA_TCINDEX_CLASSID]		= { .type = NLA_U32 },
 };
 
-static int
-tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
-		  struct tcindex_data *p, struct tcindex_filter_result *r,
-		  struct nlattr **tb, struct nlattr *est)
+
+struct tcindex_pending_config {
+	struct tcindex_filter_result	new_filter_result;
+	struct tcindex_filter_result	*r;
+	struct tcindex_filter_result	cr;
+	struct tcindex_filter		*f;
+	struct tcindex_data		cp;
+	struct tcf_exts			ext;
+	int				balloc;
+};
+
+static int tcindex_validate_parms(struct tcf_proto *tp, unsigned long base,
+				  u32 handle, struct tcindex_data *dp,
+				  struct tcindex_pending_config *p,
+				  struct tcindex_filter_result *r,
+				  struct nlattr **tb, struct nlattr *est)
 {
-	int err, balloc = 0;
-	struct tcindex_filter_result new_filter_result, *old_r = r;
-	struct tcindex_filter_result cr;
-	struct tcindex_data cp;
+	struct tcindex_filter_result *old_r = r;
 	struct tcindex_filter *f = NULL; /* make gcc behave */
-	struct tcf_exts e;
+	int err;
+
+	p->balloc = 0;
 
-	err = tcf_exts_validate(tp, tb, est, &e, &tcindex_ext_map);
+	err = tcf_exts_validate(tp, tb, est, &p->ext, &tcindex_ext_map);
 	if (err < 0)
 		return err;
 
-	memcpy(&cp, p, sizeof(cp));
-	memset(&new_filter_result, 0, sizeof(new_filter_result));
+	memcpy(&p->cp, p, sizeof(p->cp));
+	memset(&p->new_filter_result, 0, sizeof(p->new_filter_result));
 
 	if (old_r)
-		memcpy(&cr, r, sizeof(cr));
+		memcpy(&p->cr, r, sizeof(p->cr));
 	else
-		memset(&cr, 0, sizeof(cr));
+		memset(&p->cr, 0, sizeof(p->cr));
 
 	if (tb[TCA_TCINDEX_HASH])
-		cp.hash = nla_get_u32(tb[TCA_TCINDEX_HASH]);
+		p->cp.hash = nla_get_u32(tb[TCA_TCINDEX_HASH]);
 
 	if (tb[TCA_TCINDEX_MASK])
-		cp.mask = nla_get_u16(tb[TCA_TCINDEX_MASK]);
+		p->cp.mask = nla_get_u16(tb[TCA_TCINDEX_MASK]);
 
 	if (tb[TCA_TCINDEX_SHIFT])
-		cp.shift = nla_get_u32(tb[TCA_TCINDEX_SHIFT]);
+		p->cp.shift = nla_get_u32(tb[TCA_TCINDEX_SHIFT]);
 
-	err = -EBUSY;
 	/* Hash already allocated, make sure that we still meet the
 	 * requirements for the allocated hash.
 	 */
-	if (cp.perfect) {
-		if (!valid_perfect_hash(&cp) ||
-		    cp.hash > cp.alloc_hash)
-			goto errout;
-	} else if (cp.h && cp.hash != cp.alloc_hash)
-		goto errout;
+	err = -EBUSY;
+	if (p->cp.perfect) {
+		if (!valid_perfect_hash(&p->cp) ||
+		    p->cp.hash > p->cp.alloc_hash)
+			goto err_destroy;
+	} else if (p->cp.h && p->cp.hash != p->cp.alloc_hash)
+		goto err_destroy;
 
 	err = -EINVAL;
 	if (tb[TCA_TCINDEX_FALL_THROUGH])
-		cp.fall_through = nla_get_u32(tb[TCA_TCINDEX_FALL_THROUGH]);
+		p->cp.fall_through = nla_get_u32(tb[TCA_TCINDEX_FALL_THROUGH]);
 
-	if (!cp.hash) {
+	if (!p->cp.hash) {
 		/* Hash not specified, use perfect hash if the upper limit
 		 * of the hashing index is below the threshold.
 		 */
-		if ((cp.mask >> cp.shift) < PERFECT_HASH_THRESHOLD)
-			cp.hash = (cp.mask >> cp.shift)+1;
+		if ((p->cp.mask >> p->cp.shift) < PERFECT_HASH_THRESHOLD)
+			p->cp.hash = (p->cp.mask >> p->cp.shift) + 1;
 		else
-			cp.hash = DEFAULT_HASH_SIZE;
+			p->cp.hash = DEFAULT_HASH_SIZE;
 	}
 
-	if (!cp.perfect && !cp.h)
-		cp.alloc_hash = cp.hash;
+	if (!p->cp.perfect && !p->cp.h)
+		p->cp.alloc_hash = p->cp.hash;
 
 	/* Note: this could be as restrictive as if (handle & ~(mask >> shift))
 	 * but then, we'd fail handles that may become valid after some future
 	 * mask change. While this is extremely unlikely to ever matter,
 	 * the check below is safer (and also more backwards-compatible).
 	 */
-	if (cp.perfect || valid_perfect_hash(&cp))
-		if (handle >= cp.alloc_hash)
-			goto errout;
-
+	if (p->cp.perfect || valid_perfect_hash(&p->cp))
+		if (handle >= p->cp.alloc_hash)
+			goto err_destroy;
 
 	err = -ENOMEM;
-	if (!cp.perfect && !cp.h) {
-		if (valid_perfect_hash(&cp)) {
-			cp.perfect = kcalloc(cp.hash, sizeof(*r), GFP_KERNEL);
-			if (!cp.perfect)
-				goto errout;
-			balloc = 1;
+	if (!p->cp.perfect && !p->cp.h) {
+		if (valid_perfect_hash(&p->cp)) {
+			p->cp.perfect = kcalloc(p->cp.hash, sizeof(*r),
+						GFP_KERNEL);
+			if (!p->cp.perfect)
+				goto err_destroy;
+			p->balloc = 1;
 		} else {
-			cp.h = kcalloc(cp.hash, sizeof(f), GFP_KERNEL);
-			if (!cp.h)
-				goto errout;
-			balloc = 2;
+			p->cp.h = kcalloc(p->cp.hash, sizeof(f), GFP_KERNEL);
+			if (!p->cp.h)
+				goto err_destroy;
+			p->balloc = 2;
 		}
 	}
 
-	if (cp.perfect)
-		r = cp.perfect + handle;
+	if (p->cp.perfect)
+		p->r = p->cp.perfect + handle;
 	else
-		r = tcindex_lookup(&cp, handle) ? : &new_filter_result;
+		p->r = tcindex_lookup(&p->cp, handle) ? : &p->new_filter_result;
 
-	if (r == &new_filter_result) {
-		f = kzalloc(sizeof(*f), GFP_KERNEL);
-		if (!f)
+	p->f = NULL;
+	if (p->r == &p->new_filter_result) {
+		p->f = kzalloc(sizeof(*f), GFP_KERNEL);
+		if (!p->f)
 			goto errout_alloc;
 	}
 
 	if (tb[TCA_TCINDEX_CLASSID]) {
-		cr.res.classid = nla_get_u32(tb[TCA_TCINDEX_CLASSID]);
-		tcf_bind_filter(tp, &cr.res, base);
+		p->cr.res.classid = nla_get_u32(tb[TCA_TCINDEX_CLASSID]);
+		tcf_bind_filter(tp, &p->cr.res, base);
 	}
 
-	tcf_exts_change(tp, &cr.exts, &e);
+	tcf_exts_change(tp, &p->cr.exts, &p->ext);
+
+	return 0;
+
+errout_alloc:
+	if (p->balloc == 1)
+		kfree(p->cp.perfect);
+	else if (p->balloc == 2)
+		kfree(p->cp.h);
+	p->balloc = 0;
+
+err_destroy:
+	tcf_exts_destroy(tp, &p->ext);
+	return err;
+}
+
+static void tcindex_cancel_parms(struct tcf_proto *tp,
+				 struct tcindex_pending_config *p)
+{
+	if (p->balloc == 1)
+		kfree(p->cp.perfect);
+	else if (p->balloc == 2)
+		kfree(p->cp.h);
+	p->balloc = 0;
+
+	tcf_exts_destroy(tp, &p->ext);
+}
+
+static void tcindex_commit_parms(struct tcf_proto *tp, u32 handle,
+				 struct tcindex_data *dp,
+				 struct tcindex_pending_config *p,
+				 struct tcindex_filter_result *r)
+{
+	struct tcindex_filter_result *old_r = r;
+
+	r = p->r;
 
 	tcf_tree_lock(tp);
 	if (old_r && old_r != r)
 		memset(old_r, 0, sizeof(*old_r));
 
-	memcpy(p, &cp, sizeof(cp));
-	memcpy(r, &cr, sizeof(cr));
+	dp->perfect = p->cp.perfect;
+	dp->h = p->cp.h;
+	dp->mask = p->cp.mask;
+	dp->shift = p->cp.shift;
+	dp->hash = p->cp.hash;
+	dp->alloc_hash = p->cp.alloc_hash;
+	dp->fall_through = p->cp.fall_through;
+
+	memcpy(p->r, &p->cr, sizeof(p->cr));
 
-	if (r == &new_filter_result) {
-		struct tcindex_filter **fp;
+	if (p->f) {
+		struct tcindex_filter *f, **fp;
+
+		f = p->f;
+		p->f = NULL;
 
 		f->key = handle;
-		f->result = new_filter_result;
+		f->result = p->new_filter_result;
 		f->next = NULL;
-		for (fp = p->h+(handle % p->hash); *fp; fp = &(*fp)->next)
+		for (fp = dp->h+(handle % dp->hash); *fp; fp = &(*fp)->next)
 			/* nothing */;
 		*fp = f;
 	}
 	tcf_tree_unlock(tp);
-
-	return 0;
-
-errout_alloc:
-	if (balloc == 1)
-		kfree(cp.perfect);
-	else if (balloc == 2)
-		kfree(cp.h);
-errout:
-	tcf_exts_destroy(tp, &e);
-	return err;
 }
 
-static int
-tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
-	       struct nlattr **tca, unsigned long *arg)
+static int tcindex_validate_change(struct tcf_proto *tp, unsigned long base,
+				   u32 handle, struct nlattr **tca,
+				   unsigned long *arg)
 {
+	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_TCINDEX_MAX + 1];
-	struct tcindex_data *p = PRIV(tp);
-	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
+	struct tcindex_data *dp = PRIV(tp);
+	struct tcindex_pending_config *p;
 	int err;
 
-	pr_debug("tcindex_change(tp %p,handle 0x%08x,tca %p,arg %p),opt %p,"
-	    "p %p,r %p,*arg 0x%lx\n",
-	    tp, handle, tca, arg, opt, p, r, arg ? *arg : 0L);
-
 	if (!opt)
 		return 0;
 
@@ -357,9 +440,59 @@ tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (err < 0)
 		return err;
 
-	return tcindex_set_parms(tp, base, handle, p, r, tb, tca[TCA_RATE]);
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	err = tcindex_validate_parms(tp, base, handle, dp, p, r, tb, tca[TCA_RATE]);
+	if (err)
+		kfree(p);
+	else
+		dp->pending_config = p;
+
+	return err;
+}
+
+static void tcindex_commit_change(struct tcf_proto *tp, unsigned long base,
+				  u32 handle, struct nlattr **tca,
+				  unsigned long arg)
+{
+	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct tcindex_data *dp = PRIV(tp);
+	struct tcindex_pending_config *p;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!dp->pending_config);
+	p = dp->pending_config;
+	dp->pending_config = NULL;
+
+	tcindex_commit_parms(tp, handle, dp, p, r);
+
+	kfree(p);
 }
 
+static void tcindex_cancel_change(struct tcf_proto *tp, unsigned long base,
+				  u32 handle, struct nlattr **tca,
+				  unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct tcindex_data *dp = PRIV(tp);
+	struct tcindex_pending_config *p;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!dp->pending_config);
+	p = dp->pending_config;
+	dp->pending_config = NULL;
+
+	tcindex_cancel_parms(tp, p);
+
+	kfree(p);
+}
 
 static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
 {
@@ -490,8 +623,11 @@ static struct tcf_proto_ops cls_tcindex_ops __read_mostly = {
 	.destroy	=	tcindex_destroy,
 	.get		=	tcindex_get,
 	.put		=	tcindex_put,
-	.change		=	tcindex_change,
-	.delete		=	tcindex_delete,
+	.validate_change=	tcindex_validate_change,
+	.commit_change	=	tcindex_commit_change,
+	.cancel_change	=	tcindex_cancel_change,
+	.validate_delete=	tcindex_validate_delete,
+	.commit_delete	=	tcindex_commit_delete,
 	.walk		=	tcindex_walk,
 	.dump		=	tcindex_dump,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 4d75544..2408bf8 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -80,6 +80,8 @@ struct tc_u_common
 	struct Qdisc		*q;
 	int			refcnt;
 	u32			hgenerator;
+
+	void			*pending_config;
 };
 
 static const struct tcf_ext_map u32_ext_map = {
@@ -334,10 +336,15 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 	return 0;
 }
 
-static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode* key)
+static int u32_validate_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
+{
+	return 0;
+}
+
+static void u32_commit_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 {
-	struct tc_u_knode **kp;
 	struct tc_u_hnode *ht = key->ht_up;
+	struct tc_u_knode **kp;
 
 	if (ht) {
 		for (kp = &ht->ht[TC_U32_HASH(key->handle)]; *kp; kp = &(*kp)->next) {
@@ -347,12 +354,12 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode* key)
 				tcf_tree_unlock(tp);
 
 				u32_destroy_key(tp, key);
-				return 0;
+				return;
 			}
 		}
 	}
-	BUG_TRAP(0);
-	return 0;
+	WARN_ON(1);
+	return;
 }
 
 static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
@@ -369,7 +376,7 @@ static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 	}
 }
 
-static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
+static void u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 {
 	struct tc_u_common *tp_c = tp->data;
 	struct tc_u_hnode **hn;
@@ -382,12 +389,12 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 		if (*hn == ht) {
 			*hn = ht->next;
 			kfree(ht);
-			return 0;
+			return;
 		}
 	}
 
-	BUG_TRAP(0);
-	return -ENOENT;
+	WARN_ON(1);
+	return;
 }
 
 static void u32_destroy(struct tcf_proto *tp)
@@ -430,29 +437,41 @@ static void u32_destroy(struct tcf_proto *tp)
 	tp->data = NULL;
 }
 
-static int u32_delete(struct tcf_proto *tp, unsigned long arg)
+static int u32_validate_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct tc_u_hnode *ht = (struct tc_u_hnode*)arg;
 
-	if (ht == NULL)
+	if (!ht)
 		return 0;
 
 	if (TC_U32_KEY(ht->handle))
-		return u32_delete_key(tp, (struct tc_u_knode*)ht);
+		return u32_validate_delete_key(tp, (struct tc_u_knode *)ht);
 
 	if (tp->root == ht)
 		return -EINVAL;
 
-	if (ht->refcnt == 1) {
-		ht->refcnt--;
-		u32_destroy_hnode(tp, ht);
-	} else {
+	if (ht->refcnt != 1)
 		return -EBUSY;
-	}
 
 	return 0;
 }
 
+static void u32_commit_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct tc_u_hnode *ht = (struct tc_u_hnode*)arg;
+
+	if (!ht)
+		return;
+
+	if (TC_U32_KEY(ht->handle)) {
+		u32_commit_delete_key(tp, (struct tc_u_knode *)ht);
+		return;
+	}
+
+	ht->refcnt--;
+	u32_destroy_hnode(tp, ht);
+}
+
 static u32 gen_new_kid(struct tc_u_hnode *ht, u32 handle)
 {
 	struct tc_u_knode *n;
@@ -476,15 +495,29 @@ static const struct nla_policy u32_policy[TCA_U32_MAX + 1] = {
 	[TCA_U32_MARK]		= { .len = sizeof(struct tc_u32_mark) },
 };
 
-static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
-			 struct tc_u_hnode *ht,
-			 struct tc_u_knode *n, struct nlattr **tb,
-			 struct nlattr *est)
+struct u32_pending_config {
+	struct tc_u_hnode	*hlist;
+	struct tc_u_knode	*n;
+	struct tcf_exts		ext;
+	struct tc_u_hnode	*htdown;
+	char			indev[IFNAMSIZ];
+	u32			classid;
+	unsigned int		flags;
+#define FLAG_NEW		0x00000001
+#define FLAG_HAD_N		0x00000002
+#define FLAG_HAVE_LINK		0x00000004
+#define FLAG_HAVE_CLASSID	0x00000008
+#define FLAG_HAVE_INDEV		0x00000010
+};
+
+static int u32_validate_parms(struct tcf_proto *tp, unsigned long base,
+			      struct u32_pending_config *p,
+			      struct tc_u_hnode *ht, struct tc_u_knode *n,
+			      struct nlattr **tb, struct nlattr *est)
 {
 	int err;
-	struct tcf_exts e;
 
-	err = tcf_exts_validate(tp, tb, est, &e, &u32_ext_map);
+	err = tcf_exts_validate(tp, tb, est, &p->ext, &u32_ext_map);
 	if (err < 0)
 		return err;
 
@@ -494,15 +527,51 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 		struct tc_u_hnode *ht_down = NULL;
 
 		if (TC_U32_KEY(handle))
-			goto errout;
+			goto err_destroy;
 
 		if (handle) {
 			ht_down = u32_lookup_ht(ht->tp_c, handle);
 
 			if (ht_down == NULL)
-				goto errout;
-			ht_down->refcnt++;
+				goto err_destroy;
 		}
+		p->htdown = ht_down;
+		p->flags |= FLAG_HAVE_LINK;
+	}
+
+	if (tb[TCA_U32_CLASSID]) {
+		p->classid = nla_get_u32(tb[TCA_U32_CLASSID]);
+		p->flags |= FLAG_HAVE_CLASSID;
+	}
+
+#ifdef CONFIG_NET_CLS_IND
+	if (tb[TCA_U32_INDEV]) {
+		err = -EINVAL;
+		if (nla_len(tb[TCA_U32_INDEV]) >= IFNAMSIZ)
+			goto err_destroy;
+		nla_strlcpy(p->indev, tb[TCA_U32_INDEV], IFNAMSIZ);
+		p->flags |= FLAG_HAVE_INDEV;
+	}
+#endif
+
+	return 0;
+
+err_destroy:
+	tcf_exts_destroy(tp, &p->ext);
+	return err;
+}
+
+static void u32_commit_parms(struct tcf_proto *tp, unsigned long base,
+			     struct u32_pending_config *p,
+			     struct tc_u_hnode *ht, struct tc_u_knode *n)
+{
+	if (p->flags & FLAG_HAVE_LINK) {
+		struct tc_u_hnode *ht_down = p->htdown;
+
+		p->htdown = NULL;
+
+		if (ht_down)
+			ht_down->refcnt++;
 
 		tcf_tree_lock(tp);
 		ht_down = xchg(&n->ht_down, ht_down);
@@ -511,79 +580,91 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 		if (ht_down)
 			ht_down->refcnt--;
 	}
-	if (tb[TCA_U32_CLASSID]) {
-		n->res.classid = nla_get_u32(tb[TCA_U32_CLASSID]);
+
+	if (p->flags & FLAG_HAVE_CLASSID) {
+		n->res.classid = p->classid;
 		tcf_bind_filter(tp, &n->res, base);
 	}
 
 #ifdef CONFIG_NET_CLS_IND
-	if (tb[TCA_U32_INDEV]) {
-		err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV]);
-		if (err < 0)
-			goto errout;
-	}
+	if (p->flags & FLAG_HAVE_INDEV)
+		strlcpy(n->indev, p->indev, IFNAMSIZ);
 #endif
-	tcf_exts_change(tp, &n->exts, &e);
+	tcf_exts_change(tp, &n->exts, &p->ext);
+}
 
-	return 0;
-errout:
-	tcf_exts_destroy(tp, &e);
-	return err;
+static void u32_cancel_parms(struct tcf_proto *tp,
+			     struct u32_pending_config *p)
+{
+	tcf_exts_destroy(tp, &p->ext);
 }
 
-static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
-		      struct nlattr **tca,
-		      unsigned long *arg)
+static int u32_validate_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+			       struct nlattr **tca, unsigned long *arg)
 {
+	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct tc_u_common *tp_c = tp->data;
+	struct nlattr *tb[TCA_U32_MAX + 1];
+	struct u32_pending_config *p;
 	struct tc_u_hnode *ht;
 	struct tc_u_knode *n;
 	struct tc_u32_sel *s;
-	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct nlattr *tb[TCA_U32_MAX + 1];
 	u32 htid;
 	int err;
 
-	if (opt == NULL)
+	if (!opt)
 		return handle ? -EINVAL : 0;
 
 	err = nla_parse_nested(tb, TCA_U32_MAX, opt, u32_policy);
 	if (err < 0)
 		return err;
 
-	if ((n = (struct tc_u_knode*)*arg) != NULL) {
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	n = (struct tc_u_knode *) *arg;
+	err = -EINVAL;
+	if (n) {
 		if (TC_U32_KEY(n->handle) == 0)
-			return -EINVAL;
+			goto err_free_config;
 
-		return u32_set_parms(tp, base, n->ht_up, n, tb, tca[TCA_RATE]);
+		p->flags |= FLAG_HAD_N;
+		err = u32_validate_parms(tp, base, p, n->ht_up, n, tb, tca[TCA_RATE]);
+		if (err)
+			goto err_free_config;
+		return 0;
 	}
 
 	if (tb[TCA_U32_DIVISOR]) {
-		unsigned divisor = nla_get_u32(tb[TCA_U32_DIVISOR]);
+		unsigned int divisor = nla_get_u32(tb[TCA_U32_DIVISOR]);
+
+		if (--divisor > 0x100 || TC_U32_KEY(handle))
+			goto err_free_config;
 
-		if (--divisor > 0x100)
-			return -EINVAL;
-		if (TC_U32_KEY(handle))
-			return -EINVAL;
 		if (handle == 0) {
 			handle = gen_new_htid(tp->data);
+			err = -ENOMEM;
 			if (handle == 0)
-				return -ENOMEM;
+				goto err_free_config;
 		}
 		ht = kzalloc(sizeof(*ht) + divisor*sizeof(void*), GFP_KERNEL);
+		err = -ENOBUFS;
 		if (ht == NULL)
-			return -ENOBUFS;
+			goto err_free_config;
 		ht->tp_c = tp_c;
 		ht->refcnt = 1;
 		ht->divisor = divisor;
 		ht->handle = handle;
 		ht->prio = tp->prio;
 		ht->next = tp_c->hlist;
-		tp_c->hlist = ht;
-		*arg = (unsigned long)ht;
+		p->hlist = ht;
+		p->flags |= FLAG_NEW;
+		*arg = (unsigned long) ht;
 		return 0;
 	}
 
+	err = -EINVAL;
 	if (tb[TCA_U32_HASH]) {
 		htid = nla_get_u32(tb[TCA_U32_HASH]);
 		if (TC_U32_HTID(htid) == TC_U32_ROOT) {
@@ -592,37 +673,40 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 		} else {
 			ht = u32_lookup_ht(tp->data, TC_U32_HTID(htid));
 			if (ht == NULL)
-				return -EINVAL;
+				goto err_free_config;
 		}
 	} else {
 		ht = tp->root;
 		htid = ht->handle;
 	}
 
+	p->hlist = ht;
+
 	if (ht->divisor < TC_U32_HASH(htid))
-		return -EINVAL;
+		goto err_free_config;
 
 	if (handle) {
 		if (TC_U32_HTID(handle) && TC_U32_HTID(handle^htid))
-			return -EINVAL;
+			goto err_free_config;
 		handle = htid | TC_U32_NODE(handle);
 	} else
 		handle = gen_new_kid(ht, htid);
 
-	if (tb[TCA_U32_SEL] == NULL)
-		return -EINVAL;
+	if (!tb[TCA_U32_SEL])
+		goto err_free_config;
 
 	s = nla_data(tb[TCA_U32_SEL]);
 
 	n = kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL);
-	if (n == NULL)
-		return -ENOBUFS;
+	err = -ENOBUFS;
+	if (!n)
+		goto err_free_config;
 
 #ifdef CONFIG_CLS_U32_PERF
 	n->pf = kzalloc(sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(u64), GFP_KERNEL);
 	if (n->pf == NULL) {
 		kfree(n);
-		return -ENOBUFS;
+		goto err_free_config;
 	}
 #endif
 
@@ -641,25 +725,100 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	}
 #endif
 
-	err = u32_set_parms(tp, base, ht, n, tb, tca[TCA_RATE]);
-	if (err == 0) {
-		struct tc_u_knode **ins;
-		for (ins = &ht->ht[TC_U32_HASH(handle)]; *ins; ins = &(*ins)->next)
-			if (TC_U32_NODE(handle) < TC_U32_NODE((*ins)->handle))
-				break;
+	err = u32_validate_parms(tp, base, p, ht, n, tb, tca[TCA_RATE]);
+	if (err) {
+#ifdef CONFIG_CLS_U32_PERF
+		kfree(n->pf);
+#endif
+		kfree(n);
+		goto err_free_config;
+	} else {
+		tp_c->pending_config = p;
+		*arg = (unsigned long) n;
+	}
 
-		n->next = *ins;
-		wmb();
-		*ins = n;
+	return err;
+
+err_free_config:
+	kfree(p);
+	return err;
+}
+
+static void u32_cancel_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+			      struct nlattr **tca, unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct tc_u_common *tp_c = tp->data;
+	struct u32_pending_config *p;
+	struct tc_u_hnode *ht;
+	struct tc_u_knode *n;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!tp_c->pending_config);
+	p = tp_c->pending_config;
+	tp_c->pending_config = NULL;
+
+	ht = p->hlist;
+	p->hlist = NULL;
+
+	if (p->flags & FLAG_NEW) {
+		kfree(ht);
+	} else {
+		n = p->n;
+		p->n = NULL;
+
+		u32_cancel_parms(tp, p);
 
-		*arg = (unsigned long)n;
-		return 0;
-	}
 #ifdef CONFIG_CLS_U32_PERF
-	kfree(n->pf);
+		kfree(n->pf);
 #endif
-	kfree(n);
-	return err;
+		kfree(n);
+	}
+
+	kfree(p);
+}
+
+static void u32_commit_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+			      struct nlattr **tca, unsigned long arg)
+{
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct tc_u_common *tp_c = tp->data;
+	struct u32_pending_config *p;
+	struct tc_u_knode *n, **ins;
+	struct tc_u_hnode *ht;
+
+	if (!opt)
+		return;
+
+	BUG_ON(!tp_c->pending_config);
+	p = tp_c->pending_config;
+	tp_c->pending_config = NULL;
+
+	n = (struct tc_u_knode *) arg;
+	if (p->flags & FLAG_HAD_N) {
+		u32_commit_parms(tp, base, p, n->ht_up, n);
+	} else {
+		ht = p->hlist;
+		p->hlist = NULL;
+
+		if (p->flags & FLAG_NEW) {
+			tp_c->hlist = ht;
+		} else {
+			u32_commit_parms(tp, base, p, ht, n);
+
+			for (ins = &ht->ht[TC_U32_HASH(handle)]; *ins; ins = &(*ins)->next) {
+				if (TC_U32_NODE(handle) < TC_U32_NODE((*ins)->handle))
+					break;
+			}
+			n->next = *ins;
+			wmb();
+			*ins = n;
+		}
+	}
+
+	kfree(p);
 }
 
 static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
@@ -768,8 +927,11 @@ static struct tcf_proto_ops cls_u32_ops __read_mostly = {
 	.destroy	=	u32_destroy,
 	.get		=	u32_get,
 	.put		=	u32_put,
-	.change		=	u32_change,
-	.delete		=	u32_delete,
+	.validate_change=	u32_validate_change,
+	.commit_change	=	u32_commit_change,
+	.cancel_change	=	u32_cancel_change,
+	.validate_delete=	u32_validate_delete,
+	.commit_delete	=	u32_commit_delete,
 	.walk		=	u32_walk,
 	.dump		=	u32_dump,
 	.owner		=	THIS_MODULE,
-- 
1.5.6.2.255.gbed62

