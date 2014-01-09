From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 2/4] net_sched: avoid holding qdisc lock for filters
Date: Thu,  9 Jan 2014 10:19:51 -0800
Message-ID: <1389291593-2494-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:63545 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477AbaAISUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:20:12 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so3478662pdj.19
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 10:20:11 -0800 (PST)
In-Reply-To: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h     | 25 ++++---------------------
 include/net/sch_generic.h |  5 +++--
 net/sched/cls_api.c       | 12 +++++-------
 3 files changed, 12 insertions(+), 30 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 50ea079..9afb15b 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -18,26 +18,9 @@ int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
 static inline unsigned long
-__cls_set_class(unsigned long *clp, unsigned long cl)
+cls_set_class(unsigned long *clp, unsigned long cl)
 {
-	unsigned long old_cl;
- 
-	old_cl = *clp;
-	*clp = cl;
-	return old_cl;
-}
-
-static inline unsigned long
-cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
-	unsigned long cl)
-{
-	unsigned long old_cl;
-	
-	tcf_tree_lock(tp);
-	old_cl = __cls_set_class(clp, cl);
-	tcf_tree_unlock(tp);
- 
-	return old_cl;
+	return xchg(clp, cl);
 }
 
 static inline void
@@ -46,7 +29,7 @@ tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r, unsigned long base)
 	unsigned long cl;
 
 	cl = tp->q->ops->cl_ops->bind_tcf(tp->q, base, r->classid);
-	cl = cls_set_class(tp, &r->class, cl);
+	cl = cls_set_class(&r->class, cl);
 	if (cl)
 		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
 }
@@ -56,7 +39,7 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 {
 	unsigned long cl;
 
-	if ((cl = __cls_set_class(&r->class, 0)) != 0)
+	if ((cl = cls_set_class(&r->class, 0)) != 0)
 		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 97123cc..000ce54 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -215,6 +215,7 @@ struct tcf_proto_ops {
 
 struct tcf_proto {
 	/* Fast access part */
+	spinlock_t		lock;
 	struct list_head	head;
 	void			*root;
 	int			(*classify)(struct sk_buff *,
@@ -312,8 +313,8 @@ static inline void sch_tree_unlock(const struct Qdisc *q)
 	spin_unlock_bh(qdisc_root_sleeping_lock(q));
 }
 
-#define tcf_tree_lock(tp)	sch_tree_lock((tp)->q)
-#define tcf_tree_unlock(tp)	sch_tree_unlock((tp)->q)
+#define tcf_tree_lock(tp)	spin_lock_bh(&(tp)->lock);
+#define tcf_tree_unlock(tp)	spin_unlock_bh(&(tp)->lock);
 
 extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index bcc9987..9ba2804 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -117,7 +117,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_MAX + 1];
-	spinlock_t *root_lock;
 	struct tcmsg *t;
 	u32 protocol;
 	u32 prio;
@@ -215,8 +214,6 @@ replay:
 	}
 	rcu_read_unlock();
 
-	root_lock = qdisc_root_sleeping_lock(q);
-
 	if ((tp = res) == NULL) {
 		/* Proto-tcf does not exist, create new one */
 
@@ -236,6 +233,7 @@ replay:
 		if (tp == NULL)
 			goto errout;
 		INIT_LIST_HEAD(&tp->head);
+		spin_lock_init(&tp->lock);
 		err = -ENOENT;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
 		if (tp_ops == NULL) {
@@ -287,9 +285,9 @@ replay:
 
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
-			spin_lock_bh(root_lock);
+			tcf_tree_lock(tp);
 			list_del_rcu(&tp->head);
-			spin_unlock_bh(root_lock);
+			tcf_tree_unlock(tp);
 
 			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
 			tcf_destroy(tp);
@@ -328,9 +326,9 @@ replay:
 	err = tp->ops->change(net, skb, tp, cl, t->tcm_handle, tca, &fh);
 	if (err == 0) {
 		if (tp_created) {
-			spin_lock_bh(root_lock);
+			tcf_tree_lock(tp);
 			list_add_rcu(&tp->head, chain);
-			spin_unlock_bh(root_lock);
+			tcf_tree_unlock(tp);
 		}
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
 	} else {
-- 
1.8.3.1
