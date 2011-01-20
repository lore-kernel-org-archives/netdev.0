From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched: RCU conversion of stab
Date: Thu, 20 Jan 2011 14:48:19 +0100
Message-ID: <1295531299.2825.175.camel@edumazet-laptop>
References: <1295517052.2733.14.camel@edumazet-laptop>
	 <1295518636.2825.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43525 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630Ab1ATNsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 08:48:24 -0500
Received: by wwa36 with SMTP id 36so655187wwa.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 05:48:22 -0800 (PST)
In-Reply-To: <1295518636.2825.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts stab qdisc management to RCU, so that we can perform
the qdisc_calculate_pkt_len() call before getting qdisc lock.

This shortens the lock's held time in __dev_xmit_skb().

This permits more qdiscs to get TCQ_F_CAN_BYPASS status, avoiding lot of
cache misses and so reducing latencies.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jesper Dangaard Brouer <hawk@diku.dk>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Jamal Hadi Salim <hadi@cyberus.ca>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 include/net/sch_generic.h |   21 +++++++++++++++------
 net/core/dev.c            |    8 +++++---
 net/sched/sch_api.c       |   26 +++++++++++++++++---------
 net/sched/sch_generic.c   |    2 +-
 4 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e9eee99..d67cc34 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -35,6 +35,7 @@ enum qdisc___state_t {
 };
 
 struct qdisc_size_table {
+	struct rcu_head		rcu;
 	struct list_head	list;
 	struct tc_sizespec	szopts;
 	int			refcnt;
@@ -53,7 +54,7 @@ struct Qdisc {
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
 	struct Qdisc_ops	*ops;
-	struct qdisc_size_table	*stab;
+	struct qdisc_size_table	__rcu *stab;
 	struct list_head	list;
 	u32			handle;
 	u32			parent;
@@ -331,8 +332,8 @@ extern struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 				 struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				       struct Qdisc_ops *ops, u32 parentid);
-extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
-				   struct qdisc_size_table *stab);
+extern void __qdisc_calculate_pkt_len(struct sk_buff *skb,
+				      const struct qdisc_size_table *stab);
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto **fl);
 
@@ -411,12 +412,20 @@ enum net_xmit_qdisc_t {
 #define net_xmit_drop_count(e)	(1)
 #endif
 
-static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static inline void qdisc_calculate_pkt_len(struct sk_buff *skb,
+					   const struct Qdisc *sch)
 {
 #ifdef CONFIG_NET_SCHED
-	if (sch->stab)
-		qdisc_calculate_pkt_len(skb, sch->stab);
+	struct qdisc_size_table *stab = rcu_dereference_bh(sch->stab);
+
+	if (stab)
+		__qdisc_calculate_pkt_len(skb, stab);
 #endif
+}
+
+static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	qdisc_calculate_pkt_len(skb, sch);
 	return sch->enqueue(skb, sch);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 8b1d886..f27882e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2325,15 +2325,18 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct netdev_queue *txq)
 {
 	spinlock_t *root_lock = qdisc_lock(q);
-	bool contended = qdisc_is_running(q);
+	bool contended;
 	int rc;
 
+	qdisc_skb_cb(skb)->pkt_len = skb->len;
+	qdisc_calculate_pkt_len(skb, q);
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
 	 * separate lock before trying to get qdisc main lock.
 	 * This permits __QDISC_STATE_RUNNING owner to get the lock more often
 	 * and dequeue packets faster.
 	 */
+	contended = qdisc_is_running(q);
 	if (unlikely(contended))
 		spin_lock(&q->busylock);
 
@@ -2351,7 +2354,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
 			skb_dst_force(skb);
 
-		qdisc_skb_cb(skb)->pkt_len = skb->len;
 		qdisc_bstats_update(q, skb);
 
 		if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
@@ -2366,7 +2368,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		rc = NET_XMIT_SUCCESS;
 	} else {
 		skb_dst_force(skb);
-		rc = qdisc_enqueue_root(skb, q);
+		rc = q->enqueue(skb, q) & NET_XMIT_MASK;
 		if (qdisc_run_begin(q)) {
 			if (unlikely(contended)) {
 				spin_unlock(&q->busylock);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 36ac0ec..7043fd9 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -398,6 +398,11 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	return stab;
 }
 
+static void stab_kfree_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct qdisc_size_table, rcu));
+}
+
 void qdisc_put_stab(struct qdisc_size_table *tab)
 {
 	if (!tab)
@@ -407,7 +412,7 @@ void qdisc_put_stab(struct qdisc_size_table *tab)
 
 	if (--tab->refcnt == 0) {
 		list_del(&tab->list);
-		kfree(tab);
+		call_rcu_bh(&tab->rcu, stab_kfree_rcu);
 	}
 
 	spin_unlock(&qdisc_stab_lock);
@@ -430,7 +435,7 @@ nla_put_failure:
 	return -1;
 }
 
-void qdisc_calculate_pkt_len(struct sk_buff *skb, struct qdisc_size_table *stab)
+void __qdisc_calculate_pkt_len(struct sk_buff *skb, const struct qdisc_size_table *stab)
 {
 	int pkt_len, slot;
 
@@ -456,7 +461,7 @@ out:
 		pkt_len = 1;
 	qdisc_skb_cb(skb)->pkt_len = pkt_len;
 }
-EXPORT_SYMBOL(qdisc_calculate_pkt_len);
+EXPORT_SYMBOL(__qdisc_calculate_pkt_len);
 
 void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc)
 {
@@ -835,7 +840,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				err = PTR_ERR(stab);
 				goto err_out4;
 			}
-			sch->stab = stab;
+			rcu_assign_pointer(sch->stab, stab);
 		}
 		if (tca[TCA_RATE]) {
 			spinlock_t *root_lock;
@@ -875,7 +880,7 @@ err_out4:
 	 * Any broken qdiscs that would require a ops->reset() here?
 	 * The qdisc was never in action so it shouldn't be necessary.
 	 */
-	qdisc_put_stab(sch->stab);
+	qdisc_put_stab(rtnl_dereference(sch->stab));
 	if (ops->destroy)
 		ops->destroy(sch);
 	goto err_out3;
@@ -883,7 +888,7 @@ err_out4:
 
 static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 {
-	struct qdisc_size_table *stab = NULL;
+	struct qdisc_size_table *ostab, *stab = NULL;
 	int err = 0;
 
 	if (tca[TCA_OPTIONS]) {
@@ -900,8 +905,9 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 			return PTR_ERR(stab);
 	}
 
-	qdisc_put_stab(sch->stab);
-	sch->stab = stab;
+	ostab = rtnl_dereference(sch->stab);
+	rcu_assign_pointer(sch->stab, stab);
+	qdisc_put_stab(ostab);
 
 	if (tca[TCA_RATE]) {
 		/* NB: ignores errors from replace_estimator
@@ -1180,6 +1186,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	struct nlmsghdr  *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct gnet_dump d;
+	struct qdisc_size_table *stab;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
@@ -1195,7 +1202,8 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 	q->qstats.qlen = q->q.qlen;
 
-	if (q->stab && qdisc_dump_stab(skb, q->stab) < 0)
+	stab = rtnl_dereference(q->stab);
+	if (stab && qdisc_dump_stab(skb, stab) < 0)
 		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2f1cb62..cc17e79 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -632,7 +632,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 #ifdef CONFIG_NET_SCHED
 	qdisc_list_del(qdisc);
 
-	qdisc_put_stab(qdisc->stab);
+	qdisc_put_stab(rtnl_dereference(qdisc->stab));
 #endif
 	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
 	if (ops->reset)


