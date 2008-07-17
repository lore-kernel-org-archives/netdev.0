From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 12/16] proc: create /proc/net/snmp file in each net
Date: Thu, 17 Jul 2008 17:36:42 +0400
Message-ID: <487F4AEA.8090609@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51120 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbYGQNgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:36:50 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the statistics show in this file is also made per-net already.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/proc.c |   70 +++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index df8c4af..367b81f 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -266,11 +266,12 @@ static void icmpmsg_put(struct seq_file *seq)
 
 	int j, i, count;
 	static int out[PERLINE];
+	struct net *net = seq->private;
 
 	count = 0;
 	for (i = 0; i < ICMPMSG_MIB_MAX; i++) {
 
-		if (snmp_fold_field((void **) init_net.mib.icmpmsg_statistics, i))
+		if (snmp_fold_field((void **) net->mib.icmpmsg_statistics, i))
 			out[count++] = i;
 		if (count < PERLINE)
 			continue;
@@ -282,7 +283,7 @@ static void icmpmsg_put(struct seq_file *seq)
 		seq_printf(seq, "\nIcmpMsg: ");
 		for (j = 0; j < PERLINE; ++j)
 			seq_printf(seq, " %lu",
-				snmp_fold_field((void **) init_net.mib.icmpmsg_statistics,
+				snmp_fold_field((void **) net->mib.icmpmsg_statistics,
 				out[j]));
 		seq_putc(seq, '\n');
 	}
@@ -294,7 +295,7 @@ static void icmpmsg_put(struct seq_file *seq)
 		seq_printf(seq, "\nIcmpMsg:");
 		for (j = 0; j < count; ++j)
 			seq_printf(seq, " %lu", snmp_fold_field((void **)
-				init_net.mib.icmpmsg_statistics, out[j]));
+				net->mib.icmpmsg_statistics, out[j]));
 	}
 
 #undef PERLINE
@@ -303,6 +304,7 @@ static void icmpmsg_put(struct seq_file *seq)
 static void icmp_put(struct seq_file *seq)
 {
 	int i;
+	struct net *net = seq->private;
 
 	seq_puts(seq, "\nIcmp: InMsgs InErrors");
 	for (i=0; icmpmibmap[i].name != NULL; i++)
@@ -311,18 +313,18 @@ static void icmp_put(struct seq_file *seq)
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
 	seq_printf(seq, "\nIcmp: %lu %lu",
-		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_INMSGS),
-		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_INERRORS));
+		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_INMSGS),
+		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_INERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void **) init_net.mib.icmpmsg_statistics,
+			snmp_fold_field((void **) net->mib.icmpmsg_statistics,
 				icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
-		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_OUTMSGS),
-		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_OUTERRORS));
+		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
+		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void **) init_net.mib.icmpmsg_statistics,
+			snmp_fold_field((void **) net->mib.icmpmsg_statistics,
 				icmpmibmap[i].index | 0x100));
 }
 
@@ -332,6 +334,7 @@ static void icmp_put(struct seq_file *seq)
 static int snmp_seq_show(struct seq_file *seq, void *v)
 {
 	int i;
+	struct net *net = seq->private;
 
 	seq_puts(seq, "Ip: Forwarding DefaultTTL");
 
@@ -344,7 +347,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)init_net.mib.ip_statistics,
+			   snmp_fold_field((void **)net->mib.ip_statistics,
 					   snmp4_ipstats_list[i].entry));
 
 	icmp_put(seq);	/* RFC 2011 compatibility */
@@ -359,11 +362,11 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
 			seq_printf(seq, " %ld",
-				   snmp_fold_field((void **)init_net.mib.tcp_statistics,
+				   snmp_fold_field((void **)net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 		else
 			seq_printf(seq, " %lu",
-				   snmp_fold_field((void **)init_net.mib.tcp_statistics,
+				   snmp_fold_field((void **)net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 	}
 
@@ -374,7 +377,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdp:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)init_net.mib.udp_statistics,
+			   snmp_fold_field((void **)net->mib.udp_statistics,
 					   snmp4_udp_list[i].entry));
 
 	/* the UDP and UDP-Lite MIBs are the same */
@@ -385,7 +388,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdpLite:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)init_net.mib.udplite_statistics,
+			   snmp_fold_field((void **)net->mib.udplite_statistics,
 					   snmp4_udp_list[i].entry));
 
 	seq_putc(seq, '\n');
@@ -394,7 +397,32 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 
 static int snmp_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, snmp_seq_show, NULL);
+	int err;
+	struct net *net;
+
+	err = -ENXIO;
+	net = get_proc_net(inode);
+	if (net == NULL)
+		goto err_net;
+
+	err = single_open(file, snmp_seq_show, net);
+	if (err < 0)
+		goto err_open;
+
+	return 0;
+
+err_open:
+	put_net(net);
+err_net:
+	return err;
+}
+
+static int snmp_seq_release(struct inode *inode, struct file *file)
+{
+	struct net *net = ((struct seq_file *)file->private_data)->private;
+
+	put_net(net);
+	return single_release(inode, file);
 }
 
 static const struct file_operations snmp_seq_fops = {
@@ -402,7 +430,7 @@ static const struct file_operations snmp_seq_fops = {
 	.open	 = snmp_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = snmp_seq_release,
 };
 
 
@@ -483,9 +511,13 @@ static __net_init int ip_proc_init_net(struct net *net)
 		return -ENOMEM;
 	if (!proc_net_fops_create(net, "netstat", S_IRUGO, &netstat_seq_fops))
 		goto out_netstat;
+	if (!proc_net_fops_create(net, "snmp", S_IRUGO, &snmp_seq_fops))
+		goto out_snmp;
 
 	return 0;
 
+out_snmp:
+	proc_net_remove(net, "netstat");
 out_netstat:
 	proc_net_remove(net, "sockstat");
 	return -ENOMEM;
@@ -493,6 +525,7 @@ out_netstat:
 
 static __net_exit void ip_proc_exit_net(struct net *net)
 {
+	proc_net_remove(net, "snmp");
 	proc_net_remove(net, "netstat");
 	proc_net_remove(net, "sockstat");
 }
@@ -509,12 +542,9 @@ int __init ip_misc_proc_init(void)
 	if (register_pernet_subsys(&ip_proc_ops))
 		goto out_pernet;
 
-	if (!proc_net_fops_create(&init_net, "snmp", S_IRUGO, &snmp_seq_fops))
-		goto out_snmp;
 out:
 	return rc;
-out_snmp:
-	unregister_pernet_subsys(&ip_proc_ops);
+
 out_pernet:
 	rc = -ENOMEM;
 	goto out;
-- 
1.5.5.1

