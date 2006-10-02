From: paul.moore@hp.com
Subject: [PATCH v3 1/1] NetLabel: secid reconciliation support
Date: Mon, 02 Oct 2006 16:54:23 -0400
Message-ID: <20061002205549.576265000@hp.com>
References: <20061002205422.013172000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, eparis@redhat.com,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:39047 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S965104AbWJBUzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 16:55:54 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-secid_support
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides the missing NetLabel support to the secid reconciliation
patchset.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/hooks.c                    |   80 ++++++++++++++-------
 security/selinux/include/objsec.h           |    1 
 security/selinux/include/selinux_netlabel.h |   28 +++----
 security/selinux/ss/services.c              |  106 ++++++++++------------------
 4 files changed, 107 insertions(+), 108 deletions(-)

Index: net-2.6/security/selinux/hooks.c
===================================================================
--- net-2.6.orig/security/selinux/hooks.c
+++ net-2.6/security/selinux/hooks.c
@@ -3465,6 +3465,10 @@ static int selinux_sock_rcv_skb_compat(s
 			goto out;
 	}
 
+	err = selinux_netlbl_sock_rcv_skb(sock_sid, sock_class, skb, ad);
+	if (err)
+		goto out;
+
 	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb, ad);
 
 out:
@@ -3501,10 +3505,7 @@ static int selinux_socket_sock_rcv_skb(s
 	else
 		err = avc_has_perm(sksec->sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__RECV, &ad);
-	if (err)
-		goto out;
 
-	err = selinux_netlbl_sock_rcv_skb(sksec, skb, &ad);
 out:	
 	return err;
 }
@@ -3527,11 +3528,8 @@ static int selinux_socket_getpeersec_str
 		peer_sid = ssec->peer_sid;
 	}
 	else if (isec->sclass == SECCLASS_TCP_SOCKET) {
-		peer_sid = selinux_netlbl_socket_getpeersec_stream(sock);
-		if (peer_sid == SECSID_NULL) {
-			ssec = sock->sk->sk_security;
-			peer_sid = ssec->peer_sid;
-		}
+		ssec = sock->sk->sk_security;
+		peer_sid = ssec->peer_sid;
 		if (peer_sid == SECSID_NULL) {
 			err = -ENOPROTOOPT;
 			goto out;
@@ -3573,13 +3571,13 @@ static int selinux_socket_getpeersec_dgr
 	if (sock && (sock->sk->sk_family == PF_UNIX))
 		selinux_get_inode_sid(SOCK_INODE(sock), &peer_secid);
 	else if (skb) {
-		peer_secid = selinux_netlbl_socket_getpeersec_dgram(skb);
-		if (peer_secid == SECSID_NULL) {
-			if (selinux_compat_net)
+		if (selinux_compat_net) {
+			peer_secid = selinux_netlbl_socket_getpeersec_dgram(
+				skb);
+			if (peer_secid == SECSID_NULL)
 				peer_secid = selinux_socket_getpeer_dgram(skb);
-			else
-				peer_secid = skb->secmark;
-		}
+		} else
+			peer_secid = skb->secmark;
 	}
 
 	if (peer_secid == SECSID_NULL)
@@ -3641,13 +3639,11 @@ static int selinux_inet_conn_request(str
 	u32 newsid;
 	u32 peersid;
 
-	newsid = selinux_netlbl_inet_conn_request(skb, sksec->sid);
-	if (newsid != SECSID_NULL) {
-		req->secid = newsid;
-		return 0;
-	}
-
 	if (selinux_compat_net) {
+		err = selinux_netlbl_skb_sid(skb, sksec->sid, &peersid);
+		if (err == 0 && peersid != SECSID_NULL)
+			goto out;
+
 		err = selinux_xfrm_decode_session(skb, &peersid, 0);
 		BUG_ON(err);
 
@@ -3659,6 +3655,7 @@ static int selinux_inet_conn_request(str
 	} else
 		peersid = skb->secmark;
 
+out:
 	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
 	if (err)
 		return err;
@@ -3700,6 +3697,8 @@ static void selinux_req_classify_flow(co
 static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
 {
 	u32 xfrm_sid;
+	u32 nlbl_sid;
+	u32 ext_sid;
 	int err;
 
 	if (selinux_compat_net)
@@ -3717,15 +3716,27 @@ static int selinux_skb_flow_in(struct sk
 	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
 	BUG_ON(err);
 
-	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
-					PACKET__FLOW_IN, NULL);
+	err = selinux_netlbl_skb_sid(skb,
+				     xfrm_sid ? xfrm_sid : skb->secmark,
+				     &nlbl_sid);
 	if (err)
 		goto out;
 
-	if (xfrm_sid)
-		skb->secmark = xfrm_sid;
+	if (nlbl_sid)
+		ext_sid = nlbl_sid;
+	else
+		ext_sid = xfrm_sid;
 
-	/* See if NetLabel can flow in thru the current secmark here */
+	err = avc_has_perm(ext_sid,
+			   skb->secmark,
+			   SECCLASS_PACKET,
+			   PACKET__FLOW_IN,
+			   NULL);
+	if (err)
+		goto out;
+
+	if (ext_sid)
+		skb->secmark = ext_sid;
 
 out:
 	return err ? 0 : 1;
@@ -3740,10 +3751,16 @@ static int selinux_skb_flow_out(struct s
 
 	if (!skb->secmark) {
 		u32 xfrm_sid;
+		u32 nlbl_sid;
 
+		err = selinux_netlbl_skb_sid(skb, skb->secmark, &nlbl_sid);
+		if (err)
+			goto out;
 		selinux_skb_xfrm_sid(skb, &xfrm_sid);
 
-		if (xfrm_sid)
+		if (nlbl_sid)
+			skb->secmark = nlbl_sid;
+		else if (xfrm_sid)
 			skb->secmark = xfrm_sid;
 		else if (skb->sk) {
 			struct sk_security_struct *sksec = skb->sk->sk_security;
@@ -3754,6 +3771,7 @@ static int selinux_skb_flow_out(struct s
 	err = avc_has_perm(skb->secmark, nf_secid, SECCLASS_PACKET,
 				PACKET__FLOW_OUT, NULL);
 
+out:
 	return err ? 0 : 1;
 }
 
@@ -3903,10 +3921,18 @@ static unsigned int selinux_ip_postroute
 	else {
 		if (!skb->secmark) {
 			u32 xfrm_sid;
+			u32 nlbl_sid;
 
+			err = selinux_netlbl_skb_sid(skb,
+						     skb->secmark,
+						     &nlbl_sid);
+			if (err)
+				goto out;
 			selinux_skb_xfrm_sid(skb, &xfrm_sid);
 
-			if (xfrm_sid)
+			if (nlbl_sid)
+				skb->secmark = nlbl_sid;
+			else if (xfrm_sid)
 				skb->secmark = xfrm_sid;
 			else if (skb->sk) {
 				struct sk_security_struct *sksec =
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
@@ -42,17 +42,17 @@ int selinux_netlbl_socket_post_create(st
 				      int sock_family,
 				      u32 sid);
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock);
-u32 selinux_netlbl_inet_conn_request(struct sk_buff *skb, u32 sock_sid);
-int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
+int selinux_netlbl_sock_rcv_skb(u32 sock_sid,
+				u16 sock_class,
 				struct sk_buff *skb,
 				struct avc_audit_data *ad);
-u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock);
 u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb);
 void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
 				     int family);
 void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec);
 int selinux_netlbl_inode_permission(struct inode *inode, int mask);
+int selinux_netlbl_skb_sid(struct sk_buff *skb, u32 base_sid, u32 *sid);
 #else
 static inline void selinux_netlbl_cache_invalidate(void)
 {
@@ -72,24 +72,14 @@ static inline void selinux_netlbl_sock_g
 	return;
 }
 
-static inline u32 selinux_netlbl_inet_conn_request(struct sk_buff *skb,
-						   u32 sock_sid)
-{
-	return SECSID_NULL;
-}
-
-static inline int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
+static inline int selinux_netlbl_sock_rcv_skb(u32 sock_sid,
+					      u16 sock_class,
 					      struct sk_buff *skb,
 					      struct avc_audit_data *ad)
 {
 	return 0;
 }
 
-static inline u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock)
-{
-	return SECSID_NULL;
-}
-
 static inline u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb)
 {
 	return SECSID_NULL;
@@ -114,6 +104,14 @@ static inline int selinux_netlbl_inode_p
 {
 	return 0;
 }
+
+static inline int selinux_netlbl_skb_sid(struct sk_buff *skb,
+					 u32 base_sid,
+					 u32 *sid)
+{
+	*sid = SECSID_NULL;
+	return 0;
+}
 #endif /* CONFIG_NETLABEL */
 
 #endif
Index: net-2.6/security/selinux/ss/services.c
===================================================================
--- net-2.6.orig/security/selinux/ss/services.c
+++ net-2.6/security/selinux/ss/services.c
@@ -51,6 +51,7 @@
 #include "selinux_netlabel.h"
 
 extern void selnl_notify_policyload(u32 seqno);
+extern int selinux_compat_net;
 unsigned int policydb_loaded_version;
 
 static DEFINE_RWLOCK(policy_rwlock);
@@ -2454,7 +2455,6 @@ void selinux_netlbl_sk_security_init(str
 void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec)
 {
-	newssec->sclass = ssec->sclass;
 	if (ssec->nlbl_state != NLBL_UNSET)
 		newssec->nlbl_state = NLBL_REQUIRE;
 	else
@@ -2476,11 +2476,8 @@ int selinux_netlbl_socket_post_create(st
 				      int sock_family,
 				      u32 sid)
 {
-	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sock->sk->sk_security;
 
-	sksec->sclass = isec->sclass;
-
 	if (sock_family != PF_INET)
 		return 0;
 
@@ -2500,24 +2497,23 @@ int selinux_netlbl_socket_post_create(st
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
 
-	netlbl_secattr_init(&secattr);
-	if (netlbl_sock_getattr(sk, &secattr) == 0 &&
-	    selinux_netlbl_secattr_to_sid(NULL,
-					  &secattr,
-					  sksec->sid,
-					  &nlbl_peer_sid) == 0)
-		sksec->peer_sid = nlbl_peer_sid;
-	netlbl_secattr_destroy(&secattr, 0);
+	if (selinux_compat_net) {
+		netlbl_secattr_init(&secattr);
+		if (netlbl_sock_getattr(sk, &secattr) == 0 &&
+		    selinux_netlbl_secattr_to_sid(NULL,
+						  &secattr,
+						  sksec->sid,
+						  &nlbl_peer_sid) == 0)
+			sksec->peer_sid = nlbl_peer_sid;
+		netlbl_secattr_destroy(&secattr, 0);
+	}
 
 	sksec->nlbl_state = NLBL_REQUIRE;
 
@@ -2528,32 +2524,6 @@ void selinux_netlbl_sock_graft(struct so
 }
 
 /**
- * selinux_netlbl_inet_conn_request - Handle a new connection request
- * @skb: the packet
- * @sock_sid: the SID of the parent socket
- *
- * Description:
- * If present, use the security attributes of the packet in @skb and the
- * parent sock's SID to arrive at a SID for the new child sock.  Returns the
- * SID of the connection or SECSID_NULL on failure.
- *
- */
-u32 selinux_netlbl_inet_conn_request(struct sk_buff *skb, u32 sock_sid)
-{
-	int rc;
-	u32 peer_sid;
-
-	rc = selinux_netlbl_skbuff_getsid(skb, sock_sid, &peer_sid);
-	if (rc != 0)
-		return SECSID_NULL;
-
-	if (peer_sid == SECINITSID_UNLABELED)
-		return SECSID_NULL;
-
-	return peer_sid;
-}
-
-/**
  * selinux_netlbl_inode_permission - Verify the socket is NetLabel labeled
  * @inode: the file descriptor's inode
  * @mask: the permission mask
@@ -2593,7 +2563,8 @@ int selinux_netlbl_inode_permission(stru
 
 /**
  * selinux_netlbl_sock_rcv_skb - Do an inbound access check using NetLabel
- * @sksec: the sock's sk_security_struct
+ * @sock_sid: the socket's SID
+ * @sock_class: the socket's class
  * @skb: the packet
  * @ad: the audit data
  *
@@ -2603,7 +2574,8 @@ int selinux_netlbl_inode_permission(stru
  * error.
  *
  */
-int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
+int selinux_netlbl_sock_rcv_skb(u32 sock_sid,
+				u16 sock_class,
 				struct sk_buff *skb,
 				struct avc_audit_data *ad)
 {
@@ -2618,7 +2590,7 @@ int selinux_netlbl_sock_rcv_skb(struct s
 	if (netlbl_sid == SECINITSID_UNLABELED)
 		return 0;
 
-	switch (sksec->sclass) {
+	switch (sock_class) {
 	case SECCLASS_UDP_SOCKET:
 		recv_perm = UDP_SOCKET__RECVFROM;
 		break;
@@ -2629,9 +2601,9 @@ int selinux_netlbl_sock_rcv_skb(struct s
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
@@ -2642,25 +2614,6 @@ int selinux_netlbl_sock_rcv_skb(struct s
 }
 
 /**
- * selinux_netlbl_socket_getpeersec_stream - Return the connected peer's SID
- * @sock: the socket
- *
- * Description:
- * Examine @sock to find the connected peer's SID.  Returns the SID on success
- * or SECSID_NULL on error.
- *
- */
-u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock)
-{
-	struct sk_security_struct *sksec = sock->sk->sk_security;
-
-	if (sksec->peer_sid == SECINITSID_UNLABELED)
-		return SECSID_NULL;
-
-	return sksec->peer_sid;
-}
-
-/**
  * selinux_netlbl_socket_getpeersec_dgram - Return the SID of a NetLabel packet
  * @skb: the packet
  *
@@ -2686,4 +2639,27 @@ u32 selinux_netlbl_socket_getpeersec_dgr
 
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
+		*sid = SECSID_NULL;
+
+	return rc;
+}
 #endif /* CONFIG_NETLABEL */

--
paul moore
linux security @ hp
