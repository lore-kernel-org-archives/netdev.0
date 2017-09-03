From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/47] netfilter: conntrack: remove protocol name from l4proto struct
Date: Mon,  4 Sep 2017 00:41:43 +0200
Message-ID: <1504478516-13224-2-git-send-email-pablo@netfilter.org>
References: <1504478516-13224-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52896 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753439AbdICWmM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:42:12 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4BFAB190F66
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:41:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3CEBDB5026
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:41:45 +0200 (CEST)
In-Reply-To: <1504478516-13224-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

no need to waste storage for something that is only needed
in one place and can be deduced from protocol number.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |  3 ---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  1 -
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  1 -
 net/netfilter/nf_conntrack_proto.c             |  8 ++++----
 net/netfilter/nf_conntrack_proto_dccp.c        |  2 --
 net/netfilter/nf_conntrack_proto_generic.c     |  1 -
 net/netfilter/nf_conntrack_proto_gre.c         |  1 -
 net/netfilter/nf_conntrack_proto_sctp.c        |  2 --
 net/netfilter/nf_conntrack_proto_tcp.c         |  2 --
 net/netfilter/nf_conntrack_proto_udp.c         |  4 ----
 net/netfilter/nf_conntrack_standalone.c        | 17 ++++++++++++++++-
 11 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index b6e27cafb1d9..47c16bae5e00 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -108,9 +108,6 @@ struct nf_conntrack_l4proto {
 	/* Return the per-net protocol part. */
 	struct nf_proto_net *(*get_net_proto)(struct net *net);
 
-	/* Protocol name */
-	const char *name;
-
 	/* Module (if any) which this is connected to. */
 	struct module *me;
 };
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 73c591d8a9a8..fdbeb03e4600 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -362,7 +362,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 {
 	.l3proto		= PF_INET,
 	.l4proto		= IPPROTO_ICMP,
-	.name			= "icmp",
 	.pkt_to_tuple		= icmp_pkt_to_tuple,
 	.invert_tuple		= icmp_invert_tuple,
 	.print_tuple		= icmp_print_tuple,
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index d5f028e33f65..805ab122767a 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -367,7 +367,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_ICMPV6,
-	.name			= "icmpv6",
 	.pkt_to_tuple		= icmpv6_pkt_to_tuple,
 	.invert_tuple		= icmpv6_invert_tuple,
 	.print_tuple		= icmpv6_print_tuple,
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 85104a27cc89..0ecab7163d62 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -437,8 +437,8 @@ int nf_ct_l4proto_register(struct nf_conntrack_l4proto *l4proto[],
 	}
 	if (i != num_proto) {
 		ver = l4proto[i]->l3proto == PF_INET6 ? 6 : 4;
-		pr_err("nf_conntrack_ipv%d: can't register %s%d proto.\n",
-		       ver, l4proto[i]->name, ver);
+		pr_err("nf_conntrack_ipv%d: can't register l4 %d proto.\n",
+		       ver, l4proto[i]->l4proto);
 		nf_ct_l4proto_unregister(l4proto, i);
 	}
 	return ret;
@@ -458,8 +458,8 @@ int nf_ct_l4proto_pernet_register(struct net *net,
 			break;
 	}
 	if (i != num_proto) {
-		pr_err("nf_conntrack_%s%d: pernet registration failed\n",
-		       l4proto[i]->name,
+		pr_err("nf_conntrack_proto_%d %d: pernet registration failed\n",
+		       l4proto[i]->l4proto,
 		       l4proto[i]->l3proto == PF_INET6 ? 6 : 4);
 		nf_ct_l4proto_pernet_unregister(net, l4proto, i);
 	}
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 4707d997558a..a0492184a0a8 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -880,7 +880,6 @@ static struct nf_proto_net *dccp_get_net_proto(struct net *net)
 struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4 __read_mostly = {
 	.l3proto		= AF_INET,
 	.l4proto		= IPPROTO_DCCP,
-	.name			= "dccp",
 	.pkt_to_tuple		= dccp_pkt_to_tuple,
 	.invert_tuple		= dccp_invert_tuple,
 	.new			= dccp_new,
@@ -916,7 +915,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_dccp4);
 struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6 __read_mostly = {
 	.l3proto		= AF_INET6,
 	.l4proto		= IPPROTO_DCCP,
-	.name			= "dccp",
 	.pkt_to_tuple		= dccp_pkt_to_tuple,
 	.invert_tuple		= dccp_invert_tuple,
 	.new			= dccp_new,
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index d5868bad33a7..4fe8b3312823 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -187,7 +187,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 {
 	.l3proto		= PF_UNSPEC,
 	.l4proto		= 255,
-	.name			= "unknown",
 	.pkt_to_tuple		= generic_pkt_to_tuple,
 	.invert_tuple		= generic_invert_tuple,
 	.print_tuple		= generic_print_tuple,
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 87bb40a3feb5..984bcfdbd4d7 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -364,7 +364,6 @@ static int gre_init_net(struct net *net, u_int16_t proto)
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.l3proto	 = AF_INET,
 	.l4proto	 = IPPROTO_GRE,
-	.name		 = "gre",
 	.pkt_to_tuple	 = gre_pkt_to_tuple,
 	.invert_tuple	 = gre_invert_tuple,
 	.print_tuple	 = gre_print_tuple,
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 6eef29d2eec4..1d7a995ea049 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -791,7 +791,6 @@ static struct nf_proto_net *sctp_get_net_proto(struct net *net)
 struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.l3proto		= PF_INET,
 	.l4proto 		= IPPROTO_SCTP,
-	.name 			= "sctp",
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
 	.print_tuple 		= sctp_print_tuple,
@@ -828,7 +827,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_sctp4);
 struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.l3proto		= PF_INET6,
 	.l4proto 		= IPPROTO_SCTP,
-	.name 			= "sctp",
 	.pkt_to_tuple 		= sctp_pkt_to_tuple,
 	.invert_tuple 		= sctp_invert_tuple,
 	.print_tuple 		= sctp_print_tuple,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 9758a7dfd83e..e3e59e3d0592 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1556,7 +1556,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
 	.l4proto 		= IPPROTO_TCP,
-	.name 			= "tcp",
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
 	.print_tuple 		= tcp_print_tuple,
@@ -1594,7 +1593,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto 		= IPPROTO_TCP,
-	.name 			= "tcp",
 	.pkt_to_tuple 		= tcp_pkt_to_tuple,
 	.invert_tuple 		= tcp_invert_tuple,
 	.print_tuple 		= tcp_print_tuple,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index f6ebce6178ca..ec861a1169f1 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -313,7 +313,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
 	.l4proto		= IPPROTO_UDP,
-	.name			= "udp",
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
@@ -347,7 +346,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 {
 	.l3proto		= PF_INET,
 	.l4proto		= IPPROTO_UDPLITE,
-	.name			= "udplite",
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
@@ -381,7 +379,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_UDP,
-	.name			= "udp",
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
@@ -415,7 +412,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_UDPLITE,
-	.name			= "udplite",
 	.allow_clash		= true,
 	.pkt_to_tuple		= udp_pkt_to_tuple,
 	.invert_tuple		= udp_invert_tuple,
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 359d7e6a4503..b28f9e93f574 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -208,6 +208,21 @@ static const char* l3proto_name(u16 proto)
 	return "unknown";
 }
 
+static const char* l4proto_name(u16 proto)
+{
+	switch (proto) {
+	case IPPROTO_ICMP: return "icmp";
+	case IPPROTO_TCP: return "tcp";
+	case IPPROTO_UDP: return "udp";
+	case IPPROTO_DCCP: return "dccp";
+	case IPPROTO_GRE: return "gre";
+	case IPPROTO_SCTP: return "sctp";
+	case IPPROTO_UDPLITE: return "udplite";
+	}
+
+	return "unknown";
+}
+
 /* return 0 on success, 1 in case of error */
 static int ct_seq_show(struct seq_file *s, void *v)
 {
@@ -242,7 +257,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	ret = -ENOSPC;
 	seq_printf(s, "%-8s %u %-8s %u %ld ",
 		   l3proto_name(l3proto->l3proto), nf_ct_l3num(ct),
-		   l4proto->name, nf_ct_protonum(ct),
+		   l4proto_name(l4proto->l4proto), nf_ct_protonum(ct),
 		   nf_ct_expires(ct)  / HZ);
 
 	if (l4proto->print_conntrack)
-- 
2.1.4
