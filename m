From: igorm@etf.rs
Subject: [PATCH 09/10 net-next] net:ipv4:proc: Introduce proc files for ipv4 per interface stats
Date: Fri, 16 Dec 2011 16:26:02 +0100
Message-ID: <1324049163-11207-10-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:35872 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760002Ab1LPP0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:32 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

In ip_proc_init_net dev_snmp proc directory is created.

Functions snmp_(un)register_dev are for creating/deleting proc files
that have same names as interfaces for which they are created.

Per device proc files for ipv4 interfaces have the same form as
per device proc files for ipv6 interfaces.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv4/proc.c |  121 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 121 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 3569d8e..c6202d9 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -128,6 +128,14 @@ static const struct snmp_mib snmp4_ipextstats_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
+static const struct snmp_mib snmp4_icmp_list[] = {
+	SNMP_MIB_ITEM("InMsgs", ICMP_MIB_INMSGS),
+	SNMP_MIB_ITEM("InErrors", ICMP_MIB_INERRORS),
+	SNMP_MIB_ITEM("OutMsgs", ICMP_MIB_OUTMSGS),
+	SNMP_MIB_ITEM("OutErrors", ICMP_MIB_OUTERRORS),
+	SNMP_MIB_SENTINEL
+};
+
 static const struct {
 	const char *name;
 	int index;
@@ -459,6 +467,113 @@ static const struct file_operations netstat_seq_fops = {
 	.release = single_release_net,
 };
 
+static void snmp_seq_show_item(struct seq_file *seq, void __percpu **pcpumib,
+				atomic_long_t *smib,
+				const struct snmp_mib *itemlist,
+				char *prefix)
+{
+	char name[32];
+	int i;
+	unsigned long val;
+
+	for (i = 0; itemlist[i].name; i++) {
+		val = pcpumib ?
+			snmp_fold_field64(pcpumib, itemlist[i].entry,
+				offsetof(struct ipstats_mib, syncp)) :
+			atomic_long_read(smib + itemlist[i].entry);
+		snprintf(name, sizeof(name), "%s%s",
+				prefix, itemlist[i].name);
+		seq_printf(seq, "%-32s\t%lu\n", name, val);
+	}
+}
+
+static void snmp_seq_show_icmpmsg(struct seq_file *seq, atomic_long_t *smib)
+{
+	char name[32];
+	int i;
+	unsigned long val;
+	for (i = 0; i < ICMPMSG_MIB_MAX; i++) {		
+		val = atomic_long_read(smib + i);
+		if (val) {
+			snprintf(name, sizeof(name), "Icmp%sType%u",
+				i & 0x100 ? "Out" : "In", i & 0xff);
+			seq_printf(seq, "%-32s\t%lu\n", name, val);
+		}
+	}
+}
+
+static int snmp_dev_seq_show(struct seq_file *seq, void *v)
+{
+	struct in_device *idev = (struct in_device *)seq->private;
+
+	seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
+	seq_printf(seq, "%-32s\t%u\n", "Forwarding",
+		IN_DEV_FORWARD(idev));
+	seq_printf(seq, "%-32s\t%u\n", "McForwarding",
+		IN_DEV_MFORWARD(idev));
+	seq_printf(seq, "%-32s\t%u\n", "DefaultTTL",
+		   sysctl_ip_default_ttl);
+
+	BUILD_BUG_ON(offsetof(struct ipstats_mib, mibs) != 0);
+
+	snmp_seq_show_item(seq, (void __percpu **)idev->stats.ip, NULL,
+				snmp4_ipstats_list, "Ip");
+	snmp_seq_show_item(seq, (void __percpu **)idev->stats.ip, NULL,
+				snmp4_ipextstats_list, "Ip");
+	snmp_seq_show_item(seq, NULL, idev->stats.icmpdev->mibs,
+				snmp4_icmp_list, "Icmp");
+	snmp_seq_show_icmpmsg(seq, idev->stats.icmpmsgdev->mibs);
+	return 0;
+}
+
+static int snmp_dev_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, snmp_dev_seq_show, PDE(inode)->data);
+}
+
+static const struct file_operations snmp_dev_seq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = snmp_dev_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
+};
+
+int snmp_register_dev(struct in_device *idev)
+{
+	struct proc_dir_entry *p;
+	struct net *net;
+
+	if (!idev || !idev->dev)
+		return -EINVAL;
+
+	net = dev_net(idev->dev);
+	if (!net->mib.proc_net_devsnmp)
+		return -ENOENT;
+
+	p = proc_create_data(idev->dev->name, S_IRUGO,
+			net->mib.proc_net_devsnmp,
+			&snmp_dev_seq_fops, idev);
+	if (!p) 
+		return -ENOMEM;
+
+	idev->stats.proc_dir_entry = p;
+	return 0;
+}
+
+int snmp_unregister_dev(struct in_device *idev)
+{
+	struct net *net = dev_net(idev->dev);
+	if (!net->mib.proc_net_devsnmp)
+		return -ENOENT;
+	if (!idev->stats.proc_dir_entry)
+		return -EINVAL;
+	remove_proc_entry(idev->stats.proc_dir_entry->name,
+		net->mib.proc_net_devsnmp);
+	idev->stats.proc_dir_entry = NULL;
+	return 0;
+}
+
 static __net_init int ip_proc_init_net(struct net *net)
 {
 	if (!proc_net_fops_create(net, "sockstat", S_IRUGO, &sockstat_seq_fops))
@@ -467,9 +582,14 @@ static __net_init int ip_proc_init_net(struct net *net)
 		goto out_netstat;
 	if (!proc_net_fops_create(net, "snmp", S_IRUGO, &snmp_seq_fops))
 		goto out_snmp;
+	net->mib.proc_net_devsnmp = proc_mkdir("dev_snmp", net->proc_net);
+	if (!net->mib.proc_net_devsnmp)
+		goto out_dev_snmp;
 
 	return 0;
 
+out_dev_snmp:
+	proc_net_remove(net, "snmp");
 out_snmp:
 	proc_net_remove(net, "netstat");
 out_netstat:
@@ -483,6 +603,7 @@ static __net_exit void ip_proc_exit_net(struct net *net)
 	proc_net_remove(net, "snmp");
 	proc_net_remove(net, "netstat");
 	proc_net_remove(net, "sockstat");
+	proc_net_remove(net, "dev_snmp");
 }
 
 static __net_initdata struct pernet_operations ip_proc_ops = {
-- 
1.7.5.4
