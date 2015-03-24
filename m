From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 4/5] tcp: md5: remove request sock argument of calc_md5_hash()
Date: Tue, 24 Mar 2015 15:58:55 -0700
Message-ID: <1427237936-19030-5-git-send-email-edumazet@google.com>
References: <1427237936-19030-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:34115 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbCXW7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:59:32 -0400
Received: by pdjy10 with SMTP id y10so755767pdj.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:59:32 -0700 (PDT)
In-Reply-To: <1427237936-19030-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since request and established sockets now have same base,
there is no need to pass two pointers to tcp_v4_md5_hash_skb()
or tcp_v6_md5_hash_skb()

Also add a const qualifier to their struct tcp_md5sig_key argument.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 29 +++++++++++++----------------
 net/ipv4/tcp_ipv4.c   | 17 +++++++----------
 net/ipv4/tcp_output.c |  4 ++--
 net/ipv6/tcp_ipv6.c   | 15 ++++++---------
 4 files changed, 28 insertions(+), 37 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fe60e00e1919..992be858c370 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1296,9 +1296,8 @@ struct tcp_md5sig_pool {
 };
 
 /* - functions */
-int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			const struct sock *sk, const struct request_sock *req,
-			const struct sk_buff *skb);
+int tcp_v4_md5_hash_skb(char *md5_hash, const struct tcp_md5sig_key *key,
+			const struct sock *sk, const struct sk_buff *skb);
 int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp);
 int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
@@ -1616,14 +1615,13 @@ struct tcp_sock_af_ops {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
 						struct sock *addr_sk);
-	int			(*calc_md5_hash) (char *location,
-						  struct tcp_md5sig_key *md5,
-						  const struct sock *sk,
-						  const struct request_sock *req,
-						  const struct sk_buff *skb);
-	int			(*md5_parse) (struct sock *sk,
-					      char __user *optval,
-					      int optlen);
+	int		(*calc_md5_hash)(char *location,
+					 const struct tcp_md5sig_key *md5,
+					 const struct sock *sk,
+					 const struct sk_buff *skb);
+	int		(*md5_parse)(struct sock *sk,
+				     char __user *optval,
+				     int optlen);
 #endif
 };
 
@@ -1632,11 +1630,10 @@ struct tcp_request_sock_ops {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
 						struct request_sock *req);
-	int			(*calc_md5_hash) (char *location,
-						  struct tcp_md5sig_key *md5,
-						  const struct sock *sk,
-						  const struct request_sock *req,
-						  const struct sk_buff *skb);
+	int		(*calc_md5_hash) (char *location,
+					  const struct tcp_md5sig_key *md5,
+					  const struct sock *sk,
+					  const struct sk_buff *skb);
 #endif
 	void (*init_req)(struct request_sock *req, struct sock *sk,
 			 struct sk_buff *skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d339a0488f51..79d5c641688c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -648,7 +648,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 		if (!key)
 			goto release_sk1;
 
-		genhash = tcp_v4_md5_hash_skb(newhash, key, NULL, NULL, skb);
+		genhash = tcp_v4_md5_hash_skb(newhash, key, NULL, skb);
 		if (genhash || memcmp(hash_location, newhash, 16) != 0)
 			goto release_sk1;
 	} else {
@@ -1102,8 +1102,8 @@ clear_hash_noput:
 	return 1;
 }
 
-int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			const struct sock *sk, const struct request_sock *req,
+int tcp_v4_md5_hash_skb(char *md5_hash, const struct tcp_md5sig_key *key,
+			const struct sock *sk,
 			const struct sk_buff *skb)
 {
 	struct tcp_md5sig_pool *hp;
@@ -1111,12 +1111,9 @@ int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 saddr, daddr;
 
-	if (sk) {
-		saddr = inet_sk(sk)->inet_saddr;
-		daddr = inet_sk(sk)->inet_daddr;
-	} else if (req) {
-		saddr = inet_rsk(req)->ir_loc_addr;
-		daddr = inet_rsk(req)->ir_rmt_addr;
+	if (sk) { /* valid for establish/request sockets */
+		saddr = sk->sk_rcv_saddr;
+		daddr = sk->sk_daddr;
 	} else {
 		const struct iphdr *iph = ip_hdr(skb);
 		saddr = iph->saddr;
@@ -1195,7 +1192,7 @@ static bool tcp_v4_inbound_md5_hash(struct sock *sk,
 	 */
 	genhash = tcp_v4_md5_hash_skb(newhash,
 				      hash_expected,
-				      NULL, NULL, skb);
+				      NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		net_info_ratelimited("MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5b7fad4b314c..501cf9d401c3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -986,7 +986,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (md5) {
 		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		tp->af_specific->calc_md5_hash(opts.hash_location,
-					       md5, sk, NULL, skb);
+					       md5, sk, skb);
 	}
 #endif
 
@@ -2973,7 +2973,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	/* Okay, we have all we need - do the md5 hash if needed */
 	if (md5)
 		tcp_rsk(req)->af_specific->calc_md5_hash(opts.hash_location,
-					       md5, NULL, req, skb);
+					       md5, req_to_sk(req), skb);
 	rcu_read_unlock();
 #endif
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 078e7d0f4cd8..57d1c41404ec 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -582,9 +582,9 @@ clear_hash_noput:
 	return 1;
 }
 
-static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+static int tcp_v6_md5_hash_skb(char *md5_hash,
+			       const struct tcp_md5sig_key *key,
 			       const struct sock *sk,
-			       const struct request_sock *req,
 			       const struct sk_buff *skb)
 {
 	const struct in6_addr *saddr, *daddr;
@@ -592,12 +592,9 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 	struct hash_desc *desc;
 	const struct tcphdr *th = tcp_hdr(skb);
 
-	if (sk) {
-		saddr = &inet6_sk(sk)->saddr;
+	if (sk) { /* valid for establish/request sockets */
+		saddr = &sk->sk_v6_rcv_saddr;
 		daddr = &sk->sk_v6_daddr;
-	} else if (req) {
-		saddr = &inet_rsk(req)->ir_v6_loc_addr;
-		daddr = &inet_rsk(req)->ir_v6_rmt_addr;
 	} else {
 		const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 		saddr = &ip6h->saddr;
@@ -662,7 +659,7 @@ static bool tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 	/* check the signature */
 	genhash = tcp_v6_md5_hash_skb(newhash,
 				      hash_expected,
-				      NULL, NULL, skb);
+				      NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		net_info_ratelimited("MD5 Hash %s for [%pI6c]:%u->[%pI6c]:%u\n",
@@ -880,7 +877,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		if (!key)
 			goto release_sk1;
 
-		genhash = tcp_v6_md5_hash_skb(newhash, key, NULL, NULL, skb);
+		genhash = tcp_v6_md5_hash_skb(newhash, key, NULL, skb);
 		if (genhash || memcmp(hash_location, newhash, 16) != 0)
 			goto release_sk1;
 	} else {
-- 
2.2.0.rc0.207.ga3a616c
