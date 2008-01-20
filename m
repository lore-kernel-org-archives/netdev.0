From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 03/05]: Introduce child qdisc helpers
Date: Sun, 20 Jan 2008 19:28:53 +0100 (MET)
Message-ID: <20080120182852.10972.63289.sendpatchset@localhost.localdomain>
References: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64052 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717AbYATS2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 13:28:54 -0500
In-Reply-To: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a6d1954517202bffb14f5122756891d8c5b8e2e2
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:08:18 2008 +0100

    [NET_SCHED]: Introduce child qdisc helpers
    
    Introduce a few helpers to dispatch calls to child qdiscs without
    repeating the qdisc argument every time.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3ade673..decc339 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -180,6 +180,26 @@ extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto *fl);
 
+static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	return sch->enqueue(skb, sch);
+}
+
+static inline struct sk_buff *qdisc_dequeue(struct Qdisc *sch)
+{
+	return sch->dequeue(sch);
+}
+
+static inline int qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	return sch->ops->requeue(skb, sch);
+}
+
+static inline unsigned int qdisc_drop(struct Qdisc *sch)
+{
+	return sch->ops->drop ? sch->ops->drop(sch) : 0;
+}
+
 static inline int __qdisc_q_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 					 struct sk_buff_head *list)
 {
@@ -278,7 +298,7 @@ static inline unsigned int qdisc_q_drop(struct Qdisc *sch)
 	return __qdisc_q_drop(sch, &sch->q);
 }
 
-static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
+static inline int qdisc_drop_skb(struct sk_buff *skb, struct Qdisc *sch)
 {
 	kfree_skb(skb);
 	sch->qstats.drops++;
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 507fb48..ac374eb 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -19,7 +19,7 @@
 
 static int blackhole_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_SUCCESS;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6afd59e..8e186e1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -347,7 +347,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 		return __qdisc_q_enqueue_tail(skb, qdisc, list);
 	}
 
-	return qdisc_drop(skb, qdisc);
+	return qdisc_drop_skb(skb, qdisc);
 }
 
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index d933565..ca65e7c 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -233,10 +233,10 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	q->stats.pdrop++;
 drop:
-	return qdisc_drop(skb, sch);
+	return qdisc_drop_skb(skb, sch);
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_CN;
 }
 
@@ -316,7 +316,7 @@ static unsigned int gred_drop(struct Qdisc* sch)
 				red_start_of_idle_period(&q->parms);
 		}
 
-		qdisc_drop(skb, sch);
+		qdisc_drop_skb(skb, sch);
 		return len;
 	}
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 699f83d..acf06d9 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -104,7 +104,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return ret;
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_CN;
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index c58fa6e..0b46589 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -257,7 +257,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	 * i.e. drop _this_ packet.
 	 */
 	if (q->qs[x].qlen >= q->limit)
-		return qdisc_drop(skb, sch);
+		return qdisc_drop_skb(skb, sch);
 
 	sch->qstats.backlog += skb->len;
 	__skb_queue_tail(&q->qs[x], skb);
