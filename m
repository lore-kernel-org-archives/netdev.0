From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 06/13] tcp: add route_req method to tcp_request_sock_ops
Date: Wed, 25 Jun 2014 17:09:55 +0300
Message-ID: <1403705402-14388-7-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45766 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757354AbaFYOKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:33 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create wrappers with same signature for the IPv4/IPv6 request routing
calls and use these wrappers (via route_req method from
tcp_request_sock_ops) in tcp_v4_conn_request and tcp_v6_conn_request
with the purpose of unifying the two functions in a later patch.

We can later drop the wrapper functions and modify inet_csk_route_req
and inet6_cks_route_req to use the same signature.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h   |  3 +++
 net/ipv4/tcp_ipv4.c | 36 +++++++++++++++++++++++++++++-------
 net/ipv6/tcp_ipv6.c | 26 ++++++++++++++++++++------
 3 files changed, 52 insertions(+), 13 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 086d00e..59fcc59 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1605,6 +1605,9 @@ struct tcp_request_sock_ops {
 	__u32 (*cookie_init_seq)(struct sock *sk, const struct sk_buff *skb,
 				 __u16 *mss);
 #endif
+	struct dst_entry *(*route_req)(struct sock *sk, struct flowi *fl,
+				       const struct request_sock *req,
+				       bool *strict);
 };
 
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8c69e44..54fbbd8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1248,6 +1248,22 @@ static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
 	ireq->opt = tcp_v4_save_options(skb);
 }
 
+static struct dst_entry *tcp_v4_route_req(struct sock *sk, struct flowi *fl,
+					  const struct request_sock *req,
+					  bool *strict)
+{
+	struct dst_entry *dst = inet_csk_route_req(sk, &fl->u.ip4, req);
+
+	if (strict) {
+		if (fl->u.ip4.daddr == inet_rsk(req)->ir_rmt_addr)
+			*strict = true;
+		else
+			*strict = false;
+	}
+
+	return dst;
+}
+
 struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 	.family		=	PF_INET,
 	.obj_size	=	sizeof(struct tcp_request_sock),
@@ -1267,6 +1283,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 #ifdef CONFIG_SYN_COOKIES
 	.cookie_init_seq =	cookie_v4_init_sequence,
 #endif
+	.route_req	=	tcp_v4_route_req,
 };
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
@@ -1346,11 +1363,13 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		 * timewait bucket, so that all the necessary checks
 		 * are made in the function processing timewait state.
 		 */
-		if (tmp_opt.saw_tstamp &&
-		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet_csk_route_req(sk, &fl4, req)) != NULL &&
-		    fl4.daddr == saddr) {
-			if (!tcp_peer_is_proven(req, dst, true)) {
+		if (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_recycle) {
+			bool strict;
+
+			dst = af_ops->route_req(sk, (struct flowi *)&fl4, req,
+						&strict);
+			if (dst && strict &&
+			    !tcp_peer_is_proven(req, dst, true)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
 				goto drop_and_release;
 			}
@@ -1374,8 +1393,11 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 		isn = tcp_v4_init_sequence(skb);
 	}
-	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
-		goto drop_and_free;
+	if (!dst) {
+		dst = af_ops->route_req(sk, (struct flowi *)&fl4, req, NULL);
+		if (!dst)
+			goto drop_and_free;
+	}
 
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_openreq_init_rwin(req, sk, dst);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 17710cf..d780d88 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -745,6 +745,16 @@ static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
 	}
 }
 
+static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
+					  const struct request_sock *req,
+					  bool *strict)
+{
+	if (strict)
+		*strict = true;
+	return inet6_csk_route_req(sk, &fl->u.ip6, req);
+}
+
+
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
@@ -764,6 +774,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 #ifdef CONFIG_SYN_COOKIES
 	.cookie_init_seq =	cookie_v6_init_sequence,
 #endif
+	.route_req	=	tcp_v6_route_req,
 };
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
@@ -1078,10 +1089,10 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		 * timewait bucket, so that all the necessary checks
 		 * are made in the function processing timewait state.
 		 */
-		if (tmp_opt.saw_tstamp &&
-		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet6_csk_route_req(sk, &fl6, req)) != NULL) {
-			if (!tcp_peer_is_proven(req, dst, true)) {
+		if (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_recycle) {
+			dst = af_ops->route_req(sk, (struct flowi *)&fl6, req,
+						NULL);
+			if (dst && !tcp_peer_is_proven(req, dst, true)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
 				goto drop_and_release;
 			}
@@ -1110,8 +1121,11 @@ have_isn:
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_release;
 
-	if (!dst && (dst = inet6_csk_route_req(sk, &fl6, req)) == NULL)
-		goto drop_and_free;
+	if (!dst) {
+		dst = af_ops->route_req(sk, (struct flowi *)&fl6, req, NULL);
+		if (!dst)
+			goto drop_and_free;
+	}
 
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_openreq_init_rwin(req, sk, dst);
-- 
1.8.3.2
