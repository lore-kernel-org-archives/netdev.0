From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Thu, 28 Sep 2006 21:33:24 -0500
Message-ID: <451C85F4.7000406@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:54960 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161295AbWI2CeC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 22:34:02 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This defines SELinux enforcement of the 2 new LSM hooks as well
as related changes elsewhere in the SELinux code.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 security/selinux/hooks.c        |  129 +++++++++++++++++++++++-------
 security/selinux/include/xfrm.h |    5 +
 security/selinux/ss/mls.c       |    2 
 security/selinux/ss/services.c  |    2 
 security/selinux/xfrm.c         |   28 ++++++
 5 files changed, 139 insertions(+), 27 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5a66c4c..143b4b8 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3449,8 +3449,12 @@ static int selinux_sock_rcv_skb_compat(s
 
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
@@ -3489,10 +3493,6 @@ static int selinux_socket_sock_rcv_skb(s
 		goto out;
 
 	err = selinux_netlbl_sock_rcv_skb(sksec, skb, &ad);
-	if (err)
-		goto out;
-
-	err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
 out:	
 	return err;
 }
@@ -3626,13 +3626,16 @@ static int selinux_inet_conn_request(str
 		return 0;
 	}
 
-	err = selinux_xfrm_decode_session(skb, &peersid, 0);
-	BUG_ON(err);
+	if (selinux_compat_net) {
+		err = selinux_xfrm_decode_session(skb, &peersid, 0);
+		BUG_ON(err);
 
-	if (peersid == SECSID_NULL) {
-		req->secid = sksec->sid;
-		return 0;
-	}
+		if (peersid == SECSID_NULL) {
+			req->secid = sksec->sid;
+			return 0;
+		}
+	} else
+		peersid = skb->secmark;
 
 	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
 	if (err)
@@ -3662,6 +3665,69 @@ static void selinux_req_classify_flow(co
 	fl->secid = req->secid;
 }
 
+static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
+{
+	u32 xfrm_sid, trans_sid;
+	int err;
+
+	if (selinux_compat_net)
+		return 1;
+
+	/* xfrm/cipso inapplicable for loopback traffic */
+	if (skb->dev == &loopback_dev)
+		return 1;
+
+	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
+	BUG_ON(err);
+
+	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
+					PACKET__FLOW_IN, NULL);
+	if (err)
+		goto out;
+
+	if (xfrm_sid) {
+		err = security_transition_sid(xfrm_sid, skb->secmark,
+						SECCLASS_PACKET, &trans_sid);
+		if (err)
+			goto out;
+
+		skb->secmark = trans_sid;
+	}
+
+	/* See if CIPSO can flow in thru the current secmark here */
+
+out:
+	return err ? 0 : 1;
+};
+
+static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
+{
+	u32 trans_sid;
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
+out:
+	return err ? 0 : 1;
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -3700,7 +3766,8 @@ out:
 
 #ifdef CONFIG_NETFILTER
 
-static int selinux_ip_postroute_last_compat(struct sock *sk, struct net_device *dev,
+static int selinux_ip_postroute_last_compat(struct sock *sk, struct sk_buff *skb,
+					    struct net_device *dev,
 					    struct avc_audit_data *ad,
 					    u16 family, char *addrp, int len)
 {
@@ -3710,6 +3777,9 @@ static int selinux_ip_postroute_last_com
 	struct inode *inode;
 	struct inode_security_struct *isec;
 
+	if (!sk)
+		goto out;
+
 	sock = sk->sk_socket;
 	if (!sock)
 		goto out;
@@ -3768,7 +3838,11 @@ static int selinux_ip_postroute_last_com
 
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
@@ -3782,17 +3856,9 @@ static unsigned int selinux_ip_postroute
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
@@ -3803,16 +3869,25 @@ static unsigned int selinux_ip_postroute
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
+		err = avc_has_perm(skb->secmark, SECINITSID_UNLABELED,
+				   SECCLASS_PACKET, PACKET__FLOW_OUT, &ad);
+	}
 out:
 	return err ? NF_DROP : NF_ACCEPT;
 }
@@ -4719,6 +4794,8 @@ static struct security_operations selinu
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
 	.req_classify_flow =		selinux_req_classify_flow,
+	.skb_flow_in =			selinux_skb_flow_in,
+	.skb_flow_out =			selinux_skb_flow_out,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 81eb598..ed07f92 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -41,6 +41,7 @@ int selinux_xfrm_postroute_last(u32 isec
 u32 selinux_socket_getpeer_stream(struct sock *sk);
 u32 selinux_socket_getpeer_dgram(struct sk_buff *skb);
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
+void selinux_skb_xfrm_sid(struct sk_buff *skb, u32 *sid);
 #else
 static inline int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad)
@@ -68,6 +69,10 @@ static inline int selinux_xfrm_decode_se
 	*sid = SECSID_NULL;
 	return 0;
 }
+static inline void selinux_skb_xfrm_sid(struct sk_buff *skb, u32 *sid)
+{
+	*sid = SECSID_NULL;
+}
 #endif
 
 #endif /* _SELINUX_XFRM_H_ */
diff --git a/security/selinux/ss/mls.c b/security/selinux/ss/mls.c
index 119bd60..c551def 100644
--- a/security/selinux/ss/mls.c
+++ b/security/selinux/ss/mls.c
@@ -548,6 +548,8 @@ int mls_compute_sid(struct context *scon
 				}
 			}
 		}
+		else if (tclass == SECCLASS_PACKET)
+			return mls_copy_context(newcontext, scontext);
 		/* Fallthrough */
 	case AVTAB_CHANGE:
 		if (tclass == SECCLASS_PROCESS)
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 22ed17c..26176c2 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
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
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 3e742b8..3a68723 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -155,7 +155,7 @@ int selinux_xfrm_flow_state_match(struct
 }
 
 /*
- * LSM hook implementation that determines the sid for the session.
+ * LSM hook implementation that checks/returns the xfrm sid for the incoming packet.
  */
 
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
@@ -193,6 +193,32 @@ int selinux_xfrm_decode_session(struct s
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
