From: Vincent Bernat <bernat@luffy.cx>
Subject: [PATCH 2/2] net/ipv4: bind ip_nonlocal_bind to current netns
Date: Wed, 14 Dec 2011 17:20:48 +0100
Message-ID: <1323879648-419-3-git-send-email-bernat@luffy.cx>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Vincent Bernat <bernat@luffy.cx>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:39852 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755177Ab1LNQVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 11:21:05 -0500
In-Reply-To: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net.ipv4.ip_nonlocal_bind sysctl was global to all network
namespaces. This patch allows to set a different value for each
network namespace.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
---
 include/net/netns/ipv4.h   |    1 +
 net/ipv4/af_inet.c         |    6 +-----
 net/ipv4/ping.c            |    2 +-
 net/ipv4/sysctl_net_ipv4.c |   16 +++++++++-------
 net/ipv6/af_inet6.c        |    2 +-
 net/sctp/protocol.c        |    2 +-
 6 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index bbd023a..ad8587c 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -51,6 +51,7 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratelimit;
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
+	int sysctl_ip_nonlocal_bind;
 	int sysctl_rt_cache_rebuild_count;
 	int current_rt_cache_rebuild_count;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f7b5670..4fe4a7b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -443,10 +443,6 @@ int inet_release(struct socket *sock)
 }
 EXPORT_SYMBOL(inet_release);
 
-/* It is off by default, see below. */
-int sysctl_ip_nonlocal_bind __read_mostly;
-EXPORT_SYMBOL(sysctl_ip_nonlocal_bind);
-
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
@@ -485,7 +481,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	 *  is temporarily down)
 	 */
 	err = -EADDRNOTAVAIL;
-	if (!sysctl_ip_nonlocal_bind &&
+	if (!sock_net(sk)->ipv4.sysctl_ip_nonlocal_bind &&
 	    !(inet->freebind || inet->transparent) &&
 	    addr->sin_addr.s_addr != htonl(INADDR_ANY) &&
 	    chk_addr_ret != RTN_LOCAL &&
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 43d4c3b..01cf59d 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -257,7 +257,7 @@ static int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (addr->sin_addr.s_addr == INADDR_ANY)
 		chk_addr_ret = RTN_LOCAL;
 
-	if ((sysctl_ip_nonlocal_bind == 0 &&
+	if ((sock_net(sk)->ipv4.sysctl_ip_nonlocal_bind == 0 &&
 	    isk->freebind == 0 && isk->transparent == 0 &&
 	     chk_addr_ret != RTN_LOCAL) ||
 	    chk_addr_ret == RTN_MULTICAST ||
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fe9bf91..15e4534 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -265,13 +265,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "ip_nonlocal_bind",
-		.data		= &sysctl_ip_nonlocal_bind,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_syn_retries",
 		.data		= &sysctl_tcp_syn_retries,
 		.maxlen		= sizeof(int),
@@ -765,6 +758,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_tcp_mem,
 	},
+	{
+		.procname	= "ip_nonlocal_bind",
+		.data		= &init_net.ipv4.sysctl_ip_nonlocal_bind,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -802,6 +802,8 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			&net->ipv4.sysctl_rt_cache_rebuild_count;
 		table[7].data =
 			&net->ipv4.sysctl_ping_group_range;
+		table[9].data =
+			&net->ipv4.sysctl_ip_nonlocal_bind;
 
 	}
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 27c32f387..76b970d 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -307,7 +307,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		/* Reproduce AF_INET checks to make the bindings consistent */
 		v4addr = addr->sin6_addr.s6_addr32[3];
 		chk_addr_ret = inet_addr_type(net, v4addr);
-		if (!sysctl_ip_nonlocal_bind &&
+		if (!net->ipv4.sysctl_ip_nonlocal_bind &&
 		    !(inet->freebind || inet->transparent) &&
 		    v4addr != htonl(INADDR_ANY) &&
 		    chk_addr_ret != RTN_LOCAL &&
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 544a9b6..8c9c6bf 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -403,7 +403,7 @@ static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
 	if (addr->v4.sin_addr.s_addr != htonl(INADDR_ANY) &&
 	   ret != RTN_LOCAL &&
 	   !sp->inet.freebind &&
-	   !sysctl_ip_nonlocal_bind)
+	    !sock_net(sctp_opt2sk(sp))->ipv4.sysctl_ip_nonlocal_bind)
 		return 0;
 
 	if (ipv6_only_sock(sctp_opt2sk(sp)))
-- 
1.7.7.3
