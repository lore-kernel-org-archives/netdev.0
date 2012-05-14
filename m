From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 07/17] netfilter: add namespace support for l4proto_icmp
Date: Mon, 14 May 2012 16:52:17 +0800
Message-ID: <1336985547-31960-8-git-send-email-gaofeng@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:5805 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755382Ab2ENIw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 04:52:58 -0400
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

implement icmp_init_net is to initial the pernet data for
icmp proto.

beacuse nf_icmp_net is a field of netns_ct,so when proto is icmp,
return net->ct.proto.icmp in function nf_ct_l4proto_net.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netns/conntrack.h                |    6 ++++
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c |   39 ++++++++++++++++++++++++--
 net/netfilter/nf_conntrack_proto.c           |    2 +
 3 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 3d1450b..430cc71 100644
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
index 0847e37..f468d10 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -23,6 +23,11 @@
 
 static unsigned int nf_ct_icmp_timeout __read_mostly = 30*HZ;
 
+static inline struct nf_icmp_net *icmp_pernet(struct net *net)
+{
+	return &net->ct.proto.icmp;
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
@@ -333,10 +336,39 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int icmp_init_net(struct net *net, u_int8_t compat)
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
 	.l4proto		= IPPROTO_ICMP,
+	.compat			= 1,
 	.name			= "icmp",
 	.pkt_to_tuple		= icmp_pkt_to_tuple,
 	.invert_tuple		= icmp_invert_tuple,
@@ -369,4 +401,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	.ctl_compat_table	= icmp_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= icmp_init_net,
 };
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index ba96447..fc0accd 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -292,6 +292,8 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 		return (struct nf_proto_net *)&net->ct.proto.tcp;
 	case IPPROTO_UDP:
 		return (struct nf_proto_net *)&net->ct.proto.udp;
+	case IPPROTO_ICMP:
+		return (struct nf_proto_net *)&net->ct.proto.icmp;
 	case 255: /* l4proto_generic */
 		return (struct nf_proto_net *)&net->ct.proto.generic;
 	default:
-- 
1.7.7.6
