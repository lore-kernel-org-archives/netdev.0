From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 05/12] netfilter: udp proto sysctl support for net namespace
Date: Tue, 17 Apr 2012 10:56:16 +0800
Message-ID: <1334631383-12326-6-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:11141 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754633Ab2DQDfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 23:35:10 -0400
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add and export four functions nf_conntrack_proto_ipv[4,6]_udp_[init,fini]
for the nf_conntrack_ipv[4,6] modules.

modify the udp_timeouts to net->ct.proto.sysctl_udp_timeouts
---
 net/netfilter/nf_conntrack_proto_udp.c |  160 +++++++++++++++++++++++++++-----
 1 files changed, 138 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index a9073dc..8e2935a 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -19,18 +19,13 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/nf_conntrack_udp.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 
-enum udp_conntrack {
-	UDP_CT_UNREPLIED,
-	UDP_CT_REPLIED,
-	UDP_CT_MAX
-};
-
 static unsigned int udp_timeouts[UDP_CT_MAX] = {
 	[UDP_CT_UNREPLIED]	= 30*HZ,
 	[UDP_CT_REPLIED]	= 180*HZ,
@@ -73,7 +68,7 @@ static int udp_print_tuple(struct seq_file *s,
 
 static unsigned int *udp_get_timeouts(struct net *net)
 {
-	return udp_timeouts;
+	return net->ct.proto.sysctl_udp_timeouts;
 }
 
 /* Returns verdict for packet, and may modify conntracktype */
@@ -199,8 +194,6 @@ udp_timeout_nla_policy[CTA_TIMEOUT_UDP_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static unsigned int udp_sysctl_table_users;
-static struct ctl_table_header *udp_sysctl_header;
 static struct ctl_table udp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udp_timeout",
@@ -266,14 +259,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udp_sysctl_table_users,
-	.ctl_table_header	= &udp_sysctl_header,
-	.ctl_table		= udp_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= udp_compat_sysctl_table,
-#endif
-#endif
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
 
@@ -304,10 +289,141 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udp_sysctl_table_users,
-	.ctl_table_header	= &udp_sysctl_header,
-	.ctl_table		= udp_sysctl_table,
-#endif
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
+
+static int nf_conntrack_proto_udp_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	int i, ret = 0;
+
+#ifdef CONFIG_SYSCTL
+	if (!net->ct.proto.udp_sysctl_header) {
+		net->ct.proto.udp_table_users = 0;
+		for (i = 0; i < UDP_CT_MAX; i++)
+			net->ct.proto.sysctl_udp_timeouts[i] = udp_timeouts[i];
+		table = kmemdup(udp_sysctl_table,
+				sizeof(udp_sysctl_table),
+				GFP_KERNEL);
+		if (!table)
+			return -ENOMEM;
+		table[0].data = &net->ct.proto.
+				sysctl_udp_timeouts[UDP_CT_UNREPLIED];
+		table[1].data = &net->ct.proto.
+				sysctl_udp_timeouts[UDP_CT_REPLIED];
+	} else
+		table = net->ct.proto.udp_sysctl_header->ctl_table_arg;
+
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.udp_sysctl_header,
+					nf_net_netfilter_sysctl_path,
+					table,
+					&net->ct.proto.udp_table_users);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_udp:"
+			" can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	if (!net->ct.proto.udp_sysctl_header)
+		kfree(table);
+#else
+	for (i = 0; i < UDP_CT_MAX; i++)
+		net->ct.proto.sysctl_udp_timeouts[i] = udp_timeouts[i];
+#endif
+	return ret;
+}
+
+static void nf_conntrack_proto_udp_net_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *table;
+	table = net->ct.proto.udp_sysctl_header->ctl_table_arg;
+
+	nf_ct_unregister_net_sysctl(&net->ct.proto.udp_sysctl_header,
+				    table,
+				    &net->ct.proto.udp_table_users);
+#endif
+}
+
+static int nf_conntrack_proto_udp_compat_init(struct net *net)
+{
+	int ret = 0;
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *compat_table;
+	compat_table = kmemdup(udp_compat_sysctl_table,
+			       sizeof(udp_compat_sysctl_table),
+			       GFP_KERNEL);
+	if (!compat_table)
+		return -ENOMEM;
+	compat_table[0].data = &net->ct.proto.
+				sysctl_udp_timeouts[UDP_CT_UNREPLIED];
+	compat_table[1].data = &net->ct.proto.
+				sysctl_udp_timeouts[UDP_CT_REPLIED];
+
+	ret = nf_ct_register_net_sysctl(net, 
+					&net->ct.proto.udp_compat_header,
+					nf_net_ipv4_netfilter_sysctl_path,
+					compat_table,
+					NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_udp:"
+			" can't register to compat sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	kfree(compat_table);
+#endif
+#endif
+	return ret;
+}
+
+static void nf_conntrack_proto_udp_compat_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *compat_table;
+	compat_table = net->ct.proto.udp_compat_header->ctl_table_arg;
+	nf_ct_unregister_net_sysctl(&net->ct.proto.udp_compat_header,
+				    compat_table,
+				    NULL);
+#endif
+#endif
+}
+
+int nf_conntrack_proto_ipv4_udp_init(struct net *net)
+{
+	int ret = 0;
+	ret = nf_conntrack_proto_udp_net_init(net);
+	if (ret < 0)
+		return ret;
+	ret = nf_conntrack_proto_udp_compat_init(net);
+	if (ret < 0)
+		nf_conntrack_proto_udp_net_fini(net);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv4_udp_init);
+
+void nf_conntrack_proto_ipv4_udp_fini(struct net *net)
+{
+	nf_conntrack_proto_udp_compat_fini(net);
+	nf_conntrack_proto_udp_net_fini(net);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv4_udp_fini);
+
+int nf_conntrack_proto_ipv6_udp_init(struct net *net)
+{
+	return nf_conntrack_proto_udp_net_init(net);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv6_udp_init);
+
+void nf_conntrack_proto_ipv6_udp_fini(struct net *net)
+{
+	return nf_conntrack_proto_udp_net_fini(net);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv6_udp_fini);
-- 
1.7.7.6
