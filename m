From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] CIPSO: remove duplicated code in the cipso_v4_*_getattr()
	functions
Date: Wed, 12 Sep 2007 15:29:38 -0400
Message-ID: <20070912192938.18318.22897.stgit@flek.americas.hpqcorp.net>
References: <20070912192305.18318.11911.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:50035 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047AbXILTaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 15:30:06 -0400
In-Reply-To: <20070912192305.18318.11911.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bulk of the CIPSO option parsing/processing in the cipso_v4_sock_getattr()
and cipso_v4_skb_getattr() functions are identical, the only real difference
being where the functions obtain the CIPSO option itself.  This patch creates
a new function, cipso_v4_getattr(), which contains the common CIPSO option
parsing/processing code and modifies the existing functions to call this new
helper function.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/ipv4/cipso_ipv4.c |  115 ++++++++++++++++++-------------------------------
 1 files changed, 42 insertions(+), 73 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index ab56a05..805a78e 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1831,68 +1831,75 @@ socket_setattr_failure:
 }
 
 /**
- * cipso_v4_sock_getattr - Get the security attributes from a sock
- * @sk: the sock
+ * cipso_v4_getattr - Helper function for the cipso_v4_*_getattr functions
+ * @cipso: the CIPSO v4 option
  * @secattr: the security attributes
  *
  * Description:
- * Query @sk to see if there is a CIPSO option attached to the sock and if
- * there is return the CIPSO security attributes in @secattr.  This function
- * requires that @sk be locked, or privately held, but it does not do any
- * locking itself.  Returns zero on success and negative values on failure.
+ * Inspect @cipso and return the security attributes in @secattr.  Returns zero
+ * on success and negative values on failure.
  *
  */
-int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
+static int cipso_v4_getattr(const unsigned char *cipso,
+			    struct netlbl_lsm_secattr *secattr)
 {
 	int ret_val = -ENOMSG;
-	struct inet_sock *sk_inet;
-	unsigned char *cipso_ptr;
 	u32 doi;
 	struct cipso_v4_doi *doi_def;
 
-	sk_inet = inet_sk(sk);
-	if (sk_inet->opt == NULL || sk_inet->opt->cipso == 0)
-		return -ENOMSG;
-	cipso_ptr = sk_inet->opt->__data + sk_inet->opt->cipso -
-		sizeof(struct iphdr);
-	ret_val = cipso_v4_cache_check(cipso_ptr, cipso_ptr[1], secattr);
-	if (ret_val == 0)
-		return ret_val;
+	if (cipso_v4_cache_check(cipso, cipso[1], secattr) == 0)
+		return 0;
 
-	doi = ntohl(get_unaligned((__be32 *)&cipso_ptr[2]));
+	doi = ntohl(get_unaligned((__be32 *)&cipso[2]));
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_search(doi);
-	if (doi_def == NULL) {
-		rcu_read_unlock();
-		return -ENOMSG;
-	}
-
+	if (doi_def == NULL)
+		goto getattr_return;
 	/* XXX - This code assumes only one tag per CIPSO option which isn't
 	 * really a good assumption to make but since we only support the MAC
 	 * tags right now it is a safe assumption. */
-	switch (cipso_ptr[6]) {
+	switch (cipso[6]) {
 	case CIPSO_V4_TAG_RBITMAP:
-		ret_val = cipso_v4_parsetag_rbm(doi_def,
-						&cipso_ptr[6],
-						secattr);
+		ret_val = cipso_v4_parsetag_rbm(doi_def, &cipso[6], secattr);
 		break;
 	case CIPSO_V4_TAG_ENUM:
-		ret_val = cipso_v4_parsetag_enum(doi_def,
-						 &cipso_ptr[6],
-						 secattr);
+		ret_val = cipso_v4_parsetag_enum(doi_def, &cipso[6], secattr);
 		break;
 	case CIPSO_V4_TAG_RANGE:
-		ret_val = cipso_v4_parsetag_rng(doi_def,
-						&cipso_ptr[6],
-						secattr);
+		ret_val = cipso_v4_parsetag_rng(doi_def, &cipso[6], secattr);
 		break;
 	}
-	rcu_read_unlock();
 
+getattr_return:
+	rcu_read_unlock();
 	return ret_val;
 }
 
 /**
+ * cipso_v4_sock_getattr - Get the security attributes from a sock
+ * @sk: the sock
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Query @sk to see if there is a CIPSO option attached to the sock and if
+ * there is return the CIPSO security attributes in @secattr.  This function
+ * requires that @sk be locked, or privately held, but it does not do any
+ * locking itself.  Returns zero on success and negative values on failure.
+ *
+ */
+int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
+{
+	struct ip_options *opt;
+
+	opt = inet_sk(sk)->opt;
+	if (opt == NULL || opt->cipso == 0)
+		return -ENOMSG;
+
+	return cipso_v4_getattr(opt->__data + opt->cipso - sizeof(struct iphdr),
+				secattr);
+}
+
+/**
  * cipso_v4_skbuff_getattr - Get the security attributes from the CIPSO option
  * @skb: the packet
  * @secattr: the security attributes
@@ -1905,45 +1912,7 @@ int cipso_v4_sock_getattr(struct sock *sk, struct netlbl_lsm_secattr *secattr)
 int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 			    struct netlbl_lsm_secattr *secattr)
 {
-	int ret_val = -ENOMSG;
-	unsigned char *cipso_ptr;
-	u32 doi;
-	struct cipso_v4_doi *doi_def;
-
-	cipso_ptr = CIPSO_V4_OPTPTR(skb);
-	if (cipso_v4_cache_check(cipso_ptr, cipso_ptr[1], secattr) == 0)
-		return 0;
-
-	doi = ntohl(get_unaligned((__be32 *)&cipso_ptr[2]));
-	rcu_read_lock();
-	doi_def = cipso_v4_doi_search(doi);
-	if (doi_def == NULL)
-		goto skbuff_getattr_return;
-
-	/* XXX - This code assumes only one tag per CIPSO option which isn't
-	 * really a good assumption to make but since we only support the MAC
-	 * tags right now it is a safe assumption. */
-	switch (cipso_ptr[6]) {
-	case CIPSO_V4_TAG_RBITMAP:
-		ret_val = cipso_v4_parsetag_rbm(doi_def,
-						&cipso_ptr[6],
-						secattr);
-		break;
-	case CIPSO_V4_TAG_ENUM:
-		ret_val = cipso_v4_parsetag_enum(doi_def,
-						 &cipso_ptr[6],
-						 secattr);
-		break;
-	case CIPSO_V4_TAG_RANGE:
-		ret_val = cipso_v4_parsetag_rng(doi_def,
-						&cipso_ptr[6],
-						secattr);
-		break;
-	}
-
-skbuff_getattr_return:
-	rcu_read_unlock();
-	return ret_val;
+	return cipso_v4_getattr(CIPSO_V4_OPTPTR(skb), secattr);
 }
 
 /*

