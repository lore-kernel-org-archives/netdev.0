From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 11 Aug 2008 22:53:57 +0200
Message-ID: <20080811205357.GA15293@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.190]:36458 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbYHKUxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 16:53:40 -0400
Received: by gv-out-0910.google.com with SMTP id e6so26224gvc.37
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 13:53:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: Destroy gen estimators under rtnl_lock().

gen_kill_estimator() requires rtnl_lock() protection, and since it is
called in qdisc ->destroy() too, this has to go back from RCU callback
to qdisc_destroy().


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_generic.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7cf83b3..336dc88 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -524,18 +524,10 @@ EXPORT_SYMBOL(qdisc_reset);
 static void __qdisc_destroy(struct rcu_head *head)
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
-	const struct Qdisc_ops  *ops = qdisc->ops;
 
 #ifdef CONFIG_NET_SCHED
 	qdisc_put_stab(qdisc->stab);
 #endif
-	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
-	if (ops->reset)
-		ops->reset(qdisc);
-	if (ops->destroy)
-		ops->destroy(qdisc);
-
-	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
 	kfree_skb(qdisc->gso_skb);
@@ -547,6 +539,8 @@ static void __qdisc_destroy(struct rcu_head *head)
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
+	const struct Qdisc_ops *ops = qdisc->ops;
+
 	if (qdisc->flags & TCQ_F_BUILTIN ||
 	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
@@ -554,6 +548,13 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	if (qdisc->parent)
 		list_del(&qdisc->list);
 
+	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+	if (ops->reset)
+		ops->reset(qdisc);
+	if (ops->destroy)
+		ops->destroy(qdisc);
+
+	module_put(ops->owner);
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 EXPORT_SYMBOL(qdisc_destroy);
