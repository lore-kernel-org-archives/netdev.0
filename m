From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 06/12] netfilter: icmp proto sysctl support for net namespace
Date: Tue, 17 Apr 2012 10:56:17 +0800
Message-ID: <1334631383-12326-7-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:44696 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755481Ab2DQDfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 23:35:08 -0400
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add and export functions nf_conntrack_proto_ipv4_icmp_[init,fini]
for the nf_conntrack_ipv4 modules.

modify the nf_ct_icmp_timeout to net->ct.proto.sysctl_icmp_timeout
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c |  116 ++++++++++++++++++++++++--
 1 files changed, 108 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 7cbe9cb..fa827ee 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -12,6 +12,7 @@
 #include <linux/in.h>
 #include <linux/icmp.h>
 #include <linux/seq_file.h>
+#include <linux/module.h>
 #include <net/ip.h>
 #include <net/checksum.h>
 #include <linux/netfilter_ipv4.h>
@@ -77,7 +78,7 @@ static int icmp_print_tuple(struct seq_file *s,
 
 static unsigned int *icmp_get_timeouts(struct net *net)
 {
-	return &nf_ct_icmp_timeout;
+	return &net->ct.proto.sysctl_icmp_timeout;
 }
 
 /* Returns verdict for packet, or -1 for invalid. */
@@ -308,11 +309,10 @@ icmp_timeout_nla_policy[CTA_TIMEOUT_ICMP_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table_header *icmp_sysctl_header;
 static struct ctl_table icmp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_icmp_timeout",
-		.data		= &nf_ct_icmp_timeout,
+		.data		= &init_net.ct.proto.sysctl_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -323,7 +323,7 @@ static struct ctl_table icmp_sysctl_table[] = {
 static struct ctl_table icmp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_icmp_timeout",
-		.data		= &nf_ct_icmp_timeout,
+		.data		= &init_net.ct.proto.sysctl_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -362,11 +362,111 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 		.nla_policy	= icmp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+};
+
+static int nf_conntrack_proto_icmp_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	int ret = 0;
+
+	net->ct.proto.sysctl_icmp_timeout = nf_ct_icmp_timeout;
+#ifdef CONFIG_SYSCTL
+	table = kmemdup(icmp_sysctl_table,
+			sizeof(icmp_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+	table[0].data = &net->ct.proto.sysctl_icmp_timeout;
+
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.icmp_sysctl_header,
+					nf_net_netfilter_sysctl_path,
+					table,
+					NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack icmp: can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	kfree(table);
+#endif
+	return ret;
+}
+
+static void nf_conntrack_proto_icmp_net_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *table;
+	table = net->ct.proto.icmp_sysctl_header->ctl_table_arg;
+
+	nf_ct_unregister_net_sysctl(&net->ct.proto.icmp_sysctl_header,
+				    table,
+				    NULL);
+#endif
+}
+
+static int nf_conntrack_proto_icmp_compat_init(struct net *net)
+{
+	int ret = 0;
 #ifdef CONFIG_SYSCTL
-	.ctl_table_header	= &icmp_sysctl_header,
-	.ctl_table		= icmp_sysctl_table,
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= icmp_compat_sysctl_table,
+	struct ctl_table *compat_table;
+	compat_table = kmemdup(icmp_compat_sysctl_table,
+			       sizeof(icmp_compat_sysctl_table),
+			       GFP_KERNEL);
+	if (!compat_table)
+		return -ENOMEM;
+	compat_table[0].data = &net->ct.proto.sysctl_icmp_timeout;
+
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.icmp_compat_header,
+					nf_net_ipv4_netfilter_sysctl_path,
+					compat_table,
+					NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack icmp: register compat sysctl failed.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	kfree(compat_table);
 #endif
 #endif
-};
+	return ret;
+}
+
+static void nf_conntrack_proto_icmp_compat_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *compat_table;
+	compat_table = net->ct.proto.icmp_compat_header->ctl_table_arg;
+	nf_ct_unregister_net_sysctl(&net->ct.proto.icmp_compat_header,
+				    compat_table,
+				    NULL);
+#endif
+#endif
+}
+
+int nf_conntrack_proto_ipv4_icmp_init(struct net *net)
+{
+	int ret = 0;
+	ret = nf_conntrack_proto_icmp_net_init(net);
+	if (ret < 0)
+		return ret;
+	ret = nf_conntrack_proto_icmp_compat_init(net);
+	if (ret < 0)
+		nf_conntrack_proto_icmp_net_fini(net);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv4_icmp_init);
+
+void nf_conntrack_proto_ipv4_icmp_fini(struct net *net)
+{
+	nf_conntrack_proto_icmp_compat_fini(net);
+	nf_conntrack_proto_icmp_net_fini(net);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv4_icmp_fini);
-- 
1.7.7.6
