From: Shawn Lu <shawn.lu@ericsson.com>
Subject: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Mon, 30 Jan 2012 18:07:18 -0800
Message-ID: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiaoclu@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:40582 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab2AaCHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 21:07:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP RST mechanism is broken in TCP md5(RFC2385). When
connection is gone, md5 key is lost, sending RST without
md5 hash is deem to ignored by peer. This can be a problem
since RST help protocal like bgp fast recove from peer crash.

In most case, users of tcp md5, such as bgp and ldp, have listeners
on both sides. md5 keys for peers are saved in listening socket.
When passive side connection is gone, we can still get md5 key
from listening socket. When active side of connection is gone,
we can try to find listening socket through source port, and
then md5 key.
we are not loosing sercuriy here: packet is valified checked with
md5 hash. No RST is generated if md5 hash doesn't match or no md5
key can be found.

Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
---
 net/ipv4/tcp_ipv4.c |   31 ++++++++++++++++++++++++++++++-
 net/ipv6/tcp_ipv6.c |   34 ++++++++++++++++++++++++++++++++--
 2 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 337ba4c..b2358b4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -601,6 +601,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct ip_reply_arg arg;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
+	 __u8 *hash_location = NULL;
+	unsigned char newhash[16];
+	int genhash;
 #endif
 	struct net *net;
 
@@ -631,7 +634,33 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.iov[0].iov_len  = sizeof(rep.th);
 
 #ifdef CONFIG_TCP_MD5SIG
-	key = sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->saddr) : NULL;
+	hash_location = tcp_parse_md5sig_option(th);
+	if (!sk && hash_location) {
+		/*
+		 * active side is lost. Try to find listening socket through
+		 * source port, and then find md5 key through listening socket.
+		 * we are not loose security here:
+		 * Incoming packet is checked with md5 hash with finding key,
+		 * no RST generated if md5 hash doesn't match.
+		 */
+		sk = __inet_lookup_listener(dev_net(skb_dst(skb)->dev),
+					    &tcp_hashinfo, ip_hdr(skb)->daddr,
+					    ntohs(th->source), inet_iif(skb));
+		/* don't send rst if it can't find key */
+		if (!sk)
+			return;
+		key = tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->saddr);
+		if (!key)
+			return;
+		genhash = tcp_v4_md5_hash_skb(newhash, key,
+					      NULL, NULL, skb);
+		if (genhash || memcmp(hash_location, newhash, 16) != 0)
+			return;
+
+	} else {
+		key = sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->saddr) : NULL;
+	}
+
 	if (key) {
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
 				   (TCPOPT_NOP << 16) |
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3edd05a..1da99fd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1074,6 +1074,12 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	const struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
 	struct tcp_md5sig_key *key = NULL;
+#ifdef CONFIG_TCP_MD5SIG
+	__u8 *hash_location = NULL;
+	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	unsigned char newhash[16];
+	int genhash;
+#endif
 
 	if (th->rst)
 		return;
@@ -1082,8 +1088,32 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
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
+		sk = inet6_lookup_listener(dev_net(skb_dst(skb)->dev),
+					   &tcp_hashinfo, &ipv6h->daddr,
+					   ntohs(th->source), inet6_iif(skb));
+		if (!sk)
+			return;
+
+		key = tcp_v6_md5_do_lookup(sk, &ipv6h->saddr);
+		if (!key)
+			return;
+
+		genhash = tcp_v6_md5_hash_skb(newhash, key,
+					      NULL, NULL, skb);
+		if (genhash || memcmp(hash_location, newhash, 16) != 0)
+			return;
+	} else {
+		key = sk ? tcp_v6_md5_do_lookup(sk, &ipv6h->saddr) : NULL;
+	}
 #endif
 
 	if (th->ack)
-- 
1.7.0.4
