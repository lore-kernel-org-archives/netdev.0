From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 11/16] proc: create /proc/net/netstat file in each net
Date: Thu, 17 Jul 2008 17:35:22 +0400
Message-ID: <487F4A9A.4070500@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51069 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755814AbYGQNf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:35:27 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now all the shown in it statistics is netnsizated, time to
show it in appropriate net.

The appropriate net init/exit ops already exist - they make
the sockstat file per net - so just extend them.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/proc.c |   47 ++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index e11144b..df8c4af 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -413,6 +413,7 @@ static const struct file_operations snmp_seq_fops = {
 static int netstat_seq_show(struct seq_file *seq, void *v)
 {
 	int i;
+	struct net *net = seq->private;
 
 	seq_puts(seq, "TcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
@@ -421,7 +422,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nTcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)init_net.mib.net_statistics,
+			   snmp_fold_field((void **)net->mib.net_statistics,
 					   snmp4_net_list[i].entry));
 
 	seq_puts(seq, "\nIpExt:");
@@ -431,7 +432,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nIpExt:");
 	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)init_net.mib.ip_statistics,
+			   snmp_fold_field((void **)net->mib.ip_statistics,
 					   snmp4_ipextstats_list[i].entry));
 
 	seq_putc(seq, '\n');
@@ -440,7 +441,32 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 
 static int netstat_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, netstat_seq_show, NULL);
+	int err;
+	struct net *net;
+
+	err = -ENXIO;
+	net = get_proc_net(inode);
+	if (net == NULL)
+		goto err_net;
+
+	err = single_open(file, netstat_seq_show, net);
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
+static int netstat_seq_release(struct inode *inode, struct file *file)
+{
+	struct net *net = ((struct seq_file *)file->private_data)->private;
+
+	put_net(net);
+	return single_release(inode, file);
 }
 
 static const struct file_operations netstat_seq_fops = {
@@ -448,18 +474,26 @@ static const struct file_operations netstat_seq_fops = {
 	.open	 = netstat_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = netstat_seq_release,
 };
 
 static __net_init int ip_proc_init_net(struct net *net)
 {
 	if (!proc_net_fops_create(net, "sockstat", S_IRUGO, &sockstat_seq_fops))
 		return -ENOMEM;
+	if (!proc_net_fops_create(net, "netstat", S_IRUGO, &netstat_seq_fops))
+		goto out_netstat;
+
 	return 0;
+
+out_netstat:
+	proc_net_remove(net, "sockstat");
+	return -ENOMEM;
 }
 
 static __net_exit void ip_proc_exit_net(struct net *net)
 {
+	proc_net_remove(net, "netstat");
 	proc_net_remove(net, "sockstat");
 }
 
@@ -475,16 +509,11 @@ int __init ip_misc_proc_init(void)
 	if (register_pernet_subsys(&ip_proc_ops))
 		goto out_pernet;
 
-	if (!proc_net_fops_create(&init_net, "netstat", S_IRUGO, &netstat_seq_fops))
-		goto out_netstat;
-
 	if (!proc_net_fops_create(&init_net, "snmp", S_IRUGO, &snmp_seq_fops))
 		goto out_snmp;
 out:
 	return rc;
 out_snmp:
-	proc_net_remove(&init_net, "netstat");
-out_netstat:
 	unregister_pernet_subsys(&ip_proc_ops);
 out_pernet:
 	rc = -ENOMEM;
-- 
1.5.5.1

