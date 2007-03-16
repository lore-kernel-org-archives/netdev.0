From: Martin Devera <devik@cdi.cz>
Subject: [Fwd: [NET_SCHED 09/10]: sch_htb: use hrtimer based watchdog]
Date: Fri, 16 Mar 2007 10:30:42 +0100
Message-ID: <45FA63C2.90802@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:49435 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933290AbXCPKCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 06:02:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_htb: use hrtimer based watchdog

Signed-off-by: Patrick McHardy <kaber@trash.net>
Acked-by: Martin Devera <devik@cdi.cz>

---
commit a5eaa252c5da48fef25a308ebc99b4020dad7f64
tree a609ff508f5ec9a93df1ace8f814aa0a71a5ff97
parent 2d548d3ea10cb1b49db8913fbab32811d9e7c3d0
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:17:30 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:17:30 +0100

  net/sched/sch_htb.c |   91 +++++++++++++++++----------------------------------
  1 files changed, 31 insertions(+), 60 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 97cbb9a..b00cef7 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -128,7 +128,7 @@ #endif
  	} un;
  	struct rb_node node[TC_HTB_NUMPRIO];	/* node for self or feed tree */
  	struct rb_node pq_node;	/* node for event queue */
-	unsigned long pq_key;	/* the same type as jiffies global */
+	psched_time_t pq_key;

  	int prio_activity;	/* for which prios are we active */
  	enum htb_cmode cmode;	/* current mode of the class */
@@ -179,10 +179,7 @@ struct htb_sched {
  	struct rb_root wait_pq[TC_HTB_MAXDEPTH];

  	/* time of nearest event per level (row) */
-	unsigned long near_ev_cache[TC_HTB_MAXDEPTH];
-
-	/* cached value of jiffies in dequeue */
-	unsigned long jiffies;
+	psched_time_t near_ev_cache[TC_HTB_MAXDEPTH];

  	/* whether we hit non-work conserving class during this dequeue; we use */
  	int nwc_hit;		/* this to disable mindelay complaint in dequeue */
@@ -195,7 +192,7 @@ struct htb_sched {

  	int rate2quantum;	/* quant = rate / rate2quantum */
  	psched_time_t now;	/* cached dequeue time */
-	struct timer_list timer;	/* send delay timer */
+	struct qdisc_watchdog watchdog;
  #ifdef HTB_RATECM
  	struct timer_list rttim;	/* rate computer timer */
  	int recmp_bucket;	/* which hash bucket to recompute next */
@@ -342,19 +339,19 @@ static void htb_add_to_wait_tree(struct
  {
  	struct rb_node **p = &q->wait_pq[cl->level].rb_node, *parent = NULL;

-	cl->pq_key = q->jiffies + PSCHED_US2JIFFIE(delay);
-	if (cl->pq_key == q->jiffies)
+	cl->pq_key = q->now + delay;
+	if (cl->pq_key == q->now)
  		cl->pq_key++;

  	/* update the nearest event cache */
-	if (time_after(q->near_ev_cache[cl->level], cl->pq_key))
+	if (q->near_ev_cache[cl->level] > cl->pq_key)
  		q->near_ev_cache[cl->level] = cl->pq_key;

  	while (*p) {
  		struct htb_class *c;
  		parent = *p;
  		c = rb_entry(parent, struct htb_class, pq_node);
-		if (time_after_eq(cl->pq_key, c->pq_key))
+		if (cl->pq_key >= c->pq_key)
  			p = &parent->rb_right;
  		else
  			p = &parent->rb_left;
@@ -679,14 +676,6 @@ static int htb_requeue(struct sk_buff *s
  	return NET_XMIT_SUCCESS;
  }

-static void htb_timer(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc *)arg;
-	sch->flags &= ~TCQ_F_THROTTLED;
-	wmb();
-	netif_schedule(sch->dev);
-}
-
  #ifdef HTB_RATECM
  #define RT_GEN(D,R) R+=D-(R/HTB_EWMAC);D=0
  static void htb_rate_timer(unsigned long arg)
@@ -778,11 +767,11 @@ #endif
  /**
   * htb_do_events - make mode changes to classes at the level
   *
- * Scans event queue for pending events and applies them. Returns jiffies to
+ * Scans event queue for pending events and applies them. Returns time of
   * next pending event (0 for no event in pq).
- * Note: Aplied are events whose have cl->pq_key <= jiffies.
+ * Note: Applied are events whose have cl->pq_key <= q->now.
   */
-static long htb_do_events(struct htb_sched *q, int level)
+static psched_time_t htb_do_events(struct htb_sched *q, int level)
  {
  	int i;

@@ -795,9 +784,9 @@ static long htb_do_events(struct htb_sch
  			return 0;

  		cl = rb_entry(p, struct htb_class, pq_node);
-		if (time_after(cl->pq_key, q->jiffies)) {
-			return cl->pq_key - q->jiffies;
-		}
+		if (cl->pq_key > q->now)
+			return cl->pq_key;
+
  		htb_safe_rb_erase(p, q->wait_pq + level);
  		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32) cl->mbuffer);
  		htb_change_class_mode(q, cl, &diff);
@@ -806,7 +795,7 @@ static long htb_do_events(struct htb_sch
  	}
  	if (net_ratelimit())
  		printk(KERN_WARNING "htb: too many events !\n");
-	return HZ / 10;
+	return q->now + PSCHED_TICKS_PER_SEC / 10;
  }

  /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
@@ -958,30 +947,12 @@ next:
  	return skb;
  }

-static void htb_delay_by(struct Qdisc *sch, long delay)
-{
-	struct htb_sched *q = qdisc_priv(sch);
-	if (delay <= 0)
-		delay = 1;
-	if (unlikely(delay > 5 * HZ)) {
-		if (net_ratelimit())
-			printk(KERN_INFO "HTB delay %ld > 5sec\n", delay);
-		delay = 5 * HZ;
-	}
-	/* why don't use jiffies here ? because expires can be in past */
-	mod_timer(&q->timer, q->jiffies + delay);
-	sch->flags |= TCQ_F_THROTTLED;
-	sch->qstats.overlimits++;
-}
-
  static struct sk_buff *htb_dequeue(struct Qdisc *sch)
  {
  	struct sk_buff *skb = NULL;
  	struct htb_sched *q = qdisc_priv(sch);
  	int level;
-	long min_delay;
-
-	q->jiffies = jiffies;
+	psched_time_t next_event;

  	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
  	skb = __skb_dequeue(&q->direct_queue);
@@ -995,21 +966,23 @@ static struct sk_buff *htb_dequeue(struc
  		goto fin;
  	PSCHED_GET_TIME(q->now);

-	min_delay = LONG_MAX;
+	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
  	q->nwc_hit = 0;
  	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
  		/* common case optimization - skip event handler quickly */
  		int m;
-		long delay;
-		if (time_after_eq(q->jiffies, q->near_ev_cache[level])) {
-			delay = htb_do_events(q, level);
-			q->near_ev_cache[level] =
-			    q->jiffies + (delay ? delay : HZ);
+		psched_time_t event;
+
+		if (q->now >= q->near_ev_cache[level]) {
+			event = htb_do_events(q, level);
+			q->near_ev_cache[level] = event ? event :
+							  PSCHED_TICKS_PER_SEC;
  		} else
-			delay = q->near_ev_cache[level] - q->jiffies;
+			event = q->near_ev_cache[level];
+
+		if (event && next_event > event)
+			next_event = event;

-		if (delay && min_delay > delay)
-			min_delay = delay;
  		m = ~q->row_mask[level];
  		while (m != (int)(-1)) {
  			int prio = ffz(m);
@@ -1022,7 +995,8 @@ static struct sk_buff *htb_dequeue(struc
  			}
  		}
  	}
-	htb_delay_by(sch, min_delay > 5 * HZ ? 5 * HZ : min_delay);
+	sch->qstats.overlimits++;
+	qdisc_watchdog_schedule(&q->watchdog, next_event);
  fin:
  	return skb;
  }
@@ -1075,8 +1049,7 @@ static void htb_reset(struct Qdisc *sch)

  		}
  	}
-	sch->flags &= ~TCQ_F_THROTTLED;
-	del_timer(&q->timer);
+	qdisc_watchdog_cancel(&q->watchdog);
  	__skb_queue_purge(&q->direct_queue);
  	sch->q.qlen = 0;
  	memset(q->row, 0, sizeof(q->row));
@@ -1113,14 +1086,12 @@ static int htb_init(struct Qdisc *sch, s
  	for (i = 0; i < TC_HTB_NUMPRIO; i++)
  		INIT_LIST_HEAD(q->drops + i);

-	init_timer(&q->timer);
+	qdisc_watchdog_init(&q->watchdog, sch);
  	skb_queue_head_init(&q->direct_queue);

  	q->direct_qlen = sch->dev->tx_queue_len;
  	if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
  		q->direct_qlen = 2;
-	q->timer.function = htb_timer;
-	q->timer.data = (unsigned long)sch;

  #ifdef HTB_RATECM
  	init_timer(&q->rttim);
@@ -1341,7 +1312,7 @@ static void htb_destroy(struct Qdisc *sc
  {
  	struct htb_sched *q = qdisc_priv(sch);

-	del_timer_sync(&q->timer);
+	qdisc_watchdog_cancel(&q->watchdog);
  #ifdef HTB_RATECM
  	del_timer_sync(&q->rttim);
  #endif
