From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem packet scheduler class support
Date: Mon, 12 Jul 2004 10:15:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040712101500.4a0babd3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simple enhancement to netem packet scheduler that makes it classful so
that the underlying pfifo default discipline can be substituted with something
else (tbf, red, ...)

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6/net/sched/sch_netem.c	2004-07-12 08:05:35.439533776 -0700
+++ tcp-2.6/net/sched/sch_netem.c	2004-07-12 09:00:23.251710352 -0700
@@ -829,8 +829,95 @@ rtattr_failure:
 	return -1;
 }
 
+static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct netem_sched_data *q = (struct netem_sched_data*)sch->data;
+
+	if (cl != 1) 	/* only one class */
+		return -ENOENT;
+
+	tcm->tcm_handle |= TC_H_MIN(1);
+	tcm->tcm_info = q->qdisc->handle;
+
+	return 0;
+}
+
+static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		     struct Qdisc **old)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = xchg(&q->qdisc, new);
+	qdisc_reset(*old);
+	sch->q.qlen = 0;
+	sch_tree_unlock(sch);
+
+	return 0;
+}
+
+static struct Qdisc *netem_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	return q->qdisc;
+}
+
+static unsigned long netem_get(struct Qdisc *sch, u32 classid)
+{
+	return 1;
+}
+
+static void netem_put(struct Qdisc *sch, unsigned long arg)
+{
+}
+
+static int netem_change_class(struct Qdisc *sch, u32 classid, u32 parentid, 
+			    struct rtattr **tca, unsigned long *arg)
+{
+	return -ENOSYS;
+}
+
+static int netem_delete(struct Qdisc *sch, unsigned long arg)
+{
+	return -ENOSYS;
+}
+
+static void netem_walk(struct Qdisc *sch, struct qdisc_walker *walker)
+{
+	if (!walker->stop) {
+		if (walker->count >= walker->skip)
+			if (walker->fn(sch, 1, walker) < 0) {
+				walker->stop = 1;
+				return;
+			}
+		walker->count++;
+	}
+}
+
+static struct tcf_proto **netem_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	return NULL;
+}
+
+static struct Qdisc_class_ops netem_class_ops = {
+	.graft		=	netem_graft,
+	.leaf		=	netem_leaf,
+	.get		=	netem_get,
+	.put		=	netem_put,
+	.change		=	netem_change_class,
+	.delete		=	netem_delete,
+	.walk		=	netem_walk,
+	.tcf_chain	=	netem_find_tcf,
+	.dump		=	netem_dump_class,
+};
+
 static struct Qdisc_ops netem_qdisc_ops = {
 	.id		=	"netem",
+	.cl_ops		=	&netem_class_ops,
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
