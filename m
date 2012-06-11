From: pablo@netfilter.org
Subject: [PATCH 07/25] netfilter: nf_ct_tcp: add namespace support
Date: Mon, 11 Jun 2012 16:43:43 +0200
Message-ID: <1339425841-24171-8-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch adds namespace support for TCP protocol tracker.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/conntrack.h          |   10 ++
 net/netfilter/nf_conntrack_proto.c     |    2 +
 net/netfilter/nf_conntrack_proto_tcp.c |  162 ++++++++++++++++++++++++++------
 3 files changed, 145 insertions(+), 29 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 0ef8592..680d799 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/list_nulls.h>
 #include <linux/atomic.h>
+#include <linux/netfilter/nf_conntrack_tcp.h>
 
 struct ctl_table_header;
 struct nf_conntrack_ecache;
@@ -25,8 +26,17 @@ struct nf_generic_net {
 	unsigned int timeout;
 };
 
+struct nf_tcp_net {
+	struct nf_proto_net pn;
+	unsigned int timeouts[TCP_CONNTRACK_TIMEOUT_MAX];
+	unsigned int tcp_loose;
+	unsigned int tcp_be_liberal;
+	unsigned int tcp_max_retrans;
+};
+
 struct nf_ip_net {
 	struct nf_generic_net   generic;
+	struct nf_tcp_net	tcp;
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	struct ctl_table_header *ctl_table_header;
 	struct ctl_table	*ctl_table;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index b095b4a..8a71e8b 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -303,6 +303,8 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
 {
 	switch (l4proto->l4proto) {
+	case IPPROTO_TCP:
+		return (struct nf_proto_net *)&net->ct.nf_ct_proto.tcp;
 	case 255: /* l4proto_generic */
 		return (struct nf_proto_net *)&net->ct.nf_ct_proto.generic;
 	default:
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 21ff1a9..a053f67 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -270,6 +270,11 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
 	}
 };
 
+static inline struct nf_tcp_net *tcp_pernet(struct net *net)
+{
+	return &net->ct.nf_ct_proto.tcp;
+}
+
 static bool tcp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			     struct nf_conntrack_tuple *tuple)
 {
@@ -516,6 +521,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			  u_int8_t pf)
 {
 	struct net *net = nf_ct_net(ct);
+	struct nf_tcp_net *tn = tcp_pernet(net);
 	struct ip_ct_tcp_state *sender = &state->seen[dir];
 	struct ip_ct_tcp_state *receiver = &state->seen[!dir];
 	const struct nf_conntrack_tuple *tuple = &ct->tuplehash[dir].tuple;
@@ -720,7 +726,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 	} else {
 		res = false;
 		if (sender->flags & IP_CT_TCP_FLAG_BE_LIBERAL ||
-		    nf_ct_tcp_be_liberal)
+		    tn->tcp_be_liberal)
 			res = true;
 		if (!res && LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
@@ -828,6 +834,7 @@ static int tcp_packet(struct nf_conn *ct,
 		      unsigned int *timeouts)
 {
 	struct net *net = nf_ct_net(ct);
+	struct nf_tcp_net *tn = tcp_pernet(net);
 	struct nf_conntrack_tuple *tuple;
 	enum tcp_conntrack new_state, old_state;
 	enum ip_conntrack_dir dir;
@@ -1020,7 +1027,7 @@ static int tcp_packet(struct nf_conn *ct,
 	    && new_state == TCP_CONNTRACK_FIN_WAIT)
 		ct->proto.tcp.seen[dir].flags |= IP_CT_TCP_FLAG_CLOSE_INIT;
 
-	if (ct->proto.tcp.retrans >= nf_ct_tcp_max_retrans &&
+	if (ct->proto.tcp.retrans >= tn->tcp_max_retrans &&
 	    timeouts[new_state] > timeouts[TCP_CONNTRACK_RETRANS])
 		timeout = timeouts[TCP_CONNTRACK_RETRANS];
 	else if ((ct->proto.tcp.seen[0].flags | ct->proto.tcp.seen[1].flags) &
@@ -1065,6 +1072,8 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	enum tcp_conntrack new_state;
 	const struct tcphdr *th;
 	struct tcphdr _tcph;
+	struct net *net = nf_ct_net(ct);
+	struct nf_tcp_net *tn = tcp_pernet(net);
 	const struct ip_ct_tcp_state *sender = &ct->proto.tcp.seen[0];
 	const struct ip_ct_tcp_state *receiver = &ct->proto.tcp.seen[1];
 
@@ -1093,7 +1102,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 			ct->proto.tcp.seen[0].td_end;
 
 		tcp_options(skb, dataoff, th, &ct->proto.tcp.seen[0]);
-	} else if (nf_ct_tcp_loose == 0) {
+	} else if (tn->tcp_loose == 0) {
 		/* Don't try to pick up connections. */
 		return false;
 	} else {
@@ -1360,91 +1369,78 @@ static struct ctl_table_header *tcp_sysctl_header;
 static struct ctl_table tcp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_tcp_timeout_syn_sent",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_syn_recv",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_established",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_fin_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_last_ack",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_time_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_RETRANS],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_unacknowledged",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_UNACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_loose",
-		.data		= &nf_ct_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname       = "nf_conntrack_tcp_be_liberal",
-		.data           = &nf_ct_tcp_be_liberal,
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_max_retrans",
-		.data		= &nf_ct_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
@@ -1456,91 +1452,78 @@ static struct ctl_table tcp_sysctl_table[] = {
 static struct ctl_table tcp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_sent",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_sent2",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT2],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_established",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_last_ack",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_time_wait",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
-		.data		= &tcp_timeouts[TCP_CONNTRACK_RETRANS],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_loose",
-		.data		= &nf_ct_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_be_liberal",
-		.data		= &nf_ct_tcp_be_liberal,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_max_retrans",
-		.data		= &nf_ct_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
@@ -1550,6 +1533,125 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int tcp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_SYSCTL
+	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
+
+	if (pn->ctl_table)
+		return 0;
+
+	pn->ctl_table = kmemdup(tcp_sysctl_table,
+				sizeof(tcp_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+
+	pn->ctl_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
+	pn->ctl_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
+	pn->ctl_table[2].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
+	pn->ctl_table[3].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
+	pn->ctl_table[4].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+	pn->ctl_table[5].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
+	pn->ctl_table[6].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
+	pn->ctl_table[7].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
+	pn->ctl_table[8].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
+	pn->ctl_table[9].data = &tn->timeouts[TCP_CONNTRACK_UNACK];
+	pn->ctl_table[10].data = &tn->tcp_loose;
+	pn->ctl_table[11].data = &tn->tcp_be_liberal;
+	pn->ctl_table[12].data = &tn->tcp_max_retrans;
+#endif
+	return 0;
+}
+
+static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
+	pn->ctl_compat_table = kmemdup(tcp_compat_sysctl_table,
+				       sizeof(tcp_compat_sysctl_table),
+				       GFP_KERNEL);
+	if (!pn->ctl_compat_table)
+		return -ENOMEM;
+
+	pn->ctl_compat_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
+	pn->ctl_compat_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT2];
+	pn->ctl_compat_table[2].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
+	pn->ctl_compat_table[3].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
+	pn->ctl_compat_table[4].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
+	pn->ctl_compat_table[5].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+	pn->ctl_compat_table[6].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
+	pn->ctl_compat_table[7].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
+	pn->ctl_compat_table[8].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
+	pn->ctl_compat_table[9].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
+	pn->ctl_compat_table[10].data = &tn->tcp_loose;
+	pn->ctl_compat_table[11].data = &tn->tcp_be_liberal;
+	pn->ctl_compat_table[12].data = &tn->tcp_max_retrans;
+#endif
+#endif
+	return 0;
+}
+
+static int tcpv4_init_net(struct net *net)
+{
+	int i;
+	int ret = 0;
+	struct nf_tcp_net *tn = tcp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
+
+#ifdef CONFIG_SYSCTL
+	if (!pn->ctl_table) {
+#else
+	if (!pn->user++) {
+#endif
+		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
+			tn->timeouts[i] = tcp_timeouts[i];
+
+		tn->tcp_loose = nf_ct_tcp_loose;
+		tn->tcp_be_liberal = nf_ct_tcp_be_liberal;
+		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
+	}
+
+	ret = tcp_kmemdup_compat_sysctl_table(pn);
+
+	if (ret < 0)
+		return ret;
+
+	ret = tcp_kmemdup_sysctl_table(pn);
+
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	if (ret < 0) {
+		kfree(pn->ctl_compat_table);
+		pn->ctl_compat_table = NULL;
+	}
+#endif
+#endif
+	return ret;
+}
+
+static int tcpv6_init_net(struct net *net)
+{
+	int i;
+	struct nf_tcp_net *tn = tcp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
+
+#ifdef CONFIG_SYSCTL
+	if (!pn->ctl_table) {
+#else
+	if (!pn->user++) {
+#endif
+		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
+			tn->timeouts[i] = tcp_timeouts[i];
+		tn->tcp_loose = nf_ct_tcp_loose;
+		tn->tcp_be_liberal = nf_ct_tcp_be_liberal;
+		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
+	}
+
+	return tcp_kmemdup_sysctl_table(pn);
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -1590,6 +1692,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	.ctl_compat_table	= tcp_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= tcpv4_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp4);
 
@@ -1630,5 +1733,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	.ctl_table_header	= &tcp_sysctl_header,
 	.ctl_table		= tcp_sysctl_table,
 #endif
+	.init_net		= tcpv6_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp6);
-- 
1.7.10

