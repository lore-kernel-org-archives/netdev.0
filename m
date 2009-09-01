From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 15:30:06 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909011526480.12112@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:59653 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753764AbZIAPa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:30:59 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CA8FF82C5DB
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 11:32:37 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4PUx9CWhVld0 for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 11:32:37 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5149E82C77A
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 11:32:25 -0400 (EDT)
In-Reply-To: <4A9D2DBF.8030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, Patrick McHardy wrote:

> That explains it. The bnx2 driver uses multiple TX queues, but
> tc_dump_qdisc() only dumps the statistics from queue number 0.

There are no stats in other queues either... This is the result after
sending 10000 or so packets. Maybe I am not catching all the qdiscs?

(this is the result of a pretty raw patch to dump all qdiscs)

#cat /proc/net/qdisc_stats
Type Device State Bytes Packets Qlen Backlog Drops Requeues Overlimits
TX root <NULL> 0 0 0 0 0 0 0 0
RX root <NULL> 0 0 0 0 0 0 0 0
TX root  eth0 0 24830 155 0 0 0 0 0
RX root <NULL> 0 0 0 0 0 0 0 0
TX root <NULL> 0 0 0 0 0 0 0 0
RX root <NULL> 0 0 0 0 0 0 0 0
TX root <NULL> 0 0 0 0 0 0 0 0
RX root <NULL> 0 0 0 0 0 0 0 0
TX root <NULL> 0 0 0 0 0 0 0 0
RX root <NULL> 0 0 0 0 0 0 0 0

---
 net/sched/sch_api.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)

Index: linux-2.6/net/sched/sch_api.c
===================================================================
--- linux-2.6.orig/net/sched/sch_api.c	2009-08-31 21:19:04.000000000 +0000
+++ linux-2.6/net/sched/sch_api.c	2009-09-01 14:30:40.000000000 +0000
@@ -1699,6 +1699,69 @@ static const struct file_operations psch
 	.llseek = seq_lseek,
 	.release = single_release,
 };
+
+static void dump_qdisc(struct seq_file *seq, struct Qdisc *q, char *inout, char *text)
+{
+	seq_printf(seq, "%2s %2s %5s %lx %lld %d %d %d %d %d %d\n",
+		inout, text, q->dev_queue->dev->name, q->state,
+		q->bstats.bytes, q->bstats.packets,
+		q->qstats.qlen, q->qstats.backlog, q->qstats.drops,
+		q->qstats.requeues, q->qstats.overlimits);
+}
+
+static void dump_qdisc_root(struct seq_file *seq, struct Qdisc *root, char *inout)
+{
+	struct Qdisc *q;
+	int n = 0;
+
+	if (!root)
+		return;
+
+	dump_qdisc(seq, root, inout, "root");
+
+	list_for_each_entry(q, &root->list, list) {
+		char buffer[10];
+
+		sprintf(buffer,"%d", ++n);
+		dump_qdisc(seq, q, inout, buffer);
+	}
+}
+
+
+static int qdisc_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev;
+
+	seq_printf(seq, "Type Device State Bytes Packets "
+			"Qlen Backlog Drops Requeues Overlimits\n");
+
+	read_lock(&dev_base_lock);
+
+	for_each_netdev(&init_net, dev) {
+		struct netdev_queue *dev_queue;
+
+		dev_queue = netdev_get_tx_queue(dev, 0);
+		dump_qdisc_root(seq, dev_queue->qdisc_sleeping, "TX");
+		dev_queue = &dev->rx_queue;
+		dump_qdisc_root(seq, dev_queue->qdisc_sleeping, "RX");
+	}
+
+	read_unlock(&dev_base_lock);
+	return 0;
+}
+
+static int qdisc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, qdisc_show, PDE(inode)->data);
+}
+
+static const struct file_operations qdisc_fops = {
+	.owner = THIS_MODULE,
+	.open = qdisc_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
 #endif

 static int __init pktsched_init(void)
@@ -1706,6 +1769,7 @@ static int __init pktsched_init(void)
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
 	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
+	proc_net_fops_create(&init_net, "qdisc_stats", 0, &qdisc_fops);

 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);
