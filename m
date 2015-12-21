From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] tcp: honour SO_BINDTODEVICE for TW_RST case too
Date: Mon, 21 Dec 2015 17:20:09 +0100
Message-ID: <1450714809-2773-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44644 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751199AbbLUQ0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 11:26:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes points out that when we generate tcp reset for timewait sockets we
pretend we found no socket and pass NULL sk to tcp_vX_send_reset().

Make it cope with inet tw sockets and then provide tw sk so RST appears on
correct interface.

Packetdrill test case:
// want default route to be used, we rely on BINDTODEVICE
`ip route del 192.0.2.0/24 via 192.168.0.2 dev tun0`

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.001 setsockopt(3, SOL_SOCKET, SO_BINDTODEVICE, "tun0", 4) = 0
0.100...0.200 connect(3, ..., ...) = 0

0.100 > S 0:0(0) <mss 1460,sackOK,nop,nop>
0.200 < S. 0:0(0) ack 1 win 32792 <mss 1460,sackOK,nop,nop>
0.200 > . 1:1(0) ack 1

0.210 close(3) = 0

0.210 > F. 1:1(0) ack 1 win 29200
0.300 < . 1:1(0) ack 2 win 46

// more data while in FIN_WAIT2, expect RST
1.300 < P. 1:1001(1000) ack 1 win 46

// fails without this change -- default route is used
1.301 > R 1:1(0) win 0

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_ipv4.c      | 31 ++++++++++++++++++++++---------
 net/ipv4/tcp_minisocks.c |  7 ++-----
 net/ipv6/tcp_ipv6.c      | 15 +++++++++++----
 3 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 46e92fb..24ba2e1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -587,13 +587,14 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 	} rep;
 	struct ip_reply_arg arg;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
+	struct tcp_md5sig_key *key = NULL;
 	const __u8 *hash_location = NULL;
 	unsigned char newhash[16];
 	int genhash;
 	struct sock *sk1 = NULL;
 #endif
 	struct net *net;
+	bool have_full_sk;
 
 	/* Never send a reset in response to a reset. */
 	if (th->rst)
@@ -624,10 +625,14 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 	arg.iov[0].iov_base = (unsigned char *)&rep;
 	arg.iov[0].iov_len  = sizeof(rep.th);
 
-	net = sk ? sock_net(sk) : dev_net(skb_dst(skb)->dev);
+	have_full_sk = sk && sk_fullsock(sk);
+	net = have_full_sk ? sock_net(sk) : dev_net(skb_dst(skb)->dev);
 #ifdef CONFIG_TCP_MD5SIG
 	hash_location = tcp_parse_md5sig_option(th);
-	if (!sk && hash_location) {
+	if (have_full_sk) {
+		key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
+					&ip_hdr(skb)->saddr, AF_INET);
+	} else if (hash_location) {
 		/*
 		 * active side is lost. Try to find listening socket through
 		 * source port, and then find md5 key through listening socket.
@@ -651,10 +656,6 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		genhash = tcp_v4_md5_hash_skb(newhash, key, NULL, skb);
 		if (genhash || memcmp(hash_location, newhash, 16) != 0)
 			goto release_sk1;
-	} else {
-		key = sk ? tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
-					     &ip_hdr(skb)->saddr,
-					     AF_INET) : NULL;
 	}
 
 	if (key) {
@@ -675,7 +676,14 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
-	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
+	arg.flags = 0;
+	if (have_full_sk) {
+		if (inet_sk(sk)->transparent)
+			arg.flags = IP_REPLY_ARG_NOSRCCHECK;
+	} else if (sk && inet_twsk(sk)->tw_transparent) {
+		arg.flags = IP_REPLY_ARG_NOSRCCHECK;
+	}
+
 	/* When socket is gone, all binding information is lost.
 	 * routing might fail in this case. No choice here, if we choose to force
 	 * input interface, we will misroute in case of asymmetric route.
@@ -683,6 +691,9 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 	if (sk)
 		arg.bound_dev_if = sk->sk_bound_dev_if;
 
+	BUILD_BUG_ON(offsetof(struct sock, sk_bound_dev_if) !=
+		     offsetof(struct inet_timewait_sock, tw_bound_dev_if));
+
 	arg.tos = ip_hdr(skb)->tos;
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
@@ -1706,7 +1717,9 @@ do_time_wait:
 		tcp_v4_timewait_ack(sk, skb);
 		break;
 	case TCP_TW_RST:
-		goto no_tcp_socket;
+		tcp_v4_send_reset(sk, skb);
+		inet_twsk_deschedule_put(inet_twsk(sk));
+		goto discard_it;
 	case TCP_TW_SUCCESS:;
 	}
 	goto discard_it;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index ac6b196..75632a9 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -131,7 +131,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 			goto kill;
 
 		if (th->syn && !before(TCP_SKB_CB(skb)->seq, tcptw->tw_rcv_nxt))
-			goto kill_with_rst;
+			return TCP_TW_RST;
 
 		/* Dup ACK? */
 		if (!th->ack ||
@@ -145,11 +145,8 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 		 * reset.
 		 */
 		if (!th->fin ||
-		    TCP_SKB_CB(skb)->end_seq != tcptw->tw_rcv_nxt + 1) {
-kill_with_rst:
-			inet_twsk_deschedule_put(tw);
+		    TCP_SKB_CB(skb)->end_seq != tcptw->tw_rcv_nxt + 1)
 			return TCP_TW_RST;
-		}
 
 		/* FIN arrived, enter true time-wait state. */
 		tw->tw_substate	  = TCP_TIME_WAIT;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f03d2b0..2637b61 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -841,6 +841,7 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 	int genhash;
 	struct sock *sk1 = NULL;
 #endif
+	bool have_full_sk;
 	int oif;
 
 	if (th->rst)
@@ -852,9 +853,12 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 	if (!sk && !ipv6_unicast_destination(skb))
 		return;
 
+	have_full_sk = sk && sk_fullsock(sk);
 #ifdef CONFIG_TCP_MD5SIG
 	hash_location = tcp_parse_md5sig_option(th);
-	if (!sk && hash_location) {
+	if (have_full_sk) {
+		key = tcp_v6_md5_do_lookup(sk, &ipv6h->saddr);
+	} else if (hash_location) {
 		/*
 		 * active side is lost. Try to find listening socket through
 		 * source port, and then find md5 key through listening socket.
@@ -877,8 +881,6 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 		genhash = tcp_v6_md5_hash_skb(newhash, key, NULL, skb);
 		if (genhash || memcmp(hash_location, newhash, 16) != 0)
 			goto release_sk1;
-	} else {
-		key = sk ? tcp_v6_md5_do_lookup(sk, &ipv6h->saddr) : NULL;
 	}
 #endif
 
@@ -889,6 +891,9 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 			  (th->doff << 2);
 
 	oif = sk ? sk->sk_bound_dev_if : 0;
+	if (!have_full_sk)
+		sk = NULL;
+
 	tcp_v6_send_response(sk, skb, seq, ack_seq, 0, 0, 0, oif, key, 1, 0, 0);
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -1516,7 +1521,9 @@ do_time_wait:
 		break;
 	case TCP_TW_RST:
 		tcp_v6_restore_cb(skb);
-		goto no_tcp_socket;
+		tcp_v6_send_reset(sk, skb);
+		inet_twsk_deschedule_put(inet_twsk(sk));
+		goto discard_it;
 	case TCP_TW_SUCCESS:
 		;
 	}
-- 
2.4.10
