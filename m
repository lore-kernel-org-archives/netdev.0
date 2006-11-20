From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 05/06]: Fix endless loops (part 3): HFSC
Date: Mon, 20 Nov 2006 14:08:46 +0100 (MET)
Message-ID: <20061120130845.22347.81357.sendpatchset@localhost.localdomain>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11262 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965884AbWKTNIr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 08:08:47 -0500
To: davem@davemloft.net
In-Reply-To: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Fix endless loops (part 3): HFSC

Convert HFSC to use qdisc_tree_decrease_len() and add a callback
for deactivating a class when its child queue becomes empty.

All queue purging goes through hfsc_purge_queue(), which is used in
three cases: grafting, class creation (when a leaf class is turned
into an intermediate class by attaching a new class) and class
deletion. In all cases qdisc_tree_decrease_len() is needed.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 62ab4431af7bccd0a8cd9b1933fb03e78fd63252
tree 79911d570a56ac3752790808ae8139983253524a
parent 0ce9475d7baf678698eb70369f734b8feeb03e13
author Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:46:23 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:46:23 +0100

 net/sched/sch_hfsc.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 1142d29..2d43744 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -957,11 +957,7 @@ hfsc_purge_queue(struct Qdisc *sch, stru
 	unsigned int len = cl->qdisc->q.qlen;
 
 	qdisc_reset(cl->qdisc);
-	if (len > 0) {
-		update_vf(cl, 0, 0);
-		set_passive(cl);
-		sch->q.qlen -= len;
-	}
+	qdisc_tree_decrease_qlen(cl->qdisc, len);
 }
 
 static void
@@ -1295,6 +1291,17 @@ hfsc_class_leaf(struct Qdisc *sch, unsig
 	return NULL;
 }
 
+static void
+hfsc_qlen_notify(struct Qdisc *sch, unsigned long arg)
+{
+	struct hfsc_class *cl = (struct hfsc_class *)arg;
+
+	if (cl->qdisc->q.qlen == 0) {
+		update_vf(cl, 0, 0);
+		set_passive(cl);
+	}
+}
+
 static unsigned long
 hfsc_get_class(struct Qdisc *sch, u32 classid)
 {
@@ -1779,6 +1786,7 @@ static struct Qdisc_class_ops hfsc_class
 	.delete		= hfsc_delete_class,
 	.graft		= hfsc_graft_class,
 	.leaf		= hfsc_class_leaf,
+	.qlen_notify	= hfsc_qlen_notify,
 	.get		= hfsc_get_class,
 	.put		= hfsc_put_class,
 	.bind_tcf	= hfsc_bind_tcf,
