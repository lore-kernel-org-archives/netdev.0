From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 1/2] NetLabel: consolidate the struct socket/sock handling to just struct sock
Date: Thu, 07 Jun 2007 11:32:27 -0400
Message-ID: <20070607153607.205559860@hp.com>
References: <20070607153226.524778346@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:36457 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759645AbXFGPgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 11:36:50 -0400
Content-Disposition: inline; filename=netlabel-remove_redundant_funcs
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current NetLabel code has some redundant APIs which allow both
"struct socket" and "struct sock" types to be used; this may have made sense at
some point but it is wasteful now.  Remove the functions that operate on
sockets and convert the callers.  Not only does this make the code smaller and
more consistent but it pushes the locking burden up to the caller which can be
more intelligent about the locks.  Also, perform the same conversion (socket
to sock) on the SELinux/NetLabel glue code where it make sense.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/cipso_ipv4.h     |   20 ++++++--------------
 include/net/netlabel.h       |   14 +++-----------
 net/ipv4/cipso_ipv4.c        |   41 ++++++++---------------------------------
 net/netlabel/netlabel_kapi.c |   43 +++++++++----------------------------------
 security/selinux/netlabel.c  |   36 +++++++++++++++++++++---------------
 5 files changed, 47 insertions(+), 107 deletions(-)

Index: net-2.6_cleanup/include/net/cipso_ipv4.h
===================================================================
--- net-2.6_cleanup.orig/include/net/cipso_ipv4.h
+++ net-2.6_cleanup/include/net/cipso_ipv4.h
@@ -203,12 +203,10 @@ static inline int cipso_v4_cache_add(con
 
 #ifdef CONFIG_NETLABEL
 void cipso_v4_error(struct sk_buff *skb, int error, u32 gateway);
-int cipso_v4_socket_setattr(const struct socket *sock,
-			    const struct cipso_v4_doi *doi_def,
-			    const struct netlbl_lsm_secattr *secattr);
+int cipso_v4_sock_setattr(struct sock *sk,
+			  const struct cipso_v4_doi *doi_def,
+			  const struct netlbl_lsm_secattr *secattr);
 int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr);
-int cipso_v4_socket_getattr(const struct socket *sock,
-			    struct netlbl_lsm_secattr *secattr);
 int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 			    struct netlbl_lsm_secattr *secattr);
 int cipso_v4_validate(unsigned char **option);
@@ -220,9 +218,9 @@ static inline void cipso_v4_error(struct
 	return;
 }
 
-static inline int cipso_v4_socket_setattr(const struct socket *sock,
-				  const struct cipso_v4_doi *doi_def,
-				  const struct netlbl_lsm_secattr *secattr)
+static inline int cipso_v4_sock_setattr(struct sock *sk,
+				      const struct cipso_v4_doi *doi_def,
+				      const struct netlbl_lsm_secattr *secattr)
 {
 	return -ENOSYS;
 }
@@ -233,12 +231,6 @@ static inline int cipso_v4_sock_getattr(
 	return -ENOSYS;
 }
 
-static inline int cipso_v4_socket_getattr(const struct socket *sock,
-					  struct netlbl_lsm_secattr *secattr)
-{
-	return -ENOSYS;
-}
-
 static inline int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 					  struct netlbl_lsm_secattr *secattr)
 {
Index: net-2.6_cleanup/include/net/netlabel.h
===================================================================
--- net-2.6_cleanup.orig/include/net/netlabel.h
+++ net-2.6_cleanup/include/net/netlabel.h
@@ -332,17 +332,15 @@ static inline int netlbl_secattr_catmap_
  */
 
 #ifdef CONFIG_NETLABEL
-int netlbl_socket_setattr(const struct socket *sock,
-			  const struct netlbl_lsm_secattr *secattr);
+int netlbl_sock_setattr(struct sock *sk,
+			const struct netlbl_lsm_secattr *secattr);
 int netlbl_sock_getattr(struct sock *sk,
 			struct netlbl_lsm_secattr *secattr);
-int netlbl_socket_getattr(const struct socket *sock,
-			  struct netlbl_lsm_secattr *secattr);
 int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  struct netlbl_lsm_secattr *secattr);
 void netlbl_skbuff_err(struct sk_buff *skb, int error);
 #else
-static inline int netlbl_socket_setattr(const struct socket *sock,
+static inline int netlbl_sock_setattr(struct sock *sk,
 				     const struct netlbl_lsm_secattr *secattr)
 {
 	return -ENOSYS;
@@ -354,12 +352,6 @@ static inline int netlbl_sock_getattr(st
 	return -ENOSYS;
 }
 
-static inline int netlbl_socket_getattr(const struct socket *sock,
-					struct netlbl_lsm_secattr *secattr)
-{
-	return -ENOSYS;
-}
-
 static inline int netlbl_skbuff_getattr(const struct sk_buff *skb,
 					struct netlbl_lsm_secattr *secattr)
 {
Index: net-2.6_cleanup/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6_cleanup.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6_cleanup/net/ipv4/cipso_ipv4.c
@@ -1709,22 +1709,22 @@ void cipso_v4_error(struct sk_buff *skb,
 }
 
 /**
- * cipso_v4_socket_setattr - Add a CIPSO option to a socket
- * @sock: the socket
+ * cipso_v4_sock_setattr - Add a CIPSO option to a socket
+ * @sk: the socket
  * @doi_def: the CIPSO DOI to use
  * @secattr: the specific security attributes of the socket
  *
  * Description:
  * Set the CIPSO option on the given socket using the DOI definition and
  * security attributes passed to the function.  This function requires
- * exclusive access to @sock->sk, which means it either needs to be in the
- * process of being created or locked via lock_sock(sock->sk).  Returns zero on
- * success and negative values on failure.
+ * exclusive access to @sk, which means it either needs to be in the
+ * process of being created or locked.  Returns zero on success and negative
+ * values on failure.
  *
  */
-int cipso_v4_socket_setattr(const struct socket *sock,
-			    const struct cipso_v4_doi *doi_def,
-			    const struct netlbl_lsm_secattr *secattr)
+int cipso_v4_sock_setattr(struct sock *sk,
+			  const struct cipso_v4_doi *doi_def,
+			  const struct netlbl_lsm_secattr *secattr)
 {
 	int ret_val = -EPERM;
 	u32 iter;
@@ -1732,7 +1732,6 @@ int cipso_v4_socket_setattr(const struct
 	u32 buf_len = 0;
 	u32 opt_len;
 	struct ip_options *opt = NULL;
-	struct sock *sk;
 	struct inet_sock *sk_inet;
 	struct inet_connection_sock *sk_conn;
 
@@ -1740,7 +1739,6 @@ int cipso_v4_socket_setattr(const struct
 	 * defined yet but it is not a problem as the only users of these
 	 * "lite" PF_INET sockets are functions which do an accept() call
 	 * afterwards so we will label the socket as part of the accept(). */
-	sk = sock->sk;
 	if (sk == NULL)
 		return 0;
 
@@ -1892,29 +1890,6 @@ int cipso_v4_sock_getattr(struct sock *s
 }
 
 /**
- * cipso_v4_socket_getattr - Get the security attributes from a socket
- * @sock: the socket
- * @secattr: the security attributes
- *
- * Description:
- * Query @sock to see if there is a CIPSO option attached to the socket and if
- * there is return the CIPSO security attributes in @secattr.  Returns zero on
- * success and negative values on failure.
- *
- */
-int cipso_v4_socket_getattr(const struct socket *sock,
-			    struct netlbl_lsm_secattr *secattr)
-{
-	int ret_val;
-
-	lock_sock(sock->sk);
-	ret_val = cipso_v4_sock_getattr(sock->sk, secattr);
-	release_sock(sock->sk);
-
-	return ret_val;
-}
-
-/**
  * cipso_v4_skbuff_getattr - Get the security attributes from the CIPSO option
  * @skb: the packet
  * @secattr: the security attributes
Index: net-2.6_cleanup/net/netlabel/netlabel_kapi.c
===================================================================
--- net-2.6_cleanup.orig/net/netlabel/netlabel_kapi.c
+++ net-2.6_cleanup/net/netlabel/netlabel_kapi.c
@@ -246,19 +246,18 @@ int netlbl_secattr_catmap_setrng(struct 
 
 /**
  * netlbl_socket_setattr - Label a socket using the correct protocol
- * @sock: the socket to label
+ * @sk: the socket to label
  * @secattr: the security attributes
  *
  * Description:
  * Attach the correct label to the given socket using the security attributes
- * specified in @secattr.  This function requires exclusive access to
- * @sock->sk, which means it either needs to be in the process of being
- * created or locked via lock_sock(sock->sk).  Returns zero on success,
- * negative values on failure.
+ * specified in @secattr.  This function requires exclusive access to @sk,
+ * which means it either needs to be in the process of being created or locked.
+ * Returns zero on success, negative values on failure.
  *
  */
-int netlbl_socket_setattr(const struct socket *sock,
-			  const struct netlbl_lsm_secattr *secattr)
+int netlbl_sock_setattr(struct sock *sk,
+			const struct netlbl_lsm_secattr *secattr)
 {
 	int ret_val = -ENOENT;
 	struct netlbl_dom_map *dom_entry;
@@ -269,9 +268,9 @@ int netlbl_socket_setattr(const struct s
 		goto socket_setattr_return;
 	switch (dom_entry->type) {
 	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = cipso_v4_socket_setattr(sock,
-						  dom_entry->type_def.cipsov4,
-						  secattr);
+		ret_val = cipso_v4_sock_setattr(sk,
+						dom_entry->type_def.cipsov4,
+						secattr);
 		break;
 	case NETLBL_NLTYPE_UNLABELED:
 		ret_val = 0;
@@ -309,30 +308,6 @@ int netlbl_sock_getattr(struct sock *sk,
 }
 
 /**
- * netlbl_socket_getattr - Determine the security attributes of a socket
- * @sock: the socket
- * @secattr: the security attributes
- *
- * Description:
- * Examines the given socket to see any NetLabel style labeling has been
- * applied to the socket, if so it parses the socket label and returns the
- * security attributes in @secattr.  Returns zero on success, negative values
- * on failure.
- *
- */
-int netlbl_socket_getattr(const struct socket *sock,
-			  struct netlbl_lsm_secattr *secattr)
-{
-	int ret_val;
-
-	ret_val = cipso_v4_socket_getattr(sock, secattr);
-	if (ret_val == 0)
-		return 0;
-
-	return netlbl_unlabel_getattr(secattr);
-}
-
-/**
  * netlbl_skbuff_getattr - Determine the security attributes of a packet
  * @skb: the packet
  * @secattr: the security attributes
Index: net-2.6_cleanup/security/selinux/netlabel.c
===================================================================
--- net-2.6_cleanup.orig/security/selinux/netlabel.c
+++ net-2.6_cleanup/security/selinux/netlabel.c
@@ -36,8 +36,8 @@
 #include "security.h"
 
 /**
- * selinux_netlbl_socket_setsid - Label a socket using the NetLabel mechanism
- * @sock: the socket to label
+ * selinux_netlbl_sock_setsid - Label a socket using the NetLabel mechanism
+ * @sk: the socket to label
  * @sid: the SID to use
  *
  * Description:
@@ -47,17 +47,17 @@
  * this function and rcu_read_unlock() after this function returns.
  *
  */
-static int selinux_netlbl_socket_setsid(struct socket *sock, u32 sid)
+static int selinux_netlbl_sock_setsid(struct sock *sk, u32 sid)
 {
 	int rc;
-	struct sk_security_struct *sksec = sock->sk->sk_security;
+	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
 
 	rc = security_netlbl_sid_to_secattr(sid, &secattr);
 	if (rc != 0)
 		return rc;
 
-	rc = netlbl_socket_setattr(sock, &secattr);
+	rc = netlbl_sock_setattr(sk, &secattr);
 	if (rc == 0) {
 		spin_lock_bh(&sksec->nlbl_lock);
 		sksec->nlbl_state = NLBL_LABELED;
@@ -206,7 +206,7 @@ void selinux_netlbl_sock_graft(struct so
 	/* Try to set the NetLabel on the socket to save time later, if we fail
 	 * here we will pick up the pieces in later calls to
 	 * selinux_netlbl_inode_permission(). */
-	selinux_netlbl_socket_setsid(sock, sksec->sid);
+	selinux_netlbl_sock_setsid(sk, sksec->sid);
 
 	rcu_read_unlock();
 }
@@ -223,14 +223,15 @@ void selinux_netlbl_sock_graft(struct so
 int selinux_netlbl_socket_post_create(struct socket *sock)
 {
 	int rc = 0;
+	struct sock *sk = sock->sk;
 	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
-	struct sk_security_struct *sksec = sock->sk->sk_security;
+	struct sk_security_struct *sksec = sk->sk_security;
 
 	sksec->sclass = isec->sclass;
 
 	rcu_read_lock();
 	if (sksec->nlbl_state == NLBL_REQUIRE)
-		rc = selinux_netlbl_socket_setsid(sock, sksec->sid);
+		rc = selinux_netlbl_sock_setsid(sk, sksec->sid);
 	rcu_read_unlock();
 
 	return rc;
@@ -251,14 +252,16 @@ int selinux_netlbl_socket_post_create(st
 int selinux_netlbl_inode_permission(struct inode *inode, int mask)
 {
 	int rc;
-	struct sk_security_struct *sksec;
+	struct sock *sk;
 	struct socket *sock;
+	struct sk_security_struct *sksec;
 
 	if (!S_ISSOCK(inode->i_mode) ||
 	    ((mask & (MAY_WRITE | MAY_APPEND)) == 0))
 		return 0;
 	sock = SOCKET_I(inode);
-	sksec = sock->sk->sk_security;
+	sk = sock->sk;
+	sksec = sk->sk_security;
 
 	rcu_read_lock();
 	if (sksec->nlbl_state != NLBL_REQUIRE) {
@@ -266,9 +269,9 @@ int selinux_netlbl_inode_permission(stru
 		return 0;
 	}
 	local_bh_disable();
-	bh_lock_sock_nested(sock->sk);
-	rc = selinux_netlbl_socket_setsid(sock, sksec->sid);
-	bh_unlock_sock(sock->sk);
+	bh_lock_sock_nested(sk);
+	rc = selinux_netlbl_sock_setsid(sk, sksec->sid);
+	bh_unlock_sock(sk);
 	local_bh_enable();
 	rcu_read_unlock();
 
@@ -345,14 +348,17 @@ int selinux_netlbl_socket_setsockopt(str
 				     int optname)
 {
 	int rc = 0;
-	struct sk_security_struct *sksec = sock->sk->sk_security;
+	struct sock *sk = sock->sk;
+	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
 
 	rcu_read_lock();
 	if (level == IPPROTO_IP && optname == IP_OPTIONS &&
 	    sksec->nlbl_state == NLBL_LABELED) {
 		netlbl_secattr_init(&secattr);
-		rc = netlbl_socket_getattr(sock, &secattr);
+		lock_sock(sk);
+		rc = netlbl_sock_getattr(sk, &secattr);
+		release_sock(sk);
 		if (rc == 0 && secattr.flags != NETLBL_SECATTR_NONE)
 			rc = -EACCES;
 		netlbl_secattr_destroy(&secattr);

-- 
paul moore
linux security @ hp
