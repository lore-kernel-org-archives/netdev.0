From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v5] net: Add sysctl to toggle early demux for tcp and udp
Date: Thu, 23 Mar 2017 13:34:16 -0600
Message-ID: <1490297656-31068-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35334 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751467AbdCWTkH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 15:40:07 -0400
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

v3->v4: Store and use read once result instead of querying pointer
again incorrectly.

v4->v5: Refactor to avoid errors due to compilation with IPV6={m,n}

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Suggested-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Tom Herbert <tom@herbertland.com>
Cc: David Miller <davem@davemloft.net>
---
 Documentation/networking/ip-sysctl.txt | 11 +++++-
 include/net/netns/ipv4.h               |  2 +
 include/net/protocol.h                 |  7 ++--
 include/net/udp.h                      |  1 +
 net/ipv4/af_inet.c                     |  8 +++-
 net/ipv4/ip_input.c                    |  5 ++-
 net/ipv4/protocol.c                    |  2 +-
 net/ipv4/sysctl_net_ipv4.c             | 67 ++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_input.c                   |  6 ++-
 net/ipv6/protocol.c                    |  2 +-
 net/ipv6/tcp_ipv6.c                    |  3 +-
 net/ipv6/udp.c                         |  3 +-
 12 files changed, 103 insertions(+), 14 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index eaee2c8..b1c6500 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -856,12 +856,21 @@ ip_dynaddr - BOOLEAN
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
index a0e8919..cd686c4 100644
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
diff --git a/include/net/protocol.h b/include/net/protocol.h
index bf36ca3..65ba335 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -40,6 +40,7 @@
 /* This is used to register protocols. */
 struct net_protocol {
 	void			(*early_demux)(struct sk_buff *skb);
+	void                    (*early_demux_handler)(struct sk_buff *skb);
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	unsigned int		no_policy:1,
@@ -54,7 +55,7 @@ struct net_protocol {
 #if IS_ENABLED(CONFIG_IPV6)
 struct inet6_protocol {
 	void	(*early_demux)(struct sk_buff *skb);
-
+	void    (*early_demux_handler)(struct sk_buff *skb);
 	int	(*handler)(struct sk_buff *skb);
 
 	void	(*err_handler)(struct sk_buff *skb,
@@ -92,12 +93,12 @@ struct inet_protosw {
 #define INET_PROTOSW_PERMANENT 0x02  /* Permanent protocols are unremovable. */
 #define INET_PROTOSW_ICSK      0x04  /* Is this an inet_connection_sock? */
 
-extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
+extern struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
 extern const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS];
 extern const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS];
 
 #if IS_ENABLED(CONFIG_IPV6)
-extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
+extern struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
 #endif
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char num);
diff --git a/include/net/udp.h b/include/net/udp.h
index c9d8b8e..3391dbd 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -372,4 +372,5 @@ struct udp_iter_state {
 #if IS_ENABLED(CONFIG_IPV6)
 void udpv6_encap_enable(void);
 #endif
+
 #endif	/* _UDP_H */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6b1fc6e..d1a1170 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1599,8 +1599,9 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 };
 #endif
 
-static const struct net_protocol tcp_protocol = {
+static struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
+	.early_demux_handler =  tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
 	.err_handler	=	tcp_v4_err,
 	.no_policy	=	1,
@@ -1608,8 +1609,9 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	.icmp_strict_tag_validation = 1,
 };
 
-static const struct net_protocol udp_protocol = {
+static struct net_protocol udp_protocol = {
 	.early_demux =	udp_v4_early_demux,
+	.early_demux_handler =	udp_v4_early_demux,
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
 	.no_policy =	1,
@@ -1720,6 +1722,8 @@ static __net_init int inet_init_net(struct net *net)
 	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
 	net->ipv4.sysctl_ip_dynaddr = 0;
 	net->ipv4.sysctl_ip_early_demux = 1;
+	net->ipv4.sysctl_udp_early_demux = 1;
+	net->ipv4.sysctl_tcp_early_demux = 1;
 #ifdef CONFIG_SYSCTL
 	net->ipv4.sysctl_ip_prot_sock = PROT_SOCK;
 #endif
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d6feabb..fa2dc8f 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -313,6 +313,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct net_device *dev = skb->dev;
+	void (*edemux)(struct sk_buff *skb);
 
 	/* if ingress device is enslaved to an L3 master device pass the
 	 * skb to its handler for processing
@@ -329,8 +330,8 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		int protocol = iph->protocol;
 
 		ipprot = rcu_dereference(inet_protos[protocol]);
-		if (ipprot && ipprot->early_demux) {
-			ipprot->early_demux(skb);
+		if (ipprot && (edemux = READ_ONCE(ipprot->early_demux))) {
+			edemux(skb);
 			/* must reload iph, skb->head might have changed */
 			iph = ip_hdr(skb);
 		}
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 4b7c0ec..32a691b 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -28,7 +28,7 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
-const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
+struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
 const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
 EXPORT_SYMBOL(inet_offloads);
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 711c3e2..6fb2569 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -24,6 +24,7 @@
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>
 #include <net/ping.h>
+#include <net/protocol.h>
 
 static int zero;
 static int one = 1;
@@ -294,6 +295,58 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static void proc_configure_early_demux(int enabled, int protocol)
+{
+	struct net_protocol *ipprot;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct inet6_protocol *ip6prot;
+#endif
+
+	ipprot = rcu_dereference(inet_protos[protocol]);
+	if (ipprot)
+		ipprot->early_demux = enabled ? ipprot->early_demux_handler :
+						NULL;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	ip6prot = rcu_dereference(inet6_protos[protocol]);
+	if (ip6prot)
+		ip6prot->early_demux = enabled ? ip6prot->early_demux_handler :
+						 NULL;
+#endif
+}
+
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
+		proc_configure_early_demux(enabled, IPPROTO_TCP);
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
+		proc_configure_early_demux(enabled, IPPROTO_UDP);
+	}
+
+	return ret;
+}
+
 static struct ctl_table ipv4_table[] = {
 	{
 		.procname	= "tcp_timestamps",
@@ -750,6 +803,20 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
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
index aacfb4b..b04539d 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -49,6 +49,8 @@
 
 int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
+	void (*edemux)(struct sk_buff *skb);
+
 	/* if ingress device is enslaved to an L3 master device pass the
 	 * skb to its handler for processing
 	 */
@@ -60,8 +62,8 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		const struct inet6_protocol *ipprot;
 
 		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
-		if (ipprot && ipprot->early_demux)
-			ipprot->early_demux(skb);
+		if (ipprot && (edemux = READ_ONCE(ipprot->early_demux)))
+			edemux(skb);
 	}
 	if (!skb_valid_dst(skb))
 		ip6_route_input(skb);
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index e3770ab..b5d54d4 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -26,7 +26,7 @@
 #include <net/protocol.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
-const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS] __read_mostly;
+struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS] __read_mostly;
 EXPORT_SYMBOL(inet6_protos);
 
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0f08d71..031a8c0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1925,8 +1925,9 @@ struct proto tcpv6_prot = {
 	.diag_destroy		= tcp_abort,
 };
 
-static const struct inet6_protocol tcpv6_protocol = {
+static struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
+	.early_demux_handler =  tcp_v6_early_demux,
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 08a188f..b4a564e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1436,8 +1436,9 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
-static const struct inet6_protocol udpv6_protocol = {
+static struct inet6_protocol udpv6_protocol = {
 	.early_demux	=	udp_v6_early_demux,
+	.early_demux_handler =  udp_v6_early_demux,
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
-- 
1.9.1
