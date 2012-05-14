From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 11/17] netfilter: add namespace support for l4proto_sctp
Date: Mon, 14 May 2012 16:52:21 +0800
Message-ID: <1336985547-31960-12-git-send-email-gaofeng@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add pernet_operations sctp_net_ops and register it when
module nf_conntrack_proto_sctp is loaded.
move the l4proto_register from module_init function to
sctp_net_ops.init.

and implement sctp_init_net to initial the pernet sysctl
data for sctp[4,6] protos.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_sctp.c |  135 ++++++++++++++++++++++++-------
 1 files changed, 106 insertions(+), 29 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 97bbc20..3f0fdf8 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -127,6 +127,17 @@ static const u8 sctp_conntracks[2][9][SCTP_CONNTRACK_MAX] = {
 	}
 };
 
+static int sctp_net_id	__read_mostly;
+struct sctp_net {
+	struct nf_proto_net pn;
+	unsigned int timeouts[SCTP_CONNTRACK_MAX];
+};
+
+static inline struct sctp_net *sctp_pernet(struct net *net)
+{
+	return net_generic(net, sctp_net_id);
+}
+
 static bool sctp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			      struct nf_conntrack_tuple *tuple)
 {
@@ -281,7 +292,7 @@ static int sctp_new_state(enum ip_conntrack_dir dir,
 
 static unsigned int *sctp_get_timeouts(struct net *net)
 {
-	return sctp_timeouts;
+	return sctp_pernet(net)->timeouts;
 }
 
 /* Returns verdict for packet, or -NF_ACCEPT for invalid. */
@@ -604,49 +615,42 @@ static struct ctl_table_header *sctp_sysctl_header;
 static struct ctl_table sctp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_sctp_timeout_closed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_wait",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_echoed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_established",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_recd",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_ack_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -658,49 +662,42 @@ static struct ctl_table sctp_sysctl_table[] = {
 static struct ctl_table sctp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_sctp_timeout_closed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_wait",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_echoed",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_established",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_recd",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_ack_sent",
-		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -710,9 +707,63 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif
 
+static int sctp_init_net(struct net *net, u_int8_t compat)
+{
+	int i;
+	struct sctp_net *sn = sctp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)sn;
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	if (compat) {
+		pn->ctl_compat_table = kmemdup(sctp_compat_sysctl_table,
+					       sizeof(sctp_compat_sysctl_table),
+					       GFP_KERNEL);
+		if (!pn->ctl_compat_table)
+			return -ENOMEM;
+		pn->ctl_compat_table[0].data = &sn->timeouts[SCTP_CONNTRACK_CLOSED];
+		pn->ctl_compat_table[1].data = &sn->timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
+		pn->ctl_compat_table[2].data = &sn->timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
+		pn->ctl_compat_table[3].data = &sn->timeouts[SCTP_CONNTRACK_ESTABLISHED];
+		pn->ctl_compat_table[4].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
+		pn->ctl_compat_table[5].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
+		pn->ctl_compat_table[6].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
+	}
+#endif
+	if (!pn->ctl_table) {
+#else
+	if (!pn->users++) {
+#endif
+		for (i = 0; i < SCTP_CONNTRACK_MAX; i++)
+			sn->timeouts[i] = sctp_timeouts[i];
+#ifdef CONFIG_SYSCTL
+		pn->ctl_table = kmemdup(sctp_sysctl_table,
+					sizeof(sctp_sysctl_table),
+					GFP_KERNEL);
+		if (!pn->ctl_table) {
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+			if (compat) {
+				kfree(pn->ctl_compat_table);
+				pn->ctl_compat_table = NULL;
+			}
+#endif
+			return -ENOMEM;
+		}
+		pn->ctl_table[0].data = &sn->timeouts[SCTP_CONNTRACK_CLOSED];
+		pn->ctl_table[1].data = &sn->timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
+		pn->ctl_table[2].data = &sn->timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
+		pn->ctl_table[3].data = &sn->timeouts[SCTP_CONNTRACK_ESTABLISHED];
+		pn->ctl_table[4].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
+		pn->ctl_table[5].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
+		pn->ctl_table[6].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
+#endif
+	}
+	return 0;
+}
+
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.l3proto		= PF_INET,
 	.l4proto 		= IPPROTO_SCTP,
+	.compat			= 1,
 	.name 			= "sctp",
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
@@ -748,11 +799,14 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.ctl_compat_table	= sctp_compat_sysctl_table,
 #endif
 #endif
+	.net_id			= &sctp_net_id,
+	.init_net		= sctp_init_net,
 };
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.l3proto		= PF_INET6,
 	.l4proto 		= IPPROTO_SCTP,
+	.compat			= 0,
 	.name 			= "sctp",
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
@@ -785,35 +839,58 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.ctl_table_header	= &sctp_sysctl_header,
 	.ctl_table		= sctp_sysctl_table,
 #endif
+	.net_id			= &sctp_net_id,
+	.init_net		= sctp_init_net,
 };
 
-static int __init nf_conntrack_proto_sctp_init(void)
+static int sctp_net_init(struct net *net)
 {
-	int ret;
+	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_sctp4);
-	if (ret) {
-		pr_err("nf_conntrack_l4proto_sctp4: protocol register failed\n");
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_sctp4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_sctp4 :protocol register failed.\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_sctp6);
-	if (ret) {
-		pr_err("nf_conntrack_l4proto_sctp6: protocol register failed\n");
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_sctp6);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_sctp6 :protocol register failed.\n");
 		goto cleanup_sctp4;
 	}
+	return 0;
 
+cleanup_sctp4:
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_sctp4);
+out:
 	return ret;
+}
 
- cleanup_sctp4:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp4);
- out:
-	return ret;
+static void sctp_net_exit(struct net *net)
+{
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_sctp6);
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_sctp4);
+}
+
+static struct pernet_operations sctp_net_ops = {
+	.init = sctp_net_init,
+	.exit = sctp_net_exit,
+	.id   = &sctp_net_id,
+	.size = sizeof(struct sctp_net),
+};
+
+static int __init nf_conntrack_proto_sctp_init(void)
+{
+	return register_pernet_subsys(&sctp_net_ops);
 }
 
 static void __exit nf_conntrack_proto_sctp_fini(void)
 {
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp6);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp4);
+	unregister_pernet_subsys(&sctp_net_ops);
 }
 
 module_init(nf_conntrack_proto_sctp_init);
-- 
1.7.7.6

