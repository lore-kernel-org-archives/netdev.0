From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 08/17] netfilter: add namespace support for l4proto_icmpv6
Date: Fri, 27 Apr 2012 17:37:55 +0800
Message-ID: <1335519484-6089-9-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

implement icmpv6_init_net is to initial the pernet data for
icmpv6 proto.

because nf_icmp_net is a field of netns_ct,so when proto is icmpv6,
return net->ct.proto.icmpv6 in function nf_ct_l4proto_net.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netns/conntrack.h                  |    1 +
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   26 ++++++++++++++++++++++-
 net/netfilter/nf_conntrack_proto.c             |    2 +
 3 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 82de500..1f46e65 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -55,6 +55,7 @@ struct nf_ip_net {
 	struct nf_tcp_net       tcp;
 	struct nf_udp_net	udp;
 	struct nf_icmp_net	icmp;
+	struct nf_icmp_net	icmpv6;
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	struct ctl_table_header *ctl_table_header;
 	struct ctl_table        *ctl_table;
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 3e81904..3cb422e 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -29,6 +29,11 @@
 
 static unsigned int nf_ct_icmpv6_timeout __read_mostly = 30*HZ;
 
+static inline struct nf_icmp_net *icmpv6_pernet(struct net *net)
+{
+	return &net->ct.proto.icmpv6;
+}
+
 static bool icmpv6_pkt_to_tuple(const struct sk_buff *skb,
 				unsigned int dataoff,
 				struct nf_conntrack_tuple *tuple)
@@ -90,7 +95,7 @@ static int icmpv6_print_tuple(struct seq_file *s,
 
 static unsigned int *icmpv6_get_timeouts(struct net *net)
 {
-	return &nf_ct_icmpv6_timeout;
+	return &icmpv6_pernet(net)->timeout;
 }
 
 /* Returns verdict for packet, or -1 for invalid. */
@@ -319,7 +324,6 @@ static struct ctl_table_header *icmpv6_sysctl_header;
 static struct ctl_table icmpv6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_icmpv6_timeout",
-		.data		= &nf_ct_icmpv6_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -328,10 +332,27 @@ static struct ctl_table icmpv6_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
+static int icmpv6_init_net(struct net *net, u_int8_t compat)
+{
+	struct nf_icmp_net *in = icmpv6_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)in;
+	in->timeout = nf_ct_icmpv6_timeout;
+#ifdef CONFIG_SYSCTL
+	pn->ctl_table = kmemdup(icmpv6_sysctl_table,
+				sizeof(icmpv6_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+	pn->ctl_table[0].data = &in->timeout;
+#endif
+	return 0;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_ICMPV6,
+	.compat			= 0,
 	.name			= "icmpv6",
 	.pkt_to_tuple		= icmpv6_pkt_to_tuple,
 	.invert_tuple		= icmpv6_invert_tuple,
@@ -359,4 +380,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 	.ctl_table_header	= &icmpv6_sysctl_header,
 	.ctl_table		= icmpv6_sysctl_table,
 #endif
+	.init_net		= icmpv6_init_net,
 };
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index ebf4de9..3e26389 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -294,6 +294,8 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 		return (struct nf_proto_net *)&net->ct.proto.udp;
 	case IPPROTO_ICMP:
 		return (struct nf_proto_net *)&net->ct.proto.icmp;
+	case IPPROTO_ICMPV6:
+		return (struct nf_proto_net *)&net->ct.proto.icmpv6;
 	case 255: /* l4proto_generic */
 		return (struct nf_proto_net *)&net->ct.proto.generic;
 	default:
-- 
1.7.7.6

