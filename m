From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 09/13] tcp: add send_synack method to tcp_request_sock_ops
Date: Wed, 25 Jun 2014 17:09:58 +0300
Message-ID: <1403705402-14388-10-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45766 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757363AbaFYOKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:35 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new tcp_request_sock_ops method to unify the IPv4/IPv6
signature for tcp_v[46]_send_synack. This allows us to later unify
tcp_v4_rtx_synack with tcp_v6_rtx_synack and tcp_v4_conn_request with
tcp_v4_conn_request.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h   |  3 +++
 net/ipv4/tcp_ipv4.c |  9 ++++++---
 net/ipv6/tcp_ipv6.c | 14 ++++++++------
 3 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8cacf0d..8c05c25 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1609,6 +1609,9 @@ struct tcp_request_sock_ops {
 				       const struct request_sock *req,
 				       bool *strict);
 	__u32 (*init_seq)(const struct sk_buff *skb);
+	int (*send_synack)(struct sock *sk, struct dst_entry *dst,
+			   struct flowi *fl, struct request_sock *req,
+			   u16 queue_mapping, struct tcp_fastopen_cookie *foc);
 };
 
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4347826..b5945ac 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -814,6 +814,7 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  *	socket.
  */
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
+			      struct flowi *fl,
 			      struct request_sock *req,
 			      u16 queue_mapping,
 			      struct tcp_fastopen_cookie *foc)
@@ -846,7 +847,8 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 
 static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
 {
-	int res = tcp_v4_send_synack(sk, NULL, req, 0, NULL);
+	const struct  tcp_request_sock_ops *af_ops = tcp_rsk(req)->af_specific;
+	int res = af_ops->send_synack(sk, NULL, NULL, req, 0, NULL);
 
 	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
@@ -1285,6 +1287,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 #endif
 	.route_req	=	tcp_v4_route_req,
 	.init_seq	=	tcp_v4_init_sequence,
+	.send_synack	=	tcp_v4_send_synack,
 };
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
@@ -1404,8 +1407,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_openreq_init_rwin(req, sk, dst);
 	fastopen = !want_cookie &&
 		   tcp_try_fastopen(sk, skb, req, &foc, dst);
-	err = tcp_v4_send_synack(sk, dst, req,
-				 skb_get_queue_mapping(skb), &foc);
+	err = af_ops->send_synack(sk, dst, NULL, req,
+				  skb_get_queue_mapping(skb), &foc);
 	if (!fastopen) {
 		if (err || want_cookie)
 			goto drop_and_free;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2fd886f..210b610 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -470,13 +470,14 @@ out:
 
 
 static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
-			      struct flowi6 *fl6,
+			      struct flowi *fl,
 			      struct request_sock *req,
 			      u16 queue_mapping,
 			      struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct flowi6 *fl6 = &fl->u.ip6;
 	struct sk_buff *skb;
 	int err = -ENOMEM;
 
@@ -507,10 +508,11 @@ done:
 
 static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
 {
-	struct flowi6 fl6;
+	const struct tcp_request_sock_ops *af_ops = tcp_rsk(req)->af_specific;
+	struct flowi fl;
 	int res;
 
-	res = tcp_v6_send_synack(sk, NULL, &fl6, req, 0, NULL);
+	res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL);
 	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
@@ -754,7 +756,6 @@ static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
 	return inet6_csk_route_req(sk, &fl->u.ip6, req);
 }
 
-
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
@@ -776,6 +777,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 #endif
 	.route_req	=	tcp_v6_route_req,
 	.init_seq	=	tcp_v6_init_sequence,
+	.send_synack	=	tcp_v6_send_synack,
 };
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
@@ -1128,8 +1130,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_openreq_init_rwin(req, sk, dst);
 	fastopen = !want_cookie &&
 		   tcp_try_fastopen(sk, skb, req, &foc, dst);
-	err = tcp_v6_send_synack(sk, dst, &fl6, req,
-				 skb_get_queue_mapping(skb), &foc);
+	err = af_ops->send_synack(sk, dst, (struct flowi *)&fl6, req,
+				  skb_get_queue_mapping(skb), &foc);
 	if (!fastopen) {
 		if (err || want_cookie)
 			goto drop_and_free;
-- 
1.8.3.2
