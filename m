From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 2/3] secid reconciliation-v01: add LSM hooks
Date: Thu, 24 Aug 2006 12:51:13 -0500
Message-ID: <44EDE711.9080009@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:13573 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1030444AbWHXRvX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 13:51:23 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add skb_policy_check hook to LSM to enable reconciliation of the
various security identifiers as well as enforce flow control on
inbound (INPUT/FORWARD) traffic.

Also defines reconciliation for SELinux.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h       |   16 ++++++++
 security/dummy.c               |    7 +++
 security/selinux/hooks.c       |   60 +++++++++++++++++++++++++------
 security/selinux/ss/mls.c      |    2 +
 security/selinux/ss/services.c |    2 +
 5 files changed, 76 insertions(+), 11 deletions(-)

--- net-2.6.19.sid1/include/linux/security.h	2006-08-24 09:19:12.000000000 -0500
+++ net-2.6.19.sid2/include/linux/security.h	2006-08-24 09:55:39.000000000 -0500
@@ -828,6 +828,9 @@ struct request_sock;
  *	Sets the new child socket's sid to the openreq sid.
  * @req_classify_flow:
  *	Sets the flow's sid to the openreq sid.
+ * @skb_policy_check:
+ *	Checks to see if security policy would allow skb into the system.
+ *	Returns 1 if skb allowed into system, 0 otherwise.
  *
  * Security hooks for XFRM operations.
  *
@@ -1372,6 +1375,7 @@ struct security_operations {
 					struct request_sock *req);
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
+	int (*skb_policy_check)(struct sk_buff *skb, unsigned short family);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2946,6 +2950,12 @@ static inline void security_req_classify
 	security_ops->req_classify_flow(req, fl);
 }
 
+static inline int security_skb_policy_check(struct sk_buff *skb,
+					unsigned short family)
+{
+	return security_ops->skb_policy_check(skb, family);
+}
+
 static inline void security_sock_graft(struct sock* sk, struct socket *parent)
 {
 	security_ops->sock_graft(sk, parent);
@@ -3097,6 +3107,12 @@ static inline void security_req_classify
 {
 }
 
+static inline int security_skb_policy_check(struct sk_buff *skb,
+					unsigned short family)
+{
+	return 1;
+}
+
 static inline void security_sock_graft(struct sock* sk, struct socket *parent)
 {
 }
--- net-2.6.19.sid1/security/dummy.c	2006-08-24 09:19:13.000000000 -0500
+++ net-2.6.19.sid2/security/dummy.c	2006-08-24 09:55:39.000000000 -0500
@@ -832,6 +832,12 @@ static inline void dummy_req_classify_fl
 			struct flowi *fl)
 {
 }
+
+static inline int dummy_skb_policy_check(struct sk_buff *skb,
+			unsigned short family)
+{
+	return 1;
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1108,6 +1114,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, inet_conn_request);
 	set_to_dummy_if_null(ops, inet_csk_clone);
 	set_to_dummy_if_null(ops, req_classify_flow);
+	set_to_dummy_if_null(ops, skb_policy_check);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
--- net-2.6.19.sid1/security/selinux/hooks.c	2006-08-24 09:19:13.000000000 -0500
+++ net-2.6.19.sid2/security/selinux/hooks.c	2006-08-24 10:00:12.000000000 -0500
@@ -3447,8 +3447,12 @@ static int selinux_sock_rcv_skb_compat(s
 
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
@@ -3487,10 +3491,6 @@ static int selinux_socket_sock_rcv_skb(s
 		goto out;
 
 	err = selinux_netlbl_sock_rcv_skb(sksec, skb, &ad);
-	if (err)
-		goto out;
-
-	err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
 out:	
 	return err;
 }
@@ -3622,13 +3622,16 @@ static int selinux_inet_conn_request(str
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
+			return 0;
+		}
+	} else
+		peersid = skb->secmark;
 
 	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
 	if (err)
@@ -3656,6 +3659,40 @@ static void selinux_req_classify_flow(co
 	fl->secid = req->secid;
 }
 
+static int selinux_skb_policy_check(struct sk_buff *skb, unsigned short family)
+{
+	u32 xfrm_sid, trans_sid;
+	int err;
+
+	if (selinux_compat_net)
+		return 1;
+
+	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
+	BUG_ON(err);
+
+	if (xfrm_sid) {
+		err = security_transition_sid(xfrm_sid, skb->secmark,
+						SECCLASS_PACKET, &trans_sid);
+		if (err)
+			goto out;
+	}
+	else
+		trans_sid = SECSID_NULL;
+
+	err = avc_has_perm(trans_sid, skb->secmark, SECCLASS_PACKET,
+					PACKET__FLOW_IN, NULL);
+	if (err)
+		goto out;
+
+	if (trans_sid != SECSID_NULL && trans_sid != SECINITSID_UNLABELED)
+		skb->secmark = trans_sid;
+
+	/* See if CIPSO can flow in thru the current secmark here */
+
+out:
+	return err ? 0 : 1;
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -4713,6 +4750,7 @@ static struct security_operations selinu
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
 	.req_classify_flow =		selinux_req_classify_flow,
+	.skb_policy_check =		selinux_skb_policy_check,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
--- net-2.6.19.sid1/security/selinux/ss/mls.c	2006-08-24 09:19:13.000000000 -0500
+++ net-2.6.19.sid2/security/selinux/ss/mls.c	2006-08-24 09:55:39.000000000 -0500
@@ -548,6 +548,8 @@ int mls_compute_sid(struct context *scon
 				}
 			}
 		}
+		else if (tclass == SECCLASS_PACKET)
+			return mls_copy_context(newcontext, scontext);
 		/* Fallthrough */
 	case AVTAB_CHANGE:
 		if (tclass == SECCLASS_PROCESS)
--- net-2.6.19.sid1/security/selinux/ss/services.c	2006-08-24 09:19:13.000000000 -0500
+++ net-2.6.19.sid2/security/selinux/ss/services.c	2006-08-24 09:55:39.000000000 -0500
@@ -832,6 +832,7 @@ static int security_compute_sid(u32 ssid
 
 	if (!ss_initialized) {
 		switch (tclass) {
+		case SECCLASS_PACKET:
 		case SECCLASS_PROCESS:
 			*out_sid = ssid;
 			break;
@@ -876,6 +877,7 @@ static int security_compute_sid(u32 ssid
 
 	/* Set the role and type to default values. */
 	switch (tclass) {
+	case SECCLASS_PACKET:
 	case SECCLASS_PROCESS:
 		/* Use the current role and type of process. */
 		newcontext.role = scontext->role;
