From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/2]: HFSC: Fix requeueing
Date: Thu, 18 Mar 2004 17:49:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4059D327.40300@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020907010002050703010604"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020907010002050703010604
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes requeueing in HFSC. Requeued packets are kept in a
high-priority queue which is always dequeued first.

Best regards
Patrick

--------------020907010002050703010604
Content-Type: text/x-patch;
 name="02-hfsc-requeue.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02-hfsc-requeue.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/03/18 02:33:40+01:00 kaber@trash.net 
#   [NET_SCHED}: Fix requeueing in HFSC scheduler
# 
# net/sched/sch_hfsc.c
#   2004/03/18 02:33:31+01:00 kaber@trash.net +10 -30
#   [NET_SCHED}: Fix requeueing in HFSC scheduler
# 
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	Thu Mar 18 02:34:28 2004
+++ b/net/sched/sch_hfsc.c	Thu Mar 18 02:34:28 2004
@@ -181,12 +181,11 @@
 {
 	u16	defcls;				/* default class id */
 	struct hfsc_class root;			/* root class */
-	struct hfsc_class *last_xmit;		/* class that transmitted last
-						   packet (for requeueing) */
 	struct list_head clhash[HFSC_HSIZE];	/* class hash */
 	struct list_head eligible;		/* eligible list */
 	struct list_head droplist;		/* active leaf class list (for
 						   dropping) */
+	struct sk_buff_head requeue;		/* requeued packet */
 	struct timer_list wd_timer;		/* watchdog timer */
 };
 
@@ -1228,9 +1227,6 @@
 	list_del(&cl->siblings);
 	hfsc_adjust_levels(cl->cl_parent);
 	hfsc_purge_queue(sch, cl);
-	if (q->last_xmit == cl)
-		q->last_xmit = NULL;
-
 	if (--cl->refcnt == 0)
 		hfsc_destroy_class(sch, cl);
 
@@ -1538,6 +1534,7 @@
 		INIT_LIST_HEAD(&q->clhash[i]);
 	INIT_LIST_HEAD(&q->eligible);
 	INIT_LIST_HEAD(&q->droplist);
+	skb_queue_head_init(&q->requeue);
 
 	q->root.refcnt  = 1;
 	q->root.classid = sch->handle;
@@ -1616,10 +1613,9 @@
 		list_for_each_entry(cl, &q->clhash[i], hlist)
 			hfsc_reset_class(cl);
 	}
-
+	__skb_queue_purge(&q->requeue);
 	INIT_LIST_HEAD(&q->eligible);
 	INIT_LIST_HEAD(&q->droplist);
-	q->last_xmit = NULL;
 	del_timer(&q->wd_timer);
 	sch->flags &= ~TCQ_F_THROTTLED;
 	sch->q.qlen = 0;
@@ -1636,7 +1632,7 @@
 		list_for_each_entry_safe(cl, next, &q->clhash[i], hlist)
 			hfsc_destroy_class(sch, cl);
 	}
-
+	__skb_queue_purge(&q->requeue);
 	del_timer(&q->wd_timer);
 }
 
@@ -1705,6 +1701,8 @@
 
 	if (sch->q.qlen == 0)
 		return NULL;
+	if ((skb = __skb_dequeue(&q->requeue)))
+		goto out;
 
 	PSCHED_GET_TIME(cur_time);
 
@@ -1754,7 +1752,7 @@
 		set_passive(cl);
 	}
 
-	q->last_xmit = cl;
+ out:
 	sch->flags &= ~TCQ_F_THROTTLED;
 	sch->q.qlen--;
 
@@ -1765,28 +1763,10 @@
 hfsc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
-	struct hfsc_class *cl = q->last_xmit;
-	unsigned int len = skb->len;
-	int ret;
 
-	if (cl == NULL) {
-		kfree_skb(skb);
-		sch->stats.drops++;
-		return NET_XMIT_DROP;
-	}
-
-	ret = cl->qdisc->ops->requeue(skb, cl->qdisc);
-	if (ret == NET_XMIT_SUCCESS) {
-		if (cl->qdisc->q.qlen == 1)
-			set_active(cl, len);
-		sch->q.qlen++;
-	} else {
-		cl->stats.drops++;
-		sch->stats.drops++;
-	}
-	q->last_xmit = NULL;
-
-	return ret;
+	__skb_queue_head(&q->requeue, skb);
+	sch->q.qlen++;
+	return NET_XMIT_SUCCESS;
 }
 
 static unsigned int

--------------020907010002050703010604--
