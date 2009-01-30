From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/3 v2 net-next] pkt_sched: sch_htb: Warn on too many
	events.
Date: Fri, 30 Jan 2009 10:17:01 +0000
Message-ID: <20090130101701.GA8882@ff.dom.local>
References: <20090128125230.GA6282@ff.dom.local> <49808544.5010304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:9496 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbZA3KRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 05:17:10 -0500
Received: by ey-out-2122.google.com with SMTP id 25so102378eya.37
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 02:17:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49808544.5010304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2009 at 05:18:12PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> pkt_sched: sch_htb: Warn on too many events.
...
> How about making this flag and the warning message (in a out-of-line
> function) globally available? Other qdiscs (f.i. HFSC) can't deal with
> inner non-work-conserving qdiscs as well.

OK, thanks,
Jarek P.
------------------> take 2: PATCH 1/3
pkt_sched: sch_hfsc: sch_htb: Add non-work-conserving warning handler.

Patrick McHardy <kaber@trash.net> suggested:
> How about making this flag and the warning message (in a out-of-line
> function) globally available? Other qdiscs (f.i. HFSC) can't deal with
> inner non-work-conserving qdiscs as well.

This patch uses qdisc->flags field of "suspected" child qdisc.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2009-01-02 21:21:37.000000000 +0100
+++ b/include/net/pkt_sched.h	2009-01-29 22:57:55.000000000 +0100
@@ -85,6 +85,7 @@ extern struct qdisc_rate_table *qdisc_ge
 		struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 extern void qdisc_put_stab(struct qdisc_size_table *tab);
+extern void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
 
 extern void __qdisc_run(struct Qdisc *q);
 
diff -Nurp a/include/net/sch_generic.h b/include/net/sch_generic.h
--- a/include/net/sch_generic.h	2009-01-20 18:43:03.000000000 +0100
+++ b/include/net/sch_generic.h	2009-01-29 22:36:33.000000000 +0100
@@ -42,9 +42,10 @@ struct Qdisc
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
 	unsigned		flags;
-#define TCQ_F_BUILTIN	1
-#define TCQ_F_THROTTLED	2
-#define TCQ_F_INGRESS	4
+#define TCQ_F_BUILTIN		1
+#define TCQ_F_THROTTLED		2
+#define TCQ_F_INGRESS		4
+#define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
 	struct Qdisc_ops	*ops;
 	struct qdisc_size_table	*stab;
diff -Nurp a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2009-01-20 18:43:10.000000000 +0100
+++ b/net/sched/sch_api.c	2009-01-30 00:35:19.000000000 +0100
@@ -444,6 +444,17 @@ out:
 }
 EXPORT_SYMBOL(qdisc_calculate_pkt_len);
 
+void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc)
+{
+	if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
+		printk(KERN_WARNING
+		       "%s: %s qdisc %X: is non-work-conserving?\n",
+		       txt, qdisc->ops->id, qdisc->handle >> 16);
+		qdisc->flags |= TCQ_F_WARN_NONWC;
+	}
+}
+EXPORT_SYMBOL(qdisc_warn_nonwc);
+
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
diff -Nurp a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2009-01-20 18:43:10.000000000 +0100
+++ b/net/sched/sch_hfsc.c	2009-01-29 23:19:57.000000000 +0100
@@ -887,8 +887,7 @@ qdisc_peek_len(struct Qdisc *sch)
 
 	skb = sch->ops->peek(sch);
 	if (skb == NULL) {
-		if (net_ratelimit())
-			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
+		qdisc_warn_nonwc("qdisc_peek_len", sch);
 		return 0;
 	}
 	len = qdisc_pkt_len(skb);
@@ -1642,8 +1641,7 @@ hfsc_dequeue(struct Qdisc *sch)
 
 	skb = qdisc_dequeue_peeked(cl->qdisc);
 	if (skb == NULL) {
-		if (net_ratelimit())
-			printk("HFSC: Non-work-conserving qdisc ?\n");
+		qdisc_warn_nonwc("HFSC", cl->qdisc);
 		return NULL;
 	}
 
diff -Nurp a/net/sched/sch_htb.c b/net/sched/sch_htb.c
--- a/net/sched/sch_htb.c	2009-01-12 21:09:35.000000000 +0100
+++ b/net/sched/sch_htb.c	2009-01-29 23:07:42.000000000 +0100
@@ -114,8 +114,6 @@ struct htb_class {
 	struct tcf_proto *filter_list;
 	int filter_cnt;
 
-	int warned;		/* only one warning about non work conserving .. */
-
 	/* token bucket parameters */
 	struct qdisc_rate_table *rate;	/* rate table of the class itself */
 	struct qdisc_rate_table *ceil;	/* ceiling rate (limits borrows too) */
@@ -809,13 +807,8 @@ next:
 		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
 		if (likely(skb != NULL))
 			break;
-		if (!cl->warned) {
-			printk(KERN_WARNING
-			       "htb: class %X isn't work conserving ?!\n",
-			       cl->common.classid);
-			cl->warned = 1;
-		}
 
+		qdisc_warn_nonwc("htb", cl->un.leaf.q);
 		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
 				  ptr[0]) + prio);
 		cl = htb_lookup_leaf(q->row[level] + prio, prio,
