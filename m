From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH] net/ipv4: bind ip_nonlocal_bind to current netns
Date: Fri,  5 Sep 2014 15:09:03 +0200
Message-ID: <1409922543-708-1-git-send-email-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:33714 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184AbaIENSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 09:18:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net.ipv4.ip_nonlocal_bind sysctl was global to all network
namespaces. This patch allows to set a different value for each
network namespace.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 include/net/ip.h           |  2 --
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/af_inet.c         |  6 +-----
 net/ipv4/ping.c            |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv6/af_inet6.c        |  2 +-
 net/sctp/protocol.c        |  2 +-
 7 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index c8fd6112bd0b..14bfc8e1bcf9 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -229,8 +229,6 @@ static inline int inet_is_local_reserved_port(struct net *net, int port)
 }
 #endif
 
-extern int sysctl_ip_nonlocal_bind;
-
 /* From inetpeer.c */
 extern int inet_peer_threshold;
 extern int inet_peer_minttl;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index aec5e12f9f19..24945cefc4fd 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -76,6 +76,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_ecn;
 	int sysctl_ip_no_pmtu_disc;
 	int sysctl_ip_fwd_use_pmtu;
+	int sysctl_ip_nonlocal_bind;
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d156b3c5f363..b537bd94906c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -418,10 +418,6 @@ int inet_release(struct socket *sock)
 }
 EXPORT_SYMBOL(inet_release);
 
-/* It is off by default, see below. */
-int sysctl_ip_nonlocal_bind __read_mostly;
-EXPORT_SYMBOL(sysctl_ip_nonlocal_bind);
-
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
@@ -461,7 +457,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	 *  is temporarily down)
 	 */
 	err = -EADDRNOTAVAIL;
-	if (!sysctl_ip_nonlocal_bind &&
+	if (!net->ipv4.sysctl_ip_nonlocal_bind &&
 	    !(inet->freebind || inet->transparent) &&
 	    addr->sin_addr.s_addr != htonl(INADDR_ANY) &&
 	    chk_addr_ret != RTN_LOCAL &&
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index a3c59a077a5f..57f7c9804139 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -311,7 +311,7 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 		if (addr->sin_addr.s_addr == htonl(INADDR_ANY))
 			chk_addr_ret = RTN_LOCAL;
 
-		if ((sysctl_ip_nonlocal_bind == 0 &&
+		if ((net->ipv4.sysctl_ip_nonlocal_bind == 0 &&
 		    isk->freebind == 0 && isk->transparent == 0 &&
 		     chk_addr_ret != RTN_LOCAL) ||
 		    chk_addr_ret == RTN_MULTICAST ||
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 45d156dacd61..1599966f4639 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -286,13 +286,6 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &ip_ttl_max,
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
@@ -849,6 +842,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "ip_nonlocal_bind",
+		.data		= &init_net.ipv4.sysctl_ip_nonlocal_bind,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "fwmark_reflect",
 		.data		= &init_net.ipv4.sysctl_fwmark_reflect,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b9393e6a21fe..e4865a3ebe1d 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -302,7 +302,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		/* Reproduce AF_INET checks to make the bindings consistent */
 		v4addr = addr->sin6_addr.s6_addr32[3];
 		chk_addr_ret = inet_addr_type(net, v4addr);
-		if (!sysctl_ip_nonlocal_bind &&
+		if (!net->ipv4.sysctl_ip_nonlocal_bind &&
 		    !(inet->freebind || inet->transparent) &&
 		    v4addr != htonl(INADDR_ANY) &&
 		    chk_addr_ret != RTN_LOCAL &&
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 6240834f4b95..9d2c6c9facb6 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -366,7 +366,7 @@ static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
 	if (addr->v4.sin_addr.s_addr != htonl(INADDR_ANY) &&
 	   ret != RTN_LOCAL &&
 	   !sp->inet.freebind &&
-	   !sysctl_ip_nonlocal_bind)
+	   !net->ipv4.sysctl_ip_nonlocal_bind)
 		return 0;
 
 	if (ipv6_only_sock(sctp_opt2sk(sp)))
-- 
2.1.0
