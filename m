From: Patrick McHardy <kaber@trash.net>
Subject: net_sched 03/07: make cls_ops->change and cls_ops->delete optional
Date: Fri,  4 Sep 2009 18:41:16 +0200 (MEST)
Message-ID: <20090904164114.27300.23918.sendpatchset@x2.localnet>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35540 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755506AbZIDQlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 12:41:14 -0400
In-Reply-To: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c357570bb4fdd3c608dce92174acccb9b5b8163b
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 15:14:58 2009 +0200

    net_sched: make cls_ops->change and cls_ops->delete optional
    
    Some schedulers don't support creating, changing or deleting classes.
    Make the respective callbacks optionally and consistently return
    -EOPNOTSUPP for unsupported operations, instead of currently either
    -EOPNOTSUPP, -ENOSYS or no error.
    
    In case of sch_prio and sch_multiq, the removed operations additionally
    checked for an invalid class. This is not necessary since the class
    argument can only orginate from ->get() or in case of ->change is 0
    for creation of new classes, in which case ->change() incorrectly
    returned -ENOENT.
    
    As a side-effect, this patch fixes a possible (root-only) NULL pointer
    function call in sch_ingress, which didn't implement a so far mandatory
    ->delete() operation.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index bef2d64..166fcca 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1417,7 +1417,9 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 				goto out;
 			break;
 		case RTM_DELTCLASS:
-			err = cops->delete(q, cl);
+			err = -EOPNOTSUPP;
+			if (cops->delete)
+				err = cops->delete(q, cl);
 			if (err == 0)
 				tclass_notify(skb, n, q, cl, RTM_DELTCLASS);
 			goto out;
@@ -1431,7 +1433,9 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	}
 
 	new_cl = cl;
-	err = cops->change(q, clid, pid, tca, &new_cl);
+	err = -EOPNOTSUPP;
+	if (cops->change)
+		err = cops->change(q, clid, pid, tca, &new_cl);
 	if (err == 0)
 		tclass_notify(skb, n, q, new_cl, RTM_NEWTCLASS);
 
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index ace7902..a9e646b 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -42,12 +42,6 @@ static void ingress_put(struct Qdisc *sch, unsigned long cl)
 {
 }
 
-static int ingress_change(struct Qdisc *sch, u32 classid, u32 parent,
-			  struct nlattr **tca, unsigned long *arg)
-{
-	return 0;
-}
-
 static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	return;
@@ -120,7 +114,6 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 	.leaf		=	ingress_leaf,
 	.get		=	ingress_get,
 	.put		=	ingress_put,
-	.change		=	ingress_change,
 	.walk		=	ingress_walk,
 	.tcf_chain	=	ingress_find_tcf,
 	.bind_tcf	=	ingress_bind_filter,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 9127312..a0ffe71 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -348,26 +348,6 @@ static void multiq_put(struct Qdisc *q, unsigned long cl)
 	return;
 }
 
-static int multiq_change(struct Qdisc *sch, u32 handle, u32 parent,
-			 struct nlattr **tca, unsigned long *arg)
-{
-	unsigned long cl = *arg;
-	struct multiq_sched_data *q = qdisc_priv(sch);
-
-	if (cl - 1 > q->bands)
-		return -ENOENT;
-	return 0;
-}
-
-static int multiq_delete(struct Qdisc *sch, unsigned long cl)
-{
-	struct multiq_sched_data *q = qdisc_priv(sch);
-	if (cl - 1 > q->bands)
-		return -ENOENT;
-	return 0;
-}
-
-
 static int multiq_dump_class(struct Qdisc *sch, unsigned long cl,
 			     struct sk_buff *skb, struct tcmsg *tcm)
 {
@@ -430,8 +410,6 @@ static const struct Qdisc_class_ops multiq_class_ops = {
 	.leaf		=	multiq_leaf,
 	.get		=	multiq_get,
 	.put		=	multiq_put,
-	.change		=	multiq_change,
-	.delete		=	multiq_delete,
 	.walk		=	multiq_walk,
 	.tcf_chain	=	multiq_find_tcf,
 	.bind_tcf	=	multiq_bind,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 94cecef..209a4ca 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -311,25 +311,6 @@ static void prio_put(struct Qdisc *q, unsigned long cl)
 	return;
 }
 
-static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct nlattr **tca, unsigned long *arg)
-{
-	unsigned long cl = *arg;
-	struct prio_sched_data *q = qdisc_priv(sch);
-
-	if (cl - 1 > q->bands)
-		return -ENOENT;
-	return 0;
-}
-
-static int prio_delete(struct Qdisc *sch, unsigned long cl)
-{
-	struct prio_sched_data *q = qdisc_priv(sch);
-	if (cl - 1 > q->bands)
-		return -ENOENT;
-	return 0;
-}
-
-
 static int prio_dump_class(struct Qdisc *sch, unsigned long cl, struct sk_buff *skb,
 			   struct tcmsg *tcm)
 {
@@ -392,8 +373,6 @@ static const struct Qdisc_class_ops prio_class_ops = {
 	.leaf		=	prio_leaf,
 	.get		=	prio_get,
 	.put		=	prio_put,
-	.change		=	prio_change,
-	.delete		=	prio_delete,
 	.walk		=	prio_walk,
 	.tcf_chain	=	prio_find_tcf,
 	.bind_tcf	=	prio_bind,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index c27b802..a2c4d1a 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -308,17 +308,6 @@ static void red_put(struct Qdisc *sch, unsigned long arg)
 	return;
 }
 
-static int red_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
-{
-	return -ENOSYS;
-}
-
-static int red_delete(struct Qdisc *sch, unsigned long cl)
-{
-	return -ENOSYS;
-}
-
 static void red_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	if (!walker->stop) {
@@ -336,8 +325,6 @@ static const struct Qdisc_class_ops red_class_ops = {
 	.leaf		=	red_leaf,
 	.get		=	red_get,
 	.put		=	red_put,
-	.change		=	red_change_class,
-	.delete		=	red_delete,
 	.walk		=	red_walk,
 	.dump		=	red_dump_class,
 };
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8706920..cb21380 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -496,12 +496,6 @@ nla_put_failure:
 	return -1;
 }
 
-static int sfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
-{
-	return -EOPNOTSUPP;
-}
-
 static unsigned long sfq_get(struct Qdisc *sch, u32 classid)
 {
 	return 0;
@@ -560,7 +554,6 @@ static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 
 static const struct Qdisc_class_ops sfq_class_ops = {
 	.get		=	sfq_get,
-	.change		=	sfq_change_class,
 	.tcf_chain	=	sfq_find_tcf,
 	.dump		=	sfq_dump_class,
 	.dump_stats	=	sfq_dump_class_stats,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 2890969..d904167 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -410,17 +410,6 @@ static void tbf_put(struct Qdisc *sch, unsigned long arg)
 {
 }
 
-static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct nlattr **tca, unsigned long *arg)
-{
-	return -ENOSYS;
-}
-
-static int tbf_delete(struct Qdisc *sch, unsigned long arg)
-{
-	return -ENOSYS;
-}
-
 static void tbf_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	if (!walker->stop) {
@@ -439,8 +428,6 @@ static const struct Qdisc_class_ops tbf_class_ops =
 	.leaf		=	tbf_leaf,
 	.get		=	tbf_get,
 	.put		=	tbf_put,
-	.change		=	tbf_change_class,
-	.delete		=	tbf_delete,
 	.walk		=	tbf_walk,
 	.dump		=	tbf_dump_class,
 };
