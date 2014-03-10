From: John Fastabend <john.fastabend@gmail.com>
Subject: [RCU PATCH 14/14] net: sched: drop ingress qdisc lock
Date: Mon, 10 Mar 2014 10:09:02 -0700
Message-ID: <20140310170900.3011.95014.stgit@nitbit.x32>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:34550 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbaCJRJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:09:17 -0400
Received: by mail-ob0-f171.google.com with SMTP id wn1so7337651obc.30
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:09:17 -0700 (PDT)
In-Reply-To: <20140310170008.3011.73599.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the previous patches to make the filters RCU safe and
support per cpu counters we can drop the qdisc lock around
the ingress qdisc hook.

This is possible because the ingress qdisc is a very basic
qdisc and only updates stats and runs tc_classify. Its the
simplest qdiscs we have.

In order for the per-cpu counters to get invoked the
ingress qdisc must set the LLQDISC flag.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/dev.c          |    2 --
 net/sched/sch_ingress.c |    6 ++++++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dc1aa6c..1f90a04 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3449,10 +3449,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 
 	q = rcu_dereference(rxq->qdisc);
 	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
 		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
 			result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
 	}
 
 	return result;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 86cc5ce..012f9dc 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -86,6 +86,11 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 }
 
 /* ------------------------------------------------------------- */
+static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	sch->flags |= TCQ_F_LLQDISC;
+	return 0;
+}
 
 static void ingress_destroy(struct Qdisc *sch)
 {
@@ -121,6 +126,7 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 };
 
 static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
+	.init		=	ingress_init,
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
