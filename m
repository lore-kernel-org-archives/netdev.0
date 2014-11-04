From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 06/13] net_sched: move some qdisc flag into qdisc ops
Date: Tue,  4 Nov 2014 09:56:29 -0800
Message-ID: <1415123796-8093-7-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54390 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaKDR4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:53 -0500
Received: by mail-pd0-f170.google.com with SMTP id z10so14080022pdj.15
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:52 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For those static flags, that is never changed dynamically,
we could just move them into qdisc->ops. This will be used
by some following patch.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  3 ++-
 net/sched/sch_api.c       |  4 ++--
 net/sched/sch_generic.c   | 10 +++++-----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 119e129..f552c4c 100644
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
@@ -184,6 +183,8 @@ struct Qdisc_ops {
 	const struct Qdisc_class_ops	*cl_ops;
 	char			id[IFNAMSIZ];
 	int			priv_size;
+#define QDISC_F_BUILTIN		1
+	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2276b15..b6cad91 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -260,7 +260,7 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 {
 	struct Qdisc *q;
 
-	if (!(root->flags & TCQ_F_BUILTIN) &&
+	if (!(root->ops->flags & QDISC_F_BUILTIN) &&
 	    root->handle == handle)
 		return root;
 
@@ -1372,7 +1372,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 
 static bool tc_qdisc_dump_ignore(struct Qdisc *q)
 {
-	return (q->flags & TCQ_F_BUILTIN) ? true : false;
+	return (q->ops->flags & QDISC_F_BUILTIN) ? true : false;
 }
 
 static int qdisc_notify(struct net *net, struct sk_buff *oskb,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cd4ba53..3ab44a2 100644
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
 
@@ -775,7 +775,7 @@ static void transition_one_qdisc(struct net_device *dev,
 	struct Qdisc *new_qdisc = dev_queue->qdisc_sleeping;
 	int *need_watchdog_p = _need_watchdog;
 
-	if (!(new_qdisc->flags & TCQ_F_BUILTIN))
+	if (!(new_qdisc->ops->flags & QDISC_F_BUILTIN))
 		clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
 
 	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
@@ -824,7 +824,7 @@ static void dev_deactivate_queue(struct net_device *dev,
 	if (qdisc) {
 		spin_lock_bh(qdisc_lock(qdisc));
 
-		if (!(qdisc->flags & TCQ_F_BUILTIN))
+		if (!(qdisc->ops->flags & QDISC_F_BUILTIN))
 			set_bit(__QDISC_STATE_DEACTIVATED, &qdisc->state);
 
 		rcu_assign_pointer(dev_queue->qdisc, qdisc_default);
-- 
1.8.3.1
