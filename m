From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] (4/4) netem - change parameters shouldn't destroy child
 qdisc
Date: Wed, 25 Aug 2004 11:01:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825110108.6a79216a@dell_ss3.pdx.osdl.net>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix netem to allow changing parameters without zapping the underlying
qdisc.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-24 16:58:27 -07:00
+++ b/net/sched/sch_netem.c	2004-08-24 16:58:27 -07:00
@@ -795,37 +795,17 @@
 static int netem_change(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	struct tc_netem_qopt *qopt = RTA_DATA(opt);
-	struct Qdisc *child;
-	int ret;
+	const struct tc_netem_qopt *qopt = RTA_DATA(opt);
 
 	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
 		return -EINVAL;
 
-	child = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
-	if (!child)
-		return -EINVAL;
-
-	ret = set_fifo_limit(child, qopt->limit);
-	if (ret) {
-		qdisc_destroy(child);
-		return ret;
-	}
-
-	sch_tree_lock(sch);
-	if (child) {
-		child = xchg(&q->qdisc, child);
-		if (child != &noop_qdisc)
-			qdisc_destroy(child);
-	
-		q->latency = qopt->latency;
-		q->jitter = qopt->jitter;
-		q->limit = qopt->limit;
-		q->gap = qopt->gap;
-		q->loss = qopt->loss;
-		q->duplicate = qopt->duplicate;
-	}
-	sch_tree_unlock(sch);
+	q->latency = qopt->latency;
+	q->jitter = qopt->jitter;
+	q->limit = qopt->limit;
+	q->gap = qopt->gap;
+	q->loss = qopt->loss;
+	q->duplicate = qopt->duplicate;
 
 	return 0;
 }
@@ -833,19 +813,42 @@
 static int netem_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
+	const struct tc_netem_qopt *qopt;
+	int ret;
 
-	if (!opt)
+	if (!opt || opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
 		return -EINVAL;
 
 	skb_queue_head_init(&q->delayed);
-	q->qdisc = &noop_qdisc;
-
 	init_timer(&q->timer);
 	q->timer.function = netem_watchdog;
 	q->timer.data = (unsigned long) sch;
 	q->counter = 0;
 
-	return netem_change(sch, opt);
+	q->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+	if (!q->qdisc) {
+		pr_debug("netem: qdisc create failed\n");
+		return -ENOMEM;
+	}
+
+	qopt = RTA_DATA(opt);
+	ret = set_fifo_limit(q->qdisc, qopt->limit);
+	if (ret) {
+		pr_debug("netem: can't set fifo limit\n");
+		goto error;
+	}
+
+	ret = netem_change(sch, opt);
+	if (ret) {
+		pr_debug("netem: change failed\n");
+		goto error;
+	}
+
+	return 0;
+
+ error:
+	qdisc_destroy(q->qdisc);
+	return ret;
 }
 
 static void netem_destroy(struct Qdisc *sch)
@@ -862,6 +865,7 @@
 	unsigned char	 *b = skb->tail;
 	struct tc_netem_qopt qopt;
 
+	memset(&qopt, 0, sizeof(qopt));
 	qopt.latency = q->latency;
 	qopt.jitter = q->jitter;
 	qopt.limit = q->limit;
