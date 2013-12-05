From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: give visibility to mq slave qdiscs
Date: Thu, 05 Dec 2013 11:12:02 -0800
Message-ID: <1386270722.30495.210.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:52204 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab3LETME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 14:12:04 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so26246859pbc.7
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 11:12:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 6da7c8fcbcbd ("qdisc: allow setting default queuing discipline")
added the ability to change default qdisc from pfifo_fast to say fq

But as most modern ethernet devices are multiqueue, we cant really
see all the statistics from "tc -s qdisc show", as the default root
qdisc is mq.

This patch adds the calls to qdisc_list_add() to mq and mqprio

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 include/net/pkt_sched.h |    1 +
 net/sched/sch_api.c     |    3 ++-
 net/sched/sch_mq.c      |   13 +++++++++----
 net/sched/sch_mqprio.c  |   10 ++++++----
 4 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 59ec3cd15d68..891d80d2c4d2 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -88,6 +88,7 @@ int unregister_qdisc(struct Qdisc_ops *qops);
 void qdisc_get_default(char *id, size_t len);
 int qdisc_set_default(const char *id);
 
+void qdisc_list_add(struct Qdisc *q);
 void qdisc_list_del(struct Qdisc *q);
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index cd81505662b8..547b4a88ae2a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -271,11 +271,12 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 	return NULL;
 }
 
-static void qdisc_list_add(struct Qdisc *q)
+void qdisc_list_add(struct Qdisc *q)
 {
 	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
 		list_add_tail(&q->list, &qdisc_dev(q)->qdisc->list);
 }
+EXPORT_SYMBOL(qdisc_list_add);
 
 void qdisc_list_del(struct Qdisc *q)
 {
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 2e56185736d6..a8b2864a696b 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -78,14 +78,19 @@ static void mq_attach(struct Qdisc *sch)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct mq_sched *priv = qdisc_priv(sch);
-	struct Qdisc *qdisc;
+	struct Qdisc *qdisc, *old;
 	unsigned int ntx;
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
 		qdisc = priv->qdiscs[ntx];
-		qdisc = dev_graft_qdisc(qdisc->dev_queue, qdisc);
-		if (qdisc)
-			qdisc_destroy(qdisc);
+		old = dev_graft_qdisc(qdisc->dev_queue, qdisc);
+		if (old)
+			qdisc_destroy(old);
+#ifdef CONFIG_NET_SCHED
+		if (ntx < dev->real_num_tx_queues)
+			qdisc_list_add(qdisc);
+#endif
+
 	}
 	kfree(priv->qdiscs);
 	priv->qdiscs = NULL;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index d44c868cb537..6749e2f540d0 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -167,15 +167,17 @@ static void mqprio_attach(struct Qdisc *sch)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
-	struct Qdisc *qdisc;
+	struct Qdisc *qdisc, *old;
 	unsigned int ntx;
 
 	/* Attach underlying qdisc */
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
 		qdisc = priv->qdiscs[ntx];
-		qdisc = dev_graft_qdisc(qdisc->dev_queue, qdisc);
-		if (qdisc)
-			qdisc_destroy(qdisc);
+		old = dev_graft_qdisc(qdisc->dev_queue, qdisc);
+		if (old)
+			qdisc_destroy(old);
+		if (ntx < dev->real_num_tx_queues)
+			qdisc_list_add(qdisc);
 	}
 	kfree(priv->qdiscs);
 	priv->qdiscs = NULL;
