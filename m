From: paul.moore@hp.com
Subject: [PATCH 11/11] secid reconciliation: support for NetLabel
Date: Mon, 09 Oct 2006 15:42:34 -0400
Message-ID: <20061009195853.495026000@hp.com>
References: <20061009194223.402695000@hp.com>
Cc: vyekkirala@TrustedCS.com, jmorris@namei.org, sds@tycho.nsa.gov,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:55967 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S964792AbWJIT64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 15:58:56 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=secid-netlabel
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

This patch provides the missing NetLabel support to the secid reconciliation
patchset.

This includes a change to the security_skb_flow_in() LSM hook to indicate if
the hook is in the forwarding path and a change to netlbl_skbuff_err() to carry
the forwarding information to the lower protocol level.  This was required to
meet the CIPSO specifications regarding handling permission denied errors.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/linux/security.h                    |   10 +-
 include/net/netlabel.h                      |    6 -
 include/net/xfrm.h                          |    4 
 net/netlabel/netlabel_kapi.c                |    5 -
 security/dummy.c                            |    3 
 security/selinux/hooks.c                    |  139 +++++++++++++++++++---------
 security/selinux/include/objsec.h           |    1 
 security/selinux/include/selinux_netlabel.h |   34 ++----
 security/selinux/ss/services.c              |  124 ++++--------------------
 9 files changed, 153 insertions(+), 173 deletions(-)

Index: net-2.6_secidfinal/include/linux/security.h
===================================================================
--- net-2.6_secidfinal.orig/include/linux/security.h
+++ net-2.6_secidfinal/include/linux/security.h
@@ -1385,7 +1385,7 @@ struct security_operations {
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 	void (*inet_conn_established)(struct sock *sk, struct sk_buff *skb);
 	void (*igmp_classify_skb)(struct sk_buff *skb);
-	int (*skb_flow_in)(struct sk_buff *skb, unsigned short family);
+	int (*skb_flow_in)(struct sk_buff *skb, unsigned short family, u32 fwd);
 	int (*skb_flow_out)(struct sk_buff *skb, u32 nf_secid,
 			const struct net_device *out, unsigned short family);
 #endif	/* CONFIG_SECURITY_NETWORK */
@@ -2964,9 +2964,10 @@ static inline void security_igmp_classif
 }
 
 static inline int security_skb_flow_in(struct sk_buff *skb,
-					unsigned short family)
+				       unsigned short family,
+				       u32 fwd)
 {
-	return security_ops->skb_flow_in(skb, family);
+	return security_ops->skb_flow_in(skb, family, fwd);
 }
 
 static inline int security_skb_flow_out(struct sk_buff *skb,
@@ -3134,7 +3135,8 @@ static inline void security_igmp_classif
 }
 
 static inline int security_skb_flow_in(struct sk_buff *skb,
-					unsigned short family)
+				       unsigned short family,
+				       u32 fwd)
 {
 	return 1;
 }
Index: net-2.6_secidfinal/include/net/netlabel.h
===================================================================
--- net-2.6_secidfinal.orig/include/net/netlabel.h
+++ net-2.6_secidfinal/include/net/netlabel.h
@@ -237,7 +237,7 @@ int netlbl_socket_getattr(const struct s
 			  struct netlbl_lsm_secattr *secattr);
 int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  struct netlbl_lsm_secattr *secattr);
-void netlbl_skbuff_err(struct sk_buff *skb, int error);
+void netlbl_skbuff_err(struct sk_buff *skb, int error, u32 gateway);
 #else
 static inline int netlbl_socket_setattr(const struct socket *sock,
 				     const struct netlbl_lsm_secattr *secattr)
@@ -263,7 +263,9 @@ static inline int netlbl_skbuff_getattr(
 	return -ENOSYS;
 }
 
-static inline void netlbl_skbuff_err(struct sk_buff *skb, int error)
+static inline void netlbl_skbuff_err(struct sk_buff *skb,
+				     int error,
+				     u32 gateway)
 {
 	return;
 }
Index: net-2.6_secidfinal/include/net/xfrm.h
===================================================================
--- net-2.6_secidfinal.orig/include/net/xfrm.h
+++ net-2.6_secidfinal/include/net/xfrm.h
@@ -685,7 +685,9 @@ static inline int xfrm_policy_check(stru
 		      __xfrm_policy_check(sk, dir, skb, family);
 
 	if (ret)
-		ret = security_skb_flow_in(skb, family);
+		ret = security_skb_flow_in(skb,
+					   family,
+					   dir == XFRM_POLICY_FWD ? 1 : 0);
 	return ret;
 }
 
Index: net-2.6_secidfinal/net/netlabel/netlabel_kapi.c
===================================================================
--- net-2.6_secidfinal.orig/net/netlabel/netlabel_kapi.c
+++ net-2.6_secidfinal/net/netlabel/netlabel_kapi.c
@@ -159,6 +159,7 @@ int netlbl_skbuff_getattr(const struct s
  * netlbl_skbuff_err - Handle a LSM error on a sk_buff
  * @skb: the packet
  * @error: the error code
+ * @gateway: true if the packet is being forwarded and not consumed locally
  *
  * Description:
  * Deal with a LSM problem when handling the packet in @skb, typically this is
@@ -166,10 +167,10 @@ int netlbl_skbuff_getattr(const struct s
  * according to the packet's labeling protocol.
  *
  */
-void netlbl_skbuff_err(struct sk_buff *skb, int error)
+void netlbl_skbuff_err(struct sk_buff *skb, int error, u32 gateway)
 {
 	if (CIPSO_V4_OPTEXIST(skb))
-		cipso_v4_error(skb, error, 0);
+		cipso_v4_error(skb, error, gateway);
 }
 
 /**
Index: net-2.6_secidfinal/security/dummy.c
===================================================================
--- net-2.6_secidfinal.orig/security/dummy.c
+++ net-2.6_secidfinal/security/dummy.c
@@ -838,7 +838,8 @@ static inline void dummy_igmp_classify_s
 }
 
 static inline int dummy_skb_flow_in(struct sk_buff *skb,
-			unsigned short family)
+				    unsigned short family,
+				    u32 fwd)
 {
 	return -ENOENT;
 }
Index: net-2.6_secidfinal/security/selinux/hooks.c
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/hooks.c
+++ net-2.6_secidfinal/security/selinux/hooks.c
@@ -50,6 +50,7 @@
 #include <net/icmp.h>
 #include <net/ip.h>		/* for sysctl_local_port_range[] */
 #include <net/tcp.h>		/* struct or_callable used in sock_rcv_skb */
+#include <net/netlabel.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 #include <linux/bitops.h>
@@ -3465,6 +3466,10 @@ static int selinux_sock_rcv_skb_compat(s
 			goto out;
 	}
 
+	err = selinux_netlbl_sock_rcv_skb(sock_sid, sock_class, skb, ad);
+	if (err)
+		goto out;
+
 	err = selinux_xfrm_sock_rcv_skb(sock_sid, skb, ad);
 
 out:
@@ -3498,13 +3503,15 @@ static int selinux_socket_sock_rcv_skb(s
 	if (selinux_compat_net)
 		err = selinux_sock_rcv_skb_compat(sk, skb, &ad, family,
 						  addrp, len);
-	else
+	else {
 		err = avc_has_perm(sksec->sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__RECV, &ad);
-	if (err)
-		goto out;
+		if (err)
+			/* This is okay because NetLabel will only act here
+			 * if the packet is labeled with NetLabel already. */
+			netlbl_skbuff_err(skb, err, 0);
+	}
 
-	err = selinux_netlbl_sock_rcv_skb(sksec, skb, &ad);
 out:	
 	return err;
 }
@@ -3527,11 +3534,8 @@ static int selinux_socket_getpeersec_str
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
@@ -3573,13 +3577,17 @@ static int selinux_socket_getpeersec_dgr
 	if (sock && (sock->sk->sk_family == PF_UNIX))
 		selinux_get_inode_sid(SOCK_INODE(sock), &peer_secid);
 	else if (skb) {
-		peer_secid = selinux_netlbl_socket_getpeersec_dgram(skb);
-		if (peer_secid == SECSID_NULL) {
-			if (selinux_compat_net)
-				peer_secid = selinux_socket_getpeer_dgram(skb);
-			else
-				peer_secid = skb->secmark;
-		}
+		if (selinux_compat_net) {
+			u32 xfrm_peer_secid;
+
+			xfrm_peer_secid = selinux_socket_getpeer_dgram(skb);
+			err = selinux_netlbl_skb_sid(skb,
+						     xfrm_peer_secid,
+						     &peer_secid);
+			if (err == 0 && peer_secid == SECSID_NULL)
+				peer_secid = xfrm_peer_secid;
+		} else
+			peer_secid = skb->secmark;
 	}
 
 	if (peer_secid == SECSID_NULL)
@@ -3641,13 +3649,11 @@ static int selinux_inet_conn_request(str
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
 
@@ -3659,6 +3665,7 @@ static int selinux_inet_conn_request(str
 	} else
 		peersid = skb->secmark;
 
+out:
 	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
 	if (err)
 		return err;
@@ -3696,9 +3703,14 @@ static void selinux_igmp_classify_skb(st
 	skb->secmark = SECINITSID_IGMP_PACKET;
 }
 
-static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
+static int selinux_skb_flow_in(struct sk_buff *skb,
+			       unsigned short family,
+			       u32 fwd)
 {
 	u32 xfrm_sid;
+	u32 nlbl_sid;
+	u32 nlbl_base_sid;
+	u32 ext_sid;
 	int err;
 	struct avc_audit_data ad;
 	char *addrp;
@@ -3724,20 +3736,38 @@ static int selinux_skb_flow_in(struct sk
 	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
 	BUG_ON(err);
 
-	err = avc_has_perm(xfrm_sid, skb->secmark? : SECINITSID_NETMSG,
-					SECCLASS_PACKET,
-					PACKET__FLOW_IN, &ad);
+	if (xfrm_sid)
+		nlbl_base_sid = xfrm_sid;
+	else if (skb->secmark)
+		nlbl_base_sid = skb->secmark;
+	else
+		nlbl_base_sid = SECINITSID_UNLABELED;
+	err = selinux_netlbl_skb_sid(skb, nlbl_base_sid, &nlbl_sid);
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
+			   skb->secmark ? skb->secmark : SECINITSID_NETMSG,
+			   SECCLASS_PACKET,
+			   PACKET__FLOW_IN,
+			   &ad);
+	if (err) {
+		if (nlbl_sid)
+			netlbl_skbuff_err(skb, err, fwd);
+		goto out;
+	}
+
+	if (ext_sid)
+		skb->secmark = ext_sid;
 
 out:
 	return err ? 0 : 1;
-};
+}
 
 static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid,
 			const struct net_device *out, unsigned short family)
@@ -3752,16 +3782,30 @@ static int selinux_skb_flow_out(struct s
 		return 1;
 
 	if (!skb->secmark) {
+		u32 sk_sid;
 		u32 xfrm_sid;
+		u32 nlbl_sid;
+
+		if (skb->sk) {
+			struct sk_security_struct *sksec =
+				                          skb->sk->sk_security;
+			sk_sid = sksec->sid;
+		} else
+			sk_sid = SECSID_NULL;
 
 		selinux_skb_xfrm_sid(skb, &xfrm_sid);
+		err = selinux_netlbl_skb_sid(skb,
+					     xfrm_sid ? xfrm_sid : sk_sid,
+					     &nlbl_sid);
+		if (err)
+			goto out;
 
-		if (xfrm_sid)
+		if (nlbl_sid)
+			skb->secmark = nlbl_sid;
+		else if (xfrm_sid)
 			skb->secmark = xfrm_sid;
-		else if (skb->sk) {
-			struct sk_security_struct *sksec = skb->sk->sk_security;
-			skb->secmark = sksec->sid;
-		}
+		else if (sk_sid)
+			skb->secmark = sk_sid;
 	}
 
 	AVC_AUDIT_DATA_INIT(&ad, NET);
@@ -3923,17 +3967,30 @@ static unsigned int selinux_ip_postroute
 						       family, addrp, len);
 	else {
 		if (!skb->secmark) {
+			u32 sk_sid;
 			u32 xfrm_sid;
+			u32 nlbl_sid;
+
+			if (skb->sk) {
+				struct sk_security_struct *sksec =
+					                  skb->sk->sk_security;
+				sk_sid = sksec->sid;
+			} else
+				sk_sid = SECSID_NULL;
 
 			selinux_skb_xfrm_sid(skb, &xfrm_sid);
+			err = selinux_netlbl_skb_sid(skb,
+						  xfrm_sid ? xfrm_sid : sk_sid,
+						  &nlbl_sid);
+			if (err)
+				goto out;
 
-			if (xfrm_sid)
+			if (nlbl_sid)
+				skb->secmark = nlbl_sid;
+			else if (xfrm_sid)
 				skb->secmark = xfrm_sid;
-			else if (skb->sk) {
-				struct sk_security_struct *sksec =
-						skb->sk->sk_security;
-				skb->secmark = sksec->sid;
-			}
+			else if (sk_sid)
+				skb->secmark = sk_sid;
 		}
 		if (out == &loopback_dev)
 			return NF_ACCEPT;
Index: net-2.6_secidfinal/security/selinux/include/objsec.h
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/include/objsec.h
+++ net-2.6_secidfinal/security/selinux/include/objsec.h
@@ -102,7 +102,6 @@ struct sk_security_struct {
 	u32 sid;			/* SID of this object */
 	u32 peer_sid;			/* SID of peer */
 #ifdef CONFIG_NETLABEL
-	u16 sclass;			/* sock security class */
 	enum {				/* NetLabel state */
 		NLBL_UNSET = 0,
 		NLBL_REQUIRE,
Index: net-2.6_secidfinal/security/selinux/include/selinux_netlabel.h
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/include/selinux_netlabel.h
+++ net-2.6_secidfinal/security/selinux/include/selinux_netlabel.h
@@ -42,17 +42,16 @@ int selinux_netlbl_socket_post_create(st
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
-u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb);
 void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
 				     int family);
 void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec);
 int selinux_netlbl_inode_permission(struct inode *inode, int mask);
+int selinux_netlbl_skb_sid(struct sk_buff *skb, u32 base_sid, u32 *sid);
 #else
 static inline void selinux_netlbl_cache_invalidate(void)
 {
@@ -72,29 +71,14 @@ static inline void selinux_netlbl_sock_g
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
-static inline u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb)
-{
-	return SECSID_NULL;
-}
-
 static inline void selinux_netlbl_sk_security_init(
 	                                       struct sk_security_struct *ssec,
 					       int family)
@@ -114,6 +98,14 @@ static inline int selinux_netlbl_inode_p
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
Index: net-2.6_secidfinal/security/selinux/ss/services.c
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/ss/services.c
+++ net-2.6_secidfinal/security/selinux/ss/services.c
@@ -51,6 +51,7 @@
 #include "selinux_netlabel.h"
 
 extern void selnl_notify_policyload(u32 seqno);
+extern int selinux_compat_net;
 unsigned int policydb_loaded_version;
 
 static DEFINE_RWLOCK(policy_rwlock);
@@ -2336,7 +2337,7 @@ static int selinux_netlbl_secattr_to_sid
 			selinux_netlbl_cache_add(skb, &ctx_new);
 		ebitmap_destroy(&ctx_new.range.level[0].cat);
 	} else {
-		*sid = SECINITSID_UNLABELED;
+		*sid = SECSID_NULL;
 		rc = 0;
 	}
 
@@ -2349,7 +2350,7 @@ netlbl_secattr_to_sid_return_cleanup:
 }
 
 /**
- * selinux_netlbl_skbuff_getsid - Get the sid of a packet using NetLabel
+ * selinux_netlbl_skb_sid - Get the SID of a packet using NetLabel
  * @skb: the packet
  * @base_sid: the SELinux SID to use as a context for MLS only attributes
  * @sid: the SID
@@ -2360,9 +2361,7 @@ netlbl_secattr_to_sid_return_cleanup:
  * assign to the packet.  Returns zero on success, negative values on failure.
  *
  */
-static int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
-					u32 base_sid,
-					u32 *sid)
+int selinux_netlbl_skb_sid(struct sk_buff *skb, u32 base_sid, u32 *sid)
 {
 	int rc;
 	struct netlbl_lsm_secattr secattr;
@@ -2459,7 +2458,6 @@ void selinux_netlbl_sk_security_init(str
 void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec)
 {
-	newssec->sclass = ssec->sclass;
 	if (ssec->nlbl_state != NLBL_UNSET)
 		newssec->nlbl_state = NLBL_REQUIRE;
 	else
@@ -2481,11 +2479,8 @@ int selinux_netlbl_socket_post_create(st
 				      int sock_family,
 				      u32 sid)
 {
-	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sock->sk->sk_security;
 
-	sksec->sclass = isec->sclass;
-
 	if (sock_family != PF_INET)
 		return 0;
 
@@ -2505,24 +2500,23 @@ int selinux_netlbl_socket_post_create(st
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
-	netlbl_secattr_destroy(&secattr);
+	if (selinux_compat_net) {
+		netlbl_secattr_init(&secattr);
+		if (netlbl_sock_getattr(sk, &secattr) == 0 &&
+		    selinux_netlbl_secattr_to_sid(NULL,
+						  &secattr,
+						  SECINITSID_UNLABELED,
+						  &nlbl_peer_sid) == 0)
+			sksec->peer_sid = nlbl_peer_sid;
+		netlbl_secattr_destroy(&secattr);
+	}
 
 	sksec->nlbl_state = NLBL_REQUIRE;
 
@@ -2533,32 +2527,6 @@ void selinux_netlbl_sock_graft(struct so
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
@@ -2598,7 +2566,8 @@ int selinux_netlbl_inode_permission(stru
 
 /**
  * selinux_netlbl_sock_rcv_skb - Do an inbound access check using NetLabel
- * @sksec: the sock's sk_security_struct
+ * @sock_sid: the socket's SID
+ * @sock_class: the socket's class
  * @skb: the packet
  * @ad: the audit data
  *
@@ -2608,7 +2577,8 @@ int selinux_netlbl_inode_permission(stru
  * error.
  *
  */
-int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
+int selinux_netlbl_sock_rcv_skb(u32 sock_sid,
+				u16 sock_class,
 				struct sk_buff *skb,
 				struct avc_audit_data *ad)
 {
@@ -2616,14 +2586,14 @@ int selinux_netlbl_sock_rcv_skb(struct s
 	u32 netlbl_sid;
 	u32 recv_perm;
 
-	rc = selinux_netlbl_skbuff_getsid(skb, SECINITSID_NETMSG, &netlbl_sid);
+	rc = selinux_netlbl_skb_sid(skb, SECINITSID_UNLABELED, &netlbl_sid);
 	if (rc != 0)
 		return rc;
 
-	if (netlbl_sid == SECINITSID_UNLABELED)
+	if (netlbl_sid == SECSID_NULL)
 		return 0;
 
-	switch (sksec->sclass) {
+	switch (sock_class) {
 	case SECCLASS_UDP_SOCKET:
 		recv_perm = UDP_SOCKET__RECVFROM;
 		break;
@@ -2634,61 +2604,15 @@ int selinux_netlbl_sock_rcv_skb(struct s
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
 		return 0;
 
-	netlbl_skbuff_err(skb, rc);
+	netlbl_skbuff_err(skb, rc, 0);
 	return rc;
 }
-
-/**
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
-	struct sock *sk = skb->sk;
-	struct inode_security_struct *isec;
-
-	if (sk == NULL || sk->sk_socket == NULL)
-		return SECSID_NULL;
-
-	isec = SOCK_INODE(sk->sk_socket)->i_security;
-	if (selinux_netlbl_skbuff_getsid(skb, isec->sid, &peer_sid) != 0)
-		return SECSID_NULL;
-	if (peer_sid == SECINITSID_UNLABELED)
-		return SECSID_NULL;
-
-	return peer_sid;
-}
 #endif /* CONFIG_NETLABEL */

--
paul moore
linux security @ hp
