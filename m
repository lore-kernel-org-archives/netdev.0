From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Mon, 25 Jun 2007 11:30:31 +0200
Message-ID: <467F8B37.7030000@trash.net>
References: <bug-8668-10286@http.bugzilla.kernel.org/> <20070624222430.8d5b4bd7.akpm@linux-foundation.org> <467F8ADA.7060702@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060000040205010000080907"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: ranko@spidernet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63312 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbXFYJad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 05:30:33 -0400
In-Reply-To: <467F8ADA.7060702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060000040205010000080907
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> It is. This patch I had originally planned for 2.6.23 switches HTB
> to the generic estimator, which shouldn't suffer from this.
> 
> Ranko, can you try if it fixes your timer problem?


Forgot the patch ..

--------------060000040205010000080907
Content-Type: text/x-diff;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

[NET_SCHED]: sch_htb: use generic estimator

Use the generic estimator instead of reimplementing (parts of) it.
For compatibility always create a default estimator for new classes.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 156d3d463446258c3e72b9dc10238e807bfeec71
tree a136f5576a0ca3066c200c577e559097e6a5d4b8
parent 831e7e7451b662679e0e3cf56e7c070a027de306
author Patrick McHardy <kaber@trash.net> Tue, 19 Jun 2007 23:21:00 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 19 Jun 2007 23:21:00 +0200

 net/sched/sch_htb.c |   85 ++++++++++++++-------------------------------------
 1 files changed, 24 insertions(+), 61 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 035788c..26f81b8 100644
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
@@ -1175,11 +1123,6 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
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
@@ -1277,6 +1220,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		BUG_TRAP(cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
+	gen_kill_estimator(&cl->bstats, &cl->rate_est);
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
@@ -1305,9 +1249,6 @@ static void htb_destroy(struct Qdisc *sch)
 	struct htb_sched *q = qdisc_priv(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
-#ifdef HTB_RATECM
-	del_timer_sync(&q->rttim);
-#endif
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it
 	   because filter need its target class alive to be able to call
@@ -1403,6 +1344,20 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	if (!cl) {		/* new class */
 		struct Qdisc *new_q;
 		int prio;
+		struct {
+			struct rtattr		rta;
+			struct gnet_estimator	opt;
+		} est = {
+			.rta = {
+				.rta_len	= RTA_LENGTH(sizeof(est.opt)),
+				.rta_type	= TCA_RATE,
+			},
+			.opt = {
+				/* 4s interval, 16s averaging constant */
+				.interval	= 2,
+				.ewma_log	= 2,
+			},
+		};
 
 		/* check for valid classid */
 		if (!classid || TC_H_MAJ(classid ^ sch->handle)
@@ -1418,6 +1373,9 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
+		gen_new_estimator(&cl->bstats, &cl->rate_est,
+				  &sch->dev->queue_lock,
+				  tca[TCA_RATE-1] ? : &est.rta);
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
 		INIT_HLIST_NODE(&cl->hlist);
@@ -1469,8 +1427,13 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		hlist_add_head(&cl->hlist, q->hash + htb_hash(classid));
 		list_add_tail(&cl->sibling,
 			      parent ? &parent->children : &q->root);
-	} else
+	} else {
+		if (tca[TCA_RATE-1])
+			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+					      &sch->dev->queue_lock,
+					      tca[TCA_RATE-1]);
 		sch_tree_lock(sch);
+	}
 
 	/* it used to be a nasty bug here, we have to check that node
 	   is really leaf before changing cl->un.leaf ! */

--------------060000040205010000080907--
