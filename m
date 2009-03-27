From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 2/6] netlabel: Label incoming TCP connections correctly in
	SELinux
Date: Fri, 27 Mar 2009 17:10:34 -0400
Message-ID: <20090327211034.17777.81592.stgit@flek.lan>
References: <20090327205520.17777.32557.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, casey@schaufler-ca.com,
	etienne.basset@numericable.fr
To: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090327205520.17777.32557.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current NetLabel/SELinux behavior for incoming TCP connections works but
only through a series of happy coincidences that rely on the limited nature of
standard CIPSO (only able to convey MLS attributes) and the write equality
imposed by the SELinux MLS constraints.  The problem is that network sockets
created as the result of an incoming TCP connection were not on-the-wire
labeled based on the security attributes of the parent socket but rather based
on the wire label of the remote peer.  The issue had to do with how IP options
were managed as part of the network stack and where the LSM hooks were in
relation to the code which set the IP options on these newly created child
sockets.  While NetLabel/SELinux did correctly set the socket's on-the-wire
label it was promptly cleared by the network stack and reset based on the IP
options of the remote peer.

This patch, in conjunction with a prior patch that adjusted the LSM hook
locations, works to set the correct on-the-wire label format for new incoming
connections through the security_inet_conn_request() hook.  Besides the
correct behavior there are many advantages to this change, the most significant
is that all of the NetLabel socket labeling code in SELinux now lives in hooks
which can return error codes to the core stack which allows us to finally get
ride of the selinux_netlbl_inode_permission() logic which greatly simplfies
the NetLabel/SELinux glue code.  In the process of developing this patch I
also ran into a small handful of AF_INET6 cleanliness issues that have been
fixed which should make the code safer and easier to extend in the future.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/cipso_ipv4.h            |   17 +++
 include/net/netlabel.h              |   12 ++
 net/ipv4/cipso_ipv4.c               |  130 ++++++++++++++++++++++--
 net/netlabel/netlabel_kapi.c        |  152 +++++++++++++++++++++++++----
 security/selinux/hooks.c            |   54 +++-------
 security/selinux/include/netlabel.h |   27 ++---
 security/selinux/netlabel.c         |  186 ++++++++++-------------------------
 security/smack/smack_lsm.c          |    2 
 8 files changed, 360 insertions(+), 220 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index bedc7f6..abd4436 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -40,6 +40,7 @@
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <net/netlabel.h>
+#include <net/request_sock.h>
 #include <asm/atomic.h>
 
 /* known doi values */
@@ -215,6 +216,10 @@ int cipso_v4_sock_setattr(struct sock *sk,
 			  const struct netlbl_lsm_secattr *secattr);
 void cipso_v4_sock_delattr(struct sock *sk);
 int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr);
+int cipso_v4_req_setattr(struct request_sock *req,
+			 const struct cipso_v4_doi *doi_def,
+			 const struct netlbl_lsm_secattr *secattr);
+void cipso_v4_req_delattr(struct request_sock *req);
 int cipso_v4_skbuff_setattr(struct sk_buff *skb,
 			    const struct cipso_v4_doi *doi_def,
 			    const struct netlbl_lsm_secattr *secattr);
@@ -247,6 +252,18 @@ static inline int cipso_v4_sock_getattr(struct sock *sk,
 	return -ENOSYS;
 }
 
+static inline int cipso_v4_req_setattr(struct request_sock *req,
+				       const struct cipso_v4_doi *doi_def,
+				       const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
+static inline void cipso_v4_req_delattr(struct request_sock *req)
+{
+	return;
+}
+
 static inline int cipso_v4_skbuff_setattr(struct sk_buff *skb,
 				      const struct cipso_v4_doi *doi_def,
 				      const struct netlbl_lsm_secattr *secattr)
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 749011e..bdb10e5 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -36,6 +36,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <net/netlink.h>
+#include <net/request_sock.h>
 #include <asm/atomic.h>
 
 struct cipso_v4_doi;
@@ -406,6 +407,7 @@ int netlbl_secattr_catmap_setrng(struct netlbl_lsm_secattr_catmap *catmap,
  */
 int netlbl_enabled(void);
 int netlbl_sock_setattr(struct sock *sk,
+			u16 family,
 			const struct netlbl_lsm_secattr *secattr);
 void netlbl_sock_delattr(struct sock *sk);
 int netlbl_sock_getattr(struct sock *sk,
@@ -413,6 +415,8 @@ int netlbl_sock_getattr(struct sock *sk,
 int netlbl_conn_setattr(struct sock *sk,
 			struct sockaddr *addr,
 			const struct netlbl_lsm_secattr *secattr);
+int netlbl_req_setattr(struct request_sock *req,
+		       const struct netlbl_lsm_secattr *secattr);
 int netlbl_skbuff_setattr(struct sk_buff *skb,
 			  u16 family,
 			  const struct netlbl_lsm_secattr *secattr);
@@ -519,7 +523,8 @@ static inline int netlbl_enabled(void)
 	return 0;
 }
 static inline int netlbl_sock_setattr(struct sock *sk,
-				     const struct netlbl_lsm_secattr *secattr)
+				      u16 family,
+				      const struct netlbl_lsm_secattr *secattr)
 {
 	return -ENOSYS;
 }
@@ -537,6 +542,11 @@ static inline int netlbl_conn_setattr(struct sock *sk,
 {
 	return -ENOSYS;
 }
+static inline int netlbl_req_setattr(struct request_sock *req,
+				     const struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
 static inline int netlbl_skbuff_setattr(struct sk_buff *skb,
 				      u16 family,
 				      const struct netlbl_lsm_secattr *secattr)
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 7bc9929..039cc1f 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1942,23 +1942,85 @@ socket_setattr_failure:
 }
 
 /**
- * cipso_v4_sock_delattr - Delete the CIPSO option from a socket
- * @sk: the socket
+ * cipso_v4_req_setattr - Add a CIPSO option to a connection request socket
+ * @req: the connection request socket
+ * @doi_def: the CIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
  *
  * Description:
- * Removes the CIPSO option from a socket, if present.
+ * Set the CIPSO option on the given socket using the DOI definition and
+ * security attributes passed to the function.  Returns zero on success and
+ * negative values on failure.
  *
  */
-void cipso_v4_sock_delattr(struct sock *sk)
+int cipso_v4_req_setattr(struct request_sock *req,
+			 const struct cipso_v4_doi *doi_def,
+			 const struct netlbl_lsm_secattr *secattr)
 {
-	u8 hdr_delta;
-	struct ip_options *opt;
-	struct inet_sock *sk_inet;
+	int ret_val = -EPERM;
+	unsigned char *buf = NULL;
+	u32 buf_len;
+	u32 opt_len;
+	struct ip_options *opt = NULL;
+	struct inet_request_sock *req_inet;
 
-	sk_inet = inet_sk(sk);
-	opt = sk_inet->opt;
-	if (opt == NULL || opt->cipso == 0)
-		return;
+	/* We allocate the maximum CIPSO option size here so we are probably
+	 * being a little wasteful, but it makes our life _much_ easier later
+	 * on and after all we are only talking about 40 bytes. */
+	buf_len = CIPSO_V4_OPT_LEN_MAX;
+	buf = kmalloc(buf_len, GFP_ATOMIC);
+	if (buf == NULL) {
+		ret_val = -ENOMEM;
+		goto req_setattr_failure;
+	}
+
+	ret_val = cipso_v4_genopt(buf, buf_len, doi_def, secattr);
+	if (ret_val < 0)
+		goto req_setattr_failure;
+	buf_len = ret_val;
+
+	/* We can't use ip_options_get() directly because it makes a call to
+	 * ip_options_get_alloc() which allocates memory with GFP_KERNEL and
+	 * we won't always have CAP_NET_RAW even though we _always_ want to
+	 * set the IPOPT_CIPSO option. */
+	opt_len = (buf_len + 3) & ~3;
+	opt = kzalloc(sizeof(*opt) + opt_len, GFP_ATOMIC);
+	if (opt == NULL) {
+		ret_val = -ENOMEM;
+		goto req_setattr_failure;
+	}
+	memcpy(opt->__data, buf, buf_len);
+	opt->optlen = opt_len;
+	opt->cipso = sizeof(struct iphdr);
+	kfree(buf);
+	buf = NULL;
+
+	req_inet = inet_rsk(req);
+	opt = xchg(&req_inet->opt, opt);
+	kfree(opt);
+
+	return 0;
+
+req_setattr_failure:
+	kfree(buf);
+	kfree(opt);
+	return ret_val;
+}
+
+/**
+ * cipso_v4_delopt - Delete the CIPSO option from a set of IP options
+ * @opt_ptr: IP option pointer
+ *
+ * Description:
+ * Deletes the CIPSO IP option from a set of IP options and makes the necessary
+ * adjustments to the IP option structure.  Returns zero on success, negative
+ * values on failure.
+ *
+ */
+int cipso_v4_delopt(struct ip_options **opt_ptr)
+{
+	int hdr_delta = 0;
+	struct ip_options *opt = *opt_ptr;
 
 	if (opt->srr || opt->rr || opt->ts || opt->router_alert) {
 		u8 cipso_len;
@@ -2003,11 +2065,34 @@ void cipso_v4_sock_delattr(struct sock *sk)
 	} else {
 		/* only the cipso option was present on the socket so we can
 		 * remove the entire option struct */
-		sk_inet->opt = NULL;
+		*opt_ptr = NULL;
 		hdr_delta = opt->optlen;
 		kfree(opt);
 	}
 
+	return hdr_delta;
+}
+
+/**
+ * cipso_v4_sock_delattr - Delete the CIPSO option from a socket
+ * @sk: the socket
+ *
+ * Description:
+ * Removes the CIPSO option from a socket, if present.
+ *
+ */
+void cipso_v4_sock_delattr(struct sock *sk)
+{
+	int hdr_delta;
+	struct ip_options *opt;
+	struct inet_sock *sk_inet;
+
+	sk_inet = inet_sk(sk);
+	opt = sk_inet->opt;
+	if (opt == NULL || opt->cipso == 0)
+		return;
+
+	hdr_delta = cipso_v4_delopt(&sk_inet->opt);
 	if (sk_inet->is_icsk && hdr_delta > 0) {
 		struct inet_connection_sock *sk_conn = inet_csk(sk);
 		sk_conn->icsk_ext_hdr_len -= hdr_delta;
@@ -2016,6 +2101,27 @@ void cipso_v4_sock_delattr(struct sock *sk)
 }
 
 /**
+ * cipso_v4_req_delattr - Delete the CIPSO option from a request socket
+ * @reg: the request socket
+ *
+ * Description:
+ * Removes the CIPSO option from a request socket, if present.
+ *
+ */
+void cipso_v4_req_delattr(struct request_sock *req)
+{
+	struct ip_options *opt;
+	struct inet_request_sock *req_inet;
+
+	req_inet = inet_rsk(req);
+	opt = req_inet->opt;
+	if (opt == NULL || opt->cipso == 0)
+		return;
+
+	cipso_v4_delopt(&req_inet->opt);
+}
+
+/**
  * cipso_v4_getattr - Helper function for the cipso_v4_*_getattr functions
  * @cipso: the CIPSO v4 option
  * @secattr: the security attributes
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index fd9229d..cae2f5f 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -619,8 +619,9 @@ int netlbl_enabled(void)
 }
 
 /**
- * netlbl_socket_setattr - Label a socket using the correct protocol
+ * netlbl_sock_setattr - Label a socket using the correct protocol
  * @sk: the socket to label
+ * @family: protocol family
  * @secattr: the security attributes
  *
  * Description:
@@ -633,29 +634,45 @@ int netlbl_enabled(void)
  *
  */
 int netlbl_sock_setattr(struct sock *sk,
+			u16 family,
 			const struct netlbl_lsm_secattr *secattr)
 {
-	int ret_val = -ENOENT;
+	int ret_val;
 	struct netlbl_dom_map *dom_entry;
 
 	rcu_read_lock();
 	dom_entry = netlbl_domhsh_getentry(secattr->domain);
-	if (dom_entry == NULL)
+	if (dom_entry == NULL) {
+		ret_val = -ENOENT;
 		goto socket_setattr_return;
-	switch (dom_entry->type) {
-	case NETLBL_NLTYPE_ADDRSELECT:
-		ret_val = -EDESTADDRREQ;
-		break;
-	case NETLBL_NLTYPE_CIPSOV4:
-		ret_val = cipso_v4_sock_setattr(sk,
-						dom_entry->type_def.cipsov4,
-						secattr);
+	}
+	switch (family) {
+	case AF_INET:
+		switch (dom_entry->type) {
+		case NETLBL_NLTYPE_ADDRSELECT:
+			ret_val = -EDESTADDRREQ;
+			break;
+		case NETLBL_NLTYPE_CIPSOV4:
+			ret_val = cipso_v4_sock_setattr(sk,
+						    dom_entry->type_def.cipsov4,
+						    secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			ret_val = 0;
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
 		break;
-	case NETLBL_NLTYPE_UNLABELED:
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		/* since we don't support any IPv6 labeling protocols right
+		 * now we can optimize everything away until we do */
 		ret_val = 0;
 		break;
+#endif /* IPv6 */
 	default:
-		ret_val = -ENOENT;
+		ret_val = -EPROTONOSUPPORT;
 	}
 
 socket_setattr_return:
@@ -689,9 +706,25 @@ void netlbl_sock_delattr(struct sock *sk)
  * on failure.
  *
  */
-int netlbl_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
+int netlbl_sock_getattr(struct sock *sk,
+			struct netlbl_lsm_secattr *secattr)
 {
-	return cipso_v4_sock_getattr(sk, secattr);
+	int ret_val;
+
+	switch (sk->sk_family) {
+	case AF_INET:
+		ret_val = cipso_v4_sock_getattr(sk, secattr);
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		ret_val = -ENOMSG;
+		break;
+#endif /* IPv6 */
+	default:
+		ret_val = -EPROTONOSUPPORT;
+	}
+
+	return ret_val;
 }
 
 /**
@@ -748,7 +781,7 @@ int netlbl_conn_setattr(struct sock *sk,
 		break;
 #endif /* IPv6 */
 	default:
-		ret_val = 0;
+		ret_val = -EPROTONOSUPPORT;
 	}
 
 conn_setattr_return:
@@ -757,6 +790,77 @@ conn_setattr_return:
 }
 
 /**
+ * netlbl_req_setattr - Label a request socket using the correct protocol
+ * @req: the request socket to label
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Attach the correct label to the given socket using the security attributes
+ * specified in @secattr.  Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_req_setattr(struct request_sock *req,
+		       const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val;
+	struct netlbl_dom_map *dom_entry;
+	struct netlbl_domaddr4_map *af4_entry;
+	u32 proto_type;
+	struct cipso_v4_doi *proto_cv4;
+
+	rcu_read_lock();
+	dom_entry = netlbl_domhsh_getentry(secattr->domain);
+	if (dom_entry == NULL) {
+		ret_val = -ENOENT;
+		goto req_setattr_return;
+	}
+	switch (req->rsk_ops->family) {
+	case AF_INET:
+		if (dom_entry->type == NETLBL_NLTYPE_ADDRSELECT) {
+			struct inet_request_sock *req_inet = inet_rsk(req);
+			af4_entry = netlbl_domhsh_getentry_af4(secattr->domain,
+							    req_inet->rmt_addr);
+			if (af4_entry == NULL) {
+				ret_val = -ENOENT;
+				goto req_setattr_return;
+			}
+			proto_type = af4_entry->type;
+			proto_cv4 = af4_entry->type_def.cipsov4;
+		} else {
+			proto_type = dom_entry->type;
+			proto_cv4 = dom_entry->type_def.cipsov4;
+		}
+		switch (proto_type) {
+		case NETLBL_NLTYPE_CIPSOV4:
+			ret_val = cipso_v4_req_setattr(req, proto_cv4, secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			/* just delete the protocols we support for right now
+			 * but we could remove other protocols if needed */
+			cipso_v4_req_delattr(req);
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
+		ret_val = -EPROTONOSUPPORT;
+	}
+
+req_setattr_return:
+	rcu_read_unlock();
+	return ret_val;
+}
+
+/**
  * netlbl_skbuff_setattr - Label a packet using the correct protocol
  * @skb: the packet
  * @family: protocol family
@@ -808,7 +912,7 @@ int netlbl_skbuff_setattr(struct sk_buff *skb,
 		break;
 #endif /* IPv6 */
 	default:
-		ret_val = 0;
+		ret_val = -EPROTONOSUPPORT;
 	}
 
 skbuff_setattr_return:
@@ -833,9 +937,17 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  u16 family,
 			  struct netlbl_lsm_secattr *secattr)
 {
-	if (CIPSO_V4_OPTEXIST(skb) &&
-	    cipso_v4_skbuff_getattr(skb, secattr) == 0)
-		return 0;
+	switch (family) {
+	case AF_INET:
+		if (CIPSO_V4_OPTEXIST(skb) &&
+		    cipso_v4_skbuff_getattr(skb, secattr) == 0)
+			return 0;
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		break;
+#endif /* IPv6 */
+	}
 
 	return netlbl_unlabel_getattr(skb, family, secattr);
 }
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 7c52ba2..ee2e781 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -311,7 +311,7 @@ static int sk_alloc_security(struct sock *sk, int family, gfp_t priority)
 	ssec->sid = SECINITSID_UNLABELED;
 	sk->sk_security = ssec;
 
-	selinux_netlbl_sk_security_reset(ssec, family);
+	selinux_netlbl_sk_security_reset(ssec);
 
 	return 0;
 }
@@ -2945,7 +2945,6 @@ static void selinux_inode_getsecid(const struct inode *inode, u32 *secid)
 static int selinux_revalidate_file_permission(struct file *file, int mask)
 {
 	const struct cred *cred = current_cred();
-	int rc;
 	struct inode *inode = file->f_path.dentry->d_inode;
 
 	if (!mask) {
@@ -2957,29 +2956,15 @@ static int selinux_revalidate_file_permission(struct file *file, int mask)
 	if ((file->f_flags & O_APPEND) && (mask & MAY_WRITE))
 		mask |= MAY_APPEND;
 
-	rc = file_has_perm(cred, file,
-			   file_mask_to_av(inode->i_mode, mask));
-	if (rc)
-		return rc;
-
-	return selinux_netlbl_inode_permission(inode, mask);
+	return file_has_perm(cred, file,
+			     file_mask_to_av(inode->i_mode, mask));
 }
 
 static int selinux_file_permission(struct file *file, int mask)
 {
-	struct inode *inode = file->f_path.dentry->d_inode;
-	struct file_security_struct *fsec = file->f_security;
-	struct inode_security_struct *isec = inode->i_security;
-	u32 sid = current_sid();
-
-	if (!mask) {
+	if (!mask)
 		/* No permission to check.  Existence test. */
 		return 0;
-	}
-
-	if (sid == fsec->sid && fsec->isid == isec->sid
-	    && fsec->pseqno == avc_policy_seqno())
-		return selinux_netlbl_inode_permission(inode, mask);
 
 	return selinux_revalidate_file_permission(file, mask);
 }
@@ -3723,7 +3708,7 @@ static int selinux_socket_post_create(struct socket *sock, int family,
 		sksec = sock->sk->sk_security;
 		sksec->sid = isec->sid;
 		sksec->sclass = isec->sclass;
-		err = selinux_netlbl_socket_post_create(sock);
+		err = selinux_netlbl_socket_post_create(sock->sk, family);
 	}
 
 	return err;
@@ -3914,13 +3899,7 @@ static int selinux_socket_accept(struct socket *sock, struct socket *newsock)
 static int selinux_socket_sendmsg(struct socket *sock, struct msghdr *msg,
 				  int size)
 {
-	int rc;
-
-	rc = socket_has_perm(current, sock, SOCKET__WRITE);
-	if (rc)
-		return rc;
-
-	return selinux_netlbl_inode_permission(SOCK_INODE(sock), MAY_WRITE);
+	return socket_has_perm(current, sock, SOCKET__WRITE);
 }
 
 static int selinux_socket_recvmsg(struct socket *sock, struct msghdr *msg,
@@ -4304,7 +4283,7 @@ static void selinux_sk_clone_security(const struct sock *sk, struct sock *newsk)
 	newssec->peer_sid = ssec->peer_sid;
 	newssec->sclass = ssec->sclass;
 
-	selinux_netlbl_sk_security_reset(newssec, newsk->sk_family);
+	selinux_netlbl_sk_security_reset(newssec);
 }
 
 static void selinux_sk_getsecid(struct sock *sk, u32 *secid)
@@ -4348,16 +4327,15 @@ static int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb,
 	if (peersid == SECSID_NULL) {
 		req->secid = sksec->sid;
 		req->peer_secid = SECSID_NULL;
-		return 0;
+	} else {
+		err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
+		if (err)
+			return err;
+		req->secid = newsid;
+		req->peer_secid = peersid;
 	}
 
-	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
-	if (err)
-		return err;
-
-	req->secid = newsid;
-	req->peer_secid = peersid;
-	return 0;
+	return selinux_netlbl_inet_conn_request(req, family);
 }
 
 static void selinux_inet_csk_clone(struct sock *newsk,
@@ -4374,7 +4352,7 @@ static void selinux_inet_csk_clone(struct sock *newsk,
 
 	/* We don't need to take any sort of lock here as we are the only
 	 * thread with access to newsksec */
-	selinux_netlbl_sk_security_reset(newsksec, req->rsk_ops->family);
+	selinux_netlbl_inet_csk_clone(newsk, req->rsk_ops->family);
 }
 
 static void selinux_inet_conn_established(struct sock *sk, struct sk_buff *skb)
@@ -4387,8 +4365,6 @@ static void selinux_inet_conn_established(struct sock *sk, struct sk_buff *skb)
 		family = PF_INET;
 
 	selinux_skb_peerlbl_sid(skb, family, &sksec->peer_sid);
-
-	selinux_netlbl_inet_conn_established(sk, family);
 }
 
 static void selinux_req_classify_flow(const struct request_sock *req,
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index b913c8d..b4b5b9b 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -32,6 +32,7 @@
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
+#include <net/request_sock.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -42,8 +43,7 @@ void selinux_netlbl_cache_invalidate(void);
 void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway);
 
 void selinux_netlbl_sk_security_free(struct sk_security_struct *ssec);
-void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
-				      int family);
+void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec);
 
 int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
 				 u16 family,
@@ -53,9 +53,9 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 				 u16 family,
 				 u32 sid);
 
-void selinux_netlbl_inet_conn_established(struct sock *sk, u16 family);
-int selinux_netlbl_socket_post_create(struct socket *sock);
-int selinux_netlbl_inode_permission(struct inode *inode, int mask);
+int selinux_netlbl_inet_conn_request(struct request_sock *req, u16 family);
+void selinux_netlbl_inet_csk_clone(struct sock *sk, u16 family);
+int selinux_netlbl_socket_post_create(struct sock *sk, u16 family);
 int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 				struct sk_buff *skb,
 				u16 family,
@@ -85,8 +85,7 @@ static inline void selinux_netlbl_sk_security_free(
 }
 
 static inline void selinux_netlbl_sk_security_reset(
-					       struct sk_security_struct *ssec,
-					       int family)
+					       struct sk_security_struct *ssec)
 {
 	return;
 }
@@ -113,17 +112,17 @@ static inline int selinux_netlbl_conn_setsid(struct sock *sk,
 	return 0;
 }
 
-static inline void selinux_netlbl_inet_conn_established(struct sock *sk,
-							u16 family)
+static inline int selinux_netlbl_inet_conn_request(struct request_sock *req,
+						   u16 family)
 {
-	return;
+	return 0;
 }
-static inline int selinux_netlbl_socket_post_create(struct socket *sock)
+static inline void selinux_netlbl_inet_csk_clone(struct sock *sk, u16 family)
 {
-	return 0;
+	return;
 }
-static inline int selinux_netlbl_inode_permission(struct inode *inode,
-						  int mask)
+static inline int selinux_netlbl_socket_post_create(struct sock *sk,
+						    u16 family)
 {
 	return 0;
 }
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 350794a..2e98441 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -100,41 +100,6 @@ static struct netlbl_lsm_secattr *selinux_netlbl_sock_genattr(struct sock *sk)
 }
 
 /**
- * selinux_netlbl_sock_setsid - Label a socket using the NetLabel mechanism
- * @sk: the socket to label
- *
- * Description:
- * Attempt to label a socket using the NetLabel mechanism.  Returns zero values
- * on success, negative values on failure.
- *
- */
-static int selinux_netlbl_sock_setsid(struct sock *sk)
-{
-	int rc;
-	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr *secattr;
-
-	if (sksec->nlbl_state != NLBL_REQUIRE)
-		return 0;
-
-	secattr = selinux_netlbl_sock_genattr(sk);
-	if (secattr == NULL)
-		return -ENOMEM;
-	rc = netlbl_sock_setattr(sk, secattr);
-	switch (rc) {
-	case 0:
-		sksec->nlbl_state = NLBL_LABELED;
-		break;
-	case -EDESTADDRREQ:
-		sksec->nlbl_state = NLBL_REQSKB;
-		rc = 0;
-		break;
-	}
-
-	return rc;
-}
-
-/**
  * selinux_netlbl_cache_invalidate - Invalidate the NetLabel cache
  *
  * Description:
@@ -188,13 +153,9 @@ void selinux_netlbl_sk_security_free(struct sk_security_struct *ssec)
  * The caller is responsibile for all the NetLabel sk_security_struct locking.
  *
  */
-void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
-				      int family)
+void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec)
 {
-	if (family == PF_INET)
-		ssec->nlbl_state = NLBL_REQUIRE;
-	else
-		ssec->nlbl_state = NLBL_UNSET;
+	ssec->nlbl_state = NLBL_UNSET;
 }
 
 /**
@@ -281,127 +242,86 @@ skbuff_setsid_return:
 }
 
 /**
- * selinux_netlbl_inet_conn_established - Netlabel the newly accepted connection
- * @sk: the new connection
+ * selinux_netlbl_inet_conn_request - Label an incoming stream connection
+ * @req: incoming connection request socket
  *
  * Description:
- * A new connection has been established on @sk so make sure it is labeled
- * correctly with the NetLabel susbsystem.
+ * A new incoming connection request is represented by @req, we need to label
+ * the new request_sock here and the stack will ensure the on-the-wire label
+ * will get preserved when a full sock is created once the connection handshake
+ * is complete.  Returns zero on success, negative values on failure.
  *
  */
-void selinux_netlbl_inet_conn_established(struct sock *sk, u16 family)
+int selinux_netlbl_inet_conn_request(struct request_sock *req, u16 family)
 {
 	int rc;
-	struct sk_security_struct *sksec = sk->sk_security;
-	struct netlbl_lsm_secattr *secattr;
-	struct inet_sock *sk_inet = inet_sk(sk);
-	struct sockaddr_in addr;
-
-	if (sksec->nlbl_state != NLBL_REQUIRE)
-		return;
+	struct netlbl_lsm_secattr secattr;
 
-	secattr = selinux_netlbl_sock_genattr(sk);
-	if (secattr == NULL)
-		return;
+	if (family != PF_INET)
+		return 0;
 
-	rc = netlbl_sock_setattr(sk, secattr);
-	switch (rc) {
-	case 0:
-		sksec->nlbl_state = NLBL_LABELED;
-		break;
-	case -EDESTADDRREQ:
-		/* no PF_INET6 support yet because we don't support any IPv6
-		 * labeling protocols */
-		if (family != PF_INET) {
-			sksec->nlbl_state = NLBL_UNSET;
-			return;
-		}
-
-		addr.sin_family = family;
-		addr.sin_addr.s_addr = sk_inet->daddr;
-		if (netlbl_conn_setattr(sk, (struct sockaddr *)&addr,
-					secattr) != 0) {
-			/* we failed to label the connected socket (could be
-			 * for a variety of reasons, the actual "why" isn't
-			 * important here) so we have to go to our backup plan,
-			 * labeling the packets individually in the netfilter
-			 * local output hook.  this is okay but we need to
-			 * adjust the MSS of the connection to take into
-			 * account any labeling overhead, since we don't know
-			 * the exact overhead at this point we'll use the worst
-			 * case value which is 40 bytes for IPv4 */
-			struct inet_connection_sock *sk_conn = inet_csk(sk);
-			sk_conn->icsk_ext_hdr_len += 40 -
-				      (sk_inet->opt ? sk_inet->opt->optlen : 0);
-			sk_conn->icsk_sync_mss(sk, sk_conn->icsk_pmtu_cookie);
-
-			sksec->nlbl_state = NLBL_REQSKB;
-		} else
-			sksec->nlbl_state = NLBL_CONNLABELED;
-		break;
-	default:
-		/* note that we are failing to label the socket which could be
-		 * a bad thing since it means traffic could leave the system
-		 * without the desired labeling, however, all is not lost as
-		 * we have a check in selinux_netlbl_inode_permission() to
-		 * pick up the pieces that we might drop here because we can't
-		 * return an error code */
-		break;
-	}
+	netlbl_secattr_init(&secattr);
+	rc = security_netlbl_sid_to_secattr(req->secid, &secattr);
+	if (rc != 0)
+		goto inet_conn_request_return;
+	rc = netlbl_req_setattr(req, &secattr);
+inet_conn_request_return:
+	netlbl_secattr_destroy(&secattr);
+	return rc;
 }
 
 /**
- * selinux_netlbl_socket_post_create - Label a socket using NetLabel
- * @sock: the socket to label
+ * selinux_netlbl_inet_csk_clone - Initialize the newly created sock
+ * @sk: the new sock
  *
  * Description:
- * Attempt to label a socket using the NetLabel mechanism using the given
- * SID.  Returns zero values on success, negative values on failure.
+ * A new connection has been established using @sk, we've already labeled the
+ * socket via the request_sock struct in selinux_netlbl_inet_conn_request() but
+ * we need to set the NetLabel state here since we now have a sock structure.
  *
  */
-int selinux_netlbl_socket_post_create(struct socket *sock)
+void selinux_netlbl_inet_csk_clone(struct sock *sk, u16 family)
 {
-	return selinux_netlbl_sock_setsid(sock->sk);
+	struct sk_security_struct *sksec = sk->sk_security;
+
+	if (family == PF_INET)
+		sksec->nlbl_state = NLBL_LABELED;
+	else
+		sksec->nlbl_state = NLBL_UNSET;
 }
 
 /**
- * selinux_netlbl_inode_permission - Verify the socket is NetLabel labeled
- * @inode: the file descriptor's inode
- * @mask: the permission mask
+ * selinux_netlbl_socket_post_create - Label a socket using NetLabel
+ * @sock: the socket to label
+ * @family: protocol family
  *
  * Description:
- * Looks at a file's inode and if it is marked as a socket protected by
- * NetLabel then verify that the socket has been labeled, if not try to label
- * the socket now with the inode's SID.  Returns zero on success, negative
- * values on failure.
+ * Attempt to label a socket using the NetLabel mechanism using the given
+ * SID.  Returns zero values on success, negative values on failure.
  *
  */
-int selinux_netlbl_inode_permission(struct inode *inode, int mask)
+int selinux_netlbl_socket_post_create(struct sock *sk, u16 family)
 {
 	int rc;
-	struct sock *sk;
-	struct socket *sock;
-	struct sk_security_struct *sksec;
+	struct sk_security_struct *sksec = sk->sk_security;
+	struct netlbl_lsm_secattr *secattr;
 
-	if (!S_ISSOCK(inode->i_mode) ||
-	    ((mask & (MAY_WRITE | MAY_APPEND)) == 0))
-		return 0;
-	sock = SOCKET_I(inode);
-	sk = sock->sk;
-	if (sk == NULL)
-		return 0;
-	sksec = sk->sk_security;
-	if (sksec == NULL || sksec->nlbl_state != NLBL_REQUIRE)
+	if (family != PF_INET)
 		return 0;
 
-	local_bh_disable();
-	bh_lock_sock_nested(sk);
-	if (likely(sksec->nlbl_state == NLBL_REQUIRE))
-		rc = selinux_netlbl_sock_setsid(sk);
-	else
+	secattr = selinux_netlbl_sock_genattr(sk);
+	if (secattr == NULL)
+		return -ENOMEM;
+	rc = netlbl_sock_setattr(sk, family, secattr);
+	switch (rc) {
+	case 0:
+		sksec->nlbl_state = NLBL_LABELED;
+		break;
+	case -EDESTADDRREQ:
+		sksec->nlbl_state = NLBL_REQSKB;
 		rc = 0;
-	bh_unlock_sock(sk);
-	local_bh_enable();
+		break;
+	}
 
 	return rc;
 }
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index fd20d15..23ad420 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1387,7 +1387,7 @@ static int smack_netlabel(struct sock *sk, int labeled)
 	else {
 		netlbl_secattr_init(&secattr);
 		smack_to_secattr(ssp->smk_out, &secattr);
-		rc = netlbl_sock_setattr(sk, &secattr);
+		rc = netlbl_sock_setattr(sk, sk->sk_family, &secattr);
 		netlbl_secattr_destroy(&secattr);
 	}
 

