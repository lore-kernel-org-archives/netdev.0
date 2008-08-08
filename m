From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1 6/6] selinux: Set socket NetLabel based on connection
	endpoint
Date: Fri, 08 Aug 2008 16:53:41 -0400
Message-ID: <20080808205341.21077.95267.stgit@flek>
References: <20080808203542.21077.37084.stgit@flek>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:20749 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758120AbYHHUxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 16:53:47 -0400
In-Reply-To: <20080808203542.21077.37084.stgit@flek>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous work enabled the use of address based NetLabel selectors, which while
highly useful, brought the potential for additional per-packet overhead when
used.  This patch attempts to solve that by applying NetLabel socket labels
when sockets are connect()'d.  This should alleviate the per-packet NetLabel
labeling for all connected sockets (yes, it even works for connected DGRAM
sockets).

Signed-off-by: XXX
---

 include/net/cipso_ipv4.h            |    5 ++
 include/net/netlabel.h              |   13 ++++++
 net/ipv4/cipso_ipv4.c               |   47 +++++++++++++++++++++++
 net/netlabel/netlabel_kapi.c        |   72 +++++++++++++++++++++++++++++++++++
 security/selinux/hooks.c            |    4 +-
 security/selinux/include/netlabel.h |    8 ++++
 security/selinux/netlabel.c         |   44 +++++++++++++++++++++
 7 files changed, 192 insertions(+), 1 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index b45ff1c..ba02172 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -206,6 +206,7 @@ void cipso_v4_error(struct sk_buff *skb, int error, u32 gateway);
 int cipso_v4_sock_setattr(struct sock *sk,
 			  const struct cipso_v4_doi *doi_def,
 			  const struct netlbl_lsm_secattr *secattr);
+void cipso_v4_sock_delattr(struct sock *sk);
 int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr);
 int cipso_v4_skbuff_setattr(struct sk_buff *skb,
 			    const struct cipso_v4_doi *doi_def,
@@ -229,6 +230,10 @@ static inline int cipso_v4_sock_setattr(struct sock *sk,
 	return -ENOSYS;
 }
 
+static inline void cipso_v4_sock_delattr(struct sock *sk)
+{
+}
+
 static inline int cipso_v4_sock_getattr(struct sock *sk,
 					struct netlbl_lsm_secattr *secattr)
 {
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 1d777f7..d4d3146 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -383,8 +383,12 @@ int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
 int netlbl_enabled(void);
 int netlbl_sock_setattr(struct sock *sk,
 			const struct netlbl_lsm_secattr *secattr);
+void netlbl_sock_delattr(struct sock *sk);
 int netlbl_sock_getattr(struct sock *sk,
 			struct netlbl_lsm_secattr *secattr);
+int netlbl_conn_setattr(struct sock *sk,
+			struct sockaddr *addr,
+			const struct netlbl_lsm_secattr *secattr);
 int netlbl_skbuff_setattr(struct sk_buff *skb,
 			  u16 family,
 			  const struct netlbl_lsm_secattr *secattr);
@@ -462,11 +466,20 @@ static inline int netlbl_sock_setattr(struct sock *sk,
 {
 	return -ENOSYS;
 }
+static inline void netlbl_sock_delattr(struct sock *sk)
+{
+}
 static inline int netlbl_sock_getattr(struct sock *sk,
 				      struct netlbl_lsm_secattr *secattr)
 {
 	return -ENOSYS;
 }
+static inline int netlbl_conn_setattr(struct sock *sk,
+				      struct sockaddr *addr,
+				      const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
 static inline int netlbl_skbuff_setattr(struct sk_buff *skb,
 				      u16 family,
 				      const struct netlbl_lsm_secattr *secattr)
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 81a6777..5f0e507 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1762,6 +1762,53 @@ socket_setattr_failure:
 }
 
 /**
+ * cipso_v4_sock_delattr - Delete the CIPSO option from a socket
+ * @sk: the socket
+ *
+ * Description:
+ * Removes the CIPSO option from a socket, if present.
+ *
+ */
+void cipso_v4_sock_delattr(struct sock *sk)
+{
+	u8 cipso_len;
+	u8 cipso_off;
+	unsigned char *cipso_ptr;
+	struct ip_options *opt;
+	struct inet_sock *sk_inet;
+	struct inet_connection_sock *sk_conn;
+
+	sk_inet = inet_sk(sk);
+	opt = sk_inet->opt;
+	if (opt == NULL || opt->cipso == 0)
+		return;
+
+	cipso_off = opt->cipso - sizeof(struct iphdr);
+	cipso_ptr = &opt->__data[cipso_off];
+	cipso_len = cipso_ptr[1];
+	if (cipso_len < opt->optlen && opt->optlen - cipso_off > cipso_len) {
+		memmove(cipso_ptr, cipso_ptr + cipso_len,
+			opt->optlen - cipso_off - cipso_len); 
+		if (opt->srr > opt->cipso)
+			opt->srr -= cipso_len;
+		if (opt->rr)
+			opt->rr -= cipso_len;
+		if (opt->ts)
+			opt->ts -= cipso_len;
+		if (opt->router_alert)
+			opt->router_alert -= cipso_len;
+	} else
+		memset(cipso_ptr, IPOPT_NOOP, cipso_len);
+	if (sk_inet->is_icsk) {
+		sk_conn = inet_csk(sk);
+		sk_conn->icsk_ext_hdr_len -= cipso_len;
+		sk_conn->icsk_sync_mss(sk, sk_conn->icsk_pmtu_cookie);
+	}
+	opt->cipso = 0;
+	opt->optlen -= cipso_len;
+}
+
+/**
  * cipso_v4_getattr - Helper function for the cipso_v4_*_getattr functions
  * @cipso: the CIPSO v4 option
  * @secattr: the security attributes
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 976c5b9..17ff814 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -483,6 +483,19 @@ socket_setattr_return:
 }
 
 /**
+ * netlbl_sock_delattr - Delete all the NetLabel labels on a socket
+ * @sk: the socket
+ *
+ * Description:
+ * Remove all the NetLabel labeling from @sk.
+ *
+ */
+void netlbl_sock_delattr(struct sock *sk)
+{
+	cipso_v4_sock_delattr(sk);
+}
+
+/**
  * netlbl_sock_getattr - Determine the security attributes of a sock
  * @sk: the sock
  * @secattr: the security attributes
@@ -500,6 +513,65 @@ int netlbl_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
 }
 
 /**
+ * netlbl_conn_setattr - Label a connected socket using the correct protocol
+ * @sk: the socket to label
+ * @addr: the destination address
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Attach the correct label to the given connected socket using the security
+ * attributes specified in @secattr.  Returns zero on success, negative values
+ * on failure.
+ *
+ */
+int netlbl_conn_setattr(struct sock *sk,
+			struct sockaddr *addr,
+			const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	struct sockaddr_in *addr4;
+	struct netlbl_domaddr4_map *af4_entry;
+
+	rcu_read_lock();
+	switch (addr->sa_family) {
+	case AF_INET:
+		addr4 = (struct sockaddr_in *)addr;
+		af4_entry = netlbl_domhsh_getentry_af4(secattr->domain,
+						       addr4->sin_addr.s_addr);
+		if (af4_entry == NULL)
+			ret_val = -ENOENT;
+		switch (af4_entry->type) {
+		case NETLBL_NLTYPE_CIPSOV4:
+			ret_val = cipso_v4_sock_setattr(sk,
+						   af4_entry->type_def.cipsov4,
+						   secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			/* just delete the protocols we support for right now
+			 * but we could remove other protocols if needed */
+			cipso_v4_sock_delattr(sk);
+			ret_val = 0;
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		/* since we don't support any IPv6 labeling protocols right
+		 * now we can optimize everything away until we do */
+		ret_val = 0;
+		break;
+#endif /* IPv6 */
+	default:
+		ret_val = 0;
+	}
+	rcu_read_unlock();
+
+	return ret_val;
+}
+
+/**
  * netlbl_skbuff_setattr - Label a packet using the correct protocol
  * @skb: the packet
  * @family: protocol family
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index bbd68bd..a6fd2e6 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3784,6 +3784,7 @@ out:
 
 static int selinux_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen)
 {
+	struct sock *sk = sock->sk;
 	struct inode_security_struct *isec;
 	int err;
 
@@ -3797,7 +3798,6 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 	isec = SOCK_INODE(sock)->i_security;
 	if (isec->sclass == SECCLASS_TCP_SOCKET ||
 	    isec->sclass == SECCLASS_DCCP_SOCKET) {
-		struct sock *sk = sock->sk;
 		struct avc_audit_data ad;
 		struct sockaddr_in *addr4 = NULL;
 		struct sockaddr_in6 *addr6 = NULL;
@@ -3831,6 +3831,8 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 			goto out;
 	}
 
+	err = selinux_netlbl_conn_setsid(sk, address);
+
 out:
 	return err;
 }
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index 7711885..f6ef540 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -49,6 +49,8 @@ int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
 int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 				 u16 family,
 				 u32 sid);
+int selinux_netlbl_conn_setsid(struct sock *sk,
+			       struct sockaddr *addr);
 
 void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock);
 int selinux_netlbl_socket_post_create(struct socket *sock);
@@ -90,6 +92,12 @@ static inline int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 	return 0;
 }
 
+static inline int selinux_netlbl_conn_setsid(struct sock *sk,
+					     struct sockaddr *addr)
+{
+	return 0;
+}
+
 static inline void selinux_netlbl_sock_graft(struct sock *sk,
 					     struct socket *sock)
 {
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 49e33e5..5076e81 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -101,6 +101,50 @@ sock_setsid_return:
 }
 
 /**
+ * selinux_netlbl_conn_setsid - Label a connected socket using NetLabel
+ * @sk: the socket to label
+ * @addr: the destination address
+ *
+ * Description:
+ * Attempt to label a connected socket using the NetLabel mechanism using the
+ * given address.  Returns zero values on success, negative values on failure.
+ *
+ */
+int selinux_netlbl_conn_setsid(struct sock *sk,
+			       struct sockaddr *addr)
+{
+	int rc;
+	struct sk_security_struct *sksec = sk->sk_security;
+	struct netlbl_lsm_secattr secattr;
+
+	if (sksec->nlbl_state != NLBL_REQSKB)
+		return 0;
+
+	/* connected sockets are allowed to disconnect when the address family
+	 * is set to AF_UNSPEC, if that is what is happening we want to reset
+	 * the socket */
+	if (addr->sa_family == AF_UNSPEC) {
+		netlbl_sock_delattr(sk);
+		sksec->nlbl_state = NLBL_REQSKB;
+		return 0;
+	}
+
+	netlbl_secattr_init(&secattr);
+
+	rc = security_netlbl_sid_to_secattr(sksec->sid, &secattr);
+	if (rc != 0)
+		goto conn_setsid_return;
+	rc = netlbl_conn_setattr(sk, addr, &secattr);
+	if (rc != 0)
+		goto conn_setsid_return;
+	sksec->nlbl_state = NLBL_LABELED;
+	
+conn_setsid_return:
+	netlbl_secattr_destroy(&secattr);
+	return rc;
+}
+
+/**
  * selinux_netlbl_cache_invalidate - Invalidate the NetLabel cache
  *
  * Description:

