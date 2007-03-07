From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] use ktime for packet scheduling
Date: Wed, 7 Mar 2007 15:59:36 -0800
Message-ID: <20070307155936.74bf8abe@dxpl.pdx.osdl.net>
References: <20070222143047.1631b93e@freekitty>
	<45E04901.1040505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39939 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992788AbXCHAFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 19:05:23 -0500
In-Reply-To: <45E04901.1040505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the lastest version of the netem patch to use hrtimers.
It is against the current net tree, so it will need adjusting to fit
with new psched/ktime stuff.

---
 include/net/pkt_sched.h |    3 ++
 net/sched/sch_api.c     |   30 +++++++++++++++++++++
 net/sched/sch_netem.c   |   68 ++++++++++++++++++++++++------------------------
 3 files changed, 67 insertions(+), 34 deletions(-)

--- netem-dev.orig/net/sched/sch_netem.c
+++ netem-dev/net/sched/sch_netem.c
@@ -54,7 +54,7 @@
 
 struct netem_sched_data {
 	struct Qdisc	*qdisc;
-	struct timer_list timer;
+	struct hrtimer   timer;
 
 	u32 latency;
 	u32 loss;
@@ -78,8 +78,9 @@ struct netem_sched_data {
 };
 
 /* Time stamp put into socket buffer control block */
+/* TODO: move this to skb->timestamp */
 struct netem_skb_cb {
-	psched_time_t	time_to_send;
+	ktime_t	due_time;
 };
 
 /* init_crandom - initialize correlated random number generator
@@ -207,14 +208,14 @@ static int netem_enqueue(struct sk_buff 
 	if (q->gap == 0 		/* not doing reordering */
 	    || q->counter < q->gap 	/* inside last reordering gap */
 	    || q->reorder < get_crandom(&q->reorder_cor)) {
-		psched_time_t now;
-		psched_tdiff_t delay;
+		u64 ns;
 
-		delay = tabledist(q->latency, q->jitter,
-				  &q->delay_cor, q->delay_dist);
+		ns = tabledist(q->latency, q->jitter,
+			       &q->delay_cor, q->delay_dist) * 1000ul;
+
+
+		cb->due_time = ktime_add_ns(ktime_get(), ns);
 
-		PSCHED_GET_TIME(now);
-		PSCHED_TADD2(now, delay, cb->time_to_send);
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
 	} else {
@@ -222,7 +223,7 @@ static int netem_enqueue(struct sk_buff 
 		 * Do re-ordering by putting one out of N packets at the front
 		 * of the queue.
 		 */
-		PSCHED_GET_TIME(cb->time_to_send);
+		cb->due_time = ktime_get();
 		q->counter = 0;
 		ret = q->qdisc->ops->requeue(skb, q->qdisc);
 	}
@@ -273,41 +274,40 @@ static struct sk_buff *netem_dequeue(str
 	if (skb) {
 		const struct netem_skb_cb *cb
 			= (const struct netem_skb_cb *)skb->cb;
-		psched_time_t now;
+		ktime_t now = ktime_get();
 
-		/* if more time remaining? */
-		PSCHED_GET_TIME(now);
-
-		if (PSCHED_TLESS(cb->time_to_send, now)) {
+ 		/* if time has come to send? */
+ 		if (now.tv64 <= cb->due_time.tv64) {
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
 			sch->flags &= ~TCQ_F_THROTTLED;
 			return skb;
-		} else {
-			psched_tdiff_t delay = PSCHED_TDIFF(cb->time_to_send, now);
-
-			if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
-				qdisc_tree_decrease_qlen(q->qdisc, 1);
-				sch->qstats.drops++;
-				printk(KERN_ERR "netem: queue discpline %s could not requeue\n",
-				       q->qdisc->ops->id);
-			}
+		}
 
-			mod_timer(&q->timer, jiffies + PSCHED_US2JIFFIE(delay));
-			sch->flags |= TCQ_F_THROTTLED;
+		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
+			qdisc_tree_decrease_qlen(q->qdisc, 1);
+			sch->qstats.drops++;
+			printk(KERN_ERR "netem: queue discpline %s could not requeue\n",
+			       q->qdisc->ops->id);
 		}
+
+ 		hrtimer_start(&q->timer, cb->due_time, HRTIMER_MODE_ABS);
+		sch->flags |= TCQ_F_THROTTLED;
 	}
 
 	return NULL;
 }
 
-static void netem_watchdog(unsigned long arg)
+static enum hrtimer_restart netem_watchdog(struct hrtimer *hrt)
 {
-	struct Qdisc *sch = (struct Qdisc *)arg;
+	struct netem_sched_data *q
+		= container_of(hrt, struct netem_sched_data, timer);
+	struct Qdisc *sch = q->qdisc;
 
 	pr_debug("netem_watchdog qlen=%d\n", sch->q.qlen);
 	sch->flags &= ~TCQ_F_THROTTLED;
 	netif_schedule(sch->dev);
+	return HRTIMER_NORESTART;
 }
 
 static void netem_reset(struct Qdisc *sch)
@@ -317,7 +317,7 @@ static void netem_reset(struct Qdisc *sc
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
 	sch->flags &= ~TCQ_F_THROTTLED;
-	del_timer_sync(&q->timer);
+	hrtimer_cancel(&q->timer);
 }
 
 /* Pass size change message down to embedded FIFO */
@@ -502,7 +502,8 @@ static int tfifo_enqueue(struct sk_buff 
 			const struct netem_skb_cb *cb
 				= (const struct netem_skb_cb *)skb->cb;
 
-			if (!PSCHED_TLESS(ncb->time_to_send, cb->time_to_send))
+			if (ktime_to_ns(ktime_sub(ncb->due_time,
+						  cb->due_time)) >= 0)
 				break;
 		}
 
@@ -567,9 +568,8 @@ static int netem_init(struct Qdisc *sch,
 	if (!opt)
 		return -EINVAL;
 
-	init_timer(&q->timer);
+	hrtimer_init(&q->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	q->timer.function = netem_watchdog;
-	q->timer.data = (unsigned long) sch;
 
 	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
 				     TC_H_MAKE(sch->handle, 1));
@@ -590,7 +590,7 @@ static void netem_destroy(struct Qdisc *
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 
-	del_timer_sync(&q->timer);
+	hrtimer_cancel(&q->timer);
 	qdisc_destroy(q->qdisc);
 	kfree(q->delay_dist);
 }
@@ -605,8 +605,8 @@ static int netem_dump(struct Qdisc *sch,
 	struct tc_netem_reorder reorder;
 	struct tc_netem_corrupt corrupt;
 
-	qopt.latency = q->latency;
-	qopt.jitter = q->jitter;
+	qopt.latency = psched_usecs2ticks(q->latency);
+	qopt.jitter = psched_usecs2ticks(q->jitter);
 	qopt.limit = q->limit;
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
--- netem-dev.orig/include/net/pkt_sched.h
+++ netem-dev/include/net/pkt_sched.h
@@ -239,4 +239,7 @@ static inline unsigned psched_mtu(struct
 	return dev->hard_header ? mtu + dev->hard_header_len : mtu;
 }
 
+extern unsigned long psched_usecs2ticks(unsigned long us);
+extern unsigned long psched_ticks2usecs(unsigned long ticks);
+
 #endif
--- netem-dev.orig/net/sched/sch_api.c
+++ netem-dev/net/sched/sch_api.c
@@ -1178,6 +1178,36 @@ reclassify:
 static int psched_us_per_tick = 1;
 static int psched_tick_per_us = 1;
 
+
+/**
+ * psched_ticks2usecs - convert from scaled PSCHED ticks to usecs
+ * @ticks: pscehed ticks
+ * Returns time in microseconds
+ */
+unsigned long psched_ticks2usecs(unsigned long ticks)
+{
+	u64 t = ticks;
+
+	t *= psched_us_per_tick;
+	do_div(t, psched_tick_per_us);
+	return t;
+}
+EXPORT_SYMBOL(psched_ticks2usecs);
+
+/**
+ * psched_usecs2ticks - convert from usecs to PSCHED ticks
+ * @us: time in microseconds
+ */
+unsigned long psched_usecs2ticks(unsigned long us)
+{
+	u64 t = us;
+
+	t *= psched_tick_per_us;
+	do_div(t, psched_us_per_tick);
+	return t;
+}
+EXPORT_SYMBOL(psched_usecs2ticks);
+
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
