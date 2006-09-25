From: paul.moore@hp.com
Subject: [PATCH v2 1/8] NetLabel: correct improper handling of non-NetLabel peer contexts
Date: Mon, 25 Sep 2006 14:04:13 -0400
Message-ID: <20060925180639.336925000@hp.com>
References: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:42136 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751408AbWIYSGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:42 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-bug_peersec
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a problem where NetLabel would always set the value of 
sk_security_struct->peer_sid in selinux_netlbl_sock_graft() to the context of
the socket, causing problems when users would query the context of the
connection.  This patch fixes this so that the value in
sk_security_struct->peer_sid is only set when the connection is NetLabel based,
otherwise the value is untouched.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/cipso_ipv4.h       |    7 +++++
 include/net/netlabel.h         |    8 ++++++
 net/ipv4/cipso_ipv4.c          |   48 ++++++++++++++++++++++++++++-------------
 net/netlabel/netlabel_kapi.c   |   23 +++++++++++++++++++
 security/selinux/ss/services.c |   12 +++++++++-
 5 files changed, 82 insertions(+), 16 deletions(-)

Index: net-2.6.19/include/net/cipso_ipv4.h
===================================================================
--- net-2.6.19.orig/include/net/cipso_ipv4.h
+++ net-2.6.19/include/net/cipso_ipv4.h
@@ -205,6 +205,7 @@ void cipso_v4_error(struct sk_buff *skb,
 int cipso_v4_socket_setattr(const struct socket *sock,
 			    const struct cipso_v4_doi *doi_def,
 			    const struct netlbl_lsm_secattr *secattr);
+int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr);
 int cipso_v4_socket_getattr(const struct socket *sock,
 			    struct netlbl_lsm_secattr *secattr);
 int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
@@ -225,6 +226,12 @@ static inline int cipso_v4_socket_setatt
 	return -ENOSYS;
 }
 
+static inline int cipso_v4_sock_getattr(struct sock *sk,
+					struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
 static inline int cipso_v4_socket_getattr(const struct socket *sock,
 					  struct netlbl_lsm_secattr *secattr)
 {
Index: net-2.6.19/include/net/netlabel.h
===================================================================
--- net-2.6.19.orig/include/net/netlabel.h
+++ net-2.6.19/include/net/netlabel.h
@@ -238,6 +238,8 @@ static inline void netlbl_secattr_free(s
 #ifdef CONFIG_NETLABEL
 int netlbl_socket_setattr(const struct socket *sock,
 			  const struct netlbl_lsm_secattr *secattr);
+int netlbl_sock_getattr(struct sock *sk,
+			struct netlbl_lsm_secattr *secattr);
 int netlbl_socket_getattr(const struct socket *sock,
 			  struct netlbl_lsm_secattr *secattr);
 int netlbl_skbuff_getattr(const struct sk_buff *skb,
@@ -250,6 +252,12 @@ static inline int netlbl_socket_setattr(
 	return -ENOSYS;
 }
 
+static inline int netlbl_sock_getattr(struct sock *sk,
+				      struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
 static inline int netlbl_socket_getattr(const struct socket *sock,
 					struct netlbl_lsm_secattr *secattr)
 {
Index: net-2.6.19/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.19.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.19/net/ipv4/cipso_ipv4.c
@@ -1486,43 +1486,40 @@ socket_setattr_failure:
 }
 
 /**
- * cipso_v4_socket_getattr - Get the security attributes from a socket
- * @sock: the socket
+ * cipso_v4_sock_getattr - Get the security attributes from a sock
+ * @sk: the sock
  * @secattr: the security attributes
  *
  * Description:
- * Query @sock to see if there is a CIPSO option attached to the socket and if
- * there is return the CIPSO security attributes in @secattr.  Returns zero on
- * success and negative values on failure.
+ * Query @sk to see if there is a CIPSO option attached to the sock and if
+ * there is return the CIPSO security attributes in @secattr.  This function
+ * requires that @sk be locked, or privately held, but it does not do any
+ * locking itself.  Returns zero on success and negative values on failure.
  *
  */
-int cipso_v4_socket_getattr(const struct socket *sock,
-			    struct netlbl_lsm_secattr *secattr)
+int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
 {
 	int ret_val = -ENOMSG;
-	struct sock *sk;
 	struct inet_sock *sk_inet;
 	unsigned char *cipso_ptr;
 	u32 doi;
 	struct cipso_v4_doi *doi_def;
 
-	sk = sock->sk;
-	lock_sock(sk);
 	sk_inet = inet_sk(sk);
 	if (sk_inet->opt == NULL || sk_inet->opt->cipso == 0)
-		goto socket_getattr_return;
+		return -ENOMSG;
 	cipso_ptr = sk_inet->opt->__data + sk_inet->opt->cipso -
 		sizeof(struct iphdr);
 	ret_val = cipso_v4_cache_check(cipso_ptr, cipso_ptr[1], secattr);
 	if (ret_val == 0)
-		goto socket_getattr_return;
+		return ret_val;
 
 	doi = ntohl(*(u32 *)&cipso_ptr[2]);
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_getdef(doi);
 	if (doi_def == NULL) {
 		rcu_read_unlock();
-		goto socket_getattr_return;
+		return -ENOMSG;
 	}
 	switch (cipso_ptr[6]) {
 	case CIPSO_V4_TAG_RBITMAP:
@@ -1533,8 +1530,29 @@ int cipso_v4_socket_getattr(const struct
 	}
 	rcu_read_unlock();
 
-socket_getattr_return:
-	release_sock(sk);
+	return ret_val;
+}
+
+/**
+ * cipso_v4_socket_getattr - Get the security attributes from a socket
+ * @sock: the socket
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Query @sock to see if there is a CIPSO option attached to the socket and if
+ * there is return the CIPSO security attributes in @secattr.  Returns zero on
+ * success and negative values on failure.
+ *
+ */
+int cipso_v4_socket_getattr(const struct socket *sock,
+			    struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+
+	lock_sock(sock->sk);
+	ret_val = cipso_v4_sock_getattr(sock->sk, secattr);
+	release_sock(sock->sk);
+
 	return ret_val;
 }
 
Index: net-2.6.19/net/netlabel/netlabel_kapi.c
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_kapi.c
+++ net-2.6.19/net/netlabel/netlabel_kapi.c
@@ -85,6 +85,29 @@ socket_setattr_return:
 }
 
 /**
+ * netlbl_sock_getattr - Determine the security attributes of a sock
+ * @sk: the sock
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Examines the given sock to see any NetLabel style labeling has been
+ * applied to the sock, if so it parses the socket label and returns the
+ * security attributes in @secattr.  Returns zero on success, negative values
+ * on failure.
+ *
+ */
+int netlbl_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+
+	ret_val = cipso_v4_sock_getattr(sk, secattr);
+	if (ret_val == 0)
+		return 0;
+
+	return netlbl_unlabel_getattr(secattr);
+}
+
+/**
  * netlbl_socket_getattr - Determine the security attributes of a socket
  * @sock: the socket
  * @secattr: the security attributes
Index: net-2.6.19/security/selinux/ss/services.c
===================================================================
--- net-2.6.19.orig/security/selinux/ss/services.c
+++ net-2.6.19/security/selinux/ss/services.c
@@ -2502,14 +2502,24 @@ void selinux_netlbl_sock_graft(struct so
 {
 	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sk->sk_security;
+	struct netlbl_lsm_secattr secattr;
+	u32 nlbl_peer_sid;
 
 	sksec->sclass = isec->sclass;
 
 	if (sk->sk_family != PF_INET)
 		return;
 
+	netlbl_secattr_init(&secattr);
+	if (netlbl_sock_getattr(sk, &secattr) == 0 &&
+	    selinux_netlbl_secattr_to_sid(NULL,
+					  &secattr,
+					  sksec->sid,
+					  &nlbl_peer_sid) == 0)
+		sksec->peer_sid = nlbl_peer_sid;
+	netlbl_secattr_destroy(&secattr, 0);
+
 	sksec->nlbl_state = NLBL_REQUIRE;
-	sksec->peer_sid = sksec->sid;
 
 	/* Try to set the NetLabel on the socket to save time later, if we fail
 	 * here we will pick up the pieces in later calls to

--
paul moore
linux security @ hp
