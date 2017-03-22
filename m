From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v3] net: Add sysctl to toggle early demux for tcp and udp
Date: Tue, 21 Mar 2017 21:20:10 -0600
Message-ID: <1490152810-25133-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40070 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757341AbdCVD12 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 23:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Certain system process significant unconnected UDP workload.
It would be preferrable to disable UDP early demux for those systems
and enable it for TCP only.

By disabling UDP demux, we see these slight gains on an ARM64 system-
782 -> 788Mbps unconnected single stream UDPv4
633 -> 654Mbps unconnected UDPv4 different sources

The performance impact can change based on CPU architecure and cache
sizes. There will not much difference seen if entire UDP hash table
is in cache.

Both sysctls are enabled by default to preserve existing behavior.

v1->v2: Change function pointer instead of adding conditional as
suggested by Stephen.

v2->v3: Read once in callers to avoid issues due to compiler
optimizations. Also update commit message with the tests.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Suggested-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/ip-sysctl.txt | 11 +++++++-
 include/net/netns/ipv4.h               |  2 ++
 include/net/tcp.h                      |  2 ++
 include/net/udp.h                      |  3 +++
 net/ipv4/af_inet.c                     | 22 ++++++++++++++--
 net/ipv4/ip_input.c                    |  2 +-
 net/ipv4/sysctl_net_ipv4.c             | 48 ++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_input.c                   |  2 +-
 net/ipv6/tcp_ipv6.c                    | 10 ++++++-
 net/ipv6/udp.c                         | 10 ++++++-
 10 files changed, 105 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ed3d079..6b921a1 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -848,12 +848,21 @@ ip_dynaddr - BOOLEAN
 ip_early_demux - BOOLEAN
 	Optimize input packet processing down to one demux for
 	certain kinds of local sockets.  Currently we only do this
-	for established TCP sockets.
+	for established TCP and connected UDP sockets.
 
 	It may add an additional cost for pure routing workloads that
 	reduces overall throughput, in such case you should disable it.
 	Default: 1
 
+tcp_early_demux - BOOLEAN
+	Enable early demux for established TCP sockets.
+	Default: 1
+
+udp_early_demux - BOOLEAN
+	Enable early demux for connected UDP sockets. Disable this if
+	your system could experience more unconnected load.
+	Default: 1
+
 icmp_echo_ignore_all - BOOLEAN
 	If set non-zero, then the kernel will ignore all ICMP ECHO
 	requests sent to it.
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2e9d649..a489b76 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -95,6 +95,8 @@ struct netns_ipv4 {
 	/* Shall we try to damage output packets if routing dev changes? */
 	int sysctl_ip_dynaddr;
 	int sysctl_ip_early_demux;
+	int sysctl_tcp_early_demux;
+	int sysctl_udp_early_demux;
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e614ad4..edc1df4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1932,4 +1932,6 @@ static inline void tcp_listendrop(const struct sock *sk)
 	__NET_INC_STATS(sock_net(sk), LINUX_MIB_LISTENDROPS);
 }
 
+void tcp_v4_early_demux_configure(int enable);
+void tcp_v6_early_demux_configure(int enable);
 #endif	/* _TCP_H */
diff --git a/include/net/udp.h b/include/net/udp.h
index c9d8b8e..33198fa 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -372,4 +372,7 @@ struct udp_iter_state {
 #if IS_ENABLED(CONFIG_IPV6)
 void udpv6_encap_enable(void);
 #endif
+
+void udp_v4_early_demux_configure(int enable);
+void udp_v6_early_demux_configure(int enable);
 #endif	/* _UDP_H */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6b1fc6e..d286750 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1599,7 +1599,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 };
 #endif
 
-static const struct net_protocol tcp_protocol = {
+static struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
 	.err_handler	=	tcp_v4_err,
@@ -1608,7 +1608,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	.icmp_strict_tag_validation = 1,
 };
 
-static const struct net_protocol udp_protocol = {
+static struct net_protocol udp_protocol = {
 	.early_demux =	udp_v4_early_demux,
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
@@ -1616,6 +1616,22 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	.netns_ok =	1,
 };
 
+void tcp_v4_early_demux_configure(int enable)
+{
+	if (enable)
+		tcp_protocol.early_demux = tcp_v4_early_demux;
+	else
+		tcp_protocol.early_demux = NULL;
+}
+
+void udp_v4_early_demux_configure(int enable)
+{
+	if (enable)
+		udp_protocol.early_demux = udp_v4_early_demux;
+	else
+		udp_protocol.early_demux = NULL;
+}
+
 static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
 	.err_handler =	icmp_err,
@@ -1720,6 +1736,8 @@ static __net_init int inet_init_net(struct net *net)
 	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
 	net->ipv4.sysctl_ip_dynaddr = 0;
 	net->ipv4.sysctl_ip_early_demux = 1;
+	net->ipv4.sysctl_udp_early_demux = 1;
+	net->ipv4.sysctl_tcp_early_demux = 1;
 #ifdef CONFIG_SYSCTL
 	net->ipv4.sysctl_ip_prot_sock = PROT_SOCK;
 #endif
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d6feabb..48d0fc8 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -329,7 +329,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		int protocol = iph->protocol;
 
 		ipprot = rcu_dereference(inet_protos[protocol]);
-		if (ipprot && ipprot->early_demux) {
+		if (ipprot && READ_ONCE(ipprot->early_demux)) {
 			ipprot->early_demux(skb);
 			/* must reload iph, skb->head might have changed */
 			iph = ip_hdr(skb);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 11aaef0..86ad484 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -294,6 +294,40 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static int proc_tcp_early_demux(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret = 0;
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+
+	if (write && !ret) {
+		int enabled = init_net.ipv4.sysctl_tcp_early_demux;
+
+		tcp_v4_early_demux_configure(enabled);
+		tcp_v6_early_demux_configure(enabled);
+	}
+
+	return ret;
+}
+
+static int proc_udp_early_demux(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret = 0;
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+
+	if (write && !ret) {
+		int enabled = init_net.ipv4.sysctl_udp_early_demux;
+
+		udp_v4_early_demux_configure(enabled);
+		udp_v6_early_demux_configure(enabled);
+	}
+
+	return ret;
+}
+
 static struct ctl_table ipv4_table[] = {
 	{
 		.procname	= "tcp_timestamps",
@@ -750,6 +784,20 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname       = "udp_early_demux",
+		.data           = &init_net.ipv4.sysctl_udp_early_demux,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_udp_early_demux
+	},
+	{
+		.procname       = "tcp_early_demux",
+		.data           = &init_net.ipv4.sysctl_tcp_early_demux,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_tcp_early_demux
+	},
+	{
 		.procname	= "ip_default_ttl",
 		.data		= &init_net.ipv4.sysctl_ip_default_ttl,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index aacfb4b..30d18cb 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -60,7 +60,7 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		const struct inet6_protocol *ipprot;
 
 		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
-		if (ipprot && ipprot->early_demux)
+		if (ipprot && READ_ONCE(ipprot->early_demux))
 			ipprot->early_demux(skb);
 	}
 	if (!skb_valid_dst(skb))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0f08d71..e26622f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1925,13 +1925,21 @@ struct proto tcpv6_prot = {
 	.diag_destroy		= tcp_abort,
 };
 
-static const struct inet6_protocol tcpv6_protocol = {
+static struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
+void tcp_v6_early_demux_configure(int enable)
+{
+	if (enable)
+		tcpv6_protocol.early_demux = tcp_v6_early_demux;
+	else
+		tcpv6_protocol.early_demux = NULL;
+}
+
 static struct inet_protosw tcpv6_protosw = {
 	.type		=	SOCK_STREAM,
 	.protocol	=	IPPROTO_TCP,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 08a188f..7178a18 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1436,13 +1436,21 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
-static const struct inet6_protocol udpv6_protocol = {
+static struct inet6_protocol udpv6_protocol = {
 	.early_demux	=	udp_v6_early_demux,
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
+void udp_v6_early_demux_configure(int enable)
+{
+	if (enable)
+		udpv6_protocol.early_demux = udp_v6_early_demux;
+	else
+		udpv6_protocol.early_demux = NULL;
+}
+
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
 int udp6_seq_show(struct seq_file *seq, void *v)
-- 
1.9.1
