From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 15/15] net: sched: drop ingress qdisc lock
Date: Sun, 24 Aug 2014 17:54:21 -0700
Message-ID: <20140825005420.2180.4143.stgit@nitbit.x32>
References: <20140825004659.2180.35028.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35514 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188AbaHYAyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 20:54:39 -0400
Received: by mail-ob0-f169.google.com with SMTP id uz6so8219123obc.0
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 17:54:38 -0700 (PDT)
In-Reply-To: <20140825004659.2180.35028.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the previous patches to make the filters RCU safe and
support per cpu counters we can drop the qdisc lock around
the ingress qdisc hook.

This is possible because the ingress qdisc is a very basic
qdisc and only updates stats and runs tc_classify. Its the
simplest qdiscs we have.

In order for the per-cpu counters to get invoked the
ingress qdisc must set the LLQDISC flag. We could use per-cpu
counters on all counters but it is only necessary when the
qdisc lock is not held.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/dev.c          |    2 --
 net/sched/sch_ingress.c |    6 ++++++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 36d4e6d..5339d11 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3510,10 +3510,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 
 	q = rcu_dereference(rxq->qdisc);
 	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
 		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
 			result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
 	}
 
 	return result;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 2423d7b..a81b333 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -88,6 +88,11 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 }
 
 /* ------------------------------------------------------------- */
+static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	sch->flags |= TCQ_F_LLQDISC;
+	return 0;
+}
 
 static void ingress_destroy(struct Qdisc *sch)
 {
@@ -122,6 +127,7 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 };
 
 static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
+	.init		=	ingress_init,
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
