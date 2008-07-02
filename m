From: Patrick McHardy <kaber@trash.net>
Subject: net-sched: consolidate default fifo qdisc setup
Date: Wed, 02 Jul 2008 16:12:50 +0200
Message-ID: <486B8CE2.5000603@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020707070307010702020009"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38936 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbYGBOMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 10:12:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020707070307010702020009
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020707070307010702020009
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit dbe4e4f34c356cd31cf9bc8972c0eb4eadebe920
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 2 12:19:36 2008 +0200

    net-sched: consolidate default fifo qdisc setup
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 46fb4d8..8e3a0c4 100644
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
index 95ed482..82d7d7b 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -107,3 +107,45 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 EXPORT_SYMBOL(bfifo_qdisc_ops);
+
+/* Pass size change message down to embedded FIFO */
+int fifo_set_limit(struct Qdisc *q, unsigned int limit)
+{
+	struct nlattr *nla;
+	int ret = -ENOMEM;
+
+	/* Hack to avoid sending change message to non-FIFO */
+	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
+		return 0;
+
+	nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
+	if (nla) {
+		nla->nla_type = RTM_NEWQDISC;
+		nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
+		((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
+
+		ret = q->ops->change(q, nla);
+		kfree(nla);
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
index c9c649b..2469766 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -310,28 +310,6 @@ static void netem_reset(struct Qdisc *sch)
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
-/* Pass size change message down to embedded FIFO */
-static int set_fifo_limit(struct Qdisc *q, int limit)
-{
-	struct nlattr *nla;
-	int ret = -ENOMEM;
-
-	/* Hack to avoid sending change message to non-FIFO */
-	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
-		return 0;
-
-	nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-	if (nla) {
-		nla->nla_type = RTM_NEWQDISC;
-		nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
-		((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
-
-		ret = q->ops->change(q, nla);
-		kfree(nla);
-	}
-	return ret;
-}
-
 /*
  * Distribution data is a variable size payload containing
  * signed 16 bit values.
@@ -416,7 +394,7 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (ret < 0)
 		return ret;
 
-	ret = set_fifo_limit(q->qdisc, qopt->limit);
+	ret = fifo_set_limit(q->qdisc, qopt->limit);
 	if (ret) {
 		pr_debug("netem: can't set fifo limit\n");
 		return ret;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5c56985..77098ac 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -174,33 +174,6 @@ static void red_destroy(struct Qdisc *sch)
 	qdisc_destroy(q->qdisc);
 }
 
-static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
-{
-	struct Qdisc *q;
-	struct nlattr *nla;
-	int ret;
-
-	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
-			      TC_H_MAKE(sch->handle, 1));
-	if (q) {
-		nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)),
-			      GFP_KERNEL);
-		if (nla) {
-			nla->nla_type = RTM_NEWQDISC;
-			nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
-			((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
-
-			ret = q->ops->change(q, nla);
-			kfree(nla);
-
-			if (ret == 0)
-				return q;
-		}
-		qdisc_destroy(q);
-	}
-	return NULL;
-}
-
 static const struct nla_policy red_policy[TCA_RED_MAX + 1] = {
 	[TCA_RED_PARMS]	= { .len = sizeof(struct tc_red_qopt) },
 	[TCA_RED_STAB]	= { .len = RED_STAB_SIZE },
@@ -228,9 +201,9 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	ctl = nla_data(tb[TCA_RED_PARMS]);
 
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
index 0b7d78f..444c227 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -242,34 +242,6 @@ static void tbf_reset(struct Qdisc* sch)
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
-static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
-{
-	struct Qdisc *q;
-	struct nlattr *nla;
-	int ret;
-
-	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
-			      TC_H_MAKE(sch->handle, 1));
-	if (q) {
-		nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)),
-			      GFP_KERNEL);
-		if (nla) {
-			nla->nla_type = RTM_NEWQDISC;
-			nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
-			((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
-
-			ret = q->ops->change(q, nla);
-			kfree(nla);
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
 static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
 	[TCA_TBF_PARMS]	= { .len = sizeof(struct tc_tbf_qopt) },
 	[TCA_TBF_RTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
@@ -322,8 +294,11 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 		goto done;
 
 	if (qopt->limit > 0) {
-		if ((child = tbf_create_dflt_qdisc(sch, qopt->limit)) == NULL)
+		child = fifo_create_dflt(sch, &bfifo_qdisc_ops, qopt->limit);
+		if (IS_ERR(child)) {
+			err = PTR_ERR(child);
 			goto done;
+		}
 	}
 
 	sch_tree_lock(sch);

--------------020707070307010702020009--
