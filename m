From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2 4/6] netns ct: per-netns
	net.netfilter.nf_conntrack_checksum sysctl
Date: Sat, 13 Sep 2008 14:52:39 +0400
Message-ID: <20080913105239.GE7440@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:42122 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213AbYIMKuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2008 06:50:44 -0400
Received: by ey-out-2122.google.com with SMTP id 6so536886eyi.37
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2008 03:50:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48C62B1C.7070104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h           |    1 -
 include/net/netns/conntrack.h                  |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    2 +-
 net/netfilter/nf_conntrack_proto_udp.c         |    2 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |    2 +-
 net/netfilter/nf_conntrack_standalone.c        |    7 +++----
 10 files changed, 11 insertions(+), 12 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -287,7 +287,6 @@ static inline int nf_ct_is_untracked(const struct sk_buff *skb)
 
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
-extern int nf_conntrack_checksum;
 extern int nf_conntrack_max;
 
 #define NF_CT_STAT_INC(net, count)	\
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -17,6 +17,7 @@ struct netns_ct {
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct nf_conntrack_ecache *ecache;
 #endif
+	int			sysctl_checksum;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 #endif
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -270,7 +270,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_CHECKSUM,
 		.procname	= "ip_conntrack_checksum",
-		.data		= &nf_conntrack_checksum,
+		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -188,7 +188,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	}
 
 	/* See ip_conntrack_proto_tcp.c */
-	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, dataoff, 0)) {
 		if (LOG_INVALID(IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -187,7 +187,7 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 		return -NF_ACCEPT;
 	}
 
-	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip6_checksum(skb, hooknum, dataoff, IPPROTO_ICMPV6)) {
 		nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
 			      "nf_ct_icmpv6: ICMPv6 checksum failed\n");
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -575,7 +575,7 @@ static int dccp_error(struct net *net, struct sk_buff *skb,
 		}
 	}
 
-	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum_partial(skb, hooknum, dataoff, cscov, IPPROTO_DCCP,
 				pf)) {
 		msg = "nf_ct_dccp: bad checksum ";
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -780,7 +780,7 @@ static int tcp_error(struct net *net,
 	 * because the checksum is assumed to be correct.
 	 */
 	/* FIXME: Source route IP option packets --RR */
-	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_TCP, pf)) {
 		if (LOG_INVALID(IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -123,7 +123,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	 * We skip checking packets on the outgoing path
 	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
-	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_UDP, pf)) {
 		if (LOG_INVALID(IPPROTO_UDP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -129,7 +129,7 @@ static int udplite_error(struct net *net,
 	}
 
 	/* Checksum invalid? Ignore. */
-	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum_partial(skb, hooknum, dataoff, cscov, IPPROTO_UDP,
 	    			pf)) {
 		if (LOG_INVALID(IPPROTO_UDPLITE))
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -322,9 +322,6 @@ static void nf_conntrack_standalone_fini_proc(struct net *net)
 
 /* Sysctl support */
 
-int nf_conntrack_checksum __read_mostly = 1;
-EXPORT_SYMBOL_GPL(nf_conntrack_checksum);
-
 #ifdef CONFIG_SYSCTL
 /* Log invalid packets of a given protocol */
 static int log_invalid_proto_min = 0;
@@ -360,7 +357,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_NF_CONNTRACK_CHECKSUM,
 		.procname	= "nf_conntrack_checksum",
-		.data		= &nf_conntrack_checksum,
+		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
@@ -425,6 +422,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 		goto out_kmemdup;
 
 	table[1].data = &net->ct.count;
+	table[3].data = &net->ct.sysctl_checksum;
 
 	net->ct.sysctl_header = register_net_sysctl_table(net,
 					nf_net_netfilter_sysctl_path, table);
@@ -474,6 +472,7 @@ static int nf_conntrack_net_init(struct net *net)
 	ret = nf_conntrack_standalone_init_proc(net);
 	if (ret < 0)
 		goto out_proc;
+	net->ct.sysctl_checksum = 1;
 	ret = nf_conntrack_standalone_init_sysctl(net);
 	if (ret < 0)
 		goto out_sysctl;
