From: Patrick McHardy <kaber@trash.net>
Subject: net_sched 02/07: make cls_ops->tcf_chain() optional
Date: Fri,  4 Sep 2009 18:41:15 +0200 (MEST)
Message-ID: <20090904164113.27300.79145.sendpatchset@x2.localnet>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35537 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbZIDQlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 12:41:13 -0400
In-Reply-To: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6ea4233ef8f398289a14a3305d4ed440fb026d43
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 14:28:11 2009 +0200

    net_sched: make cls_ops->tcf_chain() optional
    
    Some qdiscs don't support attaching filters. Handle this centrally in
    cls_api and return a proper errno code (EOPNOTSUPP) instead of EINVAL.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 09cdcdf..eaa8f43 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -181,6 +181,9 @@ replay:
 	if ((cops = q->ops->cl_ops) == NULL)
 		return -EINVAL;
 
+	if (cops->tcf_chain == NULL)
+		return -EOPNOTSUPP;
+
 	/* Do we search for filter, attached to class? */
 	if (TC_H_MIN(parent)) {
 		cl = cops->get(q, parent);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 2bdf241..c27b802 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -331,11 +331,6 @@ static void red_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static struct tcf_proto **red_find_tcf(struct Qdisc *sch, unsigned long cl)
-{
-	return NULL;
-}
-
 static const struct Qdisc_class_ops red_class_ops = {
 	.graft		=	red_graft,
 	.leaf		=	red_leaf,
@@ -344,7 +339,6 @@ static const struct Qdisc_class_ops red_class_ops = {
 	.change		=	red_change_class,
 	.delete		=	red_delete,
 	.walk		=	red_walk,
-	.tcf_chain	=	red_find_tcf,
 	.dump		=	red_dump_class,
 };
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e22dfe8..2890969 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -433,11 +433,6 @@ static void tbf_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	}
 }
 
-static struct tcf_proto **tbf_find_tcf(struct Qdisc *sch, unsigned long cl)
-{
-	return NULL;
-}
-
 static const struct Qdisc_class_ops tbf_class_ops =
 {
 	.graft		=	tbf_graft,
@@ -447,7 +442,6 @@ static const struct Qdisc_class_ops tbf_class_ops =
 	.change		=	tbf_change_class,
 	.delete		=	tbf_delete,
 	.walk		=	tbf_walk,
-	.tcf_chain	=	tbf_find_tcf,
 	.dump		=	tbf_dump_class,
 };
 
