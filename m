From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next] net: Add sysctl to toggle early demux for tcp and udp
Date: Thu,  9 Mar 2017 14:09:18 -0700
Message-ID: <1489093758-17731-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58232 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdCIVJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 16:09:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Certain system process significant unconnected UDP workload.
It would be preferrable to disable UDP early demux for those systems
and enable it for TCP only.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Suggested-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  2 ++
 include/net/protocol.h     |  3 ++-
 net/ipv4/af_inet.c         |  9 ++++++---
 net/ipv4/ip_input.c        |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 14 ++++++++++++++
 net/ipv6/ip6_input.c       |  2 +-
 net/ipv6/tcp_ipv6.c        |  3 ++-
 7 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 0378e88..1e74da23 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -86,6 +86,8 @@ struct netns_ipv4 {
 	/* Shall we try to damage output packets if routing dev changes? */
 	int sysctl_ip_dynaddr;
 	int sysctl_ip_early_demux;
+	int sysctl_tcp_early_demux;
+	int sysctl_udp_early_demux;
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
diff --git a/include/net/protocol.h b/include/net/protocol.h
index bf36ca3..f8ede39 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -40,6 +40,7 @@
 /* This is used to register protocols. */
 struct net_protocol {
 	void			(*early_demux)(struct sk_buff *skb);
+	int			*early_demux_enabled;
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	unsigned int		no_policy:1,
@@ -54,7 +55,7 @@ struct net_protocol {
 #if IS_ENABLED(CONFIG_IPV6)
 struct inet6_protocol {
 	void	(*early_demux)(struct sk_buff *skb);
-
+	int	*early_demux_enabled;
 	int	(*handler)(struct sk_buff *skb);
 
 	void	(*err_handler)(struct sk_buff *skb,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f750698..5a1d30e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1579,7 +1579,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 };
 #endif
 
-static const struct net_protocol tcp_protocol = {
+static struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
 	.err_handler	=	tcp_v4_err,
@@ -1588,7 +1588,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	.icmp_strict_tag_validation = 1,
 };
 
-static const struct net_protocol udp_protocol = {
+static struct net_protocol udp_protocol = {
 	.early_demux =	udp_v4_early_demux,
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
@@ -1699,7 +1699,10 @@ static __net_init int inet_init_net(struct net *net)
 	 */
 	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
 	net->ipv4.sysctl_ip_dynaddr = 0;
-	net->ipv4.sysctl_ip_early_demux = 1;
+	net->ipv4.sysctl_udp_early_demux = 1;
+	net->ipv4.sysctl_tcp_early_demux = 1;
+	tcp_protocol.early_demux_enabled = &net->ipv4.sysctl_tcp_early_demux;
+	udp_protocol.early_demux_enabled = &net->ipv4.sysctl_udp_early_demux;
 
 	return 0;
 }
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d6feabb..187feae 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -329,7 +329,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		int protocol = iph->protocol;
 
 		ipprot = rcu_dereference(inet_protos[protocol]);
-		if (ipprot && ipprot->early_demux) {
+		if (ipprot && ipprot->early_demux && *ipprot->early_demux_enabled) {
 			ipprot->early_demux(skb);
 			/* must reload iph, skb->head might have changed */
 			iph = ip_hdr(skb);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index b2fa498..b212af9 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -737,6 +737,20 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname       = "udp_early_demux",
+		.data           = &init_net.ipv4.sysctl_udp_early_demux,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
+	{
+		.procname       = "tcp_early_demux",
+		.data           = &init_net.ipv4.sysctl_tcp_early_demux,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
+	{
 		.procname	= "ip_default_ttl",
 		.data		= &init_net.ipv4.sysctl_ip_default_ttl,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index aacfb4b..b34f737 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -60,7 +60,7 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		const struct inet6_protocol *ipprot;
 
 		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
-		if (ipprot && ipprot->early_demux)
+		if (ipprot && ipprot->early_demux && *ipprot->early_demux_enabled)
 			ipprot->early_demux(skb);
 	}
 	if (!skb_valid_dst(skb))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4c60c6f..fb73a41 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1926,7 +1926,7 @@ struct proto tcpv6_prot = {
 	.diag_destroy		= tcp_abort,
 };
 
-static const struct inet6_protocol tcpv6_protocol = {
+static struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
@@ -1944,6 +1944,7 @@ struct proto tcpv6_prot = {
 
 static int __net_init tcpv6_net_init(struct net *net)
 {
+	tcpv6_protocol.early_demux_enabled = &net->ipv4.sysctl_tcp_early_demux;
 	return inet_ctl_sock_create(&net->ipv6.tcp_sk, PF_INET6,
 				    SOCK_RAW, IPPROTO_TCP, net);
 }
-- 
1.9.1
