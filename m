From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 12/13] tcp: add queue_add_hash to tcp_request_sock_ops
Date: Wed, 25 Jun 2014 17:10:01 +0300
Message-ID: <1403705402-14388-13-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45766 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757371AbaFYOKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:36 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add queue_add_hash member to tcp_request_sock_ops so that we can later
unify tcp_v4_conn_request and tcp_v6_conn_request.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h   | 2 ++
 net/ipv4/tcp_ipv4.c | 3 ++-
 net/ipv6/tcp_ipv6.c | 3 ++-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 30fe98b..cec6e2c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1615,6 +1615,8 @@ struct tcp_request_sock_ops {
 	int (*send_synack)(struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
 			   u16 queue_mapping, struct tcp_fastopen_cookie *foc);
+	void (*queue_hash_add)(struct sock *sk, struct request_sock *req,
+			       const unsigned long timeout);
 };
 
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 499d440..845c39d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1277,6 +1277,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.route_req	=	tcp_v4_route_req,
 	.init_seq	=	tcp_v4_init_sequence,
 	.send_synack	=	tcp_v4_send_synack,
+	.queue_hash_add =	inet_csk_reqsk_queue_hash_add,
 };
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
@@ -1403,7 +1404,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop_and_free;
 
 		tcp_rsk(req)->listener = NULL;
-		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	}
 
 	return 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ad65833..8232bc7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -767,6 +767,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.route_req	=	tcp_v6_route_req,
 	.init_seq	=	tcp_v6_init_sequence,
 	.send_synack	=	tcp_v6_send_synack,
+	.queue_hash_add =	inet6_csk_reqsk_queue_hash_add,
 };
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
@@ -1126,7 +1127,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop_and_free;
 
 		tcp_rsk(req)->listener = NULL;
-		inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	}
 	return 0;
 
-- 
1.8.3.2
