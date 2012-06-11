From: pablo@netfilter.org
Subject: [PATCH 08/25] netfilter: nf_ct_udp: add namespace support
Date: Mon, 11 Jun 2012 16:43:44 +0200
Message-ID: <1339425841-24171-9-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch adds namespace support for UDP protocol tracker.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/conntrack.h          |   12 ++++
 net/netfilter/nf_conntrack_proto.c     |    2 +
 net/netfilter/nf_conntrack_proto_udp.c |  100 ++++++++++++++++++++++++++++----
 3 files changed, 103 insertions(+), 11 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 680d799..7bd14ab 100644
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
 	struct nf_tcp_net	tcp;
+	struct nf_udp_net	udp;
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	struct ctl_table_header *ctl_table_header;
 	struct ctl_table	*ctl_table;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 8a71e8b..9c6aee5 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -305,6 +305,8 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 	switch (l4proto->l4proto) {
 	case IPPROTO_TCP:
 		return (struct nf_proto_net *)&net->ct.nf_ct_proto.tcp;
+	case IPPROTO_UDP:
+		return (struct nf_proto_net *)&net->ct.nf_ct_proto.udp;
 	case 255: /* l4proto_generic */
 		return (struct nf_proto_net *)&net->ct.nf_ct_proto.generic;
 	default:
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 7259a6b..f56c890 100644
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
+	return &net->ct.nf_ct_proto.udp;
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
@@ -240,6 +235,87 @@ static struct ctl_table udp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int udp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_SYSCTL
+	struct nf_udp_net *un = (struct nf_udp_net *)pn;
+	if (pn->ctl_table)
+		return 0;
+	pn->ctl_table = kmemdup(udp_sysctl_table,
+				sizeof(udp_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+	pn->ctl_table[0].data = &un->timeouts[UDP_CT_UNREPLIED];
+	pn->ctl_table[1].data = &un->timeouts[UDP_CT_REPLIED];
+#endif
+	return 0;
+}
+
+static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct nf_udp_net *un = (struct nf_udp_net *)pn;
+	pn->ctl_compat_table = kmemdup(udp_compat_sysctl_table,
+				       sizeof(udp_compat_sysctl_table),
+				       GFP_KERNEL);
+	if (!pn->ctl_compat_table)
+		return -ENOMEM;
+
+	pn->ctl_compat_table[0].data = &un->timeouts[UDP_CT_UNREPLIED];
+	pn->ctl_compat_table[1].data = &un->timeouts[UDP_CT_REPLIED];
+#endif
+#endif
+	return 0;
+}
+
+static void udp_init_net_data(struct nf_udp_net *un)
+{
+	int i;
+#ifdef CONFIG_SYSCTL
+	if (!un->pn.ctl_table) {
+#else
+	if (!un->pn.user++) {
+#endif
+		for (i = 0; i < UDP_CT_MAX; i++)
+			un->timeouts[i] = udp_timeouts[i];
+	}
+}
+
+static int udpv4_init_net(struct net *net)
+{
+	int ret;
+	struct nf_udp_net *un = udp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)un;
+
+	udp_init_net_data(un);
+
+	ret = udp_kmemdup_compat_sysctl_table(pn);
+	if (ret < 0)
+		return ret;
+
+	ret = udp_kmemdup_sysctl_table(pn);
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
+static int udpv6_init_net(struct net *net)
+{
+	struct nf_udp_net *un = udp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)un;
+
+	udp_init_net_data(un);
+	return udp_kmemdup_sysctl_table(pn);
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -275,6 +351,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 	.ctl_compat_table	= udp_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= udpv4_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
 
@@ -310,5 +387,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 	.ctl_table_header	= &udp_sysctl_header,
 	.ctl_table		= udp_sysctl_table,
 #endif
+	.init_net		= udpv6_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
-- 
1.7.10

