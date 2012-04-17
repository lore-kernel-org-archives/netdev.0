From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 10/12] netfilter: sctp proto sysctl support for net namespace
Date: Tue, 17 Apr 2012 10:56:21 +0800
Message-ID: <1334631383-12326-11-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

register pernet_operations nf_conntrack_net_proto_sctp_ops
when loading nf_conntrack_proto_sctp module,and unregister
it when removing.

It makes no senes to register subsys for sctp and sctp6,because
the nf_conntrack_l4proto_sctp4 and nf_conntrack_l4proto_sctp6 are
register or unregister together.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_sctp.c |  205 ++++++++++++++++++++++++++-----
 1 files changed, 175 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 72b5088..866d151 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -281,7 +281,7 @@ static int sctp_new_state(enum ip_conntrack_dir dir,
 
 static unsigned int *sctp_get_timeouts(struct net *net)
 {
-	return sctp_timeouts;
+	return net->ct.proto.sysctl_sctp_timeouts;
 }
 
 /* Returns verdict for packet, or -NF_ACCEPT for invalid. */
@@ -599,56 +599,60 @@ sctp_timeout_nla_policy[CTA_TIMEOUT_SCTP_MAX+1] = {
 };
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
-
 #ifdef CONFIG_SYSCTL
-static unsigned int sctp_sysctl_table_users;
-static struct ctl_table_header *sctp_sysctl_header;
 static struct ctl_table sctp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_sctp_timeout_closed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_wait",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_echoed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_established",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_recd",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_ack_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -660,49 +664,56 @@ static struct ctl_table sctp_sysctl_table[] = {
 static struct ctl_table sctp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_sctp_timeout_closed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_wait",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_echoed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_established",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_recd",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_ack_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
+		.data		= &init_net.ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -742,14 +753,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 		.nla_policy	= sctp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &sctp_sysctl_table_users,
-	.ctl_table_header	= &sctp_sysctl_header,
-	.ctl_table		= sctp_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= sctp_compat_sysctl_table,
-#endif
-#endif
 };
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
@@ -782,11 +785,146 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #endif
+};
+
+static int nf_conntrack_proto_sctp_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	int i, ret = 0;
+	for (i = 0; i < SCTP_CONNTRACK_MAX; i++)
+		net->ct.proto.sysctl_sctp_timeouts[i] = sctp_timeouts[i];
+
 #ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &sctp_sysctl_table_users,
-	.ctl_table_header	= &sctp_sysctl_header,
-	.ctl_table		= sctp_sysctl_table,
+	table = kmemdup(sctp_sysctl_table,
+			sizeof(sctp_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+	table[0].data = &net->ct.proto.
+			sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED];
+	table[1].data = &net->ct.proto.
+			sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
+	table[2].data = &net->ct.proto.
+			sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
+	table[3].data = &net->ct.proto.
+			sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
+	table[4].data = &net->ct.proto.
+			sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
+	table[5].data = &net->ct.proto.
+			sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
+	table[6].data = &net->ct.proto.
+			sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
+
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.sctp_sysctl_header,
+					nf_net_netfilter_sysctl_path,
+					table,
+					NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_sctp:"
+			" can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	kfree(table);
 #endif
+	return ret;
+}
+
+static void nf_conntrack_proto_sctp_net_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *table;
+	table = net->ct.proto.sctp_sysctl_header->ctl_table_arg;
+
+	nf_ct_unregister_net_sysctl(&net->ct.proto.sctp_sysctl_header,
+				    table,
+				    NULL);
+#endif
+}
+
+static int nf_conntrack_proto_sctp_compat_init(struct net *net)
+{
+	int ret = 0;
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *compat_table;
+	compat_table = kmemdup(sctp_compat_sysctl_table,
+			       sizeof(sctp_compat_sysctl_table),
+			       GFP_KERNEL);
+	if (!compat_table)
+		return -ENOMEM;
+
+	compat_table[0].data = &net->ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED];
+	compat_table[1].data = &net->ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
+	compat_table[2].data = &net->ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
+	compat_table[3].data = &net->ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
+	compat_table[4].data = &net->ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
+	compat_table[5].data = &net->ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
+	compat_table[6].data = &net->ct.proto.
+				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
+
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.sctp_compat_header,
+					nf_net_ipv4_netfilter_sysctl_path,
+					compat_table,
+					NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_sctp:"
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
+static void nf_conntrack_proto_sctp_compat_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *compat_table;
+	compat_table = net->ct.proto.sctp_compat_header->ctl_table_arg;
+	nf_ct_unregister_net_sysctl(&net->ct.proto.sctp_compat_header,
+				    compat_table,
+				    NULL);
+#endif
+#endif
+}
+
+static int nf_conntrack_net_proto_sctp_init(struct net *net)
+{
+	int ret;
+	ret = nf_conntrack_proto_sctp_net_init(net);
+	if (ret < 0)
+		return ret;
+	ret = nf_conntrack_proto_sctp_compat_init(net);
+	if (ret < 0)
+		nf_conntrack_proto_sctp_net_fini(net);
+	return ret;
+}
+
+static void nf_conntrack_net_proto_sctp_fini(struct net *net)
+{
+	nf_conntrack_proto_sctp_compat_fini(net);
+	nf_conntrack_proto_sctp_net_fini(net);
+}
+
+static struct pernet_operations nf_conntrack_net_proto_sctp_ops = {
+	.init = nf_conntrack_net_proto_sctp_init,
+	.exit = nf_conntrack_net_proto_sctp_fini,
 };
 
 static int __init nf_conntrack_proto_sctp_init(void)
@@ -803,9 +941,15 @@ static int __init nf_conntrack_proto_sctp_init(void)
 		pr_err("nf_conntrack_l4proto_sctp6: protocol register failed\n");
 		goto cleanup_sctp4;
 	}
-
+	ret = register_pernet_subsys(&nf_conntrack_net_proto_sctp_ops);
+	if (ret) {
+		pr_err("nf_conntrack: sctp pernet subsys register failed\n");
+		goto cleanup_sctp6;
+	}
 	return ret;
 
+ cleanup_sctp6:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
  cleanup_sctp4:
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
  out:
@@ -814,6 +958,7 @@ static int __init nf_conntrack_proto_sctp_init(void)
 
 static void __exit nf_conntrack_proto_sctp_fini(void)
 {
+	unregister_pernet_subsys(&nf_conntrack_net_proto_sctp_ops);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
 }
-- 
1.7.7.6

