From: adobriyan@gmail.com
Subject: [PATCH 26/38] netns ct: per-netns net.netfilter.nf_conntrack_checksum
Date: Fri, 22 Aug 2008 02:07:36 +0400
Message-ID: <20080821220736.GZ31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 net/netfilter/nf_conntrack_standalone.c        |    8 +++-----
 10 files changed, 11 insertions(+), 13 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -282,7 +282,6 @@ static inline int nf_ct_is_dying(struct nf_conn *ct)
 
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
-extern int nf_conntrack_checksum;
 extern int nf_conntrack_max;
 
 #define NF_CT_STAT_INC(net, count)	\
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -22,6 +22,7 @@ struct netns_ct {
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
@@ -190,7 +190,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	}
 
 	/* See ip_conntrack_proto_tcp.c */
-	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
+	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, dataoff, 0)) {
 		if (LOG_INVALID(IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -188,7 +188,7 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
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
@@ -779,7 +779,7 @@ static int tcp_error(struct net *net, struct sk_buff *skb,
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
@@ -125,7 +125,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
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
@@ -130,7 +130,7 @@ static int udplite_error(struct net *net, struct sk_buff *skb,
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
@@ -424,6 +421,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 		goto out_kmemdup;
 
 	table[1].data = &net->ct.count;
+	table[3].data = &net->ct.sysctl_checksum;
 
 	net->ct.sysctl_header = register_net_sysctl_table(net,
 					nf_net_netfilter_sysctl_path, table);
@@ -473,6 +471,7 @@ static int nf_conntrack_net_init(struct net *net)
 	ret = nf_conntrack_standalone_init_proc(net);
 	if (ret < 0)
 		goto out_proc;
+	net->ct.sysctl_checksum = 1;
 	ret = nf_conntrack_standalone_init_sysctl(net);
 	if (ret < 0)
 		goto out_sysctl;
-- 
1.5.6.3


