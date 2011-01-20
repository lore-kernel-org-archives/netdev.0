From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched:  move TCQ_F_THROTTLED flag
Date: Thu, 20 Jan 2011 16:27:16 +0100
Message-ID: <1295537236.2825.286.camel@edumazet-laptop>
References: <1295517052.2733.14.camel@edumazet-laptop>
	 <1295518636.2825.4.camel@edumazet-laptop>
	 <1295531299.2825.175.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60058 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751Ab1ATP2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 10:28:13 -0500
Received: by wwa36 with SMTP id 36so764927wwa.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 07:28:11 -0800 (PST)
In-Reply-To: <1295531299.2825.175.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 371121057607e (net: QDISC_STATE_RUNNING dont need atomic bit
ops) I moved QDISC_STATE_RUNNING flag to __state container, located in
the cache line containing qdisc lock and often dirtied fields.

I now move TCQ_F_THROTTLED bit too, so that we let first cache line read
mostly, and shared by all cpus. This should speedup HTB/CBQ for example.

Not using test_bit()/__clear_bit()/__test_and_set_bit allows to use an
"unsigned int" for __state container, reducing by 8 bytes Qdisc size.

Introduce helpers to hide implementation details.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jesper Dangaard Brouer <hawk@diku.dk>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Jamal Hadi Salim <hadi@cyberus.ca>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 include/net/sch_generic.h |   38 ++++++++++++++++++++++++++----------
 net/sched/sch_api.c       |    6 ++---
 net/sched/sch_cbq.c       |    6 ++---
 net/sched/sch_hfsc.c      |    2 -
 net/sched/sch_htb.c       |    4 +--
 net/sched/sch_netem.c     |    2 -
 net/sched/sch_tbf.c       |    2 -
 7 files changed, 39 insertions(+), 21 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e9eee99..f6345f5 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -31,7 +31,8 @@ enum qdisc_state_t {
  * following bits are only changed while qdisc lock is held
  */
 enum qdisc___state_t {
-	__QDISC___STATE_RUNNING,
+	__QDISC___STATE_RUNNING = 1,
+	__QDISC___STATE_THROTTLED = 2,
 };
 
 struct qdisc_size_table {
@@ -46,10 +47,9 @@ struct Qdisc {
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
 	unsigned		flags;
 #define TCQ_F_BUILTIN		1
-#define TCQ_F_THROTTLED		2
-#define TCQ_F_INGRESS		4
-#define TCQ_F_CAN_BYPASS	8
-#define TCQ_F_MQROOT		16
+#define TCQ_F_INGRESS		2
+#define TCQ_F_CAN_BYPASS	4
+#define TCQ_F_MQROOT		8
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
 	struct Qdisc_ops	*ops;
@@ -78,25 +78,43 @@ struct Qdisc {
 	unsigned long		state;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
-	unsigned long		__state;
+	unsigned int		__state;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
 	spinlock_t		busylock;
 };
 
-static inline bool qdisc_is_running(struct Qdisc *qdisc)
+static inline bool qdisc_is_running(const struct Qdisc *qdisc)
 {
-	return test_bit(__QDISC___STATE_RUNNING, &qdisc->__state);
+	return (qdisc->__state & __QDISC___STATE_RUNNING) ? true : false;
 }
 
 static inline bool qdisc_run_begin(struct Qdisc *qdisc)
 {
-	return !__test_and_set_bit(__QDISC___STATE_RUNNING, &qdisc->__state);
+	if (qdisc_is_running(qdisc))
+		return false;
+	qdisc->__state |= __QDISC___STATE_RUNNING;
+	return true;
 }
 
 static inline void qdisc_run_end(struct Qdisc *qdisc)
 {
-	__clear_bit(__QDISC___STATE_RUNNING, &qdisc->__state);
+	qdisc->__state &= ~__QDISC___STATE_RUNNING;
+}
+
+static inline bool qdisc_is_throttled(const struct Qdisc *qdisc)
+{
+	return (qdisc->__state & __QDISC___STATE_THROTTLED) ? true : false;
+}
+
+static inline void qdisc_throttled(struct Qdisc *qdisc)
+{
+	qdisc->__state |= __QDISC___STATE_THROTTLED;
+}
+
+static inline void qdisc_unthrottled(struct Qdisc *qdisc)
+{
+	qdisc->__state &= ~__QDISC___STATE_THROTTLED;
 }
 
 struct Qdisc_class_ops {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 36ac0ec..374fcbe 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -473,7 +473,7 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
 						 timer);
 
-	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
+	qdisc_unthrottled(wd->qdisc);
 	__netif_schedule(qdisc_root(wd->qdisc));
 
 	return HRTIMER_NORESTART;
@@ -495,7 +495,7 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 		     &qdisc_root_sleeping(wd->qdisc)->state))
 		return;
 
-	wd->qdisc->flags |= TCQ_F_THROTTLED;
+	qdisc_throttled(wd->qdisc);
 	time = ktime_set(0, 0);
 	time = ktime_add_ns(time, PSCHED_TICKS2NS(expires));
 	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
@@ -505,7 +505,7 @@ EXPORT_SYMBOL(qdisc_watchdog_schedule);
 void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 {
 	hrtimer_cancel(&wd->timer);
-	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
+	qdisc_unthrottled(wd->qdisc);
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 4aaf44c..25ed522 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -351,7 +351,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 {
 	int toplevel = q->toplevel;
 
-	if (toplevel > cl->level && !(cl->q->flags & TCQ_F_THROTTLED)) {
+	if (toplevel > cl->level && !(qdisc_is_throttled(cl->q))) {
 		psched_time_t now;
 		psched_tdiff_t incr;
 
@@ -625,7 +625,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
 	}
 
-	sch->flags &= ~TCQ_F_THROTTLED;
+	qdisc_unthrottled(sch);
 	__netif_schedule(qdisc_root(sch));
 	return HRTIMER_NORESTART;
 }
@@ -974,7 +974,7 @@ cbq_dequeue(struct Qdisc *sch)
 		skb = cbq_dequeue_1(sch);
 		if (skb) {
 			sch->q.qlen--;
-			sch->flags &= ~TCQ_F_THROTTLED;
+			qdisc_unthrottled(sch);
 			return skb;
 		}
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index dea4009..b632d92 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1664,7 +1664,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		set_passive(cl);
 	}
 
-	sch->flags &= ~TCQ_F_THROTTLED;
+	qdisc_unthrottled(sch);
 	sch->q.qlen--;
 
 	return skb;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3e86fd3..39db75c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -865,7 +865,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	skb = __skb_dequeue(&q->direct_queue);
 	if (skb != NULL) {
-		sch->flags &= ~TCQ_F_THROTTLED;
+		qdisc_unthrottled(sch);
 		sch->q.qlen--;
 		return skb;
 	}
@@ -901,7 +901,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 			skb = htb_dequeue_tree(q, prio, level);
 			if (likely(skb != NULL)) {
 				sch->q.qlen--;
-				sch->flags &= ~TCQ_F_THROTTLED;
+				qdisc_unthrottled(sch);
 				goto fin;
 			}
 		}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index c2bbbe6..c26ef36 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -266,7 +266,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	if (sch->flags & TCQ_F_THROTTLED)
+	if (qdisc_is_throttled(sch))
 		return NULL;
 
 	skb = q->qdisc->ops->peek(q->qdisc);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 475edfb..86c0166 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -185,7 +185,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 			q->tokens = toks;
 			q->ptokens = ptoks;
 			sch->q.qlen--;
-			sch->flags &= ~TCQ_F_THROTTLED;
+			qdisc_unthrottled(sch);
 			return skb;
 		}
 


