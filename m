From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [RFC PATCH 13/17] calipso: Allow request sockets to be relabelled by
 the lsm.
Date: Tue, 22 Dec 2015 11:46:49 +0000
Message-ID: <1450784813-18304-14-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

Request sockets need to have a label that takes into account the
incoming connection as well as their parent's label.  This is used
for the outgoing SYN-ACK and for their child full-socket.

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 include/net/netlabel.h          |  6 ++++
 net/ipv6/calipso.c              | 78 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/exthdrs.c              | 16 ++++++---
 net/netlabel/netlabel_calipso.c | 40 +++++++++++++++++++++
 net/netlabel/netlabel_calipso.h |  4 +++
 net/netlabel/netlabel_kapi.c    | 39 ++++++++++++++++-----
 security/selinux/netlabel.c     |  2 +-
 7 files changed, 171 insertions(+), 14 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index b7ec76c..771a11c 100644
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
index ce803e2..5d72669 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -886,6 +886,82 @@ done:
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
+	txopts = ipv6_renew_options_kern(NULL, req_inet->ipv6_opt, IPV6_HOPOPTS,
+					 new, new ? ipv6_optlen(new) : 0);
+
+	kfree(new);
+
+	if (IS_ERR(txopts))
+		return PTR_ERR(txopts);
+
+	txopts = xchg(&req_inet->ipv6_opt, txopts);
+	txopt_put(txopts);
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
+
+	if (!req_inet->ipv6_opt || !req_inet->ipv6_opt->hopopt)
+		return;
+
+	if (calipso_opt_del(req_inet->ipv6_opt->hopopt, &new))
+		return; /* Nothing to do */
+
+	txopts = ipv6_renew_options_kern(NULL, req_inet->ipv6_opt, IPV6_HOPOPTS,
+					 new, new ? ipv6_optlen(new) : 0);
+
+	if (!IS_ERR(txopts)) {
+		txopts = xchg(&req_inet->ipv6_opt, txopts);
+		txopt_put(txopts);
+	}
+	kfree(new);
+}
+
 static const struct netlbl_calipso_ops ops = {
 	.doi_add          = calipso_doi_add,
 	.doi_free         = calipso_doi_free,
@@ -896,6 +972,8 @@ static const struct netlbl_calipso_ops ops = {
 	.sock_getattr     = calipso_sock_getattr,
 	.sock_setattr     = calipso_sock_setattr,
 	.sock_delattr     = calipso_sock_delattr,
+	.req_setattr      = calipso_req_setattr,
+	.req_delattr      = calipso_req_delattr,
 };
 
 /**
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 9426b26..e87c89b 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -793,7 +793,7 @@ static int ipv6_renew_option(void *ohdr,
  * specified option type is not copied into the new set of options.
  *
  * The new set of options is allocated from the socket option memory
- * buffer of @sk.
+ * buffer of @sk.  If @sk is NULL, then kmalloc() is used instead.
  */
 static struct ipv6_txoptions *
 __ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
@@ -828,7 +828,10 @@ __ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
 		return NULL;
 
 	tot_len += sizeof(*opt2);
-	opt2 = sock_kmalloc(sk, tot_len, GFP_ATOMIC);
+	if (sk)
+		opt2 = sock_kmalloc(sk, tot_len, GFP_ATOMIC);
+	else
+		opt2 = kmalloc(tot_len, GFP_ATOMIC);
 	if (!opt2)
 		return ERR_PTR(-ENOBUFS);
 
@@ -872,7 +875,10 @@ __ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
 
 	return opt2;
 out:
-	sock_kfree_s(sk, opt2, opt2->tot_len);
+	if (sk)
+		sock_kfree_s(sk, opt2, opt2->tot_len);
+	else
+		kfree(opt2);
 	return ERR_PTR(err);
 }
 
@@ -895,7 +901,7 @@ out:
  * copied into the new set of options.
  *
  * The new set of options is allocated from the socket option memory
- * buffer of @sk.
+ * buffer of @sk.  If @sk is NULL, then kmalloc() is used instead.
  */
 struct ipv6_txoptions *
 ipv6_renew_options_kern(struct sock *sk, struct ipv6_txoptions *opt,
@@ -925,7 +931,7 @@ ipv6_renew_options_kern(struct sock *sk, struct ipv6_txoptions *opt,
  * copied into the new set of options.
  *
  * The new set of options is allocated from the socket option memory
- * buffer of @sk.
+ * buffer of @sk.  If @sk is NULL, then kmalloc() is used instead.
  */
 struct ipv6_txoptions *
 ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 62e0b91..9a400b6 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -581,3 +581,43 @@ void calipso_sock_delattr(struct sock *sk)
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
index 214bbb1..9b8ef26 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -135,5 +135,9 @@ int calipso_sock_setattr(struct sock *sk,
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
1.8.0

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
