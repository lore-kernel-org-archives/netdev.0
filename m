From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 10/13] tcp: unify tcp_v4_rtx_synack and tcp_v6_rtx_synack
Date: Wed, 25 Jun 2014 17:09:59 +0300
Message-ID: <1403705402-14388-11-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45776 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757352AbaFYOKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:36 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h     |  2 ++
 net/ipv4/tcp_ipv4.c   | 14 +-------------
 net/ipv4/tcp_output.c | 15 +++++++++++++++
 net/ipv6/tcp_ipv6.c   | 15 +--------------
 4 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8c05c25..8e9c28d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1573,6 +1573,8 @@ int tcp4_proc_init(void);
 void tcp4_proc_exit(void);
 #endif
 
+int tcp_rtx_synack(struct sock *sk, struct request_sock *req);
+
 /* TCP af-specific functions */
 struct tcp_sock_af_ops {
 #ifdef CONFIG_TCP_MD5SIG
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b5945ac..597dd9d75 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -845,18 +845,6 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	return err;
 }
 
-static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
-{
-	const struct  tcp_request_sock_ops *af_ops = tcp_rsk(req)->af_specific;
-	int res = af_ops->send_synack(sk, NULL, NULL, req, 0, NULL);
-
-	if (!res) {
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
-	}
-	return res;
-}
-
 /*
  *	IPv4 request_sock destructor.
  */
@@ -1269,7 +1257,7 @@ static struct dst_entry *tcp_v4_route_req(struct sock *sk, struct flowi *fl,
 struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 	.family		=	PF_INET,
 	.obj_size	=	sizeof(struct tcp_request_sock),
-	.rtx_syn_ack	=	tcp_v4_rtx_synack,
+	.rtx_syn_ack	=	tcp_rtx_synack,
 	.send_ack	=	tcp_v4_reqsk_send_ack,
 	.destructor	=	tcp_v4_reqsk_destructor,
 	.send_reset	=	tcp_v4_send_reset,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d92bce0..f8f2a94 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3299,3 +3299,18 @@ void tcp_send_probe0(struct sock *sk)
 					  TCP_RTO_MAX);
 	}
 }
+
+int tcp_rtx_synack(struct sock *sk, struct request_sock *req)
+{
+	const struct tcp_request_sock_ops *af_ops = tcp_rsk(req)->af_specific;
+	struct flowi fl;
+	int res;
+
+	res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL);
+	if (!res) {
+		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
+	}
+	return res;
+}
+EXPORT_SYMBOL(tcp_rtx_synack);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 210b610..41389bb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -506,19 +506,6 @@ done:
 	return err;
 }
 
-static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
-{
-	const struct tcp_request_sock_ops *af_ops = tcp_rsk(req)->af_specific;
-	struct flowi fl;
-	int res;
-
-	res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL);
-	if (!res) {
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
-	}
-	return res;
-}
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
@@ -759,7 +746,7 @@ static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
-	.rtx_syn_ack	=	tcp_v6_rtx_synack,
+	.rtx_syn_ack	=	tcp_rtx_synack,
 	.send_ack	=	tcp_v6_reqsk_send_ack,
 	.destructor	=	tcp_v6_reqsk_destructor,
 	.send_reset	=	tcp_v6_send_reset,
-- 
1.8.3.2
