From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [RFC 2/3] secid reconciliation on inbound: add LSM hooks
Date: Tue, 01 Aug 2006 17:08:34 -0500
Message-ID: <44CFD0E2.9070709@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:42675 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751225AbWHAWIu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 18:08:50 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add skb_policy_check hook to LSM to enable reconciliation of the
various security identifiers as well as enforce flow control on
inbound (INPUT/FORWARD) traffic.

Also defines reconciliation for SELinux.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 dummy.c    |    7 ++
 hooks.c    |   30 ++++++++--
 security.h |   16 +++++
 3 files changed, 49 insertions(+), 4 deletions(-)

--- linux-2.6.17.child_sock/include/linux/security.h	2006-07-31 10:03:26.000000000 -0500
+++ linux-2.6.17/include/linux/security.h	2006-08-01 10:57:15.000000000 -0500
@@ -828,6 +828,9 @@ struct request_sock;
  *	Sets the new child socket's sid to the openreq sid.
  * @req_classify_flow:
  *	Sets the flow's sid to the openreq sid.
+ * @skb_policy_check:
+ *	Checks to see if security policy would allow skb into the system.
+ *	Returns 1 if skb is allowed, 0 otherwise.
  *
  * Security hooks for XFRM operations.
  *
@@ -1360,6 +1363,7 @@ struct security_operations {
 					struct request_sock *req);
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
+	int (*skb_policy_check)(struct sk_buff *skb, unsigned short family);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2917,6 +2921,12 @@ static inline void security_req_classify
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
@@ -3068,6 +3078,12 @@ static inline void security_req_classify
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
--- linux-2.6.17.child_sock/security/dummy.c	2006-07-31 10:03:26.000000000 -0500
+++ linux-2.6.17/security/dummy.c	2006-08-01 10:57:37.000000000 -0500
@@ -833,6 +833,12 @@ static inline void dummy_req_classify_fl
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
@@ -1098,6 +1104,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, inet_conn_request);
 	set_to_dummy_if_null(ops, inet_csk_clone);
 	set_to_dummy_if_null(ops, req_classify_flow);
+	set_to_dummy_if_null(ops, skb_policy_check);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
--- linux-2.6.17.child_sock/security/selinux/hooks.c	2006-07-31 10:04:31.000000000 -0500
+++ linux-2.6.17/security/selinux/hooks.c	2006-08-01 10:33:43.000000000 -0500
@@ -3465,11 +3465,11 @@ static int selinux_socket_sock_rcv_skb(s
 	else
 		err = avc_has_perm(sksec->sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__RECV, &ad);
-	if (err)
-		goto out;
+	/* if (err) */
+	/*	goto out; */
 
-	err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
-out:	
+	/* err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad); */
+out:	 
 	return err;
 }
 
@@ -3624,6 +3624,27 @@ void selinux_req_classify_flow(const str
 	fl->secid = req->secid;
 }
 
+static int selinux_skb_policy_check(struct sk_buff *skb, unsigned short family)
+{
+	u32 xfrm_sid;
+	int err;
+
+	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
+	BUG_ON(err);
+
+	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
+					PACKET__COME_THRU, NULL);
+	if (err)
+		goto out;
+
+	skb->secmark = xfrm_sid;
+
+	/* See if CIPSO can COME_THRU the current secmark here */
+
+out:
+	return err ? 0 : 1;
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -4667,6 +4688,7 @@ static struct security_operations selinu
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
 	.req_classify_flow =		selinux_req_classify_flow,
+	.skb_policy_check =		selinux_skb_policy_check,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
