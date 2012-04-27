From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 06/17] netfilter: add namespace support for l4proto_udp
Date: Fri, 27 Apr 2012 17:37:53 +0800
Message-ID: <1335519484-6089-7-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

implement udp_init_net to initial the pernet sysctl data for
udp protos.

Because udp_init_net is called by l4proto_udp[4,6],so use
nf_proto_net.users to identify if the pernet data is initialized
when CONFIG_SYSCTL is not configured.

nf_udp_net as a field of netns_ct,when proto is udp,
return net->ct.proto.udp in function nf_ct_l4proto_net.

and move enum udp_conntrack to conntrack.h

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netns/conntrack.h          |   12 ++++++
 net/netfilter/nf_conntrack_proto.c     |    2 +
 net/netfilter/nf_conntrack_proto_udp.c |   65 ++++++++++++++++++++++++++-----
 3 files changed, 68 insertions(+), 11 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 14cf47d..a1b967d 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -34,9 +34,21 @@ struct nf_tcp_net {
 	unsigned int tcp_max_retrans;
 };
 
+enum udp_conntrack {
+	UDP_CT_UNREPLIED,
+	UDP_CT_REPLIED,
+	UDP_CT_MAX
+};
+
+struct nf_udp_net {
+	struct nf_proto_net pn;
+	unsigned int timeouts[UDP_CT_MAX];
+};
+
 struct nf_ip_net {
 	struct nf_generic_net   generic;
 	struct nf_tcp_net       tcp;
+	struct nf_udp_net	udp;
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	struct ctl_table_header *ctl_table_header;
 	struct ctl_table        *ctl_table;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 25fd237..fafad1e 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -290,6 +290,8 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 	switch (l4proto->l4proto) {
 	case IPPROTO_TCP:
 		return (struct nf_proto_net *)&net->ct.proto.tcp;
+	case IPPROTO_UDP:
+		return (struct nf_proto_net *)&net->ct.proto.udp;
 	case 255: /* l4proto_generic */
 		return (struct nf_proto_net *)&net->ct.proto.generic;
 	default:
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 7259a6b..072ef9c 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -25,17 +25,16 @@
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
 };
 
+static inline struct nf_udp_net *udp_pernet(struct net *net)
+{
+	return &net->ct.proto.udp;
+}
+
 static bool udp_pkt_to_tuple(const struct sk_buff *skb,
 			     unsigned int dataoff,
 			     struct nf_conntrack_tuple *tuple)
@@ -73,7 +72,7 @@ static int udp_print_tuple(struct seq_file *s,
 
 static unsigned int *udp_get_timeouts(struct net *net)
 {
-	return udp_timeouts;
+	return udp_pernet(net)->timeouts;
 }
 
 /* Returns verdict for packet, and may modify conntracktype */
@@ -205,14 +204,12 @@ static struct ctl_table_header *udp_sysctl_header;
 static struct ctl_table udp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udp_timeout",
-		.data		= &udp_timeouts[UDP_CT_UNREPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_udp_timeout_stream",
-		.data		= &udp_timeouts[UDP_CT_REPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -223,14 +220,12 @@ static struct ctl_table udp_sysctl_table[] = {
 static struct ctl_table udp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_udp_timeout",
-		.data		= &udp_timeouts[UDP_CT_UNREPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_udp_timeout_stream",
-		.data		= &udp_timeouts[UDP_CT_REPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -240,10 +235,55 @@ static struct ctl_table udp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int udp_init_net(struct net *net, u_int8_t compat)
+{
+	int i;
+	struct nf_udp_net *un = udp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)un;
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	if (compat) {
+		pn->ctl_compat_table = kmemdup(udp_compat_sysctl_table,
+					       sizeof(udp_compat_sysctl_table),
+					       GFP_KERNEL);
+		if (!pn->ctl_compat_table)
+			return -ENOMEM;
+
+		pn->ctl_compat_table[0].data = &un->timeouts[UDP_CT_UNREPLIED];
+		pn->ctl_compat_table[1].data = &un->timeouts[UDP_CT_REPLIED];
+	}
+#endif
+	if (!pn->ctl_table) {
+#else
+	if (!pn->user++) {
+#endif
+		for (i = 0; i < UDP_CT_MAX; i++)
+			un->timeouts[i] = udp_timeouts[i];
+#ifdef CONFIG_SYSCTL
+		pn->ctl_table = kmemdup(udp_sysctl_table,
+					sizeof(udp_sysctl_table),
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
+		pn->ctl_table[0].data = &un->timeouts[UDP_CT_UNREPLIED];
+		pn->ctl_table[1].data = &un->timeouts[UDP_CT_REPLIED];
+#endif
+	}
+	return 0;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
 	.l4proto		= IPPROTO_UDP,
+	.compat			= 1,
 	.name			= "udp",
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
@@ -275,6 +315,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 	.ctl_compat_table	= udp_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
 
@@ -282,6 +323,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_UDP,
+	.compat			= 0,
 	.name			= "udp",
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
@@ -310,5 +352,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 	.ctl_table_header	= &udp_sysctl_header,
 	.ctl_table		= udp_sysctl_table,
 #endif
+	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
-- 
1.7.7.6

