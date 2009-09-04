From: Patrick McHardy <kaber@trash.net>
Subject: net_sched 01/07: fix class grafting errno codes
Date: Fri,  4 Sep 2009 18:41:13 +0200 (MEST)
Message-ID: <20090904164112.27300.33814.sendpatchset@x2.localnet>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35534 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbZIDQlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 12:41:11 -0400
In-Reply-To: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1cf555183f0ae7e256381ea8993272c0a321f5b5
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 14:28:10 2009 +0200

    net_sched: fix class grafting errno codes
    
    If the parent qdisc doesn't support classes, use EOPNOTSUPP.
    If the parent class doesn't exist, use ENOENT. Currently EINVAL
    is returned in both cases.
    
    Additionally check whether grafting is supported and remove a now
    unnecessary graft function from sch_ingress.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 24d17ce..bef2d64 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -728,14 +728,14 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 	} else {
 		const struct Qdisc_class_ops *cops = parent->ops->cl_ops;
 
-		err = -EINVAL;
-
-		if (cops) {
+		err = -EOPNOTSUPP;
+		if (cops && cops->graft) {
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
 				err = cops->graft(parent, cl, new, &old);
 				cops->put(parent, cl);
-			}
+			} else
+				err = -ENOENT;
 		}
 		if (!err)
 			notify_and_destroy(skb, n, classid, old, new);
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4a2b773..ace7902 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -22,12 +22,6 @@ struct ingress_qdisc_data {
 
 /* ------------------------- Class/flow operations ------------------------- */
 
-static int ingress_graft(struct Qdisc *sch, unsigned long arg,
-			 struct Qdisc *new, struct Qdisc **old)
-{
-	return -EOPNOTSUPP;
-}
-
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
 {
 	return NULL;
@@ -123,7 +117,6 @@ nla_put_failure:
 }
 
 static const struct Qdisc_class_ops ingress_class_ops = {
-	.graft		=	ingress_graft,
 	.leaf		=	ingress_leaf,
 	.get		=	ingress_get,
 	.put		=	ingress_put,
