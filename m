From: paul.moore@hp.com
Subject: [PATCH 07/11] secid reconciliation: Enforcement for SELinux
Date: Mon, 09 Oct 2006 15:42:30 -0400
Message-ID: <20061009195850.209607000@hp.com>
References: <20061009194223.402695000@hp.com>
Cc: vyekkirala@TrustedCS.com, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:43744 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S964798AbWJIT7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 15:59:32 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=secid-7
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>

This defines SELinux enforcement of the 2 new LSM hooks as well
as related changes elsewhere in the SELinux code.

This also now keeps track of the peersid thru the establishment
of a connection on the server (tracking peersid on the client
is covered later in this patch set).

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 security/selinux/hooks.c        |  151 +++++++++++++++++++++++++++++++---------
 security/selinux/include/xfrm.h |   11 +-
 security/selinux/xfrm.c         |   66 +++++++----------
 3 files changed, 152 insertions(+), 76 deletions(-)

Index: net-2.6_secidfinal/security/selinux/hooks.c
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/hooks.c
+++ net-2.6_secidfinal/security/selinux/hooks.c
@@ -3461,8 +3461,12 @@ static int selinux_sock_rcv_skb_compat(s
 
 		err = avc_has_perm(sock_sid, port_sid,
 				   sock_class, recv_perm, ad);
+		if (err)
+			goto out;
 	}
 
+	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb, ad);
+
 out:
 	return err;
 }
@@ -3501,10 +3505,6 @@ static int selinux_socket_sock_rcv_skb(s
 		goto out;
 
 	err = selinux_netlbl_sock_rcv_skb(sksec, skb, &ad);
-	if (err)
-		goto out;
-
-	err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
 out:	
 	return err;
 }
@@ -3517,7 +3517,7 @@ static int selinux_socket_getpeersec_str
 	u32 scontext_len;
 	struct sk_security_struct *ssec;
 	struct inode_security_struct *isec;
-	u32 peer_sid = 0;
+	u32 peer_sid;
 
 	isec = SOCK_INODE(sock)->i_security;
 
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
@@ -3562,7 +3564,8 @@ out:	
 	return err;
 }
 
-static int selinux_socket_getpeersec_dgram(struct socket *sock, struct sk_buff *skb, u32 *secid)
+static int selinux_socket_getpeersec_dgram(struct socket *sock,
+				struct sk_buff *skb, u32 *secid)
 {
 	u32 peer_secid = SECSID_NULL;
 	int err = 0;
@@ -3571,8 +3574,12 @@ static int selinux_socket_getpeersec_dgr
 		selinux_get_inode_sid(SOCK_INODE(sock), &peer_secid);
 	else if (skb) {
 		peer_secid = selinux_netlbl_socket_getpeersec_dgram(skb);
-		if (peer_secid == SECSID_NULL)
-			peer_secid = selinux_socket_getpeer_dgram(skb);
+		if (peer_secid == SECSID_NULL) {
+			if (selinux_compat_net)
+				peer_secid = selinux_socket_getpeer_dgram(skb);
+			else
+				peer_secid = skb->secmark;
+		}
 	}
 
 	if (peer_secid == SECSID_NULL)
@@ -3640,19 +3647,24 @@ static int selinux_inet_conn_request(str
 		return 0;
 	}
 
-	err = selinux_xfrm_decode_session(skb, &peersid, 0);
-	BUG_ON(err);
-
-	if (peersid == SECSID_NULL) {
-		req->secid = sksec->sid;
-		return 0;
-	}
+	if (selinux_compat_net) {
+		err = selinux_xfrm_decode_session(skb, &peersid, 0);
+		BUG_ON(err);
+
+		if (peersid == SECSID_NULL) {
+			req->secid = sksec->sid;
+			req->peer_secid = 0;
+			return 0;
+		}
+	} else
+		peersid = skb->secmark;
 
 	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
 	if (err)
 		return err;
 
 	req->secid = newsid;
+	req->peer_secid = peersid;
 	return 0;
 }
 
@@ -3662,6 +3674,7 @@ static void selinux_inet_csk_clone(struc
 	struct sk_security_struct *newsksec = newsk->sk_security;
 
 	newsksec->sid = req->secid;
+	newsksec->peer_sid = req->peer_secid;
 	/* NOTE: Ideally, we should also get the isec->sid for the
 	   new socket in sync, but we don't have the isec available yet.
 	   So we will wait until sock_graft to do it, by which
@@ -3676,6 +3689,67 @@ static void selinux_req_classify_flow(co
 	fl->secid = req->secid;
 }
 
+static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
+{
+	u32 xfrm_sid;
+	int err;
+
+	if (selinux_compat_net)
+		return 1;
+
+	/*
+	 * loopback traffic already labeled and
+	 * flow-controlled on outbound. We may
+	 * need to flow-control on the inbound
+	 * as well if there's ever a use-case for it.
+	 */
+	if (skb->dev == &loopback_dev)
+		return 1;
+
+	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
+	BUG_ON(err);
+
+	err = avc_has_perm(xfrm_sid, skb->secmark? : SECINITSID_NETMSG,
+					SECCLASS_PACKET,
+					PACKET__FLOW_IN, NULL);
+	if (err)
+		goto out;
+
+	if (xfrm_sid)
+		skb->secmark = xfrm_sid;
+
+	/* See if NetLabel can flow in thru the current secmark here */
+
+out:
+	return err ? 0 : 1;
+};
+
+static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
+{
+	int err;
+
+	if (selinux_compat_net)
+		return 1;
+
+	if (!skb->secmark) {
+		u32 xfrm_sid;
+
+		selinux_skb_xfrm_sid(skb, &xfrm_sid);
+
+		if (xfrm_sid)
+			skb->secmark = xfrm_sid;
+		else if (skb->sk) {
+			struct sk_security_struct *sksec = skb->sk->sk_security;
+			skb->secmark = sksec->sid;
+		}
+	}
+
+	err = avc_has_perm(skb->secmark, nf_secid, SECCLASS_PACKET,
+				PACKET__FLOW_OUT, NULL);
+
+	return err ? 0 : 1;
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -3714,7 +3788,8 @@ out:
 
 #ifdef CONFIG_NETFILTER
 
-static int selinux_ip_postroute_last_compat(struct sock *sk, struct net_device *dev,
+static int selinux_ip_postroute_last_compat(struct sock *sk, struct sk_buff *skb,
+					    struct net_device *dev,
 					    struct avc_audit_data *ad,
 					    u16 family, char *addrp, int len)
 {
@@ -3724,6 +3799,9 @@ static int selinux_ip_postroute_last_com
 	struct inode *inode;
 	struct inode_security_struct *isec;
 
+	if (!sk)
+		goto out;
+
 	sock = sk->sk_socket;
 	if (!sock)
 		goto out;
@@ -3782,7 +3860,11 @@ static int selinux_ip_postroute_last_com
 
 		err = avc_has_perm(isec->sid, port_sid, isec->sclass,
 				   send_perm, ad);
+		if (err)
+			goto out;
 	}
+
+	err = selinux_xfrm_postroute_last(isec->sid, skb, ad);
 out:
 	return err;
 }
@@ -3796,17 +3878,9 @@ static unsigned int selinux_ip_postroute
 {
 	char *addrp;
 	int len, err = 0;
-	struct sock *sk;
 	struct sk_buff *skb = *pskb;
 	struct avc_audit_data ad;
 	struct net_device *dev = (struct net_device *)out;
-	struct sk_security_struct *sksec;
-
-	sk = skb->sk;
-	if (!sk)
-		goto out;
-
-	sksec = sk->sk_security;
 
 	AVC_AUDIT_DATA_INIT(&ad, NET);
 	ad.u.net.netif = dev->name;
@@ -3817,16 +3891,25 @@ static unsigned int selinux_ip_postroute
 		goto out;
 
 	if (selinux_compat_net)
-		err = selinux_ip_postroute_last_compat(sk, dev, &ad,
+		err = selinux_ip_postroute_last_compat(skb->sk, skb, dev, &ad,
 						       family, addrp, len);
-	else
-		err = avc_has_perm(sksec->sid, skb->secmark, SECCLASS_PACKET,
-				   PACKET__SEND, &ad);
+	else {
+		if (!skb->secmark) {
+			u32 xfrm_sid;
 
-	if (err)
-		goto out;
+			selinux_skb_xfrm_sid(skb, &xfrm_sid);
 
-	err = selinux_xfrm_postroute_last(sksec->sid, skb, &ad);
+			if (xfrm_sid)
+				skb->secmark = xfrm_sid;
+			else if (skb->sk) {
+				struct sk_security_struct *sksec =
+						skb->sk->sk_security;
+				skb->secmark = sksec->sid;
+			}
+		}
+		err = avc_has_perm(skb->secmark, SECINITSID_NETMSG,
+				   SECCLASS_PACKET, PACKET__FLOW_OUT, &ad);
+	}
 out:
 	return err ? NF_DROP : NF_ACCEPT;
 }
@@ -4733,6 +4816,8 @@ static struct security_operations selinu
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
 	.req_classify_flow =		selinux_req_classify_flow,
+	.skb_flow_in =			selinux_skb_flow_in,
+	.skb_flow_out =			selinux_skb_flow_out,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
Index: net-2.6_secidfinal/security/selinux/include/xfrm.h
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/include/xfrm.h
+++ net-2.6_secidfinal/security/selinux/include/xfrm.h
@@ -38,9 +38,9 @@ int selinux_xfrm_sock_rcv_skb(u32 sid, s
 			struct avc_audit_data *ad);
 int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad);
-u32 selinux_socket_getpeer_stream(struct sock *sk);
 u32 selinux_socket_getpeer_dgram(struct sk_buff *skb);
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
+void selinux_skb_xfrm_sid(struct sk_buff *skb, u32 *sid);
 #else
 static inline int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad)
@@ -54,11 +54,6 @@ static inline int selinux_xfrm_postroute
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
@@ -68,6 +63,10 @@ static inline int selinux_xfrm_decode_se
 	*sid = SECSID_NULL;
 	return 0;
 }
+static inline void selinux_skb_xfrm_sid(struct sk_buff *skb, u32 *sid)
+{
+	*sid = SECSID_NULL;
+}
 #endif
 
 #endif /* _SELINUX_XFRM_H_ */
Index: net-2.6_secidfinal/security/selinux/xfrm.c
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/xfrm.c
+++ net-2.6_secidfinal/security/selinux/xfrm.c
@@ -155,7 +155,8 @@ int selinux_xfrm_flow_state_match(struct
 }
 
 /*
- * LSM hook implementation that determines the sid for the session.
+ * LSM hook implementation that checks and/or returns the xfrm sid for the
+ * incoming packet.
  */
 
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
@@ -193,6 +194,32 @@ int selinux_xfrm_decode_session(struct s
 }
 
 /*
+ * LSM hook implementation that returns the xfrm sid for the outgoing packet.
+ */
+
+void selinux_skb_xfrm_sid(struct sk_buff *skb, u32 *sid)
+{
+	struct dst_entry *dst;
+
+	*sid = SECSID_NULL;
+
+	dst = skb->dst;
+	if (dst) {
+		struct dst_entry *dst_test;
+		for (dst_test = dst; dst_test != 0;
+			dst_test = dst_test->child) {
+			struct xfrm_state *x = dst_test->xfrm;
+
+			if (x && selinux_authorizable_xfrm(x)) {
+				struct xfrm_sec_ctx *ctx = x->security;
+				*sid = ctx->ctx_sid;
+				break;
+			}
+		}
+	}
+}
+
+/*
  * Security blob allocation for xfrm_policy and xfrm_state
  * CTX does not have a meaningful value on input
  */
@@ -391,43 +418,8 @@ void selinux_xfrm_state_free(struct xfrm
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

--
paul moore
linux security @ hp
