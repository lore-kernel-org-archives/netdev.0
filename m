From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
	jiffies in htb_dequeue()
Date: Wed, 28 Jan 2009 13:23:53 +0000
Message-ID: <20090128132353.GA6443@ff.dom.local>
References: <496B19F7.4060909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:58166 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbZA1NYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 08:24:02 -0500
Received: by mu-out-0910.google.com with SMTP id g7so4986049muf.1
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 05:24:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <496B19F7.4060909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-01-2009 11:22, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Mon, Jan 12, 2009 at 07:56:37AM +0100, Patrick McHardy wrote:
>>> Sorry, I dropped the ball on this one. I still think scheduling
>>> a work-queue or something else running in process context to
>>> kick the queue once the scheduler had a chance to run would
>>> be a better solution. But Jarek's patches are an improvement
>>> to the current situation, so no objections from me.
>>>
>> Thanks for the review Patrick. As I wrote before, I'm not against
>> using a workqueue here: it's logically better, but I still think
>> this place is rather exception, so I'm not convinced we should
>> care so much adding better solution, but also some overhead when
>> cancelling this workqueue. But if it really bothers you, please
>> confirm, and I'll do it.
> 
> It doesn't bother me :) I just think its the technical better
> and also most likely code-wise cleaner solution to this problem.
> Cancellation wouldn't be necessary since an unnecessary
> netif_schedule() doesn't really matter.
> 
> It you don't mind adding the workqueue, I certainly would prefer
> it, but I'm also fine with this patch. I don't have a HTB setup
> or a testcase for this specific case, otherwise I'd simply do it
> myself.

Here is an example of this workqueue. I hope I didn't miss your point,
but since I didn't find much difference in testing, I'd prefer not to
sign-off/merge this yet, at least until there are many reports on
"too many events" problem, and somebody finds it useful.

Thanks,
Jarek P.

--- (for example only)

diff -Nurp b/net/sched/sch_htb.c c/net/sched/sch_htb.c
--- b/net/sched/sch_htb.c	2009-01-13 20:20:47.000000000 +0100
+++ c/net/sched/sch_htb.c	2009-01-13 21:32:17.000000000 +0100
@@ -35,6 +35,7 @@
 #include <linux/list.h>
 #include <linux/compiler.h>
 #include <linux/rbtree.h>
+#include <linux/workqueue.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
@@ -157,6 +158,7 @@ struct htb_sched {
 #define HTB_WARN_NONCONSERVING	0x1
 #define HTB_WARN_TOOMANYEVENTS	0x2
 	int warned;	/* only one warning about non work conserving etc. */
+	struct work_struct work;
 };
 
 /* find class in global hash table using given handle */
@@ -660,7 +662,7 @@ static void htb_charge_class(struct htb_
  * htb_do_events - make mode changes to classes at the level
  *
  * Scans event queue for pending events and applies them. Returns time of
- * next pending event (0 for no event in pq).
+ * next pending event (0 for no event in pq, q->now for too many events).
  * Note: Applied are events whose have cl->pq_key <= q->now.
  */
 static psched_time_t htb_do_events(struct htb_sched *q, int level,
@@ -688,12 +690,14 @@ static psched_time_t htb_do_events(struc
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
@@ -898,7 +902,10 @@ static struct sk_buff *htb_dequeue(struc
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
@@ -968,6 +975,14 @@ static const struct nla_policy htb_polic
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
@@ -1002,6 +1017,7 @@ static int htb_init(struct Qdisc *sch, s
 		INIT_LIST_HEAD(q->drops + i);
 
 	qdisc_watchdog_init(&q->watchdog, sch);
+	INIT_WORK(&q->work, htb_work_func);
 	skb_queue_head_init(&q->direct_queue);
 
 	q->direct_qlen = qdisc_dev(sch)->tx_queue_len;
@@ -1194,7 +1210,6 @@ static void htb_destroy_class(struct Qdi
 	kfree(cl);
 }
 
-/* always caled under BH & queue lock */
 static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
@@ -1202,6 +1217,7 @@ static void htb_destroy(struct Qdisc *sc
 	struct htb_class *cl;
 	unsigned int i;
 
+	cancel_work_sync(&q->work);
 	qdisc_watchdog_cancel(&q->watchdog);
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it
