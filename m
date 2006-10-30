From: paul.moore@hp.com
Subject: [patch 1/1] NetLabel: protect the CIPSOv4 socket option from setsockopt()
Date: Mon, 30 Oct 2006 13:03:32 -0500
Message-ID: <20061030180801.641867000@hp.com>
References: <20061030180331.404950000@hp.com>
Cc: jmorris@redhat.com, sds@epoch.ncsc.mil, eparis@redhat.com,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39909 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S932466AbWJ3SIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 13:08:04 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-sockopts
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

This patch makes two changes to protect applications from either removing or
tampering with the CIPSOv4 IP option on a socket.  The first is the requirement
that applications have the CAP_NET_RAW capability to set an IPOPT_CIPSO option
on a socket; this prevents untrusted applications from setting their own
CIPSOv4 security attributes on the packets they send.  The second change is to
SELinux and it prevents applications from setting any IPv4 options when there
is an IPOPT_CIPSO option already present on the socket; this prevents
applications from removing CIPSOv4 security attributes from the packets they
send.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c                       |    7 ++---
 net/ipv4/ip_options.c                       |    2 -
 security/selinux/hooks.c                    |    8 +++++-
 security/selinux/include/selinux_netlabel.h |   10 +++++++
 security/selinux/ss/services.c              |   37 ++++++++++++++++++++++++++++
 5 files changed, 58 insertions(+), 6 deletions(-)

Index: net-2.6_sockopt/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6_sockopt.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6_sockopt/net/ipv4/cipso_ipv4.c
@@ -1307,7 +1307,8 @@ int cipso_v4_socket_setattr(const struct
 
 	/* We can't use ip_options_get() directly because it makes a call to
 	 * ip_options_get_alloc() which allocates memory with GFP_KERNEL and
-	 * we can't block here. */
+	 * we won't always have CAP_NET_RAW even though we _always_ want to
+	 * set the IPOPT_CIPSO option. */
 	opt_len = (buf_len + 3) & ~3;
 	opt = kzalloc(sizeof(*opt) + opt_len, GFP_ATOMIC);
 	if (opt == NULL) {
@@ -1317,11 +1318,9 @@ int cipso_v4_socket_setattr(const struct
 	memcpy(opt->__data, buf, buf_len);
 	opt->optlen = opt_len;
 	opt->is_data = 1;
+	opt->cipso = sizeof(struct iphdr);
 	kfree(buf);
 	buf = NULL;
-	ret_val = ip_options_compile(opt, NULL);
-	if (ret_val != 0)
-		goto socket_setattr_failure;
 
 	sk_inet = inet_sk(sk);
 	if (sk_inet->is_icsk) {
Index: net-2.6_sockopt/net/ipv4/ip_options.c
===================================================================
--- net-2.6_sockopt.orig/net/ipv4/ip_options.c
+++ net-2.6_sockopt/net/ipv4/ip_options.c
@@ -443,7 +443,7 @@ int ip_options_compile(struct ip_options
 				opt->router_alert = optptr - iph;
 			break;
 		      case IPOPT_CIPSO:
-		        if (opt->cipso) {
+			if ((!skb && !capable(CAP_NET_RAW)) || opt->cipso) {
 				pp_ptr = optptr;
 				goto error;
 			}
Index: net-2.6_sockopt/security/selinux/hooks.c
===================================================================
--- net-2.6_sockopt.orig/security/selinux/hooks.c
+++ net-2.6_sockopt/security/selinux/hooks.c
@@ -3313,7 +3313,13 @@ static int selinux_socket_getpeername(st
 
 static int selinux_socket_setsockopt(struct socket *sock,int level,int optname)
 {
-	return socket_has_perm(current, sock, SOCKET__SETOPT);
+	int err;
+
+	err = socket_has_perm(current, sock, SOCKET__SETOPT);
+	if (err)
+		return err;
+
+	return selinux_netlbl_socket_setsockopt(sock, level, optname);
 }
 
 static int selinux_socket_getsockopt(struct socket *sock, int level,
Index: net-2.6_sockopt/security/selinux/include/selinux_netlabel.h
===================================================================
--- net-2.6_sockopt.orig/security/selinux/include/selinux_netlabel.h
+++ net-2.6_sockopt/security/selinux/include/selinux_netlabel.h
@@ -53,6 +53,9 @@ void selinux_netlbl_sk_security_init(str
 void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
 				      struct sk_security_struct *newssec);
 int selinux_netlbl_inode_permission(struct inode *inode, int mask);
+int selinux_netlbl_socket_setsockopt(struct socket *sock,
+				     int level,
+				     int optname);
 #else
 static inline void selinux_netlbl_cache_invalidate(void)
 {
@@ -114,6 +117,13 @@ static inline int selinux_netlbl_inode_p
 {
 	return 0;
 }
+
+static inline int selinux_netlbl_socket_setsockopt(struct socket *sock,
+						   int level,
+						   int optname)
+{
+	return 0;
+}
 #endif /* CONFIG_NETLABEL */
 
 #endif
Index: net-2.6_sockopt/security/selinux/ss/services.c
===================================================================
--- net-2.6_sockopt.orig/security/selinux/ss/services.c
+++ net-2.6_sockopt/security/selinux/ss/services.c
@@ -2682,4 +2682,41 @@ u32 selinux_netlbl_socket_getpeersec_dgr
 
 	return peer_sid;
 }
+
+/**
+ * selinux_netlbl_socket_setsockopt - Do not allow users to remove a NetLabel
+ * @sock: the socket
+ * @level: the socket level or protocol
+ * @optname: the socket option name
+ *
+ * Description:
+ * Check the setsockopt() call and if the user is trying to replace the IP
+ * options on a socket and a NetLabel is in place for the socket deny the
+ * access; otherwise allow the access.  Returns zero when the access is
+ * allowed, -EACCES when denied, and other negative values on error.
+ *
+ */
+int selinux_netlbl_socket_setsockopt(struct socket *sock,
+				     int level,
+				     int optname)
+{
+	int rc = 0;
+	struct inode *inode = SOCK_INODE(sock);
+	struct sk_security_struct *sksec = sock->sk->sk_security;
+	struct inode_security_struct *isec = inode->i_security;
+	struct netlbl_lsm_secattr secattr;
+
+	mutex_lock(&isec->lock);
+	if (level == IPPROTO_IP && optname == IP_OPTIONS &&
+	    sksec->nlbl_state == NLBL_LABELED) {
+		netlbl_secattr_init(&secattr);
+		rc = netlbl_socket_getattr(sock, &secattr);
+		if (rc == 0 && (secattr.cache || secattr.mls_lvl_vld))
+			rc = -EACCES;
+		netlbl_secattr_destroy(&secattr);
+	}
+	mutex_unlock(&isec->lock);
+
+	return rc;
+}
 #endif /* CONFIG_NETLABEL */

--
paul moore
linux security @ hp
