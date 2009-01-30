From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3 net-next] pkt_sched: sch_htb: Warn on too many
	events.
Date: Fri, 30 Jan 2009 10:17:25 +0000
Message-ID: <20090130101725.GC8882@ff.dom.local>
References: <20090128125230.GA6282@ff.dom.local> <49808544.5010304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:6439 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbZA3KRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 05:17:34 -0500
Received: by fg-out-1718.google.com with SMTP id 13so286551fge.17
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 02:17:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49808544.5010304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Changed In-Reply-To)
On Wed, Jan 28, 2009 at 05:20:36PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On 12-01-2009 11:22, Patrick McHardy wrote:
>>> It you don't mind adding the workqueue, I certainly would prefer
>>> it, but I'm also fine with this patch. I don't have a HTB setup
>>> or a testcase for this specific case, otherwise I'd simply do it
>>> myself.
>>
>> Here is an example of this workqueue. I hope I didn't miss your point,
>> but since I didn't find much difference in testing, I'd prefer not to
>> sign-off/merge this yet, at least until there are many reports on
>> "too many events" problem, and somebody finds it useful.
>
> No, this seems to be exactly what I meant. The differnce - yeah, it
> shouldn't make much, mainly wake up the qdisc earlier (but not too
> early) after "too many events" occured _and_ no further enqueue
> events wake up the qdisc anyways.

OK, thanks,
Jarek P.
-------------> PATCH 3/3
pkt_sched: sch_htb: Use workqueue to schedule after too many events.

Patrick McHardy <kaber@trash.net> suggested using a workqueue instead
of hrtimers to trigger netif_schedule() when there is a problem with
setting exact time of this event: 'The differnce - yeah, it shouldn't
make much, mainly wake up the qdisc earlier (but not too early) after
"too many events" occured _and_ no further enqueue events wake up the
qdisc anyways.'

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
diff -Nurp c/net/sched/sch_htb.c d/net/sched/sch_htb.c
--- c/net/sched/sch_htb.c	2009-01-30 08:48:41.000000000 +0000
+++ d/net/sched/sch_htb.c	2009-01-30 09:00:06.000000000 +0000
@@ -35,6 +35,7 @@
 #include <linux/list.h>
 #include <linux/compiler.h>
 #include <linux/rbtree.h>
+#include <linux/workqueue.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
@@ -156,6 +157,7 @@ struct htb_sched {
 
 #define HTB_WARN_TOOMANYEVENTS	0x1
 	unsigned int warned;	/* only one warning */
+	struct work_struct work;
 };
 
 /* find class in global hash table using given handle */
@@ -659,7 +661,7 @@ static void htb_charge_class(struct htb_
  * htb_do_events - make mode changes to classes at the level
  *
  * Scans event queue for pending events and applies them. Returns time of
- * next pending event (0 for no event in pq).
+ * next pending event (0 for no event in pq, q->now for too many events).
  * Note: Applied are events whose have cl->pq_key <= q->now.
  */
 static psched_time_t htb_do_events(struct htb_sched *q, int level,
@@ -687,12 +689,14 @@ static psched_time_t htb_do_events(struc
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
 	}
-	/* too much load - let's continue on next jiffie (including above) */
+
+	/* too much load - let's continue after a break for scheduling */
 	if (!(q->warned & HTB_WARN_TOOMANYEVENTS)) {
 		printk(KERN_WARNING "htb: too many events!\n");
 		q->warned |= HTB_WARN_TOOMANYEVENTS;
 	}
-	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
+
+	return q->now;
 }
 
 /* Returns class->node+prio from id-tree where classe's id is >= id. NULL
@@ -892,7 +896,10 @@ static struct sk_buff *htb_dequeue(struc
 		}
 	}
 	sch->qstats.overlimits++;
-	qdisc_watchdog_schedule(&q->watchdog, next_event);
+	if (likely(next_event > q->now))
+		qdisc_watchdog_schedule(&q->watchdog, next_event);
+	else
+		schedule_work(&q->work);
 fin:
 	return skb;
 }
@@ -962,6 +969,14 @@ static const struct nla_policy htb_polic
 	[TCA_HTB_RTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 };
 
+static void htb_work_func(struct work_struct *work)
+{
+	struct htb_sched *q = container_of(work, struct htb_sched, work);
+	struct Qdisc *sch = q->watchdog.qdisc;
+
+	__netif_schedule(qdisc_root(sch));
+}
+
 static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct htb_sched *q = qdisc_priv(sch);
@@ -996,6 +1011,7 @@ static int htb_init(struct Qdisc *sch, s
 		INIT_LIST_HEAD(q->drops + i);
 
 	qdisc_watchdog_init(&q->watchdog, sch);
+	INIT_WORK(&q->work, htb_work_func);
 	skb_queue_head_init(&q->direct_queue);
 
 	q->direct_qlen = qdisc_dev(sch)->tx_queue_len;
@@ -1188,7 +1204,6 @@ static void htb_destroy_class(struct Qdi
 	kfree(cl);
 }
 
-/* always caled under BH & queue lock */
 static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
@@ -1196,6 +1211,7 @@ static void htb_destroy(struct Qdisc *sc
 	struct htb_class *cl;
 	unsigned int i;
 
+	cancel_work_sync(&q->work);
 	qdisc_watchdog_cancel(&q->watchdog);
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it
