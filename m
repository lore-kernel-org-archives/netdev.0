From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] net_sched: remove generic throttled management
Date: Fri, 10 Jun 2016 16:41:39 -0700
Message-ID: <1465602099-15808-5-git-send-email-edumazet@google.com>
References: <1465602099-15808-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35390 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932386AbcFJXly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 19:41:54 -0400
Received: by mail-pf0-f171.google.com with SMTP id c2so27527977pfa.2
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 16:41:53 -0700 (PDT)
In-Reply-To: <1465602099-15808-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__QDISC_STATE_THROTTLED bit manipulation is rather expensive
for HTB and few others.

I already removed it for sch_fq in commit f2600cf02b5b
("net: sched: avoid costly atomic operation in fq_dequeue()")
and so far nobody complained.

When one ore more packets are stuck in one or more throttled
HTB class, a htb dequeue() performs two atomic operations
to clear/set __QDISC_STATE_THROTTLED bit, while root qdisc
lock is held.

Removing this pair of atomic operations bring me a 8 % performance
increase on 200 TCP_RR tests, in presence of throttled classes.

This patch has no side effect, since nothing actually uses
disc_is_throttled() anymore.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/pkt_sched.h   |  4 ++--
 include/net/sch_generic.h | 16 ----------------
 net/sched/sch_api.c       |  7 +------
 net/sched/sch_cbq.c       |  2 --
 net/sched/sch_fq.c        |  3 +--
 net/sched/sch_hfsc.c      |  1 -
 net/sched/sch_htb.c       |  3 +--
 net/sched/sch_netem.c     |  1 -
 net/sched/sch_tbf.c       |  4 +---
 9 files changed, 6 insertions(+), 35 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index fea53f4d92ca..7caa99b482c6 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -67,12 +67,12 @@ struct qdisc_watchdog {
 };
 
 void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
-void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires, bool throttle);
+void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires);
 
 static inline void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
 					   psched_time_t expires)
 {
-	qdisc_watchdog_schedule_ns(wd, PSCHED_TICKS2NS(expires), true);
+	qdisc_watchdog_schedule_ns(wd, PSCHED_TICKS2NS(expires));
 }
 
 void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9f3581980c15..9a0d177884c6 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -26,7 +26,6 @@ struct qdisc_rate_table {
 enum qdisc_state_t {
 	__QDISC_STATE_SCHED,
 	__QDISC_STATE_DEACTIVATED,
-	__QDISC_STATE_THROTTLED,
 };
 
 struct qdisc_size_table {
@@ -125,21 +124,6 @@ static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
 #endif
 }
 
-static inline bool qdisc_is_throttled(const struct Qdisc *qdisc)
-{
-	return test_bit(__QDISC_STATE_THROTTLED, &qdisc->state) ? true : false;
-}
-
-static inline void qdisc_throttled(struct Qdisc *qdisc)
-{
-	set_bit(__QDISC_STATE_THROTTLED, &qdisc->state);
-}
-
-static inline void qdisc_unthrottled(struct Qdisc *qdisc)
-{
-	clear_bit(__QDISC_STATE_THROTTLED, &qdisc->state);
-}
-
 struct Qdisc_class_ops {
 	/* Child qdisc manipulation */
 	struct netdev_queue *	(*select_queue)(struct Qdisc *, struct tcmsg *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d4a8bbfcc953..401eda6de682 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -583,7 +583,6 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 						 timer);
 
 	rcu_read_lock();
-	qdisc_unthrottled(wd->qdisc);
 	__netif_schedule(qdisc_root(wd->qdisc));
 	rcu_read_unlock();
 
@@ -598,15 +597,12 @@ void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_watchdog_init);
 
-void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires, bool throttle)
+void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires)
 {
 	if (test_bit(__QDISC_STATE_DEACTIVATED,
 		     &qdisc_root_sleeping(wd->qdisc)->state))
 		return;
 
-	if (throttle)
-		qdisc_throttled(wd->qdisc);
-
 	if (wd->last_expires == expires)
 		return;
 
@@ -620,7 +616,6 @@ EXPORT_SYMBOL(qdisc_watchdog_schedule_ns);
 void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 {
 	hrtimer_cancel(&wd->timer);
-	qdisc_unthrottled(wd->qdisc);
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 6e61f9aa8783..a29fd811d7b9 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -513,7 +513,6 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS_PINNED);
 	}
 
-	qdisc_unthrottled(sch);
 	__netif_schedule(qdisc_root(sch));
 	return HRTIMER_NORESTART;
 }
@@ -819,7 +818,6 @@ cbq_dequeue(struct Qdisc *sch)
 		if (skb) {
 			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
-			qdisc_unthrottled(sch);
 			return skb;
 		}
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 3c6a47d66a04..f49c81e91acd 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -445,8 +445,7 @@ begin:
 		if (!head->first) {
 			if (q->time_next_delayed_flow != ~0ULL)
 				qdisc_watchdog_schedule_ns(&q->watchdog,
-							   q->time_next_delayed_flow,
-							   false);
+							   q->time_next_delayed_flow);
 			return NULL;
 		}
 	}
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index eb3d3f5aba80..bd08c363a26d 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1664,7 +1664,6 @@ hfsc_dequeue(struct Qdisc *sch)
 		set_passive(cl);
 	}
 
-	qdisc_unthrottled(sch);
 	qdisc_bstats_update(sch, skb);
 	qdisc_qstats_backlog_dec(sch, skb);
 	sch->q.qlen--;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index b74d06668ab4..07dcd2933f01 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -889,7 +889,6 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	if (skb != NULL) {
 ok:
 		qdisc_bstats_update(sch, skb);
-		qdisc_unthrottled(sch);
 		qdisc_qstats_backlog_dec(sch, skb);
 		sch->q.qlen--;
 		return skb;
@@ -929,7 +928,7 @@ ok:
 	}
 	qdisc_qstats_overlimit(sch);
 	if (likely(next_event > q->now))
-		qdisc_watchdog_schedule_ns(&q->watchdog, next_event, true);
+		qdisc_watchdog_schedule_ns(&q->watchdog, next_event);
 	else
 		schedule_work(&q->work);
 fin:
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2dbe732ca135..876df13c745a 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -587,7 +587,6 @@ tfifo_dequeue:
 	if (skb) {
 		qdisc_qstats_backlog_dec(sch, skb);
 deliver:
-		qdisc_unthrottled(sch);
 		qdisc_bstats_update(sch, skb);
 		return skb;
 	}
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 7fa3d6e1291c..c12df84d1078 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -254,14 +254,12 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 			q->ptokens = ptoks;
 			qdisc_qstats_backlog_dec(sch, skb);
 			sch->q.qlen--;
-			qdisc_unthrottled(sch);
 			qdisc_bstats_update(sch, skb);
 			return skb;
 		}
 
 		qdisc_watchdog_schedule_ns(&q->watchdog,
-					   now + max_t(long, -toks, -ptoks),
-					   true);
+					   now + max_t(long, -toks, -ptoks));
 
 		/* Maybe we have a shorter packet in the queue,
 		   which can be sent now. It sounds cool,
-- 
2.8.0.rc3.226.g39d4020
