From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 08/13] tcp: add init_seq method to tcp_request_sock_ops
Date: Wed, 25 Jun 2014 17:09:57 +0300
Message-ID: <1403705402-14388-9-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45758 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757361AbaFYOKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:34 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More work in preparation of unifying tcp_v4_conn_request and
tcp_v6_conn_request: indirect the init sequence calls via the
tcp_request_sock_ops.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h   | 1 +
 net/ipv4/tcp_ipv4.c | 5 +++--
 net/ipv6/tcp_ipv6.c | 3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 59fcc59..8cacf0d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1608,6 +1608,7 @@ struct tcp_request_sock_ops {
 	struct dst_entry *(*route_req)(struct sock *sk, struct flowi *fl,
 				       const struct request_sock *req,
 				       bool *strict);
+	__u32 (*init_seq)(const struct sk_buff *skb);
 };
 
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 54fbbd8..4347826 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -99,7 +99,7 @@ static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 struct inet_hashinfo tcp_hashinfo;
 EXPORT_SYMBOL(tcp_hashinfo);
 
-static inline __u32 tcp_v4_init_sequence(const struct sk_buff *skb)
+static  __u32 tcp_v4_init_sequence(const struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
 					  ip_hdr(skb)->saddr,
@@ -1284,6 +1284,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.cookie_init_seq =	cookie_v4_init_sequence,
 #endif
 	.route_req	=	tcp_v4_route_req,
+	.init_seq	=	tcp_v4_init_sequence,
 };
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
@@ -1391,7 +1392,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop_and_release;
 		}
 
-		isn = tcp_v4_init_sequence(skb);
+		isn = af_ops->init_seq(skb);
 	}
 	if (!dst) {
 		dst = af_ops->route_req(sk, (struct flowi *)&fl4, req, NULL);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 91b8a2e..2fd886f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -775,6 +775,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.cookie_init_seq =	cookie_v6_init_sequence,
 #endif
 	.route_req	=	tcp_v6_route_req,
+	.init_seq	=	tcp_v6_init_sequence,
 };
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
@@ -1114,7 +1115,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop_and_release;
 		}
 
-		isn = tcp_v6_init_sequence(skb);
+		isn = af_ops->init_seq(skb);
 	}
 
 	if (!dst) {
-- 
1.8.3.2
