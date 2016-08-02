From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH net-next v2 1/2] net/sched/sch_hfsc.c: keep fsc and virtual times in sync; fix an old bug
Date: Wed,  3 Aug 2016 00:44:54 +0200
Message-ID: <1470177895-2453-2-git-send-email-soltys@ziu.info>
References: <1470177895-2453-1-git-send-email-soltys@ziu.info>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:33263 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241AbcHBWpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 18:45:49 -0400
In-Reply-To: <1470177895-2453-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simplifies how we update fsc and calculate vt from it - while
keeping the expected functionality identical with how hfsc behaves
curently. It also fixes a certain issue introduced with
a very old patch.

The idea is, that instead of correcting cl_vt before fsc curve update
(rtsc_min) and correcting cl_vt after calculation (rtsc_y2x) to keep
cl_vt local to the current period - we can simply rely on virtual times
and curve values always being in sync - analogously to how rsc and usc
function, except that we use virtual time here.

Why hasn't it been done since the beginning this way ? The likely scenario
(basing on the code trying to correct curves whenever possible) was to
keep the virtual times as small as possible - as they have tendency to
"gallop" forward whenever their siblings and other fair sharing
subtrees are idling. On top of that, current code is subtly bugged, so
cumulative time (without any corrections) is always kept and used in
init_vf() when a new backlog period begins (using cl_cvtoff).

Is cumulative value safe ? Generally yes, though corner cases are easy
to create. For example consider:

1gbit interface
some 100kbit leaf, everything else idle

With current tick (64ns) 1s is 15625000 ticks, but the leaf is alone and
it's virtual time, so in reality it's 10000 times more. ITOW 38 bits are
needed to hold 1 second. 54 - 1 day, 59 - 1 month, 63 - 1 year (all
logarithms rounded up). It's getting somewhat dangerous, but also
requires setup excusing this kind of values not mentioning permanently
backlogged class for a year. In near most extreme case (10gbit, 10kbit
leaf), we have "enough" to hold ~13.6 days in 64 bits.

Well, the issue remains mostly theoretical and cl_cvtoff has been
working fine for all those years. Sensible configuration are de-facto
immune to this issue, and not so sensible can solve it with a cronjob
and its period inversely proportional to the insanity of such setup =)

Now let's explain the subtle bug mentioned earlier.

The issue is related to how offsets are kept and how we calculate
virtual times and update fair service curve(s). The issue itself is
subtle, but easy to observe with long m1 segments. It was introduced in
rather old patch:

Commit 99296150c7: "[NET_SCHED]: O(1) children vtoff adjustment
in HFSC scheduler"

(available in git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git)

Originally when a new backlog period was started, cl_vtoff of each
sibling was updated with cl_cvtmax from past period - naturally moving
all cl_vt to proper starting point. That patch adjusted it so cumulative
offset is kept in the parent, and there is no need for traversing the
list (as any subsequent child activation derives new vt from already
active sibling(s)).

But with this change, cl_vtoff (of each sibling) is no longer persistent
across the inactivity periods, as it's calculated from parent's
cl_cvtoff on a new backlog period, conflicting with the following curve
correction from the previous period:

if (cl->cl_virtual.x == vt) {
        cl->cl_virtual.x -= cl->cl_vtoff;
	cl->cl_vtoff = 0;
}

This essentially tries to keep curve as if it was local to the period
and resets cl_vtoff (cumulative vt offset of the class) to 0 when
possible (read: when we have an intersection or if a new curve is below
the old one). But then it's recalculated from cl_cvtoff on next active
period.  Then rtsc_min() call preceding the above if() doesn't really
do what we expect it to do in such scenario - as it calculates the
minimum of corrected curve (from the previous backlog period) and the
new uncorrected curve (with offset derived from cl_cvtoff).

Example:

tc class add dev $ife parent 1:0 classid 1:1  hfsc ls m2 100mbit ul m2 100mbit
tc class add dev $ife parent 1:1 classid 1:10 hfsc ls m1 80mbit d 10s m2 20mbit
tc class add dev $ife parent 1:1 classid 1:11 hfsc ls m2 20mbit

start B, keep it backlogged, let it run 6s (30s worth of vt as A is idle)
pause B briefly to force cl_cvtoff update in parent (whole 1:1 going idle)
start A, let it run 10s
pause A briefly to force rtsc_min()

At this point we would expect A to continue at 20mbit after a brief
moment of 80mbit. But instead A will use 80mbit for full 10s again. It's
the effect of first correcting A (during 'start A'), and then - after
unpausing - calculating rtsc_min() from old corrected and new uncorrected
curve.

The patch fixes this bug and keepis vt and fsc in sync (virtual times
are cumulative, not local to the backlog period).

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 44 ++++++++++++--------------------------------
 1 file changed, 12 insertions(+), 32 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 3ddc7bd..6329d7d 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -151,11 +151,8 @@ struct hfsc_class {
 					   (monotonic within a period) */
 	u64	cl_vtadj;		/* intra-period cumulative vt
 					   adjustment */
-	u64	cl_vtoff;		/* inter-period cumulative vt offset */
-	u64	cl_cvtmax;		/* max child's vt in the last period */
-	u64	cl_cvtoff;		/* cumulative cvtmax of all periods */
-	u64	cl_pcvtoff;		/* parent's cvtoff at initialization
-					   time */
+	u64	cl_cvtoff;		/* largest virtual time seen among
+					   the children */
 
 	struct internal_sc cl_rsc;	/* internal real-time service curve */
 	struct internal_sc cl_fsc;	/* internal fair service curve */
@@ -701,28 +698,16 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 			} else {
 				/*
 				 * first child for a new parent backlog period.
-				 * add parent's cvtmax to cvtoff to make a new
-				 * vt (vtoff + vt) larger than the vt in the
-				 * last period for all children.
+				 * initialize cl_vt to the highest value seen
+				 * among the siblings. this is analogous to
+				 * what cur_time would provide in realtime case.
 				 */
-				vt = cl->cl_parent->cl_cvtmax;
-				cl->cl_parent->cl_cvtoff += vt;
-				cl->cl_parent->cl_cvtmax = 0;
+				cl->cl_vt = cl->cl_parent->cl_cvtoff;
 				cl->cl_parent->cl_cvtmin = 0;
-				cl->cl_vt = 0;
 			}
 
-			cl->cl_vtoff = cl->cl_parent->cl_cvtoff -
-							cl->cl_pcvtoff;
-
 			/* update the virtual curve */
-			vt = cl->cl_vt + cl->cl_vtoff;
-			rtsc_min(&cl->cl_virtual, &cl->cl_fsc, vt,
-						      cl->cl_total);
-			if (cl->cl_virtual.x == vt) {
-				cl->cl_virtual.x -= cl->cl_vtoff;
-				cl->cl_vtoff = 0;
-			}
+			rtsc_min(&cl->cl_virtual, &cl->cl_fsc, cl->cl_vt, cl->cl_total);
 			cl->cl_vtadj = 0;
 
 			cl->cl_vtperiod++;  /* increment vt period */
@@ -779,8 +764,7 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 			go_passive = 0;
 
 		/* update vt */
-		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total)
-			    - cl->cl_vtoff + cl->cl_vtadj;
+		cl->cl_vt = rtsc_y2x(&cl->cl_virtual, cl->cl_total) + cl->cl_vtadj;
 
 		/*
 		 * if vt of the class is smaller than cvtmin,
@@ -795,9 +779,9 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 		if (go_passive) {
 			/* no more active child, going passive */
 
-			/* update cvtmax of the parent class */
-			if (cl->cl_vt > cl->cl_parent->cl_cvtmax)
-				cl->cl_parent->cl_cvtmax = cl->cl_vt;
+			/* update cvtoff of the parent class */
+			if (cl->cl_vt > cl->cl_parent->cl_cvtoff)
+				cl->cl_parent->cl_cvtoff = cl->cl_vt;
 
 			/* remove this class from the vt tree */
 			vttree_remove(cl);
@@ -940,7 +924,7 @@ static void
 hfsc_change_fsc(struct hfsc_class *cl, struct tc_service_curve *fsc)
 {
 	sc2isc(fsc, &cl->cl_fsc);
-	rtsc_init(&cl->cl_virtual, &cl->cl_fsc, cl->cl_vtoff + cl->cl_vt, cl->cl_total);
+	rtsc_init(&cl->cl_virtual, &cl->cl_fsc, cl->cl_vt, cl->cl_total);
 	cl->cl_flags |= HFSC_FSC;
 }
 
@@ -1094,7 +1078,6 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (parent->level == 0)
 		hfsc_purge_queue(sch, parent);
 	hfsc_adjust_levels(parent);
-	cl->cl_pcvtoff = parent->cl_cvtoff;
 	sch_tree_unlock(sch);
 
 	qdisc_class_hash_grow(sch, &q->clhash);
@@ -1482,11 +1465,8 @@ hfsc_reset_class(struct hfsc_class *cl)
 	cl->cl_e            = 0;
 	cl->cl_vt           = 0;
 	cl->cl_vtadj        = 0;
-	cl->cl_vtoff        = 0;
 	cl->cl_cvtmin       = 0;
-	cl->cl_cvtmax       = 0;
 	cl->cl_cvtoff       = 0;
-	cl->cl_pcvtoff      = 0;
 	cl->cl_vtperiod     = 0;
 	cl->cl_parentperiod = 0;
 	cl->cl_f            = 0;
-- 
2.1.3
