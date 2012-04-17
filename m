From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 04/12] netfilter: tcp proto sysctl support for net namespace
Date: Tue, 17 Apr 2012 10:56:15 +0800
Message-ID: <1334631383-12326-5-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:11141 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755558Ab2DQDfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 23:35:12 -0400
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add and export four functions nf_conntrack_proto_ipv[4,6]_tcp_[init,fini]
for the nf_conntrack_ipv[4,6] modules.

modify the tcp_timeouts to net->ct.proto.sysctl_tcp_timeouts,
and use net->ct.proto.sysctl_tcp* to replace nf_ct_tcp*.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_tcp.c |  275 ++++++++++++++++++++++++++-----
 1 files changed, 230 insertions(+), 45 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 361eade..da0d240 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -720,7 +720,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 	} else {
 		res = false;
 		if (sender->flags & IP_CT_TCP_FLAG_BE_LIBERAL ||
-		    nf_ct_tcp_be_liberal)
+		    net->ct.proto.sysctl_tcp_be_liberal)
 			res = true;
 		if (!res && LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
@@ -815,7 +815,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 
 static unsigned int *tcp_get_timeouts(struct net *net)
 {
-	return tcp_timeouts;
+	return net->ct.proto.sysctl_tcp_timeouts;
 }
 
 /* Returns verdict for packet, or -1 for invalid. */
@@ -1019,7 +1019,7 @@ static int tcp_packet(struct nf_conn *ct,
 	    && new_state == TCP_CONNTRACK_FIN_WAIT)
 		ct->proto.tcp.seen[dir].flags |= IP_CT_TCP_FLAG_CLOSE_INIT;
 
-	if (ct->proto.tcp.retrans >= nf_ct_tcp_max_retrans &&
+	if (ct->proto.tcp.retrans >= net->ct.proto.sysctl_tcp_max_retrans &&
 	    timeouts[new_state] > timeouts[TCP_CONNTRACK_RETRANS])
 		timeout = timeouts[TCP_CONNTRACK_RETRANS];
 	else if ((ct->proto.tcp.seen[0].flags | ct->proto.tcp.seen[1].flags) &
@@ -1062,6 +1062,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		    unsigned int dataoff, unsigned int *timeouts)
 {
 	enum tcp_conntrack new_state;
+	struct net *net = nf_ct_net(ct);
 	const struct tcphdr *th;
 	struct tcphdr _tcph;
 	const struct ip_ct_tcp_state *sender = &ct->proto.tcp.seen[0];
@@ -1092,7 +1093,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 			ct->proto.tcp.seen[0].td_end;
 
 		tcp_options(skb, dataoff, th, &ct->proto.tcp.seen[0]);
-	} else if (nf_ct_tcp_loose == 0) {
+	} else if (net->ct.proto.sysctl_tcp_loose == 0) {
 		/* Don't try to pick up connections. */
 		return false;
 	} else {
@@ -1352,96 +1353,104 @@ static const struct nla_policy tcp_timeout_nla_policy[CTA_TIMEOUT_TCP_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static unsigned int tcp_sysctl_table_users;
-static struct ctl_table_header *tcp_sysctl_header;
 static struct ctl_table tcp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_tcp_timeout_syn_sent",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_syn_recv",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_established",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_fin_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_last_ack",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_time_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_RETRANS],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_RETRANS],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_unacknowledged",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_UNACK],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_UNACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_loose",
-		.data		= &nf_ct_tcp_loose,
+		.data		= &init_net.ct.proto.sysctl_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname       = "nf_conntrack_tcp_be_liberal",
-		.data           = &nf_ct_tcp_be_liberal,
+		.data           = &init_net.ct.proto.sysctl_tcp_be_liberal,
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_max_retrans",
-		.data		= &nf_ct_tcp_max_retrans,
+		.data		= &init_net.ct.proto.sysctl_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
@@ -1453,91 +1462,101 @@ static struct ctl_table tcp_sysctl_table[] = {
 static struct ctl_table tcp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_sent",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_sent2",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT2],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_SENT2],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_established",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_last_ack",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_time_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_RETRANS],
+		.data		= &init_net.ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_RETRANS],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_loose",
-		.data		= &nf_ct_tcp_loose,
+		.data		= &init_net.ct.proto.sysctl_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_be_liberal",
-		.data		= &nf_ct_tcp_be_liberal,
+		.data		= &init_net.ct.proto.sysctl_tcp_be_liberal,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_max_retrans",
-		.data		= &nf_ct_tcp_max_retrans,
+		.data		= &init_net.ct.proto.sysctl_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
@@ -1579,14 +1598,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 		.nla_policy	= tcp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &tcp_sysctl_table_users,
-	.ctl_table_header	= &tcp_sysctl_header,
-	.ctl_table		= tcp_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= tcp_compat_sysctl_table,
-#endif
-#endif
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp4);
 
@@ -1622,10 +1633,184 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 		.nla_policy	= tcp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &tcp_sysctl_table_users,
-	.ctl_table_header	= &tcp_sysctl_header,
-	.ctl_table		= tcp_sysctl_table,
-#endif
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp6);
+
+static int nf_conntrack_proto_tcp_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	int i, ret;
+
+#ifdef CONFIG_SYSCTL
+	if (!net->ct.proto.tcp_sysctl_header) {
+		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
+			net->ct.proto.sysctl_tcp_timeouts[i] = tcp_timeouts[i];
+		net->ct.proto.sysctl_tcp_loose = nf_ct_tcp_loose;
+		net->ct.proto.sysctl_tcp_be_liberal = nf_ct_tcp_be_liberal;
+		net->ct.proto.sysctl_tcp_max_retrans = nf_ct_tcp_max_retrans;
+		net->ct.proto.tcp_table_users = 0;	
+        	table = kmemdup(tcp_sysctl_table,
+				sizeof(tcp_sysctl_table),
+				GFP_KERNEL);
+        	if (!table) 
+                	return -ENOMEM;
+
+		table[0].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_SENT];
+		table[1].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_RECV];
+		table[2].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_ESTABLISHED];
+		table[3].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_FIN_WAIT];
+		table[4].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+		table[5].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_LAST_ACK];
+		table[6].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_TIME_WAIT];
+		table[7].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE];
+		table[8].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_RETRANS];
+		table[9].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_UNACK];
+		table[10].data = &net->ct.proto.sysctl_tcp_loose;
+		table[11].data = &net->ct.proto.sysctl_tcp_be_liberal;
+		table[12].data = &net->ct.proto.sysctl_tcp_max_retrans;
+	} else
+		table = net->ct.proto.tcp_sysctl_header->ctl_table_arg;
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.tcp_sysctl_header,
+					nf_net_netfilter_sysctl_path,
+					table,
+					&net->ct.proto.tcp_table_users);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_tcp:"
+			" can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+out_register:
+	if (!net->ct.proto.tcp_sysctl_header)
+		kfree(table);
+#else
+	for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
+		net->ct.proto.sysctl_tcp_timeouts[i] = tcp_timeouts[i];
+	net->ct.proto.sysctl_tcp_loose = nf_ct_tcp_loose;
+	net->ct.proto.sysctl_tcp_be_liberal = nf_ct_tcp_be_liberal;
+	net->ct.proto.sysctl_tcp_max_retrans = nf_ct_tcp_max_retrans;
+#endif
+	return ret;
+}
+
+static void nf_conntrack_proto_tcp_net_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *table;
+	table = net->ct.proto.tcp_sysctl_header->ctl_table_arg;
+
+	nf_ct_unregister_net_sysctl(&net->ct.proto.tcp_sysctl_header,
+				    table,
+				    &net->ct.proto.tcp_table_users);
+#endif
+}
+
+static int nf_conntrack_proto_tcp_compat_init(struct net *net)
+{
+	int ret = 0;
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *compat_table;
+	compat_table = kmemdup(tcp_compat_sysctl_table,
+			       sizeof(tcp_compat_sysctl_table),
+			       GFP_KERNEL);
+	if (!compat_table) 
+		return -ENOMEM;
+        
+	compat_table[0].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_SENT];
+	compat_table[1].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_SENT2];
+	compat_table[2].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_SYN_RECV];
+	compat_table[3].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_ESTABLISHED];
+	compat_table[4].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_FIN_WAIT];
+	compat_table[5].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+	compat_table[6].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_LAST_ACK];
+	compat_table[7].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_TIME_WAIT];
+	compat_table[8].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_CLOSE];
+	compat_table[9].data = &net->ct.proto.
+				sysctl_tcp_timeouts[TCP_CONNTRACK_RETRANS];
+	compat_table[10].data = &net->ct.proto.sysctl_tcp_loose;
+	compat_table[11].data = &net->ct.proto.sysctl_tcp_be_liberal;
+	compat_table[12].data = &net->ct.proto.sysctl_tcp_max_retrans;
+	ret = nf_ct_register_net_sysctl(net,
+					&net->ct.proto.tcp_compat_header,
+					nf_net_ipv4_netfilter_sysctl_path,
+					compat_table, NULL);
+	if (ret < 0) {
+		printk(KERN_ERR
+			"nf_conntrack_proto_tcp:"
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
+static void nf_conntrack_proto_tcp_compat_fini(struct net *net)
+{
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table *compat_table;
+	compat_table = net->ct.proto.tcp_compat_header->ctl_table_arg;
+	nf_ct_unregister_net_sysctl(&net->ct.proto.tcp_compat_header,
+				    compat_table,
+				    NULL);
+#endif
+#endif
+}
+
+int nf_conntrack_proto_ipv4_tcp_init(struct net *net)
+{
+	int ret = 0;
+	ret = nf_conntrack_proto_tcp_net_init(net);
+	if (ret < 0)
+		return ret;
+	ret = nf_conntrack_proto_tcp_compat_init(net);
+	if (ret < 0)
+		nf_conntrack_proto_tcp_net_fini(net);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv4_tcp_init);
+
+void nf_conntrack_proto_ipv4_tcp_fini(struct net *net)
+{
+	nf_conntrack_proto_tcp_net_fini(net);
+	nf_conntrack_proto_tcp_compat_fini(net);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv4_tcp_fini);
+
+int nf_conntrack_proto_ipv6_tcp_init(struct net *net)
+{
+	return nf_conntrack_proto_tcp_net_init(net);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv6_tcp_init);
+
+void nf_conntrack_proto_ipv6_tcp_fini(struct net *net)
+{
+	nf_conntrack_proto_tcp_net_fini(net);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_proto_ipv6_tcp_fini);
-- 
1.7.7.6
