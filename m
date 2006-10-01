From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 9/9] secid reconciliation-v04: Track peersecid at connection
 establishment
Date: Sun, 01 Oct 2006 16:27:15 -0500
Message-ID: <452032B3.7050902@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:3988 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932412AbWJAV1l
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 17:27:41 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This tracks the peer's secid at connection establishment time
for clients, for later retrieval using SO_PEERSEC.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h |   14 ++++++++++++++
 net/ipv4/tcp_input.c     |    2 ++
 security/dummy.c         |    6 ++++++
 security/selinux/hooks.c |    9 +++++++++
 4 files changed, 31 insertions(+)

--- net-2.6.sid2/include/linux/security.h	2006-10-01 13:07:43.000000000 -0500
+++ net-2.6/include/linux/security.h	2006-10-01 15:18:23.000000000 -0500
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
@@ -2985,6 +2988,12 @@ static inline void security_inet_csk_clo
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
@@ -3146,6 +3155,11 @@ static inline void security_inet_csk_clo
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
--- net-2.6.sid2/net/ipv4/tcp_input.c	2006-10-01 15:09:12.000000000 -0500
+++ net-2.6/net/ipv4/tcp_input.c	2006-10-01 15:17:39.000000000 -0500
@@ -4230,6 +4230,8 @@ static int tcp_rcv_synsent_state_process
 		mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
+		security_inet_conn_established(sk, skb);
+
 		/* Make sure socket is routed, for correct metrics.  */
 		icsk->icsk_af_ops->rebuild_header(sk);
 
--- net-2.6.sid2/security/dummy.c	2006-09-27 13:02:12.000000000 -0500
+++ net-2.6/security/dummy.c	2006-10-01 15:45:26.000000000 -0500
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
--- net-2.6.sid2/security/selinux/hooks.c	2006-10-01 12:34:28.000000000 -0500
+++ net-2.6/security/selinux/hooks.c	2006-10-01 15:43:12.000000000 -0500
@@ -3669,6 +3669,14 @@ static void selinux_inet_csk_clone(struc
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
@@ -4800,6 +4808,7 @@ static struct security_operations selinu
 	.sock_graft =			selinux_sock_graft,
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
+	.inet_conn_established =	selinux_inet_conn_established,
 	.req_classify_flow =		selinux_req_classify_flow,
 	.skb_flow_in =			selinux_skb_flow_in,
 	.skb_flow_out =			selinux_skb_flow_out,
