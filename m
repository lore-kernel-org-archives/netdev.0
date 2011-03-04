From: Stephen Hemminger <shemminger@vyatta.com>
Subject: QFQ debugfs
Date: Fri, 4 Mar 2011 09:20:53 -0800
Message-ID: <20110304092053.37c5f9ff@nehalam>
References: <20110228171738.2cc8c9a0@nehalam>
	<1299168235.2983.116.camel@edumazet-laptop>
	<20110303084839.3ae312ed@nehalam>
	<1299191333.2547.12.camel@edumazet-laptop>
	<20110303160343.71c55274@nehalam>
	<20110303163016.60f24e8b@nehalam>
	<1299221426.2547.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36172 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759270Ab1CDRU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 12:20:56 -0500
In-Reply-To: <1299221426.2547.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is quick hack to put a debugfs hook on:
  debug/qfq/<device>

dumps internal state

---
 net/sched/sch_qfq.c |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

--- a/net/sched/sch_qfq.c	2011-03-04 08:24:39.138728524 -0800
+++ b/net/sched/sch_qfq.c	2011-03-04 08:44:10.889972934 -0800
@@ -14,6 +14,7 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/pkt_sched.h>
+#include <linux/debugfs.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
@@ -144,6 +145,7 @@ struct qfq_group {
 struct qfq_sched {
 	struct tcf_proto *filter_list;
 	struct Qdisc_class_hash clhash;
+	struct dentry	     *debugfs;
 
 	u64		V;		/* Precise virtual time. */
 	u32		wsum;		/* weight sum */
@@ -1025,6 +1027,55 @@ static unsigned int qfq_drop(struct Qdis
 	return 0;
 }
 
+static struct dentry *qfq_debug;
+
+static int qfq_debug_show(struct seq_file *seq, void *v)
+{
+	struct Qdisc *sch = seq->private;
+	const struct qfq_sched *q = qdisc_priv(sch);
+	unsigned int i, j;
+
+	seq_printf(seq, "V=%llu wsum=%u\n", q->V, q->wsum);
+	for (i = 0; i < QFQ_MAX_STATE; i++)
+		seq_printf(seq, "%lx%c", q->bitmaps[i],
+			   (i & 3) == 3 ? '\n' : ' ');
+
+	for (i = 0; i <= QFQ_MAX_INDEX; i++) {
+		const struct qfq_group *grp = &q->groups[i];
+		seq_printf(seq, "%d: S=%llu F=%llu shift=%u index=%u front=%u full=%#lx\n",
+			   i, (unsigned long long)grp->S,
+			   (unsigned long long)grp->F,
+			   grp->slot_shift, grp->index,
+			   grp->front, grp->full_slots);
+
+		for (j = 0; j < QFQ_MAX_SLOTS; j++) {
+			const struct qfq_class *cl;
+			struct hlist_node *n;
+
+			hlist_for_each_entry(cl, n, &grp->slots[j], next) {
+				seq_printf(seq, "  %d: S=%llu F=%llu inv_w=%u lmax=%u\n",
+					   j, cl->S, cl->F,
+					   cl->inv_w, cl->lmax);
+			}
+		}
+	}
+	return 0;
+}
+
+static int qfq_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, qfq_debug_show, inode->i_private);
+}
+
+static const struct file_operations qfq_debug_fops = {
+	.owner		= THIS_MODULE,
+	.open		= qfq_debug_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+
 static int qfq_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
@@ -1042,6 +1093,9 @@ static int qfq_init_qdisc(struct Qdisc *
 			INIT_HLIST_HEAD(&grp->slots[j]);
 	}
 
+	q->debugfs = debugfs_create_file(sch->dev_queue->dev->name,
+					 S_IRUGO, qfq_debug, sch,
+					 &qfq_debug_fops);
 	return 0;
 }
 
@@ -1121,11 +1175,16 @@ static struct Qdisc_ops qfq_qdisc_ops __
 
 static int __init qfq_init(void)
 {
+	qfq_debug = debugfs_create_dir("qfq", NULL);
+
 	return register_qdisc(&qfq_qdisc_ops);
 }
 
 static void __exit qfq_exit(void)
 {
+	if (qfq_debug)
+		debugfs_remove(qfq_debug);
+
 	unregister_qdisc(&qfq_qdisc_ops);
 }
 
