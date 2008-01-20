From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 01/05]: Consolidate default fifo setup
Date: Sun, 20 Jan 2008 19:28:50 +0100 (MET)
Message-ID: <20080120182850.10972.46514.sendpatchset@localhost.localdomain>
References: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64048 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538AbYATS2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 13:28:52 -0500
In-Reply-To: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e56c933715900be7c6ad30bd07d342d31c457112
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 2 21:35:19 2008 +0100

    [NET_SCHED]: Consolidate default fifo setup
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index ab61809..9d06d2d 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -72,6 +72,10 @@ extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
 
+extern int fifo_set_limit(struct Qdisc *q, unsigned int limit);
+extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
+				      unsigned int limit);
+
 extern int register_qdisc(struct Qdisc_ops *qops);
 extern int unregister_qdisc(struct Qdisc_ops *qops);
 extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index d71dbfc..f9bf58b 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -108,3 +108,45 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 
 EXPORT_SYMBOL(bfifo_qdisc_ops);
 EXPORT_SYMBOL(pfifo_qdisc_ops);
+
+/* Pass size change message down to embedded FIFO */
+int fifo_set_limit(struct Qdisc *q, unsigned int limit)
+{
+	struct rtattr *rta;
+	int ret = -ENOMEM;
+
+	/* Hack to avoid sending change message to non-FIFO */
+	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
+		return 0;
+
+	rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
+	if (rta) {
+		rta->rta_type = RTM_NEWQDISC;
+		rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
+		((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
+
+		ret = q->ops->change(q, rta);
+		kfree(rta);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(fifo_set_limit);
+
+struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
+			       unsigned int limit)
+{
+	struct Qdisc *q;
+	int err = -ENOMEM;
+
+	q = qdisc_create_dflt(sch->dev, ops, TC_H_MAKE(sch->handle, 1));
+	if (q) {
+		err = fifo_set_limit(q, limit);
+		if (err < 0) {
+			qdisc_destroy(q);
+			q = NULL;
+		}
+	}
+
+	return q ? : ERR_PTR(err);
+}
+EXPORT_SYMBOL(fifo_create_dflt);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 6c344ad..5342a2f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -310,28 +310,6 @@ static void netem_reset(struct Qdisc *sch)
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
-/* Pass size change message down to embedded FIFO */
-static int set_fifo_limit(struct Qdisc *q, int limit)
-{
-	struct rtattr *rta;
-	int ret = -ENOMEM;
-
-	/* Hack to avoid sending change message to non-FIFO */
-	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
-		return 0;
-
-	rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-	if (rta) {
-		rta->rta_type = RTM_NEWQDISC;
-		rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-		((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
-
-		ret = q->ops->change(q, rta);
-		kfree(rta);
-	}
-	return ret;
-}
-
 /*
  * Distribution data is a variable size payload containing
  * signed 16 bit values.
@@ -414,7 +392,7 @@ static int netem_change(struct Qdisc *sch, struct rtattr *opt)
 		return -EINVAL;
 
 	qopt = RTA_DATA(opt);
-	ret = set_fifo_limit(q->qdisc, qopt->limit);
+	ret = fifo_set_limit(q->qdisc, qopt->limit);
 	if (ret) {
 		pr_debug("netem: can't set fifo limit\n");
 		return ret;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index f1e9647..699f83d 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -174,33 +174,6 @@ static void red_destroy(struct Qdisc *sch)
 	qdisc_destroy(q->qdisc);
 }
 
-static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
-{
-	struct Qdisc *q;
-	struct rtattr *rta;
-	int ret;
-
-	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
-			      TC_H_MAKE(sch->handle, 1));
-	if (q) {
-		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)),
-			      GFP_KERNEL);
-		if (rta) {
-			rta->rta_type = RTM_NEWQDISC;
-			rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-			((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
-
-			ret = q->ops->change(q, rta);
-			kfree(rta);
-
-			if (ret == 0)
-				return q;
-		}
-		qdisc_destroy(q);
-	}
-	return NULL;
-}
-
 static int red_change(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -220,9 +193,9 @@ static int red_change(struct Qdisc *sch, struct rtattr *opt)
 	ctl = RTA_DATA(tb[TCA_RED_PARMS-1]);
 
 	if (ctl->limit > 0) {
-		child = red_create_dflt(sch, ctl->limit);
-		if (child == NULL)
-			return -ENOMEM;
+		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, ctl->limit);
+		if (IS_ERR(child))
+			return PTR_ERR(child);
 	}
 
 	sch_tree_lock(sch);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index d88fea9..bd34355 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -242,33 +242,6 @@ static void tbf_reset(struct Qdisc* sch)
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
-static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
-{
-	struct Qdisc *q;
-	struct rtattr *rta;
-	int ret;
-
-	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
-			      TC_H_MAKE(sch->handle, 1));
-	if (q) {
-		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-		if (rta) {
-			rta->rta_type = RTM_NEWQDISC;
-			rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-			((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
-
-			ret = q->ops->change(q, rta);
-			kfree(rta);
-
-			if (ret == 0)
-				return q;
-		}
-		qdisc_destroy(q);
-	}
-
-	return NULL;
-}
-
 static int tbf_change(struct Qdisc* sch, struct rtattr *opt)
 {
 	int err = -EINVAL;
@@ -312,8 +285,9 @@ static int tbf_change(struct Qdisc* sch, struct rtattr *opt)
 		goto done;
 
 	if (qopt->limit > 0) {
-		if ((child = tbf_create_dflt_qdisc(sch, qopt->limit)) == NULL)
-			goto done;
+		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
+		if (IS_ERR(child))
+			return PTR_ERR(child);
 	}
 
 	sch_tree_lock(sch);
