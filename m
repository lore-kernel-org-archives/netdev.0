From: Shawn Lu <shawn.lu@ericsson.com>
Subject: [PATCH] tcp: md5: RST: getting md5 key from listener
Date: Wed, 1 Feb 2012 00:35:48 -0800
Message-ID: <1328085348-6771-1-git-send-email-shawn.lu@ericsson.com>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:49617 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400Ab2BAIgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 03:36:40 -0500
In-Reply-To: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP RST mechanism is broken in TCP md5(RFC2385). When
connection is gone, md5 key is lost, sending RST
without md5 hash is deem to ignored by peer. This can
be a problem since RST help protocal like bgp to fast
recove from peer crash.

In most case, users of tcp md5, such as bgp and ldp,
have listener on both sides to accept connection from peer.
md5 keys for peers are saved in listening socket.

There are two cases in finding md5 key when connection is
lost:
1.Passive receive RST: The message is send to well known port,
tcp will associate it with listner. md5 key is gotten from
listener.

2.Active receive RST (no sock): The message is send to ative
side, there is no socket associated with the message. In this
case, finding listener from source port, then find md5 key from
listener.

we are not loosing sercuriy here:
packet is checked with md5 hash. No RST is generated
if md5 hash doesn't match or no md5 key can be found.

Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
---
v4: change title and change log. 
regerated after  "tcp: md5: protects md5sig_info with RCU"

 net/ipv4/tcp_ipv4.c |   45 ++++++++++++++++++++++++++++++++++++++++++---
 net/ipv6/tcp_ipv6.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 83 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 567cca9..90e4793 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -593,6 +593,10 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct ip_reply_arg arg;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
+	const __u8 *hash_location = NULL;
+	unsigned char newhash[16];
+	int genhash;
+	struct sock *sk1 = NULL;
 #endif
 	struct net *net;
 
@@ -623,9 +627,36 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.iov[0].iov_len  = sizeof(rep.th);
 
 #ifdef CONFIG_TCP_MD5SIG
-	key = sk ? tcp_md5_do_lookup(sk,
-				     (union tcp_md5_addr *)&ip_hdr(skb)->saddr,
-				     AF_INET) : NULL;
+	hash_location = tcp_parse_md5sig_option(th);
+	if (!sk && hash_location) {
+		/*
+		 * active side is lost. Try to find listening socket through
+		 * source port, and then find md5 key through listening socket.
+		 * we are not loose security here:
+		 * Incoming packet is checked with md5 hash with finding key,
+		 * no RST generated if md5 hash doesn't match.
+		 */
+		sk1 = __inet_lookup_listener(dev_net(skb_dst(skb)->dev),
+					     &tcp_hashinfo, ip_hdr(skb)->daddr,
+					     ntohs(th->source), inet_iif(skb));
+		/* don't send rst if it can't find key */
+		if (!sk1)
+			return;
+		rcu_read_lock();
+		key = tcp_md5_do_lookup(sk1, (union tcp_md5_addr *)
+					&ip_hdr(skb)->saddr, AF_INET);
+		if (!key)
+			goto release_sk1;
+
+		genhash = tcp_v4_md5_hash_skb(newhash, key, NULL, NULL, skb);
+		if (genhash || memcmp(hash_location, newhash, 16) != 0)
+			goto release_sk1;
+	} else {
+		key = sk ? tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
+					     &ip_hdr(skb)->saddr,
+					     AF_INET) : NULL;
+	}
+
 	if (key) {
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
 				   (TCPOPT_NOP << 16) |
@@ -653,6 +684,14 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
+
+#ifdef CONFIG_TCP_MD5SIG
+release_sk1:
+	if (sk1) {
+		rcu_read_unlock();
+		sock_put(sk1);
+	}
+#endif
 }
 
 /* The code following below sending ACKs in SYN-RECV and TIME-WAIT states
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c250181..d16414c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -923,6 +923,13 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	const struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
 	struct tcp_md5sig_key *key = NULL;
+#ifdef CONFIG_TCP_MD5SIG
+	const __u8 *hash_location = NULL;
+	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	unsigned char newhash[16];
+	int genhash;
+	struct sock *sk1 = NULL;
+#endif
 
 	if (th->rst)
 		return;
@@ -931,8 +938,32 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		return;
 
 #ifdef CONFIG_TCP_MD5SIG
-	if (sk)
-		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->saddr);
+	hash_location = tcp_parse_md5sig_option(th);
+	if (!sk && hash_location) {
+		/*
+		 * active side is lost. Try to find listening socket through
+		 * source port, and then find md5 key through listening socket.
+		 * we are not loose security here:
+		 * Incoming packet is checked with md5 hash with finding key,
+		 * no RST generated if md5 hash doesn't match.
+		 */
+		sk1 = inet6_lookup_listener(dev_net(skb_dst(skb)->dev),
+					   &tcp_hashinfo, &ipv6h->daddr,
+					   ntohs(th->source), inet6_iif(skb));
+		if (!sk1)
+			return;
+
+		rcu_read_lock();
+		key = tcp_v6_md5_do_lookup(sk1, &ipv6h->saddr);
+		if (!key)
+			goto release_sk1;
+
+		genhash = tcp_v6_md5_hash_skb(newhash, key, NULL, NULL, skb);
+		if (genhash || memcmp(hash_location, newhash, 16) != 0)
+			goto release_sk1;
+	} else {
+		key = sk ? tcp_v6_md5_do_lookup(sk, &ipv6h->saddr) : NULL;
+	}
 #endif
 
 	if (th->ack)
@@ -942,6 +973,14 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 			  (th->doff << 2);
 
 	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1, 0);
+
+#ifdef CONFIG_TCP_MD5SIG
+release_sk1:
+	if (sk1) {
+		rcu_read_unlock();
+		sock_put(sk1);
+	}
+#endif
 }
 
 static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts,
-- 
1.7.0.4
