From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [RFC][PATCH] [TPROXY] kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Tue, 09 Dec 2008 08:51:35 +0000
Message-ID: <1228812695.7631.16.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tproxy@lists.balabit.hu, hidden@sch.bme.hu,
	panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:37253 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752017AbYLIIvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 03:51:44 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id B3C1B39D2AE
	for <netdev@vger.kernel.org>; Tue,  9 Dec 2008 09:51:40 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'd like to get some guidance regarding the following patch. There's a 
severe performance limitation related to TIME_WAIT sockets and TProxy rules.
The patch below is the 'nice' approach, but it adds 6 bytes to 
inet_sock and inet_timewait_sock. The 'ugly' approach would be to schedule the
removal of the affected TIME_WAIT sockets at PREROUTING time.

This post is meant to get some review, but please do not apply this patch this time.

Thanks in advance.

	Without tproxy redirections an incoming SYN kicks out conflicting
	TIME_WAIT sockets, in order to handle clients that reuse ports
	within the TIME_WAIT period.

	The same mechanism didn't work in case TProxy is involved in finding
	the proper socket, as the time_wait processing code looks up the
	listening socket assuming that the listener addr/port matches those
	of the established connection.

	This is not the case with TProxy as the listener addr/port is possibly
	changed with the tproxy rule.

	This patch extends struct inet_timewait_sock and inet_sock with
	6 bytes causing a 112->118 bytes increase in case of inet_timewait_sock,
	and 680->686 bytes in the case of struct inet_sock on 64 bit
	platforms. Neither of these cause another cacheline to be used.

	This patch is currently only a draft, I'm still thinking about
	changing the prototype of nf_tproxy_get_sock_v4(), so please
	do NOT apply.
---
 include/net/inet_sock.h                |    3 +++
 include/net/inet_timewait_sock.h       |    5 ++++-
 include/net/netfilter/nf_tproxy_core.h |    6 +++++-
 net/ipv4/inet_connection_sock.c        |    2 ++
 net/ipv4/inet_timewait_sock.c          |    2 ++
 net/ipv4/tcp_ipv4.c                    |    2 +-
 net/netfilter/nf_tproxy_core.c         |   29 +++++++++++++++++++++--------
 net/netfilter/xt_TPROXY.c              |   13 +++++++++----
 net/netfilter/xt_socket.c              |    2 +-
 9 files changed, 48 insertions(+), 16 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index de0ecc7..33434b1 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -143,6 +143,9 @@ struct inet_sock {
 		__be32			addr;
 		struct flowi		fl;
 	} cork;
+	/* listener addr/port, can be different than saddr/sport in case tproxy redirection occurred */
+	__be32                  laddr;
+	__be16                  lport;
 };
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 4b8ece2..4de70a2 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -130,11 +130,14 @@ struct inet_timewait_sock {
 	/* And these are ours. */
 	__u8			tw_ipv6only:1,
 				tw_transparent:1;
-	/* 15 bits hole, try to pack */
+	/* 14 bits hole, try to pack */
 	__u16			tw_ipv6_offset;
 	unsigned long		tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
+	/* listener addr/port, can be different from tw_saddr/tw_sport in case tproxy redirection occurred */
+	__be32                  tw_laddr;
+	__be16                  tw_lport;
 };
 
 static inline void inet_twsk_add_node_rcu(struct inet_timewait_sock *tw,
diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index 208b46f..b3a8942 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -8,12 +8,16 @@
 #include <net/inet_sock.h>
 #include <net/tcp.h>
 
+#define NFT_LOOKUP_ANY         0
+#define NFT_LOOKUP_LISTENER    1
+#define NFT_LOOKUP_ESTABLISHED 2
+
 /* look up and get a reference to a matching socket */
 extern struct sock *
 nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 		      const __be32 saddr, const __be32 daddr,
 		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in, bool listening);
+		      const struct net_device *in, int lookup_type);
 
 static inline void
 nf_tproxy_put_sock(struct sock *sk)
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index fe32255..adbc509 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -520,6 +520,8 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 		inet_sk(newsk)->dport = inet_rsk(req)->rmt_port;
 		inet_sk(newsk)->num = ntohs(inet_rsk(req)->loc_port);
 		inet_sk(newsk)->sport = inet_rsk(req)->loc_port;
+		inet_sk(newsk)->laddr = inet_sk(sk)->saddr;
+		inet_sk(newsk)->lport = inet_sk(sk)->sport;
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 8554d0e..0e0e844 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -126,6 +126,8 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_substate	    = state;
 		tw->tw_sport	    = inet->sport;
 		tw->tw_dport	    = inet->dport;
+		tw->tw_laddr        = inet->laddr;
+		tw->tw_lport        = inet->lport;
 		tw->tw_family	    = sk->sk_family;
 		tw->tw_reuse	    = sk->sk_reuse;
 		tw->tw_hash	    = sk->sk_hash;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 26b9030..d858ec7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1645,7 +1645,7 @@ do_time_wait:
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo,
-							iph->daddr, th->dest,
+							inet_twsk(sk)->tw_laddr, inet_twsk(sk)->tw_lport,
 							inet_iif(skb));
 		if (sk2) {
 			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index cdc97f3..1858da0 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -22,21 +22,34 @@ struct sock *
 nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 		      const __be32 saddr, const __be32 daddr,
 		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in, bool listening_only)
+		      const struct net_device *in, int lookup_type)
 {
 	struct sock *sk;
 
 	/* look up socket */
 	switch (protocol) {
 	case IPPROTO_TCP:
-		if (listening_only)
-			sk = __inet_lookup_listener(net, &tcp_hashinfo,
-						    daddr, ntohs(dport),
-						    in->ifindex);
-		else
+		switch (lookup_type) {
+		case NFT_LOOKUP_ANY:
 			sk = __inet_lookup(net, &tcp_hashinfo,
 					   saddr, sport, daddr, dport,
 					   in->ifindex);
+			break;
+		case NFT_LOOKUP_LISTENER:
+			sk = inet_lookup_listener(net, &tcp_hashinfo,
+						    daddr, dport,
+						    in->ifindex);
+			break;
+		case NFT_LOOKUP_ESTABLISHED:
+			sk = inet_lookup_established(net, &tcp_hashinfo,
+						    saddr, sport, daddr, dport,
+						    in->ifindex);
+			break;
+		default:
+			WARN_ON(1);
+			sk = NULL;
+			break;
+		}
 		break;
 	case IPPROTO_UDP:
 		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
@@ -47,8 +60,8 @@ nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 		sk = NULL;
 	}
 
-	pr_debug("tproxy socket lookup: proto %u %08x:%u -> %08x:%u, listener only: %d, sock %p\n",
-		 protocol, ntohl(saddr), ntohs(sport), ntohl(daddr), ntohs(dport), listening_only, sk);
+	pr_debug("tproxy socket lookup: proto %u %08x:%u -> %08x:%u, lookup type: %d, sock %p\n",
+		 protocol, ntohl(saddr), ntohs(sport), ntohl(daddr), ntohs(dport), lookup_type, sk);
 
 	return sk;
 }
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 1340c2f..5d66613 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -37,10 +37,15 @@ tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
 		return NF_DROP;
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-				   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
-				   hp->source, tgi->lport ? tgi->lport : hp->dest,
-				   par->in, true);
-
+				   iph->saddr, iph->daddr,
+				   hp->source, hp->dest,
+				   par->in, NFT_LOOKUP_ESTABLISHED);
+	if (!sk) {
+		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
+					   hp->source, tgi->lport ? tgi->lport : hp->dest,
+					   par->in, NFT_LOOKUP_LISTENER);
+	}
 	/* NOTE: assign_sock consumes our sk reference */
 	if (sk && nf_tproxy_assign_sock(skb, sk)) {
 		/* This should be in a separate target, but we don't do multiple
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 1d521a5..ae8233d 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -142,7 +142,7 @@ socket_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 #endif
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
-				   saddr, daddr, sport, dport, par->in, false);
+				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
 	if (sk != NULL) {
 		bool wildcard = (sk->sk_state != TCP_TIME_WAIT && inet_sk(sk)->rcv_saddr == 0);
 
-- 
1.5.6.3


