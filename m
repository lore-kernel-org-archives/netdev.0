From: paul.moore@hp.com
Subject: [PATCH 11/13] NetLabel: SELinux cleanups
Date: Fri, 17 Nov 2006 17:38:53 -0500
Message-ID: <20061117224337.351000000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:17837 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1755995AbWKQWnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:39 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-selinux_cleanup
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

This patch does a lot of cleanup in the SELinux NetLabel support code.  A
summary of the changes include:

* Use RCU locking for the NetLabel state variable in the skk_security_struct
  instead of using the inode_security_struct mutex.
* Remove unnecessary parameters in selinux_netlbl_socket_post_create().
* Rename selinux_netlbl_sk_clone_security() to
  selinux_netlbl_sk_security_clone() to better fit the other NetLabel
  sk_security functions.
* Improvements to selinux_netlbl_inode_permission() to help reduce the cost of
  the common case.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/hooks.c                    |   10 +-
 security/selinux/include/objsec.h           |    2 
 security/selinux/include/selinux_netlabel.h |   21 +++--
 security/selinux/ss/services.c              |  107 +++++++++++++++++-----------
 4 files changed, 86 insertions(+), 54 deletions(-)

Index: net-2.6.20_netlabel-base-work/security/selinux/hooks.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/hooks.c
+++ net-2.6.20_netlabel-base-work/security/selinux/hooks.c
@@ -3139,9 +3139,7 @@ static int selinux_socket_post_create(st
 	if (sock->sk) {
 		sksec = sock->sk->sk_security;
 		sksec->sid = isec->sid;
-		err = selinux_netlbl_socket_post_create(sock,
-							family,
-							isec->sid);
+		err = selinux_netlbl_socket_post_create(sock);
 	}
 
 	return err;
@@ -3660,7 +3658,7 @@ static void selinux_sk_clone_security(co
 	newssec->sid = ssec->sid;
 	newssec->peer_sid = ssec->peer_sid;
 
-	selinux_netlbl_sk_clone_security(ssec, newssec);
+	selinux_netlbl_sk_security_clone(ssec, newssec);
 }
 
 static void selinux_sk_getsecid(struct sock *sk, u32 *secid)
@@ -3729,7 +3727,9 @@ static void selinux_inet_csk_clone(struc
 	   So we will wait until sock_graft to do it, by which
 	   time it will have been created and available. */
 
-	selinux_netlbl_sk_security_init(newsksec, req->rsk_ops->family);
+	/* We don't need to take any sort of lock here as we are the only
+	 * thread with access to newsksec */
+	selinux_netlbl_sk_security_reset(newsksec, req->rsk_ops->family);
 }
 
 static void selinux_inet_conn_established(struct sock *sk,
Index: net-2.6.20_netlabel-base-work/security/selinux/include/objsec.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/include/objsec.h
+++ net-2.6.20_netlabel-base-work/security/selinux/include/objsec.h
@@ -23,6 +23,7 @@
 #include <linux/fs.h>
 #include <linux/binfmts.h>
 #include <linux/in.h>
+#include <linux/spinlock.h>
 #include "flask.h"
 #include "avc.h"
 
@@ -108,6 +109,7 @@ struct sk_security_struct {
 		NLBL_REQUIRE,
 		NLBL_LABELED,
 	} nlbl_state;
+	spinlock_t nlbl_lock;		/* protects nlbl_state */
 #endif
 };
 
Index: net-2.6.20_netlabel-base-work/security/selinux/include/selinux_netlabel.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/include/selinux_netlabel.h
+++ net-2.6.20_netlabel-base-work/security/selinux/include/selinux_netlabel.h
@@ -38,9 +38,7 @@
 
 #ifdef CONFIG_NETLABEL
 void selinux_netlbl_cache_invalidate(void);
-int selinux_netlbl_socket_post_create(struct socket *sock,
-				      int sock_family,
-				      u32 sid);
+int selinux_netlbl_socket_post_create(struct socket *sock);
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock);
 u32 selinux_netlbl_inet_conn_request(struct sk_buff *skb, u32 sock_sid);
 int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
@@ -48,9 +46,11 @@ int selinux_netlbl_sock_rcv_skb(struct s
 				struct avc_audit_data *ad);
 u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock);
 u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb);
+void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
+				      int family);
 void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
 				     int family);
-void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
+void selinux_netlbl_sk_security_clone(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec);
 int selinux_netlbl_inode_permission(struct inode *inode, int mask);
 int selinux_netlbl_socket_setsockopt(struct socket *sock,
@@ -62,9 +62,7 @@ static inline void selinux_netlbl_cache_
 	return;
 }
 
-static inline int selinux_netlbl_socket_post_create(struct socket *sock,
-						    int sock_family,
-						    u32 sid)
+static inline int selinux_netlbl_socket_post_create(struct socket *sock)
 {
 	return 0;
 }
@@ -98,6 +96,13 @@ static inline u32 selinux_netlbl_socket_
 	return SECSID_NULL;
 }
 
+static inline void selinux_netlbl_sk_security_reset(
+					       struct sk_security_struct *ssec,
+					       int family)
+{
+	return;
+}
+
 static inline void selinux_netlbl_sk_security_init(
 	                                       struct sk_security_struct *ssec,
 					       int family)
@@ -105,7 +110,7 @@ static inline void selinux_netlbl_sk_sec
 	return;
 }
 
-static inline void selinux_netlbl_sk_clone_security(
+static inline void selinux_netlbl_sk_security_clone(
 	                                   struct sk_security_struct *ssec,
 					   struct sk_security_struct *newssec)
 {
Index: net-2.6.20_netlabel-base-work/security/selinux/ss/services.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/security/selinux/ss/services.c
+++ net-2.6.20_netlabel-base-work/security/selinux/ss/services.c
@@ -29,6 +29,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/spinlock.h>
+#include <linux/rcupdate.h>
 #include <linux/errno.h>
 #include <linux/in.h>
 #include <linux/sched.h>
@@ -2390,7 +2391,9 @@ static int selinux_netlbl_skbuff_getsid(
  *
  * Description:
  * Attempt to label a socket using the NetLabel mechanism using the given
- * SID.  Returns zero values on success, negative values on failure.
+ * SID.  Returns zero values on success, negative values on failure.  The
+ * caller is responsibile for calling rcu_read_lock() before calling this
+ * this function and rcu_read_unlock() after this function returns.
  *
  */
 static int selinux_netlbl_socket_setsid(struct socket *sock, u32 sid)
@@ -2427,8 +2430,11 @@ static int selinux_netlbl_socket_setsid(
 		secattr.flags |= NETLBL_SECATTR_MLS_CAT;
 
 	rc = netlbl_socket_setattr(sock, &secattr);
-	if (rc == 0)
+	if (rc == 0) {
+		spin_lock(&sksec->nlbl_lock);
 		sksec->nlbl_state = NLBL_LABELED;
+		spin_unlock(&sksec->nlbl_lock);
+	}
 
 netlbl_socket_setsid_return:
 	POLICY_RDUNLOCK;
@@ -2437,6 +2443,25 @@ netlbl_socket_setsid_return:
 }
 
 /**
+ * selinux_netlbl_sk_security_reset - Reset the NetLabel fields
+ * @ssec: the sk_security_struct
+ * @family: the socket family
+ *
+ * Description:
+ * Called when the NetLabel state of a sk_security_struct needs to be reset.
+ * The caller is responsibile for all the NetLabel sk_security_struct locking.
+ *
+ */
+void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
+				      int family)
+{
+        if (family == PF_INET)
+		ssec->nlbl_state = NLBL_REQUIRE;
+	else
+		ssec->nlbl_state = NLBL_UNSET;
+}
+
+/**
  * selinux_netlbl_sk_security_init - Setup the NetLabel fields
  * @ssec: the sk_security_struct
  * @family: the socket family
@@ -2449,14 +2474,13 @@ netlbl_socket_setsid_return:
 void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
 				     int family)
 {
-        if (family == PF_INET)
-		ssec->nlbl_state = NLBL_REQUIRE;
-	else
-		ssec->nlbl_state = NLBL_UNSET;
+	/* No locking needed, we are the only one who has access to ssec */
+	selinux_netlbl_sk_security_reset(ssec, family);
+	spin_lock_init(&ssec->nlbl_lock);
 }
 
 /**
- * selinux_netlbl_sk_clone_security - Copy the NetLabel fields
+ * selinux_netlbl_sk_security_clone - Copy the NetLabel fields
  * @ssec: the original sk_security_struct
  * @newssec: the cloned sk_security_struct
  *
@@ -2465,41 +2489,41 @@ void selinux_netlbl_sk_security_init(str
  * @newssec.
  *
  */
-void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
+void selinux_netlbl_sk_security_clone(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec)
 {
+	/* We don't need to take newssec->nlbl_lock because we are the only
+	 * thread with access to newssec, but we do need to take the RCU read
+	 * lock as other threads could have access to ssec */
+	rcu_read_lock();
+	selinux_netlbl_sk_security_reset(newssec, ssec->sk->sk_family);
 	newssec->sclass = ssec->sclass;
-	if (ssec->nlbl_state != NLBL_UNSET)
-		newssec->nlbl_state = NLBL_REQUIRE;
-	else
-		newssec->nlbl_state = NLBL_UNSET;
+	rcu_read_unlock();
 }
 
 /**
  * selinux_netlbl_socket_post_create - Label a socket using NetLabel
  * @sock: the socket to label
- * @sock_family: the socket family
- * @sid: the SID to use
  *
  * Description:
  * Attempt to label a socket using the NetLabel mechanism using the given
  * SID.  Returns zero values on success, negative values on failure.
  *
  */
-int selinux_netlbl_socket_post_create(struct socket *sock,
-				      int sock_family,
-				      u32 sid)
+int selinux_netlbl_socket_post_create(struct socket *sock)
 {
+	int rc = 0;
 	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sock->sk->sk_security;
 
 	sksec->sclass = isec->sclass;
 
-	if (sock_family != PF_INET)
-		return 0;
+	rcu_read_lock();
+	if (sksec->nlbl_state == NLBL_REQUIRE)
+		rc = selinux_netlbl_socket_setsid(sock, sksec->sid);
+	rcu_read_unlock();
 
-	sksec->nlbl_state = NLBL_REQUIRE;
-	return selinux_netlbl_socket_setsid(sock, sid);
+	return rc;
 }
 
 /**
@@ -2521,8 +2545,12 @@ void selinux_netlbl_sock_graft(struct so
 
 	sksec->sclass = isec->sclass;
 
-	if (sk->sk_family != PF_INET)
+	rcu_read_lock();
+
+	if (sksec->nlbl_state != NLBL_REQUIRE) {
+		rcu_read_unlock();
 		return;
+	}
 
 	netlbl_secattr_init(&secattr);
 	if (netlbl_sock_getattr(sk, &secattr) == 0 &&
@@ -2534,12 +2562,12 @@ void selinux_netlbl_sock_graft(struct so
 		sksec->peer_sid = nlbl_peer_sid;
 	netlbl_secattr_destroy(&secattr);
 
-	sksec->nlbl_state = NLBL_REQUIRE;
-
 	/* Try to set the NetLabel on the socket to save time later, if we fail
 	 * here we will pick up the pieces in later calls to
 	 * selinux_netlbl_inode_permission(). */
 	selinux_netlbl_socket_setsid(sock, sksec->sid);
+
+	rcu_read_unlock();
 }
 
 /**
@@ -2580,25 +2608,24 @@ u32 selinux_netlbl_inet_conn_request(str
 int selinux_netlbl_inode_permission(struct inode *inode, int mask)
 {
 	int rc;
-	struct inode_security_struct *isec;
 	struct sk_security_struct *sksec;
 	struct socket *sock;
 
-	if (!S_ISSOCK(inode->i_mode))
+	if (!S_ISSOCK(inode->i_mode) ||
+	    ((mask & (MAY_WRITE | MAY_APPEND)) == 0))
 		return 0;
-
 	sock = SOCKET_I(inode);
-	isec = inode->i_security;
 	sksec = sock->sk->sk_security;
-	mutex_lock(&isec->lock);
-	if (unlikely(sksec->nlbl_state == NLBL_REQUIRE &&
-		     (mask & (MAY_WRITE | MAY_APPEND)))) {
-		lock_sock(sock->sk);
-		rc = selinux_netlbl_socket_setsid(sock, sksec->sid);
-		release_sock(sock->sk);
-	} else
-		rc = 0;
-	mutex_unlock(&isec->lock);
+
+	rcu_read_lock();
+	if (sksec->nlbl_state != NLBL_REQUIRE) {
+		rcu_read_unlock();
+		return 0;
+	}
+	lock_sock(sock->sk);
+	rc = selinux_netlbl_socket_setsid(sock, sksec->sid);
+	release_sock(sock->sk);
+	rcu_read_unlock();
 
 	return rc;
 }
@@ -2709,12 +2736,10 @@ int selinux_netlbl_socket_setsockopt(str
 				     int optname)
 {
 	int rc = 0;
-	struct inode *inode = SOCK_INODE(sock);
 	struct sk_security_struct *sksec = sock->sk->sk_security;
-	struct inode_security_struct *isec = inode->i_security;
 	struct netlbl_lsm_secattr secattr;
 
-	mutex_lock(&isec->lock);
+	rcu_read_lock();
 	if (level == IPPROTO_IP && optname == IP_OPTIONS &&
 	    sksec->nlbl_state == NLBL_LABELED) {
 		netlbl_secattr_init(&secattr);
@@ -2723,7 +2748,7 @@ int selinux_netlbl_socket_setsockopt(str
 			rc = -EACCES;
 		netlbl_secattr_destroy(&secattr);
 	}
-	mutex_unlock(&isec->lock);
+	rcu_read_unlock();
 
 	return rc;
 }

--
paul moore
linux security @ hp
