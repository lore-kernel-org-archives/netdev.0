From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] ipv6: make lookups simpler and faster
Date: Thu, 03 Oct 2013 15:42:29 -0700
Message-ID: <1380840149.19002.256.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f169.google.com ([209.85.213.169]:40888 "EHLO
	mail-ye0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113Ab3JCWme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 18:42:34 -0400
Received: by mail-ye0-f169.google.com with SMTP id r13so809752yen.28
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 15:42:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP listener refactoring, part 4 :

To speed up inet lookups, we moved IPv4 addresses from inet to struct
sock_common

Now is time to do the same for IPv6, because it permits us to have fast
lookups for all kind of sockets, including upcoming SYN_RECV.

Getting IPv6 addresses in TCP lookups currently requires two extra cache
lines, plus a dereference (and memory stall).

inet6_sk(sk) does the dereference of inet_sk(__sk)->pinet6

This patch is way bigger than its IPv4 counter part, because for IPv4,
we could add aliases (inet_daddr, inet_rcv_saddr), while on IPv6,
it's not doable easily.

inet6_sk(sk)->daddr becomes sk->sk_v6_daddr
inet6_sk(sk)->rcv_saddr becomes sk->sk_v6_rcv_saddr

And timewait socket also have tw->tw_v6_daddr & tw->tw_v6_rcv_saddr
at the same offset.

We get rid of INET6_TW_MATCH() as INET6_MATCH() is now the generic
macro.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/ipv6.h                           |   46 +----------
 include/net/inet6_hashtables.h                 |    5 -
 include/net/inet_timewait_sock.h               |    4 -
 include/net/ip.h                               |    2 
 include/net/ip6_checksum.h                     |    2 
 include/net/sock.h                             |    9 ++
 net/dccp/ipv6.c                                |   24 +++---
 net/dccp/ipv6.h                                |    1 
 net/dccp/minisocks.c                           |    7 -
 net/ipv4/inet_diag.c                           |   35 +++------
 net/ipv4/ping.c                                |   15 +--
 net/ipv4/tcp_metrics.c                         |   10 +-
 net/ipv4/tcp_minisocks.c                       |    7 -
 net/ipv4/tcp_probe.c                           |   29 ++-----
 net/ipv4/tcp_timer.c                           |    3 
 net/ipv6/af_inet6.c                            |   10 +-
 net/ipv6/datagram.c                            |   25 +++---
 net/ipv6/inet6_connection_sock.c               |    7 -
 net/ipv6/inet6_hashtables.c                    |   58 ++++-----------
 net/ipv6/ipv6_sockglue.c                       |    7 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 -
 net/ipv6/ping.c                                |    2 
 net/ipv6/raw.c                                 |   17 ++--
 net/ipv6/tcp_ipv6.c                            |   44 +++++------
 net/ipv6/udp.c                                 |   48 +++++-------
 net/l2tp/l2tp_core.c                           |    4 -
 net/l2tp/l2tp_debugfs.c                        |    5 -
 net/l2tp/l2tp_ip6.c                            |   16 ++--
 net/l2tp/l2tp_netlink.c                        |    4 -
 net/l2tp/l2tp_ppp.c                            |   12 +--
 net/netfilter/xt_TPROXY.c                      |    2 
 net/netfilter/xt_socket.c                      |    2 
 net/sctp/ipv6.c                                |   22 ++---
 net/sunrpc/svcsock.c                           |    2 
 security/lsm_audit.c                           |    5 -
 35 files changed, 210 insertions(+), 285 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index b7f1f3b..35f6c1b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -141,8 +141,6 @@ struct ipv6_fl_socklist;
  */
 struct ipv6_pinfo {
 	struct in6_addr 	saddr;
-	struct in6_addr 	rcv_saddr;
-	struct in6_addr		daddr;
 	struct in6_pktinfo	sticky_pktinfo;
 	const struct in6_addr		*daddr_cache;
 #ifdef CONFIG_IPV6_SUBTREES
@@ -256,22 +254,10 @@ struct tcp6_sock {
 
 extern int inet6_sk_rebuild_header(struct sock *sk);
 
-struct inet6_timewait_sock {
-	struct in6_addr tw_v6_daddr;
-	struct in6_addr	tw_v6_rcv_saddr;
-};
-
 struct tcp6_timewait_sock {
 	struct tcp_timewait_sock   tcp6tw_tcp;
-	struct inet6_timewait_sock tcp6tw_inet6;
 };
 
-static inline struct inet6_timewait_sock *inet6_twsk(const struct sock *sk)
-{
-	return (struct inet6_timewait_sock *)(((u8 *)sk) +
-					      inet_twsk(sk)->tw_ipv6_offset);
-}
-
 #if IS_ENABLED(CONFIG_IPV6)
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
@@ -321,21 +307,11 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
 #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
 
-static inline u16 inet6_tw_offset(const struct proto *prot)
-{
-	return prot->twsk_prot->twsk_obj_size -
-			sizeof(struct inet6_timewait_sock);
-}
-
-static inline struct in6_addr *__inet6_rcv_saddr(const struct sock *sk)
+static inline const struct in6_addr *inet6_rcv_saddr(const struct sock *sk)
 {
-	return likely(sk->sk_state != TCP_TIME_WAIT) ?
-		&inet6_sk(sk)->rcv_saddr : &inet6_twsk(sk)->tw_v6_rcv_saddr;
-}
-
-static inline struct in6_addr *inet6_rcv_saddr(const struct sock *sk)
-{
-	return sk->sk_family == AF_INET6 ? __inet6_rcv_saddr(sk) : NULL;
+	if (sk->sk_family == AF_INET6)
+		return &sk->sk_v6_rcv_saddr;
+	return NULL;
 }
 
 static inline int inet_v6_ipv6only(const struct sock *sk)
@@ -363,7 +339,6 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 	return NULL;
 }
 
-#define __inet6_rcv_saddr(__sk)	NULL
 #define inet6_rcv_saddr(__sk)	NULL
 #define tcp_twsk_ipv6only(__sk)		0
 #define inet_v6_ipv6only(__sk)		0
@@ -372,19 +347,10 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
 	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_family == AF_INET6)			&&	\
-	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&&	\
-	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&&	\
+	 ipv6_addr_equal(&(__sk)->sk_v6_daddr, (__saddr))		&&	\
+	 ipv6_addr_equal(&(__sk)->sk_v6_rcv_saddr, (__daddr))	&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
 	   ((__sk)->sk_bound_dev_if == (__dif))) 		&&	\
 	 net_eq(sock_net(__sk), (__net)))
 
-#define INET6_TW_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	   \
-	(((__sk)->sk_portpair == (__ports))				&& \
-	 ((__sk)->sk_family == AF_INET6)				&& \
-	 ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr))	&& \
-	 ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr)) && \
-	 (!(__sk)->sk_bound_dev_if	||				   \
-	  ((__sk)->sk_bound_dev_if == (__dif)))				&& \
-	 net_eq(sock_net(__sk), (__net)))
-
 #endif /* _IPV6_H */
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index f52fa88..a105d1a 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -43,9 +43,8 @@ static inline unsigned int inet6_ehashfn(struct net *net,
 static inline int inet6_sk_ehashfn(const struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	const struct ipv6_pinfo *np = inet6_sk(sk);
-	const struct in6_addr *laddr = &np->rcv_saddr;
-	const struct in6_addr *faddr = &np->daddr;
+	const struct in6_addr *laddr = &sk->sk_v6_rcv_saddr;
+	const struct in6_addr *faddr = &sk->sk_v6_daddr;
 	const __u16 lport = inet->inet_num;
 	const __be16 fport = inet->inet_dport;
 	struct net *net = sock_net(sk);
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index de9e3ab..b647c62 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -116,7 +116,9 @@ struct inet_timewait_sock {
 #define tw_prot			__tw_common.skc_prot
 #define tw_net			__tw_common.skc_net
 #define tw_daddr        	__tw_common.skc_daddr
+#define tw_v6_daddr		__tw_common.skc_v6_daddr
 #define tw_rcv_saddr    	__tw_common.skc_rcv_saddr
+#define tw_v6_rcv_saddr    	__tw_common.skc_v6_rcv_saddr
 #define tw_dport		__tw_common.skc_dport
 #define tw_num			__tw_common.skc_num
 
@@ -133,7 +135,7 @@ struct inet_timewait_sock {
 				tw_transparent  : 1,
 				tw_pad		: 6,	/* 6 bits hole */
 				tw_tos		: 8,
-				tw_ipv6_offset  : 16;
+				tw_pad2		: 16 /* 16 bits hole */
 	kmemcheck_bitfield_end(flags);
 	u32			tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
diff --git a/include/net/ip.h b/include/net/ip.h
index 16078f4..993336b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -374,7 +374,7 @@ static __inline__ void inet_reset_saddr(struct sock *sk)
 		struct ipv6_pinfo *np = inet6_sk(sk);
 
 		memset(&np->saddr, 0, sizeof(np->saddr));
-		memset(&np->rcv_saddr, 0, sizeof(np->rcv_saddr));
+		memset(&sk->sk_v6_rcv_saddr, 0, sizeof(sk->sk_v6_rcv_saddr));
 	}
 #endif
 }
diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 7686e3f..1944406 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -70,7 +70,7 @@ static inline void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 
-	__tcp_v6_send_check(skb, &np->saddr, &np->daddr);
+	__tcp_v6_send_check(skb, &np->saddr, &sk->sk_v6_daddr);
 }
 
 int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
diff --git a/include/net/sock.h b/include/net/sock.h
index ef80ea5..96dd429 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -191,6 +191,12 @@ struct sock_common {
 #ifdef CONFIG_NET_NS
 	struct net	 	*skc_net;
 #endif
+
+#if IS_ENABLED(CONFIG_IPV6)
+	struct in6_addr		skc_v6_daddr;
+	struct in6_addr		skc_v6_rcv_saddr;
+#endif
+
 	/*
 	 * fields between dontcopy_begin/dontcopy_end
 	 * are not copied in sock_copy()
@@ -314,6 +320,9 @@ struct sock {
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
 #define sk_net			__sk_common.skc_net
+#define sk_v6_daddr		__sk_common.skc_v6_daddr
+#define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
+
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
 	/*
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6cf9f77..7f075b8 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -67,7 +67,7 @@ static inline void dccp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 	struct dccp_hdr *dh = dccp_hdr(skb);
 
 	dccp_csum_outgoing(skb);
-	dh->dccph_checksum = dccp_v6_csum_finish(skb, &np->saddr, &np->daddr);
+	dh->dccph_checksum = dccp_v6_csum_finish(skb, &np->saddr, &sk->sk_v6_daddr);
 }
 
 static inline __u64 dccp_v6_init_sequence(struct sk_buff *skb)
@@ -467,11 +467,11 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newnp->daddr);
+		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
 
 		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
 
-		newnp->rcv_saddr = newnp->saddr;
+		newsk->sk_v6_rcv_saddr = newnp->saddr;
 
 		inet_csk(newsk)->icsk_af_ops = &dccp_ipv6_mapped;
 		newsk->sk_backlog_rcv = dccp_v4_do_rcv;
@@ -538,9 +538,9 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-	newnp->daddr = ireq6->rmt_addr;
+	newsk->sk_v6_daddr = ireq6->rmt_addr;
 	newnp->saddr = ireq6->loc_addr;
-	newnp->rcv_saddr = ireq6->loc_addr;
+	newsk->sk_v6_rcv_saddr = ireq6->loc_addr;
 	newsk->sk_bound_dev_if = ireq6->iif;
 
 	/* Now IPv6 options...
@@ -885,7 +885,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			return -EINVAL;
 	}
 
-	np->daddr = usin->sin6_addr;
+	sk->sk_v6_daddr = usin->sin6_addr;
 	np->flow_label = fl6.flowlabel;
 
 	/*
@@ -915,16 +915,16 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			goto failure;
 		}
 		ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
-		ipv6_addr_set_v4mapped(inet->inet_rcv_saddr, &np->rcv_saddr);
+		ipv6_addr_set_v4mapped(inet->inet_rcv_saddr, &sk->sk_v6_rcv_saddr);
 
 		return err;
 	}
 
-	if (!ipv6_addr_any(&np->rcv_saddr))
-		saddr = &np->rcv_saddr;
+	if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr))
+		saddr = &sk->sk_v6_rcv_saddr;
 
 	fl6.flowi6_proto = IPPROTO_DCCP;
-	fl6.daddr = np->daddr;
+	fl6.daddr = sk->sk_v6_daddr;
 	fl6.saddr = saddr ? *saddr : np->saddr;
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.fl6_dport = usin->sin6_port;
@@ -941,7 +941,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	if (saddr == NULL) {
 		saddr = &fl6.saddr;
-		np->rcv_saddr = *saddr;
+		sk->sk_v6_rcv_saddr = *saddr;
 	}
 
 	/* set the source address */
@@ -963,7 +963,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		goto late_failure;
 
 	dp->dccps_iss = secure_dccpv6_sequence_number(np->saddr.s6_addr32,
-						      np->daddr.s6_addr32,
+						      sk->sk_v6_daddr.s6_addr32,
 						      inet->inet_sport,
 						      inet->inet_dport);
 	err = dccp_connect(sk);
diff --git a/net/dccp/ipv6.h b/net/dccp/ipv6.h
index 6eef81f..6604fc3 100644
--- a/net/dccp/ipv6.h
+++ b/net/dccp/ipv6.h
@@ -30,7 +30,6 @@ struct dccp6_request_sock {
 
 struct dccp6_timewait_sock {
 	struct inet_timewait_sock   inet;
-	struct inet6_timewait_sock  tw6;
 };
 
 #endif /* _DCCP_IPV6_H */
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 662071b..32e80d9 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -56,12 +56,9 @@ void dccp_time_wait(struct sock *sk, int state, int timeo)
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
 			const struct ipv6_pinfo *np = inet6_sk(sk);
-			struct inet6_timewait_sock *tw6;
 
-			tw->tw_ipv6_offset = inet6_tw_offset(sk->sk_prot);
-			tw6 = inet6_twsk((struct sock *)tw);
-			tw6->tw_v6_daddr = np->daddr;
-			tw6->tw_v6_rcv_saddr = np->rcv_saddr;
+			tw->tw_v6_daddr = sk->sk_v6_daddr;
+			tw->tw_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 			tw->tw_ipv6only = np->ipv6only;
 		}
 #endif
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 8e1e406..ecc179d 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -121,13 +121,13 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
-		const struct ipv6_pinfo *np = inet6_sk(sk);
 
-		*(struct in6_addr *)r->id.idiag_src = np->rcv_saddr;
-		*(struct in6_addr *)r->id.idiag_dst = np->daddr;
+		*(struct in6_addr *)r->id.idiag_src = sk->sk_v6_rcv_saddr;
+		*(struct in6_addr *)r->id.idiag_dst = sk->sk_v6_daddr;
 
 		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
-			if (nla_put_u8(skb, INET_DIAG_TCLASS, np->tclass) < 0)
+			if (nla_put_u8(skb, INET_DIAG_TCLASS,
+				       inet6_sk(sk)->tclass) < 0)
 				goto errout;
 	}
 #endif
@@ -255,11 +255,8 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->idiag_inode	      = 0;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (tw->tw_family == AF_INET6) {
-		const struct inet6_timewait_sock *tw6 =
-						inet6_twsk((struct sock *)tw);
-
-		*(struct in6_addr *)r->id.idiag_src = tw6->tw_v6_rcv_saddr;
-		*(struct in6_addr *)r->id.idiag_dst = tw6->tw_v6_daddr;
+		*(struct in6_addr *)r->id.idiag_src = tw->tw_v6_rcv_saddr;
+		*(struct in6_addr *)r->id.idiag_dst = tw->tw_v6_daddr;
 	}
 #endif
 
@@ -273,10 +270,11 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			const struct nlmsghdr *unlh)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
-		return inet_twsk_diag_fill((struct inet_timewait_sock *)sk,
-					   skb, r, portid, seq, nlmsg_flags,
-					   unlh);
-	return inet_csk_diag_fill(sk, skb, r, user_ns, portid, seq, nlmsg_flags, unlh);
+		return inet_twsk_diag_fill(inet_twsk(sk), skb, r, portid, seq,
+					   nlmsg_flags, unlh);
+
+	return inet_csk_diag_fill(sk, skb, r, user_ns, portid, seq,
+				  nlmsg_flags, unlh);
 }
 
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
@@ -489,10 +487,9 @@ int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 	entry.family = sk->sk_family;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (entry.family == AF_INET6) {
-		struct ipv6_pinfo *np = inet6_sk(sk);
 
-		entry.saddr = np->rcv_saddr.s6_addr32;
-		entry.daddr = np->daddr.s6_addr32;
+		entry.saddr = sk->sk_v6_rcv_saddr.s6_addr32;
+		entry.daddr = sk->sk_v6_daddr.s6_addr32;
 	} else
 #endif
 	{
@@ -649,10 +646,8 @@ static int inet_twsk_diag_dump(struct sock *sk,
 		entry.family = tw->tw_family;
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == AF_INET6) {
-			struct inet6_timewait_sock *tw6 =
-						inet6_twsk((struct sock *)tw);
-			entry.saddr = tw6->tw_v6_rcv_saddr.s6_addr32;
-			entry.daddr = tw6->tw_v6_daddr.s6_addr32;
+			entry.saddr = tw->tw_v6_rcv_saddr.s6_addr32;
+			entry.daddr = tw->tw_v6_daddr.s6_addr32;
 		} else
 #endif
 		{
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index a626104..ccefc07 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -202,15 +202,14 @@ static struct sock *ping_lookup(struct net *net, struct sk_buff *skb, u16 ident)
 #if IS_ENABLED(CONFIG_IPV6)
 		} else if (skb->protocol == htons(ETH_P_IPV6) &&
 			   sk->sk_family == AF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(sk);
 
 			pr_debug("found: %p: num=%d, daddr=%pI6c, dif=%d\n", sk,
 				 (int) isk->inet_num,
-				 &inet6_sk(sk)->rcv_saddr,
+				 &sk->sk_v6_rcv_saddr,
 				 sk->sk_bound_dev_if);
 
-			if (!ipv6_addr_any(&np->rcv_saddr) &&
-			    !ipv6_addr_equal(&np->rcv_saddr,
+			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr) &&
+			    !ipv6_addr_equal(&sk->sk_v6_rcv_saddr,
 					     &ipv6_hdr(skb)->daddr))
 				continue;
 #endif
@@ -362,7 +361,7 @@ static void ping_set_saddr(struct sock *sk, struct sockaddr *saddr)
 	} else if (saddr->sa_family == AF_INET6) {
 		struct sockaddr_in6 *addr = (struct sockaddr_in6 *) saddr;
 		struct ipv6_pinfo *np = inet6_sk(sk);
-		np->rcv_saddr = np->saddr = addr->sin6_addr;
+		sk->sk_v6_rcv_saddr = np->saddr = addr->sin6_addr;
 #endif
 	}
 }
@@ -376,7 +375,7 @@ static void ping_clear_saddr(struct sock *sk, int dif)
 #if IS_ENABLED(CONFIG_IPV6)
 	} else if (sk->sk_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
-		memset(&np->rcv_saddr, 0, sizeof(np->rcv_saddr));
+		memset(&sk->sk_v6_rcv_saddr, 0, sizeof(sk->sk_v6_rcv_saddr));
 		memset(&np->saddr, 0, sizeof(np->saddr));
 #endif
 	}
@@ -418,7 +417,7 @@ int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	err = 0;
 	if ((sk->sk_family == AF_INET && isk->inet_rcv_saddr) ||
 	    (sk->sk_family == AF_INET6 &&
-	     !ipv6_addr_any(&inet6_sk(sk)->rcv_saddr)))
+	     !ipv6_addr_any(&sk->sk_v6_rcv_saddr)))
 		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
 
 	if (snum)
@@ -429,7 +428,7 @@ int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == AF_INET6)
-		memset(&inet6_sk(sk)->daddr, 0, sizeof(inet6_sk(sk)->daddr));
+		memset(&sk->sk_v6_daddr, 0, sizeof(sk->sk_v6_daddr));
 #endif
 
 	sk_dst_reset(sk);
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 52f3c6b..27535fd 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -240,7 +240,6 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 
 static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock *tw)
 {
-	struct inet6_timewait_sock *tw6;
 	struct tcp_metrics_block *tm;
 	struct inetpeer_addr addr;
 	unsigned int hash;
@@ -253,9 +252,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 		hash = (__force unsigned int) addr.addr.a4;
 		break;
 	case AF_INET6:
-		tw6 = inet6_twsk((struct sock *)tw);
-		*(struct in6_addr *)addr.addr.a6 = tw6->tw_v6_daddr;
-		hash = ipv6_addr_hash(&tw6->tw_v6_daddr);
+		*(struct in6_addr *)addr.addr.a6 = tw->tw_v6_daddr;
+		hash = ipv6_addr_hash(&tw->tw_v6_daddr);
 		break;
 	default:
 		return NULL;
@@ -289,8 +287,8 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 		hash = (__force unsigned int) addr.addr.a4;
 		break;
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = inet6_sk(sk)->daddr;
-		hash = ipv6_addr_hash(&inet6_sk(sk)->daddr);
+		*(struct in6_addr *)addr.addr.a6 = sk->sk_v6_daddr;
+		hash = ipv6_addr_hash(&sk->sk_v6_daddr);
 		break;
 	default:
 		return NULL;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 58a3e69..97b6841 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -293,12 +293,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
-			struct inet6_timewait_sock *tw6;
 
-			tw->tw_ipv6_offset = inet6_tw_offset(sk->sk_prot);
-			tw6 = inet6_twsk((struct sock *)tw);
-			tw6->tw_v6_daddr = np->daddr;
-			tw6->tw_v6_rcv_saddr = np->rcv_saddr;
+			tw->tw_v6_daddr = sk->sk_v6_daddr;
+			tw->tw_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 			tw->tw_tclass = np->tclass;
 			tw->tw_ipv6only = np->ipv6only;
 		}
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 611beab..8b97d71 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -101,22 +101,6 @@ static inline int tcp_probe_avail(void)
 		si4.sin_addr.s_addr = inet->inet_##mem##addr;	\
 	} while (0)						\
 
-#if IS_ENABLED(CONFIG_IPV6)
-#define tcp_probe_copy_fl_to_si6(inet, si6, mem)		\
-	do {							\
-		struct ipv6_pinfo *pi6 = inet->pinet6;		\
-		si6.sin6_family = AF_INET6;			\
-		si6.sin6_port = inet->inet_##mem##port;		\
-		si6.sin6_addr = pi6->mem##addr;			\
-		si6.sin6_flowinfo = 0; /* No need here. */	\
-		si6.sin6_scope_id = 0;	/* No need here. */	\
-	} while (0)
-#else
-#define tcp_probe_copy_fl_to_si6(fl, si6, mem)			\
-	do {							\
-		memset(&si6, 0, sizeof(si6));			\
-	} while (0)
-#endif
 
 /*
  * Hook inserted to be called before each receive packet.
@@ -147,8 +131,17 @@ static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				tcp_probe_copy_fl_to_si4(inet, p->dst.v4, d);
 				break;
 			case AF_INET6:
-				tcp_probe_copy_fl_to_si6(inet, p->src.v6, s);
-				tcp_probe_copy_fl_to_si6(inet, p->dst.v6, d);
+				memset(&p->src.v6, 0, sizeof(p->src.v6));
+				memset(&p->dst.v6, 0, sizeof(p->dst.v6));
+#if IS_ENABLED(CONFIG_IPV6)
+				p->src.v6.sin6_family = AF_INET6;
+				p->src.v6.sin6_port = inet->inet_sport;
+				p->src.v6.sin6_addr = inet6_sk(sk)->saddr;
+
+				p->dst.v6.sin6_family = AF_INET6;
+				p->dst.v6.sin6_port = inet->inet_dport;
+				p->dst.v6.sin6_addr = sk->sk_v6_daddr;
+#endif
 				break;
 			default:
 				BUG();
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 4b85e6f..af07b5b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -374,9 +374,8 @@ void tcp_retransmit_timer(struct sock *sk)
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (sk->sk_family == AF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(sk);
 			LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n"),
-				       &np->daddr,
+				       &sk->sk_v6_daddr,
 				       ntohs(inet->inet_dport), inet->inet_num,
 				       tp->snd_una, tp->snd_nxt);
 		}
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 4966b12..a2cb07c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -364,7 +364,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	inet->inet_rcv_saddr = v4addr;
 	inet->inet_saddr = v4addr;
 
-	np->rcv_saddr = addr->sin6_addr;
+	sk->sk_v6_rcv_saddr = addr->sin6_addr;
 
 	if (!(addr_type & IPV6_ADDR_MULTICAST))
 		np->saddr = addr->sin6_addr;
@@ -461,14 +461,14 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 		    peer == 1)
 			return -ENOTCONN;
 		sin->sin6_port = inet->inet_dport;
-		sin->sin6_addr = np->daddr;
+		sin->sin6_addr = sk->sk_v6_daddr;
 		if (np->sndflow)
 			sin->sin6_flowinfo = np->flow_label;
 	} else {
-		if (ipv6_addr_any(&np->rcv_saddr))
+		if (ipv6_addr_any(&sk->sk_v6_rcv_saddr))
 			sin->sin6_addr = np->saddr;
 		else
-			sin->sin6_addr = np->rcv_saddr;
+			sin->sin6_addr = sk->sk_v6_rcv_saddr;
 
 		sin->sin6_port = inet->inet_sport;
 	}
@@ -655,7 +655,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = sk->sk_protocol;
-		fl6.daddr = np->daddr;
+		fl6.daddr = sk->sk_v6_daddr;
 		fl6.saddr = np->saddr;
 		fl6.flowlabel = np->flow_label;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 48b6bd2..a454b0f 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -107,16 +107,16 @@ ipv4_connected:
 		if (err)
 			goto out;
 
-		ipv6_addr_set_v4mapped(inet->inet_daddr, &np->daddr);
+		ipv6_addr_set_v4mapped(inet->inet_daddr, &sk->sk_v6_daddr);
 
 		if (ipv6_addr_any(&np->saddr) ||
 		    ipv6_mapped_addr_any(&np->saddr))
 			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
 
-		if (ipv6_addr_any(&np->rcv_saddr) ||
-		    ipv6_mapped_addr_any(&np->rcv_saddr)) {
+		if (ipv6_addr_any(&sk->sk_v6_rcv_saddr) ||
+		    ipv6_mapped_addr_any(&sk->sk_v6_rcv_saddr)) {
 			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
-					       &np->rcv_saddr);
+					       &sk->sk_v6_rcv_saddr);
 			if (sk->sk_prot->rehash)
 				sk->sk_prot->rehash(sk);
 		}
@@ -145,7 +145,7 @@ ipv4_connected:
 		}
 	}
 
-	np->daddr = *daddr;
+	sk->sk_v6_daddr = *daddr;
 	np->flow_label = fl6.flowlabel;
 
 	inet->inet_dport = usin->sin6_port;
@@ -156,7 +156,7 @@ ipv4_connected:
 	 */
 
 	fl6.flowi6_proto = sk->sk_protocol;
-	fl6.daddr = np->daddr;
+	fl6.daddr = sk->sk_v6_daddr;
 	fl6.saddr = np->saddr;
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
@@ -183,16 +183,16 @@ ipv4_connected:
 	if (ipv6_addr_any(&np->saddr))
 		np->saddr = fl6.saddr;
 
-	if (ipv6_addr_any(&np->rcv_saddr)) {
-		np->rcv_saddr = fl6.saddr;
+	if (ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+		sk->sk_v6_rcv_saddr = fl6.saddr;
 		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 		if (sk->sk_prot->rehash)
 			sk->sk_prot->rehash(sk);
 	}
 
 	ip6_dst_store(sk, dst,
-		      ipv6_addr_equal(&fl6.daddr, &np->daddr) ?
-		      &np->daddr : NULL,
+		      ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr) ?
+		      &sk->sk_v6_daddr : NULL,
 #ifdef CONFIG_IPV6_SUBTREES
 		      ipv6_addr_equal(&fl6.saddr, &np->saddr) ?
 		      &np->saddr :
@@ -883,11 +883,10 @@ EXPORT_SYMBOL_GPL(ip6_datagram_send_ctl);
 void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
 			     __u16 srcp, __u16 destp, int bucket)
 {
-	struct ipv6_pinfo *np = inet6_sk(sp);
 	const struct in6_addr *dest, *src;
 
-	dest  = &np->daddr;
-	src   = &np->rcv_saddr;
+	dest  = &sp->sk_v6_daddr;
+	src   = &sp->sk_v6_rcv_saddr;
 	seq_printf(seq,
 		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d\n",
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index e4311cb..b7400b4 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -165,11 +165,10 @@ EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
 
 void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
 {
-	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) uaddr;
 
 	sin6->sin6_family = AF_INET6;
-	sin6->sin6_addr = np->daddr;
+	sin6->sin6_addr = sk->sk_v6_daddr;
 	sin6->sin6_port	= inet_sk(sk)->inet_dport;
 	/* We do not store received flowlabel for TCP */
 	sin6->sin6_flowinfo = 0;
@@ -203,7 +202,7 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->flowi6_proto = sk->sk_protocol;
-	fl6->daddr = np->daddr;
+	fl6->daddr = sk->sk_v6_daddr;
 	fl6->saddr = np->saddr;
 	fl6->flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl6->flowlabel);
@@ -245,7 +244,7 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	skb_dst_set_noref(skb, dst);
 
 	/* Restore final destination back after routing done */
-	fl6.daddr = np->daddr;
+	fl6.daddr = sk->sk_v6_daddr;
 
 	res = ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 	rcu_read_unlock();
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 4644077..842d833 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -89,30 +89,16 @@ begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
 			continue;
-		if (sk->sk_state == TCP_TIME_WAIT) {
-			if (!INET6_TW_MATCH(sk, net, saddr, daddr, ports, dif))
-				continue;
-		} else {
-			if (!INET6_MATCH(sk, net, saddr, daddr, ports, dif))
-				continue;
-		}
+		if (!INET6_MATCH(sk, net, saddr, daddr, ports, dif))
+			continue;
 		if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
 			goto out;
 
-		if (sk->sk_state == TCP_TIME_WAIT) {
-			if (unlikely(!INET6_TW_MATCH(sk, net, saddr, daddr,
-						     ports, dif))) {
-				sock_gen_put(sk);
-				goto begin;
-			}
-		} else {
-			if (unlikely(!INET6_MATCH(sk, net, saddr, daddr,
-						  ports, dif))) {
-				sock_put(sk);
-				goto begin;
-			}
-		goto found;
+		if (unlikely(!INET6_MATCH(sk, net, saddr, daddr, ports, dif))) {
+			sock_gen_put(sk);
+			goto begin;
 		}
+		goto found;
 	}
 	if (get_nulls_value(node) != slot)
 		goto begin;
@@ -133,11 +119,10 @@ static inline int compute_score(struct sock *sk, struct net *net,
 
 	if (net_eq(sock_net(sk), net) && inet_sk(sk)->inet_num == hnum &&
 	    sk->sk_family == PF_INET6) {
-		const struct ipv6_pinfo *np = inet6_sk(sk);
 
 		score = 1;
-		if (!ipv6_addr_any(&np->rcv_saddr)) {
-			if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
+		if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+			if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
 				return -1;
 			score++;
 		}
@@ -229,9 +214,8 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 {
 	struct inet_hashinfo *hinfo = death_row->hashinfo;
 	struct inet_sock *inet = inet_sk(sk);
-	const struct ipv6_pinfo *np = inet6_sk(sk);
-	const struct in6_addr *daddr = &np->rcv_saddr;
-	const struct in6_addr *saddr = &np->daddr;
+	const struct in6_addr *daddr = &sk->sk_v6_rcv_saddr;
+	const struct in6_addr *saddr = &sk->sk_v6_daddr;
 	const int dif = sk->sk_bound_dev_if;
 	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	struct net *net = sock_net(sk);
@@ -250,23 +234,19 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 		if (sk2->sk_hash != hash)
 			continue;
 
-		if (sk2->sk_state == TCP_TIME_WAIT) {
-			if (likely(INET6_TW_MATCH(sk2, net, saddr, daddr,
-						  ports, dif))) {
+		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports, dif))) {
+			if (sk2->sk_state == TCP_TIME_WAIT) {
 				tw = inet_twsk(sk2);
 				if (twsk_unique(sk, sk2, twp))
-					goto unique;
-				else
-					goto not_unique;
+					break;
 			}
-		}
-		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports, dif)))
 			goto not_unique;
+		}
 	}
 
-unique:
 	/* Must record num and sport now. Otherwise we will see
-	 * in hash table socket with a funny identity. */
+	 * in hash table socket with a funny identity.
+	 */
 	inet->inet_num = lport;
 	inet->inet_sport = htons(lport);
 	sk->sk_hash = hash;
@@ -299,9 +279,9 @@ not_unique:
 static inline u32 inet6_sk_port_offset(const struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	const struct ipv6_pinfo *np = inet6_sk(sk);
-	return secure_ipv6_port_ephemeral(np->rcv_saddr.s6_addr32,
-					  np->daddr.s6_addr32,
+
+	return secure_ipv6_port_ephemeral(sk->sk_v6_rcv_saddr.s6_addr32,
+					  sk->sk_v6_daddr.s6_addr32,
 					  inet->inet_dport);
 }
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d1e2e8e..4919a8e 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -174,7 +174,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			}
 
 			if (ipv6_only_sock(sk) ||
-			    !ipv6_addr_v4mapped(&np->daddr)) {
+			    !ipv6_addr_v4mapped(&sk->sk_v6_daddr)) {
 				retv = -EADDRNOTAVAIL;
 				break;
 			}
@@ -1011,7 +1011,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				struct in6_pktinfo src_info;
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
 					np->sticky_pktinfo.ipi6_ifindex;
-				src_info.ipi6_addr = np->mcast_oif ? np->daddr : np->sticky_pktinfo.ipi6_addr;
+				src_info.ipi6_addr = np->mcast_oif ? sk->sk_v6_daddr : np->sticky_pktinfo.ipi6_addr;
 				put_cmsg(&msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
 			}
 			if (np->rxopt.bits.rxhlim) {
@@ -1026,7 +1026,8 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				struct in6_pktinfo src_info;
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
 					np->sticky_pktinfo.ipi6_ifindex;
-				src_info.ipi6_addr = np->mcast_oif ? np->daddr : np->sticky_pktinfo.ipi6_addr;
+				src_info.ipi6_addr = np->mcast_oif ? sk->sk_v6_daddr :
+								     np->sticky_pktinfo.ipi6_addr;
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292PKTINFO, sizeof(src_info), &src_info);
 			}
 			if (np->rxopt.bits.rxohlim) {
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index d6e4dd8..54b75ea 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -297,9 +297,9 @@ ipv6_getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 	struct nf_conntrack_tuple tuple = { .src.l3num = NFPROTO_IPV6 };
 	struct nf_conn *ct;
 
-	tuple.src.u3.in6 = inet6->rcv_saddr;
+	tuple.src.u3.in6 = sk->sk_v6_rcv_saddr;
 	tuple.src.u.tcp.port = inet->inet_sport;
-	tuple.dst.u3.in6 = inet6->daddr;
+	tuple.dst.u3.in6 = sk->sk_v6_daddr;
 	tuple.dst.u.tcp.port = inet->inet_dport;
 	tuple.dst.protonum = sk->sk_protocol;
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 18f19df..8815e31 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -116,7 +116,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
-		daddr = &np->daddr;
+		daddr = &sk->sk_v6_daddr;
 	}
 
 	if (!iif)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a4ed241..3c00842 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -77,20 +77,19 @@ static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 
 	sk_for_each_from(sk)
 		if (inet_sk(sk)->inet_num == num) {
-			struct ipv6_pinfo *np = inet6_sk(sk);
 
 			if (!net_eq(sock_net(sk), net))
 				continue;
 
-			if (!ipv6_addr_any(&np->daddr) &&
-			    !ipv6_addr_equal(&np->daddr, rmt_addr))
+			if (!ipv6_addr_any(&sk->sk_v6_daddr) &&
+			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
 				continue;
 
 			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
 				continue;
 
-			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (ipv6_addr_equal(&np->rcv_saddr, loc_addr))
+			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+				if (ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr))
 					goto found;
 				if (is_multicast &&
 				    inet6_mc_check(sk, loc_addr, rmt_addr))
@@ -302,7 +301,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	inet->inet_rcv_saddr = inet->inet_saddr = v4addr;
-	np->rcv_saddr = addr->sin6_addr;
+	sk->sk_v6_rcv_saddr = addr->sin6_addr;
 	if (!(addr_type & IPV6_ADDR_MULTICAST))
 		np->saddr = addr->sin6_addr;
 	err = 0;
@@ -804,8 +803,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		 * sk->sk_dst_cache.
 		 */
 		if (sk->sk_state == TCP_ESTABLISHED &&
-		    ipv6_addr_equal(daddr, &np->daddr))
-			daddr = &np->daddr;
+		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
+			daddr = &sk->sk_v6_daddr;
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
@@ -816,7 +815,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 			return -EDESTADDRREQ;
 
 		proto = inet->inet_num;
-		daddr = &np->daddr;
+		daddr = &sk->sk_v6_daddr;
 		fl6.flowlabel = np->flow_label;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 528e61a..541dfc4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -192,13 +192,13 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	}
 
 	if (tp->rx_opt.ts_recent_stamp &&
-	    !ipv6_addr_equal(&np->daddr, &usin->sin6_addr)) {
+	    !ipv6_addr_equal(&sk->sk_v6_daddr, &usin->sin6_addr)) {
 		tp->rx_opt.ts_recent = 0;
 		tp->rx_opt.ts_recent_stamp = 0;
 		tp->write_seq = 0;
 	}
 
-	np->daddr = usin->sin6_addr;
+	sk->sk_v6_daddr = usin->sin6_addr;
 	np->flow_label = fl6.flowlabel;
 
 	/*
@@ -237,17 +237,17 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		} else {
 			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
 			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
-					       &np->rcv_saddr);
+					       &sk->sk_v6_rcv_saddr);
 		}
 
 		return err;
 	}
 
-	if (!ipv6_addr_any(&np->rcv_saddr))
-		saddr = &np->rcv_saddr;
+	if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr))
+		saddr = &sk->sk_v6_rcv_saddr;
 
 	fl6.flowi6_proto = IPPROTO_TCP;
-	fl6.daddr = np->daddr;
+	fl6.daddr = sk->sk_v6_daddr;
 	fl6.saddr = saddr ? *saddr : np->saddr;
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
@@ -266,7 +266,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	if (saddr == NULL) {
 		saddr = &fl6.saddr;
-		np->rcv_saddr = *saddr;
+		sk->sk_v6_rcv_saddr = *saddr;
 	}
 
 	/* set the source address */
@@ -279,7 +279,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	rt = (struct rt6_info *) dst;
 	if (tcp_death_row.sysctl_tw_recycle &&
 	    !tp->rx_opt.ts_recent_stamp &&
-	    ipv6_addr_equal(&rt->rt6i_dst.addr, &np->daddr))
+	    ipv6_addr_equal(&rt->rt6i_dst.addr, &sk->sk_v6_daddr))
 		tcp_fetch_timewait_stamp(sk, dst);
 
 	icsk->icsk_ext_hdr_len = 0;
@@ -298,7 +298,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
-							     np->daddr.s6_addr32,
+							     sk->sk_v6_daddr.s6_addr32,
 							     inet->inet_sport,
 							     inet->inet_dport);
 
@@ -515,7 +515,7 @@ static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
 static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
 						struct sock *addr_sk)
 {
-	return tcp_v6_md5_do_lookup(sk, &inet6_sk(addr_sk)->daddr);
+	return tcp_v6_md5_do_lookup(sk, &addr_sk->sk_v6_daddr);
 }
 
 static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
@@ -621,7 +621,7 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 
 	if (sk) {
 		saddr = &inet6_sk(sk)->saddr;
-		daddr = &inet6_sk(sk)->daddr;
+		daddr = &sk->sk_v6_daddr;
 	} else if (req) {
 		saddr = &inet6_rsk(req)->loc_addr;
 		daddr = &inet6_rsk(req)->rmt_addr;
@@ -1116,11 +1116,11 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newnp->daddr);
+		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
 
 		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
 
-		newnp->rcv_saddr = newnp->saddr;
+		newsk->sk_v6_rcv_saddr = newnp->saddr;
 
 		inet_csk(newsk)->icsk_af_ops = &ipv6_mapped;
 		newsk->sk_backlog_rcv = tcp_v4_do_rcv;
@@ -1185,9 +1185,9 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-	newnp->daddr = treq->rmt_addr;
+	newsk->sk_v6_daddr = treq->rmt_addr;
 	newnp->saddr = treq->loc_addr;
-	newnp->rcv_saddr = treq->loc_addr;
+	newsk->sk_v6_rcv_saddr = treq->loc_addr;
 	newsk->sk_bound_dev_if = treq->iif;
 
 	/* Now IPv6 options...
@@ -1244,13 +1244,13 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	if ((key = tcp_v6_md5_do_lookup(sk, &newnp->daddr)) != NULL) {
+	if ((key = tcp_v6_md5_do_lookup(sk, &newsk->sk_v6_daddr)) != NULL) {
 		/* We're using one, so create a matching key
 		 * on the newsk structure. If we fail to get
 		 * memory, then we end up not copying the key
 		 * across. Shucks.
 		 */
-		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newnp->daddr,
+		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newsk->sk_v6_daddr,
 			       AF_INET6, key->key, key->keylen,
 			       sk_gfp_atomic(sk, GFP_ATOMIC));
 	}
@@ -1758,10 +1758,9 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	const struct inet_sock *inet = inet_sk(sp);
 	const struct tcp_sock *tp = tcp_sk(sp);
 	const struct inet_connection_sock *icsk = inet_csk(sp);
-	const struct ipv6_pinfo *np = inet6_sk(sp);
 
-	dest  = &np->daddr;
-	src   = &np->rcv_saddr;
+	dest  = &sp->sk_v6_daddr;
+	src   = &sp->sk_v6_rcv_saddr;
 	destp = ntohs(inet->inet_dport);
 	srcp  = ntohs(inet->inet_sport);
 
@@ -1810,11 +1809,10 @@ static void get_timewait6_sock(struct seq_file *seq,
 {
 	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
-	const struct inet6_timewait_sock *tw6 = inet6_twsk((struct sock *)tw);
 	s32 delta = tw->tw_ttd - inet_tw_time_stamp();
 
-	dest = &tw6->tw_v6_daddr;
-	src  = &tw6->tw_v6_rcv_saddr;
+	dest = &tw->tw_v6_daddr;
+	src  = &tw->tw_v6_rcv_saddr;
 	destp = ntohs(tw->tw_dport);
 	srcp  = ntohs(tw->tw_sport);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8119791..3270522 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -55,11 +55,10 @@
 
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
-	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
 	int sk_ipv6only = ipv6_only_sock(sk);
 	int sk2_ipv6only = inet_v6_ipv6only(sk2);
-	int addr_type = ipv6_addr_type(sk_rcv_saddr6);
+	int addr_type = ipv6_addr_type(&sk->sk_v6_rcv_saddr);
 	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
 
 	/* if both are mapped, treat as IPv4 */
@@ -77,7 +76,7 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 		return 1;
 
 	if (sk2_rcv_saddr6 &&
-	    ipv6_addr_equal(sk_rcv_saddr6, sk2_rcv_saddr6))
+	    ipv6_addr_equal(&sk->sk_v6_rcv_saddr, sk2_rcv_saddr6))
 		return 1;
 
 	return 0;
@@ -105,7 +104,7 @@ int udp_v6_get_port(struct sock *sk, unsigned short snum)
 	unsigned int hash2_nulladdr =
 		udp6_portaddr_hash(sock_net(sk), &in6addr_any, snum);
 	unsigned int hash2_partial =
-		udp6_portaddr_hash(sock_net(sk), &inet6_sk(sk)->rcv_saddr, 0);
+		udp6_portaddr_hash(sock_net(sk), &sk->sk_v6_rcv_saddr, 0);
 
 	/* precompute partial secondary hash */
 	udp_sk(sk)->udp_portaddr_hash = hash2_partial;
@@ -115,7 +114,7 @@ int udp_v6_get_port(struct sock *sk, unsigned short snum)
 static void udp_v6_rehash(struct sock *sk)
 {
 	u16 new_hash = udp6_portaddr_hash(sock_net(sk),
-					  &inet6_sk(sk)->rcv_saddr,
+					  &sk->sk_v6_rcv_saddr,
 					  inet_sk(sk)->inet_num);
 
 	udp_lib_rehash(sk, new_hash);
@@ -131,7 +130,6 @@ static inline int compute_score(struct sock *sk, struct net *net,
 
 	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
 			sk->sk_family == PF_INET6) {
-		struct ipv6_pinfo *np = inet6_sk(sk);
 		struct inet_sock *inet = inet_sk(sk);
 
 		score = 0;
@@ -140,13 +138,13 @@ static inline int compute_score(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
-		if (!ipv6_addr_any(&np->rcv_saddr)) {
-			if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
+		if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+			if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
 				return -1;
 			score++;
 		}
-		if (!ipv6_addr_any(&np->daddr)) {
-			if (!ipv6_addr_equal(&np->daddr, saddr))
+		if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
+			if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
 				return -1;
 			score++;
 		}
@@ -169,10 +167,9 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 
 	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
 			sk->sk_family == PF_INET6) {
-		struct ipv6_pinfo *np = inet6_sk(sk);
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
+		if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, daddr))
 			return -1;
 		score = 0;
 		if (inet->inet_dport) {
@@ -180,8 +177,8 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 				return -1;
 			score++;
 		}
-		if (!ipv6_addr_any(&np->daddr)) {
-			if (!ipv6_addr_equal(&np->daddr, saddr))
+		if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
+			if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
 				return -1;
 			score++;
 		}
@@ -549,7 +546,7 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
-	if (!ipv6_addr_any(&inet6_sk(sk)->daddr))
+	if (!ipv6_addr_any(&sk->sk_v6_daddr))
 		sock_rps_save_rxhash(sk, skb);
 
 	rc = sock_queue_rcv_skb(sk, skb);
@@ -688,20 +685,19 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 
 		if (udp_sk(s)->udp_port_hash == num &&
 		    s->sk_family == PF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(s);
 			if (inet->inet_dport) {
 				if (inet->inet_dport != rmt_port)
 					continue;
 			}
-			if (!ipv6_addr_any(&np->daddr) &&
-			    !ipv6_addr_equal(&np->daddr, rmt_addr))
+			if (!ipv6_addr_any(&sk->sk_v6_daddr) &&
+			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
 				continue;
 
 			if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
 				continue;
 
-			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (!ipv6_addr_equal(&np->rcv_saddr, loc_addr))
+			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+				if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr))
 					continue;
 			}
 			if (!inet6_mc_check(s, loc_addr, rmt_addr))
@@ -1062,7 +1058,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	} else if (!up->pending) {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
-		daddr = &np->daddr;
+		daddr = &sk->sk_v6_daddr;
 	} else
 		daddr = NULL;
 
@@ -1132,8 +1128,8 @@ do_udp_sendmsg:
 		 * sk->sk_dst_cache.
 		 */
 		if (sk->sk_state == TCP_ESTABLISHED &&
-		    ipv6_addr_equal(daddr, &np->daddr))
-			daddr = &np->daddr;
+		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
+			daddr = &sk->sk_v6_daddr;
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
@@ -1144,7 +1140,7 @@ do_udp_sendmsg:
 			return -EDESTADDRREQ;
 
 		fl6.fl6_dport = inet->inet_dport;
-		daddr = &np->daddr;
+		daddr = &sk->sk_v6_daddr;
 		fl6.flowlabel = np->flow_label;
 		connected = 1;
 	}
@@ -1260,8 +1256,8 @@ do_append_data:
 	if (dst) {
 		if (connected) {
 			ip6_dst_store(sk, dst,
-				      ipv6_addr_equal(&fl6.daddr, &np->daddr) ?
-				      &np->daddr : NULL,
+				      ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr) ?
+				      &sk->sk_v6_daddr : NULL,
 #ifdef CONFIG_IPV6_SUBTREES
 				      ipv6_addr_equal(&fl6.saddr, &np->saddr) ?
 				      &np->saddr :
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index feae495..116d1c4 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1176,7 +1176,7 @@ static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
 	    !(skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
 		__wsum csum = skb_checksum(skb, 0, udp_len, 0);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		uh->check = csum_ipv6_magic(&np->saddr, &np->daddr, udp_len,
+		uh->check = csum_ipv6_magic(&np->saddr, &sk->sk_v6_daddr, udp_len,
 					    IPPROTO_UDP, csum);
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
@@ -1184,7 +1184,7 @@ static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
-		uh->check = ~csum_ipv6_magic(&np->saddr, &np->daddr,
+		uh->check = ~csum_ipv6_magic(&np->saddr, &sk->sk_v6_daddr,
 					     udp_len, IPPROTO_UDP, 0);
 	}
 }
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 072d720..2d6760a 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -127,9 +127,10 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 
 #if IS_ENABLED(CONFIG_IPV6)
 		if (tunnel->sock->sk_family == AF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(tunnel->sock);
+			const struct ipv6_pinfo *np = inet6_sk(tunnel->sock);
+
 			seq_printf(m, " from %pI6c to %pI6c\n",
-				&np->saddr, &np->daddr);
+				&np->saddr, &tunnel->sock->sk_v6_daddr);
 		} else
 #endif
 		seq_printf(m, " from %pI4 to %pI4\n",
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index b8a6039..cfd6530 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -63,7 +63,7 @@ static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
 	struct sock *sk;
 
 	sk_for_each_bound(sk, &l2tp_ip6_bind_table) {
-		struct in6_addr *addr = inet6_rcv_saddr(sk);
+		const struct in6_addr *addr = inet6_rcv_saddr(sk);
 		struct l2tp_ip6_sock *l2tp = l2tp_ip6_sk(sk);
 
 		if (l2tp == NULL)
@@ -331,7 +331,7 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rcu_read_unlock();
 
 	inet->inet_rcv_saddr = inet->inet_saddr = v4addr;
-	np->rcv_saddr = addr->l2tp_addr;
+	sk->sk_v6_rcv_saddr = addr->l2tp_addr;
 	np->saddr = addr->l2tp_addr;
 
 	l2tp_ip6_sk(sk)->conn_id = addr->l2tp_conn_id;
@@ -421,14 +421,14 @@ static int l2tp_ip6_getname(struct socket *sock, struct sockaddr *uaddr,
 		if (!lsk->peer_conn_id)
 			return -ENOTCONN;
 		lsa->l2tp_conn_id = lsk->peer_conn_id;
-		lsa->l2tp_addr = np->daddr;
+		lsa->l2tp_addr = sk->sk_v6_daddr;
 		if (np->sndflow)
 			lsa->l2tp_flowinfo = np->flow_label;
 	} else {
-		if (ipv6_addr_any(&np->rcv_saddr))
+		if (ipv6_addr_any(&sk->sk_v6_rcv_saddr))
 			lsa->l2tp_addr = np->saddr;
 		else
-			lsa->l2tp_addr = np->rcv_saddr;
+			lsa->l2tp_addr = sk->sk_v6_rcv_saddr;
 
 		lsa->l2tp_conn_id = lsk->conn_id;
 	}
@@ -537,8 +537,8 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		 * sk->sk_dst_cache.
 		 */
 		if (sk->sk_state == TCP_ESTABLISHED &&
-		    ipv6_addr_equal(daddr, &np->daddr))
-			daddr = &np->daddr;
+		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
+			daddr = &sk->sk_v6_daddr;
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    lsa->l2tp_scope_id &&
@@ -548,7 +548,7 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -EDESTADDRREQ;
 
-		daddr = &np->daddr;
+		daddr = &sk->sk_v6_daddr;
 		fl6.flowlabel = np->flow_label;
 	}
 
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 0825ff2..be446d5 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -306,8 +306,8 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 		if (np) {
 			if (nla_put(skb, L2TP_ATTR_IP6_SADDR, sizeof(np->saddr),
 				    &np->saddr) ||
-			    nla_put(skb, L2TP_ATTR_IP6_DADDR, sizeof(np->daddr),
-				    &np->daddr))
+			    nla_put(skb, L2TP_ATTR_IP6_DADDR, sizeof(sk->sk_v6_daddr),
+				    &sk->sk_v6_daddr))
 				goto nla_put_failure;
 		} else
 #endif
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 5ebee2d..f0a7ada 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -906,8 +906,8 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 #if IS_ENABLED(CONFIG_IPV6)
 	} else if ((tunnel->version == 2) &&
 		   (tunnel->sock->sk_family == AF_INET6)) {
-		struct ipv6_pinfo *np = inet6_sk(tunnel->sock);
 		struct sockaddr_pppol2tpin6 sp;
+
 		len = sizeof(sp);
 		memset(&sp, 0, len);
 		sp.sa_family	= AF_PPPOX;
@@ -920,13 +920,13 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 		sp.pppol2tp.d_session = session->peer_session_id;
 		sp.pppol2tp.addr.sin6_family = AF_INET6;
 		sp.pppol2tp.addr.sin6_port = inet->inet_dport;
-		memcpy(&sp.pppol2tp.addr.sin6_addr, &np->daddr,
-		       sizeof(np->daddr));
+		memcpy(&sp.pppol2tp.addr.sin6_addr, &tunnel->sock->sk_v6_daddr,
+		       sizeof(tunnel->sock->sk_v6_daddr));
 		memcpy(uaddr, &sp, len);
 	} else if ((tunnel->version == 3) &&
 		   (tunnel->sock->sk_family == AF_INET6)) {
-		struct ipv6_pinfo *np = inet6_sk(tunnel->sock);
 		struct sockaddr_pppol2tpv3in6 sp;
+
 		len = sizeof(sp);
 		memset(&sp, 0, len);
 		sp.sa_family	= AF_PPPOX;
@@ -939,8 +939,8 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 		sp.pppol2tp.d_session = session->peer_session_id;
 		sp.pppol2tp.addr.sin6_family = AF_INET6;
 		sp.pppol2tp.addr.sin6_port = inet->inet_dport;
-		memcpy(&sp.pppol2tp.addr.sin6_addr, &np->daddr,
-		       sizeof(np->daddr));
+		memcpy(&sp.pppol2tp.addr.sin6_addr, &tunnel->sock->sk_v6_daddr,
+		       sizeof(tunnel->sock->sk_v6_daddr));
 		memcpy(uaddr, &sp, len);
 #endif
 	} else if (tunnel->version == 3) {
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 5d8a3a3..ef8a926 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -200,7 +200,7 @@ nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
 				     in->ifindex);
 		if (sk) {
 			int connected = (sk->sk_state == TCP_ESTABLISHED);
-			int wildcard = ipv6_addr_any(&inet6_sk(sk)->rcv_saddr);
+			int wildcard = ipv6_addr_any(&sk->sk_v6_rcv_saddr);
 
 			/* NOTE: we return listeners even if bound to
 			 * 0.0.0.0, those are filtered out in
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 06df2b9..3dd0e37 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -370,7 +370,7 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 		 */
 		wildcard = (!(info->flags & XT_SOCKET_NOWILDCARD) &&
 			    sk->sk_state != TCP_TIME_WAIT &&
-			    ipv6_addr_any(&inet6_sk(sk)->rcv_saddr));
+			    ipv6_addr_any(&sk->sk_v6_rcv_saddr));
 
 		/* Ignore non-transparent sockets,
 		   if XT_SOCKET_TRANSPARENT is used */
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e7b2d4f..f6334aa 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -426,20 +426,20 @@ static void sctp_v6_from_sk(union sctp_addr *addr, struct sock *sk)
 {
 	addr->v6.sin6_family = AF_INET6;
 	addr->v6.sin6_port = 0;
-	addr->v6.sin6_addr = inet6_sk(sk)->rcv_saddr;
+	addr->v6.sin6_addr = sk->sk_v6_rcv_saddr;
 }
 
 /* Initialize sk->sk_rcv_saddr from sctp_addr. */
 static void sctp_v6_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
 {
 	if (addr->sa.sa_family == AF_INET && sctp_sk(sk)->v4mapped) {
-		inet6_sk(sk)->rcv_saddr.s6_addr32[0] = 0;
-		inet6_sk(sk)->rcv_saddr.s6_addr32[1] = 0;
-		inet6_sk(sk)->rcv_saddr.s6_addr32[2] = htonl(0x0000ffff);
-		inet6_sk(sk)->rcv_saddr.s6_addr32[3] =
+		sk->sk_v6_rcv_saddr.s6_addr32[0] = 0;
+		sk->sk_v6_rcv_saddr.s6_addr32[1] = 0;
+		sk->sk_v6_rcv_saddr.s6_addr32[2] = htonl(0x0000ffff);
+		sk->sk_v6_rcv_saddr.s6_addr32[3] =
 			addr->v4.sin_addr.s_addr;
 	} else {
-		inet6_sk(sk)->rcv_saddr = addr->v6.sin6_addr;
+		sk->sk_v6_rcv_saddr = addr->v6.sin6_addr;
 	}
 }
 
@@ -447,12 +447,12 @@ static void sctp_v6_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
 static void sctp_v6_to_sk_daddr(union sctp_addr *addr, struct sock *sk)
 {
 	if (addr->sa.sa_family == AF_INET && sctp_sk(sk)->v4mapped) {
-		inet6_sk(sk)->daddr.s6_addr32[0] = 0;
-		inet6_sk(sk)->daddr.s6_addr32[1] = 0;
-		inet6_sk(sk)->daddr.s6_addr32[2] = htonl(0x0000ffff);
-		inet6_sk(sk)->daddr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
+		sk->sk_v6_daddr.s6_addr32[0] = 0;
+		sk->sk_v6_daddr.s6_addr32[1] = 0;
+		sk->sk_v6_daddr.s6_addr32[2] = htonl(0x0000ffff);
+		sk->sk_v6_daddr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
 	} else {
-		inet6_sk(sk)->daddr = addr->v6.sin6_addr;
+		sk->sk_v6_daddr = addr->v6.sin6_addr;
 	}
 }
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 9c9caaa..0045c7c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -294,7 +294,7 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 	case PF_INET6:
 		len = snprintf(buf, remaining, "ipv6 %s %pI6 %d\n",
 				proto_name,
-				&inet6_sk(sk)->rcv_saddr,
+				&sk->sk_v6_rcv_saddr,
 				inet_sk(sk)->inet_num);
 		break;
 	default:
diff --git a/security/lsm_audit.c b/security/lsm_audit.c
index 8d8d97d..80554fc 100644
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -304,12 +304,11 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 			}
 			case AF_INET6: {
 				struct inet_sock *inet = inet_sk(sk);
-				struct ipv6_pinfo *inet6 = inet6_sk(sk);
 
-				print_ipv6_addr(ab, &inet6->rcv_saddr,
+				print_ipv6_addr(ab, &sk->sk_v6_rcv_saddr,
 						inet->inet_sport,
 						"laddr", "lport");
-				print_ipv6_addr(ab, &inet6->daddr,
+				print_ipv6_addr(ab, &sk->sk_v6_daddr,
 						inet->inet_dport,
 						"faddr", "fport");
 				break;
