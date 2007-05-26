From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] Update htb rate when stats are polled.
Date: Sat, 26 May 2007 14:55:43 +0200
Message-ID: <46582E4F.5090306@trash.net>
References: <Pine.LNX.4.63.0705250923210.27351@ranjit.corp.google.com> <4657E8AC.4080505@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050507030802040901010107"
Cc: netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57843 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbXEZMz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 08:55:56 -0400
In-Reply-To: <4657E8AC.4080505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050507030802040901010107
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Ranjit Manomohan wrote:
> 
>>Currently the HTB rate for a class is update very slowly (once
>>every 16 seconds). This patch updates the rate whenever the stats
>>are requested from user space. This enables more accurate rate
>>monitoring.
>>
>>+/* Update packet/byte rate for a class. */
>>[..]
> 
> We have a generic rate estimator, I think we should convert HTB over
> to use it and then maybe add this feature to the generic estimator.


You can use this patch as a base. It needs a bit more work
(for example the CONFIG_NET_SCHED_ESTIMATOR ifdefs are
unnecessary, but I've added them to remind me to clean this
up in all schedulers), but it works well enough for testing.

Actually .. do you still need your changes with this patch?
You can now replace the default estimator by one with a
shorter interval.


--------------050507030802040901010107
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: sch_htb: use generic estimator

Remove the internal rate estimator and use the generic one.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit add81ec9b23f1fbe973093d5999a3d70e9d4c48b
tree d5d119cceed54f14c39cbe6bc75c270a3e89f316
parent b208cb31ea86bc6296e5b08e53bc765c81306286
author Patrick McHardy <kaber@trash.net> Sat, 26 May 2007 14:52:02 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 26 May 2007 14:52:02 +0200

 net/sched/sch_htb.c |   91 +++++++++++++++++----------------------------------
 1 files changed, 30 insertions(+), 61 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 035788c..b29ff8f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -69,8 +69,6 @@
 */
 
 #define HTB_HSIZE 16		/* classid hash size */
-#define HTB_EWMAC 2		/* rate average over HTB_EWMAC*HTB_HSIZE sec */
-#define HTB_RATECM 1		/* whether to use rate computer */
 #define HTB_HYSTERESIS 1	/* whether to use mode hysteresis for speedup */
 #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
 
@@ -95,12 +93,6 @@ struct htb_class {
 	struct tc_htb_xstats xstats;	/* our special stats */
 	int refcnt;		/* usage count of this class */
 
-#ifdef HTB_RATECM
-	/* rate measurement counters */
-	unsigned long rate_bytes, sum_bytes;
-	unsigned long rate_packets, sum_packets;
-#endif
-
 	/* topology */
 	int level;		/* our level (see above) */
 	struct htb_class *parent;	/* parent class */
@@ -194,10 +186,6 @@ struct htb_sched {
 	int rate2quantum;	/* quant = rate / rate2quantum */
 	psched_time_t now;	/* cached dequeue time */
 	struct qdisc_watchdog watchdog;
-#ifdef HTB_RATECM
-	struct timer_list rttim;	/* rate computer timer */
-	int recmp_bucket;	/* which hash bucket to recompute next */
-#endif
 
 	/* non shaped skbs; let them go directly thru */
 	struct sk_buff_head direct_queue;
@@ -677,34 +665,6 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
-#ifdef HTB_RATECM
-#define RT_GEN(D,R) R+=D-(R/HTB_EWMAC);D=0
-static void htb_rate_timer(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc *)arg;
-	struct htb_sched *q = qdisc_priv(sch);
-	struct hlist_node *p;
-	struct htb_class *cl;
-
-
-	/* lock queue so that we can muck with it */
-	spin_lock_bh(&sch->dev->queue_lock);
-
-	q->rttim.expires = jiffies + HZ;
-	add_timer(&q->rttim);
-
-	/* scan and recompute one bucket at time */
-	if (++q->recmp_bucket >= HTB_HSIZE)
-		q->recmp_bucket = 0;
-
-	hlist_for_each_entry(cl,p, q->hash + q->recmp_bucket, hlist) {
-		RT_GEN(cl->sum_bytes, cl->rate_bytes);
-		RT_GEN(cl->sum_packets, cl->rate_packets);
-	}
-	spin_unlock_bh(&sch->dev->queue_lock);
-}
-#endif
-
 /**
  * htb_charge_class - charges amount "bytes" to leaf and ancestors
  *
@@ -750,11 +710,6 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 			if (cl->cmode != HTB_CAN_SEND)
 				htb_add_to_wait_tree(q, cl, diff);
 		}
-#ifdef HTB_RATECM
-		/* update rate counters */
-		cl->sum_bytes += bytes;
-		cl->sum_packets++;
-#endif
 
 		/* update byte stats except for leaves which are already updated */
 		if (cl->level) {
@@ -1095,13 +1050,6 @@ static int htb_init(struct Qdisc *sch, struct rtattr *opt)
 	if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
 		q->direct_qlen = 2;
 
-#ifdef HTB_RATECM
-	init_timer(&q->rttim);
-	q->rttim.function = htb_rate_timer;
-	q->rttim.data = (unsigned long)sch;
-	q->rttim.expires = jiffies + HZ;
-	add_timer(&q->rttim);
-#endif
 	if ((q->rate2quantum = gopt->rate2quantum) < 1)
 		q->rate2quantum = 1;
 	q->defcls = gopt->defcls;
@@ -1175,18 +1123,15 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
 
-#ifdef HTB_RATECM
-	cl->rate_est.bps = cl->rate_bytes / (HTB_EWMAC * HTB_HSIZE);
-	cl->rate_est.pps = cl->rate_packets / (HTB_EWMAC * HTB_HSIZE);
-#endif
-
 	if (!cl->level && cl->un.leaf.q)
 		cl->qstats.qlen = cl->un.leaf.q->q.qlen;
 	cl->xstats.tokens = cl->tokens;
 	cl->xstats.ctokens = cl->ctokens;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+#ifdef CONFIG_NET_ESTIMATOR
 	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+#endif
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1277,6 +1222,9 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		BUG_TRAP(cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
+#ifdef CONFIG_NET_ESTIMATOR
+	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+#endif
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
@@ -1305,9 +1253,6 @@ static void htb_destroy(struct Qdisc *sch)
 	struct htb_sched *q = qdisc_priv(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
-#ifdef HTB_RATECM
-	del_timer_sync(&q->rttim);
-#endif
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it
 	   because filter need its target class alive to be able to call
@@ -1403,6 +1348,19 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	if (!cl) {		/* new class */
 		struct Qdisc *new_q;
 		int prio;
+		struct {
+			struct rtattr		rta;
+			struct gnet_estimator	opt;
+		} est __maybe_unused = {
+			.rta = {
+				.rta_len	= RTA_LENGTH(sizeof(est.opt)),
+				.rta_type	= TCA_RATE,
+			},
+			.opt = {
+				.interval	= 2,
+				.ewma_log	= 2,
+			},
+		};
 
 		/* check for valid classid */
 		if (!classid || TC_H_MAJ(classid ^ sch->handle)
@@ -1418,6 +1376,10 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
+#ifdef CONFIG_NET_ESTIMATOR
+		gen_new_estimator(&cl->bstats, &cl->rate_est,
+				  &sch->dev->queue_lock, &est.rta);
+#endif
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
 		INIT_HLIST_NODE(&cl->hlist);
@@ -1469,8 +1431,15 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		hlist_add_head(&cl->hlist, q->hash + htb_hash(classid));
 		list_add_tail(&cl->sibling,
 			      parent ? &parent->children : &q->root);
-	} else
+	} else {
+#ifdef CONFIG_NET_ESTIMATOR
+		if (tca[TCA_RATE-1])
+			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+					      &sch->dev->queue_lock,
+					      tca[TCA_RATE-1]);
+#endif
 		sch_tree_lock(sch);
+	}
 
 	/* it used to be a nasty bug here, we have to check that node
 	   is really leaf before changing cl->un.leaf ! */

--------------050507030802040901010107--
