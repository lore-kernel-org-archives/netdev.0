From: paul.moore@hp.com
Subject: [PATCH 02/11] secid reconciliation: Add LSM hooks
Date: Mon, 09 Oct 2006 15:42:25 -0400
Message-ID: <20061009195846.817755000@hp.com>
References: <20061009194223.402695000@hp.com>
Cc: vyekkirala@TrustedCS.com, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:26590 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S964795AbWJIT7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 15:59:18 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=secid-2
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>

Add skb_policy_check and skb_netfilter_check hooks to LSM to enable
reconciliation of the various security identifiers as well as enforce
flow control on inbound (PREROUTING/INPUT) and outbound (OUTPUT/FORWARD/POSTROUTING)
traffic.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h |   41 ++++++++++++++++++++++++++++++++++++++++-
 security/dummy.c         |   13 +++++++++++++
 2 files changed, 53 insertions(+), 1 deletion(-)

Index: net-2.6_secidfinal/include/linux/security.h
===================================================================
--- net-2.6_secidfinal.orig/include/linux/security.h
+++ net-2.6_secidfinal/include/linux/security.h
@@ -828,6 +828,15 @@ struct request_sock;
  *	Sets the new child socket's sid to the openreq sid.
  * @req_classify_flow:
  *	Sets the flow's sid to the openreq sid.
+ * @skb_flow_in:
+ *	Checks to see if security policy would allow skb into the system
+ *	while also reconciling the xfrm secid, cipso, etc, if any, and
+ *	relabeling the skb with the reconciled secid.
+ *	Returns 1 if skb allowed into system, 0 otherwise.
+ * @skb_flow_out:
+ *	Checks to see if security policy would allow skb to go out of system.
+ *	Returns 1 if skb allowed out of system, 0 if not, and -ENOENT if there's
+ *	no hook defined.
  *
  * Security hooks for XFRM operations.
  *
@@ -1372,6 +1381,8 @@ struct security_operations {
 					struct request_sock *req);
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
+	int (*skb_flow_in)(struct sk_buff *skb, unsigned short family);
+	int (*skb_flow_out)(struct sk_buff *skb, u32 nf_secid);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2947,6 +2958,18 @@ static inline void security_req_classify
 	security_ops->req_classify_flow(req, fl);
 }
 
+static inline int security_skb_flow_in(struct sk_buff *skb,
+					unsigned short family)
+{
+	return security_ops->skb_flow_in(skb, family);
+}
+
+static inline int security_skb_flow_out(struct sk_buff *skb,
+					u32 nf_secid)
+{
+	return security_ops->skb_flow_out(skb, nf_secid);
+}
+
 static inline void security_sock_graft(struct sock* sk, struct socket *parent)
 {
 	security_ops->sock_graft(sk, parent);
@@ -3098,6 +3121,18 @@ static inline void security_req_classify
 {
 }
 
+static inline int security_skb_flow_in(struct sk_buff *skb,
+					unsigned short family)
+{
+	return 1;
+}
+
+static inline int security_skb_flow_out(struct sk_buff *skb,
+					u32 nf_secid)
+{
+	return -ENOENT;
+}
+
 static inline void security_sock_graft(struct sock* sk, struct socket *parent)
 {
 }
@@ -3151,7 +3186,11 @@ static inline int security_xfrm_state_al
 {
 	if (!polsec)
 		return 0;
-	return security_ops->xfrm_state_alloc_security(x, NULL, polsec, secid);
+	/*
+	 * No need to pass polsec along since we want the context to be
+	 * taken from secid which is usually from the sock.
+	 */
+	return security_ops->xfrm_state_alloc_security(x, NULL, NULL, secid);
 }
 
 static inline int security_xfrm_state_delete(struct xfrm_state *x)
Index: net-2.6_secidfinal/security/dummy.c
===================================================================
--- net-2.6_secidfinal.orig/security/dummy.c
+++ net-2.6_secidfinal/security/dummy.c
@@ -832,6 +832,17 @@ static inline void dummy_req_classify_fl
 			struct flowi *fl)
 {
 }
+
+static inline int dummy_skb_flow_in(struct sk_buff *skb,
+			unsigned short family)
+{
+	return -ENOENT;
+}
+
+static inline int dummy_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
+{
+	return -ENOENT;
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1108,6 +1119,8 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, inet_conn_request);
 	set_to_dummy_if_null(ops, inet_csk_clone);
 	set_to_dummy_if_null(ops, req_classify_flow);
+	set_to_dummy_if_null(ops, skb_flow_in);
+	set_to_dummy_if_null(ops, skb_flow_out);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);

--
paul moore
linux security @ hp
