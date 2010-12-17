From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 4/4] net_sched: add MQSAFE flag to qdisc to
	identify mq like qdiscs
Date: Fri, 17 Dec 2010 07:34:56 -0800
Message-ID: <20101217153456.12170.17327.stgit@jf-dev1-dcblab>
References: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, eric.dumazet@gmail.com, nhorman@tuxdriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50171 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755173Ab0LQPhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 10:37:33 -0500
In-Reply-To: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a MQSAFE flag to the qdisc schedulers that can be safely
managed by sch_mclass. Without this flag schedulers that are
not aware of multiple tx queues can be grafted under the
mclass qdisc. Allowing incorrect qdiscs to be grafted causes
an invalid mapping from qdisc's to netdevice queues.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/sch_generic.h |    1 +
 net/sched/sch_generic.c   |    2 +-
 net/sched/sch_mclass.c    |    5 +++--
 net/sched/sch_mq.c        |    3 +++
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2bbcd09..791df75 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -50,6 +50,7 @@ struct Qdisc {
 #define TCQ_F_INGRESS		4
 #define TCQ_F_CAN_BYPASS	8
 #define TCQ_F_MQROOT		16
+#define TCQ_F_MQSAFE		32
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
 	struct Qdisc_ops	*ops;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 73ed9b7..1bcc0ed 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -376,7 +376,7 @@ static struct netdev_queue noop_netdev_queue = {
 struct Qdisc noop_qdisc = {
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
-	.flags		=	TCQ_F_BUILTIN,
+	.flags		=	TCQ_F_BUILTIN | TCQ_F_MQSAFE,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
diff --git a/net/sched/sch_mclass.c b/net/sched/sch_mclass.c
index 551b660..444492a 100644
--- a/net/sched/sch_mclass.c
+++ b/net/sched/sch_mclass.c
@@ -178,15 +178,16 @@ static int mclass_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
 	struct mclass_sched *priv = qdisc_priv(sch);
 	unsigned long ntc = cl - 1;
 
-	if (ntc >= dev->num_tc)
+	if (ntc >= dev->num_tc || (new && !(new->flags & TCQ_F_MQSAFE)))
 		return -EINVAL;
 
 	if (dev->flags & IFF_UP)
 		dev_deactivate(dev);
 
-	*old = priv->qdiscs[ntc];
 	if (new == NULL)
 		new = &noop_qdisc;
+
+	*old = priv->qdiscs[ntc];
 	priv->qdiscs[ntc] = new;
 	qdisc_reset(*old);
 
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 35ed26d..493eaab 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -94,6 +94,9 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 
 	if (!priv->num_tc)
 		sch->flags |= TCQ_F_MQROOT;
+	else
+		sch->flags |= TCQ_F_MQSAFE;
+
 	return 0;
 
 err:

