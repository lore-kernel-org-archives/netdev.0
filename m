From: paul.moore@hp.com
Subject: [PATCH 12/13] SELinux: peer secid consolidation for external network labeling
Date: Fri, 17 Nov 2006 17:38:54 -0500
Message-ID: <20061117224338.040702000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:62361 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1755987AbWKQWnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:40 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-selinux_peersec
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Now that labeled IPsec makes use of the peer_sid field in the
sk_security_struct we can remove a lot of the special cases between labeled
IPsec and NetLabel.  In addition, create a new function,
security_skb_extlbl_sid(), which we can use in several places to get the
security context of the packet's external label which allows us to further
simplify the code in a few places.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/hooks.c                    |   43 +++----------
 security/selinux/include/security.h         |    3 
 security/selinux/include/selinux_netlabel.h |   28 ++------
 security/selinux/include/xfrm.h             |    5 -
 security/selinux/ss/services.c              |   90 ++++++++--------------------
 security/selinux/xfrm.c                     |   33 ----------
 6 files changed, 52 insertions(+), 150 deletions(-)

Index: net-2.6.20_netlabel-base-work/security/selinux/hooks.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/hooks.c
+++ net-2.6.20_netlabel-base-work/security/selinux/hooks.c
@@ -3573,27 +3573,16 @@ static int selinux_socket_getpeersec_str
 	u32 scontext_len;
 	struct sk_security_struct *ssec;
 	struct inode_security_struct *isec;
-	u32 peer_sid = 0;
+	u32 peer_sid = SECSID_NULL;
 
 	isec = SOCK_INODE(sock)->i_security;
 
-	/* if UNIX_STREAM check peer_sid, if TCP check dst for labelled sa */
-	if (isec->sclass == SECCLASS_UNIX_STREAM_SOCKET) {
+	if (isec->sclass == SECCLASS_UNIX_STREAM_SOCKET ||
+	    isec->sclass == SECCLASS_TCP_SOCKET) {
 		ssec = sock->sk->sk_security;
 		peer_sid = ssec->peer_sid;
 	}
-	else if (isec->sclass == SECCLASS_TCP_SOCKET) {
-		peer_sid = selinux_netlbl_socket_getpeersec_stream(sock);
-		if (peer_sid == SECSID_NULL) {
-			ssec = sock->sk->sk_security;
-			peer_sid = ssec->peer_sid;
-		}
-		if (peer_sid == SECSID_NULL) {
-			err = -ENOPROTOOPT;
-			goto out;
-		}
-	}
-	else {
+	if (peer_sid == SECSID_NULL) {
 		err = -ENOPROTOOPT;
 		goto out;
 	}
@@ -3625,13 +3614,12 @@ static int selinux_socket_getpeersec_dgr
 	u32 peer_secid = SECSID_NULL;
 	int err = 0;
 
-	if (sock && (sock->sk->sk_family == PF_UNIX))
+	if (sock && sock->sk->sk_family == PF_UNIX)
 		selinux_get_inode_sid(SOCK_INODE(sock), &peer_secid);
-	else if (skb) {
-		peer_secid = selinux_netlbl_socket_getpeersec_dgram(skb);
-		if (peer_secid == SECSID_NULL)
-			peer_secid = selinux_socket_getpeer_dgram(skb);
-	}
+	else if (skb)
+		security_skb_extlbl_sid(skb,
+					SECINITSID_UNLABELED,
+					&peer_secid);
 
 	if (peer_secid == SECSID_NULL)
 		err = -EINVAL;
@@ -3692,17 +3680,10 @@ static int selinux_inet_conn_request(str
 	u32 newsid;
 	u32 peersid;
 
-	newsid = selinux_netlbl_inet_conn_request(skb, sksec->sid);
-	if (newsid != SECSID_NULL) {
-		req->secid = newsid;
-		return 0;
-	}
-
-	selinux_skb_xfrm_sid(skb, &peersid);
-
+	security_skb_extlbl_sid(skb, SECINITSID_UNLABELED, &peersid);
 	if (peersid == SECSID_NULL) {
 		req->secid = sksec->sid;
-		req->peer_secid = 0;
+		req->peer_secid = SECSID_NULL;
 		return 0;
 	}
 
@@ -3737,7 +3718,7 @@ static void selinux_inet_conn_establishe
 {
 	struct sk_security_struct *sksec = sk->sk_security;
 
-	selinux_skb_xfrm_sid(skb, &sksec->peer_sid);
+	security_skb_extlbl_sid(skb, SECINITSID_UNLABELED, &sksec->peer_sid);
 }
 
 static void selinux_req_classify_flow(const struct request_sock *req,
Index: net-2.6.20_netlabel-base-work/security/selinux/include/security.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/include/security.h
+++ net-2.6.20_netlabel-base-work/security/selinux/include/security.h
@@ -8,6 +8,7 @@
 #ifndef _SELINUX_SECURITY_H_
 #define _SELINUX_SECURITY_H_
 
+#include <linux/skbuff.h>
 #include "flask.h"
 
 #define SECSID_NULL			0x00000000 /* unspecified SID */
@@ -80,6 +81,8 @@ int security_netif_sid(char *name, u32 *
 int security_node_sid(u16 domain, void *addr, u32 addrlen,
 	u32 *out_sid);
 
+void security_skb_extlbl_sid(struct sk_buff *skb, u32 base_sid, u32 *sid);
+
 int security_validate_transition(u32 oldsid, u32 newsid, u32 tasksid,
                                  u16 tclass);
 
Index: net-2.6.20_netlabel-base-work/security/selinux/include/selinux_netlabel.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/include/selinux_netlabel.h
+++ net-2.6.20_netlabel-base-work/security/selinux/include/selinux_netlabel.h
@@ -38,14 +38,12 @@
 
 #ifdef CONFIG_NETLABEL
 void selinux_netlbl_cache_invalidate(void);
+int selinux_netlbl_skbuff_getsid(struct sk_buff *skb, u32 base_sid, u32 *sid);
 int selinux_netlbl_socket_post_create(struct socket *sock);
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock);
-u32 selinux_netlbl_inet_conn_request(struct sk_buff *skb, u32 sock_sid);
 int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 				struct sk_buff *skb,
 				struct avc_audit_data *ad);
-u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock);
-u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb);
 void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
 				      int family);
 void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
@@ -62,6 +60,14 @@ static inline void selinux_netlbl_cache_
 	return;
 }
 
+static inline int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
+					       u32 base_sid,
+					       u32 *sid)
+{
+	*sid = SECSID_NULL;
+	return 0;
+}
+
 static inline int selinux_netlbl_socket_post_create(struct socket *sock)
 {
 	return 0;
@@ -73,12 +79,6 @@ static inline void selinux_netlbl_sock_g
 	return;
 }
 
-static inline u32 selinux_netlbl_inet_conn_request(struct sk_buff *skb,
-						   u32 sock_sid)
-{
-	return SECSID_NULL;
-}
-
 static inline int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 					      struct sk_buff *skb,
 					      struct avc_audit_data *ad)
@@ -86,16 +86,6 @@ static inline int selinux_netlbl_sock_rc
 	return 0;
 }
 
-static inline u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock)
-{
-	return SECSID_NULL;
-}
-
-static inline u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb)
-{
-	return SECSID_NULL;
-}
-
 static inline void selinux_netlbl_sk_security_reset(
 					       struct sk_security_struct *ssec,
 					       int family)
Index: net-2.6.20_netlabel-base-work/security/selinux/include/xfrm.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/include/xfrm.h
+++ net-2.6.20_netlabel-base-work/security/selinux/include/xfrm.h
@@ -36,7 +36,6 @@ int selinux_xfrm_sock_rcv_skb(u32 sid, s
 			struct avc_audit_data *ad);
 int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad, u8 proto);
-u32 selinux_socket_getpeer_dgram(struct sk_buff *skb);
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
 #else
 static inline int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
@@ -51,10 +50,6 @@ static inline int selinux_xfrm_postroute
 	return 0;
 }
 
-static inline int selinux_socket_getpeer_dgram(struct sk_buff *skb)
-{
-	return SECSID_NULL;
-}
 static inline int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
 {
 	*sid = SECSID_NULL;
Index: net-2.6.20_netlabel-base-work/security/selinux/ss/services.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/ss/services.c
+++ net-2.6.20_netlabel-base-work/security/selinux/ss/services.c
@@ -50,6 +50,7 @@
 #include "mls.h"
 #include "objsec.h"
 #include "selinux_netlabel.h"
+#include "xfrm.h"
 
 extern void selnl_notify_policyload(u32 seqno);
 unsigned int policydb_loaded_version;
@@ -2146,6 +2147,32 @@ void selinux_audit_set_callback(int (*ca
 	aurule_callback = callback;
 }
 
+/**
+ * security_skb_extlbl_sid - Determine the external label of a packet
+ * @skb: the packet
+ * @base_sid: the SELinux SID to use as a context for MLS only external labels
+ * @sid: the packet's SID
+ *
+ * Description:
+ * Check the various different forms of external packet labeling and determine
+ * the external SID for the packet.
+ *
+ */
+void security_skb_extlbl_sid(struct sk_buff *skb, u32 base_sid, u32 *sid)
+{
+	u32 xfrm_sid;
+	u32 nlbl_sid;
+
+	selinux_skb_xfrm_sid(skb, &xfrm_sid);
+	if (selinux_netlbl_skbuff_getsid(skb,
+					 (xfrm_sid == SECSID_NULL ?
+					  base_sid : xfrm_sid),
+					 &nlbl_sid) != 0)
+		nlbl_sid = SECSID_NULL;
+
+	*sid = (nlbl_sid == SECSID_NULL ? xfrm_sid : nlbl_sid);
+}
+
 #ifdef CONFIG_NETLABEL
 /*
  * This is the structure we store inside the NetLabel cache block.
@@ -2363,9 +2390,7 @@ netlbl_secattr_to_sid_return_cleanup:
  * assign to the packet.  Returns zero on success, negative values on failure.
  *
  */
-static int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
-					u32 base_sid,
-					u32 *sid)
+int selinux_netlbl_skbuff_getsid(struct sk_buff *skb, u32 base_sid, u32 *sid)
 {
 	int rc;
 	struct netlbl_lsm_secattr secattr;
@@ -2571,29 +2596,6 @@ void selinux_netlbl_sock_graft(struct so
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
-	return peer_sid;
-}
-
-/**
  * selinux_netlbl_inode_permission - Verify the socket is NetLabel labeled
  * @inode: the file descriptor's inode
  * @mask: the permission mask
@@ -2683,42 +2685,6 @@ int selinux_netlbl_sock_rcv_skb(struct s
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
-	return sksec->peer_sid;
-}
-
-/**
- * selinux_netlbl_socket_getpeersec_dgram - Return the SID of a NetLabel packet
- * @skb: the packet
- *
- * Description:
- * Examine @skb to find the SID assigned to it by NetLabel.  Returns the SID on
- * success, SECSID_NULL on error.
- *
- */
-u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb)
-{
-	int peer_sid;
-
-	if (selinux_netlbl_skbuff_getsid(skb,
-					 SECINITSID_UNLABELED,
-					 &peer_sid) != 0)
-		return SECSID_NULL;
-
-	return peer_sid;
-}
-
-/**
  * selinux_netlbl_socket_setsockopt - Do not allow users to remove a NetLabel
  * @sock: the socket
  * @level: the socket level or protocol
Index: net-2.6.20_netlabel-base-work/security/selinux/xfrm.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/xfrm.c
+++ net-2.6.20_netlabel-base-work/security/selinux/xfrm.c
@@ -372,39 +372,6 @@ void selinux_xfrm_state_free(struct xfrm
 		kfree(ctx);
 }
 
-/*
- * SELinux internal function to retrieve the context of a UDP packet
- * based on its security association.
- *
- * Retrieve via setsockopt IP_PASSSEC and recvmsg with control message
- * type SCM_SECURITY.
- */
-u32 selinux_socket_getpeer_dgram(struct sk_buff *skb)
-{
-	struct sec_path *sp;
-
-	if (skb == NULL)
-		return SECSID_NULL;
-
-	if (skb->sk->sk_protocol != IPPROTO_UDP)
-		return SECSID_NULL;
-
-	sp = skb->sp;
-	if (sp) {
-		int i;
-
-		for (i = sp->len-1; i >= 0; i--) {
-			struct xfrm_state *x = sp->xvec[i];
-			if (selinux_authorizable_xfrm(x)) {
-				struct xfrm_sec_ctx *ctx = x->security;
-				return ctx->ctx_sid;
-			}
-		}
-	}
-
-	return SECSID_NULL;
-}
-
  /*
   * LSM hook implementation that authorizes deletion of labeled SAs.
   */

--
paul moore
linux security @ hp
