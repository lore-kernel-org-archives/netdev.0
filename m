From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 4/4]: O(1) children vtoff adjustment
Date: Sat, 14 Aug 2004 22:00:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411E6F73.2010107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070602050008090103010707"
Cc: netdev@oss.sgi.com, devik <devik@cdi.cz>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070602050008090103010707
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patches replaces the O(n) algorithm for children vtoff adjustment by
a O(1) variant.


--------------070602050008090103010707
Content-Type: text/x-patch;
 name="04-hfsc-2.6.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04-hfsc-2.6.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/11 23:24:31+02:00 kaber@coreworks.de 
#   [NET_SCHED]: O(1) children vtoff adjustment in HFSC scheduler
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_hfsc.c
#   2004/08/11 23:24:14+02:00 kaber@coreworks.de +15 -8
#   [NET_SCHED]: O(1) children vtoff adjustment in HFSC scheduler
# 
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2004-08-12 23:25:53 +02:00
+++ b/net/sched/sch_hfsc.c	2004-08-12 23:25:53 +02:00
@@ -164,6 +164,9 @@
 					   adjustment */
 	u64	cl_vtoff;		/* inter-period cumulative vt offset */
 	u64	cl_cvtmax;		/* max child's vt in the last period */
+	u64	cl_cvtoff;		/* cumulative cvtmax of all periods */
+	u64	cl_pcvtoff;		/* parent's cvtoff at initalization
+					   time */
 
 	struct internal_sc cl_rsc;	/* internal real-time service curve */
 	struct internal_sc cl_fsc;	/* internal fair service curve */
@@ -720,7 +723,7 @@
 static void
 init_vf(struct hfsc_class *cl, unsigned int len)
 {
-	struct hfsc_class *max_cl, *p;
+	struct hfsc_class *max_cl;
 	struct rb_node *n;
 	u64 vt, f, cur_time;
 	int go_active;
@@ -752,19 +755,20 @@
 			} else {
 				/*
 				 * first child for a new parent backlog period.
-				 * add parent's cvtmax to vtoff of children
-				 * to make a new vt (vtoff + vt) larger than
-				 * the vt in the last period for all children.
+				 * add parent's cvtmax to cvtoff to make a new
+				 * vt (vtoff + vt) larger than the vt in the
+				 * last period for all children.
 				 */
 				vt = cl->cl_parent->cl_cvtmax;
-				list_for_each_entry(p, &cl->cl_parent->children,
-				                                       siblings)
-					p->cl_vtoff += vt;
-				cl->cl_vt = 0;
+				cl->cl_parent->cl_cvtoff += vt;
 				cl->cl_parent->cl_cvtmax = 0;
 				cl->cl_parent->cl_cvtmin = 0;
+				cl->cl_vt = 0;
 			}
 
+			cl->cl_vtoff = cl->cl_parent->cl_cvtoff -
+							cl->cl_pcvtoff;
+
 			/* update the virtual curve */
 			vt = cl->cl_vt + cl->cl_vtoff;
 			rtsc_min(&cl->cl_virtual, &cl->cl_fsc, vt,
@@ -1151,6 +1155,7 @@
 	if (parent->level == 0)
 		hfsc_purge_queue(sch, parent);
 	hfsc_adjust_levels(parent);
+	cl->cl_pcvtoff = parent->cl_cvtoff;
 	sch_tree_unlock(sch);
 
 #ifdef CONFIG_NET_ESTIMATOR
@@ -1584,6 +1589,8 @@
 	cl->cl_vtoff        = 0;
 	cl->cl_cvtmin       = 0;
 	cl->cl_cvtmax       = 0;
+	cl->cl_cvtoff       = 0;
+	cl->cl_pcvtoff      = 0;
 	cl->cl_vtperiod     = 0;
 	cl->cl_parentperiod = 0;
 	cl->cl_f            = 0;

--------------070602050008090103010707--
