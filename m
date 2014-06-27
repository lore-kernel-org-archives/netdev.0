From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: move ipv6only in sock_common
Date: Fri, 27 Jun 2014 08:36:16 -0700
Message-ID: <1403883376.15139.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:55960 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbaF0PgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:36:20 -0400
Received: by mail-wi0-f170.google.com with SMTP id cc10so2932204wib.1
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 08:36:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When an UDP application switches from AF_INET to AF_INET6 sockets, we
have a small performance degradation for IPv4 communications because of
extra cache line misses to access ipv6only information.

This can also be noticed for TCP listeners, as ipv6_only_sock() is also
used from __inet_lookup_listener()->compute_score()

This is magnified when SO_REUSEPORT is used.

Move ipv6only into struct sock_common so that it is available at
no extra cost in lookups.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/ipv6.h             |   10 +++++-----
 include/net/inet_timewait_sock.h |    3 ++-
 include/net/sock.h               |    4 +++-
 net/dccp/minisocks.c             |    4 +---
 net/ipv4/tcp_minisocks.c         |    2 +-
 net/ipv6/af_inet6.c              |    6 +++---
 net/ipv6/ipv6_sockglue.c         |    4 ++--
 net/ipv6/udp.c                   |    3 +--
 8 files changed, 18 insertions(+), 18 deletions(-)
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2faef339d8f2..33dc081c8068 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -193,7 +193,7 @@ struct ipv6_pinfo {
 	                        sndflow:1,
 				repflow:1,
 				pmtudisc:3,
-				ipv6only:1,
+				padding:1,	/* 1 bit hole */
 				srcprefs:3,	/* 001: prefer temporary address
 						 * 010: prefer public address
 						 * 100: prefer care-of address
@@ -282,8 +282,8 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 	__inet_sk_copy_descendant(sk_to, sk_from, ancestor_size);
 }
 
-#define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
-#define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
+#define __ipv6_only_sock(sk)	(sk->sk_ipv6only)
+#define ipv6_only_sock(sk)	(__ipv6_only_sock(sk))
 #define ipv6_sk_rxinfo(sk)	((sk)->sk_family == PF_INET6 && \
 				 inet6_sk(sk)->rxopt.bits.rxinfo)
 
@@ -296,8 +296,8 @@ static inline const struct in6_addr *inet6_rcv_saddr(const struct sock *sk)
 
 static inline int inet_v6_ipv6only(const struct sock *sk)
 {
-	return likely(sk->sk_state != TCP_TIME_WAIT) ?
-		ipv6_only_sock(sk) : inet_twsk(sk)->tw_ipv6only;
+	/* ipv6only field is at same position for timewait and other sockets */
+	return ipv6_only_sock(sk);
 }
 #else
 #define __ipv6_only_sock(sk)	0
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 61474ea02152..6c566034e26d 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -108,6 +108,7 @@ struct inet_timewait_sock {
 #define tw_family		__tw_common.skc_family
 #define tw_state		__tw_common.skc_state
 #define tw_reuse		__tw_common.skc_reuse
+#define tw_ipv6only		__tw_common.skc_ipv6only
 #define tw_bound_dev_if		__tw_common.skc_bound_dev_if
 #define tw_node			__tw_common.skc_nulls_node
 #define tw_bind_node		__tw_common.skc_bind_node
@@ -131,7 +132,7 @@ struct inet_timewait_sock {
 	__be16			tw_sport;
 	kmemcheck_bitfield_begin(flags);
 	/* And these are ours. */
-	unsigned int		tw_ipv6only     : 1,
+	unsigned int		tw_pad0		: 1,	/* 1 bit hole */
 				tw_transparent  : 1,
 				tw_flowlabel	: 20,
 				tw_pad		: 2,	/* 2 bits hole */
diff --git a/include/net/sock.h b/include/net/sock.h
index 173cae485de1..8d4c9473e7d7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -181,7 +181,8 @@ struct sock_common {
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse:4;
-	unsigned char		skc_reuseport:4;
+	unsigned char		skc_reuseport:1;
+	unsigned char		skc_ipv6only:1;
 	int			skc_bound_dev_if;
 	union {
 		struct hlist_node	skc_bind_node;
@@ -317,6 +318,7 @@ struct sock {
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_reuseport		__sk_common.skc_reuseport
+#define sk_ipv6only		__sk_common.skc_ipv6only
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index c69eb9c4fbb8..b50dc436db1f 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -55,11 +55,9 @@ void dccp_time_wait(struct sock *sk, int state, int timeo)
 		const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
-			const struct ipv6_pinfo *np = inet6_sk(sk);
-
 			tw->tw_v6_daddr = sk->sk_v6_daddr;
 			tw->tw_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
-			tw->tw_ipv6only = np->ipv6only;
+			tw->tw_ipv6only = sk->sk_ipv6only;
 		}
 #endif
 		/* Linkage updates. */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e68e0d4af6c9..1649988bd1b6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -298,7 +298,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			tw->tw_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 			tw->tw_tclass = np->tclass;
 			tw->tw_flowlabel = np->flow_label >> 12;
-			tw->tw_ipv6only = np->ipv6only;
+			tw->tw_ipv6only = sk->sk_ipv6only;
 		}
 #endif
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7cb4392690dd..a426cd7099bb 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -197,7 +197,7 @@ lookup_protocol:
 	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
-	np->ipv6only	= net->ipv6.sysctl.bindv6only;
+	sk->sk_ipv6only	= net->ipv6.sysctl.bindv6only;
 
 	/* Init the ipv4 part of the socket since we can have sockets
 	 * using v6 API for ipv4.
@@ -294,7 +294,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		/* Binding to v4-mapped address on a v6-only socket
 		 * makes no sense
 		 */
-		if (np->ipv6only) {
+		if (sk->sk_ipv6only) {
 			err = -EINVAL;
 			goto out;
 		}
@@ -371,7 +371,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr_type != IPV6_ADDR_ANY) {
 		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
 		if (addr_type != IPV6_ADDR_MAPPED)
-			np->ipv6only = 1;
+			sk->sk_ipv6only = 1;
 	}
 	if (snum)
 		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index edb58aff4ae7..cc34f65179e4 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -235,7 +235,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		if (optlen < sizeof(int) ||
 		    inet_sk(sk)->inet_num)
 			goto e_inval;
-		np->ipv6only = valbool;
+		sk->sk_ipv6only = valbool;
 		retv = 0;
 		break;
 
@@ -1058,7 +1058,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	}
 
 	case IPV6_V6ONLY:
-		val = np->ipv6only;
+		val = sk->sk_ipv6only;
 		break;
 
 	case IPV6_RECVPKTINFO:
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 95c834799288..c2bd28fd43e4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -79,7 +79,6 @@ static unsigned int udp6_ehashfn(struct net *net,
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
-	int sk_ipv6only = ipv6_only_sock(sk);
 	int sk2_ipv6only = inet_v6_ipv6only(sk2);
 	int addr_type = ipv6_addr_type(&sk->sk_v6_rcv_saddr);
 	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
@@ -95,7 +94,7 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 		return 1;
 
 	if (addr_type == IPV6_ADDR_ANY &&
-	    !(sk_ipv6only && addr_type2 == IPV6_ADDR_MAPPED))
+	    !(ipv6_only_sock(sk) && addr_type2 == IPV6_ADDR_MAPPED))
 		return 1;
 
 	if (sk2_rcv_saddr6 &&
