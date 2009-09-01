From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 17:55:44 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909011753230.25607@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <4A9D3687.2020101@gmail.com> <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1> <4A9D3D9A.1030500@gmail.com>
 <alpine.DEB.1.10.0909011534350.12112@V090114053VZO-1> <4A9D410D.5000507@gmail.com> <4A9D448D.6050309@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:54281 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754706AbZIAR4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 13:56:49 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3E57582C826
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 13:58:21 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zQlhuhi7BCt6 for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 13:58:16 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6327682C7E8
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 13:58:12 -0400 (EDT)
In-Reply-To: <4A9D448D.6050309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok i got some meaningful statistics now. Why is the qlen zero for all
devices?

$ cat /proc/net/qdisc_stats
Type     Device  St    Bytes Packts Qlen Bklg  Drops Requeu Overlimit
TX0 root     lo   0        0      0    0    0      0      0      0
 RX root     lo   0        0      0    0    0      0      0      0
TX0 root   eth0   0    12463     91    0    0      0      0      0
TX1 root   eth0   0     2954     39    0    0      0      0      0
TX2 root   eth0   0     2132     23    0    0      0      0      0
TX3 root   eth0   0    29293    210    0    0      0      0      0
TX4 root   eth0   0     2805     31    0    0      0      0      0
TX5 root   eth0   0 1286862317 3762765    0    0 643253  30886      0
TX6 root   eth0   0     1310     17    0    0      0      0      0
TX7 root   eth0   0     2860     31    0    0      0      0      0

---
 net/sched/sch_api.c |   72 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

Index: linux-2.6/net/sched/sch_api.c
===================================================================
--- linux-2.6.orig/net/sched/sch_api.c	2009-09-01 12:27:24.000000000 -0500
+++ linux-2.6/net/sched/sch_api.c	2009-09-01 12:40:30.000000000 -0500
@@ -1699,6 +1699,77 @@ static const struct file_operations psch
 	.llseek = seq_lseek,
 	.release = single_release,
 };
+
+static void dump_qdisc(struct seq_file *seq, struct net_device *dev,
+				struct Qdisc *q, char *inout, char *text)
+{
+	seq_printf(seq, "%3s %2s %6s %3lx %8lld %6d %4d %4d %6d %6d %6d\n",
+		inout, text, dev->name, q->state,
+		q->bstats.bytes, q->bstats.packets,
+		q->qstats.qlen, q->qstats.backlog, q->qstats.drops,
+		q->qstats.requeues, q->qstats.overlimits);
+}
+
+static void dump_qdisc_root(struct seq_file *seq, struct net_device *dev,
+					 struct Qdisc *root, char *inout)
+{
+	struct Qdisc *q;
+	int n = 0;
+
+	if (!root)
+		return;
+
+	dump_qdisc(seq, dev, root, inout, "root");
+
+	list_for_each_entry(q, &root->list, list) {
+		char buffer[10];
+
+		sprintf(buffer,"Q%d", ++n);
+		dump_qdisc(seq, dev, q, inout, buffer);
+	}
+}
+
+
+static int qdisc_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev;
+
+	seq_printf(seq, "Type     Device  St    Bytes Packts "
+			"Qlen Bklg  Drops Requeu Overlimit\n");
+
+	read_lock(&dev_base_lock);
+
+	for_each_netdev(&init_net, dev) {
+		struct netdev_queue *dev_queue;
+		int i;
+
+		for (i = 0; i < dev->real_num_tx_queues; i++) {
+			char buffer[10];
+
+			dev_queue = netdev_get_tx_queue(dev, i);
+			sprintf(buffer, "TX%d", i);
+			dump_qdisc_root(seq, dev, dev_queue->qdisc_sleeping, buffer);
+		}
+		dev_queue = &dev->rx_queue;
+		dump_qdisc_root(seq, dev, dev_queue->qdisc_sleeping, "RX");
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
@@ -1706,6 +1777,7 @@ static int __init pktsched_init(void)
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
 	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
+	proc_net_fops_create(&init_net, "qdisc_stats", 0, &qdisc_fops);

 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);
