From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 2/3] tcp: send_reset: test for non-NULL sk first
Date: Mon, 21 Dec 2015 21:29:25 +0100
Message-ID: <1450729766-14926-3-git-send-email-fw@strlen.de>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45115 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751253AbbLUUfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 15:35:18 -0500
In-Reply-To: <1450729766-14926-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_md5_do_lookup requires a full socket, so once we extend
_send_reset() to also accept timewait socket we would have to change

if (!sk && hash_location)

to something like

if ((!sk || !sk_fullsock(sk)) && hash_location) {
  ...
} else {
  (sk && sk_fullsock(sk)) tcp_md5_do_lookup()
}

Switch the two branches: check if we have a socket first, then
fall back to a listener lookup if we saw a md5 option (hash_location).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_ipv4.c | 11 +++++------
 net/ipv6/tcp_ipv6.c |  6 +++---
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 46e92fb..eb29c2f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -587,7 +587,7 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 	} rep;
 	struct ip_reply_arg arg;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
+	struct tcp_md5sig_key *key = NULL;
 	const __u8 *hash_location = NULL;
 	unsigned char newhash[16];
 	int genhash;
@@ -627,7 +627,10 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 	net = sk ? sock_net(sk) : dev_net(skb_dst(skb)->dev);
 #ifdef CONFIG_TCP_MD5SIG
 	hash_location = tcp_parse_md5sig_option(th);
-	if (!sk && hash_location) {
+	if (sk) {
+		key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
+					&ip_hdr(skb)->saddr, AF_INET);
+	} else if (hash_location) {
 		/*
 		 * active side is lost. Try to find listening socket through
 		 * source port, and then find md5 key through listening socket.
@@ -651,10 +654,6 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		genhash = tcp_v4_md5_hash_skb(newhash, key, NULL, skb);
 		if (genhash || memcmp(hash_location, newhash, 16) != 0)
 			goto release_sk1;
-	} else {
-		key = sk ? tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
-					     &ip_hdr(skb)->saddr,
-					     AF_INET) : NULL;
 	}
 
 	if (key) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f03d2b0..32fa0de 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -854,7 +854,9 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 
 #ifdef CONFIG_TCP_MD5SIG
 	hash_location = tcp_parse_md5sig_option(th);
-	if (!sk && hash_location) {
+	if (sk) {
+		key = tcp_v6_md5_do_lookup(sk, &ipv6h->saddr);
+	} else if (hash_location) {
 		/*
 		 * active side is lost. Try to find listening socket through
 		 * source port, and then find md5 key through listening socket.
@@ -877,8 +879,6 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 		genhash = tcp_v6_md5_hash_skb(newhash, key, NULL, skb);
 		if (genhash || memcmp(hash_location, newhash, 16) != 0)
 			goto release_sk1;
-	} else {
-		key = sk ? tcp_v6_md5_do_lookup(sk, &ipv6h->saddr) : NULL;
 	}
 #endif
 
-- 
2.4.10
