From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 11/12] netfilter: udplite proto sysctl support for net
Date: Tue, 17 Apr 2012 10:56:22 +0800
Message-ID: <1334631383-12326-12-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

register pernet_operations nf_conntrack_net_proto_udplite_ops
when loading nf_conntrack_proto_udplite module,and unregister
it when removing.

It makes no senes to register subsys for udplite and udplite6,because
the nf_conntrack_l4proto_udplite4 and nf_conntrack_l4proto_udplite6 are
register or unregister together.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_udplite.c |   83 +++++++++++++++++++++------
 1 files changed, 64 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index e060639..61881bc 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -20,16 +20,11 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/nf_conntrack_udplite.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
 
-enum udplite_conntrack {
-	UDPLITE_CT_UNREPLIED,
-	UDPLITE_CT_REPLIED,
-	UDPLITE_CT_MAX
-};
-
 static unsigned int udplite_timeouts[UDPLITE_CT_MAX] = {
 	[UDPLITE_CT_UNREPLIED]	= 30*HZ,
 	[UDPLITE_CT_REPLIED]	= 180*HZ,
@@ -70,7 +65,7 @@ static int udplite_print_tuple(struct seq_file *s,
 
 static unsigned int *udplite_get_timeouts(struct net *net)
 {
-	return udplite_timeouts;
+	return net->ct.proto.sysctl_udplite_timeouts;
 }
 
 /* Returns verdict for packet, and may modify conntracktype */
@@ -203,19 +198,19 @@ udplite_timeout_nla_policy[CTA_TIMEOUT_UDPLITE_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static unsigned int udplite_sysctl_table_users;
-static struct ctl_table_header *udplite_sysctl_header;
 static struct ctl_table udplite_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udplite_timeout",
-		.data		= &udplite_timeouts[UDPLITE_CT_UNREPLIED],
+		.data		= &init_net.ct.proto.
+				sysctl_udplite_timeouts[UDPLITE_CT_UNREPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_udplite_timeout_stream",
-		.data		= &udplite_timeouts[UDPLITE_CT_REPLIED],
+		.data		= &init_net.ct.proto.
+				sysctl_udplite_timeouts[UDPLITE_CT_REPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -252,11 +247,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 		.nla_policy	= udplite_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udplite_sysctl_table_users,
-	.ctl_table_header	= &udplite_sysctl_header,
-	.ctl_table		= udplite_sysctl_table,
-#endif
 };
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
@@ -287,11 +277,60 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 		.nla_policy	= udplite_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+};
+
+static int nf_conntrack_proto_udplite_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	int i, ret = 0;
+	for (i = 0; i < UDPLITE_CT_MAX; i++)
+		net->ct.proto.sysctl_udplite_timeouts[i] = udplite_timeouts[i];
+
+#ifdef CONFIG_SYSCTL
+	table = kmemdup(udplite_sysctl_table,
+			sizeof(udplite_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+
+	table[0].data = &net->ct.proto.
+			sysctl_udplite_timeouts[UDPLITE_CT_UNREPLIED];
+	table[1].data = &net->ct.proto.
+			sysctl_udplite_timeouts[UDPLITE_CT_REPLIED];
+
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.udplite_sysctl_header,
+					nf_net_netfilter_sysctl_path,
+					table,
+					NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_udplite:"
+			" can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	kfree(table);
+#endif
+	return ret;
+}
+
+static void nf_conntrack_proto_udplite_net_fini(struct net *net)
+{
 #ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udplite_sysctl_table_users,
-	.ctl_table_header	= &udplite_sysctl_header,
-	.ctl_table		= udplite_sysctl_table,
+	struct ctl_table *table;
+	table = net->ct.proto.udplite_sysctl_header->ctl_table_arg;
+
+	nf_ct_unregister_net_sysctl(&net->ct.proto.udplite_sysctl_header,
+				    table,
+				    NULL);
 #endif
+}
+
+static struct pernet_operations nf_conntrack_net_proto_udplite_ops = {
+	.init = nf_conntrack_proto_udplite_net_init,
+	.exit = nf_conntrack_proto_udplite_net_fini,
 };
 
 static int __init nf_conntrack_proto_udplite_init(void)
@@ -304,7 +343,12 @@ static int __init nf_conntrack_proto_udplite_init(void)
 	err = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udplite6);
 	if (err < 0)
 		goto err2;
+	err = register_pernet_subsys(&nf_conntrack_net_proto_udplite_ops);
+	if (err < 0)
+		goto err3;
 	return 0;
+err3:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
 err2:
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
 err1:
@@ -313,6 +357,7 @@ err1:
 
 static void __exit nf_conntrack_proto_udplite_exit(void)
 {
+	unregister_pernet_subsys(&nf_conntrack_net_proto_udplite_ops);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
 }
-- 
1.7.7.6

