From: pablo@netfilter.org
Subject: [PATCH 09/25] netfilter: nf_ct_icmp: add namespace support
Date: Mon, 11 Jun 2012 16:43:45 +0200
Message-ID: <1339425841-24171-10-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32906 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755431Ab2FKOpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:45:07 -0400
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch adds namespace support for ICMP protocol tracker.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/conntrack.h                |    6 ++++
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c |   38 ++++++++++++++++++++++++--
 net/netfilter/nf_conntrack_proto.c           |    2 ++
 3 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 7bd14ab..3d8e9e3 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -45,10 +45,16 @@ struct nf_udp_net {
 	unsigned int timeouts[UDP_CT_MAX];
 };
 
+struct nf_icmp_net {
+	struct nf_proto_net pn;
+	unsigned int timeout;
+};
+
 struct nf_ip_net {
 	struct nf_generic_net   generic;
 	struct nf_tcp_net	tcp;
 	struct nf_udp_net	udp;
+	struct nf_icmp_net	icmp;
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	struct ctl_table_header *ctl_table_header;
 	struct ctl_table	*ctl_table;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 0847e37..a0eabeb 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -23,6 +23,11 @@
 
 static unsigned int nf_ct_icmp_timeout __read_mostly = 30*HZ;
 
+static inline struct nf_icmp_net *icmp_pernet(struct net *net)
+{
+	return &net->ct.nf_ct_proto.icmp;
+}
+
 static bool icmp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			      struct nf_conntrack_tuple *tuple)
 {
@@ -77,7 +82,7 @@ static int icmp_print_tuple(struct seq_file *s,
 
 static unsigned int *icmp_get_timeouts(struct net *net)
 {
-	return &nf_ct_icmp_timeout;
+	return &icmp_pernet(net)->timeout;
 }
 
 /* Returns verdict for packet, or -1 for invalid. */
@@ -312,7 +317,6 @@ static struct ctl_table_header *icmp_sysctl_header;
 static struct ctl_table icmp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_icmp_timeout",
-		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -323,7 +327,6 @@ static struct ctl_table icmp_sysctl_table[] = {
 static struct ctl_table icmp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_icmp_timeout",
-		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -333,6 +336,34 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int icmp_init_net(struct net *net)
+{
+	struct nf_icmp_net *in = icmp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)in;
+	in->timeout = nf_ct_icmp_timeout;
+
+#ifdef CONFIG_SYSCTL
+	pn->ctl_table = kmemdup(icmp_sysctl_table,
+				sizeof(icmp_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+	pn->ctl_table[0].data = &in->timeout;
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	pn->ctl_compat_table = kmemdup(icmp_compat_sysctl_table,
+				       sizeof(icmp_compat_sysctl_table),
+				       GFP_KERNEL);
+	if (!pn->ctl_compat_table) {
+		kfree(pn->ctl_table);
+		pn->ctl_table = NULL;
+		return -ENOMEM;
+	}
+	pn->ctl_compat_table[0].data = &in->timeout;
+#endif
+#endif
+	return 0;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -369,4 +400,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	.ctl_compat_table	= icmp_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= icmp_init_net,
 };
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 9c6aee5..dbade5f 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -307,6 +307,8 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 		return (struct nf_proto_net *)&net->ct.nf_ct_proto.tcp;
 	case IPPROTO_UDP:
 		return (struct nf_proto_net *)&net->ct.nf_ct_proto.udp;
+	case IPPROTO_ICMP:
+		return (struct nf_proto_net *)&net->ct.nf_ct_proto.icmp;
 	case 255: /* l4proto_generic */
 		return (struct nf_proto_net *)&net->ct.nf_ct_proto.generic;
 	default:
-- 
1.7.10
