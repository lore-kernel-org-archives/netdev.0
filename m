From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH alternative] pkt_sched: Move qdisc_put_stab() from BH
	context.
Date: Tue, 12 Aug 2008 00:25:11 +0200
Message-ID: <20080811222511.GC15293@ami.dom.local>
References: <20080811214239.GB15293@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:19946 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbYHKWYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 18:24:06 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1968848fkq.5
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 15:24:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080811214239.GB15293@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 11:42:39PM +0200, Jarek Poplawski wrote:
> 
> pkt_sched: Add BH protection for qdisc_stab_lock.

...Or instead of this:
-------------> (alternative version)

pkt_sched: Move qdisc_put_stab() from BH context.

Since qdisc_stab_lock is used in qdisc_put_stab(), which is called in
BH context from __qdisc_destroy() RCU callback, softirq safe locking
should be used. Alternatively we can move this to qdisc_destroy(). 


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---
(Apply on top of: pkt_sched: Destroy gen estimator under rtnl_lock().)

diff -Nurp a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2008-08-12 00:04:22.000000000 +0200
+++ b/net/sched/sch_generic.c	2008-08-12 00:08:24.000000000 +0200
@@ -525,9 +525,6 @@ static void __qdisc_destroy(struct rcu_h
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
 
-#ifdef CONFIG_NET_SCHED
-	qdisc_put_stab(qdisc->stab);
-#endif
 	dev_put(qdisc_dev(qdisc));
 
 	kfree_skb(qdisc->gso_skb);
@@ -548,6 +545,9 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	if (qdisc->parent)
 		list_del(&qdisc->list);
 
+#ifdef CONFIG_NET_SCHED
+	qdisc_put_stab(qdisc->stab);
+#endif
 	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
 	if (ops->reset)
 		ops->reset(qdisc);
