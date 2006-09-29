From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 2/7] secid reconciliation-v03: Add LSM hooks
Date: Thu, 28 Sep 2006 21:32:57 -0500
Message-ID: <451C85D9.1020701@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:26804 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161288AbWI2CdT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 22:33:19 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add skb_policy_check and skb_netfilter_check hooks to LSM to enable
reconciliation of the various security identifiers as well as enforce
flow control on inbound (PREROUTING/INPUT) and outbound (OUTPUT/FORWARD/POSTROUTING)
traffic.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h |   35 +++++++++++++++++++++++++++++++++++
 security/dummy.c         |   13 +++++++++++++
 2 files changed, 48 insertions(+)

diff --git a/include/linux/security.h b/include/linux/security.h
index 9f56fb8..08726e1 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -828,6 +828,15 @@ #ifdef CONFIG_SECURITY
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
@@ -1372,6 +1381,8 @@ #ifdef CONFIG_SECURITY_NETWORK
 					struct request_sock *req);
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
+	int (*skb_flow_in)(struct sk_buff *skb, unsigned short family);
+	int (*skb_flow_out)(struct sk_buff *skb, u32 nf_secid);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2946,6 +2957,18 @@ static inline void security_req_classify
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
@@ -3097,6 +3120,18 @@ static inline void security_req_classify
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
diff --git a/security/dummy.c b/security/dummy.c
index aeee705..921be56 100644
--- a/security/dummy.c
+++ b/security/dummy.c
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
@@ -1108,6 +1119,8 @@ #ifdef CONFIG_SECURITY_NETWORK
 	set_to_dummy_if_null(ops, inet_conn_request);
 	set_to_dummy_if_null(ops, inet_csk_clone);
 	set_to_dummy_if_null(ops, req_classify_flow);
+	set_to_dummy_if_null(ops, skb_flow_in);
+	set_to_dummy_if_null(ops, skb_flow_out);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
