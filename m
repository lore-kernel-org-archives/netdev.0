From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v6 12/16] selinux: Set socket NetLabel based on connection
	endpoint
Date: Tue, 16 Sep 2008 08:57:09 -0400
Message-ID: <20080916125709.17132.47022.stgit@flek.lan>
References: <20080916124722.17132.38741.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916124722.17132.38741.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previous work enabled the use of address based NetLabel selectors, which while
highly useful, brought the potential for additional per-packet overhead when
used.  This patch attempts to solve that by applying NetLabel socket labels
when sockets are connect()'d.  This should alleviate the per-packet NetLabel
labeling for all connected sockets (yes, it even works for connected DGRAM
sockets).

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/cipso_ipv4.h            |    5 +
 include/net/netlabel.h              |   13 +++
 net/ipv4/cipso_ipv4.c               |   74 ++++++++++++++++++
 net/netlabel/netlabel_kapi.c        |   78 ++++++++++++++++++-
 security/selinux/hooks.c            |   11 +--
 security/selinux/include/netlabel.h |   19 ++++-
 security/selinux/include/objsec.h   |    1 
 security/selinux/netlabel.c         |  147 ++++++++++++++++++++++++++++-------
 8 files changed, 311 insertions(+), 37 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index 2ce093b..811febf 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -207,6 +207,7 @@ void cipso_v4_error(struct sk_buff *skb, int error, u32 gateway);
 int cipso_v4_sock_setattr(struct sock *sk,
 			  const struct cipso_v4_doi *doi_def,
 			  const struct netlbl_lsm_secattr *secattr);
+void cipso_v4_sock_delattr(struct sock *sk);
 int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr);
 int cipso_v4_skbuff_setattr(struct sk_buff *skb,
 			    const struct cipso_v4_doi *doi_def,
@@ -230,6 +231,10 @@ static inline int cipso_v4_sock_setattr(struct sock *sk,
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
index 3f67e6d..074cad4 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -380,8 +380,12 @@ int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
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
@@ -449,11 +453,20 @@ static inline int netlbl_sock_setattr(struct sock *sk,
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
index e13d6db..23768b9 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1810,6 +1810,80 @@ socket_setattr_failure:
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
+	u8 hdr_delta;
+	struct ip_options *opt;
+	struct inet_sock *sk_inet;
+
+	sk_inet = inet_sk(sk);
+	opt = sk_inet->opt;
+	if (opt == NULL || opt->cipso == 0)
+		return;
+
+	if (opt->srr || opt->rr || opt->ts || opt->router_alert) {
+		u8 cipso_len;
+		u8 cipso_off;
+		unsigned char *cipso_ptr;
+		int iter;
+		int optlen_new;
+
+		cipso_off = opt->cipso - sizeof(struct iphdr);
+		cipso_ptr = &opt->__data[cipso_off];
+		cipso_len = cipso_ptr[1];
+
+		if (opt->srr > opt->cipso)
+			opt->srr -= cipso_len;
+		if (opt->rr > opt->cipso)
+			opt->rr -= cipso_len;
+		if (opt->ts > opt->cipso)
+			opt->ts -= cipso_len;
+		if (opt->router_alert > opt->cipso)
+			opt->router_alert -= cipso_len;
+		opt->cipso = 0;
+
+		memmove(cipso_ptr, cipso_ptr + cipso_len,
+			opt->optlen - cipso_off - cipso_len);
+
+		/* determining the new total option length is tricky because of
+		 * the padding necessary, the only thing i can think to do at
+		 * this point is walk the options one-by-one, skipping the
+		 * padding at the end to determine the actual option size and
+		 * from there we can determine the new total option length */
+		iter = 0;
+		optlen_new = 0;
+		while (iter < opt->optlen)
+			if (opt->__data[iter] != IPOPT_NOP) {
+				iter += opt->__data[iter + 1];
+				optlen_new = iter;
+			} else
+				iter++;
+		hdr_delta = opt->optlen;
+		opt->optlen = (optlen_new + 3) & ~3;
+		hdr_delta -= opt->optlen;
+	} else {
+		/* only the cipso option was present on the socket so we can
+		 * remove the entire option struct */
+		sk_inet->opt = NULL;
+		hdr_delta = opt->optlen;
+		kfree(opt);
+	}
+
+	if (sk_inet->is_icsk && hdr_delta > 0) {
+		struct inet_connection_sock *sk_conn = inet_csk(sk);
+		sk_conn->icsk_ext_hdr_len -= hdr_delta;
+		sk_conn->icsk_sync_mss(sk, sk_conn->icsk_pmtu_cookie);
+	}
+}
+
+/**
  * cipso_v4_getattr - Helper function for the cipso_v4_*_getattr functions
  * @cipso: the CIPSO v4 option
  * @secattr: the security attributes
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index cc8047d..78fc557 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -10,7 +10,7 @@
  */
 
 /*
- * (c) Copyright Hewlett-Packard Development Company, L.P., 2006
+ * (c) Copyright Hewlett-Packard Development Company, L.P., 2006, 2008
  *
  * This program is free software;  you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -456,6 +456,20 @@ socket_setattr_return:
 }
 
 /**
+ * netlbl_sock_delattr - Delete all the NetLabel labels on a socket
+ * @sk: the socket
+ *
+ * Description:
+ * Remove all the NetLabel labeling from @sk.  The caller is responsible for
+ * ensuring that @sk is locked.
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
@@ -473,6 +487,68 @@ int netlbl_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
 }
 
 /**
+ * netlbl_conn_setattr - Label a connected socket using the correct protocol
+ * @sk: the socket to label
+ * @addr: the destination address
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Attach the correct label to the given connected socket using the security
+ * attributes specified in @secattr.  The caller is responsible for ensuring
+ * that @sk is locked.  Returns zero on success, negative values on failure.
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
+		if (af4_entry == NULL) {
+			ret_val = -ENOENT;
+			goto conn_setattr_return;
+		}
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
+
+conn_setattr_return:
+	rcu_read_unlock();
+	return ret_val;
+}
+
+/**
  * netlbl_skbuff_setattr - Label a packet using the correct protocol
  * @skb: the packet
  * @family: protocol family
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 7432bdd..632ac3e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3794,6 +3794,7 @@ out:
 
 static int selinux_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen)
 {
+	struct sock *sk = sock->sk;
 	struct inode_security_struct *isec;
 	int err;
 
@@ -3807,7 +3808,6 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 	isec = SOCK_INODE(sock)->i_security;
 	if (isec->sclass == SECCLASS_TCP_SOCKET ||
 	    isec->sclass == SECCLASS_DCCP_SOCKET) {
-		struct sock *sk = sock->sk;
 		struct avc_audit_data ad;
 		struct sockaddr_in *addr4 = NULL;
 		struct sockaddr_in6 *addr6 = NULL;
@@ -3841,6 +3841,8 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 			goto out;
 	}
 
+	err = selinux_netlbl_socket_connect(sk, address);
+
 out:
 	return err;
 }
@@ -4290,8 +4292,6 @@ static void selinux_sock_graft(struct sock *sk, struct socket *parent)
 	    sk->sk_family == PF_UNIX)
 		isec->sid = sksec->sid;
 	sksec->sclass = isec->sclass;
-
-	selinux_netlbl_sock_graft(sk, parent);
 }
 
 static int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb,
@@ -4342,8 +4342,7 @@ static void selinux_inet_csk_clone(struct sock *newsk,
 	selinux_netlbl_sk_security_reset(newsksec, req->rsk_ops->family);
 }
 
-static void selinux_inet_conn_established(struct sock *sk,
-				struct sk_buff *skb)
+static void selinux_inet_conn_established(struct sock *sk, struct sk_buff *skb)
 {
 	u16 family = sk->sk_family;
 	struct sk_security_struct *sksec = sk->sk_security;
@@ -4353,6 +4352,8 @@ static void selinux_inet_conn_established(struct sock *sk,
 		family = PF_INET;
 
 	selinux_skb_peerlbl_sid(skb, family, &sksec->peer_sid);
+
+	selinux_netlbl_inet_conn_established(sk, family);
 }
 
 static void selinux_req_classify_flow(const struct request_sock *req,
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index b3e6ae0..982bac0 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -52,7 +52,7 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 				 u16 family,
 				 u32 sid);
 
-void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock);
+void selinux_netlbl_inet_conn_established(struct sock *sk, u16 family);
 int selinux_netlbl_socket_post_create(struct socket *sock);
 int selinux_netlbl_inode_permission(struct inode *inode, int mask);
 int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
@@ -62,6 +62,8 @@ int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 int selinux_netlbl_socket_setsockopt(struct socket *sock,
 				     int level,
 				     int optname);
+int selinux_netlbl_socket_connect(struct sock *sk, struct sockaddr *addr);
+
 #else
 static inline void selinux_netlbl_cache_invalidate(void)
 {
@@ -98,8 +100,14 @@ static inline int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 	return 0;
 }
 
-static inline void selinux_netlbl_sock_graft(struct sock *sk,
-					     struct socket *sock)
+static inline int selinux_netlbl_conn_setsid(struct sock *sk,
+					     struct sockaddr *addr)
+{
+	return 0;
+}
+
+static inline void selinux_netlbl_inet_conn_established(struct sock *sk,
+							u16 family)
 {
 	return;
 }
@@ -125,6 +133,11 @@ static inline int selinux_netlbl_socket_setsockopt(struct socket *sock,
 {
 	return 0;
 }
+static inline int selinux_netlbl_socket_connect(struct sock *sk,
+						struct sockaddr *addr)
+{
+	return 0;
+}
 #endif /* CONFIG_NETLABEL */
 
 #endif
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index f46dd1c..ad34787 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -118,6 +118,7 @@ struct sk_security_struct {
 		NLBL_REQUIRE,
 		NLBL_LABELED,
 		NLBL_REQSKB,
+		NLBL_CONNLABELED,
 	} nlbl_state;
 #endif
 };
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 090404d..b22b7da 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -29,10 +29,12 @@
 
 #include <linux/spinlock.h>
 #include <linux/rcupdate.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <net/sock.h>
 #include <net/netlabel.h>
-#include <net/inet_sock.h>
-#include <net/inet_connection_sock.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
 
 #include "objsec.h"
 #include "security.h"
@@ -79,8 +81,6 @@ static int selinux_netlbl_sock_setsid(struct sock *sk)
 	int rc;
 	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
-	struct inet_sock *sk_inet;
-	struct inet_connection_sock *sk_conn;
 
 	if (sksec->nlbl_state != NLBL_REQUIRE)
 		return 0;
@@ -96,20 +96,6 @@ static int selinux_netlbl_sock_setsid(struct sock *sk)
 		sksec->nlbl_state = NLBL_LABELED;
 		break;
 	case -EDESTADDRREQ:
-		/* we are going to possibly end up labeling the individual
-		 * packets later which is problematic for stream sockets
-		 * because of the additional IP header size, our solution is to
-		 * allow for the maximum IP header length (40 bytes for IPv4,
-		 * we don't have to worry about IPv6 yet) just in case */
-		sk_inet = inet_sk(sk);
-		if (sk_inet->is_icsk) {
-			sk_conn = inet_csk(sk);
-			if (sk_inet->opt)
-				sk_conn->icsk_ext_hdr_len -=
-							   sk_inet->opt->optlen;
-			sk_conn->icsk_ext_hdr_len += 40;
-			sk_conn->icsk_sync_mss(sk, sk_conn->icsk_pmtu_cookie);
-		}
 		sksec->nlbl_state = NLBL_REQSKB;
 		rc = 0;
 		break;
@@ -247,21 +233,77 @@ skbuff_setsid_return:
 }
 
 /**
- * selinux_netlbl_sock_graft - Netlabel the new socket
+ * selinux_netlbl_inet_conn_established - Netlabel the newly accepted connection
  * @sk: the new connection
- * @sock: the new socket
  *
  * Description:
- * The connection represented by @sk is being grafted onto @sock so set the
- * socket's NetLabel to match the SID of @sk.
+ * A new connection has been established on @sk so make sure it is labeled
+ * correctly with the NetLabel susbsystem.
  *
  */
-void selinux_netlbl_sock_graft(struct sock *sk, struct socket *sock)
+void selinux_netlbl_inet_conn_established(struct sock *sk, u16 family)
 {
-	/* Try to set the NetLabel on the socket to save time later, if we fail
-	 * here we will pick up the pieces in later calls to
-	 * selinux_netlbl_inode_permission(). */
-	selinux_netlbl_sock_setsid(sk);
+	int rc;
+	struct sk_security_struct *sksec = sk->sk_security;
+	struct netlbl_lsm_secattr secattr;
+	struct inet_sock *sk_inet = inet_sk(sk);
+	struct sockaddr_in addr;
+
+	if (sksec->nlbl_state != NLBL_REQUIRE)
+		return;
+
+	netlbl_secattr_init(&secattr);
+	if (security_netlbl_sid_to_secattr(sksec->sid, &secattr) != 0)
+		goto inet_conn_established_return;
+
+	rc = netlbl_sock_setattr(sk, &secattr);
+	switch (rc) {
+	case 0:
+		sksec->nlbl_state = NLBL_LABELED;
+		break;
+	case -EDESTADDRREQ:
+		/* no PF_INET6 support yet because we don't support any IPv6
+		 * labeling protocols */
+		if (family != PF_INET) {
+			sksec->nlbl_state = NLBL_UNSET;
+			goto inet_conn_established_return;
+		}
+
+		addr.sin_family = family;
+		addr.sin_addr.s_addr = sk_inet->daddr;
+		if (netlbl_conn_setattr(sk, (struct sockaddr *)&addr,
+					&secattr) != 0) {
+			/* we failed to label the connected socket (could be
+			 * for a variety of reasons, the actual "why" isn't
+			 * important here) so we have to go to our backup plan,
+			 * labeling the packets individually in the netfilter
+			 * local output hook.  this is okay but we need to
+			 * adjust the MSS of the connection to take into
+			 * account any labeling overhead, since we don't know
+			 * the exact overhead at this point we'll use the worst
+			 * case value which is 40 bytes for IPv4 */
+			struct inet_connection_sock *sk_conn = inet_csk(sk);
+			sk_conn->icsk_ext_hdr_len += 40 -
+				      (sk_inet->opt ? sk_inet->opt->optlen : 0);
+			sk_conn->icsk_sync_mss(sk, sk_conn->icsk_pmtu_cookie);
+
+			sksec->nlbl_state = NLBL_REQSKB;
+		} else
+			sksec->nlbl_state = NLBL_CONNLABELED;
+		break;
+	default:
+		/* note that we are failing to label the socket which could be
+		 * a bad thing since it means traffic could leave the system
+		 * without the desired labeling, however, all is not lost as
+		 * we have a check in selinux_netlbl_inode_permission() to
+		 * pick up the pieces that we might drop here because we can't
+		 * return an error code */
+		break;
+	}
+
+inet_conn_established_return:
+	netlbl_secattr_destroy(&secattr);
+	return;
 }
 
 /**
@@ -398,7 +440,8 @@ int selinux_netlbl_socket_setsockopt(struct socket *sock,
 	struct netlbl_lsm_secattr secattr;
 
 	if (level == IPPROTO_IP && optname == IP_OPTIONS &&
-	    sksec->nlbl_state == NLBL_LABELED) {
+	    (sksec->nlbl_state == NLBL_LABELED ||
+	     sksec->nlbl_state == NLBL_CONNLABELED)) {
 		netlbl_secattr_init(&secattr);
 		lock_sock(sk);
 		rc = netlbl_sock_getattr(sk, &secattr);
@@ -410,3 +453,51 @@ int selinux_netlbl_socket_setsockopt(struct socket *sock,
 
 	return rc;
 }
+
+/**
+ * selinux_netlbl_socket_connect - Label a client-side socket on connect
+ * @sk: the socket to label
+ * @addr: the destination address
+ *
+ * Description:
+ * Attempt to label a connected socket with NetLabel using the given address.
+ * Returns zero values on success, negative values on failure.
+ *
+ */
+int selinux_netlbl_socket_connect(struct sock *sk, struct sockaddr *addr)
+{
+	int rc;
+	struct sk_security_struct *sksec = sk->sk_security;
+	struct netlbl_lsm_secattr secattr;
+
+	if (sksec->nlbl_state != NLBL_REQSKB &&
+	    sksec->nlbl_state != NLBL_CONNLABELED)
+		return 0;
+
+	netlbl_secattr_init(&secattr);
+	local_bh_disable();
+	bh_lock_sock_nested(sk);
+
+	/* connected sockets are allowed to disconnect when the address family
+	 * is set to AF_UNSPEC, if that is what is happening we want to reset
+	 * the socket */
+	if (addr->sa_family == AF_UNSPEC) {
+		netlbl_sock_delattr(sk);
+		sksec->nlbl_state = NLBL_REQSKB;
+		rc = 0;
+		goto socket_connect_return;
+	}
+	rc = security_netlbl_sid_to_secattr(sksec->sid, &secattr);
+	if (rc != 0)
+		goto socket_connect_return;
+	rc = netlbl_conn_setattr(sk, addr, &secattr);
+	if (rc != 0)
+		goto socket_connect_return;
+	sksec->nlbl_state = NLBL_CONNLABELED;
+
+socket_connect_return:
+	bh_unlock_sock(sk);
+	local_bh_enable();
+	netlbl_secattr_destroy(&secattr);
+	return rc;
+}

