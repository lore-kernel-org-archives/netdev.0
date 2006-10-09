From: paul.moore@hp.com
Subject: [PATCH 09/11] secid reconciliation: Track peersecid at connection establishment
Date: Mon, 09 Oct 2006 15:42:32 -0400
Message-ID: <20061009195851.444828000@hp.com>
References: <20061009194223.402695000@hp.com>
Cc: vyekkirala@TrustedCS.com, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:47007 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S964791AbWJIT6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 15:58:54 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=secid-9
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>

This tracks the peer's secid at connection establishment time
for clients, for later retrieval using SO_PEERSEC.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h |   14 ++++++++++++++
 net/ipv4/tcp_input.c     |    2 ++
 security/dummy.c         |    6 ++++++
 security/selinux/hooks.c |    9 +++++++++
 4 files changed, 31 insertions(+)

Index: net-2.6_secidfinal/include/linux/security.h
===================================================================
--- net-2.6_secidfinal.orig/include/linux/security.h
+++ net-2.6_secidfinal/include/linux/security.h
@@ -826,6 +826,8 @@ struct request_sock;
  *	Sets the openreq's sid to socket's sid with MLS portion taken from peer sid.
  * @inet_csk_clone:
  *	Sets the new child socket's sid to the openreq sid.
+ * @inet_conn_established:
+ *	Sets the connection's peersid to the secmark on skb.
  * @req_classify_flow:
  *	Sets the flow's sid to the openreq sid.
  * @skb_flow_in:
@@ -1380,6 +1382,7 @@ struct security_operations {
 	int (*inet_conn_request)(struct sock *sk, struct sk_buff *skb,
 					struct request_sock *req);
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
+	void (*inet_conn_established)(struct sock *sk, struct sk_buff *skb);
 	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
 	int (*skb_flow_in)(struct sk_buff *skb, unsigned short family);
 	int (*skb_flow_out)(struct sk_buff *skb, u32 nf_secid);
@@ -2986,6 +2989,12 @@ static inline void security_inet_csk_clo
 {
 	security_ops->inet_csk_clone(newsk, req);
 }
+
+static inline void security_inet_conn_established(struct sock *sk,
+					struct sk_buff *skb)
+{
+	security_ops->inet_conn_established(sk, skb);
+}
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct socket * sock,
 					       struct socket * other, 
@@ -3147,6 +3156,11 @@ static inline void security_inet_csk_clo
 			const struct request_sock *req)
 {
 }
+
+static inline void security_inet_conn_established(struct sock *sk,
+					struct sk_buff *skb)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
Index: net-2.6_secidfinal/net/ipv4/tcp_input.c
===================================================================
--- net-2.6_secidfinal.orig/net/ipv4/tcp_input.c
+++ net-2.6_secidfinal/net/ipv4/tcp_input.c
@@ -4230,6 +4230,8 @@ static int tcp_rcv_synsent_state_process
 		mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
+		security_inet_conn_established(sk, skb);
+
 		/* Make sure socket is routed, for correct metrics.  */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
Index: net-2.6_secidfinal/security/dummy.c
===================================================================
--- net-2.6_secidfinal.orig/security/dummy.c
+++ net-2.6_secidfinal/security/dummy.c
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
@@ -1118,6 +1123,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, sock_graft);
 	set_to_dummy_if_null(ops, inet_conn_request);
 	set_to_dummy_if_null(ops, inet_csk_clone);
+	set_to_dummy_if_null(ops, inet_conn_established);
 	set_to_dummy_if_null(ops, req_classify_flow);
 	set_to_dummy_if_null(ops, skb_flow_in);
 	set_to_dummy_if_null(ops, skb_flow_out);
Index: net-2.6_secidfinal/security/selinux/hooks.c
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/hooks.c
+++ net-2.6_secidfinal/security/selinux/hooks.c
@@ -3683,6 +3683,14 @@ static void selinux_inet_csk_clone(struc
 	selinux_netlbl_sk_security_init(newsksec, req->rsk_ops->family);
 }
 
+static void selinux_inet_conn_established(struct sock *sk,
+				   struct sk_buff *skb)
+{
+	struct sk_security_struct *sksec = sk->sk_security;
+
+	sksec->peer_sid = skb->secmark;
+}
+
 static void selinux_req_classify_flow(const struct request_sock *req,
 				      struct flowi *fl)
 {
@@ -4815,6 +4823,7 @@ static struct security_operations selinu
 	.sock_graft =			selinux_sock_graft,
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
+	.inet_conn_established =	selinux_inet_conn_established,
 	.req_classify_flow =		selinux_req_classify_flow,
 	.skb_flow_in =			selinux_skb_flow_in,
 	.skb_flow_out =			selinux_skb_flow_out,

--
paul moore
linux security @ hp
