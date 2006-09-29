From: paul.moore@hp.com
Subject: [PATCH 1/1] NetLabel: secid reconciliation support
Date: Fri, 29 Sep 2006 16:17:47 -0400
Message-ID: <20060929202226.124529000@hp.com>
References: <20060929201746.711738000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, method@gentoo.org,
	kmacmillan@mentalrootkit.com, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:23958 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1422797AbWI2UWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 16:22:30 -0400
To: vyekkirala@TrustedCS.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-secid_support
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides the missing NetLabel support to the secid reconciliation
patchset.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/hooks.c                    |   51 ++++++++++++++++++++--------
 security/selinux/include/objsec.h           |    1 
 security/selinux/include/selinux_netlabel.h |   16 +++++++-
 security/selinux/ss/mls.c                   |    2 -
 security/selinux/ss/services.c              |   42 ++++++++++++++++-------
 5 files changed, 82 insertions(+), 30 deletions(-)

Index: net-2.6/security/selinux/hooks.c
===================================================================
--- net-2.6.orig/security/selinux/hooks.c
+++ net-2.6/security/selinux/hooks.c
@@ -3440,6 +3440,10 @@ static int selinux_sock_rcv_skb_compat(s
 			goto out;
 	}
 
+	err = selinux_netlbl_sock_rcv_skb(sock_sid, sock_class, skb, ad);
+	if (err)
+		goto out;
+
 	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb, ad);
 
 out:
@@ -3476,10 +3480,7 @@ static int selinux_socket_sock_rcv_skb(s
 	else
 		err = avc_has_perm(sksec->sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__RECV, &ad);
-	if (err)
-		goto out;
 
-	err = selinux_netlbl_sock_rcv_skb(sksec, skb, &ad);
 out:	
 	return err;
 }
@@ -3654,13 +3655,14 @@ static void selinux_req_classify_flow(co
 
 static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
 {
-	u32 xfrm_sid, trans_sid;
+	u32 xfrm_sid;
+	u32 nlbl_sid;
 	int err;
 
 	if (selinux_compat_net)
 		return 1;
 
-	/* xfrm/cipso inapplicable for loopback traffic */
+	/* allow all loopback traffic */
 	if (skb->dev == &loopback_dev)
 		return 1;
 
@@ -3672,16 +3674,20 @@ static int selinux_skb_flow_in(struct sk
 	if (err)
 		goto out;
 
-	if (xfrm_sid) {
-		err = security_transition_sid(xfrm_sid, skb->secmark,
-						SECCLASS_PACKET, &trans_sid);
-		if (err)
-			goto out;
+	if (xfrm_sid)
+		skb->secmark = xfrm_sid;
 
-		skb->secmark = trans_sid;
-	}
+	err = selinux_netlbl_skb_sid(skb, skb->secmark, &nlbl_sid);
+	if (err)
+		goto out;
 
-	/* See if CIPSO can flow in thru the current secmark here */
+	err = avc_has_perm(nlbl_sid, skb->secmark, SECCLASS_PACKET,
+					PACKET__FLOW_IN, NULL);
+	if (err)
+		goto out;
+
+	if (nlbl_sid)
+		skb->secmark = nlbl_sid;
 
 out:
 	return err ? 0 : 1;
@@ -3689,7 +3695,6 @@ out:
 
 static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
 {
-	u32 trans_sid;
 	int err;
 
 	if (selinux_compat_net)
@@ -3697,6 +3702,7 @@ static int selinux_skb_flow_out(struct s
 
 	if (!skb->secmark) {
 		u32 xfrm_sid;
+		u32 nlbl_sid;
 
 		selinux_skb_xfrm_sid(skb, &xfrm_sid);
 
@@ -3706,6 +3712,13 @@ static int selinux_skb_flow_out(struct s
 			struct sk_security_struct *sksec = skb->sk->sk_security;
 			skb->secmark = sksec->sid;
 		}
+
+		err = selinux_netlbl_skb_sid(skb, skb->secmark, &nlbl_sid);
+		if (err)
+			goto out;
+
+		if (nlbl_sid)
+			skb->secmark = nlbl_sid;
 	}
 
 	err = avc_has_perm(skb->secmark, nf_secid, SECCLASS_PACKET,
@@ -3861,6 +3874,7 @@ static unsigned int selinux_ip_postroute
 	else {
 		if (!skb->secmark) {
 			u32 xfrm_sid;
+			u32 nlbl_sid;
 
 			selinux_skb_xfrm_sid(skb, &xfrm_sid);
 
@@ -3871,6 +3885,15 @@ static unsigned int selinux_ip_postroute
 						skb->sk->sk_security;
 				skb->secmark = sksec->sid;
 			}
+
+			err = selinux_netlbl_skb_sid(skb,
+						     skb->secmark,
+						     &nlbl_sid);
+			if (err)
+				goto out;
+
+			if (nlbl_sid)
+				skb->secmark = nlbl_sid;
 		}
 		err = avc_has_perm(skb->secmark, SECINITSID_UNLABELED,
 				   SECCLASS_PACKET, PACKET__FLOW_OUT, &ad);
Index: net-2.6/security/selinux/include/objsec.h
===================================================================
--- net-2.6.orig/security/selinux/include/objsec.h
+++ net-2.6/security/selinux/include/objsec.h
@@ -102,7 +102,6 @@ struct sk_security_struct {
 	u32 sid;			/* SID of this object */
 	u32 peer_sid;			/* SID of peer */
 #ifdef CONFIG_NETLABEL
-	u16 sclass;			/* sock security class */
 	enum {				/* NetLabel state */
 		NLBL_UNSET = 0,
 		NLBL_REQUIRE,
Index: net-2.6/security/selinux/include/selinux_netlabel.h
===================================================================
--- net-2.6.orig/security/selinux/include/selinux_netlabel.h
+++ net-2.6/security/selinux/include/selinux_netlabel.h
@@ -43,7 +43,8 @@ int selinux_netlbl_socket_post_create(st
 				      u32 sid);
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock);
 u32 selinux_netlbl_inet_conn_request(struct sk_buff *skb, u32 sock_sid);
-int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
+int selinux_netlbl_sock_rcv_skb(u32 sock_sid,
+				u16 sock_class,
 				struct sk_buff *skb,
 				struct avc_audit_data *ad);
 u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock);
@@ -53,6 +54,7 @@ void selinux_netlbl_sk_security_init(str
 void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec);
 int selinux_netlbl_inode_permission(struct inode *inode, int mask);
+int selinux_netlbl_skb_sid(struct sk_buff *skb, u32 base_sid, u32 *sid);
 #else
 static inline void selinux_netlbl_cache_invalidate(void)
 {
@@ -78,7 +80,8 @@ static inline u32 selinux_netlbl_inet_co
 	return SECSID_NULL;
 }
 
-static inline int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
+static inline int selinux_netlbl_sock_rcv_skb(u32 sock_sid,
+					      u16 sock_class,
 					      struct sk_buff *skb,
 					      struct avc_audit_data *ad)
 {
@@ -114,6 +117,15 @@ static inline int selinux_netlbl_inode_p
 {
 	return 0;
 }
+
+static inline int selinux_netlbl_skb_sid(struct sk_buff *skb,
+					 u32 base_sid,
+					 u32 *sid)
+{
+	*sid = SECINITSID_UNLABELED;
+	return 0;
+}
+
 #endif /* CONFIG_NETLABEL */
 
 #endif
Index: net-2.6/security/selinux/ss/mls.c
===================================================================
--- net-2.6.orig/security/selinux/ss/mls.c
+++ net-2.6/security/selinux/ss/mls.c
@@ -547,7 +547,7 @@ int mls_compute_sid(struct context *scon
 				                     &rtr->target_range);
 			}
 		}
-		else if (tclass == SECCLASS_PACKET)
+		if (tclass == SECCLASS_PACKET)
 			return mls_copy_context(newcontext, scontext);
 		/* Fallthrough */
 	case AVTAB_CHANGE:
Index: net-2.6/security/selinux/ss/services.c
===================================================================
--- net-2.6.orig/security/selinux/ss/services.c
+++ net-2.6/security/selinux/ss/services.c
@@ -2456,7 +2456,6 @@ void selinux_netlbl_sk_security_init(str
 void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec)
 {
-	newssec->sclass = ssec->sclass;
 	if (ssec->nlbl_state != NLBL_UNSET)
 		newssec->nlbl_state = NLBL_REQUIRE;
 	else
@@ -2478,11 +2477,8 @@ int selinux_netlbl_socket_post_create(st
 				      int sock_family,
 				      u32 sid)
 {
-	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sock->sk->sk_security;
 
-	sksec->sclass = isec->sclass;
-
 	if (sock_family != PF_INET)
 		return 0;
 
@@ -2502,13 +2498,10 @@ int selinux_netlbl_socket_post_create(st
  */
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock)
 {
-	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
 	u32 nlbl_peer_sid;
 
-	sksec->sclass = isec->sclass;
-
 	if (sk->sk_family != PF_INET)
 		return;
 
@@ -2595,7 +2588,8 @@ int selinux_netlbl_inode_permission(stru
 
 /**
  * selinux_netlbl_sock_rcv_skb - Do an inbound access check using NetLabel
- * @sksec: the sock's sk_security_struct
+ * @sock_sid: the socket's SID
+ * @sock_class: the socket's class
  * @skb: the packet
  * @ad: the audit data
  *
@@ -2605,7 +2599,8 @@ int selinux_netlbl_inode_permission(stru
  * error.
  *
  */
-int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
+int selinux_netlbl_sock_rcv_skb(u32 sock_sid,
+				u16 sock_class,
 				struct sk_buff *skb,
 				struct avc_audit_data *ad)
 {
@@ -2620,7 +2615,7 @@ int selinux_netlbl_sock_rcv_skb(struct s
 	if (netlbl_sid == SECINITSID_UNLABELED)
 		return 0;
 
-	switch (sksec->sclass) {
+	switch (sock_class) {
 	case SECCLASS_UDP_SOCKET:
 		recv_perm = UDP_SOCKET__RECVFROM;
 		break;
@@ -2631,9 +2626,9 @@ int selinux_netlbl_sock_rcv_skb(struct s
 		recv_perm = RAWIP_SOCKET__RECVFROM;
 	}
 
-	rc = avc_has_perm(sksec->sid,
+	rc = avc_has_perm(sock_sid,
 			  netlbl_sid,
-			  sksec->sclass,
+			  sock_class,
 			  recv_perm,
 			  ad);
 	if (rc == 0)
@@ -2688,4 +2683,27 @@ u32 selinux_netlbl_socket_getpeersec_dgr
 
 	return peer_sid;
 }
+
+/**
+ * selinux_netlbl_skb_sid - Calculate the NetLabel SID of a packet
+ * @skb: the packet
+ * @base_sid: the SELinux SID to use as a context for MLS only attributes
+ * @sid: the SID
+ *
+ * Description:
+ * Call the NetLabel mechanism to get the security attributes of the given
+ * packet and use those attributes to determine the correct context/SID to
+ * assign to the packet.  Returns zero on success, negative values on failure.
+ *
+ */
+int selinux_netlbl_skb_sid(struct sk_buff *skb, u32 base_sid, u32 *sid)
+{
+	int rc;
+
+	rc = selinux_netlbl_skbuff_getsid(skb, base_sid, sid);
+	if (rc == 0 && *sid == SECINITSID_UNLABELED)
+		*sid = 0;
+
+	return rc;
+}
 #endif /* CONFIG_NETLABEL */

--
paul moore
linux security @ hp
