From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/5] net_sched: move some qdisc flag into qdisc ops
Date: Wed, 26 Aug 2015 15:41:23 -0700
Message-ID: <1440628887-3504-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36458 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756526AbbHZWle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:41:34 -0400
Received: by pacgr6 with SMTP id gr6so1900240pac.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 15:41:34 -0700 (PDT)
In-Reply-To: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For those static flags, that is never changed dynamically,
we could just move them into qdisc->ops. This will be used
by the following patches.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  3 ++-
 net/sched/sch_api.c       |  4 ++--
 net/sched/sch_generic.c   | 10 +++++-----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2eab08c..fe835e1 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -48,7 +48,6 @@ struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
 	unsigned int		flags;
-#define TCQ_F_BUILTIN		1
 #define TCQ_F_INGRESS		2
 #define TCQ_F_CAN_BYPASS	4
 #define TCQ_F_MQROOT		8
@@ -181,6 +180,8 @@ struct Qdisc_ops {
 	const struct Qdisc_class_ops	*cl_ops;
 	char			id[IFNAMSIZ];
 	int			priv_size;
+#define QDISC_F_BUILTIN		1
+	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f06aa01..f2b194b 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -260,7 +260,7 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 {
 	struct Qdisc *q;
 
-	if (!(root->flags & TCQ_F_BUILTIN) &&
+	if (!(root->ops->flags & QDISC_F_BUILTIN) &&
 	    root->handle == handle)
 		return root;
 
@@ -1384,7 +1384,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 
 static bool tc_qdisc_dump_ignore(struct Qdisc *q)
 {
-	return (q->flags & TCQ_F_BUILTIN) ? true : false;
+	return (q->ops->flags & QDISC_F_BUILTIN) ? true : false;
 }
 
 static int qdisc_notify(struct net *net, struct sk_buff *oskb,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 942fea8..460388a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -392,6 +392,7 @@ static struct sk_buff *noop_dequeue(struct Qdisc *qdisc)
 
 struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 	.id		=	"noop",
+	.flags		=	QDISC_F_BUILTIN,
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
@@ -407,7 +408,6 @@ static struct netdev_queue noop_netdev_queue = {
 struct Qdisc noop_qdisc = {
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
-	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
@@ -418,6 +418,7 @@ EXPORT_SYMBOL(noop_qdisc);
 
 static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.id		=	"noqueue",
+	.flags		=	QDISC_F_BUILTIN,
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
@@ -434,7 +435,6 @@ static struct netdev_queue noqueue_netdev_queue = {
 static struct Qdisc noqueue_qdisc = {
 	.enqueue	=	NULL,
 	.dequeue	=	noop_dequeue,
-	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noqueue_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
@@ -676,7 +676,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 {
 	const struct Qdisc_ops  *ops = qdisc->ops;
 
-	if (qdisc->flags & TCQ_F_BUILTIN ||
+	if (ops->flags & QDISC_F_BUILTIN ||
 	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
 
@@ -777,7 +777,7 @@ static void transition_one_qdisc(struct net_device *dev,
 	struct Qdisc *new_qdisc = dev_queue->qdisc_sleeping;
 	int *need_watchdog_p = _need_watchdog;
 
-	if (!(new_qdisc->flags & TCQ_F_BUILTIN))
+	if (!(new_qdisc->ops->flags & QDISC_F_BUILTIN))
 		clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
 
 	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
@@ -826,7 +826,7 @@ static void dev_deactivate_queue(struct net_device *dev,
 	if (qdisc) {
 		spin_lock_bh(qdisc_lock(qdisc));
 
-		if (!(qdisc->flags & TCQ_F_BUILTIN))
+		if (!(qdisc->ops->flags & QDISC_F_BUILTIN))
 			set_bit(__QDISC_STATE_DEACTIVATED, &qdisc->state);
 
 		rcu_assign_pointer(dev_queue->qdisc, qdisc_default);
-- 
1.8.3.1
