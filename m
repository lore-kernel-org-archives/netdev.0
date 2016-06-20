From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 13/19] calipso: Allow request sockets to be relabelled by the lsm.
Date: Mon, 20 Jun 2016 14:36:53 +0100
Message-ID: <1466429819-12707-14-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:49028 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163AbcFTNxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 09:53:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Request sockets need to have a label that takes into account the
incoming connection as well as their parent's label.  This is used
for the outgoing SYN-ACK and for their child full-socket.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/netlabel.h          |  6 +++
 net/ipv6/calipso.c              | 86 +++++++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_calipso.c | 40 +++++++++++++++++++
 net/netlabel/netlabel_calipso.h |  4 ++
 net/netlabel/netlabel_kapi.c    | 39 +++++++++++++++----
 security/selinux/netlabel.c     |  2 +-
 6 files changed, 168 insertions(+), 9 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 918a604..a2408c3 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -229,6 +229,8 @@ struct netlbl_lsm_secattr {
  * @sock_getattr: retrieve the socket's attr
  * @sock_setattr: set the socket's attr
  * @sock_delattr: remove the socket's attr
+ * @req_setattr: set the req socket's attr
+ * @req_delattr: remove the req socket's attr
  *
  * Description:
  * This structure is filled out by the CALIPSO engine and passed
@@ -252,6 +254,10 @@ struct netlbl_calipso_ops {
 			    const struct calipso_doi *doi_def,
 			    const struct netlbl_lsm_secattr *secattr);
 	void (*sock_delattr)(struct sock *sk);
+	int (*req_setattr)(struct request_sock *req,
+			   const struct calipso_doi *doi_def,
+			   const struct netlbl_lsm_secattr *secattr);
+	void (*req_delattr)(struct request_sock *req);
 };
 
 /*
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index 959db52..067a564 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -889,6 +889,90 @@ done:
 	txopt_put(txopts);
 }
 
+/* request sock functions.
+ */
+
+/**
+ * calipso_req_setattr - Add a CALIPSO option to a connection request socket
+ * @req: the connection request socket
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
+ *
+ * Description:
+ * Set the CALIPSO option on the given socket using the DOI definition and
+ * security attributes passed to the function.  Returns zero on success and
+ * negative values on failure.
+ *
+ */
+static int calipso_req_setattr(struct request_sock *req,
+			       const struct calipso_doi *doi_def,
+			       const struct netlbl_lsm_secattr *secattr)
+{
+	struct ipv6_txoptions *txopts;
+	struct inet_request_sock *req_inet = inet_rsk(req);
+	struct ipv6_opt_hdr *old, *new;
+	struct sock *sk = sk_to_full_sk(req_to_sk(req));
+
+	if (req_inet->ipv6_opt && req_inet->ipv6_opt->hopopt)
+		old = req_inet->ipv6_opt->hopopt;
+	else
+		old = NULL;
+
+	new = calipso_opt_insert(old, doi_def, secattr);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+
+	txopts = ipv6_renew_options_kern(sk, req_inet->ipv6_opt, IPV6_HOPOPTS,
+					 new, new ? ipv6_optlen(new) : 0);
+
+	kfree(new);
+
+	if (IS_ERR(txopts))
+		return PTR_ERR(txopts);
+
+	txopts = xchg(&req_inet->ipv6_opt, txopts);
+	if (txopts) {
+		atomic_sub(txopts->tot_len, &sk->sk_omem_alloc);
+		txopt_put(txopts);
+	}
+
+	return 0;
+}
+
+/**
+ * calipso_req_delattr - Delete the CALIPSO option from a request socket
+ * @reg: the request socket
+ *
+ * Description:
+ * Removes the CALIPSO option from a request socket, if present.
+ *
+ */
+static void calipso_req_delattr(struct request_sock *req)
+{
+	struct inet_request_sock *req_inet = inet_rsk(req);
+	struct ipv6_opt_hdr *new;
+	struct ipv6_txoptions *txopts;
+	struct sock *sk = sk_to_full_sk(req_to_sk(req));
+
+	if (!req_inet->ipv6_opt || !req_inet->ipv6_opt->hopopt)
+		return;
+
+	if (calipso_opt_del(req_inet->ipv6_opt->hopopt, &new))
+		return; /* Nothing to do */
+
+	txopts = ipv6_renew_options_kern(sk, req_inet->ipv6_opt, IPV6_HOPOPTS,
+					 new, new ? ipv6_optlen(new) : 0);
+
+	if (!IS_ERR(txopts)) {
+		txopts = xchg(&req_inet->ipv6_opt, txopts);
+		if (txopts) {
+			atomic_sub(txopts->tot_len, &sk->sk_omem_alloc);
+			txopt_put(txopts);
+		}
+	}
+	kfree(new);
+}
+
 static const struct netlbl_calipso_ops ops = {
 	.doi_add          = calipso_doi_add,
 	.doi_free         = calipso_doi_free,
@@ -899,6 +983,8 @@ static const struct netlbl_calipso_ops ops = {
 	.sock_getattr     = calipso_sock_getattr,
 	.sock_setattr     = calipso_sock_setattr,
 	.sock_delattr     = calipso_sock_delattr,
+	.req_setattr      = calipso_req_setattr,
+	.req_delattr      = calipso_req_delattr,
 };
 
 /**
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 6f9c658..79519e3 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -578,3 +578,43 @@ void calipso_sock_delattr(struct sock *sk)
 	if (ops)
 		ops->sock_delattr(sk);
 }
+
+/**
+ * calipso_req_setattr - Add a CALIPSO option to a connection request socket
+ * @req: the connection request socket
+ * @doi_def: the CALIPSO DOI to use
+ * @secattr: the specific security attributes of the socket
+ *
+ * Description:
+ * Set the CALIPSO option on the given socket using the DOI definition and
+ * security attributes passed to the function.  Returns zero on success and
+ * negative values on failure.
+ *
+ */
+int calipso_req_setattr(struct request_sock *req,
+			const struct calipso_doi *doi_def,
+			const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->req_setattr(req, doi_def, secattr);
+	return ret_val;
+}
+
+/**
+ * calipso_req_delattr - Delete the CALIPSO option from a request socket
+ * @reg: the request socket
+ *
+ * Description:
+ * Removes the CALIPSO option from a request socket, if present.
+ *
+ */
+void calipso_req_delattr(struct request_sock *req)
+{
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ops->req_delattr(req);
+}
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
index 49bc116..1372fdd 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -133,5 +133,9 @@ int calipso_sock_setattr(struct sock *sk,
 			 const struct calipso_doi *doi_def,
 			 const struct netlbl_lsm_secattr *secattr);
 void calipso_sock_delattr(struct sock *sk);
+int calipso_req_setattr(struct request_sock *req,
+			const struct calipso_doi *doi_def,
+			const struct netlbl_lsm_secattr *secattr);
+void calipso_req_delattr(struct request_sock *req);
 
 #endif
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index ed35ad9..71ebef0 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1054,12 +1054,13 @@ int netlbl_req_setattr(struct request_sock *req,
 {
 	int ret_val;
 	struct netlbl_dommap_def *entry;
+	struct inet_request_sock *ireq = inet_rsk(req);
 
 	rcu_read_lock();
 	switch (req->rsk_ops->family) {
 	case AF_INET:
 		entry = netlbl_domhsh_getentry_af4(secattr->domain,
-						   inet_rsk(req)->ir_rmt_addr);
+						   ireq->ir_rmt_addr);
 		if (entry == NULL) {
 			ret_val = -ENOENT;
 			goto req_setattr_return;
@@ -1070,9 +1071,7 @@ int netlbl_req_setattr(struct request_sock *req,
 						       entry->cipso, secattr);
 			break;
 		case NETLBL_NLTYPE_UNLABELED:
-			/* just delete the protocols we support for right now
-			 * but we could remove other protocols if needed */
-			cipso_v4_req_delattr(req);
+			netlbl_req_delattr(req);
 			ret_val = 0;
 			break;
 		default:
@@ -1081,9 +1080,24 @@ int netlbl_req_setattr(struct request_sock *req,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		/* since we don't support any IPv6 labeling protocols right
-		 * now we can optimize everything away until we do */
-		ret_val = 0;
+		entry = netlbl_domhsh_getentry_af6(secattr->domain,
+						   &ireq->ir_v6_rmt_addr);
+		if (entry == NULL) {
+			ret_val = -ENOENT;
+			goto req_setattr_return;
+		}
+		switch (entry->type) {
+		case NETLBL_NLTYPE_CALIPSO:
+			ret_val = calipso_req_setattr(req,
+						      entry->calipso, secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			netlbl_req_delattr(req);
+			ret_val = 0;
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
 		break;
 #endif /* IPv6 */
 	default:
@@ -1105,7 +1119,16 @@ req_setattr_return:
 */
 void netlbl_req_delattr(struct request_sock *req)
 {
-	cipso_v4_req_delattr(req);
+	switch (req->rsk_ops->family) {
+	case AF_INET:
+		cipso_v4_req_delattr(req);
+		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		calipso_req_delattr(req);
+		break;
+#endif /* IPv6 */
+	}
 }
 
 /**
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 2477a75..ca220c3 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -284,7 +284,7 @@ int selinux_netlbl_inet_conn_request(struct request_sock *req, u16 family)
 	int rc;
 	struct netlbl_lsm_secattr secattr;
 
-	if (family != PF_INET)
+	if (family != PF_INET && family != PF_INET6)
 		return 0;
 
 	netlbl_secattr_init(&secattr);
-- 
2.7.4
