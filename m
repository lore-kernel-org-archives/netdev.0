From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 05/13] tcp: add init_cookie_seq method to tcp_request_sock_ops
Date: Wed, 25 Jun 2014 17:09:54 +0300
Message-ID: <1403705402-14388-6-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45758 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757353AbaFYOKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:32 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the specific IPv4/IPv6 cookie sequence initialization to a new
method in tcp_request_sock_ops in preparation for unifying
tcp_v4_conn_request and tcp_v6_conn_request.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h   | 34 ++++++++++++++++++++--------------
 net/ipv4/tcp_ipv4.c |  5 ++++-
 net/ipv6/tcp_ipv6.c |  5 ++++-
 3 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7ad8ce2..086d00e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -495,13 +495,6 @@ u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 			      u16 *mssp);
 __u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
 			      __u16 *mss);
-#else
-static inline __u32 cookie_v4_init_sequence(struct sock *sk,
-					    const struct sk_buff *skb,
-					    __u16 *mss)
-{
-	return 0;
-}
 #endif
 
 __u32 cookie_init_timestamp(struct request_sock *req);
@@ -517,13 +510,6 @@ u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
 			      const struct tcphdr *th, u16 *mssp);
 __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
 			      __u16 *mss);
-#else
-static inline __u32 cookie_v6_init_sequence(struct sock *sk,
-					    struct sk_buff *skb,
-					    __u16 *mss)
-{
-	return 0;
-}
 #endif
 /* tcp_output.c */
 
@@ -1615,8 +1601,28 @@ struct tcp_request_sock_ops {
 #endif
 	void (*init_req)(struct request_sock *req, struct sock *sk,
 			 struct sk_buff *skb);
+#ifdef CONFIG_SYN_COOKIES
+	__u32 (*cookie_init_seq)(struct sock *sk, const struct sk_buff *skb,
+				 __u16 *mss);
+#endif
 };
 
+#ifdef CONFIG_SYN_COOKIES
+static inline __u32 cookie_init_sequence(const struct tcp_request_sock_ops *ops,
+					 struct sock *sk, struct sk_buff *skb,
+					 __u16 *mss)
+{
+	return ops->cookie_init_seq(sk, skb, mss);
+}
+#else
+static inline __u32 cookie_init_sequence(const struct tcp_request_sock_ops *ops,
+					 struct sock *sk, struct sk_buff *skb,
+					 __u16 *mss)
+{
+	return 0;
+}
+#endif
+
 int tcpv4_offload_init(void);
 
 void tcp_v4_init(void);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f86a86b..8c69e44 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1264,6 +1264,9 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 #endif
 	.init_req	=	tcp_v4_init_req,
+#ifdef CONFIG_SYN_COOKIES
+	.cookie_init_seq =	cookie_v4_init_sequence,
+#endif
 };
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
@@ -1331,7 +1334,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		TCP_ECN_create_request(req, skb, sock_net(sk));
 
 	if (want_cookie) {
-		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
+		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
 		req->cookie_ts = tmp_opt.tstamp_ok;
 	} else if (!isn) {
 		/* VJ's idea. We save last timestamp seen
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 87a360c..17710cf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -761,6 +761,9 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 #endif
 	.init_req	=	tcp_v6_init_req,
+#ifdef CONFIG_SYN_COOKIES
+	.cookie_init_seq =	cookie_v6_init_sequence,
+#endif
 };
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
@@ -1061,7 +1064,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	if (!isn) {
 		if (want_cookie) {
-			isn = cookie_v6_init_sequence(sk, skb, &req->mss);
+			isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
 			req->cookie_ts = tmp_opt.tstamp_ok;
 			goto have_isn;
 		}
-- 
1.8.3.2
