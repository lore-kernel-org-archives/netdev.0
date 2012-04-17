From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 07/12] netfilter: icmpv6 proto sysctl support for net
Date: Tue, 17 Apr 2012 10:56:18 +0800
Message-ID: <1334631383-12326-8-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:9871 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755383Ab2DQDfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 23:35:07 -0400
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add and export functions nf_conntrack_proto_icmpv6_net_[init,fini]
for the nf_conntrack_ipv6 modules.

modify the nf_ct_icmpv6_timeout to net->ct.proto.sysctl_icmpv6_timeout

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   54 +++++++++++++++++++++---
 1 files changed, 48 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 92cc9f2..ef33f31 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -90,7 +90,7 @@ static int icmpv6_print_tuple(struct seq_file *s,
 
 static unsigned int *icmpv6_get_timeouts(struct net *net)
 {
-	return &nf_ct_icmpv6_timeout;
+	return &net->ct.proto.sysctl_icmpv6_timeout;
 }
 
 /* Returns verdict for packet, or -1 for invalid. */
@@ -315,11 +315,10 @@ icmpv6_timeout_nla_policy[CTA_TIMEOUT_ICMPV6_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table_header *icmpv6_sysctl_header;
 static struct ctl_table icmpv6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_icmpv6_timeout",
-		.data		= &nf_ct_icmpv6_timeout,
+		.data		= &init_net.ct.proto.sysctl_icmpv6_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -355,8 +354,51 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 		.nla_policy	= icmpv6_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+};
+
+int nf_conntrack_proto_icmpv6_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	int ret = 0;
+
+	net->ct.proto.sysctl_icmpv6_timeout = nf_ct_icmpv6_timeout;
+
 #ifdef CONFIG_SYSCTL
-	.ctl_table_header	= &icmpv6_sysctl_header,
-	.ctl_table		= icmpv6_sysctl_table,
+	table = kmemdup(icmpv6_sysctl_table,
+			sizeof(icmpv6_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+	table[0].data = &net->ct.proto.sysctl_icmpv6_timeout;
+
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.icmpv6_sysctl_header,
+					nf_net_netfilter_sysctl_path,
+					table,
+					NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_icmpv6:"
+			" can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	kfree(table);
 #endif
-};
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_icmpv6_net_init);
+
+void nf_conntrack_proto_icmpv6_net_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *table;
+	table = net->ct.proto.icmpv6_sysctl_header->ctl_table_arg;
+
+	nf_ct_unregister_net_sysctl(&net->ct.proto.icmpv6_sysctl_header,
+				    table, NULL);
+#endif
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_icmpv6_net_fini);
+
-- 
1.7.7.6
