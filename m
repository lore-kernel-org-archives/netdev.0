From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 2/3] mlsxfrm: Various fixes
Date: Tue, 07 Nov 2006 11:17:10 -0600
Message-ID: <4550BF96.6080709@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:42392 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1754234AbWKGRRb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 12:17:31 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix SO_PEERSEC for tcp sockets to return the security context of
the peer (as represented by the SA from the peer) as opposed to the
SA used by the local/source socket.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h        |   14 ++++++++++
 include/net/request_sock.h      |    1 
 net/ipv4/tcp_input.c            |    2 +
 security/dummy.c                |    6 ++++
 security/selinux/hooks.c        |   21 ++++++++++++---
 security/selinux/include/xfrm.h |   12 ++++-----
 security/selinux/xfrm.c         |   40 ++----------------------------
 7 files changed, 49 insertions(+), 47 deletions(-)

--- net-2.6.xfrm1/include/linux/security.h	2006-10-25 09:34:47.000000000 -0500
+++ net-2.6.xfrm2/include/linux/security.h	2006-10-25 12:26:20.000000000 -0500
@@ -826,6 +826,8 @@ struct request_sock;
  *	Sets the openreq's sid to socket's sid with MLS portion taken from peer sid.
  * @inet_csk_clone:
  *	Sets the new child socket's sid to the openreq sid.
+ * @inet_conn_established:
+ *     Sets the connection's peersid to the secmark on skb.
  * @req_classify_flow:
  *	Sets the flow's sid to the openreq sid.
  *
@@ -1368,6 +1370,7 @@ struct security_operations {
 	int (*inet_conn_request)(struct sock *sk, struct sk_buff *skb,
 					struct request_sock *req);
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
+	void (*inet_conn_established)(struct sock *sk, struct sk_buff *skb);
 	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
@@ -2961,6 +2964,12 @@ static inline void security_inet_csk_clo
 {
 	security_ops->inet_csk_clone(newsk, req);
 }
+
+static inline void security_inet_conn_established(struct sock *sk,
+			struct sk_buff *skb)
+{
+	security_ops->inet_conn_established(sk, skb);
+}
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct socket * sock,
 					       struct socket * other, 
@@ -3110,6 +3119,11 @@ static inline void security_inet_csk_clo
 			const struct request_sock *req)
 {
 }
+
+static inline void security_inet_conn_established(struct sock *sk,
+			struct sk_buff *skb)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
--- net-2.6.xfrm1/include/net/request_sock.h	2006-10-25 11:20:48.000000000 -0500
+++ net-2.6.xfrm2/include/net/request_sock.h	2006-10-25 11:21:56.000000000 -0500
@@ -54,6 +54,7 @@ struct request_sock {
 	struct request_sock_ops		*rsk_ops;
 	struct sock			*sk;
 	u32				secid;
+	u32				peer_secid;
 };
 
 static inline struct request_sock *reqsk_alloc(struct request_sock_ops *ops)
--- net-2.6.xfrm1/net/ipv4/tcp_input.c	2006-10-25 12:29:06.000000000 -0500
+++ net-2.6.xfrm2/net/ipv4/tcp_input.c	2006-10-25 12:30:07.000000000 -0500
@@ -4230,6 +4230,8 @@ static int tcp_rcv_synsent_state_process
 		mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
+		security_inet_conn_established(sk, skb);
+
 		/* Make sure socket is routed, for correct metrics.  */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
--- net-2.6.xfrm1/security/dummy.c	2006-10-23 14:31:28.000000000 -0500
+++ net-2.6.xfrm2/security/dummy.c	2006-10-25 12:23:47.000000000 -0500
@@ -828,6 +828,11 @@ static inline void dummy_inet_csk_clone(
 {
 }
 
+static inline void dummy_inet_conn_established(struct sock *sk,
+			struct sk_buff *skb)
+{
+}
+
 static inline void dummy_req_classify_flow(const struct request_sock *req,
 			struct flowi *fl)
 {
@@ -1108,6 +1113,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, sock_graft);
 	set_to_dummy_if_null(ops, inet_conn_request);
 	set_to_dummy_if_null(ops, inet_csk_clone);
+	set_to_dummy_if_null(ops, inet_conn_established);
 	set_to_dummy_if_null(ops, req_classify_flow);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
--- net-2.6.xfrm1/security/selinux/include/xfrm.h	2006-10-23 14:31:56.000000000 -0500
+++ net-2.6.xfrm2/security/selinux/include/xfrm.h	2006-11-07 09:49:24.000000000 -0600
@@ -39,7 +39,6 @@ int selinux_xfrm_sock_rcv_skb(u32 sid, s
 			struct avc_audit_data *ad);
 int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad);
-u32 selinux_socket_getpeer_stream(struct sock *sk);
 u32 selinux_socket_getpeer_dgram(struct sk_buff *skb);
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
 #else
@@ -55,11 +54,6 @@ static inline int selinux_xfrm_postroute
 	return 0;
 }
 
-static inline int selinux_socket_getpeer_stream(struct sock *sk)
-{
-	return SECSID_NULL;
-}
-
 static inline int selinux_socket_getpeer_dgram(struct sk_buff *skb)
 {
 	return SECSID_NULL;
@@ -71,4 +65,10 @@ static inline int selinux_xfrm_decode_se
 }
 #endif
 
+static inline void selinux_skb_xfrm_sid(struct sk_buff *skb, u32 *sid)
+{
+	int err = selinux_xfrm_decode_session(skb, sid, 0);
+	BUG_ON(err);
+}
+
 #endif /* _SELINUX_XFRM_H_ */
--- net-2.6.xfrm1/security/selinux/hooks.c	2006-10-25 11:50:15.000000000 -0500
+++ net-2.6.xfrm2/security/selinux/hooks.c	2006-11-07 09:51:10.000000000 -0600
@@ -3528,8 +3528,10 @@ static int selinux_socket_getpeersec_str
 	}
 	else if (isec->sclass == SECCLASS_TCP_SOCKET) {
 		peer_sid = selinux_netlbl_socket_getpeersec_stream(sock);
-		if (peer_sid == SECSID_NULL)
-			peer_sid = selinux_socket_getpeer_stream(sock->sk);
+		if (peer_sid == SECSID_NULL) {
+			ssec = sock->sk->sk_security;
+			peer_sid = ssec->peer_sid;
+		}
 		if (peer_sid == SECSID_NULL) {
 			err = -ENOPROTOOPT;
 			goto out;
@@ -3640,11 +3642,11 @@ static int selinux_inet_conn_request(str
 		return 0;
 	}
 
-	err = selinux_xfrm_decode_session(skb, &peersid, 0);
-	BUG_ON(err);
+	selinux_skb_xfrm_sid(skb, &peersid);
 
 	if (peersid == SECSID_NULL) {
 		req->secid = sksec->sid;
+		req->peer_secid = 0;
 		return 0;
 	}
 
@@ -3653,6 +3655,7 @@ static int selinux_inet_conn_request(str
 		return err;
 
 	req->secid = newsid;
+	req->peer_secid = peersid;
 	return 0;
 }
 
@@ -3662,6 +3665,7 @@ static void selinux_inet_csk_clone(struc
 	struct sk_security_struct *newsksec = newsk->sk_security;
 
 	newsksec->sid = req->secid;
+	newsksec->peer_sid = req->peer_secid;
 	/* NOTE: Ideally, we should also get the isec->sid for the
 	   new socket in sync, but we don't have the isec available yet.
 	   So we will wait until sock_graft to do it, by which
@@ -3670,6 +3674,14 @@ static void selinux_inet_csk_clone(struc
 	selinux_netlbl_sk_security_init(newsksec, req->rsk_ops->family);
 }
 
+static void selinux_inet_conn_established(struct sock *sk,
+				struct sk_buff *skb)
+{
+	struct sk_security_struct *sksec = sk->sk_security;
+
+	selinux_skb_xfrm_sid(skb, &sksec->peer_sid);
+}
+
 static void selinux_req_classify_flow(const struct request_sock *req,
 				      struct flowi *fl)
 {
@@ -4732,6 +4744,7 @@ static struct security_operations selinu
 	.sock_graft =			selinux_sock_graft,
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
+	.inet_conn_established =	selinux_inet_conn_established,
 	.req_classify_flow =		selinux_req_classify_flow,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
--- net-2.6.xfrm1/security/selinux/xfrm.c	2006-10-23 14:30:02.000000000 -0500
+++ net-2.6.xfrm2/security/selinux/xfrm.c	2006-11-07 09:49:47.000000000 -0600
@@ -184,7 +184,8 @@ int selinux_xfrm_flow_state_match(struct
 }
 
 /*
- * LSM hook implementation that determines the sid for the session.
+ * LSM hook implementation that checks and/or returns the xfrm sid for the
+ * incoming packet.
  */
 
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
@@ -402,43 +403,8 @@ void selinux_xfrm_state_free(struct xfrm
 }
 
 /*
- * SELinux internal function to retrieve the context of a connected
- * (sk->sk_state == TCP_ESTABLISHED) TCP socket based on its security
- * association used to connect to the remote socket.
- *
- * Retrieve via getsockopt SO_PEERSEC.
- */
-u32 selinux_socket_getpeer_stream(struct sock *sk)
-{
-	struct dst_entry *dst, *dst_test;
-	u32 peer_sid = SECSID_NULL;
-
-	if (sk->sk_state != TCP_ESTABLISHED)
-		goto out;
-
-	dst = sk_dst_get(sk);
-	if (!dst)
-		goto out;
-
- 	for (dst_test = dst; dst_test != 0;
-      	     dst_test = dst_test->child) {
-		struct xfrm_state *x = dst_test->xfrm;
-
- 		if (x && selinux_authorizable_xfrm(x)) {
-	 	 	struct xfrm_sec_ctx *ctx = x->security;
-			peer_sid = ctx->ctx_sid;
-			break;
-		}
-	}
-	dst_release(dst);
-
-out:
-	return peer_sid;
-}
-
-/*
  * SELinux internal function to retrieve the context of a UDP packet
- * based on its security association used to connect to the remote socket.
+ * based on its security association.
  *
  * Retrieve via setsockopt IP_PASSSEC and recvmsg with control message
  * type SCM_SECURITY.
