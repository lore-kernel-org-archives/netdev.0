From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/2] inet: make no_pmtu_disc per namespace and kill ipv4_config
Date: Sat, 14 Dec 2013 05:13:38 +0100
Message-ID: <20131214041329.GE7332@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54760 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab3LNENk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 23:13:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The other field in ipv4_config, log_martians, was converted to a
per-interface setting, so we can just remove the whole structure.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip.h           |  6 ------
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/af_inet.c         |  5 +----
 net/ipv4/icmp.c            |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/xfrm4_state.c     |  2 +-
 net/ipv6/af_inet6.c        |  2 +-
 7 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 5a25f36..5356644 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -177,12 +177,6 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 			   __be32 saddr, const struct ip_reply_arg *arg,
 			   unsigned int len);
 
-struct ipv4_config {
-	int	log_martians;
-	int	no_pmtu_disc;
-};
-
-extern struct ipv4_config ipv4_config;
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
 #define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
 #define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index ee520cb..929a668 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -69,6 +69,7 @@ struct netns_ipv4 {
 	struct local_ports sysctl_local_ports;
 
 	int sysctl_tcp_ecn;
+	int sysctl_ip_no_pmtu_disc;
 
 	kgid_t sysctl_ping_group_range[2];
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index ef4f9df..6b1193e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -126,9 +126,6 @@
 static struct list_head inetsw[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw_lock);
 
-struct ipv4_config ipv4_config;
-EXPORT_SYMBOL(ipv4_config);
-
 /* New destruction routine */
 
 void inet_sock_destruct(struct sock *sk)
@@ -342,7 +339,7 @@ lookup_protocol:
 			inet->hdrincl = 1;
 	}
 
-	if (ipv4_config.no_pmtu_disc)
+	if (net->ipv4.sysctl_ip_no_pmtu_disc)
 		inet->pmtudisc = IP_PMTUDISC_DONT;
 	else
 		inet->pmtudisc = IP_PMTUDISC_WANT;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5c0e8bc..1a4ee84 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -705,7 +705,7 @@ static void icmp_unreach(struct sk_buff *skb)
 		case ICMP_PORT_UNREACH:
 			break;
 		case ICMP_FRAG_NEEDED:
-			if (ipv4_config.no_pmtu_disc) {
+			if (net->ipv4.sysctl_ip_no_pmtu_disc) {
 				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
 					       &iph->daddr);
 			} else {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 38c8ec9..d7b63a6 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -286,13 +286,6 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &ip_ttl_max,
 	},
 	{
-		.procname	= "ip_no_pmtu_disc",
-		.data		= &ipv4_config.no_pmtu_disc,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "ip_nonlocal_bind",
 		.data		= &sysctl_ip_nonlocal_bind,
 		.maxlen		= sizeof(int),
@@ -831,6 +824,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_local_port_range,
 	},
+	{
+		.procname	= "ip_no_pmtu_disc",
+		.data		= &init_net.ipv4.sysctl_ip_no_pmtu_disc,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 0b2a064..542074c 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -16,7 +16,7 @@
 
 static int xfrm4_init_flags(struct xfrm_state *x)
 {
-	if (ipv4_config.no_pmtu_disc)
+	if (xs_net(x)->ipv4.sysctl_ip_no_pmtu_disc)
 		x->props.flags |= XFRM_STATE_NOPMTUDISC;
 	return 0;
 }
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 027615a..5e76dfa 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -213,7 +213,7 @@ lookup_protocol:
 	inet->mc_list	= NULL;
 	inet->rcv_tos	= 0;
 
-	if (ipv4_config.no_pmtu_disc)
+	if (net->ipv4.sysctl_ip_no_pmtu_disc)
 		inet->pmtudisc = IP_PMTUDISC_DONT;
 	else
 		inet->pmtudisc = IP_PMTUDISC_WANT;
-- 
1.8.3.1
