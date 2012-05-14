From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 05/17] netfilter: add namespace support for l4proto_tcp
Date: Mon, 14 May 2012 16:52:15 +0800
Message-ID: <1336985547-31960-6-git-send-email-gaofeng@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

implement tcp_init_net to initial the pernet sysctl data
for tcp proto.

Because tcp_init_net is called by l4proto_tcp[4,6],so use
nf_proto_net.users to identify if the pernet data is initialized
when CONFIG_SYSCTL is not configured.

nf_tcp_net as a field of netns_ct,when proto is tcp,
return net->ct.proto.tcp in function nf_ct_l4proto_net.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netns/conntrack.h          |   10 +++
 net/netfilter/nf_conntrack_proto.c     |    2 +
 net/netfilter/nf_conntrack_proto_tcp.c |  114 ++++++++++++++++++++++++--------
 3 files changed, 97 insertions(+), 29 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 3381b80..d79e627 100644
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
index 9b4bf6d..4531d6a 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -288,6 +288,8 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
 {
 	switch (l4proto->l4proto) {
+	case IPPROTO_TCP:
+		return (struct nf_proto_net *)&net->ct.proto.tcp;
 	case 255: /* l4proto_generic */
 		return (struct nf_proto_net *)&net->ct.proto.generic;
 	default:
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 4dfbfa8..dd19350 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -270,6 +270,11 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
 	}
 };
 
+static inline struct nf_tcp_net *tcp_pernet(struct net *net)
+{
+	return &net->ct.proto.tcp;
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
@@ -1019,7 +1026,7 @@ static int tcp_packet(struct nf_conn *ct,
 	    && new_state == TCP_CONNTRACK_FIN_WAIT)
 		ct->proto.tcp.seen[dir].flags |= IP_CT_TCP_FLAG_CLOSE_INIT;
 
-	if (ct->proto.tcp.retrans >= nf_ct_tcp_max_retrans &&
+	if (ct->proto.tcp.retrans >= tn->tcp_max_retrans &&
 	    timeouts[new_state] > timeouts[TCP_CONNTRACK_RETRANS])
 		timeout = timeouts[TCP_CONNTRACK_RETRANS];
 	else if ((ct->proto.tcp.seen[0].flags | ct->proto.tcp.seen[1].flags) &
@@ -1064,6 +1071,8 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	enum tcp_conntrack new_state;
 	const struct tcphdr *th;
 	struct tcphdr _tcph;
+	struct net *net = nf_ct_net(ct);
+	struct nf_tcp_net *tn = tcp_pernet(net);
 	const struct ip_ct_tcp_state *sender = &ct->proto.tcp.seen[0];
 	const struct ip_ct_tcp_state *receiver = &ct->proto.tcp.seen[1];
 
@@ -1092,7 +1101,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 			ct->proto.tcp.seen[0].td_end;
 
 		tcp_options(skb, dataoff, th, &ct->proto.tcp.seen[0]);
-	} else if (nf_ct_tcp_loose == 0) {
+	} else if (tn->tcp_loose == 0) {
 		/* Don't try to pick up connections. */
 		return false;
 	} else {
@@ -1359,91 +1368,78 @@ static struct ctl_table_header *tcp_sysctl_header;
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
@@ -1455,91 +1451,78 @@ static struct ctl_table tcp_sysctl_table[] = {
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
@@ -1549,10 +1532,80 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int tcp_init_net(struct net *net, u_int8_t compat)
+{
+	int i;
+	struct nf_tcp_net *tn = tcp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	if (compat) {
+		pn->ctl_compat_table = kmemdup(tcp_compat_sysctl_table,
+					       sizeof(tcp_compat_sysctl_table),
+					       GFP_KERNEL);
+		if (!pn->ctl_compat_table)
+			return -ENOMEM;
+
+		pn->ctl_compat_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
+		pn->ctl_compat_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT2];
+		pn->ctl_compat_table[2].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
+		pn->ctl_compat_table[3].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
+		pn->ctl_compat_table[4].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
+		pn->ctl_compat_table[5].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+		pn->ctl_compat_table[6].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
+		pn->ctl_compat_table[7].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
+		pn->ctl_compat_table[8].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
+		pn->ctl_compat_table[9].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
+		pn->ctl_compat_table[10].data = &tn->tcp_loose;
+		pn->ctl_compat_table[11].data = &tn->tcp_be_liberal;
+		pn->ctl_compat_table[12].data = &tn->tcp_max_retrans;
+	}
+#endif
+	if (!pn->ctl_table) {
+#else
+	if (!pn->user++) {
+#endif
+		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
+			tn->timeouts[i] = tcp_timeouts[i];
+		tn->tcp_loose = nf_ct_tcp_loose;
+		tn->tcp_be_liberal = nf_ct_tcp_be_liberal;
+		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
+#ifdef CONFIG_SYSCTL
+		pn->ctl_table = kmemdup(tcp_sysctl_table,
+					sizeof(tcp_sysctl_table),
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
+		pn->ctl_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
+		pn->ctl_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
+		pn->ctl_table[2].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
+		pn->ctl_table[3].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
+		pn->ctl_table[4].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+		pn->ctl_table[5].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
+		pn->ctl_table[6].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
+		pn->ctl_table[7].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
+		pn->ctl_table[8].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
+		pn->ctl_table[9].data = &tn->timeouts[TCP_CONNTRACK_UNACK];
+		pn->ctl_table[10].data = &tn->tcp_loose;
+		pn->ctl_table[11].data = &tn->tcp_be_liberal;
+		pn->ctl_table[12].data = &tn->tcp_max_retrans;
+#endif
+	}
+	return 0;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
 	.l4proto 		= IPPROTO_TCP,
+	.compat			= 1,
 	.name 			= "tcp",
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
@@ -1589,6 +1642,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	.ctl_compat_table	= tcp_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= tcp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp4);
 
@@ -1596,6 +1650,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto 		= IPPROTO_TCP,
+	.compat			= 0,
 	.name 			= "tcp",
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
@@ -1629,5 +1684,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	.ctl_table_header	= &tcp_sysctl_header,
 	.ctl_table		= tcp_sysctl_table,
 #endif
+	.init_net		= tcp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp6);
-- 
1.7.7.6

